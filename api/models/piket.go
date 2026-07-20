package models

import "time"

type PiketUtama struct {
	ID                 int        `json:"id"`
	Timestamp          time.Time  `json:"timestamp"`
	Email              string     `json:"email" validate:"required,email"`
	NamaLengkap        string     `json:"nama_lengkap" validate:"required"`
	Jabatan            string     `json:"jabatan" validate:"required"`
	TanggalPemeriksaan string     `json:"tanggal_pemeriksaan" validate:"required"`
	JamPemeriksaan     string     `json:"jam_pemeriksaan" validate:"required"`
	KebersihanRuangan  string     `json:"kebersihan_ruangan"`
	KebersihanSampah   string     `json:"kebersihan_sampah"`
	SuhuRuanganServer  string     `json:"suhu_ruangan_server"`
	CatatanTambahan    string     `json:"catatan_tambahan"`
	Fasilitas          Fasilitas  `json:"fasilitas"`
	Kelistrikan        []PanelSDP `json:"kelistrikan"`
	UPS                []DataUPS  `json:"ups"`
}

type Fasilitas struct {
	AC1   string `json:"ac_1"`
	AC2   string `json:"ac_2"`
	AC3   string `json:"ac_3"`
	AC4   string `json:"ac_4"`
	AC5   string `json:"ac_5"`
	AC6   string `json:"ac_6"`
	AC7   string `json:"ac_7"`
	CCTV1 string `json:"cctv_1"`
	CCTV2 string `json:"cctv_2"`
	CCTV3 string `json:"cctv_3"`
	CCTV4 string `json:"cctv_4"`
}

type PanelSDP struct {
	PanelNama    string  `json:"panel_nama"`
	KondisiDalam string  `json:"kondisi_dalam"`
	AmpereR      float64 `json:"ampere_r"`
	AmpereS      float64 `json:"ampere_s"`
	AmpereT      float64 `json:"ampere_t"`
	VoltR        float64 `json:"volt_r"`
	VoltS        float64 `json:"volt_s"`
	VoltT        float64 `json:"volt_t"`
	Hz           *float64`json:"hz,omitempty"` // pointer untuk handle null di SDP 1
}

type DataUPS struct {
	UPSNama        string `json:"ups_nama"`
	KondisiUmum    string `json:"kondisi_umum"`
	TempInternal   int    `json:"temp_internal"`
	TempExternal   int    `json:"temp_external"`
	IndikatorLED   string `json:"indikator_led"`
	TeganganInputA string `json:"tegangan_input_a"`
	TeganganInputB string `json:"tegangan_input_b"`
	LoadCapacity   string `json:"load_capacity"`
}
// === API GOLANG - DCFMIS - Saeful Hamdi (shamdi.rh@gmail.com) ===