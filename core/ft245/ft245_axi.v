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
module ft245_axi
//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
     parameter RETIME_AXI       = 1
    ,parameter AXI_ID           = 8
)
//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
    // Inputs
     input           clk_i
    ,input           rst_i
    ,input           ftdi_rxf_i
    ,input           ftdi_txe_i
    ,input  [  7:0]  ftdi_data_in_i
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
    ,output          ftdi_siwua_o
    ,output          ftdi_wrn_o
    ,output          ftdi_rdn_o
    ,output          ftdi_oen_o
    ,output [  7:0]  ftdi_data_out_o
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
    ,output [  7:0]  gpio_outputs_o
);



//-----------------------------------------------------------------
// AXI interface retiming
//-----------------------------------------------------------------
wire          outport_awvalid_w;
wire [ 31:0]  outport_awaddr_w;
wire [  3:0]  outport_awid_w;
wire [  7:0]  outport_awlen_w;
wire [  1:0]  outport_awburst_w;
wire          outport_wvalid_w;
wire [ 31:0]  outport_wdata_w;
wire [  3:0]  outport_wstrb_w;
wire          outport_wlast_w;
wire          outport_bready_w;
wire          outport_arvalid_w;
wire [ 31:0]  outport_araddr_w;
wire [  3:0]  outport_arid_w;
wire [  7:0]  outport_arlen_w;
wire [  1:0]  outport_arburst_w;
wire          outport_rready_w;
wire          outport_awready_w;
wire          outport_wready_w;
wire          outport_bvalid_w;
wire [  1:0]  outport_bresp_w;
wire [  3:0]  outport_bid_w;
wire          outport_arready_w;
wire          outport_rvalid_w;
wire [ 31:0]  outport_rdata_w;
wire [  1:0]  outport_rresp_w;
wire [  3:0]  outport_rid_w;
wire          outport_rlast_w;

generate
if (RETIME_AXI)
begin
    ft245_axi_retime 
    u_retime
    (
         .clk_i(clk_i)
        ,.rst_i(rst_i)

        ,.inport_awvalid_i(outport_awvalid_w)
        ,.inport_awaddr_i(outport_awaddr_w)
        ,.inport_awid_i(outport_awid_w)
        ,.inport_awlen_i(outport_awlen_w)
        ,.inport_awburst_i(outport_awburst_w)
        ,.inport_wvalid_i(outport_wvalid_w)
        ,.inport_wdata_i(outport_wdata_w)
        ,.inport_wstrb_i(outport_wstrb_w)
        ,.inport_wlast_i(outport_wlast_w)
        ,.inport_bready_i(outport_bready_w)
        ,.inport_arvalid_i(outport_arvalid_w)
        ,.inport_araddr_i(outport_araddr_w)
        ,.inport_arid_i(outport_arid_w)
        ,.inport_arlen_i(outport_arlen_w)
        ,.inport_arburst_i(outport_arburst_w)
        ,.inport_rready_i(outport_rready_w)
        ,.inport_awready_o(outport_awready_w)
        ,.inport_wready_o(outport_wready_w)
        ,.inport_bvalid_o(outport_bvalid_w)
        ,.inport_bresp_o(outport_bresp_w)
        ,.inport_bid_o(outport_bid_w)
        ,.inport_arready_o(outport_arready_w)
        ,.inport_rvalid_o(outport_rvalid_w)
        ,.inport_rdata_o(outport_rdata_w)
        ,.inport_rresp_o(outport_rresp_w)
        ,.inport_rid_o(outport_rid_w)
        ,.inport_rlast_o(outport_rlast_w)

        ,.outport_awvalid_o(outport_awvalid_o)
        ,.outport_awaddr_o(outport_awaddr_o)
        ,.outport_awid_o(outport_awid_o)
        ,.outport_awlen_o(outport_awlen_o)
        ,.outport_awburst_o(outport_awburst_o)
        ,.outport_wvalid_o(outport_wvalid_o)
        ,.outport_wdata_o(outport_wdata_o)
        ,.outport_wstrb_o(outport_wstrb_o)
        ,.outport_wlast_o(outport_wlast_o)
        ,.outport_bready_o(outport_bready_o)
        ,.outport_arvalid_o(outport_arvalid_o)
        ,.outport_araddr_o(outport_araddr_o)
        ,.outport_arid_o(outport_arid_o)
        ,.outport_arlen_o(outport_arlen_o)
        ,.outport_arburst_o(outport_arburst_o)
        ,.outport_rready_o(outport_rready_o)
        ,.outport_awready_i(outport_awready_i)
        ,.outport_wready_i(outport_wready_i)
        ,.outport_bvalid_i(outport_bvalid_i)
        ,.outport_bresp_i(outport_bresp_i)
        ,.outport_bid_i(outport_bid_i)
        ,.outport_arready_i(outport_arready_i)
        ,.outport_rvalid_i(outport_rvalid_i)
        ,.outport_rdata_i(outport_rdata_i)
        ,.outport_rresp_i(outport_rresp_i)
        ,.outport_rid_i(outport_rid_i)
        ,.outport_rlast_i(outport_rlast_i)
    );
