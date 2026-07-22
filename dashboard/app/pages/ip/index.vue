<template>
  <div class="p-6 text-slate-100 min-h-screen bg-slate-950 font-sans relative">
    
    <!-- HEADER -->
    <div class="flex justify-between items-center border-b border-slate-800 pb-4 mb-6">
      <div>
        <h1 class="text-2xl font-bold text-blue-500 uppercase tracking-widest">Manajemen Alokasi Jaringan</h1>
        <p class="text-xs text-slate-400 mt-1">Alokasi & Pemetaan Subnet Jaringan</p>
      </div>
      <button @click="navigateTo('/')" class="bg-slate-800 hover:bg-slate-700 px-4 py-2 rounded text-sm transition">← Kembali</button>
    </div>

    <div class="grid grid-cols-1 xl:grid-cols-4 gap-6">
      
      <!-- ========================================== -->
      <!-- KOLOM KIRI: DAFTAR BLOK IP                 -->
      <!-- ========================================== -->
      <div class="xl:col-span-1 bg-slate-900 border border-slate-800 rounded-xl p-4 h-fit max-h-[850px] overflow-y-auto custom-scrollbar">
        <div class="sticky top-0 bg-slate-900 z-10 flex justify-between items-center mb-4 border-b border-slate-800 pb-2">
          <h2 class="text-sm font-bold text-slate-300 uppercase tracking-wider">Subnet Jaringan</h2>
          <button @click="openBlockForm(null)" class="bg-blue-600 hover:bg-blue-500 px-3 py-1.5 rounded text-xs transition font-bold shadow-lg">
            + Blok Baru
          </button>
        </div>
        
        <div class="space-y-3">
          <div v-if="blocks.length === 0" class="text-center text-slate-500 text-sm py-4">Belum ada blok IP.</div>
          
          <div v-for="b in blocks" :key="b.id" @click="selectBlock(b)" 
               :class="{'border-blue-500 bg-slate-800': activeBlock?.id === b.id}"
               class="p-3 border border-slate-700 bg-slate-950 rounded hover:border-blue-500 cursor-pointer transition relative group shadow">
            
            <div class="absolute top-2 right-2 hidden group-hover:flex gap-1">
              <button @click.stop="openBlockForm(b)" class="bg-amber-600 text-white p-1 rounded text-[10px]">✏️</button>
              <button @click.stop="deleteBlock(b.id)" class="bg-red-600 text-white p-1 rounded text-[10px]">🗑️</button>
            </div>

            <div class="font-bold text-sm text-slate-200 pr-10">{{ b.nama_blok }}</div>
            <div class="text-xs text-amber-400 font-mono mt-1">{{ b.cidr_block }}</div>
            <div class="text-[10px] text-slate-500 mt-2 line-clamp-2">{{ b.keterangan }}</div>
          </div>
        </div>
      </div>

      <!-- ========================================== -->
      <!-- KOLOM KANAN (A): DETAIL BLOK JIKA DIKLIK   -->
      <!-- ========================================== -->
      <div class="xl:col-span-3" v-if="activeBlock">
        <div class="flex justify-between items-center mb-4">
          <h2 class="text-lg font-bold text-emerald-400 uppercase tracking-widest">Detail Blok: {{ activeBlock.nama_blok }}</h2>
          <button @click="activeBlock = null" class="text-xs bg-slate-800 hover:bg-slate-700 px-3 py-1.5 rounded border border-slate-700 transition">Tutup Detail (Lihat Dashboard)</button>
        </div>
        
        <div class="grid grid-cols-3 gap-4 mb-6">
          <div class="bg-slate-900 border border-slate-800 p-4 rounded-xl flex items-center justify-between">
            <div><div class="text-xs text-slate-400 uppercase tracking-wider">Total Kapasitas IP</div>
            <div class="text-2xl font-bold text-blue-400">{{ rekap.total }} <span class="text-sm font-normal">Alamat</span></div></div>
            <div class="text-4xl opacity-20">🌐</div>
          </div>
          <div class="bg-slate-900 border border-slate-800 p-4 rounded-xl flex items-center justify-between">
            <div><div class="text-xs text-slate-400 uppercase tracking-wider">Terpakai (Aktif)</div>
            <div class="text-2xl font-bold text-red-400">{{ rekap.used }} <span class="text-sm font-normal">Host</span></div></div>
            <div class="text-4xl opacity-20">🔌</div>
          </div>
          <div class="bg-slate-900 border border-slate-800 p-4 rounded-xl flex items-center justify-between">
            <div><div class="text-xs text-slate-400 uppercase tracking-wider">Tersedia (Bebas)</div>
            <div class="text-2xl font-bold text-green-400">{{ rekap.free }} <span class="text-sm font-normal">Alamat</span></div></div>
            <div class="text-4xl opacity-20">✅</div>
          </div>
        </div>

        <div class="bg-slate-900 border border-slate-800 rounded-xl p-6">
          <h3 class="text-sm font-bold text-blue-400 mb-4 border-b border-slate-800 pb-2 flex justify-between">
            <span>Peta Alokasi IP: {{ activeBlock.cidr_block }}</span>
            <span class="text-[10px] text-slate-400 font-normal">Klik kotak IP untuk mengelola</span>
          </h3>

          <div class="flex flex-wrap gap-1.5">
            <div v-for="ipObj in gridIPs" :key="ipObj.ip"
                 @click="!ipObj.isSystem ? openUsageForm(ipObj) : null"
                 class="w-10 h-10 border rounded flex flex-col items-center justify-center text-[10px] font-mono transition"
                 :class="{
                   'bg-slate-800 border-slate-700 text-slate-600 cursor-not-allowed': ipObj.isSystem,
                   'bg-red-900/40 border-red-700 text-red-400 hover:bg-red-600 hover:text-white cursor-pointer shadow-[0_0_8px_rgba(239,68,68,0.2)]': ipObj.used && !ipObj.isSystem,
                   'bg-green-900/20 border-green-800 text-green-500 hover:bg-green-600 hover:text-white cursor-pointer': !ipObj.used && !ipObj.isSystem
                 }"
                 :title="ipObj.ip">
              <span class="font-bold text-xs">{{ ipObj.lastOctet }}</span>
            </div>
          </div>
          
          <div class="mt-6 flex gap-4 text-[10px] text-slate-400 uppercase font-bold tracking-wider border-t border-slate-800 pt-4">
            <div class="flex items-center gap-1"><div class="w-3 h-3 bg-green-900/40 border border-green-800 rounded"></div> Tersedia</div>
            <div class="flex items-center gap-1"><div class="w-3 h-3 bg-red-900/60 border border-red-700 rounded"></div> Terpakai / Reserved</div>
            <div class="flex items-center gap-1"><div class="w-3 h-3 bg-slate-800 border border-slate-700 rounded"></div> Network / Broadcast (Sistem)</div>
          </div>
        </div>

        <div class="bg-slate-900 border border-slate-800 rounded-xl p-6 mt-6">
          <h3 class="text-sm font-bold text-slate-300 mb-4 border-b border-slate-800 pb-2">Daftar Rinci Pemakaian</h3>
          <table class="w-full text-left text-xs">
            <thead class="bg-slate-950 text-slate-400 uppercase tracking-wider">
              <tr>
                <th class="p-3 border-b border-slate-700">IP Address</th>
                <th class="p-3 border-b border-slate-700">Kegunaan / Server</th>
                <th class="p-3 border-b border-slate-700">Port Info</th>
                <th class="p-3 border-b border-slate-700">Status</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-800">
              <tr v-if="blockUsages.length === 0"><td colspan="4" class="p-4 text-center text-slate-500">Belum ada IP yang dialokasikan.</td></tr>
              <tr v-for="u in blockUsages" :key="u.id" class="hover:bg-slate-800 transition">
                <td class="p-3 font-mono font-bold text-blue-400">{{ u.ip_address }}</td>
                <td class="p-3 text-slate-300">{{ u.nama_server || u.kegunaan }}</td>
                <td class="p-3 text-slate-400 font-mono">{{ u.port_info || 'Semua' }}</td>
                <td class="p-3"><span class="px-2 py-1 bg-slate-950 border border-slate-700 rounded text-[10px] uppercase font-bold text-amber-500">{{ u.status }}</span></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      
      <!-- ========================================== -->
      <!-- KOLOM KANAN (B): DASHBOARD AWAL -->
      <!-- ========================================== -->
      <div v-else class="xl:col-span-3">
        <h2 class="text-xl font-bold text-amber-300 uppercase tracking-widest mb-6 border-b border-slate-800 pb-3">Dashboard Rekapitulasi Jaringan</h2>
        
        <div class="space-y-8 max-h-[750px] overflow-y-auto custom-scrollbar pr-4">
          
          <!-- SEGMEN IP PUBLIK -->
          <div>
            <h3 class="text-sm font-bold bg-[#031D44] text-blue-300 uppercase tracking-widest px-4 py-2 border border-[#1B4C50] rounded inline-block mb-4">
              Jaringan IP Publik (WAN)
            </h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div v-for="stat in [...publikBalaikota, ...publikAsnet]" :key="stat.id" class="bg-[#103B3E] border border-[#1B4C50] p-4 rounded-xl shadow-lg relative overflow-hidden">
                <div class="absolute top-0 left-0 w-1 h-full bg-blue-500"></div>
                <h4 class="text-xs font-bold text-slate-200 uppercase mb-3 border-b border-[#1B4C50] pb-2 pl-2 line-clamp-1">{{ stat.nama_blok }}</h4>
                <div class="grid grid-cols-3 gap-2 text-center">
                  <div>
                    <div class="text-[9px] text-slate-400 uppercase tracking-widest">Kapasitas</div>
                    <div class="text-lg font-black text-blue-400 font-mono">{{ stat.total }}</div>
                  </div>
                  <div>
                    <div class="text-[9px] text-slate-400 uppercase tracking-widest">Terpakai</div>
                    <div class="text-lg font-black text-red-400 font-mono">{{ stat.used }}</div>
                  </div>
                  <div>
                    <div class="text-[9px] text-slate-400 uppercase tracking-widest">Tersedia</div>
                    <div class="text-lg font-black text-green-400 font-mono">{{ stat.free }}</div>
                  </div>
                </div>
              </div>
            </div>
            <div v-if="publikBalaikota.length === 0 && publikAsnet.length === 0" class="text-xs text-slate-500 italic">Belum ada alokasi Blok IP Publik.</div>
          </div>

          <!-- SEGMEN IP LOKAL BALAIKOTA -->
          <div>
            <h3 class="text-sm font-bold bg-[#1B4C50]/20 text-emerald-400 uppercase tracking-widest px-4 py-2 border border-emerald-900 rounded inline-block mb-4">
              Jaringan IP Lokal (LAN) - Pusat Data Balaikota
            </h3>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div v-for="stat in lokalBalaikota" :key="stat.id" class="bg-[#103B3E] border border-emerald-900 p-4 rounded-xl shadow-lg relative overflow-hidden">
                <div class="absolute top-0 left-0 w-1 h-full bg-emerald-500"></div>
                <h4 class="text-xs font-bold text-slate-200 uppercase mb-3 border-b border-emerald-900/50 pb-2 pl-2 line-clamp-1">{{ stat.nama_blok }}</h4>
                <div class="grid grid-cols-3 gap-2 text-center">
                  <div>
                    <div class="text-[9px] text-slate-400 uppercase tracking-widest">Kapasitas</div>
                    <div class="text-lg font-black text-blue-400 font-mono">{{ stat.total }}</div>
                  </div>
                  <div>
                    <div class="text-[9px] text-slate-400 uppercase tracking-widest">Terpakai</div>
                    <div class="text-lg font-black text-red-400 font-mono">{{ stat.used }}</div>
                  </div>
                  <div>
                    <div class="text-[9px] text-slate-400 uppercase tracking-widest">Tersedia</div>
                    <div class="text-lg font-black text-green-400 font-mono">{{ stat.free }}</div>
                  </div>
                </div>
              </div>
            </div>
            <div v-if="lokalBalaikota.length === 0" class="text-xs text-slate-500 italic">Belum ada alokasi Blok IP Lokal untuk Balaikota.</div>
          </div>

          <!-- SEGMEN IP LOKAL ASNET -->
          <div>
            <h3 class="text-sm font-bold bg-[#1B4C50]/20 text-amber-400 uppercase tracking-widest px-4 py-2 border border-amber-900 rounded inline-block mb-4">
              Jaringan IP Lokal (LAN) - Pusat Data ASNET
            </h3>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div v-for="stat in lokalAsnet" :key="stat.id" class="bg-[#103B3E] border border-amber-900 p-4 rounded-xl shadow-lg relative overflow-hidden">
                <div class="absolute top-0 left-0 w-1 h-full bg-amber-500"></div>
                <h4 class="text-xs font-bold text-slate-200 uppercase mb-3 border-b border-amber-900/50 pb-2 pl-2 line-clamp-1">{{ stat.nama_blok }}</h4>
                <div class="grid grid-cols-3 gap-2 text-center">
                  <div>
                    <div class="text-[9px] text-slate-400 uppercase tracking-widest">Kapasitas</div>
                    <div class="text-lg font-black text-blue-400 font-mono">{{ stat.total }}</div>
                  </div>
                  <div>
                    <div class="text-[9px] text-slate-400 uppercase tracking-widest">Terpakai</div>
                    <div class="text-lg font-black text-red-400 font-mono">{{ stat.used }}</div>
                  </div>
                  <div>
                    <div class="text-[9px] text-slate-400 uppercase tracking-widest">Tersedia</div>
                    <div class="text-lg font-black text-green-400 font-mono">{{ stat.free }}</div>
                  </div>
                </div>
              </div>
            </div>
            <div v-if="lokalAsnet.length === 0" class="text-xs text-slate-500 italic">Belum ada alokasi Blok IP Lokal untuk ASNET.</div>
          </div>

        </div>
      </div>

    </div>

    <!-- MODAL FORM: TAMBAH/EDIT BLOK IP -->
    <div v-if="showBlockModal" class="fixed inset-0 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center z-50 p-4">
      <div class="bg-slate-900 border border-slate-700 p-6 rounded-xl w-full max-w-md shadow-2xl">
        <h3 class="text-lg font-bold text-blue-400 mb-4">{{ blockForm.id ? 'Edit Blok IP' : 'Tambah Blok IP Baru' }}</h3>
        <form @submit.prevent="saveBlock" class="space-y-4">
          <div><label class="text-xs text-slate-400 block mb-1">Nama Blok / Identitas</label><input v-model="blockForm.nama_blok" type="text" required class="input-style" placeholder="Cth: Blok IP Server Pusat Data Balaikota"></div>
          <div>
            <label class="text-xs text-slate-400 block mb-1">Jenis IP</label>
            <select v-model="blockForm.jenis_ip" required class="input-style">
              <option value="Publik">IP Publik</option>
              <option value="Lokal">IP Lokal</option>
            </select>
          </div>
          <div><label class="text-xs text-slate-400 block mb-1">CIDR Subnet</label><input v-model="blockForm.cidr_block" type="text" required class="input-style font-mono" placeholder="Contoh: 103.14.229.0/24"></div>
          <div><label class="text-xs text-slate-400 block mb-1">Keterangan</label><textarea v-model="blockForm.keterangan" class="input-style h-20"></textarea></div>
          
          <div class="flex justify-end gap-3 pt-4 border-t border-slate-800">
            <button type="button" @click="showBlockModal = false" class="px-4 py-2 bg-slate-800 hover:bg-slate-700 rounded text-sm transition">Batal</button>
            <button type="submit" class="px-6 py-2 bg-blue-600 hover:bg-blue-500 text-white rounded text-sm font-bold transition">Simpan Blok</button>
          </div>
        </form>
      </div>
    </div>

    <!-- MODAL FORM: ALOKASI / EDIT PEMAKAIAN IP (MULTI-SERVER) -->
    <div v-if="showUsageModal" class="fixed inset-0 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center z-50 p-4">
      <div class="bg-slate-900 border border-slate-700 p-6 rounded-xl w-full max-w-md shadow-2xl max-h-[90vh] overflow-y-auto">
        <h3 class="text-lg font-bold mb-4 text-blue-400 border-b border-slate-800 pb-2">
          Detail Penggunaan IP: <span class="text-amber-400 font-mono">{{ selectedIp }}</span>
        </h3>
        
        <div class="mb-6">
          <h4 class="text-xs font-bold uppercase tracking-wider text-slate-400 mb-2">Perangkat Terhubung Saat Ini:</h4>
          <div v-if="selectedIpUsages.length > 0" class="space-y-2">
            <div v-for="u in selectedIpUsages" :key="u.id" class="p-2 bg-[#031D44] border border-[#1B4C50] rounded text-xs flex justify-between items-center">
              <div>
                <div class="font-bold text-slate-200">{{ u.nama_server || u.kegunaan }}</div>
                <div class="text-slate-400 font-mono mt-1">Port: <span class="text-amber-300">{{ u.port_info || 'Semua Port' }}</span> | <span class="text-green-400">{{ u.status }}</span></div>
              </div>
              <button @click="deleteUsage(u.id)" class="bg-red-900/50 hover:bg-red-600 text-red-400 hover:text-white p-1.5 rounded transition" title="Hapus Alokasi">🗑️</button>
            </div>
          </div>
          <div v-else class="p-3 bg-slate-800/50 rounded text-center text-xs text-slate-400 italic">IP ini masih kosong.</div>
        </div>

        <h4 class="text-xs font-bold uppercase tracking-wider text-slate-400 border-b border-slate-700 pb-1 mb-3">Tambah Alokasi Baru</h4>
        <form @submit.prevent="saveUsage" class="space-y-4">
          <div><label class="text-xs text-slate-400 block mb-1">Kegunaan / Nama Server</label><input v-model="usageForm.kegunaan" type="text" required class="input-style" placeholder="Contoh: Web Server Portal"></div>
          <div><label class="text-xs text-slate-400 block mb-1">Port yang Dibuka</label><input v-model="usageForm.port_info" type="text" class="input-style font-mono" placeholder="Contoh: 80, 443"></div>
          <div><label class="text-xs text-slate-400 block mb-1">Status</label>
            <select v-model="usageForm.status" class="input-style"><option>Aktif</option><option>Reserved</option></select>
          </div>
          <div class="flex justify-end gap-3 pt-4 border-t border-slate-800">
            <button type="button" @click="showUsageModal = false" class="px-4 py-2 bg-slate-800 hover:bg-slate-700 rounded text-sm transition">Tutup Panel</button>
            <button type="submit" class="px-6 py-2 bg-green-600 hover:bg-green-500 text-white rounded text-sm font-bold transition">+ Tambahkan</button>
          </div>
        </form>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

