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
// File name: axi_mcb_w_channel.v
//
// Description: 
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ps/1ps
`default_nettype none

module axi_mcb_w_channel #
(
///////////////////////////////////////////////////////////////////////////////
// Parameter Definitions
///////////////////////////////////////////////////////////////////////////////
                    // Width of AXI xDATA and MCB xx_data
                    // Range: 32, 64, 128.
  parameter integer C_DATA_WIDTH              = 32, 
                    // Width of beat counter, limits max transaction size.
                    // Range: 1-6 (-> 2-64 beat transactions)
  parameter integer C_CNT_WIDTH               = 4, 
                    // Pipelines the wr_full signal from mcb by using
                    // wr_count.  Does not add write latency.
  parameter integer C_PL_WR_FULL              = 1,
                    // Pipelines the wvalid and wready handshake used for
                    // counting.  May add one cycle of latency.
  parameter integer C_PL_WHANDSHAKE           = 1,
                    // Pipelines the intermodule signal w_complete.  May add
                    // 1 cycle of latency.
  parameter integer C_PL_W_COMPLETE           = 1

)
(
///////////////////////////////////////////////////////////////////////////////
// Port Declarations     
///////////////////////////////////////////////////////////////////////////////
  input  wire                                 clk         , 
  input  wire                                 reset       , 

  input  wire [C_DATA_WIDTH-1:0]              wdata,
  input  wire [C_DATA_WIDTH/8-1:0]            wstrb,
  input  wire                                 wlast,
  input  wire                                 wvalid,
  output wire                                 wready,

  output wire                                 wr_en,
  output wire [C_DATA_WIDTH/8-1:0]            wr_mask,
  output wire [C_DATA_WIDTH-1:0]              wr_data,
  input  wire                                 wr_full,
  input  wire                                 wr_empty,
  input  wire [6:0]                           wr_count,
  input  wire                                 wr_underrun,
  input  wire                                 wr_error,
  input  wire                                 calib_done,

  output wire                                 w_complete,
  input wire                                  w_trans_cnt_full 

);

////////////////////////////////////////////////////////////////////////////////
// Local parameters
////////////////////////////////////////////////////////////////////////////////
localparam integer P_MCB_FULL_CNT = 64;

////////////////////////////////////////////////////////////////////////////////
// Wire and register declarations
////////////////////////////////////////////////////////////////////////////////
wire                    whandshake;
reg  [C_CNT_WIDTH-1:0]  cnt;
reg                     subburst_last;
wire                    w_complete_ns;
wire                    w_complete_i;
wire                    wready_i;  
wire                    wlast_i;
wire                    whandshake_i;


////////////////////////////////////////////////////////////////////////////////
// BEGIN RTL
////////////////////////////////////////////////////////////////////////////////

assign wready  = wready_i;
assign wr_en   = whandshake;
assign wr_mask = ~wstrb;
assign wr_data = wdata;

assign whandshake = wvalid & wready;

generate
if (C_PL_WR_FULL) begin : PL_WR_FULL
  reg  [6:0]              wr_count_d1;
  wire                    wr_afull_ns;
  reg                     wready_r;  
  // Calculate almost full from wr_count instead of using wr_full for timing 
  // closure
  always @(posedge clk) begin
    wr_count_d1 <= wr_count;
  end

  assign wr_afull_ns = (wr_count_d1 > (P_MCB_FULL_CNT-3));

  always @(posedge clk) begin
    if (reset) begin
      wready_r <= 1'b0;
    end else begin 
      wready_r <= ~wr_afull_ns & calib_done & ~w_trans_cnt_full;
    end
  end

  assign wready_i = wready_r;
end
else 
begin : NO_PL_WR_FULL
  assign wready_i = ~wr_full & calib_done & ~w_trans_cnt_full;
end
endgenerate


generate 
if (C_PL_WHANDSHAKE) begin : PL_WHANDSHAKE
  reg                     wlast_d1;
  reg                     whandshake_d1;

  // Count the number of beats we have 
  // Use delayed values of the incoming signals for better timing
  always @(posedge clk) begin
    wlast_d1  <= wlast;
    whandshake_d1 <= whandshake;
  end

  assign wlast_i = wlast_d1;
  assign whandshake_i = whandshake_d1;

end
else begin : NO_PL_WHANDSHAKE
  assign wlast_i = wlast;
  assign whandshake_i = whandshake;
end
endgenerate

always @(posedge clk) begin
  if (w_complete_ns | reset) begin
    cnt <= {C_CNT_WIDTH{1'b1}};
  end else if (whandshake_i) begin
    cnt <= cnt - 1'b1;
  end
end

// Determines have reached a subburst boundary
always @(posedge clk) begin
  if (reset | w_complete_ns) begin
    subburst_last <= 1'b0;
  end else if ((cnt == {{C_CNT_WIDTH-1{1'b0}},1'b1}) & whandshake_i) begin
    subburst_last <= 1'b1;
  end
end

assign w_complete_ns = whandshake_i & (wlast_i | subburst_last);

generate 
if (C_PL_W_COMPLETE) begin : PL_W_COMPLETE
  reg w_complete_r; 

  // latch the output of w_complete
  always @(posedge clk) begin
    w_complete_r <= w_complete_ns;
  end

  assign w_complete_i = w_complete_r;

end
else begin : NO_PL_W_COMPLETE
  assign w_complete_i = w_complete_ns;
end
endgenerate
    
assign w_complete = w_complete_i;

endmodule
`default_nettype wire
