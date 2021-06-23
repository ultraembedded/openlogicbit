project -new 
add_file -verilog "../rtl/infrastructure.v"
add_file -verilog "../rtl/memc_wrapper.v"
add_file -verilog "../rtl/mig.v"
add_file -verilog "../rtl/axi/a_upsizer.v"
add_file -verilog "../rtl/axi/axi_mcb.v"
add_file -verilog "../rtl/axi/axi_mcb_ar_channel.v"
add_file -verilog "../rtl/axi/axi_mcb_aw_channel.v"
add_file -verilog "../rtl/axi/axi_mcb_b_channel.v"
add_file -verilog "../rtl/axi/axi_mcb_cmd_arbiter.v"
add_file -verilog "../rtl/axi/axi_mcb_cmd_fsm.v"
add_file -verilog "../rtl/axi/axi_mcb_cmd_translator.v"
add_file -verilog "../rtl/axi/axi_mcb_incr_cmd.v"
add_file -verilog "../rtl/axi/axi_mcb_r_channel.v"
add_file -verilog "../rtl/axi/axi_mcb_simple_fifo.v"
add_file -verilog "../rtl/axi/axi_mcb_w_channel.v"
add_file -verilog "../rtl/axi/axi_mcb_wrap_cmd.v"
add_file -verilog "../rtl/axi/axi_register_slice.v"
add_file -verilog "../rtl/axi/axi_upsizer.v"
add_file -verilog "../rtl/axi/axic_register_slice.v"
add_file -verilog "../rtl/axi/carry.v"
add_file -verilog "../rtl/axi/carry_and.v"
add_file -verilog "../rtl/axi/carry_latch_and.v"
add_file -verilog "../rtl/axi/carry_latch_or.v"
add_file -verilog "../rtl/axi/carry_or.v"
add_file -verilog "../rtl/axi/command_fifo.v"
add_file -verilog "../rtl/axi/comparator.v"
add_file -verilog "../rtl/axi/comparator_mask.v"
add_file -verilog "../rtl/axi/comparator_mask_static.v"
add_file -verilog "../rtl/axi/comparator_sel.v"
add_file -verilog "../rtl/axi/comparator_sel_mask.v"
add_file -verilog "../rtl/axi/comparator_sel_mask_static.v"
add_file -verilog "../rtl/axi/comparator_sel_static.v"
add_file -verilog "../rtl/axi/comparator_static.v"
add_file -verilog "../rtl/axi/mcb_ui_top_synch.v"
add_file -verilog "../rtl/axi/mux_enc.v"
add_file -verilog "../rtl/axi/r_upsizer.v"
add_file -verilog "../rtl/axi/w_upsizer.v"
add_file -verilog "../rtl/mcb_controller/iodrp_controller.v"
add_file -verilog "../rtl/mcb_controller/iodrp_mcb_controller.v"
add_file -verilog "../rtl/mcb_controller/mcb_raw_wrapper.v"
add_file -verilog "../rtl/mcb_controller/mcb_soft_calibration.v"
add_file -verilog "../rtl/mcb_controller/mcb_soft_calibration_top.v"
add_file -verilog "../rtl/mcb_controller/mcb_ui_top.v"
add_file -constraint "../synth/mem_interface_top_synp.sdc"
impl -add rev_1
set_option -technology spartan6
set_option -part xc6slx25
set_option -package csg324
set_option -speed_grade -2
set_option -default_enum_encoding default
set_option -hdl_define -set AXI_ENABLE
set_option -symbolic_fsm_compiler 1
set_option -resource_sharing 0
set_option -use_fsm_explorer 0
set_option -top_module "mig"
set_option -frequency 312.012
set_option -fanout_limit 1000
set_option -disable_io_insertion 0
set_option -pipe 1
set_option -fixgatedclocks 0
set_option -retiming 0
set_option -modular 0
set_option -update_models_cp 0
set_option -verification_mode 0
set_option -write_verilog 0
set_option -write_vhdl 0
set_option -write_apr_constraint 0
project -result_file "../synth/rev_1/mig.edf"
set_option -vlog_std v2001
set_option -auto_constrain_io 0
impl -active "../synth/rev_1"
project -run
project -save

