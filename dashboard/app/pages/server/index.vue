<template>
  <div class="p-6 min-h-screen font-sans" style="background-color: #031D44; color: #CDEDF6;">
    <div class="flex justify-between items-center border-b pb-4 mb-6" style="border-color: #1B4C50;">
      <h1 class="text-2xl font-bold uppercase tracking-widest">Vault Server (Fisik & Virtual)</h1>
      <button @click="navigateTo('/')" class="px-4 py-2 rounded text-sm transition border hover:bg-[#1B4C50]" style="border-color: #1B4C50;">← Kembali</button>
    </div>

    <div class="grid grid-cols-1 xl:grid-cols-4 gap-6">
      
      <!-- ========================================== -->
      <!-- KIRI: FORM INPUT SERVER LENGKAP            -->
      <!-- ========================================== -->
      <div class="xl:col-span-1 rounded-xl p-5 border h-fit max-h-[850px] overflow-y-auto custom-scrollbar relative" style="background-color: #103B3E; border-color: #1B4C50;">
        <div class="sticky top-0 bg-[#103B3E] z-10 pb-2 mb-4 border-b flex justify-between items-center" style="border-color: #1B4C50;">
          <h2 class="text-sm font-bold uppercase tracking-wider text-amber-300">
            {{ form.id ? 'Edit Server ID: ' + form.id : 'Tambah Server Baru' }}
          </h2>
          <button v-if="form.id" @click="resetForm" class="text-[10px] bg-slate-700 px-2 py-1 rounded">Batal Edit</button>
        </div>
        
        <form @submit.prevent="saveServer" class="space-y-6">
          
          <!-- 1. IDENTITAS -->
          <div>
            <h3 class="text-xs font-bold uppercase text-blue-300 border-b border-blue-900/50 pb-1 mb-3">Identitas Server</h3>
            <div class="space-y-3">
              <select v-model="form.kategori_server" class="w-full rounded p-2 text-xs outline-none" style="background-color: #031D44; border: 1px solid #1B4C50;">
                <option>Virtual</option><option>Fisik</option>
              </select>
              <select v-model="form.pusat_data" required class="w-full rounded p-2 text-xs outline-none" style="background-color: #031D44; border: 1px solid #1B4C50;">
                <option value="" disabled>Pilih Lokasi Pusat Data...</option>
                <option>Pusat Data Balaikota</option><option>Pusat Data ASNET</option>
              </select>
              <input v-model="form.nama_server" type="text" required placeholder="Nama Server (Cth: SERVER VM SIMATA)" class="w-full rounded p-2 text-xs outline-none" style="background-color: #031D44; border: 1px solid #1B4C50;">
              <div class="flex gap-2">
                <input v-model="form.tanggal_pembuatan" type="date" required class="w-1/2 rounded p-2 text-xs outline-none" style="background-color: #031D44; border: 1px solid #1B4C50;">
                <input v-model="form.pembuat" type="text" disabled class="w-1/2 rounded p-2 text-xs outline-none opacity-60" style="background-color: #031D44; border: 1px dashed #1B4C50;">
              </div>
            </div>
          </div>

          <!-- 2. HARDWARE -->
          <div>
            <h3 class="text-xs font-bold uppercase text-blue-300 border-b border-blue-900/50 pb-1 mb-3">Spesifikasi Hardware</h3>
            <div class="grid grid-cols-3 gap-2">
              <input v-model="form.spek_cpu" type="text" placeholder="CPU" class="w-full rounded p-2 text-xs text-center font-mono" style="background-color: #031D44; border: 1px solid #1B4C50;">
              <input v-model="form.spek_ram" type="text" placeholder="RAM" class="w-full rounded p-2 text-xs text-center font-mono" style="background-color: #031D44; border: 1px solid #1B4C50;">
              <input v-model="form.spek_hdd" type="text" placeholder="HDD" class="w-full rounded p-2 text-xs text-center font-mono" style="background-color: #031D44; border: 1px solid #1B4C50;">
            </div>
          </div>

          <!-- 3. ALOKASI IP -->
          <div>
            <div class="flex justify-between items-center border-b border-blue-900/50 pb-1 mb-3">
              <h3 class="text-xs font-bold uppercase text-blue-300">Pemakaian IP</h3>
              <button type="button" @click="form.assigned_ips.push({ip_block_id:'', ip_address:'', port_info:'', kegunaan:''})" class="text-[10px] bg-[#1B4C50] px-2 py-1 rounded">+ IP</button>
            </div>
            <div v-for="(ip, idx) in form.assigned_ips" :key="idx" class="p-2 rounded border border-[#1B4C50]/50 mb-2" style="background-color: #031D44;">
              <div class="flex justify-between mb-2">
                <select v-model="ip.ip_block_id" class="w-full rounded p-1 text-[10px] outline-none bg-[#103B3E] border border-[#1B4C50]" required>
                  <option value="" disabled>Pilih Blok...</option>
                  <option v-for="b in ipBlocks" :key="b.id" :value="b.id">{{ b.nama_blok }} ({{b.jenis_ip}})</option>
                </select>
                <button type="button" @click="form.assigned_ips.splice(idx, 1)" class="ml-2 text-rose-400 font-bold hover:text-rose-300">×</button>
              </div>
              <input v-model="ip.kegunaan" type="text" placeholder="Kegunaan (Cth: IP Publik SSH)" required class="w-full rounded p-1 mb-2 text-[10px] bg-[#103B3E] border border-[#1B4C50]">
              <div class="flex gap-2">
                <input v-model="ip.ip_address" type="text" placeholder="IP Address" required class="w-1/2 rounded p-1 text-[10px] font-mono bg-[#103B3E] border border-[#1B4C50]">
                <input v-model="ip.port_info" type="text" placeholder="Port" class="w-1/2 rounded p-1 text-[10px] font-mono bg-[#103B3E] border border-[#1B4C50]">
              </div>
            </div>
          </div>

          <!-- 4. SOFTWARE -->
          <div>
            <div class="flex justify-between items-center border-b border-blue-900/50 pb-1 mb-3">
              <h3 class="text-xs font-bold uppercase text-blue-300">Spesifikasi Software</h3>
              <button type="button" @click="form.software_terpasang.push('')" class="text-[10px] bg-[#1B4C50] px-2 py-1 rounded">+ Soft</button>
            </div>
            <div v-for="(sw, idx) in form.software_terpasang" :key="idx" class="flex gap-2 mb-2">
              <input v-model="form.software_terpasang[idx]" type="text" placeholder="Cth: Ubuntu 24.04 LTS" class="flex-1 rounded p-1.5 text-xs outline-none bg-[#031D44] border border-[#1B4C50]">
              <button type="button" @click="form.software_terpasang.splice(idx, 1)" class="text-rose-400 font-bold hover:text-rose-300">×</button>
            </div>
          </div>

          <!-- 5. KREDENSIAL / PASSWORD -->
          <div>
            <h3 class="text-xs font-bold uppercase text-rose-300 border-b border-rose-900/50 pb-1 mb-3">User & Password Server</h3>
            
            <!-- Linux -->
            <div class="mb-3 p-2 bg-[#031D44] rounded border border-[#1B4C50]/50">
              <div class="flex justify-between items-center mb-2">
                <span class="text-[10px] font-bold uppercase">Akun Linux OS</span>
                <button type="button" @click="form.kredensial_akun.linux.push({user:'', pass:''})" class="text-[9px] bg-slate-700 px-1.5 py-0.5 rounded">+ Tambah</button>
              </div>
              <div v-for="(cred, idx) in form.kredensial_akun.linux" :key="idx" class="flex gap-2 mb-1">
                <input v-model="cred.user" type="text" placeholder="User" class="w-1/2 p-1 text-[10px] rounded bg-[#103B3E] border border-[#1B4C50]">
                <input v-model="cred.pass" type="text" placeholder="Pass" class="w-1/2 p-1 text-[10px] rounded bg-[#103B3E] border border-[#1B4C50]">
                <button type="button" @click="form.kredensial_akun.linux.splice(idx, 1)" class="text-rose-400 font-bold">×</button>
              </div>
            </div>

            <!-- Database -->
            <div class="mb-3 p-2 bg-[#031D44] rounded border border-[#1B4C50]/50">
              <div class="flex justify-between items-center mb-2">
                <span class="text-[10px] font-bold uppercase">Akun Database</span>
                <button type="button" @click="form.kredensial_akun.database.push({user:'', pass:''})" class="text-[9px] bg-slate-700 px-1.5 py-0.5 rounded">+ Tambah</button>
              </div>
              <div v-for="(cred, idx) in form.kredensial_akun.database" :key="idx" class="flex gap-2 mb-1">
                <input v-model="cred.user" type="text" placeholder="User" class="w-1/2 p-1 text-[10px] rounded bg-[#103B3E] border border-[#1B4C50]">
                <input v-model="cred.pass" type="text" placeholder="Pass" class="w-1/2 p-1 text-[10px] rounded bg-[#103B3E] border border-[#1B4C50]">
                <button type="button" @click="form.kredensial_akun.database.splice(idx, 1)" class="text-rose-400 font-bold">×</button>
              </div>
            </div>

            <!-- Aplikasi -->
            <div class="mb-3 p-2 bg-[#031D44] rounded border border-[#1B4C50]/50">
              <div class="flex justify-between items-center mb-2">
                <span class="text-[10px] font-bold uppercase">Akun Aplikasi</span>
                <button type="button" @click="form.kredensial_akun.aplikasi.push({user:'', pass:''})" class="text-[9px] bg-slate-700 px-1.5 py-0.5 rounded">+ Tambah</button>
              </div>
              <div v-for="(cred, idx) in form.kredensial_akun.aplikasi" :key="idx" class="flex gap-2 mb-1">
                <input v-model="cred.user" type="text" placeholder="User" class="w-1/2 p-1 text-[10px] rounded bg-[#103B3E] border border-[#1B4C50]">
                <input v-model="cred.pass" type="text" placeholder="Pass" class="w-1/2 p-1 text-[10px] rounded bg-[#103B3E] border border-[#1B4C50]">
                <button type="button" @click="form.kredensial_akun.aplikasi.splice(idx, 1)" class="text-rose-400 font-bold">×</button>
              </div>
            </div>
          </div>

          <button type="submit" :disabled="isSaving" class="w-full font-bold py-3 rounded text-[#031D44] uppercase tracking-widest transition hover:opacity-90 disabled:opacity-50" style="background-color: #CDEDF6;">
            {{ isSaving ? 'Menyimpan...' : 'Simpan Data Server' }}
          </button>
        </form>
      </div>

      <!-- ========================================== -->
      <!-- KANAN: DASHBOARD & TABEL                   -->
      <!-- ========================================== -->
      <div class="xl:col-span-3">
        
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
          <div class="rounded-xl border p-4 shadow-lg flex flex-col justify-center items-center text-center bg-[#103B3E] border-[#1B4C50]">
            <div class="text-[10px] uppercase tracking-widest text-emerald-300 font-bold mb-1">Fisik (Balaikota)</div>
            <div class="text-4xl font-black">{{ fisikBalaikota.length }}</div>
          </div>
          <div class="rounded-xl border p-4 shadow-lg flex flex-col justify-center items-center text-center bg-[#103B3E] border-[#1B4C50]">
            <div class="text-[10px] uppercase tracking-widest text-blue-300 font-bold mb-1">Virtual (Balaikota)</div>
            <div class="text-4xl font-black">{{ virtualBalaikota.length }}</div>
          </div>
          <div class="rounded-xl border p-4 shadow-lg flex flex-col justify-center items-center text-center bg-[#103B3E] border-[#1B4C50]">
            <div class="text-[10px] uppercase tracking-widest text-amber-300 font-bold mb-1">Fisik (ASNET)</div>
            <div class="text-4xl font-black">{{ fisikAsnet.length }}</div>
          </div>
          <div class="rounded-xl border p-4 shadow-lg flex flex-col justify-center items-center text-center bg-[#103B3E] border-[#1B4C50]">
            <div class="text-[10px] uppercase tracking-widest text-purple-300 font-bold mb-1">Virtual (ASNET)</div>
            <div class="text-4xl font-black">{{ virtualAsnet.length }}</div>
          </div>
        </div>

        <div class="space-y-6 max-h-[700px] overflow-y-auto pr-2 custom-scrollbar">
          
          <div v-for="t in tablesConfig" :key="t.key" class="rounded-xl border p-5 shadow-lg bg-[#031D44]" :style="`border-color: ${t.borderColor};`">
            <div class="flex justify-between items-center border-b pb-3 mb-4" :style="`border-color: ${t.borderColor};`">
              <h3 class="font-bold uppercase tracking-wider text-sm" :class="t.textColor">{{ t.title }}</h3>
              <span class="text-xs opacity-60">Total: {{ t.total }} Server</span>
            </div>

            <table class="w-full text-left text-sm whitespace-nowrap">
              <thead class="text-[10px] uppercase tracking-widest opacity-70 border-b" style="border-color: #1B4C50;">
                <tr>
                  <th class="pb-2">Identitas Server</th>
                  <th class="pb-2 text-center">Spesifikasi</th>
                  <th class="pb-2 text-center">IP Terpasang</th>
                  <th class="pb-2 text-center">Software</th>
                  <th class="pb-2 text-center">Aksi</th>
                </tr>
              </thead>
              <tbody class="divide-y" style="border-color: #1B4C50;">
                <tr v-for="server in t.paginatedData" :key="server.id" class="hover:bg-[#103B3E] transition">
                  <td class="py-3">
                    <div class="font-bold" :class="t.textColor">{{ server.nama_server }}</div>
                    <div class="text-[10px] opacity-70 mt-1">{{ server.tanggal_pembuatan }} | {{ server.pembuat }}</div>
                  </td>
                  <td class="py-3 text-xs text-center font-mono">
                    {{ server.spek_cpu || '-' }} C | {{ server.spek_ram || '-' }} GB | {{ server.spek_hdd || '-' }} GB
                  </td>
                  <td class="py-3 text-center">
                    <span class="px-2 py-0.5 rounded bg-slate-800 text-[10px] font-bold">{{ server.assigned_ips ? server.assigned_ips.length : 0 }} IP</span>
                  </td>
                  <td class="py-3 text-center">
                    <span class="px-2 py-0.5 rounded bg-slate-800 text-[10px] font-bold">{{ server.software_terpasang ? server.software_terpasang.length : 0 }} Items</span>
                  </td>
                  <td class="py-3 text-center">
                    <button @click="editServer(server)" class="bg-amber-600/80 hover:bg-amber-500 text-white px-3 py-1 rounded text-[10px] font-bold mr-2">DETAIL / EDIT</button>
                    <button @click="deleteServer(server.id)" class="bg-rose-900/80 hover:bg-rose-800 text-rose-200 px-3 py-1 rounded text-[10px] font-bold">HAPUS</button>
                  </td>
                </tr>
                <tr v-if="t.paginatedData.length === 0">
                  <td colspan="5" class="py-6 text-center italic text-xs opacity-50">Belum ada data server untuk kategori ini.</td>
                </tr>
              </tbody>
            </table>

            <div v-if="t.totalPages > 1" class="flex justify-between items-center mt-4 pt-3 border-t" style="border-color: #1B4C50;">
              <button @click="pageState[t.key]--" :disabled="pageState[t.key] === 1" class="text-[10px] uppercase tracking-widest font-bold bg-[#103B3E] px-3 py-1.5 rounded disabled:opacity-30 border" style="border-color: #1B4C50;">Prev</button>
              <span class="text-xs font-bold opacity-70">HAL {{ pageState[t.key] }} / {{ t.totalPages }}</span>
              <button @click="pageState[t.key]++" :disabled="pageState[t.key] >= t.totalPages" class="text-[10px] uppercase tracking-widest font-bold bg-[#103B3E] px-3 py-1.5 rounded disabled:opacity-30 border" style="border-color: #1B4C50;">Next</button>
            </div>
          </div>

        </div>

      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

