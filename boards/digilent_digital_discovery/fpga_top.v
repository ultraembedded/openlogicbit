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
module fpga_top
(
    // Inputs
     input           ftdi_clk_i
    ,input           ftdi_rst_i
    ,input           sample_clk_i
    ,input           sample_rst_i
    ,input           mem_clk_i
    ,input           mem_rst_i
    ,input           clk_i
    ,input           rst_i
    ,input           ftdi_rxf_i
    ,input           ftdi_txe_i
    ,input  [  7:0]  ftdi_data_in_i
    ,input  [ 31:0]  input_i
    ,input           mem_awready_i
    ,input           mem_wready_i
    ,input           mem_bvalid_i
    ,input  [  1:0]  mem_bresp_i
    ,input  [  3:0]  mem_bid_i
    ,input           mem_arready_i
    ,input           mem_rvalid_i
    ,input  [ 31:0]  mem_rdata_i
    ,input  [  1:0]  mem_rresp_i
    ,input  [  3:0]  mem_rid_i
    ,input           mem_rlast_i

    // Outputs
    ,output          ftdi_siwua_o
    ,output          ftdi_wrn_o
    ,output          ftdi_rdn_o
    ,output          ftdi_oen_o
    ,output [  7:0]  ftdi_data_out_o
    ,output [  7:0]  gpio_outputs_o
    ,output          status_enabled_o
    ,output          status_triggered_o
    ,output          status_overflow_o
    ,output          cfg_clk_src_ext_o
    ,output          mem_awvalid_o
    ,output [ 31:0]  mem_awaddr_o
    ,output [  3:0]  mem_awid_o
    ,output [  7:0]  mem_awlen_o
    ,output [  1:0]  mem_awburst_o
    ,output          mem_wvalid_o
    ,output [ 31:0]  mem_wdata_o
    ,output [  3:0]  mem_wstrb_o
    ,output          mem_wlast_o
    ,output          mem_bready_o
    ,output          mem_arvalid_o
    ,output [ 31:0]  mem_araddr_o
    ,output [  3:0]  mem_arid_o
    ,output [  7:0]  mem_arlen_o
    ,output [  1:0]  mem_arburst_o
    ,output          mem_rready_o
);

