package handlers

import (
	"database/sql"
	"encoding/json"
	"net/http"
)

type ServerHandler struct {
	DB *sql.DB
}

type AssignedIP struct {
	ID        int    `json:"id,omitempty"`
	IPBlockID int    `json:"ip_block_id"`
	IPAddress string `json:"ip_address"`
	PortInfo  string `json:"port_info"`
	Kegunaan  string `json:"kegunaan"`
}

type Kredensial struct {
	User string `json:"user"`
	Pass string `json:"pass"`
}

type AkunServer struct {
	Linux    []Kredensial `json:"linux"`
	Database []Kredensial `json:"database"`
	Aplikasi []Kredensial `json:"aplikasi"`
}

type ServerData struct {
	ID               int          `json:"id"`
	KategoriServer   string       `json:"kategori_server"`
	NamaServer       string       `json:"nama_server"`
	PusatData        string       `json:"pusat_data"`
	TanggalPembuatan string       `json:"tanggal_pembuatan"`
	Pembuat          string       `json:"pembuat"`
	SpekCPU          string       `json:"spek_cpu"`
	SpekRAM          string       `json:"spek_ram"`
	SpekHDD          string       `json:"spek_hdd"`
	Software         []string     `json:"software_terpasang"`
	Kredensial       AkunServer   `json:"kredensial_akun"`
	AssignedIPs      []AssignedIP `json:"assigned_ips"`

	AdminNama  string `json:"admin_nama"`
	AdminEmail string `json:"admin_email"`
}

func (h *ServerHandler) ManageServer(w http.ResponseWriter, r *http.Request) {
	var req ServerData
	json.NewDecoder(r.Body).Decode(&req)

	softwareJSON, _ := json.Marshal(req.Software)
	kredensialJSON, _ := json.Marshal(req.Kredensial)

	// ENKRIPSI DATA RAHASIA
	encNamaServer := EncryptData(req.NamaServer)
	encPusatData := EncryptData(req.PusatData)
	encSoftware := EncryptData(string(softwareJSON))
	encKredensial := EncryptData(string(kredensialJSON))

	tx, err := h.DB.Begin()
	if err != nil {
		http.Error(w, "Gagal memulai transaksi", http.StatusInternalServerError)
		return
	}

	var serverID int64
	if req.ID == 0 {
		res, err := tx.Exec(`INSERT INTO servers (kategori_server, nama_server, pusat_data, tanggal_pembuatan, pembuat, spek_cpu, spek_ram, spek_hdd, software_terpasang, kredensial_akun) 
			VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
			req.KategoriServer, encNamaServer, encPusatData, req.TanggalPembuatan, req.Pembuat, req.SpekCPU, req.SpekRAM, req.SpekHDD, encSoftware, encKredensial)
		if err != nil {
			tx.Rollback()
			http.Error(w, "Gagal insert server", http.StatusInternalServerError)
			return
		}
		serverID, _ = res.LastInsertId()
		CatatLog(h.DB, req.AdminNama, req.AdminEmail, "menambahkan data server "+req.NamaServer)

	} else {
		serverID = int64(req.ID)
		_, err := tx.Exec(`UPDATE servers SET kategori_server=?, nama_server=?, pusat_data=?, tanggal_pembuatan=?, pembuat=?, spek_cpu=?, spek_ram=?, spek_hdd=?, software_terpasang=?, kredensial_akun=? WHERE id=?`,
			req.KategoriServer, encNamaServer, encPusatData, req.TanggalPembuatan, req.Pembuat, req.SpekCPU, req.SpekRAM, req.SpekHDD, encSoftware, encKredensial, req.ID)
		if err != nil {
			tx.Rollback()
			http.Error(w, "Gagal update server", http.StatusInternalServerError)
			return
		}
		tx.Exec("DELETE FROM ip_usages WHERE server_id=?", serverID)
		CatatLog(h.DB, req.AdminNama, req.AdminEmail, "mengedit data server "+req.NamaServer)
	}

	for _, ip := range req.AssignedIPs {
		if ip.IPAddress != "" {
			tx.Exec(`INSERT INTO ip_usages (ip_block_id, server_id, ip_address, kegunaan, port_info, status) VALUES (?, ?, ?, ?, ?, ?)`,
				ip.IPBlockID, serverID, EncryptData(ip.IPAddress), ip.Kegunaan, EncryptData(ip.PortInfo), "Aktif")
		}
	}

	tx.Commit()
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{"message": "Server dan IP berhasil dikaitkan!"})
}

func (h *ServerHandler) GetServers(w http.ResponseWriter, r *http.Request) {
	rows, err := h.DB.Query(`
		SELECT id, IFNULL(kategori_server, 'Virtual'), IFNULL(nama_server, ''), IFNULL(pusat_data, ''), 
		IFNULL(DATE_FORMAT(tanggal_pembuatan, '%Y-%m-%d'), ''), IFNULL(pembuat, ''), IFNULL(spek_cpu, ''), IFNULL(spek_ram, ''), IFNULL(spek_hdd, ''),
		IFNULL(software_terpasang, '[]'), IFNULL(kredensial_akun, '{}')
		FROM servers ORDER BY id DESC
	`)
	if err != nil {
		http.Error(w, "Gagal mengambil data server", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var servers []ServerData
	for rows.Next() {
		var s ServerData
		var softJSON, credJSON string
		rows.Scan(&s.ID, &s.KategoriServer, &s.NamaServer, &s.PusatData, &s.TanggalPembuatan, &s.Pembuat, &s.SpekCPU, &s.SpekRAM, &s.SpekHDD, &softJSON, &credJSON)

		// DEKRIPSI
		s.NamaServer = DecryptData(s.NamaServer)
		s.PusatData = DecryptData(s.PusatData)
		decSoft := DecryptData(softJSON)
		decCred := DecryptData(credJSON)

		json.Unmarshal([]byte(decSoft), &s.Software)
		json.Unmarshal([]byte(decCred), &s.Kredensial)

		ipRows, _ := h.DB.Query("SELECT id, ip_block_id, ip_address, port_info, kegunaan FROM ip_usages WHERE server_id=?", s.ID)
		for ipRows.Next() {
			var ip AssignedIP
			ipRows.Scan(&ip.ID, &ip.IPBlockID, &ip.IPAddress, &ip.PortInfo, &ip.Kegunaan)

			// DEKRIPSI
			ip.IPAddress = DecryptData(ip.IPAddress)
			ip.PortInfo = DecryptData(ip.PortInfo)

			s.AssignedIPs = append(s.AssignedIPs, ip)
		}
		ipRows.Close()

		servers = append(servers, s)
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(servers)
}

func (h *ServerHandler) DeleteServer(w http.ResponseWriter, r *http.Request) {
	id := r.URL.Query().Get("id")
	adminNama := r.URL.Query().Get("admin_nama")
	adminEmail := r.URL.Query().Get("admin_email")

	var namaServer string
	h.DB.QueryRow("SELECT nama_server FROM servers WHERE id=?", id).Scan(&namaServer)

	_, err := h.DB.Exec("DELETE FROM servers WHERE id=?", id)
	if err != nil {
		http.Error(w, "Gagal menghapus server", http.StatusInternalServerError)
		return
	}

	CatatLog(h.DB, adminNama, adminEmail, "menghapus data server "+DecryptData(namaServer))

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{"message": "Server berhasil dihapus"})
}
// === API GOLANG - DCFMIS - Saeful Hamdi (shamdi.rh@gmail.com) ===