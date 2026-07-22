<template>
  <div class="min-h-screen text-[#CDEDF6] p-6 font-sans" style="background-color: #031D44;">
    
    <!-- HEADER -->
    <header class="rounded-2xl shadow-[0_4px_20px_rgba(0,0,0,0.3)] p-6 mb-6 flex justify-between items-center border" style="background-color: #103B3E; border-color: #1B4C50;">
      <div>
        <h1 class="text-2xl font-extrabold tracking-wider uppercase drop-shadow-sm" style="color: #CDEDF6;">
          Manajemen Pengguna
        </h1>
        <p class="text-xs mt-1 font-medium opacity-70">Kelola Akses dan Jabatan Sistem PUSDAT</p>
      </div>
      <button @click="navigateTo('/')" class="hover:bg-[#1B4C50] text-[#CDEDF6] border px-4 py-2 rounded-lg text-xs font-bold uppercase tracking-wider transition duration-300" style="border-color: #1B4C50;">
        ← Kembali
      </button>
    </header>

    <div class="grid grid-cols-1 xl:grid-cols-3 gap-6">
      
      <!-- KOLOM KIRI: FORM TAMBAH / EDIT -->
      <div class="xl:col-span-1 border rounded-xl shadow-md p-6 h-fit" style="background-color: #103B3E; border-color: #1B4C50;">
        <h2 class="text-sm font-bold mb-5 uppercase tracking-widest border-b pb-2" style="border-color: #1B4C50; color: #CDEDF6;">
          {{ form.id ? 'Edit Pengguna' : 'Tambah Pengguna Baru' }}
        </h2>
        
        <form @submit.prevent="saveUser" class="space-y-4">
          <div>
            <label class="block text-xs font-bold uppercase tracking-wider mb-1 opacity-80" style="color: #CDEDF6;">Nama Lengkap</label>
            <input v-model="form.nama_lengkap" type="text" required class="w-full rounded-lg p-2.5 text-sm outline-none transition" style="background-color: #031D44; border: 1px solid #1B4C50; color: #CDEDF6;">
          </div>
          
          <!-- TAMBAHAN FIELD JABATAN -->
          <div>
            <label class="block text-xs font-bold uppercase tracking-wider mb-1 opacity-80" style="color: #CDEDF6;">Jabatan</label>
            <input v-model="form.jabatan" type="text" placeholder="Cth: Pranata Komputer Ahli Muda" required class="w-full rounded-lg p-2.5 text-sm outline-none transition" style="background-color: #031D44; border: 1px solid #1B4C50; color: #CDEDF6;">
          </div>

          <div>
            <label class="block text-xs font-bold uppercase tracking-wider mb-1 opacity-80" style="color: #CDEDF6;">Email Akses</label>
            <input v-model="form.email" type="email" required class="w-full rounded-lg p-2.5 text-sm outline-none transition" style="background-color: #031D44; border: 1px solid #1B4C50; color: #CDEDF6;">
          </div>
          
          <div>
            <label class="block text-xs font-bold uppercase tracking-wider mb-1 opacity-80" style="color: #CDEDF6;">Kata Sandi <span v-if="form.id" class="text-[10px] lowercase italic font-normal text-amber-200">(Kosongkan jika tidak diubah)</span></label>
            <input v-model="form.password" type="password" :required="!form.id" class="w-full rounded-lg p-2.5 text-sm outline-none transition" style="background-color: #031D44; border: 1px solid #1B4C50; color: #CDEDF6;">
          </div>
          
          <div>
            <label class="block text-xs font-bold uppercase tracking-wider mb-1 opacity-80" style="color: #CDEDF6;">Hak Akses (Role)</label>
            <select v-model="form.role_id" required class="w-full rounded-lg p-2.5 text-sm outline-none transition" style="background-color: #031D44; border: 1px solid #1B4C50; color: #CDEDF6;">
              <option value="1">Super Admin</option>
              <option value="2">Admin Modul</option>
              <option value="3">Eksekutif (Read-Only)</option>
            </select>
          </div>
          
          <div class="flex gap-2 pt-3">
            <button v-if="form.id" type="button" @click="resetForm" class="w-1/3 py-3 rounded-lg text-xs font-bold uppercase tracking-wider border hover:bg-[#031D44] transition" style="border-color: #1B4C50; color: #CDEDF6;">
              Batal
            </button>
            <button type="submit" :disabled="isLoading" class="flex-1 font-bold py-3 rounded-lg transition text-[#031D44] uppercase tracking-wider text-xs shadow-sm hover:opacity-90 disabled:opacity-50" style="background-color: #CDEDF6;">
              {{ isLoading ? 'Menyimpan...' : 'Simpan Pengguna' }}
            </button>
          </div>
        </form>
      </div>

      <!-- KOLOM KANAN: TABEL DATA PENGGUNA -->
      <div class="xl:col-span-2 border rounded-xl shadow-md overflow-hidden flex flex-col h-fit" style="background-color: #103B3E; border-color: #1B4C50;">
        <div class="p-5 border-b flex justify-between items-center" style="background-color: #031D44; border-color: #1B4C50;">
          <h2 class="text-sm font-extrabold uppercase tracking-widest flex items-center gap-2" style="color: #CDEDF6;">
            Daftar Pengguna Sistem
          </h2>
        </div>
        
        <div class="overflow-x-auto">
          <table class="w-full text-left text-sm whitespace-nowrap">
            <thead class="uppercase text-[11px] tracking-wider font-bold border-b" style="background-color: #031D44; border-color: #1B4C50; color: #CDEDF6; opacity: 0.9;">
              <tr>
                <th class="p-4 pl-6">Nama Pengguna</th>
                <th class="p-4">Jabatan</th>
                <th class="p-4">Email</th>
                <th class="p-4 text-center">Hak Akses</th>
                <th class="p-4 text-center pr-6">Aksi</th>
              </tr>
            </thead>
            <tbody class="divide-y" style="border-color: #1B4C50;">
              <tr v-if="pending" class="animate-pulse" style="background-color: #103B3E;">
                <td colspan="5" class="p-8 text-center font-medium opacity-70">Menarik data dari server...</td>
              </tr>
              <tr v-else-if="users.length === 0">
                <td colspan="5" class="p-8 text-center italic font-medium opacity-70">Belum ada data pengguna.</td>
              </tr>
              
              <!-- LOOPING DATA PENGGUNA -->
              <tr v-for="user in users" :key="user.id" class="transition duration-150 hover:bg-[#1B4C50]/30">
                <td class="p-4 pl-6 font-bold" style="color: #CDEDF6;">{{ user.nama_lengkap }}</td>
                <td class="p-4 text-xs font-medium opacity-90">{{ user.jabatan || 'Belum Diisi' }}</td>
                <td class="p-4 text-xs opacity-80">{{ user.email }}</td>
                <td class="p-4 text-center">
                  <span class="px-2.5 py-1 rounded text-[10px] font-bold uppercase tracking-wider"
                        :class="user.role_id === 1 ? 'bg-rose-900/30 text-rose-300 border border-rose-800' : 'bg-emerald-900/30 text-emerald-400 border border-emerald-800'">
                    {{ user.role_name || (user.role_id === 1 ? 'Super Admin' : user.role_id === 2 ? 'Admin' : 'Eksekutif') }}
                  </span>
                </td>
                <td class="p-4 text-center pr-6">
                  <div class="flex justify-center gap-2">
                    <button @click="editUser(user)" class="px-3 py-1.5 rounded text-xs border hover:bg-[#1B4C50] transition shadow-sm font-bold" style="background-color: #031D44; border-color: #1B4C50; color: #CDEDF6;">
                      Edit
                    </button>
                    <button @click="deleteUser(user.id)" class="px-3 py-1.5 rounded text-xs border hover:bg-rose-900/50 transition shadow-sm font-bold text-rose-300" style="background-color: #031D44; border-color: #1B4C50;">
                      Hapus
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