wire  [  1:0]  axi_capture_rresp_w;
wire           axi_retime_arvalid_w;
wire           axi_capture_awvalid_w;
wire           axi_capture_arready_w;
wire  [  1:0]  axi_capture_bresp_w;
wire  [ 31:0]  axi_cfg_wdata_w;
wire           axi_ftdi_rready_w;
wire           axi_ftdi_bvalid_w;
wire  [  1:0]  axi_rresp_w;
wire  [  3:0]  axi_retime_wstrb_w;
wire  [  1:0]  axi_cdc_rresp_w;
wire           axi_capture_bvalid_w;
wire  [  1:0]  axi_cdc_arburst_w;
wire  [  3:0]  axi_retime_arid_w;
wire           axi_ftdi_rlast_w;
wire           axi_capture_rready_w;
wire  [  7:0]  axi_ftdi_arlen_w;
wire  [  1:0]  axi_capture_retimed_arburst_w;
wire  [  1:0]  axi_ftdi_rresp_w;
wire           axi_capture_retimed_rlast_w;
wire           axi_awvalid_w;
wire  [  3:0]  axi_capture_bid_w;
wire  [  1:0]  axi_arburst_w;
wire  [  3:0]  axi_cdc_bid_w;
wire  [ 31:0]  axi_retime_wdata_w;
wire  [ 31:0]  axi_capture_araddr_w;
wire           axi_awready_w;
wire  [ 31:0]  axi_capture_wdata_w;
wire  [  1:0]  axi_cdc_awburst_w;
wire  [  7:0]  axi_capture_retimed_awlen_w;
wire           axi_cfg_wvalid_w;
wire  [ 31:0]  axi_cfg_rdata_w;
wire           axi_rready_w;
wire  [  3:0]  axi_cfg_wstrb_w;
wire  [  1:0]  axi_capture_retimed_rresp_w;
wire  [  3:0]  axi_capture_retimed_arid_w;
wire           axi_retime_wlast_w;
wire  [ 31:0]  axi_capture_retimed_araddr_w;
wire  [  3:0]  axi_capture_retimed_wstrb_w;
wire           axi_ftdi_bready_w;
wire           axi_ftdi_wlast_w;
wire  [  3:0]  axi_capture_arid_w;
wire  [ 31:0]  axi_ftdi_awaddr_w;
wire  [  3:0]  axi_cdc_rid_w;
wire           axi_cdc_rlast_w;
wire  [  1:0]  axi_retime_arburst_w;
wire  [ 31:0]  axi_retime_rdata_w;
wire           axi_ftdi_rvalid_w;
wire           axi_rlast_w;
wire           axi_cfg_bready_w;
wire           axi_cfg_awready_w;
wire  [  3:0]  axi_bid_w;
wire  [  7:0]  axi_cdc_arlen_w;
wire  [ 31:0]  axi_ftdi_araddr_w;
wire  [  3:0]  axi_arid_w;
wire           axi_retime_bvalid_w;
wire           axi_ftdi_awready_w;
wire           axi_cfg_awvalid_w;
wire  [  3:0]  axi_capture_awid_w;
wire  [ 31:0]  axi_ftdi_rdata_w;
wire           axi_capture_retimed_arvalid_w;
wire  [  1:0]  axi_awburst_w;
wire  [  1:0]  cfg_width_w;
wire           axi_retime_rlast_w;
wire           axi_cfg_wready_w;
wire  [  3:0]  axi_cdc_wstrb_w;
wire  [ 31:0]  axi_cfg_araddr_w;
wire  [ 31:0]  axi_rdata_w;
wire  [  1:0]  axi_ftdi_awburst_w;
wire           axi_arready_w;
wire           axi_ftdi_awvalid_w;
wire  [ 31:0]  axi_araddr_w;
wire           axi_cdc_bready_w;
wire  [  7:0]  axi_ftdi_awlen_w;
wire  [  1:0]  axi_ftdi_arburst_w;
wire  [  7:0]  axi_arlen_w;
wire           axi_capture_arvalid_w;
wire           axi_capture_retimed_rvalid_w;
wire           axi_retime_arready_w;
wire  [  7:0]  axi_retime_awlen_w;
wire  [  1:0]  axi_retime_rresp_w;
wire  [  3:0]  axi_retime_bid_w;
wire           axi_cdc_bvalid_w;
wire  [  3:0]  axi_retime_rid_w;
wire           axi_ftdi_arvalid_w;
wire           axi_cdc_arready_w;
wire  [ 31:0]  input_data_w;
wire  [ 31:0]  axi_wdata_w;
wire  [ 31:0]  axi_cfg_awaddr_w;
wire           axi_cdc_awvalid_w;
wire           axi_capture_wvalid_w;
wire           cfg_test_mode_w;
wire           axi_wlast_w;
wire           axi_retime_wready_w;
wire  [ 31:0]  axi_capture_retimed_wdata_w;
wire  [ 31:0]  axi_cdc_araddr_w;
wire  [ 31:0]  axi_capture_rdata_w;
wire           axi_cfg_arvalid_w;
wire  [  3:0]  axi_cdc_awid_w;
wire           axi_retime_bready_w;
wire  [ 31:0]  axi_cdc_wdata_w;
wire  [  1:0]  axi_retime_awburst_w;
wire           axi_capture_retimed_bvalid_w;
wire  [  7:0]  axi_cdc_awlen_w;
wire  [ 31:0]  axi_cdc_awaddr_w;
wire           axi_capture_retimed_rready_w;
wire  [  1:0]  axi_bresp_w;
wire           input_valid_w;
wire           axi_wvalid_w;
wire           axi_capture_retimed_awready_w;
wire           axi_cdc_arvalid_w;
wire  [  3:0]  axi_ftdi_bid_w;
wire           axi_retime_wvalid_w;
wire           axi_capture_retimed_arready_w;
wire           axi_retime_rready_w;
wire  [  3:0]  axi_wstrb_w;
wire  [  1:0]  axi_ftdi_bresp_w;
wire           axi_ftdi_arready_w;
wire  [  1:0]  axi_cdc_bresp_w;
wire           axi_retime_awvalid_w;
wire           axi_retime_rvalid_w;
wire           axi_capture_rlast_w;
wire  [  1:0]  axi_capture_awburst_w;
wire  [  1:0]  axi_capture_arburst_w;
wire  [  1:0]  axi_capture_retimed_bresp_w;
wire  [  1:0]  axi_capture_retimed_awburst_w;
wire           axi_ftdi_wvalid_w;
wire  [ 31:0]  axi_awaddr_w;
wire  [ 31:0]  axi_ftdi_wdata_w;
wire  [  3:0]  axi_capture_rid_w;
wire  [  3:0]  axi_ftdi_rid_w;
wire  [ 31:0]  axi_retime_araddr_w;
wire           axi_capture_wlast_w;
wire  [ 31:0]  axi_cdc_rdata_w;
wire  [  3:0]  cfg_clk_div_w;
wire  [  7:0]  axi_capture_arlen_w;
wire  [  1:0]  axi_cfg_rresp_w;
wire           axi_capture_retimed_awvalid_w;
wire           axi_capture_bready_w;
wire           axi_cdc_wvalid_w;
wire  [  3:0]  axi_capture_wstrb_w;
wire           axi_cfg_rvalid_w;
wire           axi_cdc_wlast_w;
wire           axi_cfg_arready_w;
wire           axi_cdc_rready_w;
wire           axi_ftdi_wready_w;
wire  [ 31:0]  axi_retime_awaddr_w;
wire  [ 31:0]  axi_capture_retimed_awaddr_w;
wire  [  7:0]  axi_awlen_w;
wire  [  1:0]  axi_retime_bresp_w;
wire           axi_cfg_bvalid_w;
wire  [  7:0]  axi_retime_arlen_w;
wire  [ 31:0]  axi_capture_awaddr_w;
wire           axi_capture_retimed_wready_w;
wire           axi_cdc_awready_w;
wire           axi_capture_awready_w;
wire  [  7:0]  axi_capture_awlen_w;
wire           axi_cfg_rready_w;
wire  [  3:0]  axi_ftdi_arid_w;
wire  [  3:0]  axi_capture_retimed_awid_w;
wire  [  3:0]  axi_retime_awid_w;
wire           axi_cdc_wready_w;
wire           axi_wready_w;
wire           axi_capture_wready_w;
wire           axi_cdc_rvalid_w;
wire  [  3:0]  axi_capture_retimed_rid_w;
wire           axi_capture_retimed_bready_w;
wire  [  7:0]  axi_capture_retimed_arlen_w;
wire  [  3:0]  axi_cdc_arid_w;
wire           axi_rvalid_w;
wire  [  3:0]  axi_awid_w;
wire  [  3:0]  axi_capture_retimed_bid_w;
wire  [ 31:0]  axi_capture_retimed_rdata_w;
wire  [  3:0]  axi_rid_w;
wire           axi_arvalid_w;
wire           axi_bvalid_w;
wire           axi_bready_w;
wire           axi_retime_awready_w;
wire           axi_capture_retimed_wvalid_w;
wire  [  3:0]  axi_ftdi_awid_w;
wire  [  1:0]  axi_cfg_bresp_w;
wire           axi_capture_rvalid_w;
wire  [  3:0]  axi_ftdi_wstrb_w;
wire           axi_capture_retimed_wlast_w;


