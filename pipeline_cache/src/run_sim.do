# Create work library if it doesn't exist
if {![file isdirectory rtl_work]} {
    vlib rtl_work
}
vmap work rtl_work

# Compile all Verilog files
vlog -vlog01compat -work work +incdir+. *.v

# Load the testbench for simulation
vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc" pipeline_tb

# Simulation commands
add wave *
run -all 