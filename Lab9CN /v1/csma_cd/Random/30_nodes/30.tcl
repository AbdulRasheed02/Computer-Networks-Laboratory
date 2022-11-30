# Setup Simulator
set ns [new Simulator]
LanRouter set debug_ 0
# Set initial values
set opt(n) 5
set opt(r) 0.1Mb
set opt(nc) 1Mb
set opt(cd) 0

# Command line instructions for running the script
proc usage {} {
    global argv0
    puts "Usage: $argv0 \[-n NumberOfNodes\]  \[-nc NetworkCapacity\] \[-r TrafficRate\] \[-cd EnableCollisionDetectionOrNot\] \n"
    exit 1
}

# Get opt parameters
proc getopt {argc argv} {
    global opt
    lappend optlist n r cd
    if {$argc < 4} usage
    for {set i 0} {$i < $argc} {incr i} {
        set arg [lindex $argv $i]
        if {[string range $arg 0 0] != "-"} continue
        set name [string range $arg 1 end]
        set opt($name) [lindex $argv [expr $i+1]]
    }
}

getopt $argc $argv

# Set different colors for different data flow
$ns color 1 Blue
$ns color 2 Red
$ns color 3 Green

# Open the trace files
set file1 [open out1.tr w]
$ns trace-all $file1

# Open the nam trace file
set nf [open out.nam w]
$ns namtrace-all $nf

# Define a finish procedure
proc finish {} {
    global ns nf file1
    $ns flush-trace
    close $nf
    close $file1
    exec nam out.nam &
    exit 0
}

# Create nodes
set num 30
for {set i 0} {$i <= $num} {incr i} {
    set node($i) [$ns node]
    lappend nodelist $node($i)
}

# Create links
set link(0) [$ns duplex-link $node(0) $node(1) $opt(r) $opt(nc) DropTail]
set link(1) [$ns duplex-link $node(1) $node(2) $opt(r) $opt(nc) DropTail]
set link(2) [$ns duplex-link $node(2) $node(3) $opt(r) $opt(nc) DropTail]
set link(3) [$ns duplex-link $node(3) $node(4) $opt(r) $opt(nc) DropTail]
set link(4) [$ns duplex-link $node(4) $node(5) $opt(r) $opt(nc) DropTail]
set link(5) [$ns duplex-link $node(5) $node(6) $opt(r) $opt(nc) DropTail]
set link(6) [$ns duplex-link $node(6) $node(7) $opt(r) $opt(nc) DropTail]
set link(7) [$ns duplex-link $node(7) $node(8) $opt(r) $opt(nc) DropTail]
set link(8) [$ns duplex-link $node(8) $node(9) $opt(r) $opt(nc) DropTail]
set link(9) [$ns duplex-link $node(9) $node(0) $opt(r) $opt(nc) DropTail]
set link(10) [$ns duplex-link $node(10) $node(11) $opt(r) $opt(nc) DropTail]
set link(11) [$ns duplex-link $node(11) $node(12) $opt(r) $opt(nc) DropTail]
set link(12) [$ns duplex-link $node(12) $node(13) $opt(r) $opt(nc) DropTail]
set link(13) [$ns duplex-link $node(13) $node(14) $opt(r) $opt(nc) DropTail]
set link(14) [$ns duplex-link $node(14) $node(15) $opt(r) $opt(nc) DropTail]
set link(15) [$ns duplex-link $node(15) $node(16) $opt(r) $opt(nc) DropTail]
set link(16) [$ns duplex-link $node(16) $node(17) $opt(r) $opt(nc) DropTail]
set link(17) [$ns duplex-link $node(17) $node(18) $opt(r) $opt(nc) DropTail]
set link(18) [$ns duplex-link $node(18) $node(19) $opt(r) $opt(nc) DropTail]
set link(19) [$ns duplex-link $node(19) $node(10) $opt(r) $opt(nc) DropTail]
set link(20) [$ns duplex-link $node(20) $node(21) $opt(r) $opt(nc) DropTail]
set link(21) [$ns duplex-link $node(21) $node(22) $opt(r) $opt(nc) DropTail]
set link(22) [$ns duplex-link $node(22) $node(23) $opt(r) $opt(nc) DropTail]
set link(23) [$ns duplex-link $node(23) $node(24) $opt(r) $opt(nc) DropTail]
set link(24) [$ns duplex-link $node(24) $node(25) $opt(r) $opt(nc) DropTail]
set link(25) [$ns duplex-link $node(25) $node(26) $opt(r) $opt(nc) DropTail]
set link(26) [$ns duplex-link $node(26) $node(27) $opt(r) $opt(nc) DropTail]
set link(27) [$ns duplex-link $node(27) $node(28) $opt(r) $opt(nc) DropTail]
set link(28) [$ns duplex-link $node(28) $node(29) $opt(r) $opt(nc) DropTail]
set link(29) [$ns duplex-link $node(29) $node(20) $opt(r) $opt(nc) DropTail]


# Create LAN Connection between nodes according to CD preference
if {$opt(cd) == "1"} {
    set lan0 [$ns make-lan $nodelist $opt(nc) 30ms LL Queue/DropTail Mac/Csma/Cd Channel]
} else {
    set lan0 [$ns make-lan $nodelist $opt(nc) 30ms LL Queue/DropTail Mac/Sat/UnslottedAloha Channel]
}

# Create CBR Traffic with UDP Connection
for {set i 1} {$i <= $num} {incr i} {
    # Setup a UDP Connection
    set udp($i) [new Agent/UDP]
    $ns attach-agent $node($i) $udp($i)

    set null($i) [new Agent/Null]
    $ns attach-agent $node(0) $null($i)
    $ns connect $udp($i) $null($i)

    # Create a CBR Traffic source and attach to udp0
    set cbr($i) [new Application/Traffic/CBR]
    $cbr($i) set packet_size_ 1024
    $cbr($i) set rate_ $opt(r)
    $cbr($i) attach-agent $udp($i)

    $udp($i) set fid_ [expr ($i%3)+1]


    # Schedule events for CBR agents
    $ns at 0.1 "$cbr($i) start"
    $ns at 5.5 "$cbr($i) stop"
}

# Call the finish procedure
$ns at 6.0 "finish"

$ns run