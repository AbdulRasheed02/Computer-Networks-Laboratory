

#PROGRAM: CSMA/CA 

set ns [new Simulator] 

#Define different colors for data flows (for NAM) 
$ns color 1 Blue 
$ns color 2 Red 

#Open the Trace files 
set file1 [open out1.tr w] 
set winfile [open WinFile w] 
$ns trace-all $file1 

#Open the NAM trace file 
set file2 [open out.nam w] 
$ns namtrace-all $file2 

#Define a 'finish' procedure 
proc finish {} { 
global ns file1 file2 
$ns flush-trace 
close $file1 
close $file2 
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

# linear topology
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


set lan [$ns newLan "$n0 $n1 $n2 $n3 $n4 $n5 $n8 $n10" 0.5Mb 40ms LL Queue/DropTail MAC/Csma/Ca Channel] 
# Setup a TCP connection 
set tcp [new Agent/TCP/Newreno] 
$ns attach-agent $n0 $tcp 
set sink [new Agent/TCPSink/DelAck] 
$ns attach-agent $n4 $sink 
$ns connect $tcp $sink 
$tcp set fid_ 1 
$tcp set window_ 8000 
$tcp set packetSize_ 552 
#Setup a FTP over TCP connection 
set ftp [new Application/FTP] 
$ftp attach-agent $tcp 
$ftp set type_ FTP 
#Setup a UDP connection 
set udp [new Agent/UDP] 
$ns attach-agent $n1 $udp 
set null [new Agent/Null] 
$ns attach-agent $n5 $null 
$ns connect $udp $null 
$udp set fid_ 2 
#Setup a CBR over UDP connection 
set cbr [new Application/Traffic/CBR] 
$cbr attach-agent $udp 
$cbr set type_ CBR 
$cbr set packet_size_ 1000 
$cbr set rate_ 0.01mb 
$cbr set random_ false 
$ns at 0.1 "$cbr start" 
$ns at 1.0 "$ftp start" 
$ns at 124.0 "$ftp stop" 
$ns at 124.5 "$cbr stop" 
# next procedure gets two arguments: the name of the 
# tcp source node, will be called here "tcp", 
# and the name of output file. 
proc plotWindow {tcpSource file} { 
global ns 
set time 0.1 
set now [$ns now] 
set cwnd [$tcpSource set cwnd_] 
set wnd [$tcpSource set window_] 
puts $file "$now $cwnd" 
$ns at [expr $now+$time] "plotWindow $tcpSource $file" } 
$ns at 0.1 "plotWindow $tcp $winfile"
$ns at 5 "$ns trace-annotate \"packet drop\"" 
# PPP 
$ns at 125.0 "finish" 
$ns run