BEGIN {
recvsize=0;
currenttime=0;
}
{
event = $1;
toNode = $4;
currenttime = $2;
if(event =="r" && toNode=="5" ) {
recvsize+=$6;
}
}
END {
printf("Throughput : %f\n", (8*recvsize)/(100000*currenttime));
}