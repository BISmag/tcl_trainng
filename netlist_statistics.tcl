#!/usr/bin/tclsh

# Ensure a filename is provided
if {$argc != 1} {
    puts "Usage: net_stat.tcl <netlist_file>"
    exit 1
}

# Get filename from command-line argument
set filename [lindex $argv 0]

# Try to open the file for reading
if {![file exists $filename]} {
    puts "Error: File '$filename' not found."
    exit 1
}

set file [open $filename r]
set line_count 0
set instance_count 0
array set module_counts {}

# Regular expression patterns for Verilog and VHDL instances
set verilog_pattern {^\s*(\w+)\s+(\w+)\s*\(}
set vhdl_pattern {^\s*(\w+)\s*:\s*(\w+)\s+port\s+map}

# Read file line by line
while {[gets $file line] >= 0} {
    incr line_count

    # Check for Verilog module instantiation
    if {[regexp $verilog_pattern $line match module_name instance_name]} {
        incr module_counts($module_name)
        incr instance_count
    }

    # Check for VHDL component instantiation
    if {[regexp $vhdl_pattern $line match instance_name module_name]} {
        incr module_counts($module_name)
        incr instance_count
    }

    # Print progress every 5000 lines
    if {($line_count % 5000) == 0} {
        puts "Processed $line_count lines..."
    }
}

# Close the file
close $file

# Print the summary of instances
foreach module_name [array names module_counts] {
    puts "$module_name: $module_counts($module_name)"
}

# Print final statistics
puts "$line_count lines read, $instance_count instances found."
puts "Done."
