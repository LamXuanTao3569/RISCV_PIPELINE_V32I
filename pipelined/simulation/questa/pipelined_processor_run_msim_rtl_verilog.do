transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+/home/taolam/risc-v_project/pipelined {/home/taolam/risc-v_project/pipelined/riscv_pipeline.v}
vlog -vlog01compat -work work +incdir+/home/taolam/risc-v_project/pipelined {/home/taolam/risc-v_project/pipelined/imem.v}
vlog -vlog01compat -work work +incdir+/home/taolam/risc-v_project/pipelined {/home/taolam/risc-v_project/pipelined/regfile.v}
vlog -vlog01compat -work work +incdir+/home/taolam/risc-v_project/pipelined {/home/taolam/risc-v_project/pipelined/alu.v}
vlog -vlog01compat -work work +incdir+/home/taolam/risc-v_project/pipelined {/home/taolam/risc-v_project/pipelined/dmem.v}
vlog -vlog01compat -work work +incdir+/home/taolam/risc-v_project/pipelined {/home/taolam/risc-v_project/pipelined/control_unit.v}
vlog -vlog01compat -work work +incdir+/home/taolam/risc-v_project/pipelined {/home/taolam/risc-v_project/pipelined/forwarding_unit.v}
vlog -vlog01compat -work work +incdir+/home/taolam/risc-v_project/pipelined {/home/taolam/risc-v_project/pipelined/hazard_detection.v}
vlog -vlog01compat -work work +incdir+/home/taolam/risc-v_project/pipelined {/home/taolam/risc-v_project/pipelined/if_stage.v}
vlog -vlog01compat -work work +incdir+/home/taolam/risc-v_project/pipelined {/home/taolam/risc-v_project/pipelined/id_stage.v}
vlog -vlog01compat -work work +incdir+/home/taolam/risc-v_project/pipelined {/home/taolam/risc-v_project/pipelined/ex_stage.v}
vlog -vlog01compat -work work +incdir+/home/taolam/risc-v_project/pipelined {/home/taolam/risc-v_project/pipelined/mem_stage.v}
vlog -vlog01compat -work work +incdir+/home/taolam/risc-v_project/pipelined {/home/taolam/risc-v_project/pipelined/wb_stage.v}

vlog -vlog01compat -work work +incdir+/home/taolam/risc-v_project/pipelined {/home/taolam/risc-v_project/pipelined/tb_riscv_pipeline.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  tb_riscv_pipeline

add wave *
view structure
view signals
run -all
