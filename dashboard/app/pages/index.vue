<template>
  <div class="min-h-screen bg-slate-950 text-slate-100 p-6 font-sans relative">
    
    <!-- HEADER COMMAND CENTER -->
    <header class="flex flex-col md:flex-row justify-between items-start md:items-center border-b border-slate-800 pb-4 mb-6 gap-4">
      <div>
        <h1 class="text-2xl lg:text-3xl font-bold tracking-wider text-blue-500 uppercase drop-shadow-md">
          Dashboard DCFMIS
        </h1>
        <p class="text-xs text-slate-400 mt-1">Data Center Facility Management Information System</p>
      </div>
      
      <div class="flex items-center gap-4">
        <div class="text-right bg-slate-900 border border-slate-700 p-3 rounded-lg flex flex-col justify-center min-w-[200px] shadow-inner">
          <div class="text-sm font-semibold tracking-widest text-slate-200">{{ currentTime }}</div>
          <div class="text-xs text-green-400 flex items-center justify-end gap-1.5 mt-1 font-bold tracking-wider">
            <span class="h-2 w-2 rounded-full bg-green-500 animate-pulse shadow-[0_0_8px_rgba(34,197,94,0.8)]"></span> 
            SYSTEM ONLINE
          </div>
        </div>
        
        <button @click="handleLogout" class="bg-red-900/40 hover:bg-red-600 text-red-400 hover:text-white border border-red-800 px-4 py-3 rounded-lg text-xs font-bold uppercase tracking-wider transition duration-300 shadow-lg">
          Keluar
        </button>
      </div>
    </header>

    <div class="grid grid-cols-1 xl:grid-cols-4 gap-6">
      
      <!-- ========================================== -->
      <!-- KOLOM KIRI: MENU MODUL (WIDGET STYLE)      -->
      <!-- ========================================== -->
      <div class="xl:col-span-1 flex flex-col gap-5">
        
        <!-- Modul User (Admin Only) -->
        <div v-if="userRole == 1" class="bg-slate-900 border border-purple-900/50 p-4 rounded-xl shadow-lg relative overflow-hidden group hover:border-purple-500 transition duration-300">
          <div class="absolute top-0 left-0 w-1 h-full bg-purple-500"></div>
          <h2 class="text-xs font-bold text-slate-400 mb-4 uppercase tracking-widest flex justify-between items-center">
            <span>Akses User</span>
            <span class="text-[9px] bg-purple-900/50 text-purple-300 px-2 py-0.5 rounded border border-purple-800">Khusus Admin</span>
          </h2>
          <button @click="navigateTo('/users')" class="w-full bg-purple-600/80 hover:bg-purple-500 text-white font-bold py-3 rounded transition uppercase text-[11px] tracking-widest shadow">
            Kelola Pengguna
          </button>
        </div>

        <!-- MODUL PIKET -->
        <div class="bg-slate-900 border border-green-900/50 p-4 rounded-xl shadow-lg relative overflow-hidden group hover:border-green-500 transition duration-300">
          <div class="absolute top-0 left-0 w-1 h-full bg-green-500"></div>
          <h2 class="text-xs font-bold text-slate-400 mb-4 uppercase tracking-widest flex justify-between items-center">
            <span>Laporan Piket</span>
          </h2>
          <button @click="navigateTo('/piket')" class="w-full bg-green-600/80 hover:bg-green-500 text-white font-bold py-3 rounded transition uppercase text-[11px] tracking-widest shadow flex justify-center items-center gap-2">
            <span>📝</span> Isi Form Piket
          </button>
        </div>
        
        <!-- MODUL IP -->
        <div class="bg-slate-900 border border-blue-900/50 p-4 rounded-xl shadow-lg relative overflow-hidden group hover:border-blue-500 transition duration-300">
          <div class="absolute top-0 left-0 w-1 h-full bg-blue-500"></div>
          <h2 class="text-xs font-bold text-slate-400 mb-4 uppercase tracking-widest flex justify-between items-center">
            <span>Alokasi IP</span>
          </h2>
          <button @click="navigateTo('/ip')" class="w-full bg-blue-600/80 hover:bg-blue-500 text-white font-bold py-3 rounded transition uppercase text-[11px] tracking-widest shadow flex justify-center items-center gap-2">
            <span>🌐</span> Manajemen IP
          </button>
        </div>
        
        <!-- MODUL SERVER -->
        <div class="bg-slate-900 border border-amber-900/50 p-4 rounded-xl shadow-lg relative overflow-hidden group hover:border-amber-500 transition duration-300">
          <div class="absolute top-0 left-0 w-1 h-full bg-amber-500"></div>
          <h2 class="text-xs font-bold text-slate-400 mb-4 uppercase tracking-widest flex justify-between items-center">
            <span>Vault Server</span>
          </h2>
          <button @click="navigateTo('/server')" class="w-full bg-amber-600/80 hover:bg-amber-500 text-white font-bold py-3 rounded transition uppercase text-[11px] tracking-widest shadow flex justify-center items-center gap-2">
            <span>🖥️</span> Akses Server
          </button>
        </div>      

        <!-- MODUL LOG AKSES -->
        <div v-if="userRole == 1" class="bg-slate-900 border border-cyan-900/50 p-4 rounded-xl shadow-lg relative overflow-hidden group hover:border-cyan-500 transition duration-300">
          <div class="absolute top-0 left-0 w-1 h-full bg-cyan-500"></div>
          <h2 class="text-xs font-bold text-slate-400 mb-4 uppercase tracking-widest flex justify-between items-center">
            <span>Keamanan</span>
            <span class="text-[9px] bg-cyan-900/50 text-cyan-300 px-2 py-0.5 rounded border border-cyan-800">Admin</span>
          </h2>
          <button @click="navigateTo('/log-akses')" class="w-full bg-cyan-600/80 hover:bg-cyan-500 text-white font-bold py-3 rounded transition uppercase text-[11px] tracking-widest shadow flex justify-center items-center gap-2">
            <span>📡</span> Log Akses & Aktivitas
          </button>
        </div>

        <!-- MODUL TENTANG APLIKASI -->
        <div class="bg-slate-900 border border-teal-900/50 p-4 rounded-xl shadow-lg relative overflow-hidden group hover:border-teal-500 transition duration-300">
          <div class="absolute top-0 left-0 w-1 h-full bg-teal-500"></div>
          <h2 class="text-xs font-bold text-slate-400 mb-4 uppercase tracking-widest flex justify-between items-center">
            <span>Informasi</span>
          </h2>
          <button @click="showAboutModal = true" class="w-full bg-teal-600/80 hover:bg-teal-500 text-white font-bold py-3 rounded transition uppercase text-[11px] tracking-widest shadow flex justify-center items-center gap-2">
            <span>ℹ️</span> Tentang Aplikasi
          </button>
        </div>

      </div>

      <!-- ========================================== -->
      <!-- KOLOM KANAN: DASHBOARD WIDGETS & LOGS      -->
      <!-- ========================================== -->
      <div class="xl:col-span-3 flex flex-col gap-6">
        
        <!-- BARIS WIDGET 1: SERVER & LINGKUNGAN (PIKET) -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          
          <!-- Widget Piket (Kondisi Terkini) -->
          <div class="bg-slate-700 border border-slate-800 rounded-xl p-5 shadow-lg relative overflow-hidden">
            <div class="absolute -right-6 -top-6 text-7xl opacity-5">🌡️</div>
            <h3 class="text-xs font-bold text-green-400 uppercase tracking-widest mb-4">Status Lingkungan Terkini</h3>
            <div class="flex items-end gap-3 mb-2">
              <div class="text-3xl font-black font-mono text-slate-200">{{ latestPiket.suhu || '--' }}</div>
              <div class="text-xs text-slate-400 mb-1">Suhu Server</div>
            </div>
            <div class="text-[10px] text-slate-500 uppercase tracking-wider border-t border-slate-800 pt-3 mt-3 flex justify-between">
              <span>Total Laporan: {{ piketLogs.length }}</span>
              <span class="text-green-400">{{ latestPiket.waktu || 'Menunggu Data' }}</span>
            </div>
          </div>

          <!-- Widget Jaringan (IP) -->
          <div class="bg-slate-700 border border-slate-800 rounded-xl p-5 shadow-lg relative overflow-hidden md:col-span-2">
            <div class="absolute -right-4 -top-4 text-7xl opacity-5">🕸️</div>
            <h3 class="text-xs font-bold text-blue-400 uppercase tracking-widest mb-4">Rekapitulasi Alokasi Jaringan (IP)</h3>
            <div class="grid grid-cols-3 gap-4">
              <div>
                <div class="text-[10px] text-slate-400 uppercase tracking-wider mb-1">Total Blok IP</div>
                <div class="text-2xl font-black text-slate-200">{{ ipStats.totalBlocks }}</div>
              </div>
              <div>
                <div class="text-[10px] text-slate-400 uppercase tracking-wider mb-1">Kapasitas Alamat</div>
                <div class="text-2xl font-black text-blue-300 font-mono">{{ ipStats.totalCapacity }}</div>
              </div>
              <div>
                <div class="text-[10px] text-slate-400 uppercase tracking-wider mb-1">Terpakai (Host)</div>
                <div class="text-2xl font-black text-amber-400 font-mono">{{ ipStats.totalUsed }}</div>
              </div>
            </div>
            <div class="w-full bg-slate-800 h-1.5 mt-4 rounded-full overflow-hidden">
              <div class="bg-blue-500 h-full rounded-full transition-all" :style="`width: ${ipStats.percentage}%`"></div>
            </div>
          </div>

        </div>

        <!-- BARIS WIDGET 2: INFRASTRUKTUR & LOG (GRID) -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          
          <!-- Infrastruktur Server -->
          <div class="bg-slate-700 border border-slate-800 rounded-xl p-5 shadow-lg relative h-full">
            <h3 class="text-xs font-bold text-amber-400 uppercase tracking-widest mb-4 border-b border-slate-800 pb-2">Distribusi Infrastruktur Server</h3>
            <div class="grid grid-cols-2 gap-4 mt-4">
              
              <div class="p-4 rounded-lg bg-slate-950 border border-slate-800 text-center">
                <div class="text-[10px] text-slate-400 uppercase tracking-wider mb-2">Fisik (Balaikota)</div>
                <div class="text-3xl font-black text-emerald-400">{{ serverStats.fisikBalaikota }}</div>
              </div>
              <div class="p-4 rounded-lg bg-slate-950 border border-slate-800 text-center">
                <div class="text-[10px] text-slate-400 uppercase tracking-wider mb-2">Virtual (Balaikota)</div>
                <div class="text-3xl font-black text-blue-400">{{ serverStats.virtualBalaikota }}</div>
              </div>
              <div class="p-4 rounded-lg bg-slate-950 border border-slate-800 text-center">
                <div class="text-[10px] text-slate-400 uppercase tracking-wider mb-2">Fisik (ASNET)</div>
                <div class="text-3xl font-black text-amber-400">{{ serverStats.fisikAsnet }}</div>
              </div>
              <div class="p-4 rounded-lg bg-slate-950 border border-slate-800 text-center">
                <div class="text-[10px] text-slate-400 uppercase tracking-wider mb-2">Virtual (ASNET)</div>
                <div class="text-3xl font-black text-purple-400">{{ serverStats.virtualAsnet }}</div>
              </div>

            </div>
          </div>

          <!-- Log Aktivitas (Baru) -->
          <div v-if="userRole == 1" class="bg-slate-900 border border-slate-800 rounded-xl shadow-lg relative overflow-hidden flex flex-col h-full">
            <div class="px-5 py-4 border-b border-slate-800 flex justify-between items-center bg-slate-800/30">
              <h3 class="text-xs font-bold text-cyan-400 uppercase tracking-widest flex items-center gap-2">
                <span class="animate-pulse h-2 w-2 bg-cyan-500 rounded-full shadow-[0_0_8px_rgba(6,182,212,0.8)]"></span> Aktivitas Terkini
              </h3>
              <button @click="navigateTo('/log-akses')" class="text-[10px] bg-slate-800 hover:bg-slate-700 text-slate-300 px-3 py-1.5 rounded transition uppercase tracking-wider border border-slate-700">
                Selengkapnya &rarr;
              </button>
            </div>
            
            <div class="p-0 overflow-y-auto" style="height: 250px;">
              <div v-if="!latestLogs || latestLogs.length === 0" class="flex items-center justify-center h-full text-xs text-slate-500 font-mono">
                Tidak ada aktivitas terekam.
              </div>
              <ul v-else class="divide-y divide-slate-800/50">
                <li v-for="log in latestLogs" :key="log.id" class="px-5 py-3 hover:bg-slate-800/30 transition flex items-start gap-3">
                  <div class="mt-0.5">
                    <span v-if="log.aktivitas.toLowerCase().includes('gagal')" class="text-red-400 text-lg">❌</span>
                    <span v-else-if="log.aktivitas.toLowerCase().includes('berhasil login')" class="text-green-400 text-lg">✅</span>
                    <span v-else class="text-blue-400 text-lg">⚡</span>
                  </div>
                  <div class="flex-1">
                    <p class="text-[11px] text-slate-300 leading-snug">
                      <strong class="text-slate-100">{{ log.nama_lengkap }}</strong> {{ log.aktivitas }}
                    </p>
                    <p class="text-[9px] text-slate-500 mt-1 font-mono tracking-wider">{{ formatTimestamp(log.waktu) }}</p>
                  </div>
                </li>
              </ul>
            </div>
          </div>

        </div>

      </div>
    </div>

    <!-- ========================================== -->
    <!-- MODAL POP-UP: TENTANG APLIKASI             -->
    <!-- ========================================== -->
    <div v-if="showAboutModal" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/80 backdrop-blur-sm transition-opacity">
      <div class="bg-slate-900 border border-slate-700 rounded-2xl shadow-2xl w-full max-w-xl overflow-hidden transform transition-all">
        
        <div class="px-6 py-4 border-b border-slate-800 flex justify-between items-center bg-slate-800/50">
          <h3 class="text-lg font-bold text-teal-400 flex items-center gap-2">
            <span class="text-2xl">ℹ️</span> TENTANG APLIKASI
          </h3>
          <button @click="showAboutModal = false" class="text-slate-400 hover:text-red-400 transition">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" /></svg>
          </button>
        </div>

        <div class="p-6 text-sm text-slate-300 space-y-4">
          <p class="leading-relaxed text-justify">
            Aplikasi <strong class="text-slate-100">Data Center Facility Management Information System (DCFMIS)</strong> versi Web ini dibangun untuk memudahkan Tim Pusat Data dalam melakukan pengecekan rutin harian fasilitas Pusat Data: Suhu Ruangan Server, PC operator, CCTV Pusat Data, Kondisi AC Ruangan, Panel Listrik Utama, Indikator UPS dan Baterai, Indikator Panel Distribusi Listrik, Kondisi Rack Server, serta Catatan Kejadian Harian.
          </p>
          <p class="leading-relaxed text-justify">
            Aplikasi ini juga terintegrasi dan dilengkapi dengan fasilitas <strong class="text-slate-100">Manajemen Data Server</strong> dan <strong class="text-slate-100">Manajemen Data Alokasi IP</strong>.
          </p>
          
          <div class="mt-6 pt-6 border-t border-slate-800">
            <p class="text-[10px] font-bold text-slate-500 uppercase tracking-widest mb-3">Dikembangkan Oleh:</p>
            <div class="flex items-center gap-4 bg-slate-950 p-4 rounded-xl border border-slate-800">
              <div class="h-14 w-14 rounded-full bg-gradient-to-br from-teal-600 to-blue-600 flex items-center justify-center text-white text-xl font-black shadow-lg shadow-teal-900/50">
                SH
              </div>
              <div>
                <h4 class="text-base font-bold text-slate-100">Saeful Hamdi, A.Md</h4>
                <p class="text-teal-400 text-xs mt-1 flex items-center gap-1.5 font-mono">
                  <span>✉️</span> saefulhamdi@kotabogor.go.id
                </p>
                <div class="mt-2 space-y-0.5">
                  <p class="text-slate-400 text-xs font-semibold">Pranata Komputer Mahir</p>
                  <p class="text-slate-500 text-xs">Dinas Komunikasi dan Informatika Kota Bogor</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="px-6 py-4 border-t border-slate-800 bg-slate-800/30 flex justify-end">
          <button @click="showAboutModal = false" class="bg-slate-700 hover:bg-slate-600 border border-slate-600 text-white px-6 py-2 rounded-lg text-sm font-bold uppercase tracking-wider transition shadow">
            Tutup
          </button>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'

