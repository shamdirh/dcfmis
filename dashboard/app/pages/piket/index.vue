<template>
  <div class="p-6 text-slate-100 min-h-screen bg-slate-950 font-sans">
    
    <div class="flex justify-between items-center border-b border-slate-800 pb-4 mb-6">
      <div>
        <h1 class="text-2xl font-bold text-blue-500 uppercase tracking-widest">Laporan Operasional PUSDAT</h1>
        <p class="text-xs text-slate-400 mt-1">Sistem Pengawasan Terpadu Diskominfo (105 Parameter)</p>
      </div>
      <button @click="navigateTo('/')" class="bg-slate-800 hover:bg-slate-700 px-4 py-2 rounded text-sm transition">← Kembali</button>
    </div>

    <div class="grid grid-cols-1 xl:grid-cols-4 gap-6">
      
      <!-- =========================== -->
      <!-- KOLOM KIRI: ARSIP LAPORAN   -->
      <!-- =========================== -->
      <div class="xl:col-span-1 bg-slate-900 border border-slate-800 rounded-xl p-4 h-fit flex flex-col max-h-[820px]">
        <div class="flex justify-between items-center mb-4 border-b border-slate-800 pb-2">
          <h2 class="text-sm font-bold text-slate-300 uppercase tracking-wider">Arsip Laporan</h2>
          <button v-if="userRole != 3" @click="resetForm" class="bg-blue-600 hover:bg-blue-500 px-3 py-1.5 rounded text-xs transition font-bold shadow-lg">
            + Form Baru
          </button>
        </div>

        <!-- KOLOM PENCARIAN -->
        <div class="mb-3">
          <input v-model="searchQuery" type="text" placeholder="🔍 Cari nama petugas atau YYYY-MM-DD..." 
                 class="w-full bg-slate-950 border border-slate-700 rounded-lg p-2 text-xs text-slate-200 outline-none focus:border-blue-500 transition-all placeholder-slate-600">
        </div>
        
        <!-- LIST ARSIP DENGAN PAGINASI -->
        <div class="space-y-2 overflow-y-auto pr-1 flex-1">
          <div v-if="paginatedArsip.length === 0" class="text-center text-slate-500 text-xs italic py-4">
            Tidak ada laporan ditemukan.
          </div>
          <div v-for="log in paginatedArsip" :key="log.id" @click="selectLog(log.id)" 
               :class="{'border-blue-500 bg-slate-800': form.id === log.id}"
               class="p-3 border border-slate-700 bg-slate-950 rounded hover:border-blue-500 cursor-pointer transition">
            <div class="font-bold text-sm text-slate-200">{{ log.nama_lengkap }}</div>
            <div class="text-[11px] text-slate-500 flex justify-between mt-1">
              <span>{{ log.tanggal_pemeriksaan }} ({{ log.jam_pemeriksaan.substring(0,5) }})</span>
              <span class="text-amber-400 font-mono">{{ log.suhu_ruangan_server }}</span>
            </div>
          </div>
        </div>

        <!-- TOMBOL PAGINASI (PREV / NEXT) -->
        <div class="flex justify-between items-center mt-3 pt-3 border-t border-slate-800">
          <button @click="currentPage--" :disabled="currentPage === 1" 
                  class="text-xs bg-slate-800 hover:bg-slate-700 px-3 py-1.5 rounded disabled:opacity-30 transition">
            ← Prev
          </button>
          <span class="text-[10px] text-slate-400 font-bold tracking-widest">
            HAL {{ totalPages === 0 ? 0 : currentPage }} / {{ totalPages }}
          </span>
          <button @click="currentPage++" :disabled="currentPage >= totalPages" 
                  class="text-xs bg-slate-800 hover:bg-slate-700 px-3 py-1.5 rounded disabled:opacity-30 transition">
            Next →
          </button>
        </div>
      </div>

      <!-- ========================================== -->
      <!-- KOLOM KANAN: FORM 105 PARAMETER PIKET      -->
      <!-- ========================================== -->
      <div class="xl:col-span-3 bg-slate-900 border border-slate-800 rounded-xl p-6 relative">
        <div class="absolute top-6 right-6 flex gap-2 z-10" v-if="form.id && userRole != 3">
          <button v-if="isViewMode" @click="isViewMode = false" class="bg-amber-600 hover:bg-amber-500 px-4 py-1.5 rounded text-xs font-bold text-white shadow-lg transition flex items-center gap-2">
            ✏️ Edit Laporan
          </button>
          <button v-else @click="isViewMode = true" class="bg-slate-700 hover:bg-slate-600 px-4 py-1.5 rounded text-xs font-bold text-white shadow-lg transition">
            Batal Edit
          </button>
        </div>

        <h2 class="text-lg font-semibold mb-6 border-b border-slate-800 pb-2 uppercase tracking-wider"
            :class="isViewMode ? 'text-green-400' : 'text-blue-400'">
          {{ isViewMode ? `Dokumen Laporan (Mode Baca) - ID: ${form.id}` : (form.id ? `Edit Laporan ID: ${form.id}` : 'Pengisian Laporan Baru') }}
        </h2>

        <form @submit.prevent="saveLaporan" class="space-y-8 max-h-[700px] overflow-y-auto pr-2">
          
          <div class="border border-slate-700 p-5 rounded-lg" :class="isViewMode ? 'bg-slate-900/30' : 'bg-slate-950'">
            <h3 class="text-sm font-bold text-blue-400 mb-4 border-b border-slate-800 pb-2">1. INFORMASI DASAR & LINGKUNGAN</h3>
            <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
              <div><label class="label-style">Email Petugas</label><input disabled v-model="form.email" type="email" class="input-style"></div>
              <div><label class="label-style">Nama Lengkap</label><input disabled v-model="form.nama_lengkap" type="text" class="input-style"></div>
              <div><label class="label-style">Jabatan</label><input disabled v-model="form.jabatan" type="text" class="input-style"></div>
              <div><label class="label-style text-blue-300">Tanggal Pemeriksaan *</label><input :disabled="isViewMode" v-model="form.tanggal_pemeriksaan" type="date" class="input-style border-blue-900"></div>
              
              <div><label class="label-style text-blue-300">Jam Pemeriksaan *</label><input :disabled="isViewMode" v-model="form.jam_pemeriksaan" type="time" class="input-style border-blue-900"></div>
              <div>
                <label class="label-style">Kebersihan Ruangan *</label>
                <select :disabled="isViewMode" v-model="form.kebersihan_ruangan" class="input-style">
                  <option>Bersih</option><option>Kotor Sudah Dibersihkan</option>
                </select>
              </div>
              <div>
                <label class="label-style">Kebersihan Sampah *</label>
                <select :disabled="isViewMode" v-model="form.kebersihan_sampah" class="input-style">
                  <option>Bersih</option><option>Kotor Sudah Dibersihkan</option>
                </select>
              </div>
              <div><label class="label-style text-blue-300">Suhu Ruang Server *</label><input :disabled="isViewMode" v-model="form.suhu_ruangan_server" type="text" placeholder="Cth: 22 IN 21 OUT" class="input-style border-blue-900"></div>
              <div><label class="label-style">Kondisi PC NOC *</label><input :disabled="isViewMode" v-model="form.status_pc_noc" type="text" class="input-style border-blue-900"></div>
            </div>
            <div class="mt-4"><label class="label-style text-blue-300">Catatan Kejadian Selama Piket *</label><textarea :disabled="isViewMode" v-model="form.catatan_kejadian" class="input-style h-16 border-blue-900" placeholder="Tulis catatan lengkap di sini..."></textarea></div>
          </div>

          <div class="border border-slate-700 p-5 rounded-lg" :class="isViewMode ? 'bg-slate-900/30' : 'bg-slate-950'">
            <h3 class="text-sm font-bold text-indigo-400 mb-4 border-b border-slate-800 pb-2">2. STATUS AC & CCTV</h3>
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              <div v-for="(val, key) in form.fasilitas.ac" :key="key">
                <label class="label-style">{{ key }} *</label>
                <input :disabled="isViewMode" v-model="form.fasilitas.ac[key]" type="text" class="input-style">
              </div>
              <div class="col-span-full border-b border-slate-800 mt-2 mb-2"></div>
              <div v-for="(val, key) in form.fasilitas.cctv" :key="key">
                <label class="label-style text-indigo-300">{{ key }} *</label>
                <input :disabled="isViewMode" v-model="form.fasilitas.cctv[key]" type="text" class="input-style">
              </div>
            </div>
          </div>

          <div class="border border-slate-700 p-5 rounded-lg" :class="isViewMode ? 'bg-slate-900/30' : 'bg-slate-950'">
            <h3 class="text-sm font-bold text-teal-400 mb-4 border-b border-slate-800 pb-2">3. KONDISI RAK SERVER</h3>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div v-for="(val, key) in form.fasilitas.rak" :key="key">
                <label class="label-style">{{ key }} *</label>
                <input :disabled="isViewMode" v-model="form.fasilitas.rak[key]" type="text" class="input-style">
              </div>
            </div>
          </div>

          <div class="border border-slate-700 p-5 rounded-lg" :class="isViewMode ? 'bg-slate-900/30' : 'bg-slate-950'">
            <h3 class="text-sm font-bold text-amber-400 mb-4 border-b border-slate-800 pb-2">4. KELISTRIKAN & UPS (DISUSUN BERDASARKAN LOKASI FISIK PERANGKAT)</h3>
            
            <div class="space-y-6">
              <div v-for="(item, i) in physicalLayout" :key="i">
                
                <div v-if="item.type === 'panel' && form.panels[item.index]" class="bg-slate-900/60 p-4 border border-slate-700 rounded-lg">
                  <h4 class="font-bold text-amber-400 mb-3 text-sm flex justify-between items-center">
                    <span>⚡ {{ form.panels[item.index].nama_panel }}</span>
                    <select :disabled="isViewMode" v-model="form.panels[item.index].kondisi" class="bg-slate-800 text-xs px-2 py-1 rounded border border-slate-700 outline-none text-slate-300">
                      <option>Bersih</option><option>Kotor</option>
                    </select>
                  </h4>
                  <div class="grid grid-cols-2 lg:grid-cols-7 gap-3">
                    <div><label class="label-style">Ampere R *</label><input :disabled="isViewMode" v-model="form.panels[item.index].amp_r" type="text" class="input-style text-center font-mono"></div>
                    <div><label class="label-style">Ampere S *</label><input :disabled="isViewMode" v-model="form.panels[item.index].amp_s" type="text" class="input-style text-center font-mono"></div>
                    <div><label class="label-style">Ampere T *</label><input :disabled="isViewMode" v-model="form.panels[item.index].amp_t" type="text" class="input-style text-center font-mono"></div>
                    <div><label class="label-style">Voltase R *</label><input :disabled="isViewMode" v-model="form.panels[item.index].volt_r" type="text" class="input-style text-center font-mono"></div>
                    <div><label class="label-style">Voltase S *</label><input :disabled="isViewMode" v-model="form.panels[item.index].volt_s" type="text" class="input-style text-center font-mono"></div>
                    <div><label class="label-style">Voltase T *</label><input :disabled="isViewMode" v-model="form.panels[item.index].volt_t" type="text" class="input-style text-center font-mono"></div>
                    <div><label class="label-style">Frekuensi Hz *</label><input :disabled="isViewMode" v-model="form.panels[item.index].hz" type="text" class="input-style text-center font-mono"></div>
                  </div>
                </div>

                <div v-if="item.type === 'ups' && form.ups[item.index]" class="bg-slate-800/40 p-4 border border-blue-900/50 rounded-lg">
                  <h4 class="font-bold text-blue-300 mb-3 text-sm flex justify-between items-center">
                    <span>🔋 {{ form.ups[item.index].nama_ups }}</span>
                    <select :disabled="isViewMode" v-model="form.ups[item.index].kondisi_fisik" class="bg-slate-800 text-xs px-2 py-1 rounded border border-slate-700 outline-none text-slate-300">
                      <option>Bersih</option><option>Kotor</option>
                    </select>
                  </h4>
                  <div class="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-4">
                    <div><label class="label-style">Temp Internal (°C) *</label><input :disabled="isViewMode" v-model="form.ups[item.index].temp_in" type="text" class="input-style text-center"></div>
                    <div><label class="label-style">Temp External (°C) *</label><input :disabled="isViewMode" v-model="form.ups[item.index].temp_out" type="text" class="input-style text-center"></div>
                    <div><label class="label-style">Indikator LED *</label><select :disabled="isViewMode" v-model="form.ups[item.index].led_indicator" class="input-style text-center text-xs"><option>Online/Inverter LED</option><option>Battery LED</option><option>Bypass LED</option><option>Fault/Alarm Red</option></select></div>
                    <div><label class="label-style">Kapasitas Baterai *</label><select :disabled="isViewMode" v-model="form.ups[item.index].indikator_baterai" class="input-style text-center text-xs"><option>5 Kotak= 100%</option><option>4 Kotak= 80%</option><option>3 Kotak= 60%</option><option>2 Kotak= 40%</option><option>1 Kotak= 20%</option></select></div>
                  </div>
                  <div class="grid grid-cols-2 lg:grid-cols-6 gap-3 pt-3 border-t border-slate-700/50">
                    <div><label class="label-style text-amber-500 text-[9px]">IN Phase A *</label><input :disabled="isViewMode" v-model="form.ups[item.index].in_a" type="text" class="input-style font-mono text-center"></div>
                    <div><label class="label-style text-amber-500 text-[9px]">IN Phase B *</label><input :disabled="isViewMode" v-model="form.ups[item.index].in_b" type="text" class="input-style font-mono text-center"></div>
                    <div><label class="label-style text-amber-500 text-[9px]">IN Phase C *</label><input :disabled="isViewMode" v-model="form.ups[item.index].in_c" type="text" class="input-style font-mono text-center"></div>
                    <div><label class="label-style text-green-500 text-[9px]">OUT Phase A *</label><input :disabled="isViewMode" v-model="form.ups[item.index].out_a" type="text" class="input-style font-mono text-center"></div>
                    <div><label class="label-style text-green-500 text-[9px]">OUT Phase B *</label><input :disabled="isViewMode" v-model="form.ups[item.index].out_b" type="text" class="input-style font-mono text-center"></div>
                    <div><label class="label-style text-green-500 text-[9px]">OUT Phase C *</label><input :disabled="isViewMode" v-model="form.ups[item.index].out_c" type="text" class="input-style font-mono text-center"></div>
                  </div>
                </div>

              </div>
            </div>
          </div>

          <div v-if="!isViewMode && userRole != 3" class="sticky bottom-0 bg-slate-900 pt-4 border-t border-slate-800 flex justify-end gap-3">
            <button type="submit" :disabled="isSaving" class="bg-blue-600 hover:bg-blue-500 px-8 py-3 rounded font-bold uppercase tracking-widest text-sm text-white shadow-lg disabled:opacity-50 transition">
              {{ isSaving ? 'Mengecek & Menyimpan...' : 'Simpan 105 Parameter' }}
            </button>
          </div>
        </form>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'

