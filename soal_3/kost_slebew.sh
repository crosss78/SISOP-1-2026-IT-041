#!/bin/bash

cd "$(dirname "$(realpath "$0")")"

DATA="data/penghuni.csv"
LOG="log/tagihan.log"
REKAP="rekap/laporan_bulanan.txt"
SAMPAH="sampah/history_hapus.csv"

function menu() {
    echo "=================================================="
    echo "██╗  ██╗ ██████╗ ███████╗████████╗     ███████╗██╗     ███████╗██████╗ ███████╗██╗    ██╗"
    echo "██║ ██╔╝██╔═══██╗██╔════╝╚══██╔══╝     ██╔════╝██║     ██╔════╝██╔══██╗██╔════╝██║    ██║"
    echo "█████╔╝ ██║   ██║███████╗   ██║        ███████╗██║     █████╗  ██████╔╝█████╗  ██║ █╗ ██║"
    echo "██╔═██╗ ██║   ██║╚════██║   ██║        ╚════██║██║     ██╔══╝  ██╔══██╗██╔══╝  ██║███╗██║"
    echo "██║  ██╗╚██████╔╝███████║   ██║        ███████║███████╗███████╗██████╔╝███████╗╚███╔███╔╝"
    echo "╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝        ╚══════╝╚══════╝╚══════╝╚═════╝ ╚══════╝ ╚══╝╚══╝"
    echo "=================================================="
    echo "        SISTEM MANAJEMEN KOST SLEBEW"
    echo "=================================================="
    echo "1. Tambah Penghuni"
    echo "2. Hapus Penghuni"
    echo "3. Tampilkan Penghuni"
    echo "4. Update Status"
    echo "5. Laporan Keuangan"
    echo "6. Kelola Cron"
    echo "7. Exit"
    echo "=================================================="
}

function tambah_penghuni() {
    echo "=================================================="
    echo "                 TAMBAH PENGHUNI                 "
    echo "=================================================="
    
    #masukin nama
    echo -n "Masukkan nama: "
    read nama
    
    #masukkin no kamar
    while true
    do
        echo -n "Masukkan nomor kamar: "
        read no_kamar
        if ! [[ $no_kamar =~ ^[0-9]+$ ]] 
        then
            echo "❌ Nomor kamar harus berupa angka >=0. Masukkin ulang..."
            continue
        fi

        if grep -q ",$no_kamar," ""$DATA""
        then
            echo "❌ Kamar sudah diisi orang lain, cari kamar lain..."
            continue
        fi
        break
    done
    
    #masukin harga
    while true
    do
        echo -n "Masukkan harga: "
        read harga

        if (! [[ $harga =~ ^[0-9]+$ ]]) || ([ $harga -le 0 ])
        then
            echo "❌ Harganya harus berupa angka > 0. Masukkin ulang..."
            continue
        fi
        break
    done

    #masukin tanggal
    while true
    do
        echo -n "Masukkan tanggal (YYYY-MM-DD): "
        read tanggal
        
        #cek format
        if [ $(date -d $tanggal +%F 2>/dev/null) != $tanggal ]
        then
            echo "❌ Format tanggal salah. Masukkin ulang..."
            continue
        fi
        #cek lebih
        if [[ $tanggal > $(date +%F) ]]
        then
            echo "❌Tanggal tidak boleh melebihi hari ini. Masukkin ulang..."
            continue
        fi
        break
    done

    #masukkin status
    while true
    do
        echo -n "Masukkin status (Aktif/Menunggak): "
        read status
        if [[ ($status != "Aktif") && ($status != "Menunggak") ]]
        then
            echo "❌ Input status cuma bisa Aktif atau Menunggak saja. Masukkin ulang..."
            continue
        fi
        break
    done
    echo "$nama,$no_kamar,$harga,$tanggal,$status" >> "$DATA"
    echo "✅ Penghuni $nama berhasil ditambahkan..."

}

