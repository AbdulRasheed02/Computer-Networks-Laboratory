BEGIN {
	control_packets = 0;
	total_packets = 0;
}
{

	if (($1 == "+")) {
		total_packets++;
		
		if (($5 == "ack"))
			control_packets++;
	}
}
END {
	printf("Overhead : \t%f\n",control_packets/total_packets);
}
