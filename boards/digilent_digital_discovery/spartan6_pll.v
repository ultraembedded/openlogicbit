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
module spartan6_pll
(
    // Inputs
     input           clkref_i

    // Outputs
    ,output          clkout0_o
);





wire clkref_buffered_w;
wire clkfbout_w;
wire pll_clkout0_w;
wire pll_clkout0_buffered_w;

// Input buffering
assign clkref_buffered_w = clkref_i;

// Clocking primitive
PLL_BASE
#(
    .BANDWIDTH          ("OPTIMIZED"),
    .CLK_FEEDBACK       ("CLKFBOUT"),
    .COMPENSATION       ("INTERNAL"),
    .DIVCLK_DIVIDE      (1),
    .CLKFBOUT_MULT      (13), // VCO=624MHz
    .CLKFBOUT_PHASE     (0.000),
    .CLKOUT0_DIVIDE     (2), // CLK0=312MHz
    .CLKOUT0_PHASE      (0.0),
    .CLKOUT0_DUTY_CYCLE (0.500),
    .CLKIN_PERIOD       (20.8333333333),
    .REF_JITTER         (0.010)
)
pll_base_inst
(
    .CLKFBOUT(clkfbout_w),
    .CLKOUT0(pll_clkout0_w),
    .CLKOUT1(),
    .CLKOUT2(),
    .CLKOUT3(),
    .CLKOUT4(),
    .CLKOUT5(),
    .RST(1'b0),
    .CLKFBIN(clkfbout_w),
    .CLKIN(clkref_buffered_w)
);

//-----------------------------------------------------------------
// CLK_OUT0
//-----------------------------------------------------------------
BUFG clkout0_buf
(
    .I(pll_clkout0_w),
    .O(pll_clkout0_buffered_w)
);

assign clkout0_o = pll_clkout0_buffered_w;




endmodule
