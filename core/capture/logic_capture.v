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
`include "logic_capture_defs.v"

//-----------------------------------------------------------------
// Module:  Logic Capture Peripheral
//-----------------------------------------------------------------
module logic_capture
(
    // Inputs
     input          clk_i
    ,input          rst_i
    ,input          cfg_awvalid_i
    ,input  [31:0]  cfg_awaddr_i
    ,input          cfg_wvalid_i
    ,input  [31:0]  cfg_wdata_i
    ,input  [3:0]   cfg_wstrb_i
    ,input          cfg_bready_i
    ,input          cfg_arvalid_i
    ,input  [31:0]  cfg_araddr_i
    ,input          cfg_rready_i
    ,input          input_valid_i
    ,input  [31:0]  input_data_i
    ,input          outport_tready_i
    ,input  [31:0]  buffer_current_i
    ,input          buffer_wrapped_i

    // Outputs
    ,output         cfg_awready_o
    ,output         cfg_wready_o
    ,output         cfg_bvalid_o
    ,output [1:0]   cfg_bresp_o
    ,output         cfg_arready_o
    ,output         cfg_rvalid_o
    ,output [31:0]  cfg_rdata_o
    ,output [1:0]   cfg_rresp_o
    ,output         outport_tvalid_o
    ,output [31:0]  outport_tdata_o
    ,output [3:0]   outport_tstrb_o
    ,output [3:0]   outport_tdest_o
    ,output         outport_tlast_o
    ,output [31:0]  buffer_base_o
    ,output [31:0]  buffer_end_o
    ,output         buffer_reset_o
    ,output         buffer_cont_o
    ,output         cfg_clk_src_ext_o
    ,output [3:0]   cfg_clk_div_o
    ,output [1:0]   cfg_width_o
    ,output         cfg_test_mode_o
    ,output         status_enabled_o
    ,output         status_triggered_o
    ,output         status_overflow_o
);

//-----------------------------------------------------------------
// Write address / data split
//-----------------------------------------------------------------
// Address but no data ready
reg awvalid_q;

// Data but no data ready
reg wvalid_q;

wire wr_cmd_accepted_w  = (cfg_awvalid_i && cfg_awready_o) || awvalid_q;
wire wr_data_accepted_w = (cfg_wvalid_i  && cfg_wready_o)  || wvalid_q;

always @ (posedge clk_i )
if (rst_i)
    awvalid_q <= 1'b0;
else if (cfg_awvalid_i && cfg_awready_o && !wr_data_accepted_w)
    awvalid_q <= 1'b1;
else if (wr_data_accepted_w)
    awvalid_q <= 1'b0;

always @ (posedge clk_i )
if (rst_i)
    wvalid_q <= 1'b0;
else if (cfg_wvalid_i && cfg_wready_o && !wr_cmd_accepted_w)
    wvalid_q <= 1'b1;
else if (wr_cmd_accepted_w)
    wvalid_q <= 1'b0;

//-----------------------------------------------------------------
// Capture address (for delayed data)
//-----------------------------------------------------------------
reg [7:0] wr_addr_q;

always @ (posedge clk_i )
if (rst_i)
    wr_addr_q <= 8'b0;
else if (cfg_awvalid_i && cfg_awready_o)
    wr_addr_q <= cfg_awaddr_i[7:0];

wire [7:0] wr_addr_w = awvalid_q ? wr_addr_q : cfg_awaddr_i[7:0];

//-----------------------------------------------------------------
// Retime write data
//-----------------------------------------------------------------
reg [31:0] wr_data_q;

always @ (posedge clk_i )
if (rst_i)
    wr_data_q <= 32'b0;
else if (cfg_wvalid_i && cfg_wready_o)
    wr_data_q <= cfg_wdata_i;

//-----------------------------------------------------------------
// Request Logic
//-----------------------------------------------------------------
wire read_en_w  = cfg_arvalid_i & cfg_arready_o;
wire write_en_w = wr_cmd_accepted_w && wr_data_accepted_w;

//-----------------------------------------------------------------
// Accept Logic
//-----------------------------------------------------------------
assign cfg_arready_o = ~cfg_rvalid_o;
assign cfg_awready_o = ~cfg_bvalid_o && ~cfg_arvalid_i && ~awvalid_q;
assign cfg_wready_o  = ~cfg_bvalid_o && ~cfg_arvalid_i && ~wvalid_q;


//-----------------------------------------------------------------
// Register la_buffer_cfg
//-----------------------------------------------------------------
reg la_buffer_cfg_wr_q;

always @ (posedge clk_i )
if (rst_i)
    la_buffer_cfg_wr_q <= 1'b0;
else if (write_en_w && (wr_addr_w[7:0] == `LA_BUFFER_CFG))
    la_buffer_cfg_wr_q <= 1'b1;