definePageMeta({ middleware: 'auth' })

const roleCookie = useCookie('user_role')
const tokenCookie = useCookie('auth_token')
const userRole = ref(roleCookie.value)

const config = useRuntimeConfig()
const API_URL = config.public.apiBase

const headersConfig = {
  'Content-Type': 'application/json',
  'X-App-Token': '[o0Ht1407!=5437ul=@K8R{*?zQL36;}0o]'
}

const pending = ref(false)
const showAboutModal = ref(false)

// STATE DATA AWAL
const piketLogs = ref([])
const serversData = ref([])
const ipBlocksData = ref([])
const ipUsagesData = ref([])
const logsData = ref([]) // State baru untuk log akses

// ------------------------------------------------------------------
// FUNGSI TARIK SEMUA DATA UNTUK DASHBOARD
// ------------------------------------------------------------------
const fetchAllData = async () => {
  pending.value = true
  try {
    const [piketRes, serverRes, ipBlockRes, ipUsageRes, logsRes] = await Promise.all([
      $fetch(`${API_URL}/api/piket/summary`, { headers: headersConfig }).catch(() => []),
      $fetch(`${API_URL}/api/server/manage`, { headers: headersConfig }).catch(() => []),
      $fetch(`${API_URL}/api/ip/blocks`, { headers: headersConfig }).catch(() => []),
      $fetch(`${API_URL}/api/ip/usages`, { headers: headersConfig }).catch(() => []),
      $fetch(`${API_URL}/api/logs`, { headers: headersConfig }).catch(() => []) // Fetch Logs
    ])

    piketLogs.value = typeof piketRes === 'string' ? JSON.parse(piketRes) : piketRes || []
    serversData.value = typeof serverRes === 'string' ? JSON.parse(serverRes) : serverRes || []
    ipBlocksData.value = typeof ipBlockRes === 'string' ? JSON.parse(ipBlockRes) : ipBlockRes || []
    ipUsagesData.value = typeof ipUsageRes === 'string' ? JSON.parse(ipUsageRes) : ipUsageRes || []
    logsData.value = typeof logsRes === 'string' ? JSON.parse(logsRes) : logsRes || []
  } catch (error) {
    console.error("Gagal sinkronisasi dashboard:", error)
  } finally {
    pending.value = false
  }
}

