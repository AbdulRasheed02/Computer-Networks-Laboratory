#Create a simulator object
set ns [new Simulator]

#Open the nam trace file
set nf [open ctf.nam w]
$ns namtrace-all $nf
set tr [open ctf.tr w]
$ns trace-all $tr
set N 25
set nSource 10

#Define a 'finish' procedure
proc finish {} {
        global ns nf tr traffic
        $ns flush-trace
        close $nf
        close $tr
        exec nam ctf.nam &
		exec awk -f overhead.awk ctf.tr > modified_dvr_overhead_out &
		exec awk -f pdr.awk ctf.tr > modified_dvr_pdr_out &
	exit 0
}

for {set i 0} {$i < [expr 2*$N]} {incr i} {
	set n($i) [$ns node]
}

for {set i $N} {$i < [expr 2*$N-1]} {incr i} {
	$ns duplex-link $n($i) $n([expr $i+1]) 1Mb 10ms DropTail
	$ns duplex-link-op $n($i) $n([expr $i+1]) orient right
    $ns queue-limit $n($i) $n([expr $i+1]) 20
}

for {set i 0} {$i < $N} {incr i} {
	$ns duplex-link $n($i) $n([expr $i+$N]) 1Mb 10ms DropTail
	$ns duplex-link-op $n($i) $n([expr $i+$N]) orient down
}

for {set i 0} {$i < 12} {incr i} {
	$ns duplex-link $n($i) $n([expr $N-$i-1]) 1Mb 10ms DropTail
    $ns duplex-link-op $n($i) $n([expr $i+$N]) orient right
}

for {set i 0} {$i < $nSource} {incr i} {
	#Setup a TCP connection
	set tcp($i) [new Agent/TCP/Reno]
	$tcp($i) set class_ 2
	$ns attach-agent $n($i) $tcp($i)
	set sink($i) [new Agent/TCPSink]
	$ns attach-agent $n([expr $i+2]) $sink($i)
	$ns connect $tcp($i) $sink($i)
	$tcp($i) set fid_ $i

	#Setup a FTP over TCP connection
	set ftp($i) [new Application/FTP]
	$ftp($i) attach-agent $tcp($i)
	$ftp($i) set type_ FTP
}

$ns rtproto DV

$ns rtmodel-at 1.0 down $n(0) $n(24)
$ns rtmodel-at 1.0 down $n(5) $n(19)
$ns rtmodel-at 1.0 down $n(10) $n(35)
$ns rtmodel-at 1.0 down $n(32) $n(33)
$ns rtmodel-at 1.0 down $n(28) $n(29)

$ns rtmodel-at 20.0 up $n(0) $n(24)
$ns rtmodel-at 30.0 up $n(5) $n(19)
$ns rtmodel-at 40.0 up $n(10) $n(35)
$ns rtmodel-at 40.0 up $n(32) $n(33)
$ns rtmodel-at 40.0 up $n(28) $n(29)

for {set i 0} {$i < $nSource} {incr i} {
	$ns  at 0.0 "$ftp($i) start"
}

for {set i 0} {$i < $nSource} {incr i} {
	$ns at 100.0 "$ftp($i) stop"
}   

$ns at 100.0 "finish"
$ns run