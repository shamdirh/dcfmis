# 🖥️ Data Center Facility Management Information System (DCFMIS)

![Status](https://img.shields.io/badge/Status-Development-orange)
![Go](https://img.shields.io/badge/Golang-1.25.1-00ADD8)
![Nuxt](https://img.shields.io/badge/Nuxt-4.4.8-00DC82)
![Flutter](https://img.shields.io/badge/Flutter-3.38-blue)
![Database](https://img.shields.io/badge/MySQL-8.0.45-blue)

---

## 📖 Tentang Aplikasi

Data Center Facility Management Information System (DCFMIS) merupakan aplikasi yang dikembangkan untuk membantu pengelolaan operasional Pusat Data secara terintegrasi.

Aplikasi digunakan oleh Tim Pusat Data untuk melakukan monitoring, pencatatan, dan pengelolaan fasilitas pusat data secara rutin sehingga seluruh aktivitas operasional dapat terdokumentasi dengan baik.

---

## ✨ Fitur Utama

### 👥 Manajemen Pengguna

- Super Admin
- Admin
- Eksekutif

Hak akses setiap level berbeda sesuai kewenangan masing-masing.

---

### 🏢 Piket Fasilitas Pusat Data

Melakukan pencatatan kondisi:

- Suhu ruang server
- CCTV
- PC Operator
- AC
- UPS
- Panel Listrik
- Rack Server
- Catatan Harian

---

### 🖥️ Manajemen Server

Menyimpan informasi:

- Hardware Server
- Software
- Sistem Operasi
- Lokasi
- Rack
- IP Address
- Port
- Status Server

---

### 🌐 Manajemen IP

Mengelola:

- IP Public
- IP Lokal
- Alokasi IP
- Status penggunaan

---

# 🏗️ Arsitektur Sistem

DCFMIS terdiri dari tiga aplikasi utama.

```text
                    +----------------+
                    | Flutter Mobile |
                    +--------+-------+
                             |
                             |
                             |
+----------------+     REST API     +----------------------+
| Nuxt Dashboard | <--------------> |      Golang API      |
+----------------+                  +----------+-----------+
                                               |
                                               |
                                         +-----+------+
                                         |   MySQL    |
                                         +------------+
```

---

# ⚙️ Teknologi

| Komponen | Teknologi |
|----------|------------|
| Backend API | Golang 1.25.1 |
| Database | MySQL 8.0.45 |
| Dashboard | Nuxt 4 |
| Frontend | Vue 3 |
| Mobile | Flutter |
| Server | Ubuntu 24.04 LTS |

---

# 📂 Struktur Folder

```text
dcfmis/
│
├── README.md
├── LICENSE
├── docs/
│   └── images/
├── api/
│   ├── config/
│   |   └── database.go
│   ├── handlers/
│   |   ├── auth_handler.go
│   |   ├── crypto_utils.go
│   |   ├── ip_handler.go
│   |   ├── log_handler.go
│   |   ├── piket_handler.go
│   |   ├── server_handler.go
│   |   └── user_handler.go
│   ├── models/
│   |   └── piket.go
│   ├── main.go
│   └── api.md
│
├── dashboard/
│   ├── app/
│   |   ├── middleware/
│   |   |   └── auth.ts
│   |   ├── pages/
│   |   |   ├── ip/
│   |   |   |   └── index.vue
│   |   |   ├── log-akses/
│   |   |   |   └── index.vue
│   |   |   ├── piket/
│   |   |   |   └── index.vue
│   |   |   ├── server/
│   |   |   |   └── index.vue
│   |   |   ├── users/
│   |   |   |    └── index.vue
│   |   |   ├── index.vue
│   |   |   └── login.json
│   |   └── app.vue
|   ├── plugins/
│   |   └── api.js    
│   └── public/
│
└── mobile/
    ├── android/
    ├── assets/    
    ├── ios/
    ├── lib/
    |   ├── screens/
    |   |   ├── dashboard_screen.dart 
    |   |   ├── ip_screen.dart  
    |   |   ├── login_screen.dart  
    |   |   ├── piket_detail_screen.dart  
    |   |   ├── piket_input_screen.dart 
    |   |   ├── piket_screen.dart  
    |   |   ├── server_screen.dart                                                   
    |   |   └── splash_screen.dart
    |   └── main.dart
    └── pubspec.yaml
```

# 🔐 Keamanan

Implementasi keamanan pada aplikasi meliputi:

- 2 Step Authentication
- Role Based Access Control (RBAC)
- AES Encryption untuk data sensitif
- Password Hashing (bcrypt)
- API hanya dapat diakses Dashboard dan Mobile
- HTTPS/TLS
- Audit Log

Data yang dienkripsi:

- Nama Lengkap
- Email
- Password
- IP Server
- Port
- Nama Server
- Nama Pusat Data
- Software
- Credential Server

---

# 🚀 Instalasi

## Backend

```bash
cd api
go mod tidy
go run .
```

---

## Dashboard

```bash
cd dashboard
npm install
npm run dev
```

---

## Flutter

```bash
cd mobile
flutter pub get
flutter run
```

---

# 📷 Screenshot

### Dashboard Login

![Login](docs/images/login1.png)
![Login](docs/images/login2.png)

### Dashboard Utama dan Modul-modul;

![Dashboard](docs/images/dashboard.png)
![Dashboard](docs/images/modul_piket.png)
![Dashboard](docs/images/modul_aksesserver.png)
![Dashboard](docs/images/modul_ip.png)

### Mobile

<table>
<tr>
    <td align="center">
        <img src="docs/images/login1.jpeg" width="200">
        <br>
        Halaman Login 1
    </td>
    <td align="center">
        <img src="docs/images/login2.jpeg" width="200">
        <br>
        Halaman Login 2
    </td>
</tr>
<tr>
    <td align="center">
        <img src="docs/images/splash.jpeg" width="200">
        <br>
        Splash Screen
    </td>
    <td align="center">
        <img src="docs/images/dashboard.jpeg" width="200">
        <br>
        Halaman Dashboard
    </td>
</tr>
<tr>
    <td align="center">
        <img src="docs/images/manajemen-piket1.jpeg" width="200">
        <br>
        Halaman Login 1
    </td>
    <td align="center">
        <img src="docs/images/manajemen-server.jpeg" width="200">
        <br>
        Halaman Login 2
    </td>
</tr>
<tr>
    <td align="center">
        <img src="docs/images/manajemen-ip.jpeg" width="200">
        <br>
        Splash Screen
    </td>
    <td align="center">
        <img src="docs/images/tentang-aplikasi.jpeg" width="200">
        <br>
        Halaman Dashboard
    </td>
</tr>
</table>

---

# 🌐 Demo

URL

```
https://labs-dcfmis.kotabogor.go.id
```

Demo Account

| Level | User |
|--------|------|
| Admin | demo_admin@gmail.com |
| Eksekutif | demo_eksekutif@gmail.com |

Password

```
Demo12345!
```

---

# 📅 Roadmap

- [x] Authentication
- [x] User Management
- [x] Monitoring Server
- [x] Data Center Checklist
- [ ] Reset Password
- [ ] CCTV Monitoring
- [ ] Backup Management
- [ ] Report

---

# 👨‍💻 Pengembang

**Saeful Hamdi**
📧 shamdi.rh@gmail.com

---