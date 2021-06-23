//*****************************************************************************
// (c) Copyright 2009 - 2010 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: 3.7
//  \   \         Application: MIG
//  /   /         Filename: axi4_wrapper.v
// /___/   /\     Date Last Modified: $Date: 2011/06/07 13:57:01 $
// \   \  /  \    Date Created: Dec 16, 2010
//  \___\/\___\
//
//Device: Virtex-6, Spartan-6 and 7series
//Design Name: AXI4 Traffic Generator
//Purpose:
//   This module is wrapper for converting the reads and writes to transactions
//   that follow the AXI protocol.
//
//Reference:
//Revision History:
//*****************************************************************************

module s6_axi4_tg #(

// CONTROLLER 0 parameters
     parameter C_PORT_CONFIG           = "B32_B32_W32_R32_W32_R32",
     parameter C_P0_PORT_MODE          = "BI_MODE",
     parameter C_P1_PORT_MODE          = "BI_MODE",
     parameter C_P2_PORT_MODE          = "WR_MODE",
     parameter C_P3_PORT_MODE          = "RD_MODE",
     parameter C_P4_PORT_MODE          = "WR_MODE",
     parameter C_P5_PORT_MODE          = "RD_MODE",
     parameter C_PORT_ENABLE           = 6'b000000,
     parameter C_BEGIN_ADDRESS         = 32'h00000100,
     parameter C_END_ADDRESS           = 32'h000002ff,
     parameter C_PRBS_EADDR_MASK_POS   = 32'hfffffc00,
     parameter C_PRBS_SADDR_MASK_POS   = 32'h00000100,
     parameter C_EN_UPSIZER            = 0,
     parameter C_AXI_NBURST_SUPPORT    = 0, // Support for narrow burst transfers
                                            // 1-supported, 0-not supported 
     parameter C_ENFORCE_RD_WR         = 0,
     parameter C_ENFORCE_RD_WR_CMD     = 8'h11,
     parameter C_ENFORCE_RD_WR_PATTERN = 3'b000,
     parameter C_EN_WRAP_TRANS         = 0, // Set 1 to enable wrap transactions
// Controller 0, port 0 parameters
     parameter C_P0_AXI_SUPPORTS_READ  = 1,
     parameter C_P0_AXI_SUPPORTS_WRITE = 1,
     parameter C_P0_AXI_ID_WIDTH       = 4, // The AXI id width used for read and write
                                            // This is an integer between 1-16
     parameter C_P0_AXI_ADDR_WIDTH     = 32,// This is AXI address width for all 
                                            // SI and MI slots
     parameter C_P0_AXI_DATA_WIDTH     = 32,// Width of the AXI write and read data
// Controller 0, port 1 parameters
     parameter C_P1_AXI_SUPPORTS_READ  = 1,
     parameter C_P1_AXI_SUPPORTS_WRITE = 1,
     parameter C_P1_AXI_ID_WIDTH       = 4, // The AXI id width used for read and write
                                            // This is an integer between 1-16
     parameter C_P1_AXI_ADDR_WIDTH     = 32,// This is AXI address width for all 
                                            // SI and MI slots
     parameter C_P1_AXI_DATA_WIDTH     = 32,// Width of the AXI write and read data
// Controller 0, port 2 parameters
     parameter C_P2_AXI_SUPPORTS_READ  = 0,
     parameter C_P2_AXI_SUPPORTS_WRITE = 1,
     parameter C_P2_AXI_ID_WIDTH       = 4, // The AXI id width used for read and write
                                            // This is an integer between 1-16
     parameter C_P2_AXI_ADDR_WIDTH     = 32,// This is AXI address width for all 
                                            // SI and MI slots
     parameter C_P2_AXI_DATA_WIDTH     = 32,// Width of the AXI write and read data
// Controller 0, port 3 parameters
     parameter C_P3_AXI_SUPPORTS_READ  = 1,
     parameter C_P3_AXI_SUPPORTS_WRITE = 0,
     parameter C_P3_AXI_ID_WIDTH       = 4, // The AXI id width used for read and write
                                            // This is an integer between 1-16
     parameter C_P3_AXI_ADDR_WIDTH     = 32,// This is AXI address width for all 
                                            // SI and MI slots
     parameter C_P3_AXI_DATA_WIDTH     = 32,// Width of the AXI write and read data
// Controller 0, port 4 parameters
     parameter C_P4_AXI_SUPPORTS_READ  = 0,
     parameter C_P4_AXI_SUPPORTS_WRITE = 1,
     parameter C_P4_AXI_ID_WIDTH       = 4, // The AXI id width used for read and write
                                            // This is an integer between 1-16
     parameter C_P4_AXI_ADDR_WIDTH     = 32,// This is AXI address width for all 
                                            // SI and MI slots
     parameter C_P4_AXI_DATA_WIDTH     = 32,// Width of the AXI write and read data
// Controller 0, port 5 parameters
     parameter C_P5_AXI_SUPPORTS_READ  = 1,
     parameter C_P5_AXI_SUPPORTS_WRITE = 0,
     parameter C_P5_AXI_ID_WIDTH       = 4, // The AXI id width used for read and write
                                            // This is an integer between 1-16
     parameter C_P5_AXI_ADDR_WIDTH     = 32,// This is AXI address width for all 
                                            // SI and MI slots
     parameter C_P5_AXI_DATA_WIDTH     = 32,// Width of the AXI write and read data