end
else
begin
    assign outport_arvalid_o = outport_arvalid_w;
    assign outport_araddr_o  = outport_araddr_w;
    assign outport_arid_o    = outport_arid_w;
    assign outport_arlen_o   = outport_arlen_w;
    assign outport_arburst_o = outport_arburst_w;
    assign outport_awvalid_o = outport_awvalid_w;
    assign outport_awaddr_o  = outport_awaddr_w;
    assign outport_awid_o    = outport_awid_w;
    assign outport_awlen_o   = outport_awlen_w;
    assign outport_awburst_o = outport_awburst_w;
    assign outport_wvalid_o  = outport_wvalid_w;
    assign outport_wdata_o   = outport_wdata_w;
    assign outport_wstrb_o   = outport_wstrb_w;
    assign outport_wlast_o   = outport_wlast_w;
    assign outport_rready_o  = outport_rready_w;
    assign outport_bready_o  = outport_bready_w;

    assign outport_awready_w = outport_awready_i;
    assign outport_wready_w  = outport_wready_i;
    assign outport_bvalid_w  = outport_bvalid_i;
    assign outport_bresp_w   = outport_bresp_i;
    assign outport_bid_w     = outport_bid_i;
    assign outport_arready_w = outport_arready_i;
    assign outport_rvalid_w  = outport_rvalid_i;
    assign outport_rdata_w   = outport_rdata_i;
    assign outport_rresp_w   = outport_rresp_i;
    assign outport_rid_w     = outport_rid_i;
    assign outport_rlast_w   = outport_rlast_i;
end
endgenerate

//-----------------------------------------------------------------
// FTDI <-> Stream
//-----------------------------------------------------------------
wire          rx8_valid_w;
wire [ 7:0]   rx8_data_w;
wire          rx8_accept_w;

wire          tx8_valid_w;
wire [ 7:0]   tx8_data_w;
wire          tx8_accept_w;

ft245_fifo
u_ram
(
     .clk_i(clk_i)
    ,.rst_i(rst_i)
    ,.ftdi_rxf_i(ftdi_rxf_i)
    ,.ftdi_txe_i(ftdi_txe_i)
    ,.ftdi_data_in_i(ftdi_data_in_i)
    ,.ftdi_wrn_o(ftdi_wrn_o)
    ,.ftdi_rdn_o(ftdi_rdn_o)
    ,.ftdi_oen_o(ftdi_oen_o)
    ,.ftdi_data_out_o(ftdi_data_out_o)
    ,.ftdi_siwua_o(ftdi_siwua_o)

    ,.inport_valid_i(tx8_valid_w)
    ,.inport_data_i(tx8_data_w)
    ,.inport_accept_o(tx8_accept_w)

    ,.outport_valid_o(rx8_valid_w)
    ,.outport_data_o(rx8_data_w)
    ,.outport_accept_i(rx8_accept_w)
);

wire          rx_valid_w;
wire [ 31:0]  rx_data_w;
wire          rx_accept_w;

ft245_axi_fifo_8_32
u_upconv
(
     .clk_i(clk_i)
    ,.rst_i(rst_i)

    ,.inport_valid_i(rx8_valid_w)
    ,.inport_data_i(rx8_data_w)
    ,.inport_accept_o(rx8_accept_w)

    ,.outport_valid_o(rx_valid_w)
    ,.outport_data_o(rx_data_w)
    ,.outport_accept_i(rx_accept_w)
);

wire          tx_valid_w;
wire [ 31:0]  tx_data_w;
wire          tx_accept_w;

