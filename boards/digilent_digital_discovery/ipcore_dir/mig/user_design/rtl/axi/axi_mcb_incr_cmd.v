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
// File name: axi_mcb_incr_cmd.v
//
// Description: 
// MCB does not support up to 256 beats per transaction to support an AXI INCR 
// command directly.  Additionally for QOS purposes, larger transactions
// issued as many smaller transactions should improve QoS for the system.
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1ps/1ps
`default_nettype none

module axi_mcb_incr_cmd #
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
                    // Width of the read counters per mcb transaction
                    // Range: 4
  parameter integer C_CNT_WIDTH                 = 4,
                    // Static value of axsize
                    // Rannge: 2-4
  parameter integer C_AXSIZE                    = 2
)
(
///////////////////////////////////////////////////////////////////////////////
// Port Declarations     
///////////////////////////////////////////////////////////////////////////////
  input  wire                                 clk           , 
  input  wire                                 reset         , 
  input  wire [C_AXI_ADDR_WIDTH-1:0]          axaddr        , 
  input  wire [7:0]                           axlen         , 
  input  wire [2:0]                           axsize        , 
  // axhandshake = axvalid & axready
  input  wire                                 axhandshake   , 
  output wire [5:0]                           cmd_bl        , 
  output wire [C_MCB_ADDR_WIDTH-1:0]          cmd_byte_addr , 

  // Connections to/from fsm module
  // signal to increment to the next mcb transaction 
  input  wire                                 next_cmd          , 
  // signal to the fsm there is another transaction required
  output wire                                 next_pending 

);
////////////////////////////////////////////////////////////////////////////////
// Local parameters
////////////////////////////////////////////////////////////////////////////////
localparam P_AXLEN_WIDTH = 8;    
localparam P_CMD_BL_WIDTH = 6;

// AXI commands cannot cross 4096 byte boundaries, set counter max at 12 bits
localparam P_AXI_CNT_WIDTH_MAX = 12;
// Address will always increment by at least C_CNT_WIDTH+
localparam P_AXADDR_CNT_WIDTH = P_AXI_CNT_WIDTH_MAX-(8-C_CNT_WIDTH)-C_AXSIZE;
localparam P_AXADDR_CNT_START = C_AXSIZE + C_CNT_WIDTH;
////////////////////////////////////////////////////////////////////////////////
// Wire and register declarations
////////////////////////////////////////////////////////////////////////////////
reg                           sel_first;     
wire [C_MCB_ADDR_WIDTH-1:0]   axaddr_i;      
wire [C_MCB_ADDR_WIDTH-1:0]   axaddr_incr;   
wire [P_AXADDR_CNT_WIDTH-1:0] axaddr_cnt_in; 
reg  [P_AXADDR_CNT_WIDTH-1:0] axaddr_cnt;    
wire [C_CNT_WIDTH-1:0]        axlen_i;       
wire [C_CNT_WIDTH-1:0]        cmd_bl_i;      
reg  [C_CNT_WIDTH-1:0]        axlen_cnt;     
wire [C_CNT_WIDTH-1:0]        axlen_msb_cnt; 
reg                           axlen_cnt_not_zero;

////////////////////////////////////////////////////////////////////////////////
// BEGIN RTL
////////////////////////////////////////////////////////////////////////////////
// calculate cmd_byte_addr
assign cmd_byte_addr = (sel_first) ? axaddr_i : axaddr_incr;
assign axaddr_i = axaddr[0 +: C_MCB_ADDR_WIDTH];
// Incremented version of axaddr
assign axaddr_incr = { 
                        axaddr_i[P_AXI_CNT_WIDTH_MAX +: C_MCB_ADDR_WIDTH-P_AXI_CNT_WIDTH_MAX], 
                        axaddr_cnt, 
                        axaddr_i[0 +: C_AXSIZE+C_CNT_WIDTH]
                     };
// Pull off bits to increment
assign axaddr_cnt_in = axaddr_i[P_AXADDR_CNT_START +: P_AXADDR_CNT_WIDTH];

// Address Increment Counter
always @(posedge clk) begin
  if (next_cmd) begin
    axaddr_cnt <= axaddr_cnt + 1'b1;
  end else if (sel_first) begin
    axaddr_cnt <= axaddr_cnt_in;
  end
end

// Calculat cmd_bl  
assign cmd_bl = {{(P_CMD_BL_WIDTH-C_CNT_WIDTH){1'b0}}, cmd_bl_i};
assign cmd_bl_i = (next_pending) ? {C_CNT_WIDTH{1'b1}} : axlen_i;
assign axlen_i = axlen[C_CNT_WIDTH-1:0];

// assign next_pending = axlen_msb_cnt > {P_AXADDR_CNT_WIDTH{1'b0}};
assign next_pending = (sel_first) ? (| axlen[C_CNT_WIDTH +: 8-C_CNT_WIDTH]) : axlen_cnt_not_zero;
assign axlen_msb_cnt = (sel_first) ? axlen[C_CNT_WIDTH +: 8-C_CNT_WIDTH]  : axlen_cnt;

// Counter to hold number of transactions left to issue
always @(posedge clk) begin
  if (next_cmd) begin
    axlen_cnt <= axlen_msb_cnt - 1'b1;
    axlen_cnt_not_zero <= (axlen_msb_cnt != {{C_CNT_WIDTH-1{1'b0}}, 1'b1});
  end
end

// Indicates if we are on the first transaction of a mcb translation with more
// than 1 transaction.
always @(posedge clk) begin
  if (reset | axhandshake) begin
    sel_first <= 1'b1;
  end else if (next_cmd) begin
    sel_first <= 1'b0;
  end
end

endmodule
`default_nettype wire
