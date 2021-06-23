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
// File name: axi_mcb_cmd_arbiter.v
//
// Description: 
// This arbiter arbitrates commands from the read and write address channels
// of AXI to the single CMD channel of the MCB interface.  The inputs are the
// read and write commands that have already been translated to the MCB
// format.
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ps/1ps
`default_nettype none

module axi_mcb_cmd_arbiter #
(
///////////////////////////////////////////////////////////////////////////////
// Parameter Definitions
///////////////////////////////////////////////////////////////////////////////
                    // Width of cmd_byte_addr
                    // Range: 30
  parameter integer C_MCB_ADDR_WIDTH    = 30
)
(
///////////////////////////////////////////////////////////////////////////////
// Port Declarations     
///////////////////////////////////////////////////////////////////////////////
  // AXI Slave Interface
  // Slave Interface System Signals           
  input  wire                                 clk              , 
  input  wire                                 reset            , 

  input  wire                                 wr_cmd_en        , 
  input  wire [2:0]                           wr_cmd_instr     , 
  input  wire                                 wr_wrap_cmd_sel       ,
  input  wire [5:0]                           wr_wrap_cmd_bl        , 
  input  wire [C_MCB_ADDR_WIDTH-1:0]          wr_wrap_cmd_byte_addr , 
  input  wire [5:0]                           wr_incr_cmd_bl        , 
  input  wire [C_MCB_ADDR_WIDTH-1:0]          wr_incr_cmd_byte_addr , 
  output wire                                 wr_cmd_empty     , 
  output wire                                 wr_cmd_full      , 
  input  wire                                 wr_cmd_has_next_pending ,

  input  wire                                 rd_cmd_en        , 
  input  wire [2:0]                           rd_cmd_instr     , 
  input  wire                                 rd_wrap_cmd_sel       ,
  input  wire [5:0]                           rd_wrap_cmd_bl        , 
  input  wire [C_MCB_ADDR_WIDTH-1:0]          rd_wrap_cmd_byte_addr , 
  input  wire [5:0]                           rd_incr_cmd_bl        , 
  input  wire [C_MCB_ADDR_WIDTH-1:0]          rd_incr_cmd_byte_addr , 
  output wire                                 rd_cmd_empty     , 
  output wire                                 rd_cmd_full      , 
  input  wire                                 rd_cmd_has_next_pending ,

  output wire                                 cmd_en           , 
  output wire [2:0]                           cmd_instr        , 
  output wire [5:0]                           cmd_bl           , 
  output wire [C_MCB_ADDR_WIDTH-1:0]          cmd_byte_addr    , 
  input  wire                                 cmd_empty        , 
  input  wire                                 cmd_full

);

////////////////////////////////////////////////////////////////////////////////
// Local parameters
////////////////////////////////////////////////////////////////////////////////
localparam P_ARB_ALGO = "READ_PRIORITY_REG";
//localparam P_ARB_ALGO = "ROUND_ROBIN";

////////////////////////////////////////////////////////////////////////////////
// Wires/Reg declarations
////////////////////////////////////////////////////////////////////////////////
wire                        rnw;
reg [C_MCB_ADDR_WIDTH-1:0]  cmd_byte_addr_i;
reg [5:0]                   cmd_bl_i;
reg                         wr_cmd_en_last;
reg                         rd_cmd_en_last;
////////////////////////////////////////////////////////////////////////////////
// BEGIN RTL
////////////////////////////////////////////////////////////////////////////////
assign cmd_en        = rnw ? rd_cmd_en : wr_cmd_en;
assign cmd_instr     = rnw ? rd_cmd_instr     : wr_cmd_instr;
assign cmd_bl        = cmd_bl_i;
assign cmd_byte_addr = cmd_byte_addr_i;
assign wr_cmd_empty  = cmd_empty;
assign wr_cmd_full   = rnw ? 1'b1 : cmd_full;
assign rd_cmd_empty  = cmd_empty;
assign rd_cmd_full   = ~rnw ? 1'b1 : cmd_full;


always @(*) begin
  casex ({wr_wrap_cmd_sel, rd_wrap_cmd_sel, rnw}) // synopsys parallel_case
    3'bx01: cmd_byte_addr_i = rd_incr_cmd_byte_addr;
    3'bx11: cmd_byte_addr_i = rd_wrap_cmd_byte_addr;
    3'b1x0: cmd_byte_addr_i = wr_wrap_cmd_byte_addr;
    default: cmd_byte_addr_i = wr_incr_cmd_byte_addr; // 3'b0x0
  endcase
end

always @(*) begin
  casex ({wr_wrap_cmd_sel, rd_wrap_cmd_sel, rnw}) // synopsys parallel_case
    3'bx01: cmd_bl_i = rd_incr_cmd_bl;
    3'bx11: cmd_bl_i = rd_wrap_cmd_bl;
    3'b1x0: cmd_bl_i = wr_wrap_cmd_bl;
    default: cmd_bl_i = wr_incr_cmd_bl; // 3'b0x0
  endcase
end

generate
  // TDM Arbitration scheme
  if (P_ARB_ALGO == "TDM") begin : TDM
    reg rnw_i;
    // Register rnw status
    always @(posedge clk) begin
      if (reset) begin
        rnw_i <= 1'b0;
      end else begin
        rnw_i <= ~rnw_i;
      end
    end
    assign rnw = rnw_i;
  end
  else if (P_ARB_ALGO == "ROUND_ROBIN") begin : ROUND_ROBIN
    reg rnw_i;
    // Register rnw status
    always @(posedge clk) begin
      if (reset) begin
        rnw_i <= 1'b0;
      end else begin
        rnw_i <= ~rnw_i;
      end
    end
    assign rnw = (rnw_i & rd_cmd_en) | (~rnw_i & rd_cmd_en & ~wr_cmd_en);
  end
  else if (P_ARB_ALGO == "ROUND_ROBIN") begin : ROUND_ROBIN
    reg rnw_i;
    // Register rnw status
    always @(posedge clk) begin
      if (reset) begin
        rnw_i <= 1'b0;
      end else begin
        rnw_i <= ~rnw_i;
      end
    end
    assign rnw = (rnw_i & rd_cmd_en) | (~rnw_i & rd_cmd_en & ~wr_cmd_en);
  end
  else if (P_ARB_ALGO == "READ_PRIORITY_REG") begin : READ_PRIORITY_REG
    reg rnw_i;
    reg rd_cmd_en_last;
    reg wr_cmd_en_last;
    wire rd_req;
    wire wr_req;
    always @(posedge clk) begin
      rd_cmd_en_last <= rnw & rd_cmd_en & rd_cmd_has_next_pending;
      wr_cmd_en_last <= ~rnw & wr_cmd_en & wr_cmd_has_next_pending;
    end
    // Register rnw status
    always @(posedge clk) begin
      if (reset) begin
        rnw_i <= 1'b1;
      end else begin
        // Only set RNW to 0 if there is a write pending and read is idle
        rnw_i <= rd_req & ~wr_cmd_en_last ? 1'b1 : ~wr_req;
      end
    end

    assign rd_req = rd_cmd_en | rd_cmd_en_last;
    assign wr_req = wr_cmd_en | wr_cmd_en_last;
    assign rnw = rnw_i;
  end
  else if (P_ARB_ALGO == "READ_PRIORITY") begin : READ_PRIORITY
    assign rnw = ~(wr_cmd_en & ~rd_cmd_en);
  end
  else if (P_ARB_ALGO == "WRITE_PRIORITY_REG") begin : WRITE_PRIORITY_REG
    reg rnw_i;
    // Register rnw status
    always @(posedge clk) begin
      if (reset) begin
        rnw_i <= 1'b0;
      end else begin
        // Only set RNW to 1 if there is a read pending and write is idle
        rnw_i <= (~wr_cmd_en & rd_cmd_en);
      end
    end
    assign rnw = rnw_i;
  end
  else begin : WRITE_PRIORITY
    assign rnw =  (~wr_cmd_en & rd_cmd_en);
  end
endgenerate

endmodule
`default_nettype wire
