#Create a simulator object
set ns [new Simulator]

#Open the nam trace file
set nf [open outModified.nam w]
$ns namtrace-all $nf
set tr [open allModified.tr w]
$ns trace-all $tr
set N 50
set nSource 50

#Define a 'finish' procedure
proc finish {} {
        global ns nf tr traffic
        $ns flush-trace
        close $nf
        close $tr
        exec nam outModified.nam &
		exec awk -f pdr.awk allOriginal.tr > original_tahoe_pdr_out &
        exec awk -f overhead.awk allOriginal.tr > original_tahoe_overhead_out &
        exec awk -f congestionrate.awk allOriginal.tr > original_tahoe_congestion_out &
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

for {set i 0} {$i < $nSource} {incr i} {
	$ns  at 0.0 "$ftp($i) start"
}

for {set i 0} {$i < $nSource} {incr i} {
	$ns at 50.0 "$ftp($i) stop"
}

$ns at 50.0 "finish"
$ns run