function hapus_penghuni() {
    tampilkan_penghuni

    if [ $(wc -l < "$DATA") -le 1 ]
    then
        echo "Kost belum punya penghuni..."
        return
    fi

    echo -n "Masukkan nama penghuni yang akan dihapus: "
    read nama
    
    #ambil semua data dengan nama yang diinputkan
    hasil=$(awk -v n="$nama" 'BEGIN{FS=","} $1==n {print}' "$DATA")
    jumlah=$(echo "$hasil" | wc -l)

    if [ $jumlah -gt 1 ]
    then
        echo "Penghuni dengan nama $nama ada lebih dari satu..."
        echo -n "Masukkan nomor kamar: "
        read kamar

        #ambil data spesifik nama + kamar
        data=$(awk -v n="$nama" -v k="$kamar" 'BEGIN{FS=","} $1==n && $2==k {print}' "$DATA")

        if [ -z ""$data"" ]; then
            echo "❌ Penghuni dengan nama dan kamar tersebut tidak ditemukan..."
            return
        fi

        #hapus
        awk -v n="$nama" -v k=$kamar '
        BEGIN{FS=",";OFS=","}
        !($1==n && $2==k) {print}
        ' "$DATA" > temp.csv && mv temp.csv "$DATA"
    else
        data=$hasil
        awk -v n="$nama" '
        BEGIN{FS=",";OFS=","}
        !($1==n) {print}
        ' "$DATA" > temp.csv && mv temp.csv "$DATA"
    fi

    #simpen ke sampah
    tanggal_hapus=$(date +%F)
    echo ""$data",$tanggal_hapus" >> $SAMPAH

    
    if [ $jumlah -gt 1 ]
    then
        echo "Penghuni "$nama" kamar $kamar berhasil dihapus"
    else
        if [ -z "$nama" ]
        then
            echo "Tidak ada data penghuni yang dihapus"
        else
        echo "Penghuni $nama berhasil dihapus"
        fi
    fi
}

function tampilkan_penghuni() {
    echo "=============================================================="
    echo "                DAFTAR PENGHUNI KOST SLEBEW"
    echo "=============================================================="

    printf "%-3s | %-15s | %-5s | %-10s | %-12s | %-10s\n" \
    "No" "Nama" "Kamar" "Harga" "Tanggal" "Status"

    echo "--------------------------------------------------------------"

    awk '
    BEGIN{FS=","} NR>1 {
        printf "%-3d | %-15s | %-5s | %-10s | %-12s | %-10s\n",
        NR-1, $1, $2, $3, $4, $5
    }' "$DATA"
}

function update() {
    tampilkan_penghuni
    
    if [ $(wc -l < "$DATA") -le 1 ]
    then
        echo "Kost belum punya penghuni..."
        return
    fi

    echo -n "Masukkan nama penghuni yang akan diperbarui statusnya: "
    read nama
    
    #ambil semua data dengan nama yang diinputkan
    hasil=$(awk -v n="$nama" 'BEGIN{FS=","} $1==n {print}' "$DATA")
    jumlah=$(echo "$hasil" | wc -l)

    if [ $jumlah -gt 1 ]
    then
        echo "Penghuni dengan nama $nama ada lebih dari satu..."
        echo -n "Masukkan nomor kamar: "
        read kamar

        #ambil data spesifik nama + kamar
        data=$(awk -v n="$nama" -v k="$kamar" 'BEGIN{FS=","} $1==n && $2==k {print}' "$DATA")

        if [ -z ""$data"" ]; then
            echo "❌ Penghuni dengan nama dan kamar tersebut tidak ditemukan..."
            return
        fi
    fi

    while true
    do
        echo -n "Masukkin status (Aktif/Menunggak): "
        read status
        if [[ ($status != "Aktif") && ($status != "Menunggak") ]]
        then
            echo "❌ Input status cuma bisa Aktif atau Menunggak saja. Masukkin ulang..."
            continue
        fi
        break
    done

    if [ "$jumlah" -gt 1 ]; then
        awk -v n="$nama" -v k="$kamar" -v s="$status" '
        BEGIN{FS=",";OFS=","}
        {
            if($1==n && $2==k){
                $5=s
            }
            print
        }' "$DATA" > temp.csv && mv temp.csv "$DATA"
    else
        awk -v n="$nama" -v s="$status" '
        BEGIN{FS=",";OFS=","}
        {
            if($1==n){
                $5=s
            }
            print
        }' "$DATA" > temp.csv && mv temp.csv "$DATA"
    fi

    if [ $jumlah -gt 1 ]
    then
        echo "Status "$nama" kamar $kamar berhasil diperbarui"
    else
        if [ -z "$nama" ]
        then
            echo "Tidak ada data penghuni yang diperbarui"
        else
        echo "Status $nama berhasil diperbarui"
        fi
    fi
}

