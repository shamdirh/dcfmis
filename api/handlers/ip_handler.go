package handlers

import (
	"database/sql"
	"encoding/json"
	"net/http"
)

type IPHandler struct {
	DB *sql.DB
}

type IPBlock struct {
	ID         int    `json:"id"`
	NamaBlok   string `json:"nama_blok"`
	JenisIP    string `json:"jenis_ip"`
	CidrBlock  string `json:"cidr_block"`
	Keterangan string `json:"keterangan"`
	AdminNama  string `json:"admin_nama"`
	AdminEmail string `json:"admin_email"`
}

type IPUsageDetail struct {
	ID         int    `json:"id"`
	IPBlockID  int    `json:"ip_block_id"`
	IPAddress  string `json:"ip_address"`
	PortInfo   string `json:"port_info"`
	Kegunaan   string `json:"kegunaan"`
	Status     string `json:"status"`
	NamaBlok   string `json:"nama_blok"`
	JenisIP    string `json:"jenis_ip"`
	NamaServer string `json:"nama_server"`
}

func (h *IPHandler) GetBlocks(w http.ResponseWriter, r *http.Request) {
	rows, err := h.DB.Query("SELECT id, IFNULL(nama_blok, ''), IFNULL(jenis_ip, 'Publik'), IFNULL(cidr_block, ''), IFNULL(keterangan, '') FROM ip_blocks ORDER BY id ASC")
	if err != nil {
		http.Error(w, "Gagal menarik data blok IP", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var blocks []IPBlock
	for rows.Next() {
		var b IPBlock
		rows.Scan(&b.ID, &b.NamaBlok, &b.JenisIP, &b.CidrBlock, &b.Keterangan)

		// DEKRIPSI
		b.CidrBlock = DecryptData(b.CidrBlock)

		blocks = append(blocks, b)
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(blocks)
}

func (h *IPHandler) ManageBlock(w http.ResponseWriter, r *http.Request) {
	if r.Method == "POST" {
		var b IPBlock
		json.NewDecoder(r.Body).Decode(&b)

		// ENKRIPSI SEBELUM SIMPAN
		encCidr := EncryptData(b.CidrBlock)

		if b.ID == 0 {
			h.DB.Exec("INSERT INTO ip_blocks (nama_blok, jenis_ip, cidr_block, keterangan) VALUES (?, ?, ?, ?)", b.NamaBlok, b.JenisIP, encCidr, b.Keterangan)
			CatatLog(h.DB, b.AdminNama, b.AdminEmail, "menambahkan blok IP baru ("+b.NamaBlok+")")
		} else {
			h.DB.Exec("UPDATE ip_blocks SET nama_blok=?, jenis_ip=?, cidr_block=?, keterangan=? WHERE id=?", b.NamaBlok, b.JenisIP, encCidr, b.Keterangan, b.ID)
			CatatLog(h.DB, b.AdminNama, b.AdminEmail, "mengedit blok IP ("+b.NamaBlok+")")
		}
		json.NewEncoder(w).Encode(map[string]string{"message": "Blok berhasil disimpan"})

	} else if r.Method == "DELETE" {
		id := r.URL.Query().Get("id")
		adminNama := r.URL.Query().Get("admin_nama")
		adminEmail := r.URL.Query().Get("admin_email")

		var namaBlok string
		h.DB.QueryRow("SELECT nama_blok FROM ip_blocks WHERE id=?", id).Scan(&namaBlok)

		h.DB.Exec("DELETE FROM ip_blocks WHERE id=?", id)
		CatatLog(h.DB, adminNama, adminEmail, "menghapus blok IP ("+namaBlok+")")

		json.NewEncoder(w).Encode(map[string]string{"message": "Blok berhasil dihapus"})
	}
}

func (h *IPHandler) GetUsages(w http.ResponseWriter, r *http.Request) {
	rows, err := h.DB.Query(`
		SELECT 
			u.id, 
			u.ip_block_id,
			IFNULL(u.ip_address, ''), 
			IFNULL(u.port_info, ''), 
			IFNULL(u.kegunaan, ''), 
			IFNULL(u.status, 'Aktif'),
			IFNULL(b.nama_blok, ''), 
			IFNULL(b.jenis_ip, 'Publik'),
			IFNULL(s.nama_server, '')
		FROM ip_usages u
		JOIN ip_blocks b ON u.ip_block_id = b.id
		LEFT JOIN servers s ON u.server_id = s.id
	`)

	if err != nil {
		http.Error(w, "Gagal menarik data pemakaian IP", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var usages []IPUsageDetail
	for rows.Next() {
		var u IPUsageDetail
		rows.Scan(&u.ID, &u.IPBlockID, &u.IPAddress, &u.PortInfo, &u.Kegunaan, &u.Status, &u.NamaBlok, &u.JenisIP, &u.NamaServer)

		// DEKRIPSI
		u.IPAddress = DecryptData(u.IPAddress)
		u.PortInfo = DecryptData(u.PortInfo)
		u.NamaServer = DecryptData(u.NamaServer) // Kolom ini join dari servers

		if u.NamaServer == "" {
			u.NamaServer = u.Kegunaan
		}
		usages = append(usages, u)
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(usages)
}

func (h *IPHandler) ManageUsage(w http.ResponseWriter, r *http.Request) {
	if r.Method == "POST" {
		var u struct {
			ID         int    `json:"id"`
			IPBlockID  int    `json:"ip_block_id"`
			IPAddress  string `json:"ip_address"`
			Kegunaan   string `json:"kegunaan"`
			PortInfo   string `json:"port_info"`
			Status     string `json:"status"`
			AdminNama  string `json:"admin_nama"`
			AdminEmail string `json:"admin_email"`
		}
		json.NewDecoder(r.Body).Decode(&u)

		// ENKRIPSI SEBELUM SIMPAN
		encIP := EncryptData(u.IPAddress)
		encPort := EncryptData(u.PortInfo)

		if u.ID == 0 {
			h.DB.Exec("INSERT INTO ip_usages (ip_block_id, ip_address, kegunaan, port_info, status) VALUES (?, ?, ?, ?, ?)", u.IPBlockID, encIP, u.Kegunaan, encPort, u.Status)
			CatatLog(h.DB, u.AdminNama, u.AdminEmail, "menambahkan alokasi IP "+u.IPAddress)
		} else {
			h.DB.Exec("UPDATE ip_usages SET ip_address=?, kegunaan=?, port_info=?, status=? WHERE id=?", encIP, u.Kegunaan, encPort, u.Status, u.ID)
			CatatLog(h.DB, u.AdminNama, u.AdminEmail, "mengedit alokasi IP "+u.IPAddress)
		}
		json.NewEncoder(w).Encode(map[string]string{"message": "Pemakaian IP berhasil disimpan"})

	} else if r.Method == "DELETE" {
		id := r.URL.Query().Get("id")
		adminNama := r.URL.Query().Get("admin_nama")
		adminEmail := r.URL.Query().Get("admin_email")

		var ipTarget string
		h.DB.QueryRow("SELECT ip_address FROM ip_usages WHERE id=?", id).Scan(&ipTarget)

		h.DB.Exec("DELETE FROM ip_usages WHERE id=?", id)
		CatatLog(h.DB, adminNama, adminEmail, "menghapus alokasi IP "+DecryptData(ipTarget))

		json.NewEncoder(w).Encode(map[string]string{"message": "Pemakaian IP berhasil dihapus"})
	}
}
// === API GOLANG - DCFMIS - Saeful Hamdi (shamdi.rh@gmail.com) ===