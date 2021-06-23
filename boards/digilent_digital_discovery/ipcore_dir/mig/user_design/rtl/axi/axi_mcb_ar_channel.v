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
// File name: axi_mcb_ar_channel.v
//
// Description: 
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ps/1ps
`default_nettype none

module axi_mcb_ar_channel #
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
                    // Rannge: 2-4
  parameter integer C_AXSIZE            = 2,
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

  // Slave Interface Read Address Ports
  input  wire [C_ID_WIDTH-1:0]                arid          , 
  input  wire [C_AXI_ADDR_WIDTH-1:0]          araddr        , 
  input  wire [7:0]                           arlen         , 
  input  wire [2:0]                           arsize        , 
  input  wire [1:0]                           arburst       , 
  input  wire [1:0]                           arlock        , 
  input  wire [3:0]                           arcache       , 
  input  wire [2:0]                           arprot        , 
  input  wire [3:0]                           arqos         , 
  input  wire                                 arvalid       , 
  output wire                                 arready       , 

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

  // Connections to/from axi_mcb_r_channel module
  output wire                                 r_push        , 
  output wire [C_CNT_WIDTH-1:0]               r_length      , 
  output wire [C_ID_WIDTH-1:0]                r_arid        , 
  output wire                                 r_rlast       , 
  input  wire                                 r_full        

);

////////////////////////////////////////////////////////////////////////////////
// Local parameters
////////////////////////////////////////////////////////////////////////////////
localparam integer                  C_REG_SLICE_DEPTH          = 0;
localparam                          P_CMD_WRITE                = 3'b000;
localparam                          P_CMD_READ                 = 3'b001;
localparam                          P_CMD_WRITE_AUTO_PRECHARGE = 3'b010;
localparam                          P_CMD_READ_AUTO_PRECHARGE  = 3'b011;
localparam                          P_CMD_REFRESH              = 3'b100;

////////////////////////////////////////////////////////////////////////////////
// Wires/Reg declarations
////////////////////////////////////////////////////////////////////////////////
wire [C_ID_WIDTH-1:0]       arid_i    ;
wire [C_AXI_ADDR_WIDTH-1:0] araddr_i  ;
wire [7:0]                  arlen_i   ;
wire [2:0]                  arsize_i  ;
wire [1:0]                  arburst_i ;
wire [1:0]                  arlock_i  ;
wire [3:0]                  arcache_i ;
wire [2:0]                  arprot_i  ;
wire [3:0]                  arqos_i   ;
wire                        arvalid_i ;
wire                        arready_i ;
wire                        next_cmd  ;

////////////////////////////////////////////////////////////////////////////////
// BEGIN RTL
////////////////////////////////////////////////////////////////////////////////

assign arid_i    = arid      ; 
assign araddr_i  = araddr    ; 
assign arlen_i   = arlen     ; 
assign arsize_i  = arsize    ; 
assign arburst_i = arburst   ; 
assign arlock_i  = arlock    ; 
assign arcache_i = arcache   ; 
assign arprot_i  = arprot    ; 
assign arqos_i   = arqos     ; 
assign arvalid_i = arvalid   ; 
assign arready   = arready_i ; 

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
  .axaddr             ( araddr_i              ) ,
  .axlen              ( arlen_i               ) ,
  .axsize             ( arsize_i              ) ,
  .axburst            ( arburst_i             ) ,
  .axhandshake        ( arvalid_i & arready_i ) ,
  .wrap_cmd_sel       ( wrap_cmd_sel          ) ,
  .wrap_cmd_bl        ( wrap_cmd_bl           ) ,
  .wrap_cmd_byte_addr ( wrap_cmd_byte_addr    ) ,
  .incr_cmd_bl        ( incr_cmd_bl           ) ,
  .incr_cmd_byte_addr ( incr_cmd_byte_addr    ) ,
  .next_cmd           ( next_cmd              ) ,
  .next_pending       ( next_pending          ) 
);

axi_mcb_cmd_fsm ar_axi_mcb_cmd_fsm_0
(
  .clk          ( clk          ) ,
  .reset        ( reset        ) ,
  .axready      ( arready_i    ) ,
  .axvalid      ( arvalid_i    ) ,
  .cmd_en       ( cmd_en       ) ,
  .cmd_full     ( cmd_full     ) ,
  .calib_done   ( calib_done   ) ,
  .next_cmd     ( next_cmd     ) ,
  .next_pending ( next_pending ) ,
  .data_ready   ( ~r_full      ) ,
  .b_push       (              ) ,
  .b_full       ( 1'b0         ) ,
  .r_push       ( r_push       )
);

assign cmd_instr = C_ENABLE_AP ? P_CMD_READ_AUTO_PRECHARGE : P_CMD_READ;
assign r_length = wrap_cmd_sel ? wrap_cmd_bl[0 +: C_CNT_WIDTH] : incr_cmd_bl[0 +: C_CNT_WIDTH];
assign r_arid  = arid_i;
assign r_rlast = ~next_pending;

endmodule

`default_nettype wire
