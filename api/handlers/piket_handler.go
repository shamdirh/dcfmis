package handlers

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
)

type PiketHandler struct {
	DB *sql.DB
}

type Panel struct {
	NamaPanel string `json:"nama_panel"`
	Kondisi   string `json:"kondisi"`
	AmpR      string `json:"amp_r"`
	AmpS      string `json:"amp_s"`
	AmpT      string `json:"amp_t"`
	VoltR     string `json:"volt_r"`
	VoltS     string `json:"volt_s"`
	VoltT     string `json:"volt_t"`
	Hz        string `json:"hz"`
}

type UPS struct {
	NamaUPS          string `json:"nama_ups"`
	KondisiFisik     string `json:"kondisi_fisik"`
	TempIn           string `json:"temp_in"`
	TempOut          string `json:"temp_out"`
	LedIndicator     string `json:"led_indicator"`
	IndikatorBaterai string `json:"indikator_baterai"`
	InA              string `json:"in_a"`
	InB              string `json:"in_b"`
	InC              string `json:"in_c"`
	OutA             string `json:"out_a"`
	OutB             string `json:"out_b"`
	OutC             string `json:"out_c"`
}

type Fasilitas struct {
	AC   map[string]string `json:"ac"`
	CCTV map[string]string `json:"cctv"`
	Rak  map[string]string `json:"rak"`
}

type PiketRequest struct {
	ID                 int       `json:"id,omitempty"`
	Email              string    `json:"email"`
	NamaLengkap        string    `json:"nama_lengkap"`
	Jabatan            string    `json:"jabatan"`
	TanggalPemeriksaan string    `json:"tanggal_pemeriksaan"`
	JamPemeriksaan     string    `json:"jam_pemeriksaan"`
	KebersihanRuangan  string    `json:"kebersihan_ruangan"`
	KebersihanSampah   string    `json:"kebersihan_sampah"`
	SuhuRuanganServer  string    `json:"suhu_ruangan_server"`
	StatusPcNoc        string    `json:"status_pc_noc"`
	CatatanKejadian    string    `json:"catatan_kejadian"`
	Fasilitas          Fasilitas `json:"fasilitas"`
	Panels             []Panel   `json:"panels"`
	UPS                []UPS     `json:"ups"`
}

type PiketSummary struct {
	ID                 int    `json:"id"`
	NamaLengkap        string `json:"nama_lengkap"`
	TanggalPemeriksaan string `json:"tanggal_pemeriksaan"`
	JamPemeriksaan     string `json:"jam_pemeriksaan"`
	SuhuRuanganServer  string `json:"suhu_ruangan_server"`
	KebersihanRuangan  string `json:"kebersihan_ruangan"`
	KebersihanSampah   string `json:"kebersihan_sampah"`
	StatusPcNoc        string `json:"status_pc_noc"`
	CatatanKejadian    string `json:"catatan_kejadian"`
}

