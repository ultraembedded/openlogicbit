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
// File name: axi_mcb_aw_channel.v
//
// Description: 
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ps/1ps
`default_nettype none

module axi_mcb_aw_channel #
(
///////////////////////////////////////////////////////////////////////////////
// Parameter Definitions
///////////////////////////////////////////////////////////////////////////////
                    // Width of ID signals.
                    // Range: >= 1.
  parameter integer C_ID_WIDTH          = 4, 
                    // Width of AxADDR
                    // Range: 32.
  parameter integer C_AXI_ADDR_WIDTH    = 32, 
                    // Width of cmd_byte_addr
                    // Range: 30
  parameter integer C_MCB_ADDR_WIDTH    = 30,
                    // Width of AXI xDATA and MCB xx_data
                    // Range: 32, 64, 128.
  parameter integer C_DATA_WIDTH        = 32,
                    // Width of beat counter, limits max transaction size.
                    // Range: 4
  parameter integer C_CNT_WIDTH         = 4,
                    // Static value of axsize
                    // Range: 2-4
  parameter integer C_AXSIZE            = 2,
  
                    // Enforces strict checking across all MCB ports for 
                    // write data coherency.  This will ensure no race 
                    // conditions will exist between the BRESP and any 
                    // other read/write command on a different MCB port.  
                    // Not necessary for single port MCB operation.
                    // Range: 0, 1 (not implemented 12/1/2009)
  parameter integer C_STRICT_COHERENCY  = 0,
                    // Instructs the memory controller to issue an
                    // auto-precharge after each command.
                    // Range: 0,1
  parameter integer C_ENABLE_AP         = 0,
                    // Register CMD_BL_SECOND for better timing.  Does not add
                    // any latency.
  parameter integer C_PL_CMD_BL_SECOND  = 1

)
(
///////////////////////////////////////////////////////////////////////////////
// Port Declarations     
///////////////////////////////////////////////////////////////////////////////
  // AXI Slave Interface
  // Slave Interface System Signals           
  input  wire                                 clk           , 
  input  wire                                 reset         , 

  // Slave Interface Write Address Ports
  input  wire [C_ID_WIDTH-1:0]                awid          , 
  input  wire [C_AXI_ADDR_WIDTH-1:0]          awaddr        , 
  input  wire [7:0]                           awlen         , 
  input  wire [2:0]                           awsize        , 
  input  wire [1:0]                           awburst       , 
  input  wire [1:0]                           awlock        , 
  input  wire [3:0]                           awcache       , 
  input  wire [2:0]                           awprot        , 
  input  wire [3:0]                           awqos         , 
  input  wire                                 awvalid       , 
  output wire                                 awready       , 

  // MCB Master Interface
  //CMD PORT
  output wire                                 cmd_en        , 
  output wire [2:0]                           cmd_instr     , 
  output wire                                 wrap_cmd_sel       ,
  output wire [5:0]                           wrap_cmd_bl        , 
  output wire [C_MCB_ADDR_WIDTH-1:0]          wrap_cmd_byte_addr , 
  output wire [5:0]                           incr_cmd_bl        , 
  output wire [C_MCB_ADDR_WIDTH-1:0]          incr_cmd_byte_addr , 
  input  wire                                 cmd_empty     , 
  input  wire                                 cmd_full      , 
  input  wire                                 calib_done    ,
  output wire                                 next_pending  ,

  // Connections to/from axi_mcb_w_channel module
  input  wire                                 w_complete    , 
  output wire                                 w_trans_cnt_full   ,

  // Connections to/from axi_mcb_b_channel module
  output wire                                 b_push        , 
  output wire [C_ID_WIDTH-1:0]                b_awid        , 
  input  wire                                 b_full       

);

////////////////////////////////////////////////////////////////////////////////
// Local parameters
////////////////////////////////////////////////////////////////////////////////
// MCB Commands
localparam                          P_CMD_WRITE                = 3'b000;
localparam                          P_CMD_READ                 = 3'b001;
localparam                          P_CMD_WRITE_AUTO_PRECHARGE = 3'b010;
localparam                          P_CMD_READ_AUTO_PRECHARGE  = 3'b011;
localparam                          P_CMD_REFRESH              = 3'b100;
// AXI Burst Types
localparam                          P_AXBURST_FIXED            = 2'b00;
localparam                          P_AXBURST_INCR             = 2'b01;
localparam                          P_AXBURST_WRAP             = 2'b10;
// Transaction counter depth
localparam                          P_TRANS_CNT_WIDTH          = 3;
localparam                          P_TRANS_CNT_FULL           = (1<<P_TRANS_CNT_WIDTH)-5;


////////////////////////////////////////////////////////////////////////////////
// Wires/Reg declarations
////////////////////////////////////////////////////////////////////////////////
wire [C_ID_WIDTH-1:0]       awid_i       ; 
wire [C_AXI_ADDR_WIDTH-1:0] awaddr_i     ; 
wire [7:0]                  awlen_i      ; 
wire [2:0]                  awsize_i     ; 
wire [1:0]                  awburst_i    ; 
wire [1:0]                  awlock_i     ; 
wire [3:0]                  awcache_i    ; 
wire [2:0]                  awprot_i     ; 
wire [3:0]                  awqos_i      ; 
wire                        awvalid_i    ; 
wire                        awready_i    ; 
wire                        next_cmd     ; 
wire                        next_cnt     ;
reg [P_TRANS_CNT_WIDTH-1:0] w_trans_cnt         ; 
wire                        w_trans_cnt_full_ns ;
reg                         w_trans_cnt_full_r  ;
wire                        wdata_complete ;

////////////////////////////////////////////////////////////////////////////////
// BEGIN RTL
////////////////////////////////////////////////////////////////////////////////

assign awid_i    = awid      ; 
assign awaddr_i  = awaddr    ; 
assign awlen_i   = awlen     ; 
assign awsize_i  = awsize    ; 
assign awburst_i = awburst   ; 
assign awlock_i  = awlock    ; 
assign awcache_i = awcache   ; 
assign awprot_i  = awprot    ; 
assign awqos_i   = awqos     ; 
assign awvalid_i = awvalid   ; 
assign awready   = awready_i ; 

// Translate the AXI transaction to the MCB transaction(s)
axi_mcb_cmd_translator #
(
  .C_AXI_ADDR_WIDTH   ( C_AXI_ADDR_WIDTH   ) ,
  .C_MCB_ADDR_WIDTH   ( C_MCB_ADDR_WIDTH   ) ,
  .C_DATA_WIDTH       ( C_DATA_WIDTH       ) ,
  .C_CNT_WIDTH        ( C_CNT_WIDTH        ) ,
  .C_AXSIZE           ( C_AXSIZE           ) ,
  .C_PL_CMD_BL_SECOND ( C_PL_CMD_BL_SECOND ) 
)
axi_mcb_cmd_translator_0
(
  .clk                ( clk                   ) ,
  .reset              ( reset                 ) ,
  .axaddr             ( awaddr_i              ) ,
  .axlen              ( awlen_i               ) ,
  .axsize             ( awsize_i              ) ,
  .axburst            ( awburst_i             ) ,
  .axhandshake        ( awvalid_i & awready_i ) ,
  .wrap_cmd_sel       ( wrap_cmd_sel          ) ,
  .wrap_cmd_bl        ( wrap_cmd_bl           ) ,
  .wrap_cmd_byte_addr ( wrap_cmd_byte_addr    ) ,
  .incr_cmd_bl        ( incr_cmd_bl           ) ,
  .incr_cmd_byte_addr ( incr_cmd_byte_addr    ) ,
  .next_cmd           ( next_cmd              ) ,
  .next_pending       ( next_pending          ) 
);

axi_mcb_cmd_fsm aw_axi_mcb_cmd_fsm_0
(
  .clk          ( clk            ) ,
  .reset        ( reset          ) ,
  .axready      ( awready_i      ) ,
  .axvalid      ( awvalid_i      ) ,
  .cmd_en       ( cmd_en         ) ,
  .cmd_full     ( cmd_full       ) ,
  .calib_done   ( calib_done     ) ,
  .next_cmd     ( next_cmd       ) ,
  .next_pending ( next_pending   ) ,
  .data_ready   ( wdata_complete ) ,
  .b_push       ( b_push         ) ,
  .b_full       ( b_full         ) ,
  .r_push       (                )
);

assign cmd_instr = C_ENABLE_AP ? P_CMD_WRITE_AUTO_PRECHARGE : P_CMD_WRITE;
assign b_awid = awid_i;

// Count of the number of write data transactions sent to MCB.  This would 
// either be when 16 beats of write data are pushed into MCB or when a wlast
// is asserted.
always @(posedge clk) begin
  if (reset) begin 
    w_trans_cnt <= {P_TRANS_CNT_WIDTH{1'b0}};
  end else if (w_complete & ~next_cnt) begin
    w_trans_cnt <= w_trans_cnt + 1'b1;
  end else if (~w_complete & next_cnt) begin
    w_trans_cnt <= w_trans_cnt - 1'b1;
  end
end

always @(posedge clk) begin
  if (reset) begin 
    w_trans_cnt_full_r <= 1'b0;
  end else if (w_complete & ~next_cnt & (w_trans_cnt >= P_TRANS_CNT_FULL)) begin
    w_trans_cnt_full_r <= 1'b1;
  end else if (~w_complete & next_cnt & (w_trans_cnt < P_TRANS_CNT_FULL)) begin
    w_trans_cnt_full_r <= 1'b0;
  end
end

assign w_trans_cnt_full = w_trans_cnt_full_r; 
/*assign w_trans_cnt_full_ns = w_trans_cnt > ((1<<P_TRANS_CNT_WIDTH)-4);*/

/*always @(posedge clk) begin*/
/*  w_trans_cnt_full_r <= w_trans_cnt_full_ns;*/
/*end*/

assign wdata_complete = (w_trans_cnt > 0) | w_complete;

assign next_cnt       = (cmd_en & ~cmd_full) & ~(wrap_cmd_sel & next_pending);

    

endmodule

`default_nettype wire