const config = useRuntimeConfig()
const API_URL = config.public.apiBase

const headersConfig = {
  'Content-Type': 'application/json',
  'X-App-Token': '[o0Ht1407!=5437ul=@K8R{*?zQL36;}0o]123'
}

// AMBIL DATA USER AKTIF DARI COOKIE UNTUK LOG
const userNama = useCookie('user_nama')
const userEmail = useCookie('user_email')

const blocks = ref([])
const allGlobalUsages = ref([]) 
const activeBlock = ref(null)
const blockUsages = ref([]) 

const showBlockModal = ref(false)
const blockForm = ref({})
const showUsageModal = ref(false)
const selectedIp = ref('')
const selectedIpUsages = ref([])
const usageForm = ref({})

// ------------------------------------------------------------------
// 1. FUNGSI FETCHING DATA GLOBAL
// ------------------------------------------------------------------
const fetchAllData = async () => {
  try {
    const [resBlocks, resUsages] = await Promise.all([
      $fetch(`${API_URL}/api/ip/blocks`, { headers: headersConfig }),
      $fetch(`${API_URL}/api/ip/usages`, { headers: headersConfig })
    ])
    blocks.value = typeof resBlocks === 'string' ? JSON.parse(resBlocks) : resBlocks || []
    allGlobalUsages.value = typeof resUsages === 'string' ? JSON.parse(resUsages) : resUsages || []
  } catch (error) {
    console.error("Gagal menarik data", error)
  }
}

