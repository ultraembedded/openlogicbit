::****************************************************************************
:: (c) Copyright 2009 Xilinx, Inc. All rights reserved.
::
:: This file contains confidential and proprietary information
:: of Xilinx, Inc. and is protected under U.S. and
:: international copyright and other intellectual property
:: laws.
::
:: DISCLAIMER
:: This disclaimer is not a license and does not grant any
:: rights to the materials distributed herewith. Except as
:: otherwise provided in a valid license issued to you by
:: Xilinx, and to the maximum extent permitted by applicable
:: law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
:: WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
:: AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
:: BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
:: INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
:: (2) Xilinx shall not be liable (whether in contract or tort,
:: including negligence, or under any other theory of
:: liability) for any loss or damage of any kind or nature
:: related to, arising under or in connection with these
:: materials, including for any direct, or any indirect,
:: special, incidental, or consequential loss or damage
:: (including loss of data, profits, goodwill, or any type of
:: loss or damage suffered as a result of any action brought
:: by a third party) even if such damage or loss was
:: reasonably foreseeable or Xilinx had been advised of the
:: possibility of the same.
::
:: CRITICAL APPLICATIONS
:: Xilinx products are not designed or intended to be fail-
:: safe, or for use in any application requiring fail-safe
:: performance, such as life-support or safety devices or
:: systems, Class III medical devices, nuclear facilities,
:: applications related to the deployment of airbags, or any
:: other applications that could lead to death, personal
:: injury, or severe property or environmental damage
:: (individually and collectively, "Critical
:: Applications"). Customer assumes the sole risk and
:: liability of any use of Xilinx products in Critical
:: Applications, subject only to applicable laws and
:: regulations governing limitations on product liability.
::
:: THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
:: PART OF THIS FILE AT ALL TIMES.
::
::****************************************************************************
::   ____  ____
::  /   /\/   /
:: /___/  \  /    Vendor                : Xilinx
:: \   \   \/     Version               : 3.92
::  \   \         Application           : MIG
::  /   /         Filename              : readme.txt
:: /___/   /\     Date Last Modified    : $Date: 2011/06/02 07:16:57 $
:: \   \  /  \    Date Created          : Fri Feb 06 2009
::  \___\/\___\
::
:: Device            : Spartan-6
:: Design Name       : DDR/DDR2/DDR3/LPDDR
:: Purpose           : Information about par folder
:: Reference         :
:: Revision History  :
::****************************************************************************

This folder has the batch files to synthesize using XST or Synplify Pro and
implement the design either in "Command Line Mode" or in "GUI Mode".

Steps to run the design using the ise_flow (batch mode):

1. Executing the "ise_flow.bat" file synthesizes the design using XST or
   Synplify Pro and does implement the design.
     a. First it removes the XST/Synplify Pro report files, implementation
        files, supporting scripts, the generated chipscope designs (if 
        enabled) and the ISE project files (if exist any on previous runs)
     b. Synthesizes the design either with XST or Synplicity
     c. Implements the design with ISE.   

2. After the design is run, it creates ise_flow_results.txt file that will have
   the ISE log information.

Steps to run the design using the create_ise (GUI mode - for XST cases only):

1. This file will appear for XST cases only.

2. On executing the "create_ise.bat" file creates "test.xise" project file
   and set all the properties of the design selected.

3. The design can be implemented in ISE Projnav GUI by invoking the "test.xise" project file.

4. In Linux operating systems, test.xise project can be invoked by executing the command
   'ise test.xise' from the terminal.

Other files in PAR folder :

* "mig.ucf" file is the constraint file for the design.
  It has clock constraints, location constraints and IO standards.

* "mem_interface_top.ut" file has the options for the Configuration file
  generation i.e. the "mig.bit" file to run in batch mode.

* "rem_files.bat" file has all the ISE/Synplify Pro generated report files, 
  implementation files, supporting scripts, the generated chipscope designs
  (if enabled) and the ISE project files.

* "set_ise_prop.tcl" file has all the properties that are to be
  set in GUI mode.

* "ise_run.txt" file has synthesis options for the XST tool.
  This file is used for batch mode.

* "icon_coregen.xco", "ila_coregen.xco" and "vio_coregen.xco"files are used to 
   generate ChipScope ila,vio and icon EDIF/NGC files. In order to generate the 
   EDIF/NGC files, you must execute the following commands before starting 
   synthesis and PAR.

           coregen -b ila_coregen.xco
           coregen -b icon_coregen.xco
           coregen -b vio_coregen.xco

Note : When you generate the design using "Debug Signals for Memory Controller"
       option Enable, the above mentioned ChipScope coregen commands are printed
       into ise_flow.bat and create_ise.bat files. The mig rtl file
       will have the design debug signals portmapped to vio and icon
       ChipScope modules.

* At the start of a Chip Scope Analyzer project, all of the signals in
  every core have generic names. "mig.cdc" is a file that contains
  all the signal names of all cores. Upon importing this file, signal names are
  renamed to the specified names in "mig.cdc" file. This file will work
  for the generated designs from MIG. If any of the design parameter values
  are changed after generating the design, this file will not work.
  For Multiple Controller designs, signal names provided in CDC file are of 
  the controller that is enabled for Debug in the GUI.

synth folder:

1. mem_interface_top_synp.sdc
2. script_synp.tcl
3. mig.prj
4. mig.lso

   mem_interface_top_synp.sdc and script_synp.tcl files are being used by
   Synplify Pro and mig.prj and mig.lso are being used by XST.