axi4_cdc
u_cdc
(
    // Inputs
     .wr_clk_i(ftdi_clk_i)
    ,.wr_rst_i(ftdi_rst_i)
    ,.inport_awvalid_i(axi_cdc_awvalid_w)
    ,.inport_awaddr_i(axi_cdc_awaddr_w)
    ,.inport_awid_i(axi_cdc_awid_w)
    ,.inport_awlen_i(axi_cdc_awlen_w)
    ,.inport_awburst_i(axi_cdc_awburst_w)
    ,.inport_wvalid_i(axi_cdc_wvalid_w)
    ,.inport_wdata_i(axi_cdc_wdata_w)
    ,.inport_wstrb_i(axi_cdc_wstrb_w)
    ,.inport_wlast_i(axi_cdc_wlast_w)
    ,.inport_bready_i(axi_cdc_bready_w)
    ,.inport_arvalid_i(axi_cdc_arvalid_w)
    ,.inport_araddr_i(axi_cdc_araddr_w)
    ,.inport_arid_i(axi_cdc_arid_w)
    ,.inport_arlen_i(axi_cdc_arlen_w)
    ,.inport_arburst_i(axi_cdc_arburst_w)
    ,.inport_rready_i(axi_cdc_rready_w)
    ,.rd_clk_i(clk_i)
    ,.rd_rst_i(rst_i)
    ,.outport_awready_i(axi_awready_w)
    ,.outport_wready_i(axi_wready_w)
    ,.outport_bvalid_i(axi_bvalid_w)
    ,.outport_bresp_i(axi_bresp_w)
    ,.outport_bid_i(axi_bid_w)
    ,.outport_arready_i(axi_arready_w)
    ,.outport_rvalid_i(axi_rvalid_w)
    ,.outport_rdata_i(axi_rdata_w)
    ,.outport_rresp_i(axi_rresp_w)
    ,.outport_rid_i(axi_rid_w)
    ,.outport_rlast_i(axi_rlast_w)

    // Outputs
    ,.inport_awready_o(axi_cdc_awready_w)
    ,.inport_wready_o(axi_cdc_wready_w)
    ,.inport_bvalid_o(axi_cdc_bvalid_w)
    ,.inport_bresp_o(axi_cdc_bresp_w)
    ,.inport_bid_o(axi_cdc_bid_w)
    ,.inport_arready_o(axi_cdc_arready_w)
    ,.inport_rvalid_o(axi_cdc_rvalid_w)
    ,.inport_rdata_o(axi_cdc_rdata_w)
    ,.inport_rresp_o(axi_cdc_rresp_w)
    ,.inport_rid_o(axi_cdc_rid_w)
    ,.inport_rlast_o(axi_cdc_rlast_w)
    ,.outport_awvalid_o(axi_awvalid_w)
    ,.outport_awaddr_o(axi_awaddr_w)
    ,.outport_awid_o(axi_awid_w)
    ,.outport_awlen_o(axi_awlen_w)
    ,.outport_awburst_o(axi_awburst_w)
    ,.outport_wvalid_o(axi_wvalid_w)
    ,.outport_wdata_o(axi_wdata_w)
    ,.outport_wstrb_o(axi_wstrb_w)
    ,.outport_wlast_o(axi_wlast_w)
    ,.outport_bready_o(axi_bready_w)
    ,.outport_arvalid_o(axi_arvalid_w)
    ,.outport_araddr_o(axi_araddr_w)
    ,.outport_arid_o(axi_arid_w)
    ,.outport_arlen_o(axi_arlen_w)
    ,.outport_arburst_o(axi_arburst_w)
    ,.outport_rready_o(axi_rready_w)
);