// ------------------------------------------------------------------
// AMBIL 10 LOG TERAKHIR UNTUK WIDGET
// ------------------------------------------------------------------
const latestLogs = computed(() => {
  if (!logsData.value || !Array.isArray(logsData.value)) return []
  return logsData.value.slice(0, 10)
})

// ------------------------------------------------------------------
// KALKULASI WIDGET PIKET LINGKUNGAN
// ------------------------------------------------------------------
const latestPiket = computed(() => {
  if (piketLogs.value.length === 0) return { suhu: null, waktu: null }
  const latest = piketLogs.value[0] 
  return {
    suhu: latest.suhu_ruangan_server,
    waktu: `${latest.tanggal_pemeriksaan} (${latest.jam_pemeriksaan.substring(0,5)})`
  }
})

// ------------------------------------------------------------------
// KALKULASI WIDGET SERVER
// ------------------------------------------------------------------
const serverStats = computed(() => {
  return {
    fisikBalaikota: serversData.value.filter(s => s.kategori_server === 'Fisik' && s.pusat_data === 'Pusat Data Balaikota').length,
    virtualBalaikota: serversData.value.filter(s => s.kategori_server === 'Virtual' && s.pusat_data === 'Pusat Data Balaikota').length,
    fisikAsnet: serversData.value.filter(s => s.kategori_server === 'Fisik' && s.pusat_data === 'Pusat Data ASNET').length,
    virtualAsnet: serversData.value.filter(s => s.kategori_server === 'Virtual' && s.pusat_data === 'Pusat Data ASNET').length
  }
})

