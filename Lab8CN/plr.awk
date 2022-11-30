BEGIN{
    pktsend=0;
    pktrec=0;
    ctime=20.0;
}
{
    e=$1;
   
    if ($2 > ctime) {
    	if(pktrec > pktsend) {
		printf("%d\t%f\n", ctime, -(1-pktrec/pktsend));
		ctime = ctime + 20.0;
		pktsend = 0;
		pktrec = 0;
		}
	else {
		printf("%d\t%f\n", ctime, (1-pktrec/pktsend));
		ctime = ctime + 20.0;
		pktsend = 0;
		pktrec = 0;
		}  
	}
    if(e =="r" && ($4 == 2))
    {
        pktrec++;
    }
    if(e =="+" && ($3 == 0))
    {
        pktsend++;
    }
}
END{
    	if(pktrec > pktsend) {
		printf("%d\t%f\n", ctime, -(1-pktrec/pktsend));
		
		}
	else {
		printf("%d\t%f\n", ctime, (1-pktrec/pktsend));
		
		}  
    #printf("%d\t%f", ctime, (1-pktrec/pktsend));
}
