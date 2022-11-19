set ns [new Simulator]

set tr [open "out.tr" w]
$ns trace-all $tr

set fr [open "out.nam" w]
$ns namtrace-all $fr

set n0 [$ns node]
set n1 [$ns node]

$ns duplex-link $n0 $n1 2Mb 4ms DropTail

set tcp1 [new Agent/TCP]
set sink [new Agent/TCPSink]

$ns attach-agent $n0 $tcp1
$ns attach-agent $n1 $sink

$ns connect $tcp1 $sink

set ftp [new Application/FTP]
$ftp attach-agent $tcp1

proc finish { } {
    global ns tr fr
    $ns flush-trace
    close $tr
    close $fr
    exec nam out.nam &
    exit
}

$ns at .1 "$ftp start"
$ns at 2.0 "$ftp stop"

$ns at 2.1 "finish"

$ns run