// Common parameters
     parameter DBG_WR_STS_WIDTH        = 32,
     parameter DBG_RD_STS_WIDTH        = 32
)
(
   input                               aclk,    // AXI input clock for controller 0
   input                               aresetn, // Active low AXI reset signal for controller 0

// Input control signals
   input                               init_cmptd,  // Initialization completed
   input                               init_test,   // Initialize the test
   input                               wdog_mask,   // Mask the watchdog timeouts
   input                               wrap_en,     // Enable wrap transactions

// CONTROLLER 0 - interface signals
// PORT 0 - interface signals
// AXI write address channel signals (for port 0)
   input                               axi_wready_c_p0, // Write address ready
   output [C_P0_AXI_ID_WIDTH-1:0]      axi_wid_c_p0,    // Write ID
   output [C_P0_AXI_ADDR_WIDTH-1:0]    axi_waddr_c_p0,  // Write address
   output [7:0]                        axi_wlen_c_p0,   // Write Burst Length
   output [2:0]                        axi_wsize_c_p0,  // Write Burst size
   output [1:0]                        axi_wburst_c_p0, // Write Burst type
   output                              axi_wlock_c_p0,  // Write lock type
   output [3:0]                        axi_wcache_c_p0, // Write Cache type
   output [2:0]                        axi_wprot_c_p0,  // Write Protection type
   output                              axi_wvalid_c_p0, // Write address valid

// AXI write data channel signals (for port 0)
   input                               axi_wd_wready_c_p0,  // Write data ready
   output [C_P0_AXI_ID_WIDTH-1:0]      axi_wd_wid_c_p0,     // Write ID tag
   output [C_P0_AXI_DATA_WIDTH-1:0]    axi_wd_data_c_p0,    // Write data
   output [C_P0_AXI_DATA_WIDTH/8-1:0]  axi_wd_strb_c_p0,    // Write strobes
   output                              axi_wd_last_c_p0,    // Last write transaction   
   output                              axi_wd_valid_c_p0,   // Write valid

// AXI write response channel signals (for port 0)
   input  [C_P0_AXI_ID_WIDTH-1:0]      axi_wd_bid_c_p0,     // Response ID
   input  [1:0]                        axi_wd_bresp_c_p0,   // Write response
   input                               axi_wd_bvalid_c_p0,  // Write reponse valid
   output                              axi_wd_bready_c_p0,  // Response ready
  
// AXI read address channel signals (for port 0)
   input                               axi_rready_c_p0,     // Read address ready
   output [C_P0_AXI_ID_WIDTH-1:0]      axi_rid_c_p0,        // Read ID
   output [C_P0_AXI_ADDR_WIDTH-1:0]    axi_raddr_c_p0,      // Read address
   output [7:0]                        axi_rlen_c_p0,       // Read Burst Length
   output [2:0]                        axi_rsize_c_p0,      // Read Burst size
   output [1:0]                        axi_rburst_c_p0,     // Read Burst type
   output                              axi_rlock_c_p0,      // Read lock type
   output [3:0]                        axi_rcache_c_p0,     // Read Cache type
   output [2:0]                        axi_rprot_c_p0,      // Read Protection type
   output                              axi_rvalid_c_p0,     // Read address valid

// AXI read data channel signals (for port 0)   
   input  [C_P0_AXI_ID_WIDTH-1:0]      axi_rd_bid_c_p0,     // Response ID
   input  [1:0]                        axi_rd_rresp_c_p0,   // Read response
   input                               axi_rd_rvalid_c_p0,  // Read reponse valid
   input  [C_P0_AXI_DATA_WIDTH-1:0]    axi_rd_data_c_p0,    // Read data
   input                               axi_rd_last_c_p0,    // Read last
   output                              axi_rd_rready_c_p0,  // Read Response ready

// PORT 1 - interface signals
// AXI write address channel signals (for port 1)
   input                               axi_wready_c_p1, // Write address ready 
   output [C_P1_AXI_ID_WIDTH-1:0]      axi_wid_c_p1,    // Write ID
   output [C_P1_AXI_ADDR_WIDTH-1:0]    axi_waddr_c_p1,  // Write address
   output [7:0]                        axi_wlen_c_p1,   // Write Burst Length
   output [2:0]                        axi_wsize_c_p1,  // Write Burst size
   output [1:0]                        axi_wburst_c_p1, // Write Burst type
   output                              axi_wlock_c_p1,  // Write lock type
   output [3:0]                        axi_wcache_c_p1, // Write Cache type
   output [2:0]                        axi_wprot_c_p1,  // Write Protection type
   output                              axi_wvalid_c_p1, // Write address valid 

// AXI write data channel signals (for port 1)
   input                               axi_wd_wready_c_p1,  // Write data ready
   output [C_P1_AXI_ID_WIDTH-1:0]      axi_wd_wid_c_p1,     // Write ID tag
   output [C_P1_AXI_DATA_WIDTH-1:0]    axi_wd_data_c_p1,    // Write data
   output [C_P1_AXI_DATA_WIDTH/8-1:0]  axi_wd_strb_c_p1,    // Write strobes
   output                              axi_wd_last_c_p1,    // Last write transaction   
   output                              axi_wd_valid_c_p1,   // Write valid

// AXI write response channel signals (for port 1)
   input  [C_P1_AXI_ID_WIDTH-1:0]      axi_wd_bid_c_p1,     // Response ID
   input  [1:0]                        axi_wd_bresp_c_p1,   // Write response
   input                               axi_wd_bvalid_c_p1,  // Write reponse valid
   output                              axi_wd_bready_c_p1,  // Response ready
  
// AXI read address channel signals (for port 1)
   input                               axi_rready_c_p1,     // Read address ready
   output [C_P1_AXI_ID_WIDTH-1:0]      axi_rid_c_p1,        // Read ID
   output [C_P1_AXI_ADDR_WIDTH-1:0]    axi_raddr_c_p1,      // Read address
   output [7:0]                        axi_rlen_c_p1,       // Read Burst Length
   output [2:0]                        axi_rsize_c_p1,      // Read Burst size
   output [1:0]                        axi_rburst_c_p1,     // Read Burst type
   output                              axi_rlock_c_p1,      // Read lock type
   output [3:0]                        axi_rcache_c_p1,     // Read Cache type
   output [2:0]                        axi_rprot_c_p1,      // Read Protection type
   output                              axi_rvalid_c_p1,     // Read address valid

// AXI read data channel signals (for port 1)   
   input  [C_P1_AXI_ID_WIDTH-1:0]      axi_rd_bid_c_p1,     // Response ID
   input  [1:0]                        axi_rd_rresp_c_p1,   // Read response
   input                               axi_rd_rvalid_c_p1,  // Read reponse valid
   input  [C_P1_AXI_DATA_WIDTH-1:0]    axi_rd_data_c_p1,    // Read data
   input                               axi_rd_last_c_p1,    // Read last
   output                              axi_rd_rready_c_p1,  // Read Response ready

// PORT 2 - interface signals
// AXI write address channel signals (for port 2)
   input                               axi_wready_c_p2, // Write address ready 
   output [C_P2_AXI_ID_WIDTH-1:0]      axi_wid_c_p2,    // Write ID
   output [C_P2_AXI_ADDR_WIDTH-1:0]    axi_waddr_c_p2,  // Write address
   output [7:0]                        axi_wlen_c_p2,   // Write Burst Length
   output [2:0]                        axi_wsize_c_p2,  // Write Burst size
   output [1:0]                        axi_wburst_c_p2, // Write Burst type
   output                              axi_wlock_c_p2,  // Write lock type
   output [3:0]                        axi_wcache_c_p2, // Write Cache type
   output [2:0]                        axi_wprot_c_p2,  // Write Protection type
   output                              axi_wvalid_c_p2, // Write address valid 

// AXI write data channel signals (for port 2)
   input                               axi_wd_wready_c_p2,  // Write data ready
   output [C_P2_AXI_ID_WIDTH-1:0]      axi_wd_wid_c_p2,     // Write ID tag
   output [C_P2_AXI_DATA_WIDTH-1:0]    axi_wd_data_c_p2,    // Write data
   output [C_P2_AXI_DATA_WIDTH/8-1:0]  axi_wd_strb_c_p2,    // Write strobes
   output                              axi_wd_last_c_p2,    // Last write transaction   
   output                              axi_wd_valid_c_p2,   // Write valid

// AXI write response channel signals (for port 2)
   input  [C_P2_AXI_ID_WIDTH-1:0]      axi_wd_bid_c_p2,     // Response ID
   input  [1:0]                        axi_wd_bresp_c_p2,   // Write response
   input                               axi_wd_bvalid_c_p2,  // Write reponse valid
   output                              axi_wd_bready_c_p2,  // Response ready
  
// AXI read address channel signals (for port 2)
   input                               axi_rready_c_p2,     // Read address ready
   output [C_P2_AXI_ID_WIDTH-1:0]      axi_rid_c_p2,        // Read ID
   output [C_P2_AXI_ADDR_WIDTH-1:0]    axi_raddr_c_p2,      // Read address
   output [7:0]                        axi_rlen_c_p2,       // Read Burst Length
   output [2:0]                        axi_rsize_c_p2,      // Read Burst size
   output [1:0]                        axi_rburst_c_p2,     // Read Burst type
   output                              axi_rlock_c_p2,      // Read lock type
   output [3:0]                        axi_rcache_c_p2,     // Read Cache type
   output [2:0]                        axi_rprot_c_p2,      // Read Protection type
   output                              axi_rvalid_c_p2,     // Read address valid

// AXI read data channel signals (for port 2)   
   input  [C_P2_AXI_ID_WIDTH-1:0]      axi_rd_bid_c_p2,     // Response ID
   input  [1:0]                        axi_rd_rresp_c_p2,   // Read response
   input                               axi_rd_rvalid_c_p2,  // Read reponse valid
   input  [C_P2_AXI_DATA_WIDTH-1:0]    axi_rd_data_c_p2,    // Read data
   input                               axi_rd_last_c_p2,    // Read last
   output                              axi_rd_rready_c_p2,  // Read Response ready

// PORT 3 - interface signals
// AXI write address channel signals (for port 3)
   input                               axi_wready_c_p3, // Write address ready 
   output [C_P3_AXI_ID_WIDTH-1:0]      axi_wid_c_p3,    // Write ID
   output [C_P3_AXI_ADDR_WIDTH-1:0]    axi_waddr_c_p3,  // Write address
   output [7:0]                        axi_wlen_c_p3,   // Write Burst Length
   output [2:0]                        axi_wsize_c_p3,  // Write Burst size
   output [1:0]                        axi_wburst_c_p3, // Write Burst type
   output                              axi_wlock_c_p3,  // Write lock type
   output [3:0]                        axi_wcache_c_p3, // Write Cache type
   output [2:0]                        axi_wprot_c_p3,  // Write Protection type
   output                              axi_wvalid_c_p3, // Write address valid 

// AXI write data channel signals (for port 3)
   input                               axi_wd_wready_c_p3,  // Write data ready
   output [C_P3_AXI_ID_WIDTH-1:0]      axi_wd_wid_c_p3,     // Write ID tag
   output [C_P3_AXI_DATA_WIDTH-1:0]    axi_wd_data_c_p3,    // Write data
   output [C_P3_AXI_DATA_WIDTH/8-1:0]  axi_wd_strb_c_p3,    // Write strobes
   output                              axi_wd_last_c_p3,    // Last write transaction   
   output                              axi_wd_valid_c_p3,   // Write valid

// AXI write response channel signals (for port 3)
   input  [C_P3_AXI_ID_WIDTH-1:0]      axi_wd_bid_c_p3,     // Response ID
   input  [1:0]                        axi_wd_bresp_c_p3,   // Write response
   input                               axi_wd_bvalid_c_p3,  // Write reponse valid
   output                              axi_wd_bready_c_p3,  // Response ready
  
// AXI read address channel signals (for port 3)
   input                               axi_rready_c_p3,     // Read address ready
   output [C_P3_AXI_ID_WIDTH-1:0]      axi_rid_c_p3,        // Read ID
   output [C_P3_AXI_ADDR_WIDTH-1:0]    axi_raddr_c_p3,      // Read address
   output [7:0]                        axi_rlen_c_p3,       // Read Burst Length
   output [2:0]                        axi_rsize_c_p3,      // Read Burst size
   output [1:0]                        axi_rburst_c_p3,     // Read Burst type
   output                              axi_rlock_c_p3,      // Read lock type
   output [3:0]                        axi_rcache_c_p3,     // Read Cache type
   output [2:0]                        axi_rprot_c_p3,      // Read Protection type
   output                              axi_rvalid_c_p3,     // Read address valid

// AXI read data channel signals (for port 3)   
   input  [C_P3_AXI_ID_WIDTH-1:0]      axi_rd_bid_c_p3,     // Response ID
   input  [1:0]                        axi_rd_rresp_c_p3,   // Read response
   input                               axi_rd_rvalid_c_p3,  // Read reponse valid
   input  [C_P3_AXI_DATA_WIDTH-1:0]    axi_rd_data_c_p3,    // Read data
   input                               axi_rd_last_c_p3,    // Read last
   output                              axi_rd_rready_c_p3,  // Read Response ready

// PORT 4 - interface signals
// AXI write address channel signals (for port 4)
   input                               axi_wready_c_p4, // Write address ready 
   output [C_P4_AXI_ID_WIDTH-1:0]      axi_wid_c_p4,    // Write ID
   output [C_P4_AXI_ADDR_WIDTH-1:0]    axi_waddr_c_p4,  // Write address
   output [7:0]                        axi_wlen_c_p4,   // Write Burst Length
   output [2:0]                        axi_wsize_c_p4,  // Write Burst size
   output [1:0]                        axi_wburst_c_p4, // Write Burst type
   output                              axi_wlock_c_p4,  // Write lock type
   output [3:0]                        axi_wcache_c_p4, // Write Cache type
   output [2:0]                        axi_wprot_c_p4,  // Write Protection type
   output                              axi_wvalid_c_p4, // Write address valid 

// AXI write data channel signals (for port 4)
   input                               axi_wd_wready_c_p4,  // Write data ready
   output [C_P4_AXI_ID_WIDTH-1:0]      axi_wd_wid_c_p4,     // Write ID tag
   output [C_P4_AXI_DATA_WIDTH-1:0]    axi_wd_data_c_p4,    // Write data
   output [C_P4_AXI_DATA_WIDTH/8-1:0]  axi_wd_strb_c_p4,    // Write strobes
   output                              axi_wd_last_c_p4,    // Last write transaction   
   output                              axi_wd_valid_c_p4,   // Write valid

// AXI write response channel signals (for port 4)
   input  [C_P4_AXI_ID_WIDTH-1:0]      axi_wd_bid_c_p4,     // Response ID
   input  [1:0]                        axi_wd_bresp_c_p4,   // Write response
   input                               axi_wd_bvalid_c_p4,  // Write reponse valid
   output                              axi_wd_bready_c_p4,  // Response ready
  
// AXI read address channel signals (for port 4)
   input                               axi_rready_c_p4,     // Read address ready
   output [C_P4_AXI_ID_WIDTH-1:0]      axi_rid_c_p4,        // Read ID
   output [C_P4_AXI_ADDR_WIDTH-1:0]    axi_raddr_c_p4,      // Read address
   output [7:0]                        axi_rlen_c_p4,       // Read Burst Length
   output [2:0]                        axi_rsize_c_p4,      // Read Burst size
   output [1:0]                        axi_rburst_c_p4,     // Read Burst type
   output                              axi_rlock_c_p4,      // Read lock type
   output [3:0]                        axi_rcache_c_p4,     // Read Cache type
   output [2:0]                        axi_rprot_c_p4,      // Read Protection type
   output                              axi_rvalid_c_p4,     // Read address valid

// AXI read data channel signals (for port 4)   
   input  [C_P4_AXI_ID_WIDTH-1:0]      axi_rd_bid_c_p4,     // Response ID
   input  [1:0]                        axi_rd_rresp_c_p4,   // Read response
   input                               axi_rd_rvalid_c_p4,  // Read reponse valid
   input  [C_P4_AXI_DATA_WIDTH-1:0]    axi_rd_data_c_p4,    // Read data
   input                               axi_rd_last_c_p4,    // Read last
   output                              axi_rd_rready_c_p4,  // Read Response ready

// PORT 5 - interface signals
// AXI write address channel signals (for port 5)
   input                               axi_wready_c_p5, // Write address ready 
   output [C_P5_AXI_ID_WIDTH-1:0]      axi_wid_c_p5,    // Write ID
   output [C_P5_AXI_ADDR_WIDTH-1:0]    axi_waddr_c_p5,  // Write address
   output [7:0]                        axi_wlen_c_p5,   // Write Burst Length
   output [2:0]                        axi_wsize_c_p5,  // Write Burst size
   output [1:0]                        axi_wburst_c_p5, // Write Burst type
   output                              axi_wlock_c_p5,  // Write lock type
   output [3:0]                        axi_wcache_c_p5, // Write Cache type
   output [2:0]                        axi_wprot_c_p5,  // Write Protection type
   output                              axi_wvalid_c_p5, // Write address valid 

// AXI write data channel signals (for port 5)
   input                               axi_wd_wready_c_p5,  // Write data ready
   output [C_P5_AXI_ID_WIDTH-1:0]      axi_wd_wid_c_p5,     // Write ID tag
   output [C_P5_AXI_DATA_WIDTH-1:0]    axi_wd_data_c_p5,    // Write data
   output [C_P5_AXI_DATA_WIDTH/8-1:0]  axi_wd_strb_c_p5,    // Write strobes
   output                              axi_wd_last_c_p5,    // Last write transaction   
   output                              axi_wd_valid_c_p5,   // Write valid

// AXI write response channel signals (for port 5)
   input  [C_P5_AXI_ID_WIDTH-1:0]      axi_wd_bid_c_p5,     // Response ID
   input  [1:0]                        axi_wd_bresp_c_p5,   // Write response
   input                               axi_wd_bvalid_c_p5,  // Write reponse valid
   output                              axi_wd_bready_c_p5,  // Response ready
  
// AXI read address channel signals (for port 5)
   input                               axi_rready_c_p5,     // Read address ready
   output [C_P5_AXI_ID_WIDTH-1:0]      axi_rid_c_p5,        // Read ID
   output [C_P5_AXI_ADDR_WIDTH-1:0]    axi_raddr_c_p5,      // Read address
   output [7:0]                        axi_rlen_c_p5,       // Read Burst Length
   output [2:0]                        axi_rsize_c_p5,      // Read Burst size
   output [1:0]                        axi_rburst_c_p5,     // Read Burst type
   output                              axi_rlock_c_p5,      // Read lock type
   output [3:0]                        axi_rcache_c_p5,     // Read Cache type
   output [2:0]                        axi_rprot_c_p5,      // Read Protection type
   output                              axi_rvalid_c_p5,     // Read address valid

// AXI read data channel signals (for port 5)   
   input  [C_P5_AXI_ID_WIDTH-1:0]      axi_rd_bid_c_p5,     // Response ID
   input  [1:0]                        axi_rd_rresp_c_p5,   // Read response
   input                               axi_rd_rvalid_c_p5,  // Read reponse valid
   input  [C_P5_AXI_DATA_WIDTH-1:0]    axi_rd_data_c_p5,    // Read data
   input                               axi_rd_last_c_p5,    // Read last
   output                              axi_rd_rready_c_p5,  // Read Response ready

// Error status signals
   output                              cmd_err,          // Error during command phase
   output                              data_msmatch_err, // Data mismatch
   output                              write_err,        // Write error occured
   output                              read_err,         // Read error occured
   output                              test_cmptd,       // Data pattern test completed
   output                              cmptd_one_wr_rd,  // Completed atleast one write
                                                         // and read

// Debug status signals
   output                              dbg_wr_sts_vld, // Write debug status valid,
   output [DBG_WR_STS_WIDTH-1:0]       dbg_wr_sts,     // Write status
   output                              dbg_rd_sts_vld, // Read debug status valid
   output [DBG_RD_STS_WIDTH-1:0]       dbg_rd_sts      // Read status
);

