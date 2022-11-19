set ns [new Simulator]
$ns rtproto DV
set nf [open mesh.nam w]
$ns namtrace-all $nf
set tr [open mesh.tr w]
$ns trace-all $tr
set N 10
set pktsize [lindex $argv 0]

proc finish {} {
	global ns nf tr
	$ns flush-trace
	close $nf
	exec nam mesh.nam &
	exec awk -f ../throughput.awk mesh.tr > throughput_output &
	exit 0
}

for {set i 0} {$i < $N} {incr i} {	
	set n($i) [$ns node]
}
for {set i 0} {$i < $N} {incr i} {
    if {([expr $i%2]==1)} {
        for {set j 0} {$j < $N} {incr j} {
            if {($i<$j||$i>$j)} {
                $ns duplex-link $n($i) $n($j) 1Mb 10ms DropTail
            }
	    }
    }
}

for {set i 1} {$i < $N} {incr i} {
	if {[expr $i%2]==1} {
		set udp($i) [new Agent/UDP]
		$ns attach-agent $n([expr ($i)]) $udp($i)
		set null($i) [new Agent/Null]
		$ns attach-agent $n([expr ($i)-1]) $null($i)
		$ns connect $udp($i) $null($i)
		set cbr($i) [new Application/Traffic/CBR]
		$cbr($i) attach-agent $udp($i)
		$cbr($i) set packetSize_ $pktsize
		$cbr($i) set interval_ 0.005
	}
}

if ($N%2) {
	set udp($N+1) [new Agent/UDP]
 	$ns attach-agent $n([expr ($N%2)]) $udp($N+1)
 	set cbr($N+1) [new Application/Traffic/CBR]
	$cbr($N+1) attach-agent $udp($N+1)
	$cbr($N+1) set packetSize_ $pktsize
	$cbr($N+1) set interval_ 0.005
	set null($N) [new Agent/Null]
	$ns attach-agent $n([expr ($N-1)]) $null($N)
	$ns connect $udp($N+1) $null($N)
	$ns  at 0.5 "$cbr($N+1) start"
 	
}
for {set i 0} {$i < $N} {incr i} {
	if {[expr $i%2]!=0} {
		$ns  at 0.5 "$cbr($i) start"
	}
}

for {set i 0} {$i < $N} {incr i} {
	if { [expr $i%2]!=0 } {
		$ns at 4.5 "$cbr($i) stop"
	}
}
$ns at 5.0 "finish"
$ns run