func (h *PiketHandler) GetPiketSummary(w http.ResponseWriter, r *http.Request) {
	pageStr := r.URL.Query().Get("page")
	tanggal := r.URL.Query().Get("tanggal")

	page := 1
	if pageStr != "" {
		if p, err := strconv.Atoi(pageStr); err == nil {
			page = p
		}
	}

	limit := 6
	offset := (page - 1) * limit

	query := `
		SELECT id, IFNULL(nama_lengkap, ''), IFNULL(DATE_FORMAT(tanggal_pemeriksaan, '%Y-%m-%d'), ''), 
		IFNULL(jam_pemeriksaan, ''), IFNULL(suhu_ruangan_server, ''), IFNULL(kebersihan_ruangan, ''), 
		IFNULL(kebersihan_sampah, ''), IFNULL(status_pc_noc, ''), IFNULL(catatan_kejadian, '') 
		FROM piket_laporan WHERE 1=1 `

	args := []interface{}{}
	if tanggal != "" {
		query += ` AND DATE_FORMAT(tanggal_pemeriksaan, '%Y-%m-%d') = ? `
		args = append(args, tanggal)
	}
	query += ` ORDER BY id DESC LIMIT ? OFFSET ?`
	args = append(args, limit, offset)

	rows, err := h.DB.Query(query, args...)
	if err != nil {
		fmt.Println("Error Query:", err)
		http.Error(w, "Gagal mengambil data", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var summaries []PiketSummary
	for rows.Next() {
		var s PiketSummary
		rows.Scan(&s.ID, &s.NamaLengkap, &s.TanggalPemeriksaan, &s.JamPemeriksaan, &s.SuhuRuanganServer,
			&s.KebersihanRuangan, &s.KebersihanSampah, &s.StatusPcNoc, &s.CatatanKejadian)

		// DEKRIPSI NAMA
		s.NamaLengkap = DecryptData(s.NamaLengkap)

		summaries = append(summaries, s)
	}

	if summaries == nil {
		summaries = []PiketSummary{}
	}
	json.NewEncoder(w).Encode(summaries)
}

func (h *PiketHandler) GetPiketDetail(w http.ResponseWriter, r *http.Request) {
	id := r.URL.Query().Get("id")
	var req PiketRequest

	h.DB.QueryRow(`
		SELECT id, IFNULL(email, ''), IFNULL(nama_lengkap, ''), IFNULL(jabatan, ''), 
		IFNULL(DATE_FORMAT(tanggal_pemeriksaan, '%Y-%m-%d'), ''), IFNULL(jam_pemeriksaan, ''), IFNULL(kebersihan_ruangan, ''), 
		IFNULL(kebersihan_sampah, ''), IFNULL(suhu_ruangan_server, ''), IFNULL(status_pc_noc, ''), IFNULL(catatan_kejadian, '') 
		FROM piket_laporan WHERE id=?
	`, id).Scan(
		&req.ID, &req.Email, &req.NamaLengkap, &req.Jabatan, &req.TanggalPemeriksaan,
		&req.JamPemeriksaan, &req.KebersihanRuangan, &req.KebersihanSampah, &req.SuhuRuanganServer,
		&req.StatusPcNoc, &req.CatatanKejadian,
	)

	// DEKRIPSI
	req.Email = DecryptData(req.Email)
	req.NamaLengkap = DecryptData(req.NamaLengkap)

	var acCctvData, rakData []byte
	h.DB.QueryRow("SELECT ac_cctv_data, rak_server_data FROM piket_fasilitas WHERE piket_id=?", id).Scan(&acCctvData, &rakData)

	var acCctv map[string]map[string]string
	json.Unmarshal(acCctvData, &acCctv)
	req.Fasilitas.AC = acCctv["ac"]
	req.Fasilitas.CCTV = acCctv["cctv"]

	var rak map[string]string
	json.Unmarshal(rakData, &rak)
	req.Fasilitas.Rak = rak

	rowsPanel, _ := h.DB.Query(`
		SELECT IFNULL(nama_panel, ''), IFNULL(kondisi, ''), IFNULL(amp_r, ''), IFNULL(amp_s, ''), IFNULL(amp_t, ''), 
		IFNULL(volt_r, ''), IFNULL(volt_s, ''), IFNULL(volt_t, ''), IFNULL(hz, '') 
		FROM piket_panel_listrik WHERE piket_id=?`, id)
	defer rowsPanel.Close()
	for rowsPanel.Next() {
		var p Panel
		rowsPanel.Scan(&p.NamaPanel, &p.Kondisi, &p.AmpR, &p.AmpS, &p.AmpT, &p.VoltR, &p.VoltS, &p.VoltT, &p.Hz)
		req.Panels = append(req.Panels, p)
	}

	rowsUps, _ := h.DB.Query(`
		SELECT IFNULL(nama_ups, ''), IFNULL(kondisi_fisik, ''), IFNULL(temp_in, ''), IFNULL(temp_out, ''), IFNULL(led_indicator, ''), 
		IFNULL(indikator_baterai, ''), IFNULL(in_a, ''), IFNULL(in_b, ''), IFNULL(in_c, ''), IFNULL(out_a, ''), IFNULL(out_b, ''), IFNULL(out_c, '') 
		FROM piket_ups WHERE piket_id=?`, id)
	defer rowsUps.Close()
	for rowsUps.Next() {
		var u UPS
		rowsUps.Scan(&u.NamaUPS, &u.KondisiFisik, &u.TempIn, &u.TempOut, &u.LedIndicator, &u.IndikatorBaterai, &u.InA, &u.InB, &u.InC, &u.OutA, &u.OutB, &u.OutC)
		req.UPS = append(req.UPS, u)
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(req)
}

func (h *PiketHandler) ManagePiket(w http.ResponseWriter, r *http.Request) {
	var req PiketRequest
	json.NewDecoder(r.Body).Decode(&req)

	// ENKRIPSI SEBELUM SIMPAN
	encEmail := EncryptData(req.Email)
	encNama := EncryptData(req.NamaLengkap)

	if req.ID == 0 {
		res, err := h.DB.Exec(`
			INSERT INTO piket_laporan (email, nama_lengkap, jabatan, tanggal_pemeriksaan, jam_pemeriksaan, kebersihan_ruangan, kebersihan_sampah, suhu_ruangan_server, status_pc_noc, catatan_kejadian) 
			VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
			encEmail, encNama, req.Jabatan, req.TanggalPemeriksaan, req.JamPemeriksaan, req.KebersihanRuangan, req.KebersihanSampah, req.SuhuRuanganServer, req.StatusPcNoc, req.CatatanKejadian)

		if err != nil {
			http.Error(w, "Gagal insert laporan", http.StatusInternalServerError)
			return
		}

		piketID, _ := res.LastInsertId()
		acCctvMap := map[string]interface{}{"ac": req.Fasilitas.AC, "cctv": req.Fasilitas.CCTV}
		acCctvData, _ := json.Marshal(acCctvMap)
		rakData, _ := json.Marshal(req.Fasilitas.Rak)
		h.DB.Exec("INSERT INTO piket_fasilitas (piket_id, ac_cctv_data, rak_server_data) VALUES (?, ?, ?)", piketID, acCctvData, rakData)

		for _, p := range req.Panels {
			h.DB.Exec(`INSERT INTO piket_panel_listrik (piket_id, nama_panel, kondisi, amp_r, amp_s, amp_t, volt_r, volt_s, volt_t, hz) 
				VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`, piketID, p.NamaPanel, p.Kondisi, p.AmpR, p.AmpS, p.AmpT, p.VoltR, p.VoltS, p.VoltT, p.Hz)
		}
		for _, u := range req.UPS {
			h.DB.Exec(`INSERT INTO piket_ups (piket_id, nama_ups, kondisi_fisik, temp_in, temp_out, led_indicator, indikator_baterai, in_a, in_b, in_c, out_a, out_b, out_c) 
				VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`, piketID, u.NamaUPS, u.KondisiFisik, u.TempIn, u.TempOut, u.LedIndicator, u.IndikatorBaterai, u.InA, u.InB, u.InC, u.OutA, u.OutB, u.OutC)
		}

		CatatLog(h.DB, req.NamaLengkap, req.Email, "menambahkan laporan piket harian baru")

	} else {
		h.DB.Exec(`
			UPDATE piket_laporan SET email=?, nama_lengkap=?, jabatan=?, tanggal_pemeriksaan=?, jam_pemeriksaan=?, kebersihan_ruangan=?, kebersihan_sampah=?, suhu_ruangan_server=?, status_pc_noc=?, catatan_kejadian=? 
			WHERE id=?`, encEmail, encNama, req.Jabatan, req.TanggalPemeriksaan, req.JamPemeriksaan, req.KebersihanRuangan, req.KebersihanSampah, req.SuhuRuanganServer, req.StatusPcNoc, req.CatatanKejadian, req.ID)

		acCctvMap := map[string]interface{}{"ac": req.Fasilitas.AC, "cctv": req.Fasilitas.CCTV}
		acCctvData, _ := json.Marshal(acCctvMap)
		rakData, _ := json.Marshal(req.Fasilitas.Rak)
		h.DB.Exec("UPDATE piket_fasilitas SET ac_cctv_data=?, rak_server_data=? WHERE piket_id=?", acCctvData, rakData, req.ID)

		h.DB.Exec("DELETE FROM piket_panel_listrik WHERE piket_id=?", req.ID)
		for _, p := range req.Panels {
			h.DB.Exec("INSERT INTO piket_panel_listrik (piket_id, nama_panel, kondisi, amp_r, amp_s, amp_t, volt_r, volt_s, volt_t, hz) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", req.ID, p.NamaPanel, p.Kondisi, p.AmpR, p.AmpS, p.AmpT, p.VoltR, p.VoltS, p.VoltT, p.Hz)
		}

		h.DB.Exec("DELETE FROM piket_ups WHERE piket_id=?", req.ID)
		for _, u := range req.UPS {
			h.DB.Exec("INSERT INTO piket_ups (piket_id, nama_ups, kondisi_fisik, temp_in, temp_out, led_indicator, indikator_baterai, in_a, in_b, in_c, out_a, out_b, out_c) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", req.ID, u.NamaUPS, u.KondisiFisik, u.TempIn, u.TempOut, u.LedIndicator, u.IndikatorBaterai, u.InA, u.InB, u.InC, u.OutA, u.OutB, u.OutC)
		}

		CatatLog(h.DB, req.NamaLengkap, req.Email, "mengedit laporan piket harian (ID: "+strconv.Itoa(req.ID)+")")
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{"message": "Laporan berhasil diproses"})
}

// === API GOLANG - DCFMIS - Saeful Hamdi (shamdi.rh@gmail.com) ===