const config = useRuntimeConfig()
const API_URL = config.public.apiBase

const headersConfig = { 'Content-Type': 'application/json', 'X-App-Token': '[o0Ht1407!=5437ul=@K8R{*?zQL36;}0o]123' }

// AMBIL DATA USER AKTIF DARI COOKIE
const userNama = useCookie('user_nama')
const userEmail = useCookie('user_email')

const isSaving = ref(false)

const emptyForm = () => ({
  id: 0,
  kategori_server: 'Virtual',
  nama_server: '',
  pusat_data: '',
  tanggal_pembuatan: new Date().toISOString().split('T')[0],
  pembuat: userNama.value || 'Administrator', 
  spek_cpu: '', spek_ram: '', spek_hdd: '',
  software_terpasang: [], 
  assigned_ips: [],
  kredensial_akun: { linux: [], database: [], aplikasi: [] } 
})

const form = ref(emptyForm())
const ipBlocks = ref([]) 
const allServers = ref([]) 

const pageState = ref({ fb: 1, vb: 1, fa: 1, va: 1 })
const itemsPerPage = 10

const fetchIpBlocks = async () => {
  try {
    const res = await $fetch(`${API_URL}/api/ip/blocks`, { headers: headersConfig })
    ipBlocks.value = typeof res === 'string' ? JSON.parse(res) : res || []
  } catch (error) { console.error("Gagal menarik data Blok IP:", error) }
}

