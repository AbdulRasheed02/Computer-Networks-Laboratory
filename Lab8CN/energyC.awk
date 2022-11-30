#packet delivery ratio
BEGIN{
    rcvsize=0;
    ctime=20.0;
}
{
    e=$1;
    #Trace File current destination
    tf_dest=$4;
    #Trace File current source
    tf_src=$3;
    if ($2 > ctime) {
        printf("%d\t%f\n", ctime, (8*rcvsize)/(100000));
        ctime = ctime + 20.0;
        pktsend = 0;
        pktrec = 0;
    }
    if(e =="r" && tf_dest==dest)
    {
        rcvsize+=$6;
    }
}
END{
    printf("%d\t%f ", ctime,(8*rcvsize)/(100000));
}
