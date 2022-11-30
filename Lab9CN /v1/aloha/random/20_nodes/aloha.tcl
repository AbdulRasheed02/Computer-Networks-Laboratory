#This is the simulation of a network with MAC Protocol = slotted aloha.


set ns [new Simulator]

#Tell the simulator to use dynamic routing
$ns rtproto DV
$ns macType Mac/Sat/SlottedAloha

#Open the nam trace file
set nf [open out.nam w]
$ns namtrace-all $nf

#Open the output files
set f0 [open out1.tr w]
$ns trace-all $f0

#Define a finish procedure
proc finish {} {
  global ns f0 nf
  $ns flush-trace

#Close the trace file
  close $f0
  close $nf
  exec nam out.nam &
  exit 0
}

#Create 10 nodes 
set n0 [$ns node] 
set n1 [$ns node] 
set n2 [$ns node] 
set n3 [$ns node] 
set n4 [$ns node] 
set n5 [$ns node] 
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]
set n9 [$ns node]
set n10 [$ns node] 
set n11 [$ns node]
set n12 [$ns node]
set n13 [$ns node]
set n14 [$ns node]
set n15 [$ns node]
set n16 [$ns node]
set n17 [$ns node]
set n18 [$ns node]
set n19 [$ns node]



# Create duplex links between nodes with bandwidth and distance
# linear topology
$ns duplex-link $n0 $n1 1Mb 10ms DropTail
$ns duplex-link $n0 $n1 1Mb 10ms DropTail
$ns duplex-link $n1 $n2 1Mb 10ms DropTail
$ns duplex-link $n2 $n3 1Mb 10ms DropTail
$ns duplex-link $n3 $n4 1Mb 10ms DropTail
$ns duplex-link $n4 $n5 1Mb 10ms DropTail
$ns duplex-link $n5 $n6 1Mb 10ms DropTail
$ns duplex-link $n6 $n7 1Mb 10ms DropTail
$ns duplex-link $n7 $n8 1Mb 10ms DropTail
$ns duplex-link $n8 $n9 1Mb 10ms DropTail
$ns duplex-link $n9 $n10 1Mb 10ms DropTail
$ns duplex-link $n10 $n11 1Mb 10ms DropTail
$ns duplex-link $n11 $n12 1Mb 10ms DropTail
$ns duplex-link $n12 $n13 1Mb 10ms DropTail
$ns duplex-link $n13 $n14 1Mb 10ms DropTail
$ns duplex-link $n14 $n15 1Mb 10ms DropTail
$ns duplex-link $n15 $n16 1Mb 10ms DropTail
$ns duplex-link $n16 $n17 1Mb 10ms DropTail
$ns duplex-link $n17 $n18 1Mb 10ms DropTail
$ns duplex-link $n18 $n19 1Mb 10ms DropTail
$ns duplex-link $n16 $n5 1Mb 10ms DropTail
$ns duplex-link $n17 $n4 1Mb 10ms DropTail
$ns duplex-link $n18 $n4 1Mb 10ms DropTail

# Create a duplex link between nodes 4 and 5 as queue position
$ns duplex-link-op $n4 $n5 queuePos 0.5

#Create a UDP agent and attach it to node n(0)
set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0

# Create a CBR traffic source and attach it to udp0
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.5
$cbr0 attach-agent $udp0

#Create a Null agent (a traffic sink) and attach it to node n(3)
set null0 [new Agent/Null]
$ns attach-agent $n2 $null0

#Connect the traffic source with the traffic sink
$ns connect $udp0 $null0

#Schedule events for the CBR agent and the network dynamics
$ns at 0.5 "$cbr0 start" 
$ns at 4.5 "$cbr0 stop"

#Call the finish procedure after 5 seconds of simulation time
$ns at 5.0 "finish"

#Run the simulation
$ns run