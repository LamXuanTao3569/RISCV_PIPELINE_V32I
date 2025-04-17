transcript on

# Xóa thư viện cũ nếu tồn tại
if {[file exists rtl_work]} {
    vdel -lib rtl_work -all
}

# Tạo thư viện mới
vlib rtl_work
vmap work rtl_work

# Biên dịch tất cả file Verilog
vlog -vlog01compat -work work +incdir+/home/taolam/risc-v_project/simple {/home/taolam/risc-v_project/simple/regfile.v}
vlog -vlog01compat -work work +incdir+/home/taolam/risc-v_project/simple {/home/taolam/risc-v_project/simple/alu.v}
vlog -vlog01compat -work work +incdir+/home/taolam/risc-v_project/simple {/home/taolam/risc-v_project/simple/riscv_single_cycle.v}
vlog -vlog01compat -work work +incdir+/home/taolam/risc-v_project/simple {/home/taolam/risc-v_project/simple/imem.v}
vlog -vlog01compat -work work +incdir+/home/taolam/risc-v_project/simple {/home/taolam/risc-v_project/simple/control_unit.v}
vlog -vlog01compat -work work +incdir+/home/taolam/risc-v_project/simple {/home/taolam/risc-v_project/simple/dmem.v}
vlog -vlog01compat -work work +incdir+/home/taolam/risc-v_project/simple {/home/taolam/risc-v_project/simple/tb_riscv_single_cycle.v}

# Chạy mô phỏng với GUI và testbench đúng
vsim -gui -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc" work.tb_riscv_single_cycle

# Thêm tín hiệu và chạy
add wave -r /*
run -all
