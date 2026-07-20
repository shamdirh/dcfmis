package main

import (
	"api/config"
	"api/handlers"
	"fmt"
	"log"
	"net/http"
)

// ==========================================
// MIDDLEWARE KEAMANAN GLOBAL (API TOKEN & CORS)
// ==========================================
func middlewareKeamanan(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// 1. Pengaturan CORS Terbatas (Nuxt Web & Android)
		origin := r.Header.Get("Origin")

		// Izinkan localhost:3000 agar Bapak tetap bisa testing / ngoding di lokal
		if origin == "https://labs-dcfmis.kotabogor.go.id" || origin == "http://localhost:3000" {
			w.Header().Set("Access-Control-Allow-Origin", origin)
		} else if origin != "" {
			// Jika request datang dari browser/domain SELAIN yang diizinkan di atas -> BLOKIR
			http.Error(w, "CORS Policy: Akses Ditolak", http.StatusForbidden)
			log.Printf("❌ [CORS BLOCKED] Akses dari domain tidak dikenal: %s\n", origin)
			return
		} else {
			// Jika origin KOSONG (berarti request dari aplikasi Android / Postman), berikan izin
			w.Header().Set("Access-Control-Allow-Origin", "*")
		}

		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, X-App-Token")

		// 2. PENANGANAN REQUEST OPTIONS (PRE-FLIGHT) HARUS DI ATAS
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		log.Printf("🌍 Request Masuk: [%s] %s", r.Method, r.URL.Path)

		// 3. Pengecekan API Token
		token := r.Header.Get("X-App-Token")

		if token != "[o0Ht1407!=5437ul=@K8R{*?zQL36;}0o]" {
			http.Error(w, "Akses Ilegal: Token tidak valid", http.StatusUnauthorized)
			log.Printf("❌ [KEAMANAN GAGAL] Token Ditolak!\n")
			return
		}

		next(w, r)
	}
}

func main() {
	log.Println("⏳ Memulai inisialisasi server DCFMIS...")

	db := config.ConnectDB()
	defer db.Close()
	log.Println("✅ Koneksi Database berhasil!")

	piketHandler := &handlers.PiketHandler{DB: db}
	authHandler := &handlers.AuthHandler{DB: db}
	userHandler := &handlers.UserHandler{DB: db}
	ipHandler := &handlers.IPHandler{DB: db}
	serverHandler := &handlers.ServerHandler{DB: db}
	// Tambahkan inisialisasi LogHandler
	logHandler := &handlers.LogHandler{DB: db}

	// 1. ROUTING MODUL PIKET
	http.HandleFunc("/api/piket/summary", middlewareKeamanan(func(w http.ResponseWriter, r *http.Request) {
		piketHandler.GetPiketSummary(w, r)
	}))
	http.HandleFunc("/api/piket/detail", middlewareKeamanan(func(w http.ResponseWriter, r *http.Request) {
		piketHandler.GetPiketDetail(w, r)
	}))
	http.HandleFunc("/api/piket/manage", middlewareKeamanan(func(w http.ResponseWriter, r *http.Request) {
		piketHandler.ManagePiket(w, r)
	}))

	// 2. ROUTING MODUL AUTENTIKASI
	http.HandleFunc("/api/auth/login-step1", middlewareKeamanan(func(w http.ResponseWriter, r *http.Request) {
		if r.Method == "POST" {
			authHandler.LoginStep1(w, r)
		}
	}))
	http.HandleFunc("/api/auth/verify-math", middlewareKeamanan(func(w http.ResponseWriter, r *http.Request) {
		if r.Method == "POST" {
			authHandler.VerifyMath(w, r)
		}
	}))

	// 3. ROUTING MODUL USER & PERMISSIONS
	http.HandleFunc("/api/users", middlewareKeamanan(func(w http.ResponseWriter, r *http.Request) {
		if r.Method == "GET" {
			userHandler.GetUsers(w, r)
		} else if r.Method == "POST" {
			userHandler.SaveUser(w, r)
		} else if r.Method == "DELETE" {
			userHandler.DeleteUser(w, r)
		}
	}))
	http.HandleFunc("/api/permissions", middlewareKeamanan(func(w http.ResponseWriter, r *http.Request) {
		if r.Method == "GET" {
			userHandler.GetUserPermissions(w, r)
		}
	}))

	// 4. ROUTING MODUL IP
	http.HandleFunc("/api/ip/blocks", middlewareKeamanan(func(w http.ResponseWriter, r *http.Request) {
		if r.Method == "GET" {
			ipHandler.GetBlocks(w, r)
		} else {
			ipHandler.ManageBlock(w, r)
		}
	}))
	http.HandleFunc("/api/ip/usages", middlewareKeamanan(func(w http.ResponseWriter, r *http.Request) {
		if r.Method == "GET" {
			ipHandler.GetUsages(w, r)
		} else {
			ipHandler.ManageUsage(w, r)
		}
	}))

	// 5. ROUTING MODUL SERVER
	http.HandleFunc("/api/server/manage", middlewareKeamanan(func(w http.ResponseWriter, r *http.Request) {
		if r.Method == "GET" {
			serverHandler.GetServers(w, r)
		} else if r.Method == "POST" {
			serverHandler.ManageServer(w, r)
		} else if r.Method == "DELETE" {
			serverHandler.DeleteServer(w, r)
		}
	}))

	// 6. ROUTING MODUL LOG AKSES
	http.HandleFunc("/api/logs", middlewareKeamanan(func(w http.ResponseWriter, r *http.Request) {
		if r.Method == "GET" {
			logHandler.GetLogs(w, r)
		}
	}))

	fmt.Println("🚀 Secure API server berjalan di http://localhost:8080")
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatalf("❌ Server gagal berjalan: %v", err)
	}
}
// === API GOLANG - DCFMIS - Saeful Hamdi (shamdi.rh@gmail.com) ===