definePageMeta({ middleware: 'auth' })

const roleCookie = useCookie('user_role')
const userRole = ref(roleCookie.value)

const userEmail = useCookie('user_email')
const userNama = useCookie('user_nama')
const userJabatan = useCookie('user_jabatan')

const arsip = ref([])
const isSaving = ref(false)
const isViewMode = ref(false)

// ==========================================
// STATE UNTUK UX FILTER & PAGINASI
// ==========================================
const searchQuery = ref('')
const currentPage = ref(1)
const itemsPerPage = 8 

const filteredArsip = computed(() => {
  if (!searchQuery.value) return arsip.value;
  const lowerCaseQuery = searchQuery.value.toLowerCase();
  return arsip.value.filter(log => 
    (log.nama_lengkap && log.nama_lengkap.toLowerCase().includes(lowerCaseQuery)) ||
    (log.tanggal_pemeriksaan && log.tanggal_pemeriksaan.includes(lowerCaseQuery))
  );
})

const totalPages = computed(() => {
  return Math.ceil(filteredArsip.value.length / itemsPerPage);
})

const paginatedArsip = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage;
  const end = start + itemsPerPage;
  return filteredArsip.value.slice(start, end);
})

watch(searchQuery, () => {
  currentPage.value = 1;
})
// ==========================================

