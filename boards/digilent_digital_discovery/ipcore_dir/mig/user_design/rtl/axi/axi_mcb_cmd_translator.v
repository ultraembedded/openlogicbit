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
// File name: axi_mcb_cmd_translator.v
//
// Description: 
// INCR and WRAP burst modes are decoded in parallel and then the output is
// chosen based on the AxBURST value.  FIXED burst mode is not supported and
// is mapped to the INCR command instead.  
//
// Specifications:
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ps/1ps
`default_nettype none

module axi_mcb_cmd_translator #
(
///////////////////////////////////////////////////////////////////////////////
// Parameter Definitions
///////////////////////////////////////////////////////////////////////////////
                    // Width of AxADDR
                    // Range: 32.
  parameter integer C_AXI_ADDR_WIDTH            = 32, 
                    // Width of cmd_byte_addr
                    // Range: 30
  parameter integer C_MCB_ADDR_WIDTH            = 30,
                    // Width of AXI xDATA and MCB xx_data
                    // Range: 32, 64, 128.
  parameter integer C_DATA_WIDTH                = 32,
                    // Width of beat counter, limits max transaction size.
                    // Range: 4
  parameter integer C_CNT_WIDTH                 = 4,
                    // Static value of axsize
                    // Rannge: 2-4
  parameter integer C_AXSIZE                    = 2,
                    // Register CMD_BL_SECOND for better timing.  Does not add
                    // any latency.
  parameter integer C_PL_CMD_BL_SECOND           = 1
)
(
///////////////////////////////////////////////////////////////////////////////
// Port Declarations     
///////////////////////////////////////////////////////////////////////////////
  input  wire                                 clk                , 
  input  wire                                 reset              , 
  input  wire [C_AXI_ADDR_WIDTH-1:0]          axaddr             , 
  input  wire [7:0]                           axlen              , 
  input  wire [2:0]                           axsize             , 
  input  wire [1:0]                           axburst            , 
  input  wire                                 axhandshake        , 
  output wire                                 wrap_cmd_sel       ,
  output wire [C_MCB_ADDR_WIDTH-1:0]          wrap_cmd_byte_addr , 
  output wire [5:0]                           wrap_cmd_bl        , 
  output wire [C_MCB_ADDR_WIDTH-1:0]          incr_cmd_byte_addr , 
  output wire [5:0]                           incr_cmd_bl        , 

  // Connections to/from fsm module
  // signal to increment to the next mcb transaction 
  input  wire                                 next_cmd           , 
  // signal to the fsm there is another transaction required
  output wire                                 next_pending


);

////////////////////////////////////////////////////////////////////////////////
// Local parameters
////////////////////////////////////////////////////////////////////////////////
// AXBURST decodes
localparam P_AXBURST_FIXED = 2'b00;
localparam P_AXBURST_INCR  = 2'b01;
localparam P_AXBURST_WRAP  = 2'b10;

////////////////////////////////////////////////////////////////////////////////
// Wires/Reg declarations
////////////////////////////////////////////////////////////////////////////////
wire [C_MCB_ADDR_WIDTH-1:0]     incr_cmd_byte_addr_i;
wire [5:0]                      incr_cmd_bl_i;
wire                            incr_next_pending;
wire [C_MCB_ADDR_WIDTH-1:0]     wrap_cmd_byte_addr_i;
wire [5:0]                      wrap_cmd_bl_i;
wire                            wrap_next_pending;
reg  [1:0]                      axburst_d1;
reg  [5:0]                      wrap_cmd_bl_d1;
reg  [5:0]                      incr_cmd_bl_d1;

////////////////////////////////////////////////////////////////////////////////
// BEGIN RTL
////////////////////////////////////////////////////////////////////////////////

// INCR and WRAP translations are calcuated in independently, select the one
// for our transactions
always @(posedge clk) begin
  axburst_d1 <= axburst;
  wrap_cmd_bl_d1 <= wrap_cmd_bl;
  incr_cmd_bl_d1 <= incr_cmd_bl;
end

// No support for FIXED.  Anything other than a wrap is treated as INCR.
assign wrap_cmd_sel         = axburst_d1[1];
assign wrap_cmd_byte_addr   = {wrap_cmd_byte_addr_i[C_MCB_ADDR_WIDTH-1:C_AXSIZE], {C_AXSIZE{1'b0}}};
assign wrap_cmd_bl          = wrap_cmd_bl_i;
assign incr_cmd_byte_addr   = {incr_cmd_byte_addr_i[C_MCB_ADDR_WIDTH-1:C_AXSIZE], {C_AXSIZE{1'b0}}};
assign incr_cmd_bl          = incr_cmd_bl_i;

assign next_pending     = wrap_cmd_sel ? wrap_next_pending : incr_next_pending;

axi_mcb_incr_cmd #
(
  .C_AXI_ADDR_WIDTH (C_AXI_ADDR_WIDTH),
  .C_MCB_ADDR_WIDTH (C_MCB_ADDR_WIDTH),
  .C_DATA_WIDTH     (C_DATA_WIDTH),
  .C_CNT_WIDTH      (C_CNT_WIDTH),
  .C_AXSIZE         (C_AXSIZE)
)
axi_mcb_incr_cmd_0
(
  .clk           ( clk                  ) ,
  .reset         ( reset                ) ,
  .axaddr        ( axaddr               ) ,
  .axlen         ( axlen                ) ,
  .axsize        ( axsize               ) ,
  .axhandshake   ( axhandshake          ) ,
  .cmd_bl        ( incr_cmd_bl_i        ) ,
  .cmd_byte_addr ( incr_cmd_byte_addr_i ) ,
  .next_cmd      ( next_cmd             ) ,
  .next_pending  ( incr_next_pending    ) 
);

axi_mcb_wrap_cmd #
(
  .C_AXI_ADDR_WIDTH   ( C_AXI_ADDR_WIDTH   ) ,
  .C_MCB_ADDR_WIDTH   ( C_MCB_ADDR_WIDTH   ) ,
  .C_DATA_WIDTH       ( C_DATA_WIDTH       ) ,
  .C_PL_CMD_BL_SECOND ( C_PL_CMD_BL_SECOND ) 
)
axi_mcb_wrap_cmd_0
(
  .clk           ( clk                  ) ,
  .reset         ( reset                ) ,
  .axaddr        ( axaddr               ) ,
  .axlen         ( axlen                ) ,
  .axsize        ( axsize               ) ,
  .axhandshake   ( axhandshake          ) ,
  .cmd_bl        ( wrap_cmd_bl_i        ) ,
  .cmd_byte_addr ( wrap_cmd_byte_addr_i ) ,
  .next_cmd      ( next_cmd             ) ,
  .next_pending  ( wrap_next_pending    ) 
);

endmodule
`default_nettype wire
