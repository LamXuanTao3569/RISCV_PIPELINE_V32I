import os
import shutil
import subprocess
import csv
import sys
from datetime import datetime
import getpass

# === Detect current username ===
try:
    current_user = os.getlogin()
except OSError:
    current_user = getpass.getuser()

# === Configuration ===

dir_home = "/srv/calab_grade/CA_Lab-2025"
#dir_home = "/home/quangle/CA_Lab-2025"
dir_c = f"/tmp/grade_{current_user}"
log_file = os.path.join(dir_c, "sim.log")
csv_file = f"{dir_home}/students.csv"
pass_message = "All tests passed"
user_full_name = "Unknown Name"
user_username = current_user

# === Supported tests and fixed Verilog sources ===
test_configs = {
    "sc1": [f"{dir_home}/sim/testbench/RISCV_Single_Cycle_tb_grade.v"],
    "sc2": [f"{dir_home}/sim/testbench/tb_RISCV_sc2.v"],
    "pl1": [],
    "pl2": []
}

# === Fixed non-Verilog data files per test ===
fixed_data = {
    "sc1": [f"{dir_home}/sim/mem/imem.hex",
            f"{dir_home}/sim/mem/dmem_init.hex",
            f"{dir_home}/sim/mem/golden_output.txt"],
    "sc2": [f"{dir_home}/sim/mem/imem2.hex",
            f"{dir_home}/sim/mem/dmem_init2.hex",
            f"{dir_home}/sim/mem/golden_output2.txt"],
    "pl1": [],
    "pl2": []
}

# === Parse args ===
if len(sys.argv) < 3:
    print("Usage: python calab_grade.py <test_name> user_file1.v user_file2.v ...")
    sys.exit(1)

test_name = sys.argv[1].lower()
user_sources = sys.argv[2:]

if test_name not in test_configs:
    print(f"[ERROR] Unknown test '{test_name}'. Valid options: {list(test_configs.keys())}")
    sys.exit(1)

fixed_sources = test_configs[test_name]
extra_data_files = fixed_data.get(test_name, [])

# === Validate all files exist ===
all_sources = fixed_sources + user_sources + extra_data_files
for f in all_sources:
    if not os.path.isfile(f):
        print(f"[ERROR] File not found: {f}")
        sys.exit(1)

# === Step 1: Prepare working directory ===
os.makedirs(dir_c, exist_ok=True)
copied_files = []

# Copy user Verilog files
for full_path in user_sources:
    filename = os.path.basename(full_path)
    dest_path = os.path.join(dir_c, filename)
    shutil.copy2(full_path, dest_path)
    copied_files.append(filename)

# Copy fixed Verilog files
for full_path in fixed_sources:
    filename = os.path.basename(full_path)
    dest_path = os.path.join(dir_c, filename)
    shutil.copy2(full_path, dest_path)
    copied_files.append(filename)

# Copy fixed non-Verilog data files into /mem subdirectory
mem_dir = os.path.join(dir_c, "mem")
os.makedirs(mem_dir, exist_ok=True)

for full_path in extra_data_files:
    filename = os.path.basename(full_path)
    dest_path = os.path.join(mem_dir, filename)
    shutil.copy2(full_path, dest_path)
    # NOT added to copied_files, so won't be compiled

# === Step 2: Compile ===
compile_cmd = ["iverilog", "-g2012", "-o", "sim.out"] + copied_files
subprocess.run(compile_cmd, cwd=dir_c, check=True)

# === Step 3: Run simulation ===
with open(log_file, "w") as f:
    subprocess.run(["vvp", "sim.out"], cwd=dir_c, stdout=f, stderr=subprocess.STDOUT)

# === Step 4: Check pass ===
def test_passed(log_path, keyword):
    with open(log_path, "r") as f:
        return any(keyword in line for line in f)
# === Step 5: Update CSV ===
column_name = f"{test_name}_pass"
timestamp_col = f"{test_name}_timestamp"

if test_passed(log_file, pass_message):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    updated_rows = []
    user_found = False

    if os.path.exists(csv_file):
        with open(csv_file, newline="") as f:
            reader = csv.DictReader(f)
            fieldnames = reader.fieldnames
            if column_name not in fieldnames:
                fieldnames += [column_name, timestamp_col]
            for row in reader:
                if row["username"].strip().lower() == user_username.strip().lower():
                    row[column_name] = "x"
                    row[timestamp_col] = timestamp
                    user_found = True
                updated_rows.append(row)
    else:
        fieldnames = ["full_name", "username", column_name, timestamp_col]

    if not user_found:
        updated_rows.append({
            "full_name": user_full_name,
            "username": user_username,
            column_name: "x",
            timestamp_col: timestamp
        })

    with open(csv_file, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(updated_rows)

    print(f"[INFO] ✅ Test '{test_name}' passed. User '{user_username}' marked in {csv_file}.")
else:
    print(f"[INFO] ❌ Test '{test_name}' failed. Please debug and retry again.")

# === Step 6: Clean up ===
#shutil.rmtree(dir_c)
print(f"[INFO] 🧹 Temporary directory '{dir_c}' deleted.")
