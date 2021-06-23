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

module capture_rle
(
    // Inputs
     input           clk_i
    ,input           rst_i
    ,input           input_clk_i
    ,input           input_rst_i
    ,input  [ 31:0]  input_i
    ,input  [  3:0]  cfg_clk_div_i
    ,input  [  1:0]  cfg_width_i
    ,input           cfg_test_mode_i

    // Outputs
    ,output          valid_o
    ,output [ 31:0]  data_o
);



//-----------------------------------------------------------------
// Config
//-----------------------------------------------------------------
// These may come from another clock domain - they will be stable prior
// to enabling, but resync to keep the timing tools happy.
(* ASYNC_REG = "TRUE" *) reg [6:0] cfg_ms_q;

always @ (posedge input_clk_i )
if (input_rst_i)
    cfg_ms_q <= 7'b0;
else
    cfg_ms_q <= {cfg_test_mode_i, cfg_width_i, cfg_clk_div_i};

reg [6:0] cfg_q;

always @ (posedge input_clk_i )
if (input_rst_i)
    cfg_q <= 7'b0;
else
    cfg_q <= cfg_ms_q;

wire       cfg_32bit_w;
wire       cfg_24bit_w;
wire [3:0] cfg_clk_div_w;
wire       cfg_test_mode_w;

assign {cfg_test_mode_w, cfg_32bit_w, cfg_24bit_w, cfg_clk_div_w} = cfg_q;

//-----------------------------------------------------------------
// Clock divider
//-----------------------------------------------------------------
reg [3:0] clk_div_q;

always @ (posedge clk_i )
if (rst_i)
    clk_div_q <= 4'd0;
else if (clk_div_q == 4'd0)
    clk_div_q <= cfg_clk_div_w;
else
    clk_div_q <= clk_div_q - 4'd1;

wire clk_en_w = (clk_div_q == 4'd0);

//-----------------------------------------------------------------
// Resync
//-----------------------------------------------------------------
(* ASYNC_REG = "TRUE" *) reg [31:0] resync_ms_q;

always @ (posedge input_clk_i )
if (input_rst_i)
    resync_ms_q <= 32'b0;
else
    resync_ms_q <= input_i;

//-----------------------------------------------------------------
// Sample capture
//-----------------------------------------------------------------
reg [31:0] capture_q;

always @ (posedge input_clk_i )
if (input_rst_i)
    capture_q <= 32'b0;
else
    capture_q <= resync_ms_q;

//-----------------------------------------------------------------
// Test mode
//-----------------------------------------------------------------
reg [31:0] test_count_q;

always @ (posedge input_clk_i )
if (input_rst_i)
    test_count_q <= 32'b0;
else if (clk_en_w)
    test_count_q <= test_count_q + 32'd1;

wire [31:0] capture_w = cfg_test_mode_w ? test_count_q : capture_q;

//-----------------------------------------------------------------
// Previous capture
//-----------------------------------------------------------------
reg [31:0] prev_q;

always @ (posedge input_clk_i )
if (input_rst_i)
    prev_q <= 32'b0;
else if (clk_en_w)
    prev_q <= capture_w;

wire same_w = (prev_q == capture_w);

reg prev_valid_q;

always @ (posedge input_clk_i )
if (input_rst_i)
    prev_valid_q <= 1'b0;
else if (clk_en_w)
    prev_valid_q <= 1'b1;

//-----------------------------------------------------------------
// RLE count
//-----------------------------------------------------------------
reg [15:0] rle_count_q;

wire overflow_w = cfg_32bit_w ? 1'b1 :
                  cfg_24bit_w ? (rle_count_q >= 16'hFF) : 
                                (rle_count_q == 16'hFFFF);

always @ (posedge input_clk_i )
if (input_rst_i)
    rle_count_q <= 16'd1;
else if (!clk_en_w)
    ;
else if (overflow_w || !same_w)
    rle_count_q <= 16'd1;
else
    rle_count_q <= rle_count_q + 16'd1;

//-----------------------------------------------------------------
// Output retime
//-----------------------------------------------------------------
reg        valid_q;
reg [31:0] data_q;

always @ (posedge input_clk_i )
if (input_rst_i)
    valid_q <= 1'b0;
else
    valid_q <= (!same_w || overflow_w) && prev_valid_q && clk_en_w;

always @ (posedge input_clk_i )
if (input_rst_i)
    data_q <= 32'b0;
else if (!clk_en_w)
    ;
else if (cfg_32bit_w)
    data_q <= prev_q;
else if (cfg_24bit_w)
    data_q <= {rle_count_q[7:0],  prev_q[23:0]};
else
    data_q <= {rle_count_q[15:0], prev_q[15:0]};

//-----------------------------------------------------------------
// Output
//-----------------------------------------------------------------
wire output_empty_w;

capture_rle_cdc
u_cdc
(
     .wr_clk_i(input_clk_i)
    ,.wr_rst_i(input_rst_i)
    ,.wr_push_i(valid_q)
    ,.wr_data_i(data_q)
    ,.wr_full_o()

    ,.rd_clk_i(clk_i)
    ,.rd_rst_i(rst_i)
    ,.rd_data_o(data_o)
    ,.rd_empty_o(output_empty_w)
    ,.rd_pop_i(1'b1)
);

assign valid_o = ~output_empty_w;



endmodule
