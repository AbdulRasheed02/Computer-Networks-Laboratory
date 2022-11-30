BEGIN {
	control_packets = 0;
	total_packets = 0;
	end_time = 20.0;
}
{
	if ($2 > end_time) {
		printf("%d\t%f\n", end_time, control_packets/total_packets);
		control_packets = 0;
		total_packets = 0;
		end_time = end_time + 20.0;
	}

	if (($1 == "+")) {
		total_packets++;
		
		if (($5 == "ack"))
			control_packets++;
	}
}
END {
	printf("%d\t%f\n", end_time, control_packets/total_packets);
}