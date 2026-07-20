package handlers

import (
	"database/sql"
	"encoding/json"
	"net/http"

	"golang.org/x/crypto/bcrypt"
)

type UserHandler struct {
	DB *sql.DB
}

type User struct {
	ID          int    `json:"id"`
	NamaLengkap string `json:"nama_lengkap"`
	Jabatan     string `json:"jabatan"`
	Email       string `json:"email"`
	Password    string `json:"password,omitempty"`
	RoleID      int    `json:"role_id"`
	RoleName    string `json:"role_name,omitempty"`
	CreatedAt   string `json:"created_at,omitempty"`

	AdminNama  string `json:"admin_nama"`
	AdminEmail string `json:"admin_email"`
}

func (h *UserHandler) GetUsers(w http.ResponseWriter, r *http.Request) {
	rows, err := h.DB.Query(`
		SELECT u.id, u.nama_lengkap, IFNULL(u.jabatan, ''), u.email, u.role_id, r.nama_role, u.created_at
		FROM users u
		JOIN roles r ON u.role_id = r.id
		ORDER BY u.id DESC
	`)
	if err != nil {
		http.Error(w, "Gagal mengambil data user: "+err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var users []User
	for rows.Next() {
		var u User
		if err := rows.Scan(&u.ID, &u.NamaLengkap, &u.Jabatan, &u.Email, &u.RoleID, &u.RoleName, &u.CreatedAt); err != nil {
			continue
		}

		// DEKRIPSI
		u.NamaLengkap = DecryptData(u.NamaLengkap)
		u.Email = DecryptData(u.Email)

		users = append(users, u)
	}
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(users)
}

func (h *UserHandler) SaveUser(w http.ResponseWriter, r *http.Request) {
	var u User
	json.NewDecoder(r.Body).Decode(&u)

	// ENKRIPSI
	encNama := EncryptData(u.NamaLengkap)
	encEmail := EncryptData(u.Email)

	if u.ID == 0 {
		hashedPassword, _ := bcrypt.GenerateFromPassword([]byte(u.Password), bcrypt.DefaultCost)
		_, err := h.DB.Exec("INSERT INTO users (nama_lengkap, jabatan, email, password_hash, role_id) VALUES (?, ?, ?, ?, ?)",
			encNama, u.Jabatan, encEmail, hashedPassword, u.RoleID)
		if err != nil {
			http.Error(w, "Gagal menyimpan user", http.StatusInternalServerError)
			return
		}
		CatatLog(h.DB, u.AdminNama, u.AdminEmail, "menambahkan user sistem baru: "+u.NamaLengkap)

	} else {
		if u.Password != "" {
			hashedPassword, _ := bcrypt.GenerateFromPassword([]byte(u.Password), bcrypt.DefaultCost)
			_, err := h.DB.Exec("UPDATE users SET nama_lengkap=?, jabatan=?, email=?, password_hash=?, role_id=? WHERE id=?",
				encNama, u.Jabatan, encEmail, hashedPassword, u.RoleID, u.ID)
			if err != nil {
				http.Error(w, "Gagal update user", http.StatusInternalServerError)
				return
			}
		} else {
			_, err := h.DB.Exec("UPDATE users SET nama_lengkap=?, jabatan=?, email=?, role_id=? WHERE id=?",
				encNama, u.Jabatan, encEmail, u.RoleID, u.ID)
			if err != nil {
				http.Error(w, "Gagal update user", http.StatusInternalServerError)
				return
			}
		}
		CatatLog(h.DB, u.AdminNama, u.AdminEmail, "mengedit data user: "+u.NamaLengkap)
	}
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{"message": "User berhasil disimpan"})
}

func (h *UserHandler) DeleteUser(w http.ResponseWriter, r *http.Request) {
	id := r.URL.Query().Get("id")
	adminNama := r.URL.Query().Get("admin_nama")
	adminEmail := r.URL.Query().Get("admin_email")

	var targetUser string
	h.DB.QueryRow("SELECT nama_lengkap FROM users WHERE id=?", id).Scan(&targetUser)

	_, err := h.DB.Exec("DELETE FROM users WHERE id=?", id)
	if err != nil {
		http.Error(w, "Gagal menghapus user", http.StatusInternalServerError)
		return
	}

	CatatLog(h.DB, adminNama, adminEmail, "menghapus user sistem: "+DecryptData(targetUser))

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{"message": "User berhasil dihapus"})
}

func (h *UserHandler) GetUserPermissions(w http.ResponseWriter, r *http.Request) {
	rows, err := h.DB.Query("SELECT id, nama_role FROM roles")
	if err != nil {
		http.Error(w, "Gagal mengambil daftar role", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var roles []map[string]interface{}
	for rows.Next() {
		var id int
		var nama string
		rows.Scan(&id, &nama)
		roles = append(roles, map[string]interface{}{"id": id, "nama_role": nama})
	}
	json.NewEncoder(w).Encode(roles)
}
// === API GOLANG - DCFMIS - Saeful Hamdi (shamdi.rh@gmail.com) ===