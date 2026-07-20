package handlers

import (
	"database/sql"
	"encoding/json"
	"log"
	"net/http"
)

type LogHandler struct {
	DB *sql.DB
}

type LogData struct {
	ID          int    `json:"id"`
	NamaLengkap string `json:"nama_lengkap"`
	Email       string `json:"email"`
	Aktivitas   string `json:"aktivitas"`
	Waktu       string `json:"waktu"`
}

func CatatLog(db *sql.DB, namaLengkap, email, aktivitas string) {
	// MENGOTOMATISKAN ENKRIPSI NAMA DAN EMAIL SAAT MENCATAT
	encNama := EncryptData(namaLengkap)
	encEmail := EncryptData(email)

	query := "INSERT INTO logs (nama_lengkap, email, aktivitas) VALUES (?, ?, ?)"
	_, err := db.Exec(query, encNama, encEmail, aktivitas)
	if err != nil {
		log.Printf("❌ Gagal mencatat log: %v", err)
	}
}

func (h *LogHandler) GetLogs(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	rows, err := h.DB.Query("SELECT id, nama_lengkap, email, aktivitas, waktu FROM logs ORDER BY waktu DESC LIMIT 100")
	if err != nil {
		http.Error(w, "Gagal mengambil data log", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	logs := []LogData{}
	for rows.Next() {
		var l LogData
		if err := rows.Scan(&l.ID, &l.NamaLengkap, &l.Email, &l.Aktivitas, &l.Waktu); err != nil {
			continue
		}

		// DEKRIPSI SAAT DIBACA
		l.NamaLengkap = DecryptData(l.NamaLengkap)
		l.Email = DecryptData(l.Email)

		logs = append(logs, l)
	}

	json.NewEncoder(w).Encode(logs)
}

// === API GOLANG - DCFMIS - Saeful Hamdi (shamdi.rh@gmail.com) ===