capture_rle
u_input
(
    // Inputs
     .clk_i(clk_i)
    ,.rst_i(rst_i)
    ,.input_clk_i(sample_clk_i)
    ,.input_rst_i(sample_rst_i)
    ,.input_i(input_i)
    ,.cfg_clk_div_i(cfg_clk_div_w)
    ,.cfg_width_i(cfg_width_w)
    ,.cfg_test_mode_i(cfg_test_mode_w)

    // Outputs
    ,.valid_o(input_valid_w)
    ,.data_o(input_data_w)
);


axi4_lite_tap
u_dist
(
    // Inputs
     .clk_i(clk_i)
    ,.rst_i(rst_i)
    ,.inport_awvalid_i(axi_awvalid_w)
    ,.inport_awaddr_i(axi_awaddr_w)
    ,.inport_awid_i(axi_awid_w)
    ,.inport_awlen_i(axi_awlen_w)
    ,.inport_awburst_i(axi_awburst_w)
    ,.inport_wvalid_i(axi_wvalid_w)
    ,.inport_wdata_i(axi_wdata_w)
    ,.inport_wstrb_i(axi_wstrb_w)
    ,.inport_wlast_i(axi_wlast_w)
    ,.inport_bready_i(axi_bready_w)
    ,.inport_arvalid_i(axi_arvalid_w)
    ,.inport_araddr_i(axi_araddr_w)
    ,.inport_arid_i(axi_arid_w)
    ,.inport_arlen_i(axi_arlen_w)
    ,.inport_arburst_i(axi_arburst_w)
    ,.inport_rready_i(axi_rready_w)
    ,.outport_awready_i(axi_ftdi_awready_w)
    ,.outport_wready_i(axi_ftdi_wready_w)
    ,.outport_bvalid_i(axi_ftdi_bvalid_w)
    ,.outport_bresp_i(axi_ftdi_bresp_w)
    ,.outport_bid_i(axi_ftdi_bid_w)
    ,.outport_arready_i(axi_ftdi_arready_w)
    ,.outport_rvalid_i(axi_ftdi_rvalid_w)
    ,.outport_rdata_i(axi_ftdi_rdata_w)
    ,.outport_rresp_i(axi_ftdi_rresp_w)
    ,.outport_rid_i(axi_ftdi_rid_w)
    ,.outport_rlast_i(axi_ftdi_rlast_w)
    ,.outport_peripheral0_awready_i(axi_cfg_awready_w)
    ,.outport_peripheral0_wready_i(axi_cfg_wready_w)
    ,.outport_peripheral0_bvalid_i(axi_cfg_bvalid_w)
    ,.outport_peripheral0_bresp_i(axi_cfg_bresp_w)
    ,.outport_peripheral0_arready_i(axi_cfg_arready_w)
    ,.outport_peripheral0_rvalid_i(axi_cfg_rvalid_w)
    ,.outport_peripheral0_rdata_i(axi_cfg_rdata_w)
    ,.outport_peripheral0_rresp_i(axi_cfg_rresp_w)

    // Outputs
    ,.inport_awready_o(axi_awready_w)
    ,.inport_wready_o(axi_wready_w)
    ,.inport_bvalid_o(axi_bvalid_w)
    ,.inport_bresp_o(axi_bresp_w)
    ,.inport_bid_o(axi_bid_w)
    ,.inport_arready_o(axi_arready_w)
    ,.inport_rvalid_o(axi_rvalid_w)
    ,.inport_rdata_o(axi_rdata_w)
    ,.inport_rresp_o(axi_rresp_w)
    ,.inport_rid_o(axi_rid_w)
    ,.inport_rlast_o(axi_rlast_w)
    ,.outport_awvalid_o(axi_ftdi_awvalid_w)
    ,.outport_awaddr_o(axi_ftdi_awaddr_w)
    ,.outport_awid_o(axi_ftdi_awid_w)
    ,.outport_awlen_o(axi_ftdi_awlen_w)
    ,.outport_awburst_o(axi_ftdi_awburst_w)
    ,.outport_wvalid_o(axi_ftdi_wvalid_w)
    ,.outport_wdata_o(axi_ftdi_wdata_w)
    ,.outport_wstrb_o(axi_ftdi_wstrb_w)
    ,.outport_wlast_o(axi_ftdi_wlast_w)
    ,.outport_bready_o(axi_ftdi_bready_w)
    ,.outport_arvalid_o(axi_ftdi_arvalid_w)
    ,.outport_araddr_o(axi_ftdi_araddr_w)
    ,.outport_arid_o(axi_ftdi_arid_w)
    ,.outport_arlen_o(axi_ftdi_arlen_w)
    ,.outport_arburst_o(axi_ftdi_arburst_w)
    ,.outport_rready_o(axi_ftdi_rready_w)
    ,.outport_peripheral0_awvalid_o(axi_cfg_awvalid_w)
    ,.outport_peripheral0_awaddr_o(axi_cfg_awaddr_w)
    ,.outport_peripheral0_wvalid_o(axi_cfg_wvalid_w)
    ,.outport_peripheral0_wdata_o(axi_cfg_wdata_w)
    ,.outport_peripheral0_wstrb_o(axi_cfg_wstrb_w)
    ,.outport_peripheral0_bready_o(axi_cfg_bready_w)
    ,.outport_peripheral0_arvalid_o(axi_cfg_arvalid_w)
    ,.outport_peripheral0_araddr_o(axi_cfg_araddr_w)
    ,.outport_peripheral0_rready_o(axi_cfg_rready_w)
);