// ------------------------------------------------------------------
// KALKULASI WIDGET IP
// ------------------------------------------------------------------
const getCidrCapacity = (cidr) => {
  if (!cidr || !cidr.includes('/')) return 0
  const mask = parseInt(cidr.split('/')[1], 10)
  if (mask >= 31) return Math.pow(2, 32 - mask)
  return Math.pow(2, 32 - mask) - 2
}

const ipStats = computed(() => {
  const totalBlocks = ipBlocksData.value.length
  const totalCapacity = ipBlocksData.value.reduce((sum, block) => sum + getCidrCapacity(block.cidr_block), 0)
  
  const uniqueUsedIps = new Set(ipUsagesData.value.map(u => u.ip_address))
  const totalUsed = uniqueUsedIps.size

  const percentage = totalCapacity > 0 ? Math.min(100, Math.round((totalUsed / totalCapacity) * 100)) : 0

  return { totalBlocks, totalCapacity, totalUsed, percentage }
})

// ------------------------------------------------------------------
// SISTEM JAM & LOGOUT
// ------------------------------------------------------------------
const handleLogout = () => {
  tokenCookie.value = null
  roleCookie.value = null
  window.location.href = '/login'
}

const currentTime = ref('')
let timer

const updateTime = () => {
  const now = new Date()
  currentTime.value = now.toLocaleString('id-ID', { 
    weekday: 'short', day: '2-digit', month: 'short', year: 'numeric', 
    hour: '2-digit', minute: '2-digit', second: '2-digit' 
  }).replace(/\./g, ':')
}

// FUNGSI FORMAT TANGGAL WAKTU UNTUK LOG
const formatTimestamp = (waktuString) => {
  if (!waktuString) return '-'
  const date = new Date(waktuString)
  if (isNaN(date.getTime())) return waktuString
  
  const jam = date.getHours().toString().padStart(2, '0')
  const menit = date.getMinutes().toString().padStart(2, '0')
  const detik = date.getSeconds().toString().padStart(2, '0')
  const hari = date.toLocaleDateString('id-ID', { day: '2-digit', month: 'short', year: 'numeric' })
  
  return `${hari} - ${jam}:${menit}:${detik} WIB`
}

onMounted(() => {
  updateTime()
  timer = setInterval(updateTime, 1000)
  fetchAllData()
  
  setInterval(() => { fetchAllData() }, 30000)
})

onUnmounted(() => {
  clearInterval(timer)
})
</script>
<!-- === NUXT DASHBOARD ADMIN - DCFMIS - Saeful Hamdi (shamdi.rh@gmail.com) === -->