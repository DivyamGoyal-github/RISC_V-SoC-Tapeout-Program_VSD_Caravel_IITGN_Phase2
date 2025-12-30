# ========================================================================
# Setup Work Directory (generates fresh per run)
# ========================================================================
set root_dir "/home/dgoyal/vsdRiscvScl180"
set work_dir "$root_dir/synthesis/work"
set report_dir "$root_dir/synthesis/report"

# Clean and recreate work directory for fresh run
puts "INFO: Cleaning and setting up work directory..."
file delete -force $work_dir
file mkdir $work_dir
file mkdir $work_dir/alib
file mkdir "$root_dir/synthesis/output"
file mkdir $report_dir

# Define work library
define_design_lib WORK -path $work_dir
set_app_var alib_library_analysis_path "$work_dir/alib"

# ========================================================================
# Load Technology Libraries
# ========================================================================
read_db "/home/Synopsys/pdk/SCL_PDK_3/SCLPDK_V3.0_KIT/scl180/iopad/cio250/4M1L/liberty/tsl18cio250_min.db"
read_db "/home/Synopsys/pdk/SCL_PDK_3/SCLPDK_V3.0_KIT/scl180/stdcell/fs120/4M1IL/liberty/lib_flow_ff/tsl18fs120_scl_ff.db"

set target_library "/home/Synopsys/pdk/SCL_PDK_3/SCLPDK_V3.0_KIT/scl180/iopad/cio250/4M1L/liberty/tsl18cio250_min.db /home/Synopsys/pdk/SCL_PDK_3/SCLPDK_V3.0_KIT/scl180/stdcell/fs120/4M1IL/liberty/lib_flow_ff/tsl18fs120_scl_ff.db"
set link_library "* /home/Synopsys/pdk/SCL_PDK_3/SCLPDK_V3.0_KIT/scl180/iopad/cio250/4M1L/liberty/tsl18cio250_min.db /home/Synopsys/pdk/SCL_PDK_3/SCLPDK_V3.0_KIT/scl180/stdcell/fs120/4M1IL/liberty/lib_flow_ff/tsl18fs120_scl_ff.db"

set_app_var target_library $target_library
set_app_var link_library $link_library

# ========================================================================
# Create RAM Blackbox Stubs
# ========================================================================
puts "INFO: Creating RAM blackbox stubs..."
set blackbox_file "$work_dir/ram_blackbox.v"
set fp [open $blackbox_file w]
puts $fp "(* blackbox *)"
puts $fp "module RAM128(CLK, EN0, VGND, VPWR, A0, Di0, Do0, WE0);"
puts $fp "  input CLK, EN0, VGND, VPWR;"
puts $fp "  input \[6:0\] A0;"
puts $fp "  input \[31:0\] Di0;"
puts $fp "  input \[3:0\] WE0;"
puts $fp "  output \[31:0\] Do0;"
puts $fp "endmodule"
puts $fp ""
puts $fp "(* blackbox *)"
puts $fp "module RAM256(VPWR, VGND, CLK, WE0, EN0, A0, Di0, Do0);"
puts $fp "  input CLK, EN0;"
puts $fp "  inout VPWR, VGND;"
puts $fp "  input \[7:0\] A0;"
puts $fp "  input \[31:0\] Di0;"
puts $fp "  input \[3:0\] WE0;"
puts $fp "  output \[31:0\] Do0;"
puts $fp "endmodule"
close $fp
puts "INFO: RAM blackbox stubs created at $blackbox_file"

# ========================================================================
# Read Design Files
# ========================================================================
set io_lib "/home/Synopsys/pdk/SCL_PDK_3/SCLPDK_V3.0_KIT/scl180/iopad/cio250/4M1L/verilog/tsl18cio250/zero"
set verilog_files "$root_dir/rtl"
set top_module "vsdcaravel"
set output_file "$root_dir/synthesis/output/vsdcaravel_synthesis.v"

# Read blackbox stubs first
read_file $blackbox_file -format verilog

# Read defines
read_file $verilog_files/defines.v
read_file $verilog_files/user_defines.v

# Read pad macros and pad wrappers BEFORE chip_io / mprj_io
set pad_wrappers [list \
    "$verilog_files/pads.v" \
    "$verilog_files/primitives.v" \
    "$verilog_files/scl180_wrapper/pc3d01.v" \
    "$verilog_files/pc3d21.v" \
    "$verilog_files/scl180_wrapper/pc3b03ed.v" \
    "$verilog_files/scl180_wrapper/pt3b02.v" \
]

read_file $pad_wrappers -format verilog

# (Optional) Pad library verilog from PDK, but WITHOUT -autoread/-top
read_file $io_lib -format verilog

