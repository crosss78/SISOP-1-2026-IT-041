# SISOP-1-2026-IT-041

| Nama                   | NRP        |
| ---------------------- | ---------- |
| Muhamad Sabilil Haq    | 5027251041 |

## Soal 1

Pertama, download dulu file ``passenger.csv``, kemudian lihat dulu sebagian isi dari filenya menggunakan command ``cat passenger.csv | head``

![alt text](assets/soal_1/0.png)

### a. Menghitung total penumpang
Untuk menghitung total penumpang, bisa dengan menjumlahkan keseluruhan barisnya menggunakan command:

```
awk 'NR>1 {count++} END{print "Jumlah seluruh penumpang KANJ adalah " count " orang"}' passenger.csv
```

![alt text](assets/soal_1/1.png)

yang mana ``NR>1`` untuk memfilter header agar tidak terhitung sebagai penumpang.

### b. Menghitung total gerbong
Untuk menghitung total gerbong pada kereta, bisa dengan command:

```
awk '{FS=","} NR>1 {c[$3"-"$4]++} END{print length(c)}' passenger.csv
```

![alt text](assets/soal_1/2.png)

yang mana ``{FS=","}`` untuk memisahkan kolom karena dalam file ``csv`` karakter ``koma(,)`` itu merupakan pemisah antar kolom. Kemudian, ``{c[$3"-"$4]++}`` gunanya untuk meng-increment setiap kali ada pasangan unik dari kolom ke-3 dan ke-4, di akhir, command tersebut akan mengeprint banyaknya gerbong pada kereta tersebut.

Untuk memastikan gerbongnya tidak ada yang duplikat, kita dapat mengeceknya menggunakan command:

```
awk '{FS=","} NR>1 {c[$3"-"$4]++} END{for (l in c) print l}' passenger.csv
```

![alt text](assets/soal_1/3.png)

Ternyata, ``Business-Gerbong3`` terduplikat bukan karena datanya benar-benar ada dua yang sama, melainkan karena terdapat perbedaan karakter tersembunyi (whitespace) seperti spasi di awal atau akhir teks. Sehingga, untuk mendapat total gerbong yang tepat, kita dapat mengurangi ``length(c)`` dengan ``1``.

```
awk '{FS=","} NR>1 {c[$3"-"$4]++} END{print "Jumlah gerbong penumpang KANJ adalah " length(c)-1}' passenger.csv
```

![alt text](assets/soal_1/4.png)

### c. Mengecek penumpang dengan usia tertua
Untuk mengeceknya, dapat dengan membandingkan nilai pada kolom kedua satu per satu. Kemudian, nilai yang paling besar nantinya akan di set nama dan usianya, sebagai penumpang tertua.

```
awk '{FS=","} NR>1 {if($2>max){name=$1;max=$2}} END{print name " adalah penumpang kereta tertua dengan usia " max " tahun"}' passenger.csv
```

![alt text](assets/soal_1/5.png)

yang menarik dari awk itu sendiri, dia dapat mendeklarasikan variabel secara langsung tanpa menginisiasinya terlebih dahulu. Jadinya, variabel ``max`` disana secara default nilainya 0, sehingga bisa langsung membandingkan kolom ke-2 satu per satu secara langsung. Kemudian, karakter ``semi-colon(;)`` itu sama saja dengan ``enter``.

### d. Menghitung rata rata usia penumpang
Untuk menghitung rata ratanya dan membulatkannya, dapat menggunakan command:

```
awk '{FS=","} NR>1 {count++;sum+=$2} END{printf ("Rata-rata usia penumpang adalah %.0f tahun\n", sum/count)}' passenger.csv
```

![alt text](assets/soal_1/6.png)

Jika dilihat, pada proses print, itu syntaxnya sama dengan bahasa C. Di bagian, ``NR>1 {count++;sum+=$2}`` ``sum`` digunakan untuk menjumlahkan seluruh usia penumpang dan ``count`` sebagai pembaginya (total penumpang).