else
    la_buffer_cfg_wr_q <= 1'b0;

// la_buffer_cfg_cont [internal]
reg        la_buffer_cfg_cont_q;

always @ (posedge clk_i )
if (rst_i)
    la_buffer_cfg_cont_q <= 1'd`LA_BUFFER_CFG_CONT_DEFAULT;
else if (write_en_w && (wr_addr_w[7:0] == `LA_BUFFER_CFG))
    la_buffer_cfg_cont_q <= cfg_wdata_i[`LA_BUFFER_CFG_CONT_R];

wire        la_buffer_cfg_cont_out_w = la_buffer_cfg_cont_q;


// la_buffer_cfg_test_mode [internal]
reg        la_buffer_cfg_test_mode_q;

always @ (posedge clk_i )
if (rst_i)
    la_buffer_cfg_test_mode_q <= 1'd`LA_BUFFER_CFG_TEST_MODE_DEFAULT;
else if (write_en_w && (wr_addr_w[7:0] == `LA_BUFFER_CFG))
    la_buffer_cfg_test_mode_q <= cfg_wdata_i[`LA_BUFFER_CFG_TEST_MODE_R];

wire        la_buffer_cfg_test_mode_out_w = la_buffer_cfg_test_mode_q;


// la_buffer_cfg_width [internal]
reg [1:0]  la_buffer_cfg_width_q;

always @ (posedge clk_i )
if (rst_i)
    la_buffer_cfg_width_q <= 2'd`LA_BUFFER_CFG_WIDTH_DEFAULT;
else if (write_en_w && (wr_addr_w[7:0] == `LA_BUFFER_CFG))
    la_buffer_cfg_width_q <= cfg_wdata_i[`LA_BUFFER_CFG_WIDTH_R];

wire [1:0]  la_buffer_cfg_width_out_w = la_buffer_cfg_width_q;


// la_buffer_cfg_clk_div [internal]
reg [3:0]  la_buffer_cfg_clk_div_q;

always @ (posedge clk_i )
if (rst_i)
    la_buffer_cfg_clk_div_q <= 4'd`LA_BUFFER_CFG_CLK_DIV_DEFAULT;
else if (write_en_w && (wr_addr_w[7:0] == `LA_BUFFER_CFG))
    la_buffer_cfg_clk_div_q <= cfg_wdata_i[`LA_BUFFER_CFG_CLK_DIV_R];

wire [3:0]  la_buffer_cfg_clk_div_out_w = la_buffer_cfg_clk_div_q;


// la_buffer_cfg_clk_src [internal]
reg        la_buffer_cfg_clk_src_q;

always @ (posedge clk_i )
if (rst_i)
    la_buffer_cfg_clk_src_q <= 1'd`LA_BUFFER_CFG_CLK_SRC_DEFAULT;
else if (write_en_w && (wr_addr_w[7:0] == `LA_BUFFER_CFG))
    la_buffer_cfg_clk_src_q <= cfg_wdata_i[`LA_BUFFER_CFG_CLK_SRC_R];

wire        la_buffer_cfg_clk_src_out_w = la_buffer_cfg_clk_src_q;


// la_buffer_cfg_enabled [internal]
reg        la_buffer_cfg_enabled_q;

always @ (posedge clk_i )
if (rst_i)
    la_buffer_cfg_enabled_q <= 1'd`LA_BUFFER_CFG_ENABLED_DEFAULT;
else if (write_en_w && (wr_addr_w[7:0] == `LA_BUFFER_CFG))
    la_buffer_cfg_enabled_q <= cfg_wdata_i[`LA_BUFFER_CFG_ENABLED_R];

wire        la_buffer_cfg_enabled_out_w = la_buffer_cfg_enabled_q;


//-----------------------------------------------------------------
// Register la_buffer_sts
//-----------------------------------------------------------------
reg la_buffer_sts_wr_q;

always @ (posedge clk_i )
if (rst_i)
    la_buffer_sts_wr_q <= 1'b0;
else if (write_en_w && (wr_addr_w[7:0] == `LA_BUFFER_STS))
    la_buffer_sts_wr_q <= 1'b1;
else
    la_buffer_sts_wr_q <= 1'b0;





//-----------------------------------------------------------------
// Register la_buffer_base
//-----------------------------------------------------------------
reg la_buffer_base_wr_q;

always @ (posedge clk_i )
if (rst_i)
    la_buffer_base_wr_q <= 1'b0;
else if (write_en_w && (wr_addr_w[7:0] == `LA_BUFFER_BASE))
    la_buffer_base_wr_q <= 1'b1;
else
    la_buffer_base_wr_q <= 1'b0;

// la_buffer_base_addr [internal]
reg [31:0]  la_buffer_base_addr_q;

always @ (posedge clk_i )
if (rst_i)
    la_buffer_base_addr_q <= 32'd`LA_BUFFER_BASE_ADDR_DEFAULT;
else if (write_en_w && (wr_addr_w[7:0] == `LA_BUFFER_BASE))
    la_buffer_base_addr_q <= cfg_wdata_i[`LA_BUFFER_BASE_ADDR_R];

wire [31:0]  la_buffer_base_addr_out_w = la_buffer_base_addr_q;


//-----------------------------------------------------------------
// Register la_buffer_end
//-----------------------------------------------------------------
reg la_buffer_end_wr_q;

always @ (posedge clk_i )
if (rst_i)
    la_buffer_end_wr_q <= 1'b0;
else if (write_en_w && (wr_addr_w[7:0] == `LA_BUFFER_END))
    la_buffer_end_wr_q <= 1'b1;
else
    la_buffer_end_wr_q <= 1'b0;

// la_buffer_end_addr [internal]
reg [31:0]  la_buffer_end_addr_q;

always @ (posedge clk_i )
if (rst_i)
    la_buffer_end_addr_q <= 32'd`LA_BUFFER_END_ADDR_DEFAULT;
else if (write_en_w && (wr_addr_w[7:0] == `LA_BUFFER_END))
    la_buffer_end_addr_q <= cfg_wdata_i[`LA_BUFFER_END_ADDR_R];

wire [31:0]  la_buffer_end_addr_out_w = la_buffer_end_addr_q;


//-----------------------------------------------------------------
// Register la_buffer_current
//-----------------------------------------------------------------
reg la_buffer_current_wr_q;

always @ (posedge clk_i )
if (rst_i)
    la_buffer_current_wr_q <= 1'b0;
else if (write_en_w && (wr_addr_w[7:0] == `LA_BUFFER_CURRENT))
    la_buffer_current_wr_q <= 1'b1;
else
    la_buffer_current_wr_q <= 1'b0;


//-----------------------------------------------------------------
// Register la_buffer_samples
//-----------------------------------------------------------------
reg la_buffer_samples_wr_q;

always @ (posedge clk_i )
if (rst_i)
    la_buffer_samples_wr_q <= 1'b0;
else if (write_en_w && (wr_addr_w[7:0] == `LA_BUFFER_SAMPLES))
    la_buffer_samples_wr_q <= 1'b1;
else
    la_buffer_samples_wr_q <= 1'b0;


//-----------------------------------------------------------------
// Register la_buffer_trig_enable
//-----------------------------------------------------------------
reg la_buffer_trig_enable_wr_q;

always @ (posedge clk_i )
if (rst_i)
    la_buffer_trig_enable_wr_q <= 1'b0;
else if (write_en_w && (wr_addr_w[7:0] == `LA_BUFFER_TRIG_ENABLE))
    la_buffer_trig_enable_wr_q <= 1'b1;
else
    la_buffer_trig_enable_wr_q <= 1'b0;

// la_buffer_trig_enable_value [internal]
reg [31:0]  la_buffer_trig_enable_value_q;

always @ (posedge clk_i )
if (rst_i)
    la_buffer_trig_enable_value_q <= 32'd`LA_BUFFER_TRIG_ENABLE_VALUE_DEFAULT;
else if (write_en_w && (wr_addr_w[7:0] == `LA_BUFFER_TRIG_ENABLE))
    la_buffer_trig_enable_value_q <= cfg_wdata_i[`LA_BUFFER_TRIG_ENABLE_VALUE_R];

wire [31:0]  la_buffer_trig_enable_value_out_w = la_buffer_trig_enable_value_q;


//-----------------------------------------------------------------
// Register la_buffer_trig_sense
//-----------------------------------------------------------------
reg la_buffer_trig_sense_wr_q;

always @ (posedge clk_i )
if (rst_i)
    la_buffer_trig_sense_wr_q <= 1'b0;
else if (write_en_w && (wr_addr_w[7:0] == `LA_BUFFER_TRIG_SENSE))
    la_buffer_trig_sense_wr_q <= 1'b1;
else
    la_buffer_trig_sense_wr_q <= 1'b0;

// la_buffer_trig_sense_value [internal]
reg [31:0]  la_buffer_trig_sense_value_q;

always @ (posedge clk_i )
if (rst_i)
    la_buffer_trig_sense_value_q <= 32'd`LA_BUFFER_TRIG_SENSE_VALUE_DEFAULT;
else if (write_en_w && (wr_addr_w[7:0] == `LA_BUFFER_TRIG_SENSE))
    la_buffer_trig_sense_value_q <= cfg_wdata_i[`LA_BUFFER_TRIG_SENSE_VALUE_R];

wire [31:0]  la_buffer_trig_sense_value_out_w = la_buffer_trig_sense_value_q;


//-----------------------------------------------------------------
// Register la_buffer_trig_level
//-----------------------------------------------------------------
reg la_buffer_trig_level_wr_q;

always @ (posedge clk_i )
if (rst_i)
    la_buffer_trig_level_wr_q <= 1'b0;
else if (write_en_w && (wr_addr_w[7:0] == `LA_BUFFER_TRIG_LEVEL))
    la_buffer_trig_level_wr_q <= 1'b1;
else
    la_buffer_trig_level_wr_q <= 1'b0;

// la_buffer_trig_level_value [internal]
reg [31:0]  la_buffer_trig_level_value_q;

always @ (posedge clk_i )
if (rst_i)
    la_buffer_trig_level_value_q <= 32'd`LA_BUFFER_TRIG_LEVEL_VALUE_DEFAULT;
else if (write_en_w && (wr_addr_w[7:0] == `LA_BUFFER_TRIG_LEVEL))
    la_buffer_trig_level_value_q <= cfg_wdata_i[`LA_BUFFER_TRIG_LEVEL_VALUE_R];

wire [31:0]  la_buffer_trig_level_value_out_w = la_buffer_trig_level_value_q;


wire [5:0]  la_buffer_sts_num_channels_in_w;
wire        la_buffer_sts_data_loss_in_w;
wire        la_buffer_sts_wrapped_in_w;
wire        la_buffer_sts_trig_in_w;
wire [31:0]  la_buffer_current_addr_in_w;
wire [31:0]  la_buffer_samples_count_in_w;


//-----------------------------------------------------------------
// Read mux
//-----------------------------------------------------------------
reg [31:0] data_r;

always @ *
begin
    data_r = 32'b0;

    case (cfg_araddr_i[7:0])

    `LA_BUFFER_CFG:
    begin
        data_r[`LA_BUFFER_CFG_CONT_R] = la_buffer_cfg_cont_q;
        data_r[`LA_BUFFER_CFG_TEST_MODE_R] = la_buffer_cfg_test_mode_q;
        data_r[`LA_BUFFER_CFG_WIDTH_R] = la_buffer_cfg_width_q;
        data_r[`LA_BUFFER_CFG_CLK_DIV_R] = la_buffer_cfg_clk_div_q;
        data_r[`LA_BUFFER_CFG_CLK_SRC_R] = la_buffer_cfg_clk_src_q;
        data_r[`LA_BUFFER_CFG_ENABLED_R] = la_buffer_cfg_enabled_q;
    end
    `LA_BUFFER_STS:
    begin
        data_r[`LA_BUFFER_STS_NUM_CHANNELS_R] = la_buffer_sts_num_channels_in_w;
        data_r[`LA_BUFFER_STS_DATA_LOSS_R] = la_buffer_sts_data_loss_in_w;
        data_r[`LA_BUFFER_STS_WRAPPED_R] = la_buffer_sts_wrapped_in_w;
        data_r[`LA_BUFFER_STS_TRIG_R] = la_buffer_sts_trig_in_w;
    end
    `LA_BUFFER_BASE:
    begin
        data_r[`LA_BUFFER_BASE_ADDR_R] = la_buffer_base_addr_q;
    end
    `LA_BUFFER_END:
    begin
        data_r[`LA_BUFFER_END_ADDR_R] = la_buffer_end_addr_q;
    end
    `LA_BUFFER_CURRENT:
    begin
        data_r[`LA_BUFFER_CURRENT_ADDR_R] = la_buffer_current_addr_in_w;
    end
    `LA_BUFFER_SAMPLES:
    begin
        data_r[`LA_BUFFER_SAMPLES_COUNT_R] = la_buffer_samples_count_in_w;
    end
    `LA_BUFFER_TRIG_ENABLE:
    begin
        data_r[`LA_BUFFER_TRIG_ENABLE_VALUE_R] = la_buffer_trig_enable_value_q;
    end
    `LA_BUFFER_TRIG_SENSE:
    begin
        data_r[`LA_BUFFER_TRIG_SENSE_VALUE_R] = la_buffer_trig_sense_value_q;
    end
    `LA_BUFFER_TRIG_LEVEL:
    begin
        data_r[`LA_BUFFER_TRIG_LEVEL_VALUE_R] = la_buffer_trig_level_value_q;
    end
    default :
        data_r = 32'b0;
    endcase
end

//-----------------------------------------------------------------
// RVALID
//-----------------------------------------------------------------
reg rvalid_q;

always @ (posedge clk_i )
if (rst_i)
    rvalid_q <= 1'b0;
else if (read_en_w)
    rvalid_q <= 1'b1;
else if (cfg_rready_i)
    rvalid_q <= 1'b0;

assign cfg_rvalid_o = rvalid_q;

//-----------------------------------------------------------------
// Retime read response
//-----------------------------------------------------------------
reg [31:0] rd_data_q;

always @ (posedge clk_i )
if (rst_i)
    rd_data_q <= 32'b0;
else if (!cfg_rvalid_o || cfg_rready_i)
    rd_data_q <= data_r;

assign cfg_rdata_o = rd_data_q;
assign cfg_rresp_o = 2'b0;

//-----------------------------------------------------------------
// BVALID
//-----------------------------------------------------------------
reg bvalid_q;

always @ (posedge clk_i )
if (rst_i)
    bvalid_q <= 1'b0;
else if (write_en_w)
    bvalid_q <= 1'b1;
else if (cfg_bready_i)
    bvalid_q <= 1'b0;

assign cfg_bvalid_o = bvalid_q;
assign cfg_bresp_o  = 2'b0;



parameter NUM_CHANNELS  = 16;

localparam  WIDTH_16BIT = 2'd0;
localparam  WIDTH_24BIT = 2'd1;
localparam  WIDTH_32BIT = 2'd2;

//-----------------------------------------------------------------
// Enable detect
//-----------------------------------------------------------------
wire cfg_enabled_w     = la_buffer_cfg_enabled_out_w;
reg  cfg_enabled_q;

always @ (posedge clk_i )
if (rst_i)
    cfg_enabled_q <= 1'b0;
else
    cfg_enabled_q <= cfg_enabled_w;

wire cfg_enable_reset_w = !cfg_enabled_q & cfg_enabled_w;

//-----------------------------------------------------------------
// Triggering
//-----------------------------------------------------------------
reg [31:0] prev_q;

always @ (posedge clk_i )
if (rst_i)
    prev_q <= 32'b0;
else if (!cfg_enabled_w)
    prev_q <= la_buffer_trig_sense_value_out_w;
else if (input_valid_i)
    prev_q <= input_data_i;

integer i;
reg [31:0] trig_r;

always @ *
begin
    trig_r = 32'b0;

    if (input_valid_i)
    begin
        for (i=0;i<32;i=i+1)
        begin
            // Level sensitive
            if (la_buffer_trig_level_value_out_w[i])
            begin
                if (input_data_i[i] == la_buffer_trig_sense_value_out_w[i])
                    trig_r[i] = 1'b1;
            end
            // Edge sensitive (rising)
            else if (la_buffer_trig_sense_value_out_w[i])
            begin
                if (input_data_i[i] && !prev_q[i])
                    trig_r[i] = 1'b1;
            end
            // Edge sensitive (falling)
            else
            begin
                if (!input_data_i[i] && prev_q[i])
                    trig_r[i] = 1'b1;
            end
        end
    end

    // Combine with channel enable
    trig_r = trig_r & la_buffer_trig_enable_value_out_w;
end

wire trigger_hit_w      = (trig_r == la_buffer_trig_enable_value_out_w);
wire trigger_edge_any_w = |(la_buffer_trig_enable_value_out_w & ~la_buffer_trig_level_value_out_w);

reg triggered_q;

always @ (posedge clk_i )
if (rst_i)
    triggered_q <= 1'b0;
else if (cfg_enable_reset_w)
    triggered_q <= (la_buffer_trig_enable_value_out_w == 32'b0); // No triggers
else if (cfg_enabled_w && trigger_hit_w)
    triggered_q <= 1'b1;

//-----------------------------------------------------------------
// Data delay
//-----------------------------------------------------------------
reg [31:0] buffer_q;
reg        buffer_wr_q;

always @ (posedge clk_i )
if (rst_i)
    buffer_q <= 32'b0;
else
    buffer_q <= input_data_i;

always @ (posedge clk_i )
if (rst_i)
    buffer_wr_q <= 1'b0;
else
    buffer_wr_q <= input_valid_i;

//-----------------------------------------------------------------
// Sample FIFO - decouple sample capture from memory stalls
//-----------------------------------------------------------------
wire data_accept_w;

// Push on valid data, and push previous value on hitting an edge trigger
wire data_push_w = (buffer_wr_q & triggered_q) || 
                   (trigger_hit_w && trigger_edge_any_w && !triggered_q);

wire [31:0] data_in_w = (buffer_wr_q & triggered_q) ? buffer_q : prev_q;

logic_capture_fifo
u_fifo_data
(
     .clk_i(clk_i)
    ,.rst_i(rst_i)

    ,.push_i(data_push_w)
    ,.data_in_i(data_in_w)
    ,.accept_o(data_accept_w)

    ,.valid_o(outport_tvalid_o)
    ,.data_out_o(outport_tdata_o)
    ,.pop_i(outport_tready_i)
);

assign outport_tstrb_o  = 4'hF;
assign outport_tdest_o  = 4'b0;
assign outport_tlast_o  = 1'b0;

//-----------------------------------------------------------------
// Sample capture count
//-----------------------------------------------------------------
reg [31:0] samples_count_q;

always @ (posedge clk_i )
if (rst_i)
    samples_count_q <= 32'b0;
else if (cfg_enable_reset_w)
    samples_count_q <= 32'b0;
else if (outport_tvalid_o && outport_tready_i)
begin
    case (la_buffer_cfg_width_out_w)
    WIDTH_16BIT: samples_count_q <= samples_count_q + {16'b0, outport_tdata_o[31:16]};
    WIDTH_24BIT: samples_count_q <= samples_count_q + {24'b0, outport_tdata_o[31:24]};
    default:     samples_count_q <= samples_count_q + 32'd1;
    endcase
end

assign la_buffer_samples_count_in_w = samples_count_q;

//-----------------------------------------------------------------
// Write detection
//-----------------------------------------------------------------
reg write_detect_q;

always @ (posedge clk_i )
if (rst_i) 
    write_detect_q <= 1'b0;
else if (cfg_enable_reset_w)
    write_detect_q <= 1'b0;
else if (data_push_w)
    write_detect_q <= 1'b1;

assign la_buffer_sts_trig_in_w = write_detect_q;

assign la_buffer_sts_num_channels_in_w = NUM_CHANNELS[5:0];

//-----------------------------------------------------------------
// FIFO overflow detect
//-----------------------------------------------------------------
reg data_lost_q;

always @ (posedge clk_i )
if (rst_i) 
    data_lost_q <= 1'b0;
else if (cfg_enable_reset_w)
    data_lost_q <= 1'b0;
else if (data_push_w && !data_accept_w)
    data_lost_q <= 1'b1;

assign la_buffer_sts_data_loss_in_w = data_lost_q;

assign la_buffer_current_addr_in_w  = buffer_current_i;
assign buffer_base_o                = {la_buffer_base_addr_out_w[31:2], 2'b0};
assign buffer_end_o                 = {la_buffer_end_addr_out_w[31:2], 2'b0};
assign buffer_reset_o               = !cfg_enabled_w;
assign la_buffer_sts_wrapped_in_w   = buffer_wrapped_i;
assign buffer_cont_o                = la_buffer_cfg_cont_out_w;


assign status_enabled_o    = cfg_enabled_w;
assign status_triggered_o  = la_buffer_sts_trig_in_w;
assign status_overflow_o   = la_buffer_sts_data_loss_in_w;
assign cfg_clk_src_ext_o   = la_buffer_cfg_clk_src_out_w;
assign cfg_clk_div_o       = la_buffer_cfg_clk_div_out_w;
assign cfg_width_o         = la_buffer_cfg_width_out_w;
assign cfg_test_mode_o     = la_buffer_cfg_test_mode_out_w;

endmodule
