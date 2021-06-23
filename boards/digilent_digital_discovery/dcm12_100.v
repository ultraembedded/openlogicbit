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
module dcm12_100
(
    // Inputs
     input           clkref_i

    // Outputs
    ,output          clkout0_o
);

wire clkref_buffered_w;
wire clkfb;
wire clk0;
wire clkfx;

// Clocking primitive
DCM_SP
#(
    .CLKDV_DIVIDE(2.000),
    .CLKFX_DIVIDE(3),
    .CLKFX_MULTIPLY(25),
    .CLKIN_PERIOD(83.3333333333),
    .CLKOUT_PHASE_SHIFT("NONE"),
    .CLK_FEEDBACK("1X"),
    .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"),
    .PHASE_SHIFT(0)
)
dcm_sp_inst
(
    .CLKIN(clkref_i),
    .CLKFB(clkfb),
    // Output clocks
    .CLK0(clk0), // 100MHz
    .CLK90(),
    .CLK180(),
    .CLK270(),
    .CLK2X(),
    .CLK2X180(),
    .CLKFX(clkfx),
    .CLKFX180(),
    .CLKDV(),
    // Ports for dynamic phase shift
    .PSCLK(1'b0),
    .PSEN(1'b0),
    .PSINCDEC(1'b0),
    .PSDONE(),
    // Other control and status signals,
    .LOCKED(),
    .STATUS(),
    .RST(1'b0),
    // Unused pin, tie low
    .DSSEN(1'b0)
);

BUFG clkfb_buf
(
    .I(clk0),
    .O(clkfb)
);

//-----------------------------------------------------------------
// CLK_OUT0
//-----------------------------------------------------------------
BUFG clkout0_buf
(
    .I(clkfx),
    .O(clkout0_o)
);

endmodule