### e. Menghitung total penumpang kategori kursi kelas bisnis
Untuk menghitungnya, kita dapat melakukan pengecekan dengan kondisi ``if ($3=="Business")`` untuk memastikan hanya baris dengan kelas Business yang dihitung. Setiap baris yang memenuhi kondisi tersebut akan menambah nilai variabel count sebanyak satu.

```
awk '{FS=","} NR>1 {if ($3=="Business"){count++}} END{print "Jumlah penumpang kelas bisnis ada " count " orang"}' passenger.csv
```

![alt text](assets/soal_1/7.png)

**Note:**

``END{print #var#}``: agar yang dicetaknya itu hanya baris terakhirnya saja.

### Buat file KANJ.sh
File ini dibuat untuk mempermudah penggunaan awk agar tidak terus menerus menuliskan command yang panjang untuk setiap soalnya, cara penggunaan dari file ini yaitu cukup dengan command:

``awk -f KANJ.sh passenger.csv [a/b/c/d/e]``

![alt text](assets/soal_1/8.png)

Isi file ``KANJ.sh``:
```
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
        c[$3"-"$4]++
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
        printf ("Rata-rata usia penumpang adalah %.0f tahun\n", sum/count)
    }
    else if (opsi == "e"){
        print "Jumlah penumpang kelas bisnis ada " count " orang"
    }
}
```
Di bagian ``if(NR>1)`` itu untuk mengabaikan baris pertama (header) pada file CSV, sehingga hanya data penumpang yang diproses. Kemudian, di bagian ``delete ARGV[2]`` digunakan untuk menghapus argumen ke-2 dari daftar input file yang dibaca oleh awk karena awk akan menganggap semua argumen setelah nama script sebagai file input. Terakhir, bagian ``END{...}`` digunakan untuk menampilkan hasil akhir setelah seluruh baris pada file selesai diproses.


## Soal 2
Pertama, download file ``peta-ekspedisi-amba.pdf``. Setelah berhasil, saya mengecek isi filenya, namun hanya terlihat peta saja, tidak ada informasi tambahan. Di soal, ada clue untuk mengecek filenya menggunakan command ``cat``, saya mengeceknya dan terdapat link github kemudian saya meng-*clonenya* dan di dalamnya terdapat file ``gsxtrack.json``.

![alt text](assets/soal_2/1.png)

Seperti yang dikatakan di soal, file ``gsxtrack.json`` memuat beberapa titik lokasi dengan informasi site_name, latitude, dan lainnya. Saya membuat file ``parserkoordinat.sh`` untuk memparser koordinatnya. Isi file ``parserkoordinat.sh``:
```
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
```
Isinya merupakan perintah awk untuk membaca file ``gsxtrack.json `` baris per baris dan mengekstrak informasi penting berupa ``id``, ``site_name``, ``latitude``, dan ``longitude`` menggunakan regular expression (regex) dan di akhir diberitahu jika proses parser telah selesai.

Di bagian 
```
/^}/ {
    if(id && site && latitude && longitude)
        print id "," site "," latitude "," longitude
}
```
``/^}/ {`` digunakan sebagai penanda akhir dari satu objek (node) dalam file JSON. Kemudian,  ``if(id && site && latitude && longitude)`` digunakan untuk memastikan semua data yang dibutuhkan sudah terisi sebelum dicetak. Setelah itu, hasilnya diproses dengan perintah: ``sort -u``untuk mengurutkan data berdasarkan id dan menghapus kemungkinan duplikasi data.

![alt text](assets/soal_2/2.png)

Terakhir, proses pencarian koordinat posisi pusakanya berdasarkan clue yang diberikan. Untuk itu, saya membuat file ``nemupusaka.sh`` yang isinya:
```
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
```
![alt text](assets/soal_2/3.png)

Didapatlah koordinat pusatnyaaa dan disimpen filenya dengan nama ``posisipusaka.txt``

![alt text](assets/soal_2/4.png)

Struktur repo soal 2:

![alt text](assets/soal_2/5.png)
