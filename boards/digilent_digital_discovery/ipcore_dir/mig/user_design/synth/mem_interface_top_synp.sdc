# Synplicity, Inc. constraint file
# Written on Mon Jun 27 15:50:39 2005

define_attribute          {v:work.infrastructure} syn_hier {hard}
define_attribute          {v:work.memc_wrapper} syn_hier {hard}
define_attribute          {v:work.mig} syn_hier {hard}
define_attribute          {v:work.a_upsizer} syn_hier {hard}
define_attribute          {v:work.axi_mcb} syn_hier {hard}
define_attribute          {v:work.axi_mcb_ar_channel} syn_hier {hard}
define_attribute          {v:work.axi_mcb_aw_channel} syn_hier {hard}
define_attribute          {v:work.axi_mcb_b_channel} syn_hier {hard}
define_attribute          {v:work.axi_mcb_cmd_arbiter} syn_hier {hard}
define_attribute          {v:work.axi_mcb_cmd_fsm} syn_hier {hard}
define_attribute          {v:work.axi_mcb_cmd_translator} syn_hier {hard}
define_attribute          {v:work.axi_mcb_incr_cmd} syn_hier {hard}
define_attribute          {v:work.axi_mcb_r_channel} syn_hier {hard}
define_attribute          {v:work.axi_mcb_simple_fifo} syn_hier {hard}
define_attribute          {v:work.axi_mcb_w_channel} syn_hier {hard}
define_attribute          {v:work.axi_mcb_wrap_cmd} syn_hier {hard}
define_attribute          {v:work.axi_register_slice} syn_hier {hard}
define_attribute          {v:work.axi_upsizer} syn_hier {hard}
define_attribute          {v:work.axic_register_slice} syn_hier {hard}
define_attribute          {v:work.carry} syn_hier {hard}
define_attribute          {v:work.carry_and} syn_hier {hard}
define_attribute          {v:work.carry_latch_and} syn_hier {hard}
define_attribute          {v:work.carry_latch_or} syn_hier {hard}
define_attribute          {v:work.carry_or} syn_hier {hard}
define_attribute          {v:work.command_fifo} syn_hier {hard}
define_attribute          {v:work.comparator} syn_hier {hard}
define_attribute          {v:work.comparator_mask} syn_hier {hard}
define_attribute          {v:work.comparator_mask_static} syn_hier {hard}
define_attribute          {v:work.comparator_sel} syn_hier {hard}
define_attribute          {v:work.comparator_sel_mask} syn_hier {hard}
define_attribute          {v:work.comparator_sel_mask_static} syn_hier {hard}
define_attribute          {v:work.comparator_sel_static} syn_hier {hard}
define_attribute          {v:work.comparator_static} syn_hier {hard}
define_attribute          {v:work.mcb_ui_top_synch} syn_hier {hard}
define_attribute          {v:work.mux_enc} syn_hier {hard}
define_attribute          {v:work.r_upsizer} syn_hier {hard}
define_attribute          {v:work.w_upsizer} syn_hier {hard}
define_attribute          {v:work.iodrp_controller} syn_hier {hard}
define_attribute          {v:work.iodrp_mcb_controller} syn_hier {hard}
define_attribute          {v:work.mcb_raw_wrapper} syn_hier {hard}
define_attribute          {v:work.mcb_soft_calibration} syn_hier {hard}
define_attribute          {v:work.mcb_soft_calibration_top} syn_hier {hard}
define_attribute          {v:work.mcb_ui_top} syn_hier {hard}

# clock Constraints
define_clock -disable -name {memc3_infrastructure_inst} -period 3205 -clockgroup default_clkgroup_1
define_clock          -name {memc3_infrastructure_inst.SYS_CLK_INST} -period 3205 -clockgroup default_clkgroup_2
define_clock -disable -name {memc3_infrastructure_inst.u_pll_adv} -period 3205 -clockgroup default_clkgroup_3