ft245_axi
#(
     .AXI_ID(8)
    ,.RETIME_AXI(1)
)
u_dbg
(
    // Inputs
     .clk_i(ftdi_clk_i)
    ,.rst_i(ftdi_rst_i)
    ,.ftdi_rxf_i(ftdi_rxf_i)
    ,.ftdi_txe_i(ftdi_txe_i)
    ,.ftdi_data_in_i(ftdi_data_in_i)
    ,.outport_awready_i(axi_cdc_awready_w)
    ,.outport_wready_i(axi_cdc_wready_w)
    ,.outport_bvalid_i(axi_cdc_bvalid_w)
    ,.outport_bresp_i(axi_cdc_bresp_w)
    ,.outport_bid_i(axi_cdc_bid_w)
    ,.outport_arready_i(axi_cdc_arready_w)
    ,.outport_rvalid_i(axi_cdc_rvalid_w)
    ,.outport_rdata_i(axi_cdc_rdata_w)
    ,.outport_rresp_i(axi_cdc_rresp_w)
    ,.outport_rid_i(axi_cdc_rid_w)
    ,.outport_rlast_i(axi_cdc_rlast_w)

    // Outputs
    ,.ftdi_siwua_o(ftdi_siwua_o)
    ,.ftdi_wrn_o(ftdi_wrn_o)
    ,.ftdi_rdn_o(ftdi_rdn_o)
    ,.ftdi_oen_o(ftdi_oen_o)
    ,.ftdi_data_out_o(ftdi_data_out_o)
    ,.outport_awvalid_o(axi_cdc_awvalid_w)
    ,.outport_awaddr_o(axi_cdc_awaddr_w)
    ,.outport_awid_o(axi_cdc_awid_w)
    ,.outport_awlen_o(axi_cdc_awlen_w)
    ,.outport_awburst_o(axi_cdc_awburst_w)
    ,.outport_wvalid_o(axi_cdc_wvalid_w)
    ,.outport_wdata_o(axi_cdc_wdata_w)
    ,.outport_wstrb_o(axi_cdc_wstrb_w)
    ,.outport_wlast_o(axi_cdc_wlast_w)
    ,.outport_bready_o(axi_cdc_bready_w)
    ,.outport_arvalid_o(axi_cdc_arvalid_w)
    ,.outport_araddr_o(axi_cdc_araddr_w)
    ,.outport_arid_o(axi_cdc_arid_w)
    ,.outport_arlen_o(axi_cdc_arlen_w)
    ,.outport_arburst_o(axi_cdc_arburst_w)
    ,.outport_rready_o(axi_cdc_rready_w)
    ,.gpio_outputs_o(gpio_outputs_o)
);


axi4_cdc
u_cdc_mem
(
    // Inputs
     .wr_clk_i(clk_i)
    ,.wr_rst_i(rst_i)
    ,.inport_awvalid_i(axi_retime_awvalid_w)
    ,.inport_awaddr_i(axi_retime_awaddr_w)
    ,.inport_awid_i(axi_retime_awid_w)
    ,.inport_awlen_i(axi_retime_awlen_w)
    ,.inport_awburst_i(axi_retime_awburst_w)
    ,.inport_wvalid_i(axi_retime_wvalid_w)
    ,.inport_wdata_i(axi_retime_wdata_w)
    ,.inport_wstrb_i(axi_retime_wstrb_w)
    ,.inport_wlast_i(axi_retime_wlast_w)
    ,.inport_bready_i(axi_retime_bready_w)
    ,.inport_arvalid_i(axi_retime_arvalid_w)
    ,.inport_araddr_i(axi_retime_araddr_w)
    ,.inport_arid_i(axi_retime_arid_w)
    ,.inport_arlen_i(axi_retime_arlen_w)
    ,.inport_arburst_i(axi_retime_arburst_w)
    ,.inport_rready_i(axi_retime_rready_w)
    ,.rd_clk_i(mem_clk_i)
    ,.rd_rst_i(mem_rst_i)
    ,.outport_awready_i(mem_awready_i)
    ,.outport_wready_i(mem_wready_i)
    ,.outport_bvalid_i(mem_bvalid_i)
    ,.outport_bresp_i(mem_bresp_i)
    ,.outport_bid_i(mem_bid_i)
    ,.outport_arready_i(mem_arready_i)
    ,.outport_rvalid_i(mem_rvalid_i)
    ,.outport_rdata_i(mem_rdata_i)
    ,.outport_rresp_i(mem_rresp_i)
    ,.outport_rid_i(mem_rid_i)
    ,.outport_rlast_i(mem_rlast_i)

    // Outputs
    ,.inport_awready_o(axi_retime_awready_w)
    ,.inport_wready_o(axi_retime_wready_w)
    ,.inport_bvalid_o(axi_retime_bvalid_w)
    ,.inport_bresp_o(axi_retime_bresp_w)
    ,.inport_bid_o(axi_retime_bid_w)
    ,.inport_arready_o(axi_retime_arready_w)
    ,.inport_rvalid_o(axi_retime_rvalid_w)
    ,.inport_rdata_o(axi_retime_rdata_w)
    ,.inport_rresp_o(axi_retime_rresp_w)
    ,.inport_rid_o(axi_retime_rid_w)
    ,.inport_rlast_o(axi_retime_rlast_w)
    ,.outport_awvalid_o(mem_awvalid_o)
    ,.outport_awaddr_o(mem_awaddr_o)
    ,.outport_awid_o(mem_awid_o)
    ,.outport_awlen_o(mem_awlen_o)
    ,.outport_awburst_o(mem_awburst_o)
    ,.outport_wvalid_o(mem_wvalid_o)
    ,.outport_wdata_o(mem_wdata_o)
    ,.outport_wstrb_o(mem_wstrb_o)
    ,.outport_wlast_o(mem_wlast_o)
    ,.outport_bready_o(mem_bready_o)
    ,.outport_arvalid_o(mem_arvalid_o)
    ,.outport_araddr_o(mem_araddr_o)
    ,.outport_arid_o(mem_arid_o)
    ,.outport_arlen_o(mem_arlen_o)
    ,.outport_arburst_o(mem_arburst_o)
    ,.outport_rready_o(mem_rready_o)
);