const fetchServers = async () => {
  try {
    const res = await $fetch(`${API_URL}/api/server/manage`, { headers: headersConfig })
    allServers.value = typeof res === 'string' ? JSON.parse(res) : res || []
  } catch (error) { console.error("Gagal menarik data Server:", error) }
}

const editServer = (server) => {
  let parsed = JSON.parse(JSON.stringify(server)) 
  if (!parsed.software_terpasang) parsed.software_terpasang = []
  if (!parsed.assigned_ips) parsed.assigned_ips = []
  if (!parsed.kredensial_akun) parsed.kredensial_akun = { linux: [], database: [], aplikasi: [] }
  if (!parsed.kredensial_akun.linux) parsed.kredensial_akun.linux = []
  if (!parsed.kredensial_akun.database) parsed.kredensial_akun.database = []
  if (!parsed.kredensial_akun.aplikasi) parsed.kredensial_akun.aplikasi = []
  
  form.value = parsed
}

const resetForm = () => { form.value = emptyForm() }

const deleteServer = async (id) => {
  if(!confirm("Yakin ingin menghapus Server ini beserta catatan IP-nya secara permanen?")) return;
  try {
    await $fetch(`${API_URL}/api/server/manage?id=${id}&admin_nama=${userNama.value}&admin_email=${userEmail.value}`, { method: 'DELETE', headers: headersConfig })
    fetchServers()
    if(form.value.id === id) resetForm()
  } catch (err) {
    alert("Gagal menghapus server")
  }
}

