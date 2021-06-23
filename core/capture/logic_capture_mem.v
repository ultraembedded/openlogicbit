//-----------------------------------------------------------------
//                         open-logic-bit
//                            V0.1
//                        Copyright 2021
//              github.com/ultraembedded/openlogicbit
//
//                   admin@ultra-embedded.com
//
//                     License: Apache 2.0
//-----------------------------------------------------------------
// Copyright 2021 Ultra-Embedded.com
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//-----------------------------------------------------------------
module logic_capture_mem
(
    // Inputs
     input           clk_i
    ,input           rst_i
    ,input           cfg_awvalid_i
    ,input  [ 31:0]  cfg_awaddr_i
    ,input           cfg_wvalid_i
    ,input  [ 31:0]  cfg_wdata_i
    ,input  [  3:0]  cfg_wstrb_i
    ,input           cfg_bready_i
    ,input           cfg_arvalid_i
    ,input  [ 31:0]  cfg_araddr_i
    ,input           cfg_rready_i
    ,input           input_valid_i
    ,input  [ 31:0]  input_data_i
    ,input           outport_awready_i
    ,input           outport_wready_i
    ,input           outport_bvalid_i
    ,input  [  1:0]  outport_bresp_i
    ,input  [  3:0]  outport_bid_i
    ,input           outport_arready_i
    ,input           outport_rvalid_i
    ,input  [ 31:0]  outport_rdata_i
    ,input  [  1:0]  outport_rresp_i
    ,input  [  3:0]  outport_rid_i
    ,input           outport_rlast_i

    // Outputs
    ,output          cfg_awready_o
    ,output          cfg_wready_o
    ,output          cfg_bvalid_o
    ,output [  1:0]  cfg_bresp_o
    ,output          cfg_arready_o
    ,output          cfg_rvalid_o
    ,output [ 31:0]  cfg_rdata_o
    ,output [  1:0]  cfg_rresp_o
    ,output          outport_awvalid_o
    ,output [ 31:0]  outport_awaddr_o
    ,output [  3:0]  outport_awid_o
    ,output [  7:0]  outport_awlen_o
    ,output [  1:0]  outport_awburst_o
    ,output          outport_wvalid_o
    ,output [ 31:0]  outport_wdata_o
    ,output [  3:0]  outport_wstrb_o
    ,output          outport_wlast_o
    ,output          outport_bready_o
    ,output          outport_arvalid_o
    ,output [ 31:0]  outport_araddr_o
    ,output [  3:0]  outport_arid_o
    ,output [  7:0]  outport_arlen_o
    ,output [  1:0]  outport_arburst_o
    ,output          outport_rready_o
    ,output          cfg_clk_src_ext_o
    ,output [  3:0]  cfg_clk_div_o
    ,output [  1:0]  cfg_width_o
    ,output          cfg_test_mode_o
    ,output          status_enabled_o
    ,output          status_triggered_o
    ,output          status_overflow_o
);



//-----------------------------------------------------------------
// Core
//-----------------------------------------------------------------
wire         fifo_tvalid_w;
wire [31:0]  fifo_tdata_w;
wire         fifo_tready_w;
    
wire [31:0]  buffer_base_w;
wire [31:0]  buffer_end_w;
wire         buffer_reset_w;
wire [31:0]  buffer_current_w;
wire         buffer_cont_w;
wire         buffer_wrapped_w;
wire         buffer_full_w;

logic_capture
u_core
(
     .clk_i(clk_i)
    ,.rst_i(rst_i)

    // Config
    ,.cfg_awvalid_i(cfg_awvalid_i)
    ,.cfg_awaddr_i(cfg_awaddr_i)
    ,.cfg_wvalid_i(cfg_wvalid_i)
    ,.cfg_wdata_i(cfg_wdata_i)
    ,.cfg_wstrb_i(cfg_wstrb_i)
    ,.cfg_bready_i(cfg_bready_i)
    ,.cfg_arvalid_i(cfg_arvalid_i)
    ,.cfg_araddr_i(cfg_araddr_i)
    ,.cfg_rready_i(cfg_rready_i)
    ,.cfg_awready_o(cfg_awready_o)
    ,.cfg_wready_o(cfg_wready_o)
    ,.cfg_bvalid_o(cfg_bvalid_o)
    ,.cfg_bresp_o(cfg_bresp_o)
    ,.cfg_arready_o(cfg_arready_o)
    ,.cfg_rvalid_o(cfg_rvalid_o)
    ,.cfg_rdata_o(cfg_rdata_o)
    ,.cfg_rresp_o(cfg_rresp_o)

    // Input capture
    ,.input_valid_i(input_valid_i)
    ,.input_data_i(input_data_i)

    // Stream
    ,.outport_tvalid_o(fifo_tvalid_w)
    ,.outport_tdata_o(fifo_tdata_w)
    ,.outport_tstrb_o()
    ,.outport_tdest_o()
    ,.outport_tlast_o()
    ,.outport_tready_i(fifo_tready_w)

    // Buffer Config
    ,.buffer_base_o(buffer_base_w)
    ,.buffer_end_o(buffer_end_w)
    ,.buffer_reset_o(buffer_reset_w)
    ,.buffer_cont_o(buffer_cont_w)
    ,.buffer_current_i(buffer_current_w)
    ,.buffer_wrapped_i(buffer_wrapped_w)

    // Misc
    ,.cfg_clk_src_ext_o(cfg_clk_src_ext_o)
    ,.cfg_clk_div_o(cfg_clk_div_o)
    ,.cfg_width_o(cfg_width_o)
    ,.cfg_test_mode_o(cfg_test_mode_o)

    // Status
    ,.status_enabled_o(status_enabled_o)
    ,.status_triggered_o(status_triggered_o)
    ,.status_overflow_o(status_overflow_o)
);

