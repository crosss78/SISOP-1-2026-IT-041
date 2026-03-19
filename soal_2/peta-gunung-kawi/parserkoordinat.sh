#!/bin/bash

awk '
    /"id":/ {
    match($0, /"id": "([^"]+)"/, i)
    id = i[1]}

    /"site_name":/ {
    match($0, /"site_name": "([^"]+)"/, s)
    site = s[1]}

    /"latitude":/ {
    match($0, /"latitude": ([^,]+)/, lat)
    latitude = lat[1]}

    /"longitude":/ {
    match ($0, /"longitude": ([^,]+)/, long)
    longitude = long[1]}

    /^}/ {
    {if(id && site && latitude && longitude) print id "," site "," latitude "," longitude}
    }
    ' gsxtrack.json | sort -u > titik-penting.txt
echo "File udah di parser dan disimpen dengan nama titik-penting.txt. Silakan di cek..."
