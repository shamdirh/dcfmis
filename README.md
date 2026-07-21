# Data Center Facility Management Information System (DCFMIS)

Aplikasi Data Center Facility Management Information System (DCFMIS) ini dibangun untuk memudahkan Tim Pusat Data dalam melakukan pengecekan rutin harian fasilitas Pusat Data: Suhu Ruangan Server, PC operator, CCTV Pusat Data, Kondisi AC Ruangan, Panel Listrik Utama, Indikator UPS dan Baterai, Indikator Panel Distribusi Listrik, Kondisi Rack Server, serta Catatan Kejadian Harian.

Beberapa modul yang tersedia di aplikasi saat ini adalah:
- Modul Manajemen Pengguna Aplikasi: pengguna dibagi adalam 3 level: Super Admin yang dapat mengelola semua data, Admin dapat mengelola semua data kecuali Manajemen Pengguna Plikasi. Level Eksekutif hanya dapat melihat data.
- Modul Piket Fasilitas Pusat Data: Mencatat hasil pengecekan rutin harian fasilitas Pusat Data: Suhu Ruangan Server, PC operator, CCTV Pusat Data, Kondisi AC Ruangan, Panel Listrik Utama, Indikator UPS dan Baterai, Indikator Panel Distribusi Listrik, Kondisi Rack Server, serta Catatan Kejadian Harian.
- Modul Manajemen Akses Server: berisi data server beserta spesifikasi hardware dan software terinstal
- Modul Manajemen Alokasi IP Publik dan IP Lokal
---

## Infrastruktur Aplikasi

Aplikasi DCFMIS dibangun dalam 3 aplikasi berbeda yang terintegrasi:
- Golang API menyediakan API yang diperlukan untuk pengelolaan data dari Aplikasi Nuxt Dashboard Admin dan Aplikasi Mobile
-- Golang 1.25.12
-- MySql 8.0.45  
- Nuxt Dashboard Admin menyediakan fasilitas pengelolaan data berbasis Web
-- nuxt 4.4.8
-- vue 3.5.39
-- vue-router 5.1.0
- Flutter Mobile App digunakan untuk input dan update data oleh operator pusat data menggunakan pengakat mobile
-- flutter 3.138.0
-- dart 3.138.0
-- sdk 3.11.4
---

## Struktur Folder

Dikembangkan Oleh:
Saeful Hamdi
shamdi.rh@gmail.com