ft245_axi_fifo_32_8
u_downconv
(
     .clk_i(clk_i)
    ,.rst_i(rst_i)

    ,.inport_valid_i(tx_valid_w)
    ,.inport_data_i(tx_data_w)
    ,.inport_accept_o(tx_accept_w)

    ,.outport_valid_o(tx8_valid_w)
    ,.outport_data_o(tx8_data_w)
    ,.outport_accept_i(tx8_accept_w)
);


//-----------------------------------------------------------------
// Defines / Local params
//-----------------------------------------------------------------
localparam STATE_W           = 4;
localparam STATE_IDLE        = 4'd0;
localparam STATE_CMD_REQ     = 4'd1;
localparam STATE_CMD_ADDR    = 4'd2;
localparam STATE_ECHO        = 4'd3;
localparam STATE_STATUS      = 4'd4;
localparam STATE_READ_CMD    = 4'd5;
localparam STATE_READ_DATA   = 4'd6;
localparam STATE_WRITE_CMD   = 4'd7;
localparam STATE_WRITE_DATA  = 4'd8;
localparam STATE_WRITE_RESP  = 4'd9;
localparam STATE_DRAIN       = 4'd10;
localparam STATE_GPIO_WR     = 4'd11;
localparam STATE_GPIO_RD     = 4'd12;

localparam CMD_ID_ECHO       = 8'h01;
localparam CMD_ID_DRAIN      = 8'h02;
localparam CMD_ID_READ       = 8'h10;
localparam CMD_ID_WRITE8_NP  = 8'h20; // 8-bit write (with response)
localparam CMD_ID_WRITE16_NP = 8'h21; // 16-bit write (with response)
localparam CMD_ID_WRITE_NP   = 8'h22; // 32-bit write (with response)
localparam CMD_ID_WRITE8     = 8'h30; // 8-bit write
localparam CMD_ID_WRITE16    = 8'h31; // 16-bit write
localparam CMD_ID_WRITE      = 8'h32; // 32-bit write
localparam CMD_ID_GPIO_WR    = 8'h40;
localparam CMD_ID_GPIO_RD    = 8'h41;

reg [STATE_W-1:0] state_q;
reg [7:0]         cmd_len_q;
reg [31:0]        cmd_addr_q;
reg [15:0]        cmd_seq_q;
reg [7:0]         cmd_id_q;

reg [7:0]         stat_len_q;
reg [1:0]         stat_resp_q;

