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
module axi4_cdc_fifo37
(
    // Inputs
     input           rd_clk_i
    ,input           rd_rst_i
    ,input           rd_pop_i
    ,input           wr_clk_i
    ,input           wr_rst_i
    ,input  [ 36:0]  wr_data_i
    ,input           wr_push_i

    // Outputs
    ,output [ 36:0]  rd_data_o
    ,output          rd_empty_o
    ,output          wr_full_o
);





//-----------------------------------------------------------------
// Registers
//-----------------------------------------------------------------
reg [4:0]       rd_ptr_q;
reg [4:0]       wr_ptr_q;

//-----------------------------------------------------------------
// Write
//-----------------------------------------------------------------
wire [4:0]      wr_ptr_next_w = wr_ptr_q + 5'd1;

always @ (posedge wr_clk_i or posedge wr_rst_i)
if (wr_rst_i)
    wr_ptr_q <= 5'b0;
else if (wr_push_i & ~wr_full_o)
    wr_ptr_q <= wr_ptr_next_w;

wire [4:0] wr_rd_ptr_w;

axi4_cdc_fifo37_resync_bus
#( .WIDTH(5))
u_resync_rd_ptr_q
(
    .wr_clk_i(rd_clk_i),
    .wr_rst_i(rd_rst_i),
    .wr_i(1'b1),
    .wr_data_i(rd_ptr_q),
    .wr_busy_o(),
    .rd_clk_i(wr_clk_i),
    .rd_rst_i(wr_rst_i),
    .rd_data_o(wr_rd_ptr_w) // Delayed version of rd_ptr_q
);

assign wr_full_o = (wr_ptr_next_w == wr_rd_ptr_w);

//-------------------------------------------------------------------
// Dual port RAM
//-------------------------------------------------------------------
wire [36:0] rd_data_w;

axi4_cdc_fifo37_ram_dp_32_5
u_ram
(
    // Inputs
    .clk0_i(wr_clk_i),
    .rst0_i(wr_rst_i),
    .clk1_i(rd_clk_i),
    .rst1_i(rd_rst_i),

    // Write side
    .addr0_i(wr_ptr_q),
    .wr0_i(wr_push_i & ~wr_full_o),
    .data0_i(wr_data_i),
    .data0_o(),

    // Read side
    .addr1_i(rd_ptr_q),
    .data1_i(37'b0),
    .wr1_i(1'b0),
    .data1_o(rd_data_w)
);

//-----------------------------------------------------------------
// Read
//-----------------------------------------------------------------
wire [4:0] rd_wr_ptr_w;

axi4_cdc_fifo37_resync_bus
#( .WIDTH(5))
u_resync_wr_ptr_q
(
    .wr_clk_i(wr_clk_i),
    .wr_rst_i(wr_rst_i),
    .wr_i(1'b1),
    .wr_data_i(wr_ptr_q),
    .wr_busy_o(),
    .rd_clk_i(rd_clk_i),
    .rd_rst_i(rd_rst_i),
    .rd_data_o(rd_wr_ptr_w) // Delayed version of wr_ptr_q
);

//-------------------------------------------------------------------
// Read Skid Buffer
//-------------------------------------------------------------------
reg                rd_skid_q;
reg [36:0] rd_skid_data_q;
reg                rd_q;

wire read_ok_w = (rd_wr_ptr_w != rd_ptr_q);
wire valid_w   = (rd_skid_q | rd_q);

always @ (posedge rd_clk_i or posedge rd_rst_i)
if (rd_rst_i)
begin
    rd_skid_q <= 1'b0;
    rd_skid_data_q <= 37'b0;
end
else if (valid_w && !rd_pop_i)
begin
    rd_skid_q      <= 1'b1;
    rd_skid_data_q <= rd_data_o;
end
else
begin
    rd_skid_q      <= 1'b0;
    rd_skid_data_q <= 37'b0;
end

assign rd_data_o = rd_skid_q ? rd_skid_data_q : rd_data_w;

//-----------------------------------------------------------------
// Read Pointer
//-----------------------------------------------------------------
always @ (posedge rd_clk_i or posedge rd_rst_i)
if (rd_rst_i)
    rd_q <= 1'b0;
else
    rd_q <= read_ok_w;

wire [4:0] rd_ptr_next_w = rd_ptr_q + 5'd1;

always @ (posedge rd_clk_i or posedge rd_rst_i)
if (rd_rst_i)
    rd_ptr_q <= 5'b0;
// Read address increment
else if (read_ok_w && ((!valid_w) || (valid_w && rd_pop_i)))
    rd_ptr_q <= rd_ptr_next_w;

assign rd_empty_o = !valid_w;

endmodule

//-------------------------------------------------------------------
// Dual port RAM
//-------------------------------------------------------------------
module axi4_cdc_fifo37_ram_dp_32_5
(
    // Inputs
     input           clk0_i
    ,input           rst0_i
    ,input  [ 4:0]  addr0_i
    ,input  [ 36:0]  data0_i
    ,input           wr0_i
    ,input           clk1_i
    ,input           rst1_i
    ,input  [ 4:0]  addr1_i
    ,input  [ 36:0]  data1_i
    ,input           wr1_i

    // Outputs
    ,output [ 36:0]  data0_o
    ,output [ 36:0]  data1_o
);

/* verilator lint_off MULTIDRIVEN */
reg [36:0]   ram [31:0] /*verilator public*/;
/* verilator lint_on MULTIDRIVEN */

reg [36:0] ram_read0_q;
reg [36:0] ram_read1_q;

// Synchronous write
always @ (posedge clk0_i)
begin
    if (wr0_i)
        ram[addr0_i] <= data0_i;

    ram_read0_q <= ram[addr0_i];
end

always @ (posedge clk1_i)
begin
    if (wr1_i)
        ram[addr1_i] <= data1_i;

    ram_read1_q <= ram[addr1_i];
end

assign data0_o = ram_read0_q;
assign data1_o = ram_read1_q;

endmodule 

module axi4_cdc_fifo37_resync_bus
//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
    parameter WIDTH     = 4
)
//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
    input              wr_clk_i,
    input              wr_rst_i,
    input              wr_i,
    input  [WIDTH-1:0] wr_data_i,
    output             wr_busy_o,

    input              rd_clk_i,
    input              rd_rst_i,
    output [WIDTH-1:0] rd_data_o
);

wire rd_toggle_w;
wire wr_toggle_w;

//-----------------------------------------------------------------
// Write
//-----------------------------------------------------------------
wire write_req_w = wr_i && !wr_busy_o;

// Write storage for domain crossing
(* ASYNC_REG = "TRUE" *) reg [WIDTH-1:0] wr_buffer_q;

always @ (posedge wr_clk_i or posedge wr_rst_i)
if (wr_rst_i)
    wr_buffer_q <= {(WIDTH){1'b0}};
else if (write_req_w)
    wr_buffer_q <= wr_data_i;

reg wr_toggle_q;
always @ (posedge wr_clk_i or posedge wr_rst_i)
if (wr_rst_i)
    wr_toggle_q <= 1'b0;
else if (write_req_w)
    wr_toggle_q <= ~wr_toggle_q;

reg wr_busy_q;
always @ (posedge wr_clk_i or posedge wr_rst_i)
if (wr_rst_i)
    wr_busy_q <= 1'b0;
else if (write_req_w)
    wr_busy_q <= 1'b1;
else if (wr_toggle_q == wr_toggle_w)
    wr_busy_q <= 1'b0;

assign wr_busy_o = wr_busy_q;

//-----------------------------------------------------------------
// Write -> Read request
//-----------------------------------------------------------------
axi4_cdc_fifo37_resync
u_sync_wr_toggle
(
    .clk_i(rd_clk_i),
    .rst_i(rd_rst_i),
    .async_i(wr_toggle_q),
    .sync_o(rd_toggle_w)
);

//-----------------------------------------------------------------
// Read
//-----------------------------------------------------------------
reg rd_toggle_q;
always @ (posedge rd_clk_i or posedge rd_rst_i)
if (rd_rst_i)
    rd_toggle_q <= 1'b0;
else
    rd_toggle_q <= rd_toggle_w;

// Read storage for domain crossing
(* ASYNC_REG = "TRUE" *) reg [WIDTH-1:0] rd_buffer_q;

always @ (posedge rd_clk_i or posedge rd_rst_i)
if (rd_rst_i)
    rd_buffer_q <= {(WIDTH){1'b0}};
else if (rd_toggle_q != rd_toggle_w)
    rd_buffer_q <= wr_buffer_q; // Capture from other domain

assign rd_data_o = rd_buffer_q;

//-----------------------------------------------------------------
// Read->Write response
//-----------------------------------------------------------------
axi4_cdc_fifo37_resync
u_sync_rd_toggle
(
    .clk_i(wr_clk_i),
    .rst_i(wr_rst_i),
    .async_i(rd_toggle_q),
    .sync_o(wr_toggle_w)
);

endmodule

module axi4_cdc_fifo37_resync
//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
    parameter RESET_VAL = 1'b0
)
//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
    input  clk_i,
    input  rst_i,
    input  async_i,
    output sync_o
);

(* ASYNC_REG = "TRUE" *) reg sync_ms;
(* ASYNC_REG = "TRUE" *) reg sync_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
begin
    sync_ms  <= RESET_VAL;
    sync_q   <= RESET_VAL;
end
else
begin
    sync_ms  <= async_i;
    sync_q   <= sync_ms;
end

assign sync_o = sync_q;


endmodule