function laporan_keuangan() {

    echo "=================================================="
    echo "           LAPORAN KEUANGAN KOST"
    echo "=================================================="

    if [ $(wc -l < "$DATA") -le 1 ]; then
        echo "Kost belum punya penghuni..."
        return
    fi

    awk '
    BEGIN{FS=",";jml_aktif=0;jml_nunggak=0;aktif=0;nunggak=0}
    NR>1 {
        if($5=="Aktif"){
            aktif += $3
            jml_aktif++
        }
        else if($5=="Menunggak"){
            nunggak += $3
            jml_nunggak++
            p[jml_nunggak] = $1
        }
    }
    END {
        print "Jumlah Penghuni Aktif     :", jml_aktif
        print "Total Pemasukan Aktif     : Rp", aktif
        print "-----------------------------------------"
        print "Jumlah Penghuni Menunggak :", jml_nunggak
        print "Total Tunggakan           : Rp", nunggak
        print "-----------------------------------------"
        print "Total Penghuni            : ", jml_aktif + jml_nunggak
        print "Total Keseluruhan         : Rp", aktif + nunggak
        print "-----------------------------------------"
        print "List Nama Penghuni Menunggak:"
        
        if(jml_nunggak==0){
        print "-Tidak ada penghuni menunggak-"
        }
        else{
        for(i=1;i<=jml_nunggak;i++){
            print i ". " p[i]
            }
        }

        print "-----------------------------------------"
        
    }' "$DATA" > "$REKAP" && cat "$REKAP"
}

#BAGIAN CRON
if [ "$1" == "--check-tagihan" ]
then
    awk -F',' '
    NR>1 && $5=="Menunggak" {
        waktu = strftime("%Y-%m-%d %H:%M:%S")
        printf "[%s] TAGIHAN: %s (Kamar %s) - Menunggak Rp%s\n", waktu, $1, $2, $3
    }
    ' "$DATA"
    exit
fi

function kelola_cron(){
    while true
    do
        echo "============================="
        echo "          KELOLA CRON        "
        echo "============================="
        echo "1. Lihat Cron Aktif"
        echo "2. Tambah Cron"
        echo "3. Hapus Cron"
        echo "4. Kembali"
        echo "============================="
        echo -n "Pilih [1 - 4]: "
        read opsi

        case $opsi in
        1)
        if crontab -l >/dev/null 2>&1
            then
                crontab -l
            else
                echo "belum ada crontab"
        fi
        ;;
        2)
        echo -n "Masukkan jam (0-23): "
        read jam
        echo -n "Masukkan menit (0-59): "
        read menit

        loc=$PWD
        script_path="$loc/kost_slebew.sh"
        log_path="$loc/log/tagihan.log"

        command="$script_path --check-tagihan >> $log_path 2>&1"

        (
            crontab -l 2>/dev/null | grep -v -- "--check-tagihan"
            echo "$menit $jam * * * $command"
        ) | crontab -

        echo "✅ Cron berhasil ditambahkan!"
        ;;
        3)
        if crontab -l >/dev/null 2>&1
            then
                crontab -r
                echo "✅ Cron berhasil dihapus!"
            else
                echo "belum ada crontab"
        fi
        ;;
        4)
        break;;
        *)
        echo "Pilihan tidak valid";;
        esac
    done
}


while true
do
    menu
    echo -n "Pilih [1 - 7] : "
    read pilih
    
    case $pilih in
        1)
        tambah_penghuni;;
        2)
        hapus_penghuni;;
        3)
        tampilkan_penghuni
        echo "--------------------------------------------------------------"
        awk '
        BEGIN{FS=",";m=0;a=0}
        NR > 1 {
        count++
        if ($5=="Aktif"){a++}
        if ($5=="Menunggak"){m++}
        }
        END{print "AKTIF: " a "          |      MENUNGGAK: " m "          |     TOTAL: " count}
        ' "$DATA"
        echo "--------------------------------------------------------------"
        ;;
        4)
        update;;
        5)
        laporan_keuangan;;
        6)
        kelola_cron;;
        7)
        echo "Keluar dari program."
        exit;;
        *)
        echo "Input yang di masukkan tidak valid.";;  
    esac
done