const physicalLayout = [
  { type: 'panel', index: 0 }, 
  { type: 'panel', index: 1 }, 
  { type: 'ups', index: 0 },   
  { type: 'panel', index: 2 }, 
  { type: 'ups', index: 1 },   
  { type: 'panel', index: 3 }, 
  { type: 'ups', index: 2 },   
  { type: 'panel', index: 4 }  
]

const emptyForm = () => ({
  id: null, 
  email: userEmail.value || '', 
  nama_lengkap: userNama.value || '', 
  jabatan: userJabatan.value || '', 
  tanggal_pemeriksaan: new Date().toISOString().split('T')[0], 
  jam_pemeriksaan: '08:00',
  kebersihan_ruangan: 'Bersih', kebersihan_sampah: 'Bersih', suhu_ruangan_server: '',
  status_pc_noc: 'Menyala Normal', catatan_kejadian: '',
  fasilitas: { 
    ac: { 'Status AC 1 - Ruang NOC': 'Menyala Normal', 'Status AC 2 - Ruang Server': 'Menyala Normal', 'Status AC 3 - Ruang Server': 'Menyala Normal', 'Status AC 4 - Ruang Server': 'Menyala Normal', 'Status AC 5 - Ruang Server': 'Menyala Normal', 'Status AC 6 - Ruang Server': 'Menyala Normal', 'Status AC 7 - Ruang Pusat Data 2': 'Menyala Normal' },
    cctv: { 'Status CCTV 1 - Ruang NOC': 'Menyala Normal', 'Status CCTV 2 - Ruang Server': 'Menyala Normal', 'Status CCTV 3 - Ruang Server': 'Menyala Normal', 'Status CCTV 4 - Ruang Pusat Data 2': 'Menyala Normal' },
    rak: { 'Rak Server 1': 'Tidak Ada Perubahan', 'Rak Server 2': 'Tidak Ada Perubahan', 'Rak Server 3': 'Tidak Ada Perubahan', 'Rak Server 4': 'Tidak Ada Perubahan', 'Rak Server 5': 'Tidak Ada Perubahan', 'Rak Server 6': 'Tidak Ada Perubahan', 'Rak Server 7': 'Tidak Ada Perubahan', 'Rak Server 8': 'Tidak Ada Perubahan', 'Rak Server 9': 'Tidak Ada Perubahan' }
  },
  panels: ['Panel SDP 1', 'Panel SDP 2', 'Panel Distribusi 1', 'Panel Distribusi 2', 'Panel Distribusi 3'].map(p => ({ nama_panel: p, kondisi: 'Bersih', amp_r: '', amp_s: '', amp_t: '', volt_r: '', volt_s: '', volt_t: '', hz: '' })),
  ups: ['UPS 1', 'UPS 2', 'UPS 3'].map(u => ({ nama_ups: u, kondisi_fisik: 'Bersih', temp_in: '', temp_out: '', led_indicator: 'Online/Inverter LED', indikator_baterai: '5 Kotak= 100%', in_a: '', in_b: '', in_c: '', out_a: '', out_b: '', out_c: '' }))
})

