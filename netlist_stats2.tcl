#!/usr/bin/tclsh

# Ensure two arguments are provided
if {$argc != 2} {
    puts "Usage: net_stat2.tcl <netlist_file> <report_file>"
    exit 1
}

# Get command-line arguments
set netlist_file [lindex $argv 0]
set report_file [lindex $argv 1]

# Check if netlist file exists
if {![file exists $netlist_file]} {
    puts "Error: File '$netlist_file' not found."
    exit 1
}

# Open the netlist file for reading
set file [open $netlist_file r]
set line_count 0
set instance_count 0
array set module_counts {}

# Regular expressions for Verilog and VHDL instances
set verilog_pattern {^\s*(\w+)\s+(\w+)\s*\(\s*\.}
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

# Close the netlist file
close $file

# Create formatted report
set report ""
append report "----------------------------------------\n"
append report [format "| %-35s |\n" "Statistics from $netlist_file"]
append report "+--------------------------------------+\n"
append report [format "| %-25s | %-5s |\n" "Cell type" "Count"]
append report "+--------------------------------------+\n"

foreach module_name [lsort [array names module_counts]] {
    append report [format "| %-25s | %-5d |\n" $module_name $module_counts($module_name)]
}

append report "+--------------------------------------+\n"
append report [format "| The file has %d instances           |\n" $instance_count]
append report "----------------------------------------\n"

# Print report to standard output
puts $report

# Write report to the output file
set output [open $report_file w]
puts $output $report
close $output

# Print completion message
puts "Report saved to $report_file."
puts "Done."
