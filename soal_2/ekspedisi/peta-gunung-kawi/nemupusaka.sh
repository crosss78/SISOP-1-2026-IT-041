#!/bin/bash

awk '
BEGIN{FS=","}
NR==1 {lat1=$3; lon1=$4}
NR==3 {lat2=$3; lon2=$4}
END {
    mid_lat = (lat1 + lat2)/2
    mid_lon = (lon1 + lon2)/2
    printf "Koordinat pusat:\n%.6f,%.6f\n", mid_lat, mid_lon
}
' titik-penting.txt > posisipusaka.txt
cat posisipusaka.txt
echo "File udah kesimpen namanya: posisipusaka.txt"