//-----------------------------------------------------------------
// Next State Logic
//-----------------------------------------------------------------
reg [STATE_W-1:0] next_state_r;
always @ *
begin
    next_state_r = state_q;

    case (state_q)
    //-----------------------------------------
    // STATE_IDLE
    //-----------------------------------------
    STATE_IDLE :
    begin
        if (rx_valid_w)
            next_state_r = STATE_CMD_REQ;
    end
    //-----------------------------------------
    // STATE_CMD_REQ
    //-----------------------------------------
    STATE_CMD_REQ :
    begin
        if (rx_valid_w) next_state_r  = STATE_CMD_ADDR;
    end
    //-----------------------------------------
    // STATE_CMD_ADDR
    //-----------------------------------------
    STATE_CMD_ADDR :
    begin
        if (cmd_id_q == CMD_ID_ECHO && cmd_len_q != 8'b0)
            next_state_r = STATE_ECHO;
        else if (cmd_id_q == CMD_ID_ECHO && cmd_len_q == 8'b0)
            next_state_r = STATE_STATUS;
        else if (cmd_id_q == CMD_ID_READ)
            next_state_r = STATE_READ_CMD;
        else if (cmd_id_q == CMD_ID_WRITE8_NP  ||
                 cmd_id_q == CMD_ID_WRITE16_NP || 
                 cmd_id_q == CMD_ID_WRITE_NP   ||
                 cmd_id_q == CMD_ID_WRITE8     ||
                 cmd_id_q == CMD_ID_WRITE16    || 
                 cmd_id_q == CMD_ID_WRITE)
            next_state_r = STATE_WRITE_CMD;
        else if (cmd_id_q == CMD_ID_DRAIN)
            next_state_r = STATE_DRAIN;
        else if (cmd_id_q == CMD_ID_GPIO_WR)
            next_state_r = STATE_GPIO_WR;
        else if (cmd_id_q == CMD_ID_GPIO_RD)
            next_state_r = STATE_GPIO_RD;
    end
    //-----------------------------------------
    // STATE_ECHO
    //-----------------------------------------
    STATE_ECHO :
    begin
        if ((stat_len_q + 8'd1) == cmd_len_q && tx_accept_w)
            next_state_r = STATE_STATUS;
    end
    //-----------------------------------------
    // STATE_READ_CMD
    //-----------------------------------------
    STATE_READ_CMD :
    begin
        if (outport_arready_w)
            next_state_r = STATE_READ_DATA;
    end
    //-----------------------------------------
    // STATE_READ_DATA
    //-----------------------------------------
    STATE_READ_DATA :
    begin
        if (outport_rvalid_w && outport_rready_w && outport_rlast_w)
            next_state_r = STATE_STATUS;
    end
    //-----------------------------------------
    // STATE_WRITE_CMD
    //-----------------------------------------
    STATE_WRITE_CMD :
    begin
        if (outport_awready_w)
            next_state_r = STATE_WRITE_DATA;
    end
    //-----------------------------------------
    // STATE_WRITE_DATA
    //-----------------------------------------
    STATE_WRITE_DATA :
    begin
        if (outport_wvalid_w && outport_wlast_w && outport_wready_w)
            next_state_r = STATE_WRITE_RESP;
    end
    //-----------------------------------------
    // STATE_WRITE_RESP
    //-----------------------------------------
    STATE_WRITE_RESP :
    begin
        if (outport_bvalid_w && outport_bready_w)
        begin
            if (cmd_id_q == CMD_ID_WRITE8   ||
                cmd_id_q == CMD_ID_WRITE16  || 
                cmd_id_q == CMD_ID_WRITE)
                next_state_r = STATE_IDLE;
            else
                next_state_r = STATE_STATUS;
        end
    end
    //-----------------------------------------
    // STATE_STATUS
    //-----------------------------------------
    STATE_STATUS :
    begin
        if (tx_accept_w) next_state_r = STATE_IDLE;
    end
    //-----------------------------------------
    // STATE_DRAIN
    //-----------------------------------------
    STATE_DRAIN :
    begin
        if (!rx_valid_w) next_state_r = STATE_IDLE;
    end
    //-----------------------------------------
    // STATE_GPIO_WR
    //-----------------------------------------
    STATE_GPIO_WR :
    begin
        if (rx_valid_w) next_state_r = STATE_STATUS;
    end
    //-----------------------------------------
    // STATE_GPIO_RD
    //-----------------------------------------
    STATE_GPIO_RD :
    begin
        if (tx_accept_w) next_state_r = STATE_STATUS;
    end
    default:
        ;
   endcase
end

// Update state
always @ (posedge clk_i )
if (rst_i)
    state_q   <= STATE_IDLE;
else
    state_q   <= next_state_r;

//-----------------------------------------------------------------
// Command capture
//-----------------------------------------------------------------
always @ (posedge clk_i )
if (rst_i)
    cmd_id_q <= 8'b0;
else if (state_q != STATE_CMD_REQ && next_state_r == STATE_CMD_REQ)
    cmd_id_q <= rx_data_w[7:0];

always @ (posedge clk_i )
if (rst_i)
    cmd_len_q <= 8'b0;
else if (state_q != STATE_CMD_REQ && next_state_r == STATE_CMD_REQ)
    cmd_len_q <= rx_data_w[15:8];

always @ (posedge clk_i )
if (rst_i)
    cmd_seq_q <= 16'b0;
else if (state_q != STATE_CMD_REQ && next_state_r == STATE_CMD_REQ)
    cmd_seq_q <= rx_data_w[31:16];

always @ (posedge clk_i )
if (rst_i)
    cmd_addr_q <= 32'b0;
else if (state_q != STATE_CMD_ADDR && next_state_r == STATE_CMD_ADDR)
    cmd_addr_q <= rx_data_w;

//-----------------------------------------------------------------
// Length
//-----------------------------------------------------------------
always @ (posedge clk_i )
if (rst_i)
    stat_len_q <= 8'b0;
else if (state_q != STATE_CMD_REQ && next_state_r == STATE_CMD_REQ)
    stat_len_q <= 8'b0;
else if (state_q == STATE_ECHO && tx_accept_w)
    stat_len_q <= stat_len_q + 8'd1;
else if (state_q == STATE_WRITE_DATA && outport_wvalid_w && outport_wready_w)
    stat_len_q <= stat_len_q + 8'd1;

//-----------------------------------------------------------------
// Write Mask
//-----------------------------------------------------------------
reg [3:0] write_strb_q;

always @ (posedge clk_i )
if (rst_i)
    write_strb_q <= 4'b0;
else if (state_q != STATE_CMD_ADDR && next_state_r == STATE_CMD_ADDR)
begin
    if (cmd_id_q == CMD_ID_WRITE8 || cmd_id_q == CMD_ID_WRITE8_NP)
    begin
        case (rx_data_w[1:0])
        2'b00: write_strb_q <= 4'b0001;
        2'b01: write_strb_q <= 4'b0010;
        2'b10: write_strb_q <= 4'b0100;
        2'b11: write_strb_q <= 4'b1000;
        endcase
    end
    else if (cmd_id_q == CMD_ID_WRITE16 || cmd_id_q == CMD_ID_WRITE16_NP)
    begin
        case ({rx_data_w[1],1'b0})
        2'b00: write_strb_q <= 4'b0011;
        2'b10: write_strb_q <= 4'b1100;
        default: ;
        endcase
    end
    else
        write_strb_q <= 4'b1111;
end

//-----------------------------------------------------------------
// Handshaking
//-----------------------------------------------------------------
reg rx_accept_r;
always @ *
begin
    rx_accept_r = 1'b0;

    case (state_q)
    STATE_IDLE,
    STATE_CMD_REQ,
    STATE_GPIO_WR,
    STATE_DRAIN :     rx_accept_r = 1'b1;
    STATE_CMD_ADDR :  rx_accept_r = 1'b0;
    STATE_ECHO:       rx_accept_r = tx_accept_w;
    STATE_WRITE_DATA: rx_accept_r = outport_wready_w;
    default:
        ;
   endcase
end

assign rx_accept_w = rx_accept_r;

reg        tx_valid_r;
reg [31:0] tx_data_r;


always @ *
begin
    tx_valid_r = 1'b0;
    tx_data_r  = 32'b0;

    case (state_q)
    STATE_ECHO:
    begin
        tx_valid_r = rx_valid_w;
        tx_data_r  = rx_data_w;
    end
    STATE_STATUS:
    begin
        tx_valid_r = 1'b1;
        tx_data_r  = {14'b0, stat_resp_q, cmd_seq_q};
    end
    STATE_READ_DATA:
    begin
        tx_valid_r = outport_rvalid_w;
        tx_data_r  = outport_rdata_w;
    end
    STATE_GPIO_RD:
    begin
        tx_valid_r = 1'b1;
        tx_data_r  = 32'b0;
    end
    default:
        ;
   endcase
end

assign tx_valid_w = tx_valid_r;
assign tx_data_w  = tx_data_r;

//-----------------------------------------------------------------
// AXI Read
//-----------------------------------------------------------------
assign outport_arvalid_w = (state_q == STATE_READ_CMD);
assign outport_araddr_w  = cmd_addr_q;
assign outport_arid_w    = AXI_ID;
assign outport_arlen_w   = cmd_len_q - 8'd1;
assign outport_arburst_w = 2'b01;

assign outport_rready_w  = (state_q == STATE_READ_DATA) && tx_accept_w;

//-----------------------------------------------------------------
// AXI Write
//-----------------------------------------------------------------
assign outport_awvalid_w = (state_q == STATE_WRITE_CMD);
assign outport_awaddr_w  = cmd_addr_q;
assign outport_awid_w    = AXI_ID;
assign outport_awlen_w   = cmd_len_q - 8'd1;
assign outport_awburst_w = 2'b01;

assign outport_wvalid_w  = (state_q == STATE_WRITE_DATA) && rx_valid_w;
assign outport_wdata_w   = rx_data_w;
assign outport_wstrb_w   = write_strb_q;
assign outport_wlast_w   = (stat_len_q + 8'd1) == cmd_len_q;

assign outport_bready_w  = 1'b1;

//-----------------------------------------------------------------
// AXI Response
//-----------------------------------------------------------------
always @ (posedge clk_i )
if (rst_i)
    stat_resp_q <= 2'b0;
else if (state_q == STATE_IDLE)
    stat_resp_q <= 2'b0;
else if (outport_bvalid_w && outport_bready_w)
    stat_resp_q <= outport_bresp_w;
else if (outport_rvalid_w && outport_rlast_w && outport_rready_w)
    stat_resp_q <= outport_rresp_w;

//-----------------------------------------------------------------
// GPIO Outputs
//-----------------------------------------------------------------
reg [7:0] gpio_out_q;
always @ (posedge clk_i )
if (rst_i)
    gpio_out_q <= 8'b0;
else if (state_q == STATE_GPIO_WR && rx_valid_w)
    gpio_out_q <= rx_data_w[7:0];

assign gpio_outputs_o = gpio_out_q;


endmodule


module ft245_axi_fifo_8_32
(
    // Inputs
     input           clk_i
    ,input           rst_i
    ,input           inport_valid_i
    ,input  [  7:0]  inport_data_i
    ,input           outport_accept_i

    // Outputs
    ,output          inport_accept_o
    ,output          outport_valid_o
    ,output [ 31:0]  outport_data_o
);



wire       flush_w = !inport_valid_i;
wire       space_w = !outport_valid_o || outport_accept_i;

//-----------------------------------------------------------------
// Data write index
//-----------------------------------------------------------------
reg [1:0]  idx_q;
always @ (posedge clk_i )
if (rst_i)
    idx_q <= 2'b0;
else if (flush_w)
    idx_q <= 2'b0;
else if (inport_valid_i && inport_accept_o)
    idx_q <= idx_q + 2'd1;

//-----------------------------------------------------------------
// Data
//-----------------------------------------------------------------
reg [31:0] data_q;
reg [31:0] data_r;

always @ *
begin
    data_r = 32'b0;
    case (idx_q)
    2'd0: data_r = {24'b0,  inport_data_i};
    2'd1: data_r = {16'b0,  inport_data_i, data_q[7:0]};
    2'd2: data_r = {8'b0,   inport_data_i, data_q[15:0]};
    2'd3: data_r = {inport_data_i, data_q[23:0]};
    endcase
end

always @ (posedge clk_i )
if (rst_i)
    data_q <= 32'b0;
else if (inport_valid_i && inport_accept_o)
    data_q <= data_r;

//-----------------------------------------------------------------
// Valid
//-----------------------------------------------------------------
reg valid_q;

always @ (posedge clk_i )
if (rst_i)
    valid_q <= 1'b0;
else if (flush_w && idx_q != 2'd0)
    valid_q <= 1'b1;
else if (inport_valid_i && inport_accept_o && idx_q == 2'd3)
    valid_q <= 1'b1;
else if (outport_accept_i)
    valid_q <= 1'b0;

//-----------------------------------------------------------------
// Outputs
//-----------------------------------------------------------------
assign outport_valid_o = valid_q;
assign outport_data_o  = data_q;

assign inport_accept_o = space_w;

endmodule

module ft245_axi_fifo_32_8
(
    // Inputs
     input           clk_i
    ,input           rst_i
    ,input           inport_valid_i
    ,input  [ 31:0]  inport_data_i
    ,input           outport_accept_i

    // Outputs
    ,output          inport_accept_o
    ,output [  7:0]  outport_data_o
    ,output          outport_valid_o
);



reg       valid_q;
reg [7:0] data_q;

reg [1:0] idx_q;

wire      accept_w;

//-----------------------------------------------------------------
// Last valid data detection
//-----------------------------------------------------------------
wire last_data_w = (idx_q == 2'd3);

//-----------------------------------------------------------------
// Data
//-----------------------------------------------------------------
reg [7:0] data_r;

always @ *
begin
    data_r = 8'b0;
    case (idx_q)
    2'd0: data_r = inport_data_i[7:0];
    2'd1: data_r = inport_data_i[15:8];
    2'd2: data_r = inport_data_i[23:16];
    2'd3: data_r = inport_data_i[31:24];
    endcase
end

always @ (posedge clk_i )
if (rst_i)
    data_q <= 8'b0;
else if (accept_w)
    data_q <= data_r;

assign outport_data_o = data_q;

//-----------------------------------------------------------------
// Valid
//-----------------------------------------------------------------
always @ (posedge clk_i )
if (rst_i)
    valid_q <= 1'b0;
else if (accept_w)
    valid_q <= inport_valid_i;

assign outport_valid_o = valid_q;

//-----------------------------------------------------------------
// Data read index
//-----------------------------------------------------------------
always @ (posedge clk_i )
if (rst_i)
    idx_q <= 2'b0;
else if (last_data_w && accept_w)
    idx_q <= 2'b0;
else if (accept_w && inport_valid_i)
    idx_q <= idx_q + 2'd1;

//-----------------------------------------------------------------
// Accept
//-----------------------------------------------------------------
assign accept_w = !outport_valid_o || (outport_valid_o && outport_accept_i);

// Entire word consumed, pop...
assign inport_accept_o = accept_w && last_data_w;




endmodule
