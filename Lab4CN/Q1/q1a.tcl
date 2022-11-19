
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

$ns duplex-link $n0 $n3 2Mb 4ms DropTail
$ns duplex-link $n1 $n3 2Mb 4ms DropTail
$ns duplex-link $n2 $n3 2Mb 4ms DropTail
$ns duplex-link $n4 $n3 2Mb 4ms DropTail

$ns duplex-link-op $n0 $n3 orient right-down      
$ns duplex-link-op $n1 $n3 orient right 
$ns duplex-link-op $n2 $n3 orient right-up
$ns duplex-link-op $n3 $n4 orient right 

#Sink Nodes
set sink0 [new Agent/TCPSink]
$ns attach-agent $n3 $sink0

set sink1 [new Agent/TCPSink]
$ns attach-agent $n4 $sink1

#Source Nodes
set tcp0 [new Agent/TCP]
$tcp0 set class_ 1
$ns attach-agent $n0 $tcp0
set ftp0 [new Application/FTP]
$ftp0 set type_ FTP
$ftp0 set packetSize_ 500
$ftp0 set rate_ 1mb
$ftp0 attach-agent $tcp0

set tcp1 [new Agent/TCP]
$tcp1 set class_ 2
$ns attach-agent $n1 $tcp1
set ftp1 [new Application/FTP]
$ftp1 set type_ FTP
$ftp1 set packetSize_ 500
$ftp1 set rate_ 1mb
$ftp1 attach-agent $tcp1

$ns connect $tcp0 $sink1
$ns connect $tcp1 $sink0

$ns at 0.1 "$ftp0 start"
$ns at 0.1 "$ftp1 start"

$ns at 60.1 "$ftp0 stop"
$ns at 60.1 "$ftp1 stop"

$ns at 61.0 "finish"

$ns run