const saveServer = async () => {
  isSaving.value = true
  
  // Menambahkan admin login info ke payload
  form.value.admin_nama = userNama.value;
  form.value.admin_email = userEmail.value;

  try {
    await $fetch(`${API_URL}/api/server/manage`, {
      method: 'POST', headers: headersConfig, body: form.value
    })
    alert('Server berhasil disimpan dan IP otomatis diperbarui di Modul Jaringan!')
    resetForm()
    fetchServers() 
  } catch (err) {
    alert('Gagal menyimpan server.')
  } finally {
    isSaving.value = false
  }
}

const fisikBalaikota = computed(() => allServers.value.filter(s => s.kategori_server === 'Fisik' && s.pusat_data === 'Pusat Data Balaikota'))
const virtualBalaikota = computed(() => allServers.value.filter(s => s.kategori_server === 'Virtual' && s.pusat_data === 'Pusat Data Balaikota'))
const fisikAsnet = computed(() => allServers.value.filter(s => s.kategori_server === 'Fisik' && s.pusat_data === 'Pusat Data ASNET'))
const virtualAsnet = computed(() => allServers.value.filter(s => s.kategori_server === 'Virtual' && s.pusat_data === 'Pusat Data ASNET'))

const tablesConfig = computed(() => [
  {
    key: 'fb', title: 'Server Fisik - Pusat Data Balaikota', total: fisikBalaikota.value.length,
    totalPages: Math.ceil(fisikBalaikota.value.length / itemsPerPage) || 1,
    paginatedData: fisikBalaikota.value.slice((pageState.value.fb - 1) * itemsPerPage, pageState.value.fb * itemsPerPage),
    textColor: 'text-emerald-300', borderColor: '#064e3b'
  },
  {
    key: 'vb', title: 'Server Virtual - Pusat Data Balaikota', total: virtualBalaikota.value.length,
    totalPages: Math.ceil(virtualBalaikota.value.length / itemsPerPage) || 1,
    paginatedData: virtualBalaikota.value.slice((pageState.value.vb - 1) * itemsPerPage, pageState.value.vb * itemsPerPage),
    textColor: 'text-blue-300', borderColor: '#1e3a8a'
  },
  {
    key: 'fa', title: 'Server Fisik - Pusat Data ASNET', total: fisikAsnet.value.length,
    totalPages: Math.ceil(fisikAsnet.value.length / itemsPerPage) || 1,
    paginatedData: fisikAsnet.value.slice((pageState.value.fa - 1) * itemsPerPage, pageState.value.fa * itemsPerPage),
    textColor: 'text-amber-300', borderColor: '#78350f'
  },
  {
    key: 'va', title: 'Server Virtual - Pusat Data ASNET', total: virtualAsnet.value.length,
    totalPages: Math.ceil(virtualAsnet.value.length / itemsPerPage) || 1,
    paginatedData: virtualAsnet.value.slice((pageState.value.va - 1) * itemsPerPage, pageState.value.va * itemsPerPage),
    textColor: 'text-purple-300', borderColor: '#4c1d95'
  }
])

onMounted(() => {
  fetchIpBlocks()
  fetchServers()
})
</script>

<style scoped>
.custom-scrollbar::-webkit-scrollbar { width: 4px; }
.custom-scrollbar::-webkit-scrollbar-thumb { background-color: #1B4C50; border-radius: 10px; }
.custom-scrollbar::-webkit-scrollbar-track { background-color: transparent; }
</style>
<!-- === NUXT DASHBOARD ADMIN - DCFMIS - Saeful Hamdi (shamdi.rh@gmail.com) === -->