set all_rtl     [glob -nocomplain $verilog_files/*.v]
set rtl_to_read [list]

# Read RTL but EXCLUDE RAM128.v and RAM256.v
puts "INFO: Reading RTL files (excluding RAM modules)..."
set all_rtl [glob -nocomplain $verilog_files/*.v]
set rtl_to_read [list]
foreach file $all_rtl {
    if {![string match "*RAM128.v" $file] && \
        ![string match "*RAM256.v" $file] && \
        ![string match "*defines.v" $file]} {
        lappend rtl_to_read $file
    }
}

# Add BOTH macros that your design needs
# read_file $rtl_to_read -autoread -define {USE_POWER_PINS OPENFRAME_IO_PADS CLK_DIV} -format verilog -top $top_module
read_file $rtl_to_read -autoread -define {USE_POWER_PINS} -format verilog -top $top_module

puts "INFO: Elaborating design..."
elaborate $top_module

# ========================================================================
# Mark RAM Modules as Blackbox
# ========================================================================
puts "INFO: Marking RAM modules as blackbox..."
foreach ram_module {"RAM128" "RAM256"} {
    if {[sizeof_collection [get_designs -quiet $ram_module]] > 0} {
        set_attribute [get_designs $ram_module] is_black_box true -quiet
        set_dont_touch [get_designs $ram_module]
        puts "INFO: $ram_module marked as blackbox"
    }
}

# Protect RAM instances
foreach ram_ref {"RAM128" "RAM256"} {
    set instances [get_cells -quiet -hierarchical -filter "ref_name == $ram_ref"]
    if {[sizeof_collection $instances] > 0} {
        set_dont_touch $instances
        puts "INFO: Protected [sizeof_collection $instances] instance(s) of $ram_ref"
    }
}

# ========================================================================
# Link and Compile
# ========================================================================
link
#set_uniquify_design false
#set_flatten false

# ========================================================================
# Read SDC and Elaborate
# ========================================================================
read_sdc "$root_dir/synthesis/vsdcaravel.sdc"
update_timing

#compile
compile_ultra -incremental

# ========================================================================
# Reports
# ========================================================================
report_qor > "$report_dir/qor_post_synth.rpt"
report_area > "$report_dir/area_post_synth.rpt"
report_power > "$report_dir/power_post_synth.rpt"

# ========================================================================
# Generate Reports
# ========================================================================
puts "INFO: Generating synthesis reports..."

# Original reports from golden script
report_qor > "$report_dir/qor_post_synth.rpt"
report_area > "$report_dir/area_post_synth.rpt"
report_power > "$report_dir/power_post_synth.rpt"

# Additional reports
report_timing -max_paths 10 > "$report_dir/timing_post_synth.rpt"
report_constraint -all_violators > "$report_dir/constraints_post_synth.rpt"

# Blackbox modules report
puts "INFO: Generating blackbox module report..."
set bb_report [open "$report_dir/blackbox_modules.rpt" w]
puts $bb_report "========================================"
puts $bb_report "Blackbox Modules Report"
puts $bb_report "========================================"
puts $bb_report ""
puts $bb_report "Date: [date]"
puts $bb_report "Design: $top_module"
puts $bb_report ""

foreach bb_module {"RAM128" "RAM256"} {
    puts $bb_report "----------------------------------------"
    puts $bb_report "Module: $bb_module"
    puts $bb_report "----------------------------------------"
    
    # Check if design exists
    set design_exists [sizeof_collection [get_designs -quiet $bb_module]]
    if {$design_exists > 0} {
        puts $bb_report "  Design Status: PRESENT (blackbox)"
        
        # Check for instances
        set instances [get_cells -quiet -hierarchical -filter "ref_name == $bb_module"]
        set inst_count [sizeof_collection $instances]
        
        if {$inst_count > 0} {
            puts $bb_report "  Instance Count: $inst_count"
            puts $bb_report "  Instances:"
            foreach_in_collection inst $instances {
                puts $bb_report "    - [get_object_name $inst]"
            }
        } else {
            puts $bb_report "  Instance Count: 0 (not instantiated)"
        }
    } else {
        puts $bb_report "  Design Status: NOT FOUND"
        puts $bb_report "  Instance Count: N/A"
    }
    puts $bb_report ""
}

puts $bb_report "========================================"
puts $bb_report "End of Blackbox Report"
puts $bb_report "========================================"
close $bb_report
puts "INFO: Blackbox report written to: $report_dir/blackbox_modules.rpt"

# ========================================================================
# Write Output Files
# ========================================================================
puts "INFO: Writing output files..."

# Write Verilog netlist (as in golden script)
write -format verilog -hierarchy -output $output_file
puts "INFO: Netlist written to: $output_file"

# Write DDC format for place-and-route
write -format ddc -hierarchy -output "$root_dir/synthesis/output/vsdcaravel_synthesis.ddc"
puts "INFO: DDC written to: $root_dir/synthesis/output/vsdcaravel_synthesis.ddc"

# Write SDC with actual timing constraints
write_sdc "$root_dir/synthesis/output/vsdcaravel_synthesis.sdc"
puts "INFO: SDC written to: $root_dir/synthesis/output/vsdcaravel_synthesis.sdc"


puts ""
puts "========================================"
puts "Synthesis Complete!"
puts "========================================"
puts "Netlist: $output_file"
puts "Work directory: $work_dir (cleaned each run)"
puts "RAM128 and RAM256 preserved as blackboxes"
puts "========================================"