const form = ref(emptyForm())

const config = useRuntimeConfig()
const API_URL = config.public.apiBase

const headersConfig = {
  'Content-Type': 'application/json',
  'X-App-Token': '[o0Ht1407!=5437ul=@K8R{*?zQL36;}0o]'
}

const fetchArsip = async () => {
  try {
    const res = await $fetch(`${API_URL}/api/piket/summary`, { headers: headersConfig })
    arsip.value = typeof res === 'string' ? JSON.parse(res) : res || []
  } catch (error) {
    console.error("Gagal menarik data arsip piket:", error)
  }
}

const selectLog = async (id) => {
  isViewMode.value = true 
  try {
    const res = await $fetch(`${API_URL}/api/piket/detail?id=${id}`, { headers: headersConfig })
    let data = typeof res === 'string' ? JSON.parse(res) : res
    
    if (data.tanggal_pemeriksaan && data.tanggal_pemeriksaan.includes('T')) {
      data.tanggal_pemeriksaan = data.tanggal_pemeriksaan.split('T')[0]
    }

    const template = emptyForm();
    if (!data.fasilitas) data.fasilitas = {};
    
    const finalFasilitas = { ...template.fasilitas };
    if (data.fasilitas.ac) for (const key in finalFasilitas.ac) if (data.fasilitas.ac[key]) finalFasilitas.ac[key] = data.fasilitas.ac[key];
    if (data.fasilitas.cctv) for (const key in finalFasilitas.cctv) if (data.fasilitas.cctv[key]) finalFasilitas.cctv[key] = data.fasilitas.cctv[key];
    if (data.fasilitas.rak) for (const key in finalFasilitas.rak) if (data.fasilitas.rak[key]) finalFasilitas.rak[key] = data.fasilitas.rak[key];

    if (!data.panels || data.panels.length === 0) data.panels = template.panels;
    if (!data.ups || data.ups.length === 0) data.ups = template.ups;

    form.value = { ...template, ...data, fasilitas: finalFasilitas }

  } catch (error) {
    console.error("Gagal menarik detail data")
  }
}

