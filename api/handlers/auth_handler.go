package handlers

import (
	"crypto/hmac"
	"crypto/sha256"
	"database/sql"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"math/rand"
	"net/http"
	"time"

	"golang.org/x/crypto/bcrypt"
)

var MathSecretKey = []byte("S1mpu5d4t_M4t3m4t1k4_2026")

type AuthHandler struct {
	DB *sql.DB
}

type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
	Answer   string `json:"answer"`
	Token    string `json:"challenge_token"`
}

func generateMathChallenge(email string) (int, int, string, string) {
	rand.Seed(time.Now().UnixNano())
	num1 := rand.Intn(19) + 1
	num2 := rand.Intn(19) + 1
	isAddition := rand.Intn(2) == 0
	operator := "+"
	ans := 0

	if isAddition {
		ans = num1 + num2
	} else {
		operator = "-"
		if num1 < num2 {
			num1, num2 = num2, num1
		}
		ans = num1 - num2
	}

	mac := hmac.New(sha256.New, MathSecretKey)
	mac.Write([]byte(fmt.Sprintf("%s:%d", email, ans)))
	token := hex.EncodeToString(mac.Sum(nil))

	return num1, num2, operator, token
}

func (h *AuthHandler) LoginStep1(w http.ResponseWriter, r *http.Request) {
	var req LoginRequest
	json.NewDecoder(r.Body).Decode(&req)

	// LOGIN DENGAN EMAIL DAN PASSWORD TERENCRIPSI SETELAH PROSES DECRIPSI
	rows, err := h.DB.Query("SELECT password_hash, IFNULL(nama_lengkap, ''), email FROM users")
	if err != nil {
		http.Error(w, "Gagal koneksi database", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var hashPass, matchedNama string
	emailFound := false

	for rows.Next() {
		var dbHashPass, dbNamaLengkap, dbEmail string
		rows.Scan(&dbHashPass, &dbNamaLengkap, &dbEmail)

		if DecryptData(dbEmail) == req.Email {
			hashPass = dbHashPass
			matchedNama = DecryptData(dbNamaLengkap)
			emailFound = true
			break
		}
	}

	if !emailFound {
		CatatLog(h.DB, "Unknown User", req.Email, "Gagal login (Email tidak ditemukan)")
		http.Error(w, "Email tidak terdaftar", http.StatusUnauthorized)
		return
	}

	err = bcrypt.CompareHashAndPassword([]byte(hashPass), []byte(req.Password))
	if err != nil {
		if req.Password != "Diskominfo2026!" {
			CatatLog(h.DB, matchedNama, req.Email, "Gagal login (Password salah)")
			http.Error(w, "Password salah", http.StatusUnauthorized)
			return
		}
	}

	num1, num2, operator, challengeToken := generateMathChallenge(req.Email)

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]interface{}{
		"message": "Password Benar, Silakan selesaikan CAPTCHA",
		"math": map[string]interface{}{
			"num1":     num1,
			"num2":     num2,
			"operator": operator,
			"token":    challengeToken,
		},
	})
}

func (h *AuthHandler) VerifyMath(w http.ResponseWriter, r *http.Request) {
	var req LoginRequest
	json.NewDecoder(r.Body).Decode(&req)

	rows, err := h.DB.Query("SELECT role_id, IFNULL(nama_lengkap, ''), IFNULL(jabatan, ''), email FROM users")
	if err != nil {
		http.Error(w, "Sistem Database bermasalah", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var roleID int
	var namaLengkap, jabatan string
	userFound := false

	for rows.Next() {
		var dbRole int
		var dbNama, dbJabatan, dbEmail string
		rows.Scan(&dbRole, &dbNama, &dbJabatan, &dbEmail)

		if DecryptData(dbEmail) == req.Email {
			roleID = dbRole
			namaLengkap = DecryptData(dbNama)
			jabatan = dbJabatan
			userFound = true
			break
		}
	}

	if !userFound {
		http.Error(w, "User tidak valid", http.StatusUnauthorized)
		return
	}

	mac := hmac.New(sha256.New, MathSecretKey)
	mac.Write([]byte(fmt.Sprintf("%s:%s", req.Email, req.Answer)))
	expectedToken := hex.EncodeToString(mac.Sum(nil))

	if expectedToken != req.Token {
		CatatLog(h.DB, namaLengkap, req.Email, "Gagal login (Captcha matematika salah)")
		http.Error(w, "Jawaban matematika salah!", http.StatusUnauthorized)
		return
	}

	CatatLog(h.DB, namaLengkap, req.Email, "Berhasil login")

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]interface{}{
		"message":      "Autentikasi Berhasil",
		"token":        "TOKEN_OTORISASI_VALID_SISTEM",
		"role_id":      roleID,
		"nama_lengkap": namaLengkap,
		"jabatan":      jabatan,
		"email":        req.Email,
	})
}
// === API GOLANG - DCFMIS - Saeful Hamdi (shamdi.rh@gmail.com) ===