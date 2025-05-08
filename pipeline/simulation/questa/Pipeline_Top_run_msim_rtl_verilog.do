transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src {/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src/Decode_Cycle.v}
vlog -vlog01compat -work work +incdir+/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src {/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src/Register_File.v}
vlog -vlog01compat -work work +incdir+/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src {/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src/PC.v}
vlog -vlog01compat -work work +incdir+/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src {/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src/Sign_Extend.v}
vlog -vlog01compat -work work +incdir+/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src {/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src/Writeback_Cycle.v}
vlog -vlog01compat -work work +incdir+/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src {/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src/PC_Adder.v}
vlog -vlog01compat -work work +incdir+/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src {/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src/Control_Unit_Top.v}
vlog -vlog01compat -work work +incdir+/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src {/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src/Hazard_unit.v}
vlog -vlog01compat -work work +incdir+/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src {/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src/Execute_Cycle.v}
vlog -vlog01compat -work work +incdir+/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src {/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src/ALU.v}
vlog -vlog01compat -work work +incdir+/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src {/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src/ALU_Decoder.v}
vlog -vlog01compat -work work +incdir+/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src {/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src/Data_Memory.v}
vlog -vlog01compat -work work +incdir+/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src {/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src/Main_Decoder.v}
vlog -vlog01compat -work work +incdir+/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src {/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src/Mux.v}
vlog -vlog01compat -work work +incdir+/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src {/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src/Memory_Cycle.v}
vlog -vlog01compat -work work +incdir+/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src {/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src/Fetch_Cycle.v}
vlog -vlog01compat -work work +incdir+/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src {/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src/Pipeline_Top.v}
vlog -vlog01compat -work work +incdir+/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src {/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src/Instruction_Memory.v}

vlog -vlog01compat -work work +incdir+/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src {/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src/pipeline_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  tb

add wave *
view structure
view signals
run -all