const resetForm = () => {
  isViewMode.value = false
  form.value = emptyForm()
}

const validateLaporan = () => {
  const f = form.value;
  if (!f.tanggal_pemeriksaan || !f.jam_pemeriksaan || !f.suhu_ruangan_server || !f.status_pc_noc || !f.catatan_kejadian) return "Info Dasar & Lingkungan masih belum lengkap!";
  for (const p of f.panels) {
    if (!p.amp_r || !p.amp_s || !p.amp_t || !p.volt_r || !p.volt_s || !p.volt_t || !p.hz) return `Indikator Ampere/Voltase pada ${p.nama_panel} tidak boleh kosong!`;
  }
  for (const u of f.ups) {
    if (!u.temp_in || !u.temp_out || !u.in_a || !u.in_b || !u.in_c || !u.out_a || !u.out_b || !u.out_c) return `Seluruh parameter input/output pada ${u.nama_ups} tidak boleh kosong!`;
  }
  return null; 
}

const saveLaporan = async () => {
  const errorMessage = validateLaporan();
  if (errorMessage) {
    alert("PENYIMPANAN DITOLAK: \n\n" + errorMessage);
    return;
  }

  isSaving.value = true
  try {
    await $fetch(`${API_URL}/api/piket/manage`, { 
      method: 'POST', 
      headers: headersConfig,
      body: form.value 
    })
    alert("Berhasil memproses 105 Parameter Laporan Piket!")
    fetchArsip()
    isViewMode.value = true 
  } catch (error) {
    alert("Gagal: " + (error.response?._data || error.message))
  } finally {
    isSaving.value = false
  }
}

onMounted(() => {
  fetchArsip()
  if (userRole.value == 3) {
    isViewMode.value = true
  }
})
</script>

<style scoped>
.label-style { @apply text-[11px] text-slate-400 block mb-1 uppercase tracking-wider font-semibold; }
.input-style { @apply w-full bg-slate-900 border border-slate-700 rounded p-2 text-sm text-slate-200 transition-all duration-300 outline-none focus:border-blue-500; }
.input-style:disabled { @apply bg-slate-900/40 border-transparent text-slate-400 font-semibold cursor-not-allowed shadow-inner; }

.overflow-y-auto::-webkit-scrollbar { width: 4px; }
.overflow-y-auto::-webkit-scrollbar-thumb { background-color: #334155; border-radius: 4px; }
</style>
<!-- === NUXT DASHBOARD ADMIN - DCFMIS - Saeful Hamdi (shamdi.rh@gmail.com) === -->