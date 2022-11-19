set ns [new Simulator]

set tr [open q3.tr w]
$ns trace-all $tr

set ntr [open out.nam w]
$ns namtrace-all $ntr

set f0 [open q3boutput.tr w]

$ns color 1 Blue
$ns color 2 Red

proc finish { } {
    global ns tr ntr f0
    $ns flush-trace
    close $tr
    close $ntr
    close $f0
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

#Source
set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
$tcp0 set fid_ 1

set tcp2 [new Agent/TCP]
$ns attach-agent $n2 $tcp2
$tcp2 set fid_ 2

#Sink
set sink3 [new Agent/TCPSink]
$ns attach-agent $n3 $sink3

set sink4 [new Agent/TCPSink]
$ns attach-agent $n4 $sink4

#Generating Traffic
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0

set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2

$ns connect $tcp0 $sink4
$ns connect $tcp2 $sink3

proc record {} {
        global sink3 sink4 f0 
        set ns [Simulator instance]
        set time 0.5
        set bw0 [$sink3 set bytes_]
        set bw1 [$sink4 set bytes_]
        set now [$ns now]
        set temp1 [expr $bw0/$time*8/1000000]
        set temp2 [expr $bw1/$time*8/1000000]
        puts $f0 "$now [expr $temp1+$temp2]"
        $sink3 set bytes_ 0
        $sink4 set bytes_ 0
        $ns at [expr $now+$time] "record"
}

$ns at 0.0 "record"

$ns at 0.0 "$ftp0 start"
$ns at 10.0 "$ftp2 start"

$ns at 60.1 "$ftp0 stop"
$ns at 60.1 "$ftp2 stop"

$ns at 62.0 "finish"

$ns run

