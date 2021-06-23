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
`define LA_BUFFER_CFG    8'h0

    `define LA_BUFFER_CFG_CONT      31
    `define LA_BUFFER_CFG_CONT_DEFAULT    0
    `define LA_BUFFER_CFG_CONT_B          31
    `define LA_BUFFER_CFG_CONT_T          31
    `define LA_BUFFER_CFG_CONT_W          1
    `define LA_BUFFER_CFG_CONT_R          31:31

    `define LA_BUFFER_CFG_TEST_MODE      8
    `define LA_BUFFER_CFG_TEST_MODE_DEFAULT    0
    `define LA_BUFFER_CFG_TEST_MODE_B          8
    `define LA_BUFFER_CFG_TEST_MODE_T          8
    `define LA_BUFFER_CFG_TEST_MODE_W          1
    `define LA_BUFFER_CFG_TEST_MODE_R          8:8

    `define LA_BUFFER_CFG_WIDTH_DEFAULT    0
    `define LA_BUFFER_CFG_WIDTH_B          6
    `define LA_BUFFER_CFG_WIDTH_T          7
    `define LA_BUFFER_CFG_WIDTH_W          2
    `define LA_BUFFER_CFG_WIDTH_R          7:6

    `define LA_BUFFER_CFG_CLK_DIV_DEFAULT    0
    `define LA_BUFFER_CFG_CLK_DIV_B          2
    `define LA_BUFFER_CFG_CLK_DIV_T          5
    `define LA_BUFFER_CFG_CLK_DIV_W          4
    `define LA_BUFFER_CFG_CLK_DIV_R          5:2

    `define LA_BUFFER_CFG_CLK_SRC      1
    `define LA_BUFFER_CFG_CLK_SRC_DEFAULT    0
    `define LA_BUFFER_CFG_CLK_SRC_B          1
    `define LA_BUFFER_CFG_CLK_SRC_T          1
    `define LA_BUFFER_CFG_CLK_SRC_W          1
    `define LA_BUFFER_CFG_CLK_SRC_R          1:1

    `define LA_BUFFER_CFG_ENABLED      0
    `define LA_BUFFER_CFG_ENABLED_DEFAULT    0
    `define LA_BUFFER_CFG_ENABLED_B          0
    `define LA_BUFFER_CFG_ENABLED_T          0
    `define LA_BUFFER_CFG_ENABLED_W          1
    `define LA_BUFFER_CFG_ENABLED_R          0:0

`define LA_BUFFER_STS    8'h4

    `define LA_BUFFER_STS_NUM_CHANNELS_DEFAULT    0
    `define LA_BUFFER_STS_NUM_CHANNELS_B          24
    `define LA_BUFFER_STS_NUM_CHANNELS_T          29
    `define LA_BUFFER_STS_NUM_CHANNELS_W          6
    `define LA_BUFFER_STS_NUM_CHANNELS_R          29:24

    `define LA_BUFFER_STS_DATA_LOSS      2
    `define LA_BUFFER_STS_DATA_LOSS_DEFAULT    0
    `define LA_BUFFER_STS_DATA_LOSS_B          2
    `define LA_BUFFER_STS_DATA_LOSS_T          2
    `define LA_BUFFER_STS_DATA_LOSS_W          1
    `define LA_BUFFER_STS_DATA_LOSS_R          2:2

    `define LA_BUFFER_STS_WRAPPED      1
    `define LA_BUFFER_STS_WRAPPED_DEFAULT    0
    `define LA_BUFFER_STS_WRAPPED_B          1
    `define LA_BUFFER_STS_WRAPPED_T          1
    `define LA_BUFFER_STS_WRAPPED_W          1
    `define LA_BUFFER_STS_WRAPPED_R          1:1

    `define LA_BUFFER_STS_TRIG      0
    `define LA_BUFFER_STS_TRIG_DEFAULT    0
    `define LA_BUFFER_STS_TRIG_B          0
    `define LA_BUFFER_STS_TRIG_T          0
    `define LA_BUFFER_STS_TRIG_W          1
    `define LA_BUFFER_STS_TRIG_R          0:0

`define LA_BUFFER_BASE    8'h8

    `define LA_BUFFER_BASE_ADDR_DEFAULT    0
    `define LA_BUFFER_BASE_ADDR_B          0
    `define LA_BUFFER_BASE_ADDR_T          31
    `define LA_BUFFER_BASE_ADDR_W          32
    `define LA_BUFFER_BASE_ADDR_R          31:0

`define LA_BUFFER_END    8'hc

    `define LA_BUFFER_END_ADDR_DEFAULT    33554432
    `define LA_BUFFER_END_ADDR_B          0
    `define LA_BUFFER_END_ADDR_T          31
    `define LA_BUFFER_END_ADDR_W          32
    `define LA_BUFFER_END_ADDR_R          31:0

`define LA_BUFFER_CURRENT    8'h10

    `define LA_BUFFER_CURRENT_ADDR_DEFAULT    0
    `define LA_BUFFER_CURRENT_ADDR_B          0
    `define LA_BUFFER_CURRENT_ADDR_T          31
    `define LA_BUFFER_CURRENT_ADDR_W          32
    `define LA_BUFFER_CURRENT_ADDR_R          31:0

`define LA_BUFFER_SAMPLES    8'h14

    `define LA_BUFFER_SAMPLES_COUNT_DEFAULT    0
    `define LA_BUFFER_SAMPLES_COUNT_B          0
    `define LA_BUFFER_SAMPLES_COUNT_T          31
    `define LA_BUFFER_SAMPLES_COUNT_W          32
    `define LA_BUFFER_SAMPLES_COUNT_R          31:0

`define LA_BUFFER_TRIG_ENABLE    8'h18

    `define LA_BUFFER_TRIG_ENABLE_VALUE_DEFAULT    0
    `define LA_BUFFER_TRIG_ENABLE_VALUE_B          0
    `define LA_BUFFER_TRIG_ENABLE_VALUE_T          31
    `define LA_BUFFER_TRIG_ENABLE_VALUE_W          32
    `define LA_BUFFER_TRIG_ENABLE_VALUE_R          31:0

`define LA_BUFFER_TRIG_SENSE    8'h1c

    `define LA_BUFFER_TRIG_SENSE_VALUE_DEFAULT    0
    `define LA_BUFFER_TRIG_SENSE_VALUE_B          0
    `define LA_BUFFER_TRIG_SENSE_VALUE_T          31
    `define LA_BUFFER_TRIG_SENSE_VALUE_W          32
    `define LA_BUFFER_TRIG_SENSE_VALUE_R          31:0

`define LA_BUFFER_TRIG_LEVEL    8'h20

    `define LA_BUFFER_TRIG_LEVEL_VALUE_DEFAULT    0
    `define LA_BUFFER_TRIG_LEVEL_VALUE_B          0
    `define LA_BUFFER_TRIG_LEVEL_VALUE_T          31
    `define LA_BUFFER_TRIG_LEVEL_VALUE_W          32
    `define LA_BUFFER_TRIG_LEVEL_VALUE_R          31:0