axi4_arb
u_arb
(
    // Inputs
     .clk_i(clk_i)
    ,.rst_i(rst_i)
    ,.inport0_awvalid_i(axi_capture_retimed_awvalid_w)
    ,.inport0_awaddr_i(axi_capture_retimed_awaddr_w)
    ,.inport0_awid_i(axi_capture_retimed_awid_w)
    ,.inport0_awlen_i(axi_capture_retimed_awlen_w)
    ,.inport0_awburst_i(axi_capture_retimed_awburst_w)
    ,.inport0_wvalid_i(axi_capture_retimed_wvalid_w)
    ,.inport0_wdata_i(axi_capture_retimed_wdata_w)
    ,.inport0_wstrb_i(axi_capture_retimed_wstrb_w)
    ,.inport0_wlast_i(axi_capture_retimed_wlast_w)
    ,.inport0_bready_i(axi_capture_retimed_bready_w)
    ,.inport0_arvalid_i(axi_capture_retimed_arvalid_w)
    ,.inport0_araddr_i(axi_capture_retimed_araddr_w)
    ,.inport0_arid_i(axi_capture_retimed_arid_w)
    ,.inport0_arlen_i(axi_capture_retimed_arlen_w)
    ,.inport0_arburst_i(axi_capture_retimed_arburst_w)
    ,.inport0_rready_i(axi_capture_retimed_rready_w)
    ,.inport1_awvalid_i(axi_ftdi_awvalid_w)
    ,.inport1_awaddr_i(axi_ftdi_awaddr_w)
    ,.inport1_awid_i(axi_ftdi_awid_w)
    ,.inport1_awlen_i(axi_ftdi_awlen_w)
    ,.inport1_awburst_i(axi_ftdi_awburst_w)
    ,.inport1_wvalid_i(axi_ftdi_wvalid_w)
    ,.inport1_wdata_i(axi_ftdi_wdata_w)
    ,.inport1_wstrb_i(axi_ftdi_wstrb_w)
    ,.inport1_wlast_i(axi_ftdi_wlast_w)
    ,.inport1_bready_i(axi_ftdi_bready_w)
    ,.inport1_arvalid_i(axi_ftdi_arvalid_w)
    ,.inport1_araddr_i(axi_ftdi_araddr_w)
    ,.inport1_arid_i(axi_ftdi_arid_w)
    ,.inport1_arlen_i(axi_ftdi_arlen_w)
    ,.inport1_arburst_i(axi_ftdi_arburst_w)
    ,.inport1_rready_i(axi_ftdi_rready_w)
    ,.outport_awready_i(axi_retime_awready_w)
    ,.outport_wready_i(axi_retime_wready_w)
    ,.outport_bvalid_i(axi_retime_bvalid_w)
    ,.outport_bresp_i(axi_retime_bresp_w)
    ,.outport_bid_i(axi_retime_bid_w)
    ,.outport_arready_i(axi_retime_arready_w)
    ,.outport_rvalid_i(axi_retime_rvalid_w)
    ,.outport_rdata_i(axi_retime_rdata_w)
    ,.outport_rresp_i(axi_retime_rresp_w)
    ,.outport_rid_i(axi_retime_rid_w)
    ,.outport_rlast_i(axi_retime_rlast_w)

    // Outputs
    ,.inport0_awready_o(axi_capture_retimed_awready_w)
    ,.inport0_wready_o(axi_capture_retimed_wready_w)
    ,.inport0_bvalid_o(axi_capture_retimed_bvalid_w)
    ,.inport0_bresp_o(axi_capture_retimed_bresp_w)
    ,.inport0_bid_o(axi_capture_retimed_bid_w)
    ,.inport0_arready_o(axi_capture_retimed_arready_w)
    ,.inport0_rvalid_o(axi_capture_retimed_rvalid_w)
    ,.inport0_rdata_o(axi_capture_retimed_rdata_w)
    ,.inport0_rresp_o(axi_capture_retimed_rresp_w)
    ,.inport0_rid_o(axi_capture_retimed_rid_w)
    ,.inport0_rlast_o(axi_capture_retimed_rlast_w)
    ,.inport1_awready_o(axi_ftdi_awready_w)
    ,.inport1_wready_o(axi_ftdi_wready_w)
    ,.inport1_bvalid_o(axi_ftdi_bvalid_w)
    ,.inport1_bresp_o(axi_ftdi_bresp_w)
    ,.inport1_bid_o(axi_ftdi_bid_w)
    ,.inport1_arready_o(axi_ftdi_arready_w)
    ,.inport1_rvalid_o(axi_ftdi_rvalid_w)
    ,.inport1_rdata_o(axi_ftdi_rdata_w)
    ,.inport1_rresp_o(axi_ftdi_rresp_w)
    ,.inport1_rid_o(axi_ftdi_rid_w)
    ,.inport1_rlast_o(axi_ftdi_rlast_w)
    ,.outport_awvalid_o(axi_retime_awvalid_w)
    ,.outport_awaddr_o(axi_retime_awaddr_w)
    ,.outport_awid_o(axi_retime_awid_w)
    ,.outport_awlen_o(axi_retime_awlen_w)
    ,.outport_awburst_o(axi_retime_awburst_w)
    ,.outport_wvalid_o(axi_retime_wvalid_w)
    ,.outport_wdata_o(axi_retime_wdata_w)
    ,.outport_wstrb_o(axi_retime_wstrb_w)
    ,.outport_wlast_o(axi_retime_wlast_w)
    ,.outport_bready_o(axi_retime_bready_w)
    ,.outport_arvalid_o(axi_retime_arvalid_w)
    ,.outport_araddr_o(axi_retime_araddr_w)
    ,.outport_arid_o(axi_retime_arid_w)
    ,.outport_arlen_o(axi_retime_arlen_w)
    ,.outport_arburst_o(axi_retime_arburst_w)
    ,.outport_rready_o(axi_retime_rready_w)
);


