set ns [new Simulator]

set tr [open "q2.tr" w]
$ns trace-all $tr

set fr [open "q2.nam" w]
$ns namtrace-all $fr

$ns color 1 Blue
$ns color 2 Red

proc finish {} {
        global ns tr fr
        $ns flush-trace
        close $tr
        close $fr
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
$ns duplex-link $n3 $n4 2Mb 4ms DropTail

$ns duplex-link-op $n0 $n3 orient right-down
$ns duplex-link-op $n1 $n3 orient right
$ns duplex-link-op $n2 $n3 orient right-up
$ns duplex-link-op $n3 $n4 orient right

# #Source
set udp0 [new Agent/UDP]
$udp0 set fid_ 1
$ns attach-agent $n0 $udp0
set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0

set udp1 [new Agent/UDP]
$udp0 set fid_ 2
$ns attach-agent $n1 $udp1
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1

#Sink
set null [new Agent/Null]
$ns attach-agent $n4 $null

$ns connect $udp0 $null
$ns connect $udp1 $null

$ns at 0.1 "$cbr0 start"
$ns at 5.1 "$cbr1 start"

$ns at 150.1 "$cbr0 stop"
$ns at 150.1 "$cbr1 stop"

$ns at 151.0 "finish"

$ns run