const selectBlock = (b) => {
  activeBlock.value = b
  blockUsages.value = allGlobalUsages.value.filter(u => u.ip_block_id === b.id || u.nama_blok === b.nama_blok)
}

// ------------------------------------------------------------------
// 2. LOGIKA CIDR KALKULATOR (UNTUK GRID DAN DASHBOARD)
// ------------------------------------------------------------------
const getCidrCapacity = (cidr) => {
  if (!cidr || !cidr.includes('/')) return 0
  const mask = parseInt(cidr.split('/')[1], 10)
  if (mask === 32) return 1
  if (mask === 31) return 2
  return Math.pow(2, 32 - mask) - 2 
}

const gridIPs = computed(() => {
  if (!activeBlock.value) return []
  const cidr = activeBlock.value.cidr_block
  if (!cidr.includes('/')) return []

  const [baseIp, maskStr] = cidr.split('/')
  const mask = parseInt(maskStr, 10)
  const ipToInt = ip => ip.split('.').reduce((int, oct) => (int << 8) + parseInt(oct, 10), 0) >>> 0
  const intToIp = int => [(int >>> 24) & 255, (int >>> 16) & 255, (int >>> 8) & 255, int & 255].join('.')
  
  const maskInt = ~((1 << (32 - mask)) - 1) >>> 0
  const networkInt = ipToInt(baseIp) & maskInt
  const broadcastInt = networkInt | (~maskInt >>> 0)
  
  let ips = []
  for (let i = networkInt; i <= broadcastInt; i++) {
    const ipStr = intToIp(i)
    const usagesForIp = blockUsages.value.filter(u => u.ip_address === ipStr)
    ips.push({
      ip: ipStr, lastOctet: ipStr.split('.').pop(),
      isSystem: i === networkInt || i === broadcastInt,
      used: usagesForIp.length > 0, details: usagesForIp
    })
  }
  return ips
})

const rekap = computed(() => {
  const total = gridIPs.value.filter(i => !i.isSystem).length 
  const used = gridIPs.value.filter(i => i.used && !i.isSystem).length 
  return { total, used, free: total - used }
})

// ------------------------------------------------------------------
// 3. LOGIKA UNTUK DASHBOARD WIDGET
// ------------------------------------------------------------------
const dashboardStats = computed(() => {
  return blocks.value.map(b => {
    const total = getCidrCapacity(b.cidr_block)
    const usages = allGlobalUsages.value.filter(u => u.ip_block_id === b.id)
    const used = new Set(usages.map(u => u.ip_address)).size
    return { ...b, total, used, free: total - used }
  })
})

const filterStats = (jenis, keyword) => dashboardStats.value.filter(b => 
  (b.jenis_ip || '').toLowerCase() === jenis.toLowerCase() && 
  (b.nama_blok || '').toLowerCase().includes(keyword.toLowerCase())
)

const publikBalaikota = computed(() => filterStats('Publik', 'Balaikota'))
const publikAsnet = computed(() => filterStats('Publik', 'Asnet'))
const lokalBalaikota = computed(() => filterStats('Lokal', 'Balaikota'))
const lokalAsnet = computed(() => filterStats('Lokal', 'Asnet'))

// ------------------------------------------------------------------
// 4. CRUD BLOK & USAGES DENGAN PAYLOAD LOG
// ------------------------------------------------------------------
const openBlockForm = (b) => {
  blockForm.value = b ? { ...b } : { id: null, nama_blok: '', jenis_ip: 'Publik', cidr_block: '', keterangan: '' }
  showBlockModal.value = true
}

const saveBlock = async () => {
  // Tambahkan admin_nama dan admin_email ke payload
  blockForm.value.admin_nama = userNama.value;
  blockForm.value.admin_email = userEmail.value;

  await $fetch(`${API_URL}/api/ip/blocks`, { method: 'POST', body: blockForm.value, headers: headersConfig })
  showBlockModal.value = false
  await fetchAllData()
  if (activeBlock.value && activeBlock.value.id === blockForm.value.id) activeBlock.value = null
}

const deleteBlock = async (id) => {
  if (confirm("🚨 Hapus blok ini beserta seluruh data alokasi IP di dalamnya?")) {
    await $fetch(`${API_URL}/api/ip/blocks?id=${id}&admin_nama=${userNama.value}&admin_email=${userEmail.value}`, { method: 'DELETE', headers: headersConfig })
    if (activeBlock.value && activeBlock.value.id === id) activeBlock.value = null
    fetchAllData()
  }
}