logic_capture_mem
u_capture
(
    // Inputs
     .clk_i(clk_i)
    ,.rst_i(rst_i)
    ,.cfg_awvalid_i(axi_cfg_awvalid_w)
    ,.cfg_awaddr_i(axi_cfg_awaddr_w)
    ,.cfg_wvalid_i(axi_cfg_wvalid_w)
    ,.cfg_wdata_i(axi_cfg_wdata_w)
    ,.cfg_wstrb_i(axi_cfg_wstrb_w)
    ,.cfg_bready_i(axi_cfg_bready_w)
    ,.cfg_arvalid_i(axi_cfg_arvalid_w)
    ,.cfg_araddr_i(axi_cfg_araddr_w)
    ,.cfg_rready_i(axi_cfg_rready_w)
    ,.input_valid_i(input_valid_w)
    ,.input_data_i(input_data_w)
    ,.outport_awready_i(axi_capture_awready_w)
    ,.outport_wready_i(axi_capture_wready_w)
    ,.outport_bvalid_i(axi_capture_bvalid_w)
    ,.outport_bresp_i(axi_capture_bresp_w)
    ,.outport_bid_i(axi_capture_bid_w)
    ,.outport_arready_i(axi_capture_arready_w)
    ,.outport_rvalid_i(axi_capture_rvalid_w)
    ,.outport_rdata_i(axi_capture_rdata_w)
    ,.outport_rresp_i(axi_capture_rresp_w)
    ,.outport_rid_i(axi_capture_rid_w)
    ,.outport_rlast_i(axi_capture_rlast_w)

    // Outputs
    ,.cfg_awready_o(axi_cfg_awready_w)
    ,.cfg_wready_o(axi_cfg_wready_w)
    ,.cfg_bvalid_o(axi_cfg_bvalid_w)
    ,.cfg_bresp_o(axi_cfg_bresp_w)
    ,.cfg_arready_o(axi_cfg_arready_w)
    ,.cfg_rvalid_o(axi_cfg_rvalid_w)
    ,.cfg_rdata_o(axi_cfg_rdata_w)
    ,.cfg_rresp_o(axi_cfg_rresp_w)
    ,.outport_awvalid_o(axi_capture_awvalid_w)
    ,.outport_awaddr_o(axi_capture_awaddr_w)
    ,.outport_awid_o(axi_capture_awid_w)
    ,.outport_awlen_o(axi_capture_awlen_w)
    ,.outport_awburst_o(axi_capture_awburst_w)
    ,.outport_wvalid_o(axi_capture_wvalid_w)
    ,.outport_wdata_o(axi_capture_wdata_w)
    ,.outport_wstrb_o(axi_capture_wstrb_w)
    ,.outport_wlast_o(axi_capture_wlast_w)
    ,.outport_bready_o(axi_capture_bready_w)
    ,.outport_arvalid_o(axi_capture_arvalid_w)
    ,.outport_araddr_o(axi_capture_araddr_w)
    ,.outport_arid_o(axi_capture_arid_w)
    ,.outport_arlen_o(axi_capture_arlen_w)
    ,.outport_arburst_o(axi_capture_arburst_w)
    ,.outport_rready_o(axi_capture_rready_w)
    ,.cfg_clk_src_ext_o(cfg_clk_src_ext_o)
    ,.cfg_clk_div_o(cfg_clk_div_w)
    ,.cfg_width_o(cfg_width_w)
    ,.cfg_test_mode_o(cfg_test_mode_w)
    ,.status_enabled_o(status_enabled_o)
    ,.status_triggered_o(status_triggered_o)
    ,.status_overflow_o(status_overflow_o)
);