//*****************************************************************************
// Local Parameter declarations
//*****************************************************************************

  localparam C_AXI_ID_WIDTH           = 4;
  localparam C_AXI_ADDR_WIDTH         = 32;
  localparam C_AXI_DATA_WIDTH         = (C_PORT_CONFIG == "B64_B32_B32") ? 32 : (C_PORT_ENABLE[0] ? 
                                         C_P0_AXI_DATA_WIDTH : (C_PORT_ENABLE[1] ? C_P1_AXI_DATA_WIDTH :
                                         (C_PORT_ENABLE[2] ? C_P2_AXI_DATA_WIDTH : (C_PORT_ENABLE[3] ?
                                         C_P3_AXI_DATA_WIDTH : (C_PORT_ENABLE[4] ? C_P4_AXI_DATA_WIDTH :
                                         C_P5_AXI_DATA_WIDTH)))));
  localparam P0_WRITE                 = ((C_P0_AXI_SUPPORTS_WRITE == 1) && (C_PORT_ENABLE[0] == 1'b1)) ? 1'b1 : 1'b0;
  localparam P1_WRITE                 = ((C_P1_AXI_SUPPORTS_WRITE == 1) && (C_PORT_ENABLE[1] == 1'b1)) ? 1'b1 : 1'b0;
  localparam P2_WRITE                 = ((C_P2_AXI_SUPPORTS_WRITE == 1) && (C_PORT_ENABLE[2] == 1'b1)) ? 1'b1 : 1'b0;
  localparam P3_WRITE                 = ((C_P3_AXI_SUPPORTS_WRITE == 1) && (C_PORT_ENABLE[3] == 1'b1)) ? 1'b1 : 1'b0;
  localparam P4_WRITE                 = ((C_P4_AXI_SUPPORTS_WRITE == 1) && (C_PORT_ENABLE[4] == 1'b1)) ? 1'b1 : 1'b0;
  localparam P5_WRITE                 = ((C_P5_AXI_SUPPORTS_WRITE == 1) && (C_PORT_ENABLE[5] == 1'b1)) ? 1'b1 : 1'b0;
  localparam P0_READ                  = ((C_P0_AXI_SUPPORTS_READ == 1) && (C_PORT_ENABLE[0] == 1'b1)) ? 1'b1 : 1'b0;
  localparam P1_READ                  = ((C_P1_AXI_SUPPORTS_READ == 1) && (C_PORT_ENABLE[1] == 1'b1)) ? 1'b1 : 1'b0;
  localparam P2_READ                  = ((C_P2_AXI_SUPPORTS_READ == 1) && (C_PORT_ENABLE[2] == 1'b1)) ? 1'b1 : 1'b0;
  localparam P3_READ                  = ((C_P3_AXI_SUPPORTS_READ == 1) && (C_PORT_ENABLE[3] == 1'b1)) ? 1'b1 : 1'b0;
  localparam P4_READ                  = ((C_P4_AXI_SUPPORTS_READ == 1) && (C_PORT_ENABLE[4] == 1'b1)) ? 1'b1 : 1'b0;
  localparam P5_READ                  = ((C_P5_AXI_SUPPORTS_READ == 1) && (C_PORT_ENABLE[5] == 1'b1)) ? 1'b1 : 1'b0;
  localparam ENFORCE_RD_WR            = (C_EN_UPSIZER == 0 && C_PORT_CONFIG == "B64_B32_B32") ? 1'b1 : C_ENFORCE_RD_WR;
  localparam ENFORCE_RD_WR_CMD        = (C_EN_UPSIZER == 0 && C_PORT_CONFIG == "B64_B32_B32") ? 8'h55 : C_ENFORCE_RD_WR_CMD;
  localparam ENFORCE_RD_WR_PATTERN    = (C_EN_UPSIZER == 0 && C_PORT_CONFIG == "B64_B32_B32") ? 3'b001 : C_ENFORCE_RD_WR_PATTERN;

//*****************************************************************************
// Internal register and wire declarations
//*****************************************************************************

  wire [C_AXI_ID_WIDTH-1:0]            axi_wid;    // Write ID
  wire [C_AXI_ADDR_WIDTH-1:0]          axi_waddr;  // Write address
  wire [7:0]                           axi_wlen;   // Write Burst Length
  wire [2:0]                           axi_wsize;  // Write Burst size
  wire [1:0]                           axi_wburst; // Write Burst type
  wire [1:0]                           axi_wlock;  // Write lock type
  wire [3:0]                           axi_wcache; // Write Cache type
  wire [2:0]                           axi_wprot;  // Write Protection type

  wire [C_AXI_ID_WIDTH-1:0]            axi_wd_wid;  // Write ID tag
  wire [C_AXI_DATA_WIDTH-1:0]          axi_wd_data; // Write data
  wire [C_AXI_DATA_WIDTH/8-1:0]        axi_wd_strb; // Write strobes
  wire                                 axi_wd_last; // Last write transaction   
  
  reg                                  axi_wready;
  wire                                 axi_wvalid;
  reg                                  axi_wd_wready;
  wire                                 axi_wd_valid;
  reg  [C_AXI_ID_WIDTH-1:0]            axi_wd_bid;
  reg  [1:0]                           axi_wd_bresp;
  reg                                  axi_wd_bvalid;
  wire                                 axi_wd_bready;
  reg                                  axi_rready;
  wire [C_AXI_ID_WIDTH-1:0]            axi_rid;
  wire [C_AXI_ADDR_WIDTH-1:0]          axi_raddr;
  wire [7:0]                           axi_rlen;
  wire [2:0]                           axi_rsize;
  wire [1:0]                           axi_rburst;
  wire [1:0]                           axi_rlock;
  wire [3:0]                           axi_rcache;
  wire [2:0]                           axi_rprot;
  wire                                 axi_rvalid;
  reg  [C_AXI_ID_WIDTH-1:0]            axi_rd_bid;
  reg  [1:0]                           axi_rd_rresp;
  reg                                  axi_rd_rvalid;
  reg  [C_AXI_DATA_WIDTH-1:0]          axi_rd_data;
  reg                                  axi_rd_last;
  wire                                 axi_rd_rready;
  wire [2:0]                           write_ports [0:5];
  wire [2:0]                           read_ports [0:5];
  reg  [2:0]                           read_cntr;
  reg  [2:0]                           write_cntr;
  wire [2:0]                           wr_port_sel;
  wire [2:0]                           rd_port_sel;
  wire                                 write_cmptd;
  wire                                 read_cmptd;
  wire                                 cmptd_cycle;
  wire [31:0]                          axi_rd_data_c_p0_mux;
  reg                                  axi_rd_data_c_p0_mux_sel;
  reg                                  axi_wburst_c_p0_mux_sel;

//*****************************************************************************
// Combinatorial Logic
//*****************************************************************************

  generate 
    begin : wid_widths
      if (C_P0_AXI_ID_WIDTH <= 4) begin
        assign axi_wid_c_p0 = axi_wid[C_P0_AXI_ID_WIDTH-1:0]; 
        assign axi_wd_wid_c_p0 = axi_wd_wid[C_P0_AXI_ID_WIDTH-1:0];
        assign axi_rid_c_p0 = axi_rid[C_P0_AXI_ID_WIDTH-1:0];
      end
      else begin
        assign axi_wid_c_p0 = {{{C_P0_AXI_ID_WIDTH-4}{1'b0}}, axi_wid};  
        assign axi_wd_wid_c_p0 = {{{C_P0_AXI_ID_WIDTH-4}{1'b0}}, axi_wd_wid};
        assign axi_rid_c_p0 = {{{C_P0_AXI_ID_WIDTH-4}{1'b0}}, axi_rid};
      end
      if (C_P1_AXI_ID_WIDTH <= 4) begin
        assign axi_wid_c_p1 = axi_wid[C_P1_AXI_ID_WIDTH-1:0];
        assign axi_wd_wid_c_p1 = axi_wd_wid[C_P1_AXI_ID_WIDTH-1:0]; 
        assign axi_rid_c_p1 = axi_rid[C_P1_AXI_ID_WIDTH-1:0];
      end
      else begin
        assign axi_wid_c_p1 = {{{C_P1_AXI_ID_WIDTH-4}{1'b0}}, axi_wid};  
        assign axi_wd_wid_c_p1 = {{{C_P1_AXI_ID_WIDTH-4}{1'b0}}, axi_wd_wid};
        assign axi_rid_c_p1 = {{{C_P1_AXI_ID_WIDTH-4}{1'b0}}, axi_rid};
      end
      if (C_P2_AXI_ID_WIDTH <= 4) begin
        assign axi_wid_c_p2 = axi_wid[C_P2_AXI_ID_WIDTH-1:0];
        assign axi_wd_wid_c_p2 = axi_wd_wid[C_P2_AXI_ID_WIDTH-1:0];
        assign axi_rid_c_p2 = axi_rid[C_P2_AXI_ID_WIDTH-1:0];
      end
      else begin
        assign axi_wid_c_p2 = {{{C_P2_AXI_ID_WIDTH-4}{1'b0}}, axi_wid};  
        assign axi_wd_wid_c_p2 = {{{C_P2_AXI_ID_WIDTH-4}{1'b0}}, axi_wd_wid};
        assign axi_rid_c_p2 = {{{C_P2_AXI_ID_WIDTH-4}{1'b0}}, axi_rid};
      end
      if (C_P3_AXI_ID_WIDTH <= 4) begin
        assign axi_wid_c_p3 = axi_wid[C_P3_AXI_ID_WIDTH-1:0];
        assign axi_wd_wid_c_p3 = axi_wd_wid[C_P3_AXI_ID_WIDTH-1:0];
        assign axi_rid_c_p3 = axi_rid[C_P3_AXI_ID_WIDTH-1:0];
      end
      else begin
        assign axi_wid_c_p3 = {{{C_P3_AXI_ID_WIDTH-4}{1'b0}}, axi_wid};  
        assign axi_wd_wid_c_p3 = {{{C_P3_AXI_ID_WIDTH-4}{1'b0}}, axi_wd_wid};
        assign axi_rid_c_p3 = {{{C_P3_AXI_ID_WIDTH-4}{1'b0}}, axi_rid};
      end
      if (C_P4_AXI_ID_WIDTH <= 4) begin
        assign axi_wid_c_p4 = axi_wid[C_P4_AXI_ID_WIDTH-1:0];
        assign axi_wd_wid_c_p4 = axi_wd_wid[C_P4_AXI_ID_WIDTH-1:0];
        assign axi_rid_c_p4 = axi_rid[C_P4_AXI_ID_WIDTH-1:0];
      end
      else begin
        assign axi_wid_c_p4 = {{{C_P4_AXI_ID_WIDTH-4}{1'b0}}, axi_wid};  
        assign axi_wd_wid_c_p4 = {{{C_P4_AXI_ID_WIDTH-4}{1'b0}}, axi_wd_wid};
        assign axi_rid_c_p4 = {{{C_P4_AXI_ID_WIDTH-4}{1'b0}}, axi_rid};
      end
      if (C_P5_AXI_ID_WIDTH <= 4) begin
        assign axi_wid_c_p5 = axi_wid[C_P5_AXI_ID_WIDTH-1:0];
        assign axi_wd_wid_c_p5 = axi_wd_wid[C_P5_AXI_ID_WIDTH-1:0];
        assign axi_rid_c_p5 = axi_rid[C_P5_AXI_ID_WIDTH-1:0];
      end
      else begin
        assign axi_wid_c_p5 = {{{C_P5_AXI_ID_WIDTH-4}{1'b0}}, axi_wid};  
        assign axi_wd_wid_c_p5 = {{{C_P5_AXI_ID_WIDTH-4}{1'b0}}, axi_wd_wid};
        assign axi_rid_c_p5 = {{{C_P5_AXI_ID_WIDTH-4}{1'b0}}, axi_rid};
      end
    end
  endgenerate

  assign axi_waddr_c_p0 = axi_waddr;
  assign axi_waddr_c_p1 = axi_waddr;
  assign axi_waddr_c_p2 = axi_waddr;
  assign axi_waddr_c_p3 = axi_waddr;
  assign axi_waddr_c_p4 = axi_waddr;
  assign axi_waddr_c_p5 = axi_waddr;

  assign axi_wlen_c_p0  = axi_wlen;
  assign axi_wlen_c_p1  = axi_wlen;
  assign axi_wlen_c_p2  = axi_wlen;
  assign axi_wlen_c_p3  = axi_wlen;
  assign axi_wlen_c_p4  = axi_wlen;
  assign axi_wlen_c_p5  = axi_wlen;

  assign axi_wsize_c_p0 = ((C_PORT_CONFIG == "B64_B32_B32") && (P0_WRITE == 1'b1) && 
                           (C_EN_UPSIZER == 0)) ? (axi_wsize + 3'b001) : axi_wsize;
  assign axi_wsize_c_p1 = axi_wsize;
  assign axi_wsize_c_p2 = axi_wsize;
  assign axi_wsize_c_p3 = axi_wsize;
  assign axi_wsize_c_p4 = axi_wsize;
  assign axi_wsize_c_p5 = axi_wsize;

  assign axi_wburst_c_p0 = axi_wburst;
  assign axi_wburst_c_p1 = axi_wburst;
  assign axi_wburst_c_p2 = axi_wburst;
  assign axi_wburst_c_p3 = axi_wburst;
  assign axi_wburst_c_p4 = axi_wburst;
  assign axi_wburst_c_p5 = axi_wburst;

  assign axi_wlock_c_p0 = axi_wlock[0];
  assign axi_wlock_c_p1 = axi_wlock[0];
  assign axi_wlock_c_p2 = axi_wlock[0];
  assign axi_wlock_c_p3 = axi_wlock[0];
  assign axi_wlock_c_p4 = axi_wlock[0];
  assign axi_wlock_c_p5 = axi_wlock[0];

  assign axi_wcache_c_p0 = axi_wcache;
  assign axi_wcache_c_p1 = axi_wcache;
  assign axi_wcache_c_p2 = axi_wcache;
  assign axi_wcache_c_p3 = axi_wcache;
  assign axi_wcache_c_p4 = axi_wcache;
  assign axi_wcache_c_p5 = axi_wcache;

  assign axi_wprot_c_p0 = axi_wprot;
  assign axi_wprot_c_p1 = axi_wprot;
  assign axi_wprot_c_p2 = axi_wprot;
  assign axi_wprot_c_p3 = axi_wprot;
  assign axi_wprot_c_p4 = axi_wprot;
  assign axi_wprot_c_p5 = axi_wprot;


  assign axi_wd_data_c_p0 = (C_PORT_CONFIG == "B64_B32_B32") ? {axi_wd_data, axi_wd_data} : axi_wd_data;
  assign axi_wd_data_c_p1 = axi_wd_data;
  assign axi_wd_data_c_p2 = axi_wd_data;
  assign axi_wd_data_c_p3 = axi_wd_data;
  assign axi_wd_data_c_p4 = axi_wd_data;
  assign axi_wd_data_c_p5 = axi_wd_data;

  generate 
    if ((C_PORT_CONFIG == "B64_B32_B32") && (P0_WRITE == 1'b1)) begin : strobe_mux
      always @(posedge aclk)
        if (~aresetn)
          axi_wburst_c_p0_mux_sel <= 1'b0;
        else if (write_cmptd)
          axi_wburst_c_p0_mux_sel <= 1'b0;
        else if (axi_wd_valid_c_p0)
          axi_wburst_c_p0_mux_sel <= ~axi_wburst_c_p0_mux_sel;

    end
  endgenerate

  assign axi_wd_strb_c_p0 = ((C_PORT_CONFIG == "B64_B32_B32") && (P0_WRITE == 1'b1)) ? 
                              ((C_EN_UPSIZER == 1) ? {(axi_wd_strb & {4{axi_wburst_c_p0_mux_sel}}),
                                                     (axi_wd_strb & {4{~axi_wburst_c_p0_mux_sel}})} :
                                                    {axi_wd_strb, axi_wd_strb}) :
                                                    axi_wd_strb;
  assign axi_wd_strb_c_p1 = axi_wd_strb;
  assign axi_wd_strb_c_p2 = axi_wd_strb;
  assign axi_wd_strb_c_p3 = axi_wd_strb;
  assign axi_wd_strb_c_p4 = axi_wd_strb;
  assign axi_wd_strb_c_p5 = axi_wd_strb;

  assign axi_wd_last_c_p0 = axi_wd_last;
  assign axi_wd_last_c_p1 = axi_wd_last;
  assign axi_wd_last_c_p2 = axi_wd_last;
  assign axi_wd_last_c_p3 = axi_wd_last;
  assign axi_wd_last_c_p4 = axi_wd_last;
  assign axi_wd_last_c_p5 = axi_wd_last;

  // Select the write ports which will be used for AXI write transactions. If there
  // is only one write port enabled, the same will be used for all transactions
  assign write_ports[0] = (P0_WRITE ? 3'b000 : (P1_WRITE ? 3'b001 : (P2_WRITE ? 3'b010 :
                           (P3_WRITE ? 3'b011 : (P4_WRITE ? 3'b100 : 3'b101)))));    
  assign write_ports[1] = (P1_WRITE ? 3'b001 : (P5_WRITE ? 3'b101 : (P4_WRITE ? 3'b100 : 
                           (P3_WRITE ? 3'b011 : (P2_WRITE ? 3'b010 : 3'b000)))));    
  assign write_ports[2] = (P2_WRITE ? 3'b010 : (P0_WRITE ? 3'b000 : (P1_WRITE ? 3'b001 : 
                           (P3_WRITE ? 3'b011 : (P4_WRITE ? 3'b100 : 3'b101)))));    
  assign write_ports[3] = (P3_WRITE ? 3'b011 : (P5_WRITE ? 3'b101 : (P4_WRITE ? 3'b100 : 
                           (P2_WRITE ? 3'b010 : (P1_WRITE ? 3'b001 : 3'b000)))));    
  assign write_ports[4] = (P4_WRITE ? 3'b100 : (P0_WRITE ? 3'b000 : (P1_WRITE ? 3'b001 : 
                           (P2_WRITE ? 3'b010 : (P3_WRITE ? 3'b011 : 3'b101)))));    
  assign write_ports[5] = (P5_WRITE ? 3'b101 : (P4_WRITE ? 3'b100 : (P3_WRITE ? 3'b011 : 
                           (P2_WRITE ? 3'b010 : (P1_WRITE ? 3'b001 : 3'b000)))));    

  // Select the read ports which will be used for AXI read transactions. If there
  // is only one read port enabled, the same will be used for all transactions
  assign read_ports[0] = (P0_READ ? 3'b000 : (P1_READ ? 3'b001 : (P2_READ ? 3'b010 :
                          (P3_READ ? 3'b011 : (P4_READ ? 3'b100 : 3'b101)))));    
  assign read_ports[1] = (P1_READ ? 3'b001 : (P5_READ ? 3'b101 : (P4_READ ? 3'b100 : 
                          (P3_READ ? 3'b011 : (P2_READ ? 3'b010 : 3'b000)))));    
  assign read_ports[2] = (P2_READ ? 3'b010 : (P0_READ ? 3'b000 : (P1_READ ? 3'b001 : 
                          (P3_READ ? 3'b011 : (P4_READ ? 3'b100 : 3'b101)))));    
  assign read_ports[3] = (P3_READ ? 3'b011 : (P5_READ ? 3'b101 : (P4_READ ? 3'b100 : 
                          (P2_READ ? 3'b010 : (P1_READ ? 3'b001 : 3'b000)))));    
  assign read_ports[4] = (P4_READ ? 3'b100 : (P0_READ ? 3'b000 : (P1_READ ? 3'b001 : 
                          (P2_READ ? 3'b010 : (P3_READ ? 3'b011 : 3'b101)))));    
  assign read_ports[5] = (P5_READ ? 3'b101 : (P4_READ ? 3'b100 : (P3_READ ? 3'b011 : 
                          (P2_READ ? 3'b010 : (P1_READ ? 3'b001 : 3'b000)))));    

// Port select multiplexer 
  assign wr_port_sel = write_ports[write_cntr];
  assign rd_port_sel = read_ports[read_cntr];

// Mux for write data / address / control ports
  assign axi_wvalid_c_p0 = (wr_port_sel == 3'b000) ? axi_wvalid : 1'b0;
  assign axi_wd_valid_c_p0 = (wr_port_sel == 3'b000) ? axi_wd_valid : 1'b0;
  assign axi_wvalid_c_p1 = (wr_port_sel == 3'b001) ? axi_wvalid : 1'b0; 
  assign axi_wd_valid_c_p1 = (wr_port_sel == 3'b001) ? axi_wd_valid : 1'b0;
  assign axi_wvalid_c_p2 = (wr_port_sel == 3'b010) ? axi_wvalid : 1'b0; 
  assign axi_wd_valid_c_p2 = (wr_port_sel == 3'b010) ? axi_wd_valid : 1'b0;
  assign axi_wvalid_c_p3 = (wr_port_sel == 3'b011) ? axi_wvalid : 1'b0; 
  assign axi_wd_valid_c_p3 = (wr_port_sel == 3'b011) ? axi_wd_valid : 1'b0;
  assign axi_wvalid_c_p4 = (wr_port_sel == 3'b100) ? axi_wvalid : 1'b0; 
  assign axi_wd_valid_c_p4 = (wr_port_sel == 3'b100) ? axi_wd_valid : 1'b0;
  assign axi_wvalid_c_p5 = (wr_port_sel == 3'b101) ? axi_wvalid : 1'b0; 
  assign axi_wd_valid_c_p5 = (wr_port_sel == 3'b101) ? axi_wd_valid : 1'b0;

  always @(*) 
    case (wr_port_sel)
      3'b001 : begin 
                 axi_wready = axi_wready_c_p1; 
                 axi_wd_wready = axi_wd_wready_c_p1;
               end
      3'b010 : begin
                 axi_wready = axi_wready_c_p2; 
                 axi_wd_wready = axi_wd_wready_c_p2;
               end
      3'b011 : begin
                 axi_wready = axi_wready_c_p3; 
                 axi_wd_wready = axi_wd_wready_c_p3;
               end
      3'b100 : begin
                 axi_wready = axi_wready_c_p4; 
                 axi_wd_wready = axi_wd_wready_c_p4;
               end
      3'b101 : begin
                 axi_wready = axi_wready_c_p5; 
                 axi_wd_wready = axi_wd_wready_c_p5;
               end
      default : begin 
                  axi_wready = axi_wready_c_p0;
                  axi_wd_wready = axi_wd_wready_c_p0;
                end
    endcase

// Mux for write reponse ports
  assign axi_wd_bready_c_p0 = (wr_port_sel == 3'b000) ? axi_wd_bready : 1'b0;
  assign axi_wd_bready_c_p1 = (wr_port_sel == 3'b001) ? axi_wd_bready : 1'b0;
  assign axi_wd_bready_c_p2 = (wr_port_sel == 3'b010) ? axi_wd_bready : 1'b0;
  assign axi_wd_bready_c_p3 = (wr_port_sel == 3'b011) ? axi_wd_bready : 1'b0;
  assign axi_wd_bready_c_p4 = (wr_port_sel == 3'b100) ? axi_wd_bready : 1'b0;
  assign axi_wd_bready_c_p5 = (wr_port_sel == 3'b101) ? axi_wd_bready : 1'b0;

  always @(*)
    case (wr_port_sel)
      3'b001 : begin
                 axi_wd_bid = axi_wd_bid_c_p1;
                 axi_wd_bresp = axi_wd_bresp_c_p1;
                 axi_wd_bvalid = axi_wd_bvalid_c_p1;
               end 
      3'b010 : begin
                 axi_wd_bid = axi_wd_bid_c_p2;
                 axi_wd_bresp = axi_wd_bresp_c_p2;
                 axi_wd_bvalid = axi_wd_bvalid_c_p2;
               end
      3'b011 : begin
                 axi_wd_bid = axi_wd_bid_c_p3;
                 axi_wd_bresp = axi_wd_bresp_c_p3;
                 axi_wd_bvalid = axi_wd_bvalid_c_p3;
               end
      3'b100 : begin
                 axi_wd_bid = axi_wd_bid_c_p4;
                 axi_wd_bresp = axi_wd_bresp_c_p4;
                 axi_wd_bvalid = axi_wd_bvalid_c_p4;
               end
      3'b101 : begin
                 axi_wd_bid = axi_wd_bid_c_p5;
                 axi_wd_bresp = axi_wd_bresp_c_p5;
                 axi_wd_bvalid = axi_wd_bvalid_c_p5;
               end
      default : begin
                  axi_wd_bid = axi_wd_bid_c_p0;
                  axi_wd_bresp = axi_wd_bresp_c_p0;
                  axi_wd_bvalid = axi_wd_bvalid_c_p0;
                end
    endcase

// Mux for read address / control ports
  assign axi_rvalid_c_p0 = (rd_port_sel == 3'b000) ? axi_rvalid : 1'b0;
  assign axi_rvalid_c_p1 = (rd_port_sel == 3'b001) ? axi_rvalid : 1'b0;
  assign axi_rvalid_c_p2 = (rd_port_sel == 3'b010) ? axi_rvalid : 1'b0;
  assign axi_rvalid_c_p3 = (rd_port_sel == 3'b011) ? axi_rvalid : 1'b0;
  assign axi_rvalid_c_p4 = (rd_port_sel == 3'b100) ? axi_rvalid : 1'b0;
  assign axi_rvalid_c_p5 = (rd_port_sel == 3'b101) ? axi_rvalid : 1'b0;

  always @(*) 
    case (rd_port_sel)
      3'b001 : axi_rready = axi_rready_c_p1;
      3'b010 : axi_rready = axi_rready_c_p2;
      3'b011 : axi_rready = axi_rready_c_p3;
      3'b100 : axi_rready = axi_rready_c_p4;
      3'b101 : axi_rready = axi_rready_c_p5;
      default : axi_rready = axi_rready_c_p0;
    endcase 


   assign axi_raddr_c_p0 = axi_raddr;
   assign axi_raddr_c_p1 = axi_raddr;
   assign axi_raddr_c_p2 = axi_raddr;
   assign axi_raddr_c_p3 = axi_raddr;
   assign axi_raddr_c_p4 = axi_raddr;
   assign axi_raddr_c_p5 = axi_raddr;

   assign axi_rlen_c_p0 = axi_rlen;
   assign axi_rlen_c_p1 = axi_rlen;
   assign axi_rlen_c_p2 = axi_rlen;
   assign axi_rlen_c_p3 = axi_rlen;
   assign axi_rlen_c_p4 = axi_rlen;
   assign axi_rlen_c_p5 = axi_rlen;

   assign axi_rsize_c_p0 = ((C_PORT_CONFIG == "B64_B32_B32") && (P0_READ == 1'b1) && 
                            (C_EN_UPSIZER == 0)) ? (axi_rsize + 3'b001) : axi_rsize;
   assign axi_rsize_c_p1 = axi_rsize;
   assign axi_rsize_c_p2 = axi_rsize;
   assign axi_rsize_c_p3 = axi_rsize;
   assign axi_rsize_c_p4 = axi_rsize;
   assign axi_rsize_c_p5 = axi_rsize;

   assign axi_rburst_c_p0 = axi_rburst;
   assign axi_rburst_c_p1 = axi_rburst;
   assign axi_rburst_c_p2 = axi_rburst;
   assign axi_rburst_c_p3 = axi_rburst;
   assign axi_rburst_c_p4 = axi_rburst;
   assign axi_rburst_c_p5 = axi_rburst;

   assign axi_rlock_c_p0 = axi_rlock[0];
   assign axi_rlock_c_p1 = axi_rlock[0];
   assign axi_rlock_c_p2 = axi_rlock[0];
   assign axi_rlock_c_p3 = axi_rlock[0];
   assign axi_rlock_c_p4 = axi_rlock[0];
   assign axi_rlock_c_p5 = axi_rlock[0];

   assign axi_rcache_c_p0 = axi_rcache;
   assign axi_rcache_c_p1 = axi_rcache;
   assign axi_rcache_c_p2 = axi_rcache;
   assign axi_rcache_c_p3 = axi_rcache;
   assign axi_rcache_c_p4 = axi_rcache;
   assign axi_rcache_c_p5 = axi_rcache;

   assign axi_rprot_c_p0 = axi_rprot;
   assign axi_rprot_c_p1 = axi_rprot;
   assign axi_rprot_c_p2 = axi_rprot;
   assign axi_rprot_c_p3 = axi_rprot;
   assign axi_rprot_c_p4 = axi_rprot;
   assign axi_rprot_c_p5 = axi_rprot;

// Mux for read data ports
  assign axi_rd_rready_c_p0 = (rd_port_sel == 3'b000) ? axi_rd_rready : 1'b0;
  assign axi_rd_rready_c_p1 = (rd_port_sel == 3'b001) ? axi_rd_rready : 1'b0;
  assign axi_rd_rready_c_p2 = (rd_port_sel == 3'b010) ? axi_rd_rready : 1'b0;
  assign axi_rd_rready_c_p3 = (rd_port_sel == 3'b011) ? axi_rd_rready : 1'b0;
  assign axi_rd_rready_c_p4 = (rd_port_sel == 3'b100) ? axi_rd_rready : 1'b0;
  assign axi_rd_rready_c_p5 = (rd_port_sel == 3'b101) ? axi_rd_rready : 1'b0;

// Read data re-alignment for B64_B32_B32 configuration when port 0 is selected
  generate 
    if ((C_PORT_CONFIG == "B64_B32_B32") && (P0_READ == 1'b1)) begin : data_mux
      always @(posedge aclk)
        if (~aresetn)
          axi_rd_data_c_p0_mux_sel <= 1'b0;
        else if (read_cmptd)
          axi_rd_data_c_p0_mux_sel <= 1'b0;
        else if (axi_rd_rvalid_c_p0)
          axi_rd_data_c_p0_mux_sel <= ~axi_rd_data_c_p0_mux_sel;

      assign axi_rd_data_c_p0_mux = axi_rd_data_c_p0_mux_sel ? axi_rd_data_c_p0[63:32] :
                                                               axi_rd_data_c_p0[31:0];
    end
  endgenerate 

  always @(*) 
    case (rd_port_sel)
      3'b001 : begin 
                 axi_rd_bid = axi_rd_bid_c_p1;
                 axi_rd_rresp = axi_rd_rresp_c_p1;
                 axi_rd_rvalid = axi_rd_rvalid_c_p1;
                 axi_rd_data = axi_rd_data_c_p1;
                 axi_rd_last = axi_rd_last_c_p1;
               end
      3'b010 : begin 
                 axi_rd_bid = axi_rd_bid_c_p2;
                 axi_rd_rresp = axi_rd_rresp_c_p2;
                 axi_rd_rvalid = axi_rd_rvalid_c_p2;
                 axi_rd_data = axi_rd_data_c_p2;
                 axi_rd_last = axi_rd_last_c_p2;
               end
      3'b011 : begin 
                 axi_rd_bid = axi_rd_bid_c_p3;
                 axi_rd_rresp = axi_rd_rresp_c_p3;
                 axi_rd_rvalid = axi_rd_rvalid_c_p3;
                 axi_rd_data = axi_rd_data_c_p3;
                 axi_rd_last = axi_rd_last_c_p3;
               end
      3'b100 : begin 
                 axi_rd_bid = axi_rd_bid_c_p4;
                 axi_rd_rresp = axi_rd_rresp_c_p4;
                 axi_rd_rvalid = axi_rd_rvalid_c_p4;
                 axi_rd_data = axi_rd_data_c_p4;
                 axi_rd_last = axi_rd_last_c_p4;
               end
      3'b101 : begin 
                 axi_rd_bid = axi_rd_bid_c_p5;
                 axi_rd_rresp = axi_rd_rresp_c_p5;
                 axi_rd_rvalid = axi_rd_rvalid_c_p5;
                 axi_rd_data = axi_rd_data_c_p5;
                 axi_rd_last = axi_rd_last_c_p5;
               end
      default : begin 
                  axi_rd_bid = axi_rd_bid_c_p0;
                  axi_rd_rresp = axi_rd_rresp_c_p0;
                  axi_rd_rvalid = axi_rd_rvalid_c_p0;
                  axi_rd_data = ((C_PORT_CONFIG == "B64_B32_B32") && (P0_READ == 1'b1)) ? 
                                                                   axi_rd_data_c_p0_mux :
                                                                   axi_rd_data_c_p0;
                  axi_rd_last = axi_rd_last_c_p0;
                end
    endcase

//*****************************************************************************
// Registered Logic
//*****************************************************************************

// Counter for write transactions
  always @(posedge aclk)
    if (~aresetn | (write_cntr == 3'b101 & write_cmptd) | 
        (C_EN_UPSIZER == 0 & C_PORT_CONFIG == "B64_B32_B32" & ((write_cmptd & 
         write_cntr == 3'b010) | cmptd_cycle)))
      write_cntr <= 3'b000;
    else if (write_cmptd)
      write_cntr <= write_cntr + 3'b001;

// Counter for read transactions
  always @(posedge aclk)
    if (~aresetn | (read_cntr == 3'b101 & read_cmptd) |
        (C_EN_UPSIZER == 0 & C_PORT_CONFIG == "B64_B32_B32" & ((read_cmptd & 
         read_cntr == 3'b010) | cmptd_cycle)))
      read_cntr <= 3'b000;
    else if (read_cmptd)
      read_cntr <= read_cntr + 3'b001;

//*****************************************************************************
// Instance of the AXI4 TG Master for controller
//*****************************************************************************
axi4_tg #(
    
     .C_AXI_ID_WIDTH                   (C_AXI_ID_WIDTH),         
     .C_AXI_ADDR_WIDTH                 (C_AXI_ADDR_WIDTH),
     .C_AXI_DATA_WIDTH                 (C_AXI_DATA_WIDTH),      
     .C_AXI_NBURST_SUPPORT             (0),   
     .C_EN_WRAP_TRANS                  (C_EN_WRAP_TRANS),      
     .C_BEGIN_ADDRESS                  (C_BEGIN_ADDRESS),     
     .C_END_ADDRESS                    (C_END_ADDRESS),     
     .EN_UPSIZER                       (C_EN_UPSIZER),
     .DBG_WR_STS_WIDTH                 (DBG_WR_STS_WIDTH),  
     .DBG_RD_STS_WIDTH                 (DBG_RD_STS_WIDTH),
     .ENFORCE_RD_WR                    (ENFORCE_RD_WR),  
     .ENFORCE_RD_WR_CMD                (ENFORCE_RD_WR_CMD),
     .ENFORCE_RD_WR_PATTERN            (ENFORCE_RD_WR_PATTERN)
  
) axi4_tg_c_inst
(
     .aclk                             (aclk),        // AXI input clock
     .aresetn                          (aresetn),     // Active low AXI reset signal

// Input control signals
     .init_cmptd                       (init_cmptd),  // Initialization completed
     .init_test                        (init_test),   // Initialize the test
     .wdog_mask                        (wdog_mask),   // Mask the watchdog timeouts
     .wrap_en                          (wrap_en),     // Enable wrap transactions

// AXI write address channel signals
     .axi_wready                       (axi_wready), // Indicates slave is ready to accept a 
     .axi_wid                          (axi_wid),    // Write ID
     .axi_waddr                        (axi_waddr),  // Write address
     .axi_wlen                         (axi_wlen),   // Write Burst Length
     .axi_wsize                        (axi_wsize),  // Write Burst size
     .axi_wburst                       (axi_wburst), // Write Burst type
     .axi_wlock                        (axi_wlock),  // Write lock type
     .axi_wcache                       (axi_wcache), // Write Cache type
     .axi_wprot                        (axi_wprot),  // Write Protection type
     .axi_wvalid                       (axi_wvalid), // Write address valid
  
// AXI write data channel signals
     .axi_wd_wready                    (axi_wd_wready), // Write data ready
     .axi_wd_wid                       (axi_wd_wid),    // Write ID tag
     .axi_wd_data                      (axi_wd_data),   // Write data
     .axi_wd_strb                      (axi_wd_strb),   // Write strobes
     .axi_wd_last                      (axi_wd_last),   // Last write transaction   
     .axi_wd_valid                     (axi_wd_valid),  // Write valid
  
// AXI write response channel signals
     .axi_wd_bid                       (axi_wd_bid),     // Response ID
     .axi_wd_bresp                     (axi_wd_bresp),   // Write response
     .axi_wd_bvalid                    (axi_wd_bvalid),  // Write reponse valid
     .axi_wd_bready                    (axi_wd_bready),  // Response ready
  
// AXI read address channel signals
     .axi_rready                       (axi_rready),     // Read address ready
     .axi_rid                          (axi_rid),        // Read ID
     .axi_raddr                        (axi_raddr),      // Read address
     .axi_rlen                         (axi_rlen),       // Read Burst Length
     .axi_rsize                        (axi_rsize),      // Read Burst size
     .axi_rburst                       (axi_rburst),     // Read Burst type
     .axi_rlock                        (axi_rlock),      // Read lock type
     .axi_rcache                       (axi_rcache),     // Read Cache type
     .axi_rprot                        (axi_rprot),      // Read Protection type
     .axi_rvalid                       (axi_rvalid),     // Read address valid
  
// AXI read data channel signals   
     .axi_rd_bid                       (axi_rd_bid),     // Response ID
     .axi_rd_rresp                     (axi_rd_rresp),   // Read response
     .axi_rd_rvalid                    (axi_rd_rvalid),  // Read reponse valid
     .axi_rd_data                      (axi_rd_data),    // Read data
     .axi_rd_last                      (axi_rd_last),    // Read last
     .axi_rd_rready                    (axi_rd_rready),  // Read Response ready

// Error status signals
     .cmd_err                          (cmd_err),   // Error during command phase
     .data_msmatch_err                 (data_msmatch_err), // Data mismatch
     .write_err                        (write_err), // Write error occured
     .read_err                         (read_err),  // Read error occured
     .test_cmptd                       (test_cmptd),// Data pattern test completed
     .write_cmptd                      (write_cmptd),
     .read_cmptd                       (read_cmptd),
     .cmptd_cycle                      (cmptd_cycle),
     .cmptd_one_wr_rd                  (cmptd_one_wr_rd),

// Debug status signals
     .dbg_wr_sts_vld                   (dbg_wr_sts_vld),// Write debug status valid,
     .dbg_wr_sts                       (dbg_wr_sts),    // Write status
     .dbg_rd_sts_vld                   (dbg_rd_sts_vld),// Read debug status valid
     .dbg_rd_sts                       (dbg_rd_sts)     // Read status
);

endmodule
