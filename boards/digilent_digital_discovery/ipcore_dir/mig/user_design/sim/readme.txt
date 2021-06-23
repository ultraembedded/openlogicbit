###############################################################################
## (c) Copyright 2009 Xilinx, Inc. All rights reserved.
##
## This file contains confidential and proprietary information
## of Xilinx, Inc. and is protected under U.S. and
## international copyright and other intellectual property
## laws.
##
## DISCLAIMER
## This disclaimer is not a license and does not grant any
## rights to the materials distributed herewith. Except as
## otherwise provided in a valid license issued to you by
## Xilinx, and to the maximum extent permitted by applicable
## law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
## WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
## AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
## BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
## INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
## (2) Xilinx shall not be liable (whether in contract or tort,
## including negligence, or under any other theory of
## liability) for any loss or damage of any kind or nature
## related to, arising under or in connection with these
## materials, including for any direct, or any indirect,
## special, incidental, or consequential loss or damage
## (including loss of data, profits, goodwill, or any type of
## loss or damage suffered as a result of any action brought
## by a third party) even if such damage or loss was
## reasonably foreseeable or Xilinx had been advised of the
## possibility of the same.
##
## CRITICAL APPLICATIONS
## Xilinx products are not designed or intended to be fail-
## safe, or for use in any application requiring fail-safe
## performance, such as life-support or safety devices or
## systems, Class III medical devices, nuclear facilities,
## applications related to the deployment of airbags, or any
## other applications that could lead to death, personal
## injury, or severe property or environmental damage
## (individually and collectively, "Critical
## Applications"). Customer assumes the sole risk and
## liability of any use of Xilinx products in Critical
## Applications, subject only to applicable laws and
## regulations governing limitations on product liability.
##
## THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
## PART OF THIS FILE AT ALL TIMES.
##
###############################################################################
##   ____  ____
##  /   /\/   /
## /___/  \  /    Vendor             : Xilinx
## \   \   \/     Version            : 3.92
##  \   \         Application	     : MIG
##  /   /         Filename           : readme.txt
## /___/   /\     Date Last Modified : $Date: 2011/06/02 07:16:58 $
## \   \  /  \    Date Created       : Mon Oct 19 2009
##  \___\/\___\
##
## Device          : Spartan-6
## Design Name     : DDR/DDR2/DDR3/LPDDR
## Purpose         : Steps to run simulation using ISIM/Modelsim simualtor in this folder
## Assumptions:
##      - Simulation takes place in \sim\<functional/timing> folder of MIG output directory
## Reference       :
## Revision History:
###############################################################################

The sim/functional folder has files to perform functional simulation of the design.

1. Simulation using Modelsim simulator

A) sim.do File :
   
   1) The 'sim.do' file has commands to compile and simulate memory interface
      design and run the simulation for specified period of time. 
    
   2) It has the syntax to Map the required libraries.
      Also, $XILINX environment variable must be set in order to compile glbl.v file

   3) Displays the waveforms that are listed with "add wave" command.
     
B) Steps to run the Modelsim simulation:

   1) The user should invoke the Modelsim simulator GUI.
   2) Change the present working directory path to the sim/functional folder.
      In Transcript window, at Modelsim prompt, type the following command to 
      change directory path.
           cd <sim/functional directory path>

   2) Run the simulation using sim.do file.
      At Modelsim prompt, type the following command:
           do sim.do      

   3) To exit simulation, type the following command at Modelsim prompt:
           quit -f

   4) Verify the transcript file for the memory transactions.


2. Simulation using ISIM simulator
  
A) Following files are provided :
   
   1) The '.prj' file contains the list of all the files associated with the design.
      It also contains the hdl, library and the source file name.       
    
   2) The '.tcl' file contains the Tcl commands for simulation and 
      resume on error. 

   3) The 'isim.bat' has commands which use '.prj' and '.tcl' files. 

     
B) Steps to run the ISIM simulation:

   The user should execute the file isim.bat, which does the following steps:
   1) Compiles, elaborates the design and generates the simulation executable using
      the fuse command in 'isim.bat' file.

   2) Invokes the ISIM GUI.

   3) User can add required signals from objects window to the waveform viewer and run 
      simulation for specified time using the command "run <time>" in ISIM GUI.