axi4_retime
#(
     .AXI4_RETIME_RD_RESP(1)
    ,.AXI4_RETIME_WR_RESP(1)
    ,.AXI4_RETIME_RD_REQ(1)
    ,.AXI4_RETIME_WR_REQ(1)
)
u_retime_cap
(
    // Inputs
     .clk_i(clk_i)
    ,.rst_i(rst_i)
    ,.inport_awvalid_i(axi_capture_awvalid_w)
    ,.inport_awaddr_i(axi_capture_awaddr_w)
    ,.inport_awid_i(axi_capture_awid_w)
    ,.inport_awlen_i(axi_capture_awlen_w)
    ,.inport_awburst_i(axi_capture_awburst_w)
    ,.inport_wvalid_i(axi_capture_wvalid_w)
    ,.inport_wdata_i(axi_capture_wdata_w)
    ,.inport_wstrb_i(axi_capture_wstrb_w)
    ,.inport_wlast_i(axi_capture_wlast_w)
    ,.inport_bready_i(axi_capture_bready_w)
    ,.inport_arvalid_i(axi_capture_arvalid_w)
    ,.inport_araddr_i(axi_capture_araddr_w)
    ,.inport_arid_i(axi_capture_arid_w)
    ,.inport_arlen_i(axi_capture_arlen_w)
    ,.inport_arburst_i(axi_capture_arburst_w)
    ,.inport_rready_i(axi_capture_rready_w)
    ,.outport_awready_i(axi_capture_retimed_awready_w)
    ,.outport_wready_i(axi_capture_retimed_wready_w)
    ,.outport_bvalid_i(axi_capture_retimed_bvalid_w)
    ,.outport_bresp_i(axi_capture_retimed_bresp_w)
    ,.outport_bid_i(axi_capture_retimed_bid_w)
    ,.outport_arready_i(axi_capture_retimed_arready_w)
    ,.outport_rvalid_i(axi_capture_retimed_rvalid_w)
    ,.outport_rdata_i(axi_capture_retimed_rdata_w)
    ,.outport_rresp_i(axi_capture_retimed_rresp_w)
    ,.outport_rid_i(axi_capture_retimed_rid_w)
    ,.outport_rlast_i(axi_capture_retimed_rlast_w)

    // Outputs
    ,.inport_awready_o(axi_capture_awready_w)
    ,.inport_wready_o(axi_capture_wready_w)
    ,.inport_bvalid_o(axi_capture_bvalid_w)
    ,.inport_bresp_o(axi_capture_bresp_w)
    ,.inport_bid_o(axi_capture_bid_w)
    ,.inport_arready_o(axi_capture_arready_w)
    ,.inport_rvalid_o(axi_capture_rvalid_w)
    ,.inport_rdata_o(axi_capture_rdata_w)
    ,.inport_rresp_o(axi_capture_rresp_w)
    ,.inport_rid_o(axi_capture_rid_w)
    ,.inport_rlast_o(axi_capture_rlast_w)
    ,.outport_awvalid_o(axi_capture_retimed_awvalid_w)
    ,.outport_awaddr_o(axi_capture_retimed_awaddr_w)
    ,.outport_awid_o(axi_capture_retimed_awid_w)
    ,.outport_awlen_o(axi_capture_retimed_awlen_w)
    ,.outport_awburst_o(axi_capture_retimed_awburst_w)
    ,.outport_wvalid_o(axi_capture_retimed_wvalid_w)
    ,.outport_wdata_o(axi_capture_retimed_wdata_w)
    ,.outport_wstrb_o(axi_capture_retimed_wstrb_w)
    ,.outport_wlast_o(axi_capture_retimed_wlast_w)
    ,.outport_bready_o(axi_capture_retimed_bready_w)
    ,.outport_arvalid_o(axi_capture_retimed_arvalid_w)
    ,.outport_araddr_o(axi_capture_retimed_araddr_w)
    ,.outport_arid_o(axi_capture_retimed_arid_w)
    ,.outport_arlen_o(axi_capture_retimed_arlen_w)
    ,.outport_arburst_o(axi_capture_retimed_arburst_w)
    ,.outport_rready_o(axi_capture_retimed_rready_w)
);



endmodule
