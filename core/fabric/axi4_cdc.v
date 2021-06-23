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
module axi4_cdc
(
    // Inputs
     input           wr_clk_i
    ,input           wr_rst_i
    ,input           inport_awvalid_i
    ,input  [ 31:0]  inport_awaddr_i
    ,input  [  3:0]  inport_awid_i
    ,input  [  7:0]  inport_awlen_i
    ,input  [  1:0]  inport_awburst_i
    ,input           inport_wvalid_i
    ,input  [ 31:0]  inport_wdata_i
    ,input  [  3:0]  inport_wstrb_i
    ,input           inport_wlast_i
    ,input           inport_bready_i
    ,input           inport_arvalid_i
    ,input  [ 31:0]  inport_araddr_i
    ,input  [  3:0]  inport_arid_i
    ,input  [  7:0]  inport_arlen_i
    ,input  [  1:0]  inport_arburst_i
    ,input           inport_rready_i
    ,input           rd_clk_i
    ,input           rd_rst_i
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
    ,output          inport_awready_o
    ,output          inport_wready_o
    ,output          inport_bvalid_o
    ,output [  1:0]  inport_bresp_o
    ,output [  3:0]  inport_bid_o
    ,output          inport_arready_o
    ,output          inport_rvalid_o
    ,output [ 31:0]  inport_rdata_o
    ,output [  1:0]  inport_rresp_o
    ,output [  3:0]  inport_rid_o
    ,output          inport_rlast_o
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
);




//-----------------------------------------------------------------
// Write Command Request
//-----------------------------------------------------------------
wire [45:0] write_cmd_req_out_w;
wire                          write_cmd_full_w;
wire                          read_cmd_empty_w;

axi4_cdc_fifo46
u_write_cmd_req
(
    .wr_clk_i(wr_clk_i),
    .wr_rst_i(wr_rst_i),
    .wr_push_i(inport_awvalid_i),
    .wr_data_i({inport_awaddr_i, inport_awid_i, inport_awlen_i, inport_awburst_i}),
    .wr_full_o(write_cmd_full_w),

    .rd_clk_i(rd_clk_i),
    .rd_rst_i(rd_rst_i),
    .rd_empty_o(read_cmd_empty_w),
    .rd_data_o(write_cmd_req_out_w),
    .rd_pop_i(outport_awready_i)
);

assign inport_awready_o  = ~write_cmd_full_w;
assign outport_awvalid_o = ~read_cmd_empty_w;

assign {outport_awaddr_o, outport_awid_o, outport_awlen_o, outport_awburst_o} = write_cmd_req_out_w;

//-----------------------------------------------------------------
// Write Data Request
//-----------------------------------------------------------------
wire [36:0] write_data_req_out_w;
wire                           write_data_full_w;
wire                           write_data_empty_w;

axi4_cdc_fifo37
u_write_data_req
(
    .wr_clk_i(wr_clk_i),
    .wr_rst_i(wr_rst_i),
    .wr_push_i(inport_wvalid_i),
    .wr_data_i({inport_wlast_i, inport_wstrb_i, inport_wdata_i}),
    .wr_full_o(write_data_full_w),

    .rd_clk_i(rd_clk_i),
    .rd_rst_i(rd_rst_i),
    .rd_empty_o(write_data_empty_w),
    .rd_data_o(write_data_req_out_w),
    .rd_pop_i(outport_wready_i)
);

assign inport_wready_o  = ~write_data_full_w;
assign outport_wvalid_o = ~write_data_empty_w;

assign {outport_wlast_o, outport_wstrb_o, outport_wdata_o} = write_data_req_out_w;

//-----------------------------------------------------------------
// Write Response
//-----------------------------------------------------------------
wire [5:0] write_resp_out_w;
wire                       write_resp_full_w;
wire                       write_resp_empty_w;

axi4_cdc_fifo6
u_write_resp
(
    .wr_clk_i(rd_clk_i),
    .wr_rst_i(rd_rst_i),
    .wr_push_i(outport_bvalid_i),
    .wr_data_i({outport_bresp_i, outport_bid_i}),
    .wr_full_o(write_resp_full_w),

    .rd_clk_i(wr_clk_i),
    .rd_rst_i(wr_rst_i),
    .rd_empty_o(write_resp_empty_w),
    .rd_data_o(write_resp_out_w),
    .rd_pop_i(inport_bready_i)
);

assign outport_bready_o  = ~write_resp_full_w;
assign inport_bvalid_o   = ~write_resp_empty_w;

assign {inport_bresp_o, inport_bid_o} = write_resp_out_w;

//-----------------------------------------------------------------
// Read Request
//-----------------------------------------------------------------
wire [45:0] read_req_out_w;
wire                     read_req_full_w;
wire                     read_req_empty_w;

axi4_cdc_fifo46
u_read_req
(
    .wr_clk_i(wr_clk_i),
    .wr_rst_i(wr_rst_i),
    .wr_push_i(inport_arvalid_i),
    .wr_data_i({inport_araddr_i, inport_arid_i, inport_arlen_i, inport_arburst_i}),
    .wr_full_o(read_req_full_w),

    .rd_clk_i(rd_clk_i),
    .rd_rst_i(rd_rst_i),
    .rd_empty_o(read_req_empty_w),
    .rd_data_o(read_req_out_w),
    .rd_pop_i(outport_arready_i)
);

assign inport_arready_o  = ~read_req_full_w;
assign outport_arvalid_o = ~read_req_empty_w;


assign {outport_araddr_o, outport_arid_o, outport_arlen_o, outport_arburst_o} = read_req_out_w;

//-----------------------------------------------------------------
// Read Response
//-----------------------------------------------------------------
wire [38:0] read_resp_out_w;
wire                      read_resp_full_w;
wire                      read_resp_empty_w;

axi4_cdc_fifo39
u_read_resp
(
    .wr_clk_i(rd_clk_i),
    .wr_rst_i(rd_rst_i),
    .wr_push_i(outport_rvalid_i),
    .wr_data_i({outport_rdata_i, outport_rresp_i, outport_rid_i, outport_rlast_i}),
    .wr_full_o(read_resp_full_w),

    .rd_clk_i(wr_clk_i),
    .rd_rst_i(wr_rst_i),
    .rd_empty_o(read_resp_empty_w),
    .rd_data_o(read_resp_out_w),
    .rd_pop_i(inport_rready_i)
);

assign outport_rready_o = ~read_resp_full_w;
assign inport_rvalid_o  = ~read_resp_empty_w;

assign {inport_rdata_o, inport_rresp_o, inport_rid_o, inport_rlast_o} = read_resp_out_w;


endmodule
