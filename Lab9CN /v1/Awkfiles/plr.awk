BEGIN {
    pksend=0;
    pktrec=0;
}
{
    event = $1;
    toNode = $4;
    fromNode = $3;
    currenttime = $2;
    if(event =="r" && (toNode=="9" || toNode=="5")){
        pktrec++;
    }
    if(event=="+" && (fromNode=="1" || fromNode=="2")){
        pksend++;
    }
}
END {
    printf("PLR : %f\n",(pksend-pktrec)/pksend);
}