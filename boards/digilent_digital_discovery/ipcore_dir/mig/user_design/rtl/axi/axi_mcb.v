// -- (c) Copyright 2010 Xilinx, Inc. All rights reserved.
// --
// -- This file contains confidential and proprietary information
// -- of Xilinx, Inc. and is protected under U.S. and
// -- international copyright and other intellectual property
// -- laws.
// --
// -- DISCLAIMER
// -- This disclaimer is not a license and does not grant any
// -- rights to the materials distributed herewith. Except as
// -- otherwise provided in a valid license issued to you by
// -- Xilinx, and to the maximum extent permitted by applicable
// -- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// -- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// -- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// -- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// -- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// -- (2) Xilinx shall not be liable (whether in contract or tort,
// -- including negligence, or under any other theory of
// -- liability) for any loss or damage of any kind or nature
// -- related to, arising under or in connection with these
// -- materials, including for any direct, or any indirect,
// -- special, incidental, or consequential loss or damage
// -- (including loss of data, profits, goodwill, or any type of
// -- loss or damage suffered as a result of any action brought
// -- by a third party) even if such damage or loss was
// -- reasonably foreseeable or Xilinx had been advised of the
// -- possibility of the same.
// --
// -- CRITICAL APPLICATIONS
// -- Xilinx products are not designed or intended to be fail-
// -- safe, or for use in any application requiring fail-safe
// -- performance, such as life-support or safety devices or
// -- systems, Class III medical devices, nuclear facilities,
// -- applications related to the deployment of airbags, or any
// -- other applications that could lead to death, personal
// -- injury, or severe property or environmental damage
// -- (individually and collectively, "Critical
// -- Applications"). Customer assumes the sole risk and
// -- liability of any use of Xilinx products in Critical
// -- Applications, subject only to applicable laws and
// -- regulations governing limitations on product liability.
// --
// -- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// -- PART OF THIS FILE AT ALL TIMES.
// --
///////////////////////////////////////////////////////////////////////////////
//
// File name: axi_mcb.v
//
// Description:
// To handle AXI4 transactions to external memory on Spartan-6 architectures
// requires a bridge to convert the AXI4 transactions to the MCB user
// interface.  The MCB user interface is a hard block consisting of
// configurable 1-6 independent slave ports with 128/64/32 bit bidirectional
// and unidirectional data paths.   To allow AXI4 IP masters to communicate
// with the MCB, this parameterized AXI4 bridge allows each of the configurable
// ports to conform to the AXI4 and MCB protocols.
//
// Specifications:
// AXI4 Slave Side:
// Configurable data width of 32, 64, 128
// Read acceptance depth is:
// Write acceptance depth is:
//
// Structure:
// axi_mcb
//   axi_register_slice_d1
//   USE_UPSIZER
//     upsizer_d2
//   axi_register_slice_d3
//   WRITE_BUNDLE
//     axi_mcb_aw_channel_0
//       axi_mcb_cmd_translator_0
//       rd_axi_mcb_cmd_fsm_0
//     axi_mcb_w_channel_0
//     axi_mcb_b_channel_0
//   READ_BUNDLE
//     axi_mcb_ar_channel_0
//       axi_mcb_cmd_translator_0
//       rd_axi_mcb_cmd_fsm_0
//     axi_mcb_r_channel_0
//   USE_CMD_ARBITER
//     axi_mcb_cmd_arbiter_0
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ps/1ps
`default_nettype none

module axi_mcb #
(
///////////////////////////////////////////////////////////////////////////////
// Parameter Definitions
///////////////////////////////////////////////////////////////////////////////
                    // FPGA Family. Current version: spartan6.
  parameter         C_FAMILY                        = "spartan6",
                    // Width of all master and slave ID signals.
                    // Range: >= 1.
  parameter integer C_S_AXI_ID_WIDTH                = 4,
                    // Width of S_AXI_AWADDR, S_AXI_ARADDR, M_AXI_AWADDR and
                    // M_AXI_ARADDR for all SI/MI slots.
                    // Range: 32.
  parameter integer C_S_AXI_ADDR_WIDTH              = 64,
                    // Width of WDATA and RDATA on SI slot.
                    // Must be <= C_MCB_DATA_WIDTH
                    // Range: 32, 64, 128, 256.
  parameter integer C_S_AXI_DATA_WIDTH              = 32,
                    // Indicates whether to use AXI AR and R channels.
                    // Range: 0, 1
  parameter integer C_S_AXI_SUPPORTS_READ           = 1,
                    // Indicates whether to use AXI AW, W, and B channels.
                    // Range: 0, 1
  parameter integer C_S_AXI_SUPPORTS_WRITE          = 1,
                    // Indicates whether to instatiate upsizer
                    // Range: 0, 1
  parameter integer C_S_AXI_SUPPORTS_NARROW_BURST   = 1,
                    // Vector to instantiate various pipelines.
                    //
                    // Bits [0-3] instatiate various pipelines inside the
                    // axi_mcb module and help isolating timing paths
                    // between the shim and the mcb interface.
                    // Bits [4-7] instatiate an axi register slice for
                    // each channel between the upsizer and axi_mcb module.
                    // These bits will override C_S_AXI_REG_EN1 for each
                    // respective channel with the optimal register type. 
                    // Bits [8-11] are only valid when
                    // C_SUPPORTS_NARROW_BURST = 1 and instantiate register
                    // slices inside the upsizer.
                    // Generally only [8-11] or [4-7] of these would be needed to improve
                    // timing, and generally favors instantiating the
                    // register slice inside the upsizer.
                    //
                    // C_S_AXI_REG_EN0[0] = Register slice on w_complete
                    // output signal of axi_mcb_w_channel to
                    // axi_mcb_aw_channel.
                    // C_S_AXI_REG_EN0[1] = Register axi_s_wready and
                    // axi_s_valid handshake condition.
                    // C_S_AXI_REG_EN0[2] = Register RD_Empty output of mcb
                    // and increases ready latency by 1 cycle. 
                    // C_S_AXI_REG_EN0[3] = Pipelines commands sent to
                    // axi_mcb to isolate cmd channel timing paths to the
                    // hard module.  
                    //
                    // C_S_AXI_REG_EN0[4] = AW Channel Register Slice
                    // C_S_AXI_REG_EN0[5] = W Channel Register Slice
                    // C_S_AXI_REG_EN0[6] = B Channel Register Slice
                    // C_S_AXI_REG_EN0[7] = R Channel Register Slice
                    //
                    // C_S_AXI_REG_EN0[8]  = AW Channel Register Slice
                    // C_S_AXI_REG_EN0[9]  = W Channel Register Slice
                    // C_S_AXI_REG_EN0[10] = AR Channel Register Slice
                    // C_S_AXI_REG_EN0[11] = R Channel Register Slice
                    //
                    // Note: There must always be a register slice on the
                    // AXI AR Channel, if it is not instantiated in the
                    // upsizer, a type 7 will be instatiated after hte
                    // upsizer.  
                    //
                    // Recommended values for this parameter to achieve
                    // highest possible clock frequency: 
                    // if C_S_AXI_SUPPORTS_NARROWS == 1
                    // then C_S_AXI_REG_EN0 == 0x30E
                    // if C_S_AXI_SUPPORTS_NARROWS == 0
                    // then C_S_AXI_REG_EN0 == 0x00F
  parameter integer C_S_AXI_REG_EN0                 = 20'h00000,
                    // Instatiates register slices before upsizer.
                    // The type of register is specified for each channel
                    // in a vector. 4 bits per channel are used.
                    // C_S_AXI_REG_EN1[03:00] = AW CHANNEL REGISTER SLICE
                    // C_S_AXI_REG_EN1[07:04] =  W CHANNEL REGISTER SLICE
                    // C_S_AXI_REG_EN1[11:08] =  B CHANNEL REGISTER SLICE
                    // C_S_AXI_REG_EN1[15:12] = AR CHANNEL REGISTER SLICE
                    // C_S_AXI_REG_EN1[20:16] =  R CHANNEL REGISTER SLICE
                    // Possible values for each channel are:
                    //
                    //   0 => BYPASS    = The channel is just wired through the
                    //                    module.
                    //   1 => FWD       = The master VALID and payload signals
                    //                    are registrated.
                    //   2 => REV       = The slave ready signal is registrated
                    //   3 => FWD_REV   = Both FWD and REV
                    //   4 => SLAVE_FWD = All slave side signals and master
                    //                    VALID and payload are registrated.
                    //   5 => SLAVE_RDY = All slave side signals and master
                    //                    READY are registrated.
                    //   6 => INPUTS    = Slave and Master side inputs are
                    //                    registrated.
                    //
                    //                                     A  A
                    //                                    RRBWW
  parameter integer C_S_AXI_REG_EN1                 = 20'h00000,
                    // Width of mcb_cmd_addr
                    // Range: 30.
  parameter integer C_MCB_ADDR_WIDTH                = 30,
                    // Width of wr_data and rd_data.
                    // Range: 32, 64, 128.
  parameter integer C_MCB_DATA_WIDTH                = 32,
                    // Enforces strict checking across all MCB ports for
                    // write data coherency.  This will ensure no race
                    // conditions will exist between the BRESP and any
                    // other read/write command on a different MCB port.
                    // Not necessary for single port MCB operation.
                    // Range: 0, 1
  parameter integer C_STRICT_COHERENCY              = 1,
                    // Instructs the memory controller to issue an
                    // auto-precharge after each command.
                    // Range: 0,1
  parameter integer C_ENABLE_AP                     = 0
)
(
///////////////////////////////////////////////////////////////////////////////
// Port Declarations
///////////////////////////////////////////////////////////////////////////////
  // AXI Slave Interface
  // Slave Interface System Signals
  input  wire                               aclk               ,
  input  wire                               aresetn            ,
  // Slave Interface Write Address Ports
  input  wire [C_S_AXI_ID_WIDTH-1:0]        s_axi_awid        ,
  input  wire [C_S_AXI_ADDR_WIDTH-1:0]      s_axi_awaddr      ,
  input  wire [7:0]                         s_axi_awlen       ,
  input  wire [2:0]                         s_axi_awsize      ,
  input  wire [1:0]                         s_axi_awburst     ,
  input  wire [0:0]                         s_axi_awlock      ,
  input  wire [3:0]                         s_axi_awcache     ,
  input  wire [2:0]                         s_axi_awprot      ,
  input  wire [3:0]                         s_axi_awqos       ,
  input  wire                               s_axi_awvalid     ,
  output wire                               s_axi_awready     ,
  // Slave Interface Write Data Ports
  input  wire [C_S_AXI_DATA_WIDTH-1:0]      s_axi_wdata       ,
  input  wire [C_S_AXI_DATA_WIDTH/8-1:0]    s_axi_wstrb       ,
  input  wire                               s_axi_wlast       ,
  input  wire                               s_axi_wvalid      ,
  output wire                               s_axi_wready      ,
  // Slave Interface Write Response Ports
  output wire [C_S_AXI_ID_WIDTH-1:0]        s_axi_bid         ,
  output wire [1:0]                         s_axi_bresp       ,
  output wire                               s_axi_bvalid      ,
  input  wire                               s_axi_bready      ,
  // Slave Interface Read Address Ports
  input  wire [C_S_AXI_ID_WIDTH-1:0]        s_axi_arid        ,
  input  wire [C_S_AXI_ADDR_WIDTH-1:0]      s_axi_araddr      ,
  input  wire [7:0]                         s_axi_arlen       ,
  input  wire [2:0]                         s_axi_arsize      ,
  input  wire [1:0]                         s_axi_arburst     ,
  input  wire [0:0]                         s_axi_arlock      ,
  input  wire [3:0]                         s_axi_arcache     ,
  input  wire [2:0]                         s_axi_arprot      ,
  input  wire [3:0]                         s_axi_arqos       ,
  input  wire                               s_axi_arvalid     ,
  output wire                               s_axi_arready     ,
  // Slave Interface Read Data Ports
  output wire [C_S_AXI_ID_WIDTH-1:0]        s_axi_rid         ,
  output wire [C_S_AXI_DATA_WIDTH-1:0]      s_axi_rdata       ,
  output wire [1:0]                         s_axi_rresp       ,
  output wire                               s_axi_rlast       ,
  output wire                               s_axi_rvalid      ,
  input  wire                               s_axi_rready      ,

  // MCB Master Interface
  //CMD PORT
  output wire                               mcb_cmd_clk       ,
  output wire                               mcb_cmd_en        ,
  output wire [2:0]                         mcb_cmd_instr     ,
  output wire [5:0]                         mcb_cmd_bl        ,
  output wire [C_MCB_ADDR_WIDTH-1:0]        mcb_cmd_byte_addr ,
  input  wire                               mcb_cmd_empty     ,
  input  wire                               mcb_cmd_full      ,

  //DATA PORT
  output wire                               mcb_wr_clk        ,
  output wire                               mcb_wr_en         ,
  output wire [C_MCB_DATA_WIDTH/8-1:0]      mcb_wr_mask       ,
  output wire [C_MCB_DATA_WIDTH-1:0]        mcb_wr_data       ,
  input  wire                               mcb_wr_full       ,
  input  wire                               mcb_wr_empty      ,
  input  wire [6:0]                         mcb_wr_count      ,
  input  wire                               mcb_wr_underrun   ,
  input  wire                               mcb_wr_error      ,

  output wire                               mcb_rd_clk        ,
  output wire                               mcb_rd_en         ,
  input  wire [C_MCB_DATA_WIDTH-1:0]        mcb_rd_data       ,
  input  wire                               mcb_rd_full       ,
  input  wire                               mcb_rd_empty      ,
  input  wire [6:0]                         mcb_rd_count      ,
  input  wire                               mcb_rd_overflow   ,
  input  wire                               mcb_rd_error      ,
  input  wire                               mcb_calib_done

);

////////////////////////////////////////////////////////////////////////////////
// Local parameters
////////////////////////////////////////////////////////////////////////////////
localparam integer P_RD_CNT_WIDTH = 4;
localparam integer P_WR_CNT_WIDTH = 4;
localparam integer P_AXSIZE = (C_MCB_DATA_WIDTH == 32) ? 3'd2 :
                              (C_MCB_DATA_WIDTH == 64) ? 3'd3 : 3'd4;

// C_D?_REG_CONFIG_*:
//   0 => BYPASS    = The channel is just wired through the module.
//   1 => FWD       = The master VALID and payload signals are registrated.
//   2 => REV       = The slave ready signal is registrated
//   3 => FWD_REV   = Both FWD and REV
//   4 => SLAVE_FWD = All slave side signals and master VALID and payload are registrated.
//   5 => SLAVE_RDY = All slave side signals and master READY are registrated.
//   6 => INPUTS    = Slave and Master side inputs are registrated.
localparam integer P_D1_REG_CONFIG_AW = 0;
localparam integer P_D1_REG_CONFIG_W  = 0;
localparam integer P_D1_REG_CONFIG_B  = 0;
localparam integer P_D1_REG_CONFIG_AR = 0;
localparam integer P_D1_REG_CONFIG_R  = 0;

localparam integer P_D2_REG_CONFIG_AW = C_S_AXI_REG_EN0[8];
localparam integer P_D2_REG_CONFIG_W  = C_S_AXI_REG_EN0[9];
localparam integer P_D2_REG_CONFIG_AR = C_S_AXI_REG_EN0[10];
localparam integer P_D2_REG_CONFIG_R  = C_S_AXI_REG_EN0[11];

localparam integer P_D3_REG_CONFIG_AW = C_S_AXI_REG_EN0[4] ? 7 : C_S_AXI_REG_EN1[ 0 +: 4];
localparam integer P_D3_REG_CONFIG_W  = C_S_AXI_REG_EN0[5] ? 2 : C_S_AXI_REG_EN1[ 4 +: 4];
localparam integer P_D3_REG_CONFIG_B  = C_S_AXI_REG_EN0[6] ? 7 : C_S_AXI_REG_EN1[ 8 +: 4];
// AR channel must always have a register slice.
localparam integer P_D3_REG_CONFIG_AR = C_S_AXI_REG_EN0[10] ? 0 : 7;
localparam integer P_D3_REG_CONFIG_R  = C_S_AXI_REG_EN0[7] ? 6 : C_S_AXI_REG_EN1[16 +: 4];

localparam integer P_PL_W_COMPLETE    = C_S_AXI_REG_EN0[0];
localparam integer P_PL_WHANDSHAKE    = C_S_AXI_REG_EN0[1];
localparam integer P_PL_WR_FULL       = 1;
localparam integer P_PL_RD_EMPTY      = C_S_AXI_REG_EN0[2];
localparam integer P_PL_CMD_BL_SECOND = 1;
localparam integer P_PL_MCB_CMD       = C_S_AXI_REG_EN0[3];

// Upsizer
localparam integer P_USE_UPSIZER = (C_S_AXI_DATA_WIDTH < C_MCB_DATA_WIDTH) ? 1'b1
                                   : C_S_AXI_SUPPORTS_NARROW_BURST;
localparam integer P_UPSIZER_PACKING_LEVEL = 2;
localparam integer P_SUPPORTS_USER_SIGNALS = 0;
// Set this parameter to 1 if data can be returned out of order
localparam integer P_SINGLE_THREAD = 0;
localparam integer P_CMD_PAYLOAD_WIDTH = 3 + 6 + C_MCB_DATA_WIDTH;

////////////////////////////////////////////////////////////////////////////////
// Wires/Reg declarations
////////////////////////////////////////////////////////////////////////////////
wire                           reset            ;

// First reg slice slave side output/inputs
wire  [C_S_AXI_ID_WIDTH-1:0]   awid_d1          ;
wire  [C_S_AXI_ADDR_WIDTH-1:0] awaddr_d1        ;
wire  [7:0]                    awlen_d1         ;
wire  [2:0]                    awsize_d1        ;
wire  [1:0]                    awburst_d1       ;
wire  [1:0]                    awlock_d1        ;
wire  [3:0]                    awcache_d1       ;
wire  [2:0]                    awprot_d1        ;
wire  [3:0]                    awqos_d1         ;
wire                           awvalid_d1       ;
wire                           awready_d1       ;
wire  [C_S_AXI_DATA_WIDTH-1:0] wdata_d1         ;
wire  [C_S_AXI_DATA_WIDTH/8-1:0] wstrb_d1       ;
wire                           wlast_d1         ;
wire                           wvalid_d1        ;
wire                           wready_d1        ;
wire  [C_S_AXI_ID_WIDTH-1:0]   bid_d1           ;
wire  [1:0]                    bresp_d1         ;
wire                           bvalid_d1        ;
wire                           bready_d1        ;
wire  [C_S_AXI_ID_WIDTH-1:0]   arid_d1          ;
wire  [C_S_AXI_ADDR_WIDTH-1:0] araddr_d1        ;
wire  [7:0]                    arlen_d1         ;
wire  [2:0]                    arsize_d1        ;
wire  [1:0]                    arburst_d1       ;
wire  [1:0]                    arlock_d1        ;
wire  [3:0]                    arcache_d1       ;
wire  [2:0]                    arprot_d1        ;
wire  [3:0]                    arqos_d1         ;
wire                           arvalid_d1       ;
wire                           arready_d1       ;
wire  [C_S_AXI_ID_WIDTH-1:0]   rid_d1           ;
wire  [C_S_AXI_DATA_WIDTH-1:0] rdata_d1         ;
wire  [1:0]                    rresp_d1         ;
wire                           rlast_d1         ;
wire                           rvalid_d1        ;
wire                           rready_d1        ;
// Upsizer slave side outputs/inputs
wire  [C_S_AXI_ID_WIDTH-1:0]   awid_d2          ;
wire  [C_S_AXI_ADDR_WIDTH-1:0] awaddr_d2        ;
wire  [7:0]                    awlen_d2         ;
wire  [2:0]                    awsize_d2        ;
wire  [1:0]                    awburst_d2       ;
wire  [1:0]                    awlock_d2        ;
wire  [3:0]                    awcache_d2       ;
wire  [2:0]                    awprot_d2        ;
wire  [3:0]                    awqos_d2         ;
wire                           awvalid_d2       ;
wire                           awready_d2       ;
wire  [C_MCB_DATA_WIDTH-1:0]   wdata_d2         ;
wire  [C_MCB_DATA_WIDTH/8-1:0] wstrb_d2         ;
wire                           wlast_d2         ;
wire                           wvalid_d2        ;
wire                           wready_d2        ;
wire  [C_S_AXI_ID_WIDTH-1:0]   bid_d2           ;
wire  [1:0]                    bresp_d2         ;
wire                           bvalid_d2        ;
wire                           bready_d2        ;
wire  [C_S_AXI_ID_WIDTH-1:0]   arid_d2          ;
wire  [C_S_AXI_ADDR_WIDTH-1:0] araddr_d2        ;
wire  [7:0]                    arlen_d2         ;
wire  [2:0]                    arsize_d2        ;
wire  [1:0]                    arburst_d2       ;
wire  [1:0]                    arlock_d2        ;
wire  [3:0]                    arcache_d2       ;
wire  [2:0]                    arprot_d2        ;
wire  [3:0]                    arqos_d2         ;
wire                           arvalid_d2       ;
wire                           arready_d2       ;
wire  [C_S_AXI_ID_WIDTH-1:0]   rid_d2           ;
wire  [C_MCB_DATA_WIDTH-1:0]   rdata_d2         ;
wire  [1:0]                    rresp_d2         ;
wire                           rlast_d2         ;
wire                           rvalid_d2        ;
wire                           rready_d2        ;
// Registe Slice 2 slave side outputs/inputs
wire  [C_S_AXI_ID_WIDTH-1:0]   awid_d3          ;
wire  [C_S_AXI_ADDR_WIDTH-1:0] awaddr_d3        ;
wire  [7:0]                    awlen_d3         ;
// AxSIZE hardcoded with static value
// wire  [2:0]                    awsize_d3        ;
wire  [1:0]                    awburst_d3       ;
wire  [1:0]                    awlock_d3        ;
wire  [3:0]                    awcache_d3       ;
wire  [2:0]                    awprot_d3        ;
wire  [3:0]                    awqos_d3         ;
wire                           awvalid_d3       ;
wire                           awready_d3       ;
wire  [C_MCB_DATA_WIDTH-1:0]   wdata_d3         ;
wire  [C_MCB_DATA_WIDTH/8-1:0] wstrb_d3         ;
wire                           wlast_d3         ;
wire                           wvalid_d3        ;
wire                           wready_d3        ;
wire  [C_S_AXI_ID_WIDTH-1:0]   bid_d3           ;
wire  [1:0]                    bresp_d3         ;
wire                           bvalid_d3        ;
wire                           bready_d3        ;
wire  [C_S_AXI_ID_WIDTH-1:0]   arid_d3          ;
wire  [C_S_AXI_ADDR_WIDTH-1:0] araddr_d3        ;
wire  [7:0]                    arlen_d3         ;
// AxSIZE hardcoded with static value
// wire  [2:0]                    arsize_d3        ;
wire  [1:0]                    arburst_d3       ;
wire  [1:0]                    arlock_d3        ;
wire  [3:0]                    arcache_d3       ;
wire  [2:0]                    arprot_d3        ;
wire  [3:0]                    arqos_d3         ;
wire                           arvalid_d3       ;
wire                           arready_d3       ;
wire  [C_S_AXI_ID_WIDTH-1:0]   rid_d3           ;
wire  [C_MCB_DATA_WIDTH-1:0]   rdata_d3         ;
wire  [1:0]                    rresp_d3         ;
wire                           rlast_d3         ;
wire                           rvalid_d3        ;
wire                           rready_d3        ;

// AW/AR module outputs to arbiter.
wire                           cmd_en_iw        ;
wire  [2:0]                    cmd_instr_iw     ;
wire                           wrap_cmd_sel_iw       ;
wire  [5:0]                    wrap_cmd_bl_iw        ;
wire  [C_MCB_ADDR_WIDTH-1:0]   wrap_cmd_byte_addr_iw ;
wire  [5:0]                    incr_cmd_bl_iw        ;
wire  [C_MCB_ADDR_WIDTH-1:0]   incr_cmd_byte_addr_iw ;
wire                           cmd_empty_iw     ;
wire                           cmd_full_iw      ;
wire                           next_pending_iw  ;
wire                           cmd_en_ir        ;
wire  [2:0]                    cmd_instr_ir     ;
wire                           wrap_cmd_sel_ir       ;
wire  [5:0]                    wrap_cmd_bl_ir        ;
wire  [C_MCB_ADDR_WIDTH-1:0]   wrap_cmd_byte_addr_ir ;
wire  [5:0]                    incr_cmd_bl_ir        ;
wire  [C_MCB_ADDR_WIDTH-1:0]   incr_cmd_byte_addr_ir ;
wire                           cmd_empty_ir     ;
wire                           cmd_full_ir      ;
wire                           next_pending_ir  ;

wire                           mcb_cmd_en_i          ;
wire  [2:0]                    mcb_cmd_instr_i       ;
wire  [5:0]                    mcb_cmd_bl_i          ;
wire  [C_MCB_ADDR_WIDTH-1:0]   mcb_cmd_byte_addr_i   ;
wire                           mcb_cmd_empty_i       ;
wire                           mcb_cmd_full_i        ;
////////////////////////////////////////////////////////////////////////////////
// BEGIN RTL
////////////////////////////////////////////////////////////////////////////////

assign reset = ~aresetn;
// Command clock
assign mcb_cmd_clk = aclk;

axi_register_slice #
(
  .C_FAMILY                    ( C_FAMILY                ) ,
  .C_AXI_ID_WIDTH              ( C_S_AXI_ID_WIDTH        ) ,
  .C_AXI_ADDR_WIDTH            ( C_S_AXI_ADDR_WIDTH      ) ,
  .C_AXI_DATA_WIDTH            ( C_S_AXI_DATA_WIDTH      ) ,
  .C_AXI_SUPPORTS_USER_SIGNALS ( P_SUPPORTS_USER_SIGNALS ) ,
  .C_AXI_AWUSER_WIDTH          ( 1                       ) ,
  .C_AXI_ARUSER_WIDTH          ( 1                       ) ,
  .C_AXI_WUSER_WIDTH           ( 1                       ) ,
  .C_AXI_RUSER_WIDTH           ( 1                       ) ,
  .C_AXI_BUSER_WIDTH           ( 1                       ) ,
  .C_REG_CONFIG_AW             ( P_D1_REG_CONFIG_AW      ) ,
  .C_REG_CONFIG_W              ( P_D1_REG_CONFIG_W       ) ,
  .C_REG_CONFIG_B              ( P_D1_REG_CONFIG_B       ) ,
  .C_REG_CONFIG_AR             ( P_D1_REG_CONFIG_AR      ) ,
  .C_REG_CONFIG_R              ( P_D1_REG_CONFIG_R       )
)
axi_register_slice_d1
(
  .ACLK          ( aclk          ) ,
  .ARESETN       ( aresetn       ) ,
  .S_AXI_AWID    ( s_axi_awid    ) ,
  .S_AXI_AWADDR  ( s_axi_awaddr  ) ,
  .S_AXI_AWLEN   ( s_axi_awlen   ) ,
  .S_AXI_AWSIZE  ( s_axi_awsize  ) ,
  .S_AXI_AWBURST ( s_axi_awburst ) ,
  .S_AXI_AWLOCK  ( {1'b0, s_axi_awlock}) ,
  .S_AXI_AWCACHE ( s_axi_awcache ) ,
  .S_AXI_AWPROT  ( s_axi_awprot  ) ,
  .S_AXI_AWREGION( 4'b0          ) ,
  .S_AXI_AWQOS   ( s_axi_awqos   ) ,
  .S_AXI_AWUSER  ( 1'b0          ) ,
  .S_AXI_AWVALID ( s_axi_awvalid ) ,
  .S_AXI_AWREADY ( s_axi_awready ) ,
  .S_AXI_WDATA   ( s_axi_wdata   ) ,
  .S_AXI_WID     ( {C_S_AXI_ID_WIDTH{1'b0}} ) ,
  .S_AXI_WSTRB   ( s_axi_wstrb   ) ,
  .S_AXI_WLAST   ( s_axi_wlast   ) ,
  .S_AXI_WUSER   ( 1'b0          ) ,
  .S_AXI_WVALID  ( s_axi_wvalid  ) ,
  .S_AXI_WREADY  ( s_axi_wready  ) ,
  .S_AXI_BID     ( s_axi_bid     ) ,
  .S_AXI_BRESP   ( s_axi_bresp   ) ,
  .S_AXI_BUSER   (               ) ,
  .S_AXI_BVALID  ( s_axi_bvalid  ) ,
  .S_AXI_BREADY  ( s_axi_bready  ) ,
  .S_AXI_ARID    ( s_axi_arid    ) ,
  .S_AXI_ARADDR  ( s_axi_araddr  ) ,
  .S_AXI_ARLEN   ( s_axi_arlen   ) ,
  .S_AXI_ARSIZE  ( s_axi_arsize  ) ,
  .S_AXI_ARBURST ( s_axi_arburst ) ,
  .S_AXI_ARLOCK  ( {1'b0, s_axi_arlock} ) ,
  .S_AXI_ARCACHE ( s_axi_arcache ) ,
  .S_AXI_ARPROT  ( s_axi_arprot  ) ,
  .S_AXI_ARREGION( 4'b0          ) ,
  .S_AXI_ARQOS   ( s_axi_arqos   ) ,
  .S_AXI_ARUSER  ( 1'b0          ) ,
  .S_AXI_ARVALID ( s_axi_arvalid ) ,
  .S_AXI_ARREADY ( s_axi_arready ) ,
  .S_AXI_RID     ( s_axi_rid     ) ,
  .S_AXI_RDATA   ( s_axi_rdata   ) ,
  .S_AXI_RRESP   ( s_axi_rresp   ) ,
  .S_AXI_RLAST   ( s_axi_rlast   ) ,
  .S_AXI_RUSER   (               ) ,
  .S_AXI_RVALID  ( s_axi_rvalid  ) ,
  .S_AXI_RREADY  ( s_axi_rready  ) ,
  .M_AXI_AWID    ( awid_d1       ) ,
  .M_AXI_AWADDR  ( awaddr_d1     ) ,
  .M_AXI_AWLEN   ( awlen_d1      ) ,
  .M_AXI_AWSIZE  ( awsize_d1     ) ,
  .M_AXI_AWBURST ( awburst_d1    ) ,
  .M_AXI_AWLOCK  ( awlock_d1     ) ,
  .M_AXI_AWCACHE ( awcache_d1    ) ,
  .M_AXI_AWREGION(               ) ,
  .M_AXI_AWPROT  ( awprot_d1     ) ,
  .M_AXI_AWQOS   ( awqos_d1      ) ,
  .M_AXI_AWUSER  (               ) ,
  .M_AXI_AWVALID ( awvalid_d1    ) ,
  .M_AXI_AWREADY ( awready_d1    ) ,
  .M_AXI_WID     (               ) ,
  .M_AXI_WDATA   ( wdata_d1      ) ,
  .M_AXI_WSTRB   ( wstrb_d1      ) ,
  .M_AXI_WLAST   ( wlast_d1      ) ,
  .M_AXI_WUSER   (               ) ,
  .M_AXI_WVALID  ( wvalid_d1     ) ,
  .M_AXI_WREADY  ( wready_d1     ) ,
  .M_AXI_BID     ( bid_d1        ) ,
  .M_AXI_BRESP   ( bresp_d1      ) ,
  .M_AXI_BUSER   ( 1'b0          ) ,
  .M_AXI_BVALID  ( bvalid_d1     ) ,
  .M_AXI_BREADY  ( bready_d1     ) ,
  .M_AXI_ARID    ( arid_d1       ) ,
  .M_AXI_ARADDR  ( araddr_d1     ) ,
  .M_AXI_ARLEN   ( arlen_d1      ) ,
  .M_AXI_ARSIZE  ( arsize_d1     ) ,
  .M_AXI_ARBURST ( arburst_d1    ) ,
  .M_AXI_ARLOCK  ( arlock_d1     ) ,
  .M_AXI_ARCACHE ( arcache_d1    ) ,
  .M_AXI_ARPROT  ( arprot_d1     ) ,
  .M_AXI_ARREGION(               ) ,
  .M_AXI_ARQOS   ( arqos_d1      ) ,
  .M_AXI_ARUSER  (               ) ,
  .M_AXI_ARVALID ( arvalid_d1    ) ,
  .M_AXI_ARREADY ( arready_d1    ) ,
  .M_AXI_RID     ( rid_d1        ) ,
  .M_AXI_RDATA   ( rdata_d1      ) ,
  .M_AXI_RRESP   ( rresp_d1      ) ,
  .M_AXI_RLAST   ( rlast_d1      ) ,
  .M_AXI_RUSER   ( 1'b0          ) ,
  .M_AXI_RVALID  ( rvalid_d1     ) ,
  .M_AXI_RREADY  ( rready_d1     )
);

generate
  if (P_USE_UPSIZER) begin : USE_UPSIZER
    axi_upsizer #(
      .C_FAMILY                    ( C_FAMILY                ) ,
      .C_AXI_ID_WIDTH              ( C_S_AXI_ID_WIDTH        ) ,
      .C_AXI_ADDR_WIDTH            ( C_S_AXI_ADDR_WIDTH      ) ,
      .C_S_AXI_DATA_WIDTH          ( C_S_AXI_DATA_WIDTH      ) ,
      .C_M_AXI_DATA_WIDTH          ( C_MCB_DATA_WIDTH        ) ,
      .C_M_AXI_AW_REGISTER         ( P_D2_REG_CONFIG_AW      ) ,
      .C_M_AXI_W_REGISTER          ( P_D2_REG_CONFIG_W       ) ,
      .C_M_AXI_AR_REGISTER         ( P_D2_REG_CONFIG_AR      ) ,
      .C_S_AXI_R_REGISTER          ( P_D2_REG_CONFIG_R       ) ,
      .C_AXI_SUPPORTS_USER_SIGNALS ( P_SUPPORTS_USER_SIGNALS ) ,
      .C_AXI_AWUSER_WIDTH          ( 1                       ) ,
      .C_AXI_ARUSER_WIDTH          ( 1                       ) ,
      .C_AXI_WUSER_WIDTH           ( 1                       ) ,
      .C_AXI_RUSER_WIDTH           ( 1                       ) ,
      .C_AXI_BUSER_WIDTH           ( 1                       ) ,
      .C_AXI_SUPPORTS_WRITE        ( C_S_AXI_SUPPORTS_WRITE  ) ,
      .C_AXI_SUPPORTS_READ         ( C_S_AXI_SUPPORTS_READ   ) ,
      .C_PACKING_LEVEL             ( P_UPSIZER_PACKING_LEVEL ) ,
      .C_SUPPORT_BURSTS            ( 1                       ) ,
      .C_SINGLE_THREAD             ( P_SINGLE_THREAD         )
    )
    upsizer_d2
    (
      .ARESETN       ( aresetn       ) ,
      .ACLK          ( aclk          ) ,
      .S_AXI_AWID    ( awid_d1       ) ,
      .S_AXI_AWADDR  ( awaddr_d1     ) ,
      .S_AXI_AWLEN   ( awlen_d1      ) ,
      .S_AXI_AWSIZE  ( awsize_d1     ) ,
      .S_AXI_AWBURST ( awburst_d1    ) ,
      .S_AXI_AWLOCK  ( awlock_d1     ) ,
      .S_AXI_AWCACHE ( awcache_d1    ) ,
      .S_AXI_AWPROT  ( awprot_d1     ) ,
      .S_AXI_AWREGION( 4'b0          ) ,
      .S_AXI_AWQOS   ( awqos_d1      ) ,
      .S_AXI_AWUSER  ( 1'b0          ) ,
      .S_AXI_AWVALID ( awvalid_d1    ) ,
      .S_AXI_AWREADY ( awready_d1    ) ,
      .S_AXI_WDATA   ( wdata_d1      ) ,
      .S_AXI_WSTRB   ( wstrb_d1      ) ,
      .S_AXI_WLAST   ( wlast_d1      ) ,
      .S_AXI_WUSER   ( 1'b0          ) ,
      .S_AXI_WVALID  ( wvalid_d1     ) ,
      .S_AXI_WREADY  ( wready_d1     ) ,
      .S_AXI_BID     ( bid_d1        ) ,
      .S_AXI_BRESP   ( bresp_d1      ) ,
      .S_AXI_BUSER   (               ) ,
      .S_AXI_BVALID  ( bvalid_d1     ) ,
      .S_AXI_BREADY  ( bready_d1     ) ,
      .S_AXI_ARID    ( arid_d1       ) ,
      .S_AXI_ARADDR  ( araddr_d1     ) ,
      .S_AXI_ARLEN   ( arlen_d1      ) ,
      .S_AXI_ARSIZE  ( arsize_d1     ) ,
      .S_AXI_ARBURST ( arburst_d1    ) ,
      .S_AXI_ARLOCK  ( arlock_d1     ) ,
      .S_AXI_ARCACHE ( arcache_d1    ) ,
      .S_AXI_ARPROT  ( arprot_d1     ) ,
      .S_AXI_ARREGION( 4'b0          ) ,
      .S_AXI_ARQOS   ( arqos_d1      ) ,
      .S_AXI_ARUSER  ( 1'b0          ) ,
      .S_AXI_ARVALID ( arvalid_d1    ) ,
      .S_AXI_ARREADY ( arready_d1    ) ,
      .S_AXI_RID     ( rid_d1        ) ,
      .S_AXI_RDATA   ( rdata_d1      ) ,
      .S_AXI_RRESP   ( rresp_d1      ) ,
      .S_AXI_RLAST   ( rlast_d1      ) ,
      .S_AXI_RUSER   (               ) ,
      .S_AXI_RVALID  ( rvalid_d1     ) ,
      .S_AXI_RREADY  ( rready_d1     ) ,
      .M_AXI_AWID    ( awid_d2       ) ,
      .M_AXI_AWADDR  ( awaddr_d2     ) ,
      .M_AXI_AWLEN   ( awlen_d2      ) ,
      .M_AXI_AWSIZE  ( awsize_d2     ) ,
      .M_AXI_AWBURST ( awburst_d2    ) ,
      .M_AXI_AWLOCK  ( awlock_d2     ) ,
      .M_AXI_AWCACHE ( awcache_d2    ) ,
      .M_AXI_AWPROT  ( awprot_d2     ) ,
      .M_AXI_AWREGION(               ) ,
      .M_AXI_AWQOS   ( awqos_d2      ) ,
      .M_AXI_AWUSER  (               ) ,
      .M_AXI_AWVALID ( awvalid_d2    ) ,
      .M_AXI_AWREADY ( awready_d2    ) ,
      .M_AXI_WDATA   ( wdata_d2      ) ,
      .M_AXI_WSTRB   ( wstrb_d2      ) ,
      .M_AXI_WLAST   ( wlast_d2      ) ,
      .M_AXI_WUSER   (               ) ,
      .M_AXI_WVALID  ( wvalid_d2     ) ,
      .M_AXI_WREADY  ( wready_d2     ) ,
      .M_AXI_BID     ( bid_d2        ) ,
      .M_AXI_BRESP   ( bresp_d2      ) ,
      .M_AXI_BUSER   ( 1'b0          ) ,
      .M_AXI_BVALID  ( bvalid_d2     ) ,
      .M_AXI_BREADY  ( bready_d2     ) ,
      .M_AXI_ARID    ( arid_d2       ) ,
      .M_AXI_ARADDR  ( araddr_d2     ) ,
      .M_AXI_ARLEN   ( arlen_d2      ) ,
      .M_AXI_ARSIZE  ( arsize_d2     ) ,
      .M_AXI_ARBURST ( arburst_d2    ) ,
      .M_AXI_ARLOCK  ( arlock_d2     ) ,
      .M_AXI_ARCACHE ( arcache_d2    ) ,
      .M_AXI_ARPROT  ( arprot_d2     ) ,
      .M_AXI_ARREGION(               ) ,
      .M_AXI_ARQOS   ( arqos_d2      ) ,
      .M_AXI_ARUSER  (               ) ,
      .M_AXI_ARVALID ( arvalid_d2    ) ,
      .M_AXI_ARREADY ( arready_d2    ) ,
      .M_AXI_RID     ( rid_d2        ) ,
      .M_AXI_RDATA   ( rdata_d2      ) ,
      .M_AXI_RRESP   ( rresp_d2      ) ,
      .M_AXI_RLAST   ( rlast_d2      ) ,
      .M_AXI_RUSER   ( 1'b0          ) ,
      .M_AXI_RVALID  ( rvalid_d2     ) ,
      .M_AXI_RREADY  ( rready_d2     )
    );
  end
  else begin : NO_UPSIZER
    assign awid_d2    = awid_d1    ;
    assign awaddr_d2  = awaddr_d1  ;
    assign awlen_d2   = awlen_d1   ;
    assign awsize_d2  = awsize_d1  ;
    assign awburst_d2 = awburst_d1 ;
    assign awlock_d2  = awlock_d1  ;
    assign awcache_d2 = awcache_d1 ;
    assign awprot_d2  = awprot_d1  ;
    assign awqos_d2   = awqos_d1   ;
    assign awvalid_d2 = awvalid_d1 ;
    assign awready_d1 = awready_d2 ;
    assign wdata_d2   = wdata_d1   ;
    assign wstrb_d2   = wstrb_d1   ;
    assign wlast_d2   = wlast_d1   ;
    assign wvalid_d2  = wvalid_d1  ;
    assign wready_d1  = wready_d2  ;
    assign bid_d1     = bid_d2     ;
    assign bresp_d1   = bresp_d2   ;
    assign bvalid_d1  = bvalid_d2  ;
    assign bready_d2  = bready_d1  ;
    assign arid_d2    = arid_d1    ;
    assign araddr_d2  = araddr_d1  ;
    assign arlen_d2   = arlen_d1   ;
    assign arsize_d2  = arsize_d1  ;
    assign arburst_d2 = arburst_d1 ;
    assign arlock_d2  = arlock_d1  ;
    assign arcache_d2 = arcache_d1 ;
    assign arprot_d2  = arprot_d1  ;
    assign arqos_d2   = arqos_d1   ;
    assign arvalid_d2 = arvalid_d1 ;
    assign arready_d1 = arready_d2 ;
    assign rid_d1     = rid_d2     ;
    assign rdata_d1   = rdata_d2   ;
    assign rresp_d1   = rresp_d2   ;
    assign rlast_d1   = rlast_d2   ;
    assign rvalid_d1  = rvalid_d2  ;
    assign rready_d2  = rready_d1  ;
  end
endgenerate

axi_register_slice #
(
  .C_FAMILY                    ( C_FAMILY                ) ,
  .C_AXI_ID_WIDTH              ( C_S_AXI_ID_WIDTH        ) ,
  .C_AXI_ADDR_WIDTH            ( C_S_AXI_ADDR_WIDTH      ) ,
  .C_AXI_DATA_WIDTH            ( C_MCB_DATA_WIDTH        ) ,
  .C_AXI_SUPPORTS_USER_SIGNALS ( P_SUPPORTS_USER_SIGNALS ) ,
  .C_AXI_AWUSER_WIDTH          ( 1                       ) ,
  .C_AXI_ARUSER_WIDTH          ( 1                       ) ,
  .C_AXI_WUSER_WIDTH           ( 1                       ) ,
  .C_AXI_RUSER_WIDTH           ( 1                       ) ,
  .C_AXI_BUSER_WIDTH           ( 1                       ) ,
  .C_REG_CONFIG_AW             ( P_D3_REG_CONFIG_AW      ) ,
  .C_REG_CONFIG_W              ( P_D3_REG_CONFIG_W       ) ,
  .C_REG_CONFIG_B              ( P_D3_REG_CONFIG_B       ) ,
  .C_REG_CONFIG_AR             ( P_D3_REG_CONFIG_AR      ) ,
  .C_REG_CONFIG_R              ( P_D3_REG_CONFIG_R       )
)
axi_register_slice_d3
(
  .ACLK          ( aclk          ) ,
  .ARESETN       ( aresetn       ) ,
  .S_AXI_AWID    ( awid_d2       ) ,
  .S_AXI_AWADDR  ( awaddr_d2     ) ,
  .S_AXI_AWLEN   ( awlen_d2      ) ,
  .S_AXI_AWSIZE  ( P_AXSIZE[2:0] ) ,
  .S_AXI_AWBURST ( awburst_d2    ) ,
  .S_AXI_AWLOCK  ( awlock_d2     ) ,
  .S_AXI_AWCACHE ( awcache_d2    ) ,
  .S_AXI_AWPROT  ( awprot_d2     ) ,
  .S_AXI_AWREGION( 4'b0          ) ,
  .S_AXI_AWQOS   ( awqos_d2      ) ,
  .S_AXI_AWUSER  ( 1'b0          ) ,
  .S_AXI_AWVALID ( awvalid_d2    ) ,
  .S_AXI_AWREADY ( awready_d2    ) ,
  .S_AXI_WID     ( {C_S_AXI_ID_WIDTH{1'b0}} ) ,
  .S_AXI_WDATA   ( wdata_d2      ) ,
  .S_AXI_WSTRB   ( wstrb_d2      ) ,
  .S_AXI_WLAST   ( wlast_d2      ) ,
  .S_AXI_WUSER   ( 1'b0          ) ,
  .S_AXI_WVALID  ( wvalid_d2     ) ,
  .S_AXI_WREADY  ( wready_d2     ) ,
  .S_AXI_BID     ( bid_d2        ) ,
  .S_AXI_BRESP   ( bresp_d2      ) ,
  .S_AXI_BUSER   (               ) ,
  .S_AXI_BVALID  ( bvalid_d2     ) ,
  .S_AXI_BREADY  ( bready_d2     ) ,
  .S_AXI_ARID    ( arid_d2       ) ,
  .S_AXI_ARADDR  ( araddr_d2     ) ,
  .S_AXI_ARLEN   ( arlen_d2      ) ,
  .S_AXI_ARSIZE  ( P_AXSIZE[2:0] ) ,
  .S_AXI_ARBURST ( arburst_d2    ) ,
  .S_AXI_ARLOCK  ( arlock_d2     ) ,
  .S_AXI_ARCACHE ( arcache_d2    ) ,
  .S_AXI_ARPROT  ( arprot_d2     ) ,
  .S_AXI_ARREGION( 4'b0          ) ,
  .S_AXI_ARQOS   ( arqos_d2      ) ,
  .S_AXI_ARUSER  ( 1'b0          ) ,
  .S_AXI_ARVALID ( arvalid_d2    ) ,
  .S_AXI_ARREADY ( arready_d2    ) ,
  .S_AXI_RID     ( rid_d2        ) ,
  .S_AXI_RDATA   ( rdata_d2      ) ,
  .S_AXI_RRESP   ( rresp_d2      ) ,
  .S_AXI_RLAST   ( rlast_d2      ) ,
  .S_AXI_RUSER   (               ) ,
  .S_AXI_RVALID  ( rvalid_d2     ) ,
  .S_AXI_RREADY  ( rready_d2     ) ,
  .M_AXI_AWID    ( awid_d3       ) ,
  .M_AXI_AWADDR  ( awaddr_d3     ) ,
  .M_AXI_AWLEN   ( awlen_d3      ) ,
// AxSIZE hardcoded with static value
//  .M_AXI_AWSIZE  ( awsize_d3     ) ,
  .M_AXI_AWSIZE  (               ) ,
  .M_AXI_AWBURST ( awburst_d3    ) ,
  .M_AXI_AWLOCK  ( awlock_d3     ) ,
  .M_AXI_AWCACHE ( awcache_d3    ) ,
  .M_AXI_AWPROT  ( awprot_d3     ) ,
  .M_AXI_AWREGION(               ) ,
  .M_AXI_AWQOS   ( awqos_d3      ) ,
  .M_AXI_AWUSER  (               ) ,
  .M_AXI_AWVALID ( awvalid_d3    ) ,
  .M_AXI_AWREADY ( awready_d3    ) ,
  .M_AXI_WID     (               ) ,
  .M_AXI_WDATA   ( wdata_d3      ) ,
  .M_AXI_WSTRB   ( wstrb_d3      ) ,
  .M_AXI_WLAST   ( wlast_d3      ) ,
  .M_AXI_WUSER   (               ) ,
  .M_AXI_WVALID  ( wvalid_d3     ) ,
  .M_AXI_WREADY  ( wready_d3     ) ,
  .M_AXI_BID     ( bid_d3        ) ,
  .M_AXI_BRESP   ( bresp_d3      ) ,
  .M_AXI_BUSER   ( 1'b0          ) ,
  .M_AXI_BVALID  ( bvalid_d3     ) ,
  .M_AXI_BREADY  ( bready_d3     ) ,
  .M_AXI_ARID    ( arid_d3       ) ,
  .M_AXI_ARADDR  ( araddr_d3     ) ,
  .M_AXI_ARLEN   ( arlen_d3      ) ,
// AxSIZE hardcoded with static value
//  .M_AXI_ARSIZE  ( arsize_d3     ) ,
  .M_AXI_ARSIZE  (               ) ,
  .M_AXI_ARBURST ( arburst_d3    ) ,
  .M_AXI_ARLOCK  ( arlock_d3     ) ,
  .M_AXI_ARCACHE ( arcache_d3    ) ,
  .M_AXI_ARPROT  ( arprot_d3     ) ,
  .M_AXI_ARREGION(               ) ,
  .M_AXI_ARQOS   ( arqos_d3      ) ,
  .M_AXI_ARUSER  (               ) ,
  .M_AXI_ARVALID ( arvalid_d3    ) ,
  .M_AXI_ARREADY ( arready_d3    ) ,
  .M_AXI_RID     ( rid_d3        ) ,
  .M_AXI_RDATA   ( rdata_d3      ) ,
  .M_AXI_RRESP   ( rresp_d3      ) ,
  .M_AXI_RLAST   ( rlast_d3      ) ,
  .M_AXI_RUSER   ( 1'b0          ) ,
  .M_AXI_RVALID  ( rvalid_d3     ) ,
  .M_AXI_RREADY  ( rready_d3     )
);
generate
  if (C_S_AXI_SUPPORTS_WRITE) begin : WRITE_BUNDLE
    // AW/W/B channel internal communication
    wire                                w_complete  ;
    wire                                w_trans_cnt_full ;
    wire                                b_push;
    wire [C_S_AXI_ID_WIDTH-1:0]         b_awid;
    wire                                b_full;
    wire                                mcb_error;
    wire                                mcb_empty;

    assign mcb_wr_clk = aclk;
    assign mcb_error = mcb_wr_error | mcb_wr_underrun;
    assign mcb_empty = mcb_wr_empty | mcb_cmd_empty;

    axi_mcb_aw_channel #
    (
      .C_ID_WIDTH         ( C_S_AXI_ID_WIDTH   ) ,
      .C_AXI_ADDR_WIDTH   ( C_S_AXI_ADDR_WIDTH ) ,
      .C_MCB_ADDR_WIDTH   ( C_MCB_ADDR_WIDTH   ) ,
      .C_DATA_WIDTH       ( C_MCB_DATA_WIDTH   ) ,
      .C_CNT_WIDTH        ( P_WR_CNT_WIDTH     ) ,
      .C_AXSIZE           ( P_AXSIZE           ) ,
      .C_STRICT_COHERENCY ( C_STRICT_COHERENCY ) ,
      .C_ENABLE_AP        ( C_ENABLE_AP        ) ,
      .C_PL_CMD_BL_SECOND ( P_PL_CMD_BL_SECOND )
    )
    axi_mcb_aw_channel_0
    (
      .clk                ( aclk                  ) ,
      .reset              ( reset                 ) ,
      .awid               ( awid_d3               ) ,
      .awaddr             ( awaddr_d3             ) ,
      .awlen              ( awlen_d3              ) ,
      .awsize             ( P_AXSIZE[2:0]         ) ,
      .awburst            ( awburst_d3            ) ,
      .awlock             ( awlock_d3             ) ,
      .awcache            ( awcache_d3            ) ,
      .awprot             ( awprot_d3             ) ,
      .awqos              ( awqos_d3              ) ,
      .awvalid            ( awvalid_d3            ) ,
      .awready            ( awready_d3            ) ,
      .cmd_en             ( cmd_en_iw             ) ,
      .cmd_instr          ( cmd_instr_iw          ) ,
      .wrap_cmd_sel       ( wrap_cmd_sel_iw       ) ,
      .wrap_cmd_bl        ( wrap_cmd_bl_iw        ) ,
      .wrap_cmd_byte_addr ( wrap_cmd_byte_addr_iw ) ,
      .incr_cmd_bl        ( incr_cmd_bl_iw        ) ,
      .incr_cmd_byte_addr ( incr_cmd_byte_addr_iw ) ,
      .cmd_empty          ( cmd_empty_iw          ) ,
      .cmd_full           ( cmd_full_iw           ) ,
      .calib_done         ( mcb_calib_done        ) ,
      .next_pending       ( next_pending_iw       ) ,
      .w_complete         ( w_complete            ) ,
      .w_trans_cnt_full   ( w_trans_cnt_full      ) ,
      .b_push             ( b_push                ) ,
      .b_awid             ( b_awid                ) ,
      .b_full             ( b_full                ) 
    );

    axi_mcb_w_channel #
    (
      .C_DATA_WIDTH    ( C_MCB_DATA_WIDTH ) ,
      .C_CNT_WIDTH     ( P_WR_CNT_WIDTH   ) ,
      .C_PL_W_COMPLETE ( P_PL_W_COMPLETE  ) ,
      .C_PL_WHANDSHAKE ( P_PL_WHANDSHAKE  ) ,
      .C_PL_WR_FULL    ( P_PL_WR_FULL     ) 

    )
    axi_mcb_w_channel_0
    (
      .clk         ( aclk            ) ,
      .reset       ( reset           ) ,
      .wdata       ( wdata_d3        ) ,
      .wstrb       ( wstrb_d3        ) ,
      .wlast       ( wlast_d3        ) ,
      .wvalid      ( wvalid_d3       ) ,
      .wready      ( wready_d3       ) ,
      .wr_en       ( mcb_wr_en       ) ,
      .wr_mask     ( mcb_wr_mask     ) ,
      .wr_data     ( mcb_wr_data     ) ,
      .wr_full     ( mcb_wr_full     ) ,
      .wr_empty    ( mcb_wr_empty    ) ,
      .wr_count    ( mcb_wr_count    ) ,
      .wr_underrun ( mcb_wr_underrun ) ,
      .wr_error    ( mcb_wr_error    ) ,
      .calib_done  ( mcb_calib_done  ) ,
      .w_complete       ( w_complete       ) ,
      .w_trans_cnt_full ( w_trans_cnt_full )  
    );

    axi_mcb_b_channel #
    (
      .C_ID_WIDTH         ( C_S_AXI_ID_WIDTH   ) ,
      .C_STRICT_COHERENCY ( C_STRICT_COHERENCY )
    )
    axi_mcb_b_channel_0
    (
      .clk           ( aclk          ) ,
      .reset         ( reset         ) ,
      .bid           ( bid_d3        ) ,
      .bresp         ( bresp_d3      ) ,
      .bvalid        ( bvalid_d3     ) ,
      .bready        ( bready_d3     ) ,
      .b_push        ( b_push        ) ,
      .b_awid        ( b_awid        ) ,
      .b_full        ( b_full        ) ,
      .mcb_error     ( mcb_error     ) ,
      .mcb_cmd_empty ( mcb_cmd_empty ) ,
      .mcb_cmd_full  ( mcb_cmd_full  ) ,
      .mcb_wr_empty  ( mcb_wr_empty  )
    );
  end
  else begin : NO_WRITE_BUNDLE
    assign awready_d3 = 1'b0                     ;
    assign wready_d3  = 1'b0                     ;
    assign bid_d3     = {C_S_AXI_ID_WIDTH{1'b0}} ;
    assign bresp_d3   = 2'b0                     ;
    assign bvalid_d3  = 1'b0                     ;
    assign mcb_wr_clk = 1'b0                     ;
    assign mcb_wr_en  = 1'b0                     ;
  end
endgenerate

generate
  if (C_S_AXI_SUPPORTS_READ) begin : READ_BUNDLE
    // AR/R channel communication
    wire                                r_push      ;
    wire [P_RD_CNT_WIDTH-1:0]           r_length    ;
    wire [C_S_AXI_ID_WIDTH-1:0]         r_arid      ;
    wire                                r_rlast     ;
    wire                                r_full      ;

    assign mcb_rd_clk = aclk;

    axi_mcb_ar_channel #
    (
      .C_ID_WIDTH         ( C_S_AXI_ID_WIDTH   ) ,
      .C_AXI_ADDR_WIDTH   ( C_S_AXI_ADDR_WIDTH ) ,
      .C_MCB_ADDR_WIDTH   ( C_MCB_ADDR_WIDTH   ) ,
      .C_DATA_WIDTH       ( C_MCB_DATA_WIDTH   ) ,
      .C_CNT_WIDTH        ( P_RD_CNT_WIDTH     ) ,
      .C_AXSIZE           ( P_AXSIZE           ) ,
      .C_ENABLE_AP        ( C_ENABLE_AP        ) ,
      .C_PL_CMD_BL_SECOND ( P_PL_CMD_BL_SECOND ) 
    )
    axi_mcb_ar_channel_0
    (
      .clk                ( aclk                  ) ,
      .reset              ( reset                 ) ,
      .arid               ( arid_d3               ) ,
      .araddr             ( araddr_d3             ) ,
      .arlen              ( arlen_d3              ) ,
      .arsize             ( P_AXSIZE[2:0]         ) ,
      .arburst            ( arburst_d3            ) ,
      .arlock             ( arlock_d3             ) ,
      .arcache            ( arcache_d3            ) ,
      .arprot             ( arprot_d3             ) ,
      .arqos              ( arqos_d3              ) ,
      .arvalid            ( arvalid_d3            ) ,
      .arready            ( arready_d3            ) ,
      .cmd_en             ( cmd_en_ir             ) ,
      .cmd_instr          ( cmd_instr_ir          ) ,
      .wrap_cmd_sel       ( wrap_cmd_sel_ir       ) ,
      .wrap_cmd_bl        ( wrap_cmd_bl_ir        ) ,
      .wrap_cmd_byte_addr ( wrap_cmd_byte_addr_ir ) ,
      .incr_cmd_bl        ( incr_cmd_bl_ir        ) ,
      .incr_cmd_byte_addr ( incr_cmd_byte_addr_ir ) ,
      .cmd_empty          ( cmd_empty_ir          ) ,
      .cmd_full           ( cmd_full_ir           ) ,
      .calib_done         ( mcb_calib_done        ) ,
      .next_pending       ( next_pending_ir       ) ,
      .r_push             ( r_push                ) ,
      .r_length           ( r_length              ) ,
      .r_arid             ( r_arid                ) ,
      .r_rlast            ( r_rlast               ) ,
      .r_full             ( r_full                ) 
    );

    axi_mcb_r_channel #
    (
      .C_ID_WIDTH    ( C_S_AXI_ID_WIDTH ) ,
      .C_DATA_WIDTH  ( C_MCB_DATA_WIDTH ) ,
      .C_CNT_WIDTH   ( P_RD_CNT_WIDTH   ) ,
      .C_PL_RD_EMPTY ( P_PL_RD_EMPTY    ) 
    )
    axi_mcb_r_channel_0
    (
      .clk         ( aclk            ) ,
      .reset       ( reset           ) ,
      .rid         ( rid_d3          ) ,
      .rdata       ( rdata_d3        ) ,
      .rresp       ( rresp_d3        ) ,
      .rlast       ( rlast_d3        ) ,
      .rvalid      ( rvalid_d3       ) ,
      .rready      ( rready_d3       ) ,
      .rd_en       ( mcb_rd_en       ) ,
      .rd_data     ( mcb_rd_data     ) ,
      .rd_full     ( mcb_rd_full     ) ,
      .rd_empty    ( mcb_rd_empty    ) ,
      .rd_count    ( mcb_rd_count    ) ,
      .rd_overflow ( mcb_rd_overflow ) ,
      .rd_error    ( mcb_rd_error    ) ,
      .r_push      ( r_push          ) ,
      .r_length    ( r_length        ) ,
      .r_arid      ( r_arid          ) ,
      .r_rlast     ( r_rlast         ) ,
      .r_full      ( r_full          )
    );
  end
  else begin : NO_READ_BUNDLE
    assign arready_d3 = 1'b0                     ;
    assign rid_d3     = {C_S_AXI_ID_WIDTH{1'b0}} ;
    assign rdata_d3   = {C_MCB_DATA_WIDTH{1'b0}} ;
    assign rresp_d3   = 2'b0                     ;
    assign rlast_d3   = 1'b0                     ;
    assign rvalid_d3  = 1'b0                     ;
    assign mcb_rd_clk = 1'b0                     ;
    assign mcb_rd_en  = 1'b0                     ;
  end
endgenerate

generate
  if (C_S_AXI_SUPPORTS_READ && C_S_AXI_SUPPORTS_WRITE) begin : USE_CMD_ARBITER
    axi_mcb_cmd_arbiter #
    (
      .C_MCB_ADDR_WIDTH          ( C_MCB_ADDR_WIDTH  )
    )
    axi_mcb_cmd_arbiter_0
    (
      .clk                       ( aclk              ) ,
      .reset                     ( reset             ) ,
      // Write commands from AXI
      .wr_cmd_en                 ( cmd_en_iw         ) ,
      .wr_cmd_instr              ( cmd_instr_iw      ) ,
      .wr_wrap_cmd_sel           ( wrap_cmd_sel_iw        ) ,
      .wr_wrap_cmd_bl            ( wrap_cmd_bl_iw         ) ,
      .wr_wrap_cmd_byte_addr     ( wrap_cmd_byte_addr_iw  ) ,
      .wr_incr_cmd_bl            ( incr_cmd_bl_iw         ) ,
      .wr_incr_cmd_byte_addr     ( incr_cmd_byte_addr_iw  ) ,
      .wr_cmd_empty              ( cmd_empty_iw      ) ,
      .wr_cmd_full               ( cmd_full_iw       ) ,
      .wr_cmd_has_next_pending   ( next_pending_iw   ) ,
      // Read commands from AXI
      .rd_cmd_en                 ( cmd_en_ir         ) ,
      .rd_cmd_instr              ( cmd_instr_ir      ) ,
      .rd_wrap_cmd_sel           ( wrap_cmd_sel_ir        ) ,
      .rd_wrap_cmd_bl            ( wrap_cmd_bl_ir         ) ,
      .rd_wrap_cmd_byte_addr     ( wrap_cmd_byte_addr_ir  ) ,
      .rd_incr_cmd_bl            ( incr_cmd_bl_ir         ) ,
      .rd_incr_cmd_byte_addr     ( incr_cmd_byte_addr_ir  ) ,
      .rd_cmd_empty              ( cmd_empty_ir      ) ,
      .rd_cmd_full               ( cmd_full_ir       ) ,
      .rd_cmd_has_next_pending   ( next_pending_ir   ) ,
      // To MCB
      .cmd_en                    ( mcb_cmd_en_i           ) ,
      .cmd_instr                 ( mcb_cmd_instr_i        ) ,
      .cmd_bl                    ( mcb_cmd_bl_i           ) ,
      .cmd_byte_addr             ( mcb_cmd_byte_addr_i    ) ,
      .cmd_empty                 ( mcb_cmd_empty_i        ) ,
      .cmd_full                  ( mcb_cmd_full_i         )
    );
  end
  else if (C_S_AXI_SUPPORTS_READ && !C_S_AXI_SUPPORTS_WRITE) begin : NO_CMD_ARBITER_RD_ONLY
    assign mcb_cmd_en_i        = cmd_en_ir        ;
    assign mcb_cmd_instr_i     = cmd_instr_ir     ;
    assign mcb_cmd_bl_i        = wrap_cmd_sel_ir ? wrap_cmd_bl_ir : incr_cmd_bl_ir      ;
    assign mcb_cmd_byte_addr_i = wrap_cmd_sel_ir ? wrap_cmd_byte_addr_ir : incr_cmd_byte_addr_ir ;
    assign cmd_empty_ir        = mcb_cmd_empty_i  ;
    assign cmd_full_ir         = mcb_cmd_full_i   ;
  end
  else begin : NO_CMD_ARBITER_WR_ONLY
    assign mcb_cmd_en_i        = cmd_en_iw        ;
    assign mcb_cmd_instr_i     = cmd_instr_iw     ;
    assign mcb_cmd_bl_i        = wrap_cmd_sel_iw ? wrap_cmd_bl_iw : incr_cmd_bl_iw      ;
    assign mcb_cmd_byte_addr_i = wrap_cmd_sel_iw ? wrap_cmd_byte_addr_iw : incr_cmd_byte_addr_iw ;
    assign cmd_empty_iw        = mcb_cmd_empty_i  ;
    assign cmd_full_iw         = mcb_cmd_full_i   ;
  end
endgenerate

generate
  if (P_PL_MCB_CMD) begin : USE_PL_MCB_CMD
    wire [P_CMD_PAYLOAD_WIDTH-1:0] s_payload_data;
    wire [P_CMD_PAYLOAD_WIDTH-1:0] m_payload_data;
    wire                           s_ready;
    wire                           s_valid;
    wire                           m_ready;
    wire                           m_valid;

    assign s_payload_data = {mcb_cmd_byte_addr_i, mcb_cmd_bl_i, mcb_cmd_instr_i};
    assign s_valid        = mcb_cmd_en_i;
    assign mcb_cmd_full_i = ~s_ready;

    // This provides a 1 deep pipeline that can send data once every other cycle
    // Since the state machine architecture can only send a command once every 
    // other cycle, then this should not reduce any throughput.
    axic_register_slice #
    (
      .C_FAMILY         (C_FAMILY),
      .C_DATA_WIDTH     (P_CMD_PAYLOAD_WIDTH),
      .C_REG_CONFIG     (32'h7)
    )
    mcb_cmd_pipeline_0
    (
       // System Signals
      .ARESET         ( reset          ) ,
      .ACLK           ( aclk           ) ,
       // Slave side
      .S_PAYLOAD_DATA ( s_payload_data ) ,
      .S_VALID        ( s_valid        ) ,
      .S_READY        ( s_ready        ) ,
       // Master side
      .M_PAYLOAD_DATA ( m_payload_data ) ,
      .M_VALID        ( m_valid        ) ,
      .M_READY        ( m_ready        )  
    );

    assign mcb_cmd_instr        = m_payload_data[0 +: 3];
    assign mcb_cmd_bl           = m_payload_data[3 +: 6];
    assign mcb_cmd_byte_addr    = m_payload_data[9 +: C_MCB_ADDR_WIDTH];
    assign mcb_cmd_en           = m_valid;
    assign m_ready              = ~mcb_cmd_full;
    // Does not take into account the pipeline register slice
    assign mcb_cmd_empty_i     = mcb_cmd_empty       ;

  end else begin : NO_PL_MCB_CMD
    assign mcb_cmd_en          = mcb_cmd_en_i        ;
    assign mcb_cmd_instr       = mcb_cmd_instr_i     ;
    assign mcb_cmd_bl          = mcb_cmd_bl_i        ;
    assign mcb_cmd_byte_addr   = mcb_cmd_byte_addr_i ;
    assign mcb_cmd_empty_i     = mcb_cmd_empty       ;
    assign mcb_cmd_full_i      = mcb_cmd_full        ;
  end
endgenerate


endmodule

`default_nettype wire