const openUsageForm = (ipObj) => {
  selectedIp.value = ipObj.ip
  selectedIpUsages.value = ipObj.details || [] 
  usageForm.value = { id: null, ip_block_id: activeBlock.value.id, ip_address: ipObj.ip, kegunaan: '', port_info: '', status: 'Aktif' }
  showUsageModal.value = true
}

const refreshModalData = () => {
  const ipObj = gridIPs.value.find(i => i.ip === selectedIp.value)
  if(ipObj) selectedIpUsages.value = ipObj.details || []
}

const saveUsage = async () => {
  // Tambahkan admin_nama dan admin_email ke payload
  usageForm.value.admin_nama = userNama.value;
  usageForm.value.admin_email = userEmail.value;

  await $fetch(`${API_URL}/api/ip/usages`, { method: 'POST', body: usageForm.value, headers: headersConfig })
  await fetchAllData() 
  selectBlock(activeBlock.value) 
  refreshModalData() 
  usageForm.value.kegunaan = ''; usageForm.value.port_info = '';
}

const deleteUsage = async (id) => {
  if (confirm("Hapus alokasi perangkat/server ini dari IP tersebut?")) {
    await $fetch(`${API_URL}/api/ip/usages?id=${id}&admin_nama=${userNama.value}&admin_email=${userEmail.value}`, { method: 'DELETE', headers: headersConfig })
    await fetchAllData()
    selectBlock(activeBlock.value) 
    refreshModalData() 
  }
}

onMounted(() => fetchAllData())
</script>

<style scoped>
.input-style {
  @apply w-full bg-slate-900 border border-slate-700 rounded p-2 text-sm text-slate-200 transition-all duration-300 outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-500;
}
.custom-scrollbar::-webkit-scrollbar { width: 4px; }
.custom-scrollbar::-webkit-scrollbar-thumb { background-color: #1B4C50; border-radius: 10px; }
.custom-scrollbar::-webkit-scrollbar-track { background-color: transparent; }
</style>
<!-- === NUXT DASHBOARD ADMIN - DCFMIS - Saeful Hamdi (shamdi.rh@gmail.com) === -->