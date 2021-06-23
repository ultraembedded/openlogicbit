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
// File name: axi_mcb_r_channel.v
//
// Description: 
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ps/1ps
`default_nettype none

module axi_mcb_r_channel #
(
///////////////////////////////////////////////////////////////////////////////
// Parameter Definitions
///////////////////////////////////////////////////////////////////////////////
                    // Width of ID signals.
                    // Range: >= 1.
  parameter integer C_ID_WIDTH                = 4, 
                    // Width of AXI xDATA and MCB xx_data
                    // Range: 32, 64, 128.
  parameter integer C_DATA_WIDTH              = 32, 
                    // Width of beat counter, limits max transaction size.
                    // Range: 1-6 (-> 2-64 beat transactions)
  parameter integer C_CNT_WIDTH               = 4,
                    // Pipelines the output of rd_empty to rvalid,
                    // Adds at least one cycle of latency.
  parameter integer C_PL_RD_EMPTY       = 1
)
(
///////////////////////////////////////////////////////////////////////////////
// Port Declarations     
///////////////////////////////////////////////////////////////////////////////
  input  wire                                 clk         , 
  input  wire                                 reset       , 

  output wire [C_ID_WIDTH-1:0]                rid         , 
  output wire [C_DATA_WIDTH-1:0]              rdata       , 
  output wire [1:0]                           rresp       , 
  output wire                                 rlast       , 
  output wire                                 rvalid      , 
  input  wire                                 rready      , 

  output wire                                 rd_en       , 
  input  wire [C_DATA_WIDTH-1:0]              rd_data     , 
  input  wire                                 rd_full     , 
  input  wire                                 rd_empty    , 
  input  wire [6:0]                           rd_count    , 
  input  wire                                 rd_overflow , 
  input  wire                                 rd_error    , 

  // Connections to/from axi_mcb_ar_channel module
  input  wire                                 r_push      , 
  input  wire [C_CNT_WIDTH-1:0]               r_length    , 
  input  wire [C_ID_WIDTH-1:0]                r_arid      , 
  input  wire                                 r_rlast     , 
  output wire                                 r_full

);

////////////////////////////////////////////////////////////////////////////////
// Local parameters
////////////////////////////////////////////////////////////////////////////////
localparam P_WIDTH = C_CNT_WIDTH+C_ID_WIDTH+2;
localparam P_DEPTH = (C_CNT_WIDTH == 4) ? 4 :
                     (C_CNT_WIDTH == 5) ? 2 :
                     1;
localparam P_AWIDTH = (P_DEPTH == 4) ? 2 : 1;
// AXI protocol responses:
localparam P_OKAY   = 2'b00;
localparam P_EXOKAY = 2'b01;
localparam P_SLVERR = 2'b10;
localparam P_DECERR = 2'b11;

////////////////////////////////////////////////////////////////////////////////
// Wire and register declarations
////////////////////////////////////////////////////////////////////////////////
wire [C_ID_WIDTH-1:0]  rid_i;
reg                    cnt_is_zero;
wire                   assert_rlast;
wire                   length_is_zero_i;
wire                   length_is_zero;
wire [P_WIDTH-1:0]     trans_in;
wire [P_WIDTH-1:0]     trans_out;
wire                   fifo_a_full;
wire                   fifo_full;
wire                   fifo_empty;
wire [C_CNT_WIDTH-1:0] length;
wire                   rhandshake;
reg  [C_CNT_WIDTH-1:0]   cnt;
wire [C_CNT_WIDTH-1:0]   rcnt;
wire                   rvalid_i;
reg                    sel_first;
(* KEEP = "TRUE" *) wire                   done /* synthesis syn_keep = 1 */;

////////////////////////////////////////////////////////////////////////////////
// BEGIN RTL
////////////////////////////////////////////////////////////////////////////////

// assign AXI outputs
assign rid        = rid_i;
assign rdata      = rd_data;
assign rresp      = P_OKAY;
assign rlast      = ((length_is_zero | cnt_is_zero) & assert_rlast);
assign rvalid     = rvalid_i;

generate
if (C_PL_RD_EMPTY) begin : PL_RD_EMPTY
  reg                    rd_empty_d1;
  reg [6:0]              rd_count_d1;
  reg                    rhandshake_d1;
  reg                    rd_count_gt_2;
  reg                    fifo_empty_d1;

  assign rvalid_i = ((~rd_empty_d1 & ~rhandshake_d1) | rd_count_gt_2);

  always @(posedge clk) begin 
    rd_empty_d1 <= rd_empty;
    rd_count_d1 <= rd_count;
    rhandshake_d1 <= rhandshake;
    rd_count_gt_2 <= rd_count > 2;
    fifo_empty_d1 <= fifo_empty;
  end
end
else begin : NO_PL_RD_EMPTY
  assign rvalid_i = ~rd_empty & ~fifo_empty;
end
endgenerate

// assign MCB outputs
assign rd_en      = rhandshake;

// assign axi_mcb_ar_channel outputs
assign r_full     = fifo_full | (r_push & fifo_a_full);

// Push input from axi_mcb_ar_channel into FIFO
assign length_is_zero_i = (r_length[0 +: C_CNT_WIDTH] == 0);
assign trans_in         = {r_length, r_arid, r_rlast, length_is_zero_i};

axi_mcb_simple_fifo #(
  .C_WIDTH                  (P_WIDTH),
  .C_AWIDTH                 (P_AWIDTH),
  .C_DEPTH                  (P_DEPTH)
)
transaction_fifo_0
(
  .clk     ( clk         ) ,
  .rst     ( reset       ) ,
  .wr_en   ( r_push      ) ,
  .rd_en   ( done        ) ,
  .din     ( trans_in    ) ,
  .dout    ( trans_out   ) ,
  .a_full  ( fifo_a_full ) ,
  .full    ( fifo_full   ) ,
  .a_empty (             ) ,
  .empty   ( fifo_empty  ) 
);

assign length           = trans_out[2+C_ID_WIDTH +: C_CNT_WIDTH];
assign rid_i            = trans_out[2 +: C_ID_WIDTH];
assign assert_rlast     = trans_out[1];
assign length_is_zero   = trans_out[0];

// Alias for succesful handshake
assign rhandshake = rvalid & rready;

// Read Transaction counter
always @(posedge clk) begin
  if (rhandshake) begin
    cnt <= rcnt - 1'b1;
  end
end

// Register compare output of counter for timing
always @(posedge clk) begin
  if (reset) begin
    cnt_is_zero <= 1'b0;
  end
  else if (rhandshake) begin
    cnt_is_zero <= (rcnt == {{C_CNT_WIDTH-1{1'b0}}, 1'b1}); // rcnt == 1
  end
end

// For the first beat, use the output of the fifo, otherwise use the output of
// the counter
assign rcnt = sel_first ? length : cnt;

// Indicates if we are on the first beat of a transaction
always @(posedge clk) begin
  if (reset | done) begin
    sel_first <= 1'b1;
  end else if (rhandshake) begin
    sel_first <= 1'b0;
  end
end

// Transaction is complete when rhandshake and rcnt_is_zero
// assign done = rvalid & rready & rcnt_is_zero;

// Timing optimiziation of above statement 
assign done = rvalid & rready & (length_is_zero | cnt_is_zero);

endmodule
`default_nettype wire
