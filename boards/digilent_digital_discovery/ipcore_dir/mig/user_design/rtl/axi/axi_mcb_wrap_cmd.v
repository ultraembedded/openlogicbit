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
// File name: axi_mcb_wrap_cmd.v
//
// Description: 
// MCB does not support an AXI WRAP command directly.  
// To complete an AXI WRAP transaction we will issue one transaction if the
// address is wrap boundary aligned, otherwise two transactions are issued.
// The first transaction is from the starting offset to the wrap address upper
// boundary.  The second transaction is from the wrap boundary lowest address
// to the address offset.  WRAP burst types will never exceed 16 beats.
//
// Calculates the number of MCB beats for each axi transaction for WRAP
// burst type ( for all axsize values = C_DATA_WIDTH ):
// AR_SIZE   | AR_LEN     | OFFSET | NUM_BEATS 1 | NUM_BEATS 2
// b010(  4) | b0001(  2) |  b0000 |   2         |   0 
// b010(  4) | b0001(  2) |  b0001 |   1         |   1 
// b010(  4) | b0011(  4) |  b0000 |   4         |   0 
// b010(  4) | b0011(  4) |  b0001 |   3         |   1 
// b010(  4) | b0011(  4) |  b0010 |   2         |   2 
// b010(  4) | b0011(  4) |  b0011 |   1         |   3 
// b010(  4) | b0111(  8) |  b0000 |   8         |   0 
// b010(  4) | b0111(  8) |  b0001 |   7         |   1 
// b010(  4) | b0111(  8) |  b0010 |   6         |   2 
// b010(  4) | b0111(  8) |  b0011 |   5         |   3 
// b010(  4) | b0111(  8) |  b0100 |   4         |   4 
// b010(  4) | b0111(  8) |  b0101 |   3         |   5 
// b010(  4) | b0111(  8) |  b0110 |   2         |   6 
// b010(  4) | b0111(  8) |  b0111 |   1         |   7 
// b010(  4) | b1111( 16) |  b0000 |  16         |   0 
// b010(  4) | b1111( 16) |  b0001 |  15         |   1 
// b010(  4) | b1111( 16) |  b0010 |  14         |   2 
// b010(  4) | b1111( 16) |  b0011 |  13         |   3 
// b010(  4) | b1111( 16) |  b0100 |  12         |   4 
// b010(  4) | b1111( 16) |  b0101 |  11         |   5 
// b010(  4) | b1111( 16) |  b0110 |  10         |   6 
// b010(  4) | b1111( 16) |  b0111 |   9         |   7 
// b010(  4) | b1111( 16) |  b1000 |   8         |   8 
// b010(  4) | b1111( 16) |  b1001 |   7         |   9 
// b010(  4) | b1111( 16) |  b1010 |   6         |  10 
// b010(  4) | b1111( 16) |  b1011 |   5         |  11 
// b010(  4) | b1111( 16) |  b1100 |   4         |  12 
// b010(  4) | b1111( 16) |  b1101 |   3         |  13 
// b010(  4) | b1111( 16) |  b1110 |   2         |  14 
// b010(  4) | b1111( 16) |  b1111 |   1         |  15 
///////////////////////////////////////////////////////////////////////////////

`timescale 1ps/1ps
`default_nettype none

module axi_mcb_wrap_cmd #
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
                    // Register CMD_BL_SECOND for better timing.  Does not add
                    // any latency.
  parameter integer C_PL_CMD_BL_SECOND        = 1
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
  input  wire                                 next_cmd      , 
  // signal to the fsm there is another transaction required
  output wire                                 next_pending 

);
////////////////////////////////////////////////////////////////////////////////
// Wire and register declarations
////////////////////////////////////////////////////////////////////////////////
reg                         sel_first;
wire [C_MCB_ADDR_WIDTH-1:0] axaddr_i;
wire [3:0]                  axlen_i;
wire [C_MCB_ADDR_WIDTH-1:0] wrap_boundary_axaddr;
wire [3:0]                  axaddr_offset;
wire [3:0]                  cmd_bl_i;
wire [3:0]                  cmd_bl_first;
wire [3:0]                  cmd_bl_second;
wire [3:0]                  cmd_bl_second_i;
wire [3:0]                  cmd_bl_second_ns;
wire                        next_pending_ns;
reg                         next_pending_r;

////////////////////////////////////////////////////////////////////////////////
// BEGIN RTL
////////////////////////////////////////////////////////////////////////////////
assign cmd_byte_addr = (sel_first) ? axaddr_i : wrap_boundary_axaddr;
assign axaddr_i = axaddr[0 +: C_MCB_ADDR_WIDTH];
assign axlen_i = axlen[3:0];
// Mask bits based on transaction length to get wrap boundary low address
assign wrap_boundary_axaddr = axaddr_i & ~(axlen_i << axsize);

// Offset used to calculate the length of each transaction
assign axaddr_offset = axaddr_i[axsize +: 4] & axlen_i;
// burst length will never exceed 16 beats, add zeros to msb
assign cmd_bl = {2'b0, cmd_bl_i};
assign cmd_bl_i = (sel_first) ? cmd_bl_first : cmd_bl_second;
// Equations for calculating the number of beats.
assign cmd_bl_first = axlen_i & ~axaddr_offset;
assign cmd_bl_second    = cmd_bl_second_i;
assign cmd_bl_second_ns = axaddr_offset - 1'b1;

generate
if (C_PL_CMD_BL_SECOND) begin : PL_CMD_BL_SECOND
  reg  [3:0]                  cmd_bl_second_r;

  always @(posedge clk) begin
    cmd_bl_second_r <= cmd_bl_second_ns;
  end

  assign cmd_bl_second_i = cmd_bl_second_r;
end else begin : NO_PL_CMD_BL_SECOND
  assign cmd_bl_second_i = cmd_bl_second_ns;
end
endgenerate

assign next_pending_ns = ((axaddr_offset > 4'b0000) & sel_first) & ~next_cmd;

always @(posedge clk) begin
  next_pending_r <= next_pending_ns;
end
// Assign output
assign next_pending = next_pending_r;

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