definePageMeta({ middleware: 'auth' })

//const API_URL = 'http://localhost:8080'
//const API_URL = 'https://labs-api-dcfmis.net'
const config = useRuntimeConfig()
const API_URL = config.public.apiBase

const headersConfig = {
  'Content-Type': 'application/json',
  'X-App-Token': '[o0Ht1407!=5437ul=@K8R{*?zQL36;}0o]123'
}

const userNama = useCookie('user_nama')
const userEmail = useCookie('user_email')

const users = ref([])
const pending = ref(true)
const isLoading = ref(false)

const form = ref({
  id: null,
  nama_lengkap: '',
  jabatan: '',
  email: '',
  password: '',
  role_id: 2
})

const fetchUsers = async () => {
  pending.value = true
  try {
    const res = await $fetch(`${API_URL}/api/users`, { headers: headersConfig })
    users.value = typeof res === 'string' ? JSON.parse(res) : res || []
  } catch (error) {
    console.error("Gagal menarik data pengguna", error)
  } finally {
    pending.value = false
  }
}

const saveUser = async () => {
  isLoading.value = true
  try {
    await $fetch(`${API_URL}/api/users`, {
      method: 'POST',
      headers: headersConfig,
      body: {
        id: form.value.id ? Number(form.value.id) : 0,
        nama_lengkap: form.value.nama_lengkap,
        jabatan: form.value.jabatan,
        email: form.value.email,
        password: form.value.password,
        role_id: Number(form.value.role_id),
        // Tambahan Log Info Pelaku Admin
        admin_nama: userNama.value,
        admin_email: userEmail.value
      }
    })
    alert("Pengguna berhasil disimpan!")
    resetForm()
    fetchUsers()
  } catch (error) {
    alert("Gagal menyimpan pengguna. Pastikan email tidak duplikat.")
  } finally {
    isLoading.value = false
  }
}

const editUser = (user) => {
  form.value = {
    id: user.id,
    nama_lengkap: user.nama_lengkap,
    jabatan: user.jabatan || '', 
    email: user.email,
    password: '', 
    role_id: user.role_id
  }
}

const deleteUser = async (id) => {
  if (!confirm("Yakin ingin menghapus pengguna ini secara permanen?")) return
  try {
    await $fetch(`${API_URL}/api/users?id=${id}&admin_nama=${userNama.value}&admin_email=${userEmail.value}`, {
      method: 'DELETE',
      headers: headersConfig
    })
    fetchUsers()
  } catch (error) {
    alert("Gagal menghapus pengguna.")
  }
}

const resetForm = () => {
  form.value = { id: null, nama_lengkap: '', jabatan: '', email: '', password: '', role_id: 2 }
}

onMounted(() => {
  fetchUsers()
})
</script>