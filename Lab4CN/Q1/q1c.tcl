
set ns [new Simulator]

set nf [open out.nam w]
$ns namtrace-all $nf

$ns color 1 Blue
$ns color 2 Red

proc finish {} {
        global ns nf
        $ns flush-trace
        close $nf
        exec nam out.nam &
        exit 0
}

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]

$ns duplex-link $n0 $n1 2Mb 4ms DropTail
$ns duplex-link $n0 $n2 2Mb 4ms DropTail
$ns duplex-link $n1 $n3 2Mb 4ms DropTail
$ns duplex-link $n1 $n4 2Mb 4ms DropTail
$ns duplex-link $n2 $n5 2Mb 4ms DropTail
$ns duplex-link $n2 $n6 2Mb 4ms DropTail

$ns duplex-link-op $n0 $n1 orient left-down
$ns duplex-link-op $n0 $n2 orient right-down      
$ns duplex-link-op $n1 $n3 orient left-down
$ns duplex-link-op $n1 $n4 orient right-down    
$ns duplex-link-op $n2 $n5 orient left-down
$ns duplex-link-op $n2 $n6 orient right-down  

#Source Nodes
set tcp0 [new Agent/TCP]
$tcp0 set class_ 1
$ns attach-agent $n0 $tcp0
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0

set tcp1 [new Agent/TCP]
$tcp1 set class_ 2
$ns attach-agent $n5 $tcp1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

#Sink Nodes
set sink0 [new Agent/TCPSink]
$ns attach-agent $n3 $sink0

set sink1 [new Agent/TCPSink]
$ns attach-agent $n6 $sink1

$ns connect $tcp0 $sink0
$ns connect $tcp1 $sink1

$ns at 0.1 "$ftp0 start"
$ns at 5.1 "$ftp1 start"

$ns at 60.1 "$ftp0 stop"
$ns at 60.1 "$ftp1 stop"

$ns at 61.0 "finish"

$ns run
