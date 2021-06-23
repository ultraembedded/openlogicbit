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
// File name: axi_mcb_cmd_fsm.v
//
// Description: 
// Simple state machine to handle sending commands from AXI to MCB.  The flow:
// 1. A transaction can only be initiaited when axvalid is true and data_ready
// is true.  For writes, data_ready means that  one completed burst/sub-burst 
// has been pushed into the MCB write FIFOs.  For read operations,
// data_ready indicates that there is enough room to push the transaction into
// the read FIFO.  If the FIFO in the read channel module is full, then we do
// not have enough room in the MCB FIFO to issue a new transaction.
//
// 2. When CMD_EN is asserted, it remains high until we sample CMD_FULL in
// a low state.  When CMD_EN == 1'b1, and CMD_FULL == 1'b0, then the command
// has been accepted.  When the command is accepted, if the next_pending
// signal is high we will incremented to the next transaction and issue the
// cmd_en again when data_ready is high.  Otherwise we will go to the done
// state.
//
// 3. The AXI transaction can only complete when b_full is not true (for writes)
// and no more mcb transactions need to be issued.  The AXREADY will be
// asserted and the state machine will progress back to the the IDLE state.
// 
///////////////////////////////////////////////////////////////////////////////
`timescale 1ps/1ps
`default_nettype none

module axi_mcb_cmd_fsm 
(
///////////////////////////////////////////////////////////////////////////////
// Port Declarations     
///////////////////////////////////////////////////////////////////////////////
  input  wire                                 clk           , 
  input  wire                                 reset         , 
  output wire                                 axready       , 
  input  wire                                 axvalid       , 
  output wire                                 cmd_en        , 
  input  wire                                 cmd_full      , 
  input  wire                                 calib_done    ,
  // signal to increment to the next mcb transaction 
  output wire                                 next_cmd      , 
  // signal to the fsm there is another transaction required
  input  wire                                 next_pending  ,
  // Write Data portion has completed or Read FIFO has a slot available (not
  // full)
  input  wire                                 data_ready    ,
  output wire                                 b_push        ,
  input  wire                                 b_full        ,
  output wire                                 r_push

);

////////////////////////////////////////////////////////////////////////////////
// Local parameters
////////////////////////////////////////////////////////////////////////////////
// AXBURST decodes
localparam SM_WAIT_FOR_CALIB_DONE = 3'b000;
localparam SM_IDLE                = 3'b001;
localparam SM_CMD_EN              = 3'b010;
localparam SM_CMD_ACCEPTED        = 3'b011;
localparam SM_DONE_WAIT           = 3'b100;
localparam SM_DONE                = 3'b101;
localparam SM_FAIL                = 3'b111;

////////////////////////////////////////////////////////////////////////////////
// Wires/Reg declarations
////////////////////////////////////////////////////////////////////////////////
reg [2:0]       state;
reg [2:0]       next_state;

////////////////////////////////////////////////////////////////////////////////
// BEGIN RTL
////////////////////////////////////////////////////////////////////////////////

// State is registered
always @(posedge clk) begin
  if (reset) begin
    state <= SM_WAIT_FOR_CALIB_DONE;
  end else begin
    state <= next_state;
  end
end

// Next state transitions.
always @(*)
begin
  next_state = state;
  case (state)
    SM_WAIT_FOR_CALIB_DONE:
      if (calib_done)
        next_state = SM_IDLE;
      else 
        next_state = state;

    SM_IDLE:
      if (axvalid & data_ready)
        next_state = SM_CMD_EN;
      else 
        next_state = state;

    SM_CMD_EN:
      if (~cmd_full & next_pending)
        next_state = SM_CMD_ACCEPTED;
      else if (~cmd_full & ~next_pending & b_full)
        next_state = SM_DONE_WAIT;
      else if (~cmd_full & ~next_pending & ~b_full)
        next_state = SM_DONE;
      else 
        next_state = state;

    SM_CMD_ACCEPTED:
      if (data_ready)
        next_state = SM_CMD_EN;
      else 
        next_state = SM_IDLE;

    SM_DONE_WAIT:
      if (!b_full)
        next_state = SM_DONE;
      else 
        next_state = state;

    SM_DONE:
      next_state = SM_IDLE;

    SM_FAIL:
      next_state = SM_FAIL;

      default:
        next_state = SM_FAIL;
  endcase
end

// Assign outputs based on current state.
assign cmd_en   = (state == SM_CMD_EN);
assign next_cmd = (state == SM_CMD_ACCEPTED) || (state == SM_DONE);
assign axready  = (state == SM_DONE);
assign b_push   = (state == SM_DONE);
assign r_push   = (state == SM_CMD_ACCEPTED) || (state == SM_DONE);


endmodule
`default_nettype wire
