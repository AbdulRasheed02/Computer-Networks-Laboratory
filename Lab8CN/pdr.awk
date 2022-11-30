BEGIN {
	sent = 0;
	recvd = 0;
	end_time = 20.0;
}
{
	if ($2 > end_time) {
		printf("%d\t%f\n", end_time, recvd/sent);
		end_time = end_time + 20.0;
		sent = 0;
		recvd = 0;
	}
	if (($1 == "+") && ($3 >= 0 && $3 <=  12)) {
		sent++;
	}
	if (($1 == "r") && ($4 >= 2 || $4 <= 14) && $5 == "tcp") {
		recvd++;
	}
}
END {
	printf("%d\t%f\n", end_time, recvd/sent);
}