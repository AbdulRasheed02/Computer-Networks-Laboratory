#Create a simulator object
set ns [new Simulator]

#Define different colors for data flows (for NAM)
$ns color 0 Blue
$ns color 1 Red
$ns color 3 green
$ns color 4 cyan
$ns color 5 yellow
$ns color 6 orange
$ns color 7 black
$ns color 8 purple
$ns color 9 gold
$ns color 10 maroon
$ns color 11 violet
$ns color 12 brown

#Open the nam trace file
set nf [open out.nam w]
$ns namtrace-all $nf

set all_trace [open all.tr w]
$ns trace-all $all_trace

set N 25
set traffic [lindex $argv 0]

if { $traffic == "low" } {
	set nsrc 3
} elseif { $traffic == "medium" } {
	set nsrc 8
} else {
	set nsrc 13
}

#Define a 'finish' procedure
proc finish {} {
        global ns nf all_trace traffic
        $ns flush-trace
        #Close the trace file
        close $nf
        close $all_trace
        #Execute nam on the trace file
        exec nam out.nam &
	exec awk -f ../pdr.awk all.tr > ${traffic}_reno_pdr_out &
	exec awk -f ../overhead.awk all.tr > ${traffic}_reno_overhead_out &
	exec awk -f ../congestionrate.awk all.tr > ${traffic}_reno_congestion_out &
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

for {set i 0} {$i < $nsrc} {incr i} {
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

for {set i 0} {$i < $nsrc} {incr i} {
	$ns  at 0.0 "$ftp($i) start"
}

for {set i 0} {$i < $nsrc} {incr i} {
	$ns at 50.0 "$ftp($i) stop"
}

$ns at 50.0 "finish"

#Run the simulation
$ns run