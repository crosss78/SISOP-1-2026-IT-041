BEGIN {
    FS = ","
    opsi = ARGV[2]
    # Hapus agar tidak dianggap file input
    delete ARGV[2]
}

{
 if(NR>1)
 {
    if(opsi == "a") {
        count++
    }
    else if (opsi == "b"){
        c[$4]++
    }
    else if (opsi == "c"){
        if($2>max){name=$1;max=$2}
    }
    else if (opsi == "d"){
        count++;sum+=$2
    }
    else if (opsi == "e"){
        if ($3=="Business"){count++}
    }
    else{
        print "Soal tidak dikenali. Gunakan a, b, c, d, atau e.\nContoh penggunaan: awk -f KANJ.sh passenger.csv a"
        exit
    }
 }
}

# Blok END harus berdiri sendiri di luar
END {
    if (opsi == "a") {
        print "Jumlah seluruh penumpang KANJ adalah " count " orang"
    }
    else if (opsi == "b"){
        print "Jumlah gerbong penumpang KANJ adalah " length(c)-1 
    }
    else if (opsi == "c"){
        print name " adalah penumpang kereta tertua dengan usia " max " tahun"
    }
    else if (opsi == "d"){
        printf ("Rata-rata usia penumpang adalah %d tahun\n", sum/count)
    }
    else if (opsi == "e"){
        print "Jumlah penumpang kelas bisnis ada " count " orang"
    }
}
