BEGIN {
	end_time = 10.0;
	congestions = 0;
}
{
	if ($2 > end_time) {
		printf("%f\t%f\n", end_time, congestions/10.0);
		congestions = 0;
		end_time += 10.0;
	}
	if (($1 == "+") && ($3 == $4-25) && ($5 == "ack")) {
		acks[$4$3$11]++;
		if (acks[$4$3$11] % 3 == 0)
			congestions++;
	}
}
END {
	printf("%f\t%f\n", end_time, congestions/10.0);
}