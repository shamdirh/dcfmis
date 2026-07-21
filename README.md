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
| Framework | Gin |
| ORM | GORM |
| Database | MySQL 8.0.45 |
| Dashboard | Nuxt 4 |
| Frontend | Vue 3 |
| Mobile | Flutter |
| Authentication | JWT |
| Server | Ubuntu 24.04 LTS |

---

# 📂 Struktur Folder

```text
DCFMIS/
│
├── README.md
├── LICENSE
├── docs/
│   ├── images/
│   ├── api.md
│   ├── deployment.md
│   └── database.md
│
├── golang-api/
│   ├── cmd/
│   ├── config/
│   ├── handlers/
│   ├── middleware/
│   ├── models/
│   ├── routes/
│   ├── go.mod
│   └── go.sum
│
├── dashboard/
│   ├── assets/
│   ├── components/
│   ├── composables/
│   ├── pages/
│   ├── public/
│   ├── app.vue
│   └── package.json
│
└── mobile/
    ├── android/
    ├── ios/
    ├── lib/
    ├── assets/
    └── pubspec.yaml
```

---

# 🔐 Keamanan

Implementasi keamanan pada aplikasi meliputi:

- JWT Authentication
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
cd golang-api
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

![Login](docs/images/login.png)

### Dashboard Utama

![Dashboard](docs/images/dashboard.png)

### Mobile

![Mobile](docs/images/mobile.png)

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
- [ ] Notification WA
- [ ] Monitoring SNMP
- [ ] Grafana Integration
- [ ] Backup Management

---

# 👨‍💻 Pengembang

**Saeful Hamdi**

Pranata Komputer Mahir  
Dinas Komunikasi dan Informatika Kota Bogor

📧 shamdi.rh@gmail.com

---
