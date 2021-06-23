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
module top
(
    // Clocks
     input          CLK12

    ,output         LD2_B
    ,output         LD2_R
    ,output         LD2_G
    
    ,output         LD1_R
    ,output         LD1_G
    ,output         LD1_B

    ,input          FTDI_CLK
    ,inout [7:0]    FTDI_D
    ,input          FTDI_RXF
    ,input          FTDI_TXE
    ,inout          FTDI_WR
    ,inout          FTDI_RD
    ,inout          FTDI_SIWUA
    ,inout          FTDI_OE

    // Main input port
    ,input [23:0]   DIN_FPGA
    ,output         DIN_VREF_L
    ,output         DIN_VREF_H

    // DDR
    ,inout  [15:0]  mcb3_dram_dq
    ,output [13:0]  mcb3_dram_a
    ,output [2:0]   mcb3_dram_ba
    ,output         mcb3_dram_ras_n
    ,output         mcb3_dram_cas_n
    ,output         mcb3_dram_we_n
    ,output         mcb3_dram_odt
    ,output         mcb3_dram_reset_n
    ,output         mcb3_dram_cke
    ,output         mcb3_dram_dm
    ,inout          mcb3_dram_udqs
    ,inout          mcb3_dram_udqs_n
    ,inout          mcb3_rzq
    ,inout          mcb3_zio
    ,output         mcb3_dram_udm
    ,inout          mcb3_dram_dqs
    ,inout          mcb3_dram_dqs_n
    ,output         mcb3_dram_ck
    ,output         mcb3_dram_ck_n    
);

//-----------------------------------------------------------------
// Reset
//-----------------------------------------------------------------
wire ftdi_clk_w = FTDI_CLK;
wire ftdi_rst_w;

reset_gen
u_rst_gen
(
     .clk_i(ftdi_clk_w)
    ,.rst_o(ftdi_rst_w)
);

//-----------------------------------------------------------------
// Memory Clock
//-----------------------------------------------------------------
wire clk48_w;
wire clk312_w;
wire clk100_w;
wire mem_clk_w; // 104MHz
wire mem_rst_w;

// Input buffering
IBUFG u_clk_buf
(
    .I (CLK12),
    .O (clk12_buffered_w)
);

dcm12_48
u_dcm_mem
(
     .clkref_i(clk12_buffered_w)
    ,.clkout0_o(clk48_w)
);

dcm12_100
u_dcm_core
(
     .clkref_i(clk12_buffered_w)
    ,.clkout0_o(clk100_w)
);


spartan6_pll
u_pll_mem
(
     .clkref_i(clk48_w)
    ,.clkout0_o(clk312_w)
);

wire clk312_rst_w;

reset_gen
u_rst_mem
(
     .clk_i(clk312_w)
    ,.rst_o(clk312_rst_w)
);

wire clk100_rst_w;

reset_gen
u_rst_core
(
     .clk_i(clk100_w)
    ,.rst_o(clk100_rst_w)
);

//-----------------------------------------------------------------
// Sample clock
//-----------------------------------------------------------------
wire sample_clk_w = clk100_w;
wire sample_rst_w = clk100_rst_w;

//-----------------------------------------------------------------
// FTDI
//-----------------------------------------------------------------
wire [7:0]    ftdi_data_in_w;
wire [7:0]    ftdi_data_out_w;

wire          status_enabled_w;
wire          status_trigger_w;
wire          status_overflow_w;

wire          mem_awvalid_w;
wire [ 31:0]  mem_awaddr_w;
wire [  3:0]  mem_awid_w;
wire [  7:0]  mem_awlen_w;
wire [  1:0]  mem_awburst_w;
wire          mem_wvalid_w;
wire [ 31:0]  mem_wdata_w;
wire [  3:0]  mem_wstrb_w;
wire          mem_wlast_w;
wire          mem_bready_w;
wire          mem_arvalid_w;
wire [ 31:0]  mem_araddr_w;
wire [  3:0]  mem_arid_w;
wire [  7:0]  mem_arlen_w;
wire [  1:0]  mem_arburst_w;
wire          mem_rready_w;
wire          mem_awready_w;
wire          mem_wready_w;
wire          mem_bvalid_w;
wire [  1:0]  mem_bresp_w;
wire [  3:0]  mem_bid_w;
wire          mem_arready_w;
wire          mem_rvalid_w;
wire [ 31:0]  mem_rdata_w;
wire [  1:0]  mem_rresp_w;
wire [  3:0]  mem_rid_w;
wire          mem_rlast_w;

fpga_top
u_core
(
     .ftdi_clk_i(ftdi_clk_w)
    ,.ftdi_rst_i(ftdi_rst_w)
    ,.ftdi_rxf_i(FTDI_RXF)
    ,.ftdi_txe_i(FTDI_TXE)
    ,.ftdi_data_in_i(ftdi_data_in_w)
    ,.ftdi_siwua_o(FTDI_SIWUA)
    ,.ftdi_wrn_o(FTDI_WR)
    ,.ftdi_rdn_o(FTDI_RD)
    ,.ftdi_oen_o(FTDI_OE)
    ,.ftdi_data_out_o(ftdi_data_out_w)

    ,.clk_i(clk100_w)
    ,.rst_i(clk100_rst_w)

    ,.sample_clk_i(sample_clk_w)
    ,.sample_rst_i(sample_rst_w)

    ,.gpio_outputs_o()

    ,.input_i({8'b0, DIN_FPGA})

    ,.status_enabled_o(status_enabled_w)
    ,.status_triggered_o(status_trigger_w)
    ,.status_overflow_o(status_overflow_w)

    ,.cfg_clk_src_ext_o()

    ,.mem_clk_i(mem_clk_w)
    ,.mem_rst_i(mem_rst_w)
    ,.mem_awvalid_o(mem_awvalid_w)
    ,.mem_awaddr_o(mem_awaddr_w)
    ,.mem_awid_o(mem_awid_w)
    ,.mem_awlen_o(mem_awlen_w)
    ,.mem_awburst_o(mem_awburst_w)
    ,.mem_wvalid_o(mem_wvalid_w)
    ,.mem_wdata_o(mem_wdata_w)
    ,.mem_wstrb_o(mem_wstrb_w)
    ,.mem_wlast_o(mem_wlast_w)
    ,.mem_bready_o(mem_bready_w)
    ,.mem_arvalid_o(mem_arvalid_w)
    ,.mem_araddr_o(mem_araddr_w)
    ,.mem_arid_o(mem_arid_w)
    ,.mem_arlen_o(mem_arlen_w)
    ,.mem_arburst_o(mem_arburst_w)
    ,.mem_rready_o(mem_rready_w)
    ,.mem_awready_i(mem_awready_w)
    ,.mem_wready_i(mem_wready_w)
    ,.mem_bvalid_i(mem_bvalid_w)
    ,.mem_bresp_i(mem_bresp_w)
    ,.mem_bid_i(mem_bid_w)
    ,.mem_arready_i(mem_arready_w)
    ,.mem_rvalid_i(mem_rvalid_w)
    ,.mem_rdata_i(mem_rdata_w)
    ,.mem_rresp_i(mem_rresp_w)
    ,.mem_rid_i(mem_rid_w)
    ,.mem_rlast_i(mem_rlast_w)
);

assign ftdi_data_in_w = FTDI_D;
assign FTDI_D         = FTDI_OE ? ftdi_data_out_w : 8'hZZ;

//-----------------------------------------------------------------
// MIG
//-----------------------------------------------------------------
mig
u_mig
(
     .mcb3_dram_dq(mcb3_dram_dq)
    ,.mcb3_dram_a(mcb3_dram_a)
    ,.mcb3_dram_ba(mcb3_dram_ba)
    ,.mcb3_dram_ras_n(mcb3_dram_ras_n)
    ,.mcb3_dram_cas_n(mcb3_dram_cas_n)
    ,.mcb3_dram_we_n(mcb3_dram_we_n)
    ,.mcb3_dram_odt(mcb3_dram_odt)
    ,.mcb3_dram_reset_n(mcb3_dram_reset_n)
    ,.mcb3_dram_cke(mcb3_dram_cke)
    ,.mcb3_dram_dm(mcb3_dram_dm)
    ,.mcb3_dram_udqs(mcb3_dram_udqs)
    ,.mcb3_dram_udqs_n(mcb3_dram_udqs_n)
    ,.mcb3_rzq(mcb3_rzq)
    ,.mcb3_zio(mcb3_zio)
    ,.mcb3_dram_udm(mcb3_dram_udm)
    ,.mcb3_dram_dqs(mcb3_dram_dqs)
    ,.mcb3_dram_dqs_n(mcb3_dram_dqs_n)
    ,.mcb3_dram_ck(mcb3_dram_ck)
    ,.mcb3_dram_ck_n(mcb3_dram_ck_n)

    ,.c3_sys_clk(clk312_w)
    ,.c3_sys_rst_i(clk312_rst_w)
    ,.c3_calib_done()

    ,.c3_clk0(mem_clk_w) // 104MHz
    ,.c3_rst0(mem_rst_w)

    ,.c3_s0_axi_aclk(mem_clk_w)
    ,.c3_s0_axi_aresetn(~mem_rst_w)
    ,.c3_s0_axi_awid(mem_awid_w)
    ,.c3_s0_axi_awaddr(mem_awaddr_w)
    ,.c3_s0_axi_awlen(mem_awlen_w)
    ,.c3_s0_axi_awsize(3'b010)
    ,.c3_s0_axi_awburst(mem_awburst_w)
    ,.c3_s0_axi_awlock(1'b0)
    ,.c3_s0_axi_awcache(4'b0)
    ,.c3_s0_axi_awprot(3'b0)
    ,.c3_s0_axi_awqos(4'b0)
    ,.c3_s0_axi_awvalid(mem_awvalid_w)
    ,.c3_s0_axi_awready(mem_awready_w)
    ,.c3_s0_axi_wdata(mem_wdata_w)
    ,.c3_s0_axi_wstrb(mem_wstrb_w)
    ,.c3_s0_axi_wlast(mem_wlast_w)
    ,.c3_s0_axi_wvalid(mem_wvalid_w)
    ,.c3_s0_axi_wready(mem_wready_w)
    ,.c3_s0_axi_bid(mem_bid_w)
    ,.c3_s0_axi_wid()
    ,.c3_s0_axi_bresp(mem_bresp_w)
    ,.c3_s0_axi_bvalid(mem_bvalid_w)
    ,.c3_s0_axi_bready(mem_bready_w)
    ,.c3_s0_axi_arid(mem_arid_w)
    ,.c3_s0_axi_araddr(mem_araddr_w)
    ,.c3_s0_axi_arlen(mem_arlen_w)
    ,.c3_s0_axi_arsize(3'b010)
    ,.c3_s0_axi_arburst(mem_arburst_w)
    ,.c3_s0_axi_arlock(1'b0)
    ,.c3_s0_axi_arcache(4'b0)
    ,.c3_s0_axi_arprot(3'b0)
    ,.c3_s0_axi_arqos(4'b0)
    ,.c3_s0_axi_arvalid(mem_arvalid_w)
    ,.c3_s0_axi_arready(mem_arready_w)
    ,.c3_s0_axi_rid(mem_rid_w)
    ,.c3_s0_axi_rdata(mem_rdata_w)
    ,.c3_s0_axi_rresp(mem_rresp_w)
    ,.c3_s0_axi_rlast(mem_rlast_w)
    ,.c3_s0_axi_rvalid(mem_rvalid_w)
    ,.c3_s0_axi_rready(mem_rready_w)
);

//-----------------------------------------------------------------
// LED
//-----------------------------------------------------------------
reg [2:0] rgb_q;

always @ (posedge clk100_w)
begin
    if (status_overflow_w)
        rgb_q   <= 3'b100;
    else if (status_trigger_w)
        rgb_q   <= 3'b010;
    else if (status_enabled_w)
        rgb_q   <= 3'b001;
end

assign {LD1_R, LD1_G, LD1_B} = rgb_q;

assign LD2_R = 1'b0;
assign LD2_B = 1'b0;
assign LD2_G = 1'b0;

//-----------------------------------------------------------------
// Misc
//-----------------------------------------------------------------
// VREFIO: 0V, when DIN_VREF_H = DIN_VREF_L = low
assign DIN_VREF_L = 1'b0;
assign DIN_VREF_H = 1'b0;

endmodule
