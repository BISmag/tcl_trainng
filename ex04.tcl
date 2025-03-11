# phonebk.tcl - A Tcl script to manage a telephone directory

# Global variable to store the phone directory
global phonebook
set phonebook {}

# Procedure to read the phonebook file
proc readBook {filename} {
    global phonebook
    set phonebook {}
    
    if {![file exists $filename]} {
        puts "Error: File '$filename' not found."
        return
    }
    
    set file [open $filename r]
    while {[gets $file line] >= 0} {
        set fields [split $line ":"]
        if {[llength $fields] == 4} {
            lappend phonebook $fields
        }
    }
    close $file
    puts "Phonebook loaded successfully."
}

# Procedure to search by name
proc phone {name} {
    global phonebook
    set results {}
    
    foreach entry $phonebook {
        set surname [lindex $entry 0]
        set firstname [lindex $entry 1]
        
        if {[string match *$name* $surname] || [string match *$name* $firstname]} {
            lappend results $entry
        }
    }
    
    if {[llength $results] == 0} {
        puts "No entry found for '$name'."
    } else {
        foreach result $results {
            puts "[join $result ":"]"
        }
    }
}

# Procedure to search by phone number
proc who {number} {
    global phonebook
    set results {}
    
    foreach entry $phonebook {
        set phone [lindex $entry 3]
        
        if {[string match *$number* $phone]} {
            lappend results $entry
        }
    }
    
    if {[llength $results] == 0} {
        puts "No entry found for '$number'."
    } else {
        foreach result $results {
            puts "[join $result ":"]"
        }
    }
}