//-----------------------------------------------------------------
// Large block RAM based buffer
//-----------------------------------------------------------------
wire         stream_tvalid_int_w;
wire         stream_tvalid_w;
wire [31:0]  stream_tdata_w;
wire         stream_tready_w;
wire         stream_tready_int_w;
wire         fifo_space_w;

reg  [31:0]  stream_count_q;

logic_capture_mem_fifo_ram
u_buffer
(
     .clk_i(clk_i)
    ,.rst_i(rst_i)

    ,.push_i(fifo_tvalid_w)
    ,.data_in_i(fifo_tdata_w)
    ,.accept_o(fifo_tready_w)

    ,.valid_o(stream_tvalid_int_w)
    ,.data_out_o(stream_tdata_w)
    ,.pop_i(stream_tready_int_w)
);

// Delay output to allow a bursts worth of data to accumulate
reg [3:0] stream_delay_q;

always @ (posedge clk_i )
if (rst_i) 
    stream_delay_q <= 4'b0;
else if (stream_delay_q != 4'd0)
    stream_delay_q <= stream_delay_q - 4'd1;
else if (!stream_tvalid_int_w) // Empty
    stream_delay_q <= 4'd15;

assign stream_tvalid_w     = stream_tvalid_int_w && (stream_delay_q == 4'd0) && fifo_space_w;
assign stream_tready_int_w = stream_tready_w     && (stream_delay_q == 4'd0) && fifo_space_w;

always @ (posedge clk_i )
if (rst_i) 
    stream_count_q <= 32'b0;
else if ((fifo_tvalid_w && fifo_tready_w)  && !(stream_tvalid_int_w && stream_tready_int_w))
    stream_count_q <= stream_count_q + 32'd1;
else if (!(fifo_tvalid_w && fifo_tready_w) && (stream_tvalid_int_w && stream_tready_int_w))
    stream_count_q <= stream_count_q - 32'd1;

//-----------------------------------------------------------------
// AXI: Write logic
//-----------------------------------------------------------------
reg [31:0]  write_addr_q;
wire        mem_ack_w;
wire        mem_was_burst_w;

reg  [7:0]  in_burst_q;
wire [7:0]  inport_len_w;

wire [31:0] wrap_remain_w = buffer_end_w - write_addr_q;
wire        can_burst_w = (write_addr_q[4:0] == 5'd0) && (stream_count_q  >= 32'd8) && (wrap_remain_w > 32'd32);

always @ (posedge clk_i )
if (rst_i) 
    in_burst_q <= 8'b0;
else if (stream_tvalid_w && !buffer_full_w && stream_tready_w && in_burst_q != 8'd0)
    in_burst_q <= in_burst_q - 8'd1;
else if (stream_tvalid_w && !buffer_full_w && stream_tready_w)
    in_burst_q <= (inport_len_w != 8'd0) ? inport_len_w : 8'd0;

assign inport_len_w = (|in_burst_q) ? 8'd0 : 
                      (can_burst_w) ? 8'd7 : 8'd0;

logic_capture_mem_track_fifo
#(
     .WIDTH(1)
    ,.DEPTH(32)
    ,.ADDR_W(5)
)
u_fifo_burst_track
(
     .clk_i(clk_i)
    ,.rst_i(rst_i)

    ,.push_i(stream_tvalid_w && !buffer_full_w && stream_tready_w && in_burst_q == 8'd0)
    ,.data_in_i(|inport_len_w)
    ,.accept_o(fifo_space_w)

    ,.valid_o()
    ,.data_out_o(mem_was_burst_w)
    ,.pop_i(mem_ack_w)
);


logic_capture_mem_axi
u_axi
(
     .clk_i(clk_i)
    ,.rst_i(rst_i)

    ,.outport_awready_i(outport_awready_i)
    ,.outport_wready_i(outport_wready_i)
    ,.outport_bvalid_i(outport_bvalid_i)
    ,.outport_bresp_i(outport_bresp_i)
    ,.outport_arready_i(outport_arready_i)
    ,.outport_rvalid_i(outport_rvalid_i)
    ,.outport_rdata_i(outport_rdata_i)
    ,.outport_rresp_i(outport_rresp_i)
    ,.outport_awvalid_o(outport_awvalid_o)
    ,.outport_awaddr_o(outport_awaddr_o)
    ,.outport_wvalid_o(outport_wvalid_o)
    ,.outport_wdata_o(outport_wdata_o)
    ,.outport_wstrb_o(outport_wstrb_o)
    ,.outport_bready_o(outport_bready_o)
    ,.outport_arvalid_o(outport_arvalid_o)
    ,.outport_araddr_o(outport_araddr_o)
    ,.outport_rready_o(outport_rready_o)
    ,.outport_awid_o(outport_awid_o)
    ,.outport_awlen_o(outport_awlen_o)
    ,.outport_awburst_o(outport_awburst_o)
    ,.outport_wlast_o(outport_wlast_o)
    ,.outport_arid_o(outport_arid_o)
    ,.outport_arlen_o(outport_arlen_o)
    ,.outport_arburst_o(outport_arburst_o)
    ,.outport_bid_i(outport_bid_i)
    ,.outport_rid_i(outport_rid_i)
    ,.outport_rlast_i(outport_rlast_i)

    ,.inport_wr_i({4{stream_tvalid_w & ~buffer_full_w}})
    ,.inport_rd_i(1'b0)
    ,.inport_len_i(inport_len_w)
    ,.inport_addr_i(write_addr_q)
    ,.inport_write_data_i(stream_tdata_w)
    ,.inport_accept_o(stream_tready_w)
    ,.inport_ack_o(mem_ack_w)
    ,.inport_error_o()
    ,.inport_read_data_o()
);

//-----------------------------------------------------------------
// Buffer Full
//-----------------------------------------------------------------
reg buffer_full_q;

always @ (posedge clk_i )
if (rst_i) 
    buffer_full_q <= 1'b0;
else if (buffer_reset_w)
    buffer_full_q <= 1'b0;
else if (stream_tvalid_w && stream_tready_w && !buffer_cont_w && (write_addr_q == buffer_end_w))
    buffer_full_q <= 1'b1;

assign buffer_full_w = buffer_full_q;

//-----------------------------------------------------------------
// Buffer Wrapped
//-----------------------------------------------------------------
reg buffer_wrap_q;

always @ (posedge clk_i )
if (rst_i) 
    buffer_wrap_q <= 1'b0;
else if (buffer_reset_w)
    buffer_wrap_q <= 1'b0;
else if (stream_tvalid_w && stream_tready_w && buffer_cont_w && (write_addr_q == buffer_end_w))
    buffer_wrap_q <= 1'b1;

assign buffer_wrapped_w = buffer_wrap_q;

//-----------------------------------------------------------------
// Write Address
//-----------------------------------------------------------------
always @ (posedge clk_i )
if (rst_i) 
    write_addr_q <= 32'b0;
else if (buffer_reset_w)
    write_addr_q <= buffer_base_w;
else if (stream_tvalid_w && stream_tready_w && !buffer_full_w)
begin
    if (write_addr_q == buffer_end_w)
        write_addr_q <= buffer_base_w;
    else
        write_addr_q <= write_addr_q + 32'd4;
end

//-----------------------------------------------------------------
// Read pointer (based on completed writes)
//-----------------------------------------------------------------
reg [31:0] buffer_current_q;

always @ (posedge clk_i )
if (rst_i) 
    buffer_current_q <= 32'b0;
else if (buffer_reset_w)
    buffer_current_q <= buffer_base_w;
// Control word writes actually occur in IDLE...
else if (mem_ack_w && (buffer_cont_w || buffer_current_q != buffer_end_w))
begin
    if (buffer_current_q == buffer_end_w)
        buffer_current_q <= buffer_base_w;
    else
        buffer_current_q <= buffer_current_q + (mem_was_burst_w ? 32'd32 : 32'd4);
end

assign buffer_current_w = buffer_current_q;



endmodule
