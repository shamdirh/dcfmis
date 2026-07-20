<template>
  <div class="min-h-screen bg-slate-950 text-slate-100 p-6 font-sans relative">
    
    <!-- HEADER -->
    <header class="flex flex-col md:flex-row justify-between items-start md:items-center border-b border-slate-800 pb-4 mb-6 gap-4">
      <div class="flex items-center gap-4">
        <!-- Tombol Back -->
        <button @click="navigateTo('/')" class="bg-slate-900 border border-slate-700 hover:border-cyan-500 hover:bg-slate-800 text-slate-400 hover:text-cyan-400 p-2.5 rounded-lg transition shadow-lg">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
          </svg>
        </button>
        <div>
          <h1 class="text-2xl lg:text-3xl font-bold tracking-wider text-cyan-500 uppercase drop-shadow-md">
            Log & Riwayat Aktivitas
          </h1>
          <p class="text-xs text-slate-400 mt-1">Pencatatan rekam jejak pengguna pada sistem DCFMIS</p>
        </div>
      </div>
    </header>

    <!-- KONTEN UTAMA (TABEL) -->
    <div class="bg-slate-900 border border-slate-800 rounded-xl shadow-lg relative overflow-hidden flex flex-col">
      
      <!-- Loading State -->
      <div v-if="pending" class="flex justify-center items-center py-20">
        <div class="animate-spin rounded-full h-10 w-10 border-b-2 border-cyan-500 shadow-[0_0_15px_rgba(6,182,212,0.5)]"></div>
      </div>
      
      <!-- State Kosong -->
      <div v-else-if="!logs || logs.length === 0" class="text-center py-20 bg-slate-900/50">
        <p class="text-slate-500 font-mono text-sm tracking-widest uppercase">Belum ada riwayat aktivitas yang tercatat.</p>
      </div>

      <!-- State Tabel Log -->
      <div v-else class="overflow-x-auto">
        <table class="w-full text-left border-collapse">
          <thead>
            <tr class="bg-slate-950/80 border-b border-slate-700 text-[10px] uppercase tracking-widest text-slate-400">
              <th class="p-5 font-semibold w-16 text-center">Tipe</th>
              <th class="p-5 font-semibold">Pengguna Sistem</th>
              <th class="p-5 font-semibold w-[45%]">Rincian Aktivitas</th>
              <th class="p-5 font-semibold text-right">Waktu Eksekusi</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-800/80 text-sm">
            <tr v-for="log in logs" :key="log.id" class="hover:bg-slate-800/40 transition group">
              
              <!-- Ikon -->
              <td class="p-5 text-center align-top">
                <div class="inline-flex items-center justify-center h-8 w-8 rounded-lg bg-slate-950 border border-slate-800 group-hover:border-slate-600 transition">
                  <span v-if="log.aktivitas.toLowerCase().includes('gagal')" class="text-red-500">❌</span>
                  <span v-else-if="log.aktivitas.toLowerCase().includes('berhasil login')" class="text-green-500">✅</span>
                  <span v-else class="text-cyan-500">⚡</span>
                </div>
              </td>
              
              <!-- Pengguna -->
              <td class="p-5 align-top">
                <div class="font-bold text-slate-200 tracking-wide">{{ log.nama_lengkap }}</div>
                <div class="text-xs text-slate-500 font-mono mt-0.5 flex items-center gap-1">
                  <span>✉️</span> {{ log.email }}
                </div>
              </td>
              
              <!-- Aktivitas -->
              <td class="p-5 align-top">
                <p class="text-slate-300 leading-relaxed text-[13px]">
                  {{ log.aktivitas }}
                </p>
              </td>
              
              <!-- Waktu -->
              <td class="p-5 text-right align-top">
                <div class="text-xs font-mono text-slate-400 whitespace-nowrap bg-slate-950 px-3 py-1.5 rounded-md inline-block border border-slate-800">
                  {{ formatTanggal(log.waktu) }}
                </div>
              </td>

            </tr>
          </tbody>
        </table>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref } from 'vue'

definePageMeta({ middleware: 'auth' })

const config = useRuntimeConfig()
const API_URL = config.public.apiBase

// Fetch data log dari backend Golang
const { data: logs, pending } = await useFetch(`${API_URL}/api/logs`, {
  headers: {
    'X-App-Token': '[o0Ht1407!=5437ul=@K8R{*?zQL36;}0o]'
  },
  default: () => []
})

// Fungsi memformat tanggal (Format: 15 Jul 2026 - 14:30:05 WIB)
const formatTanggal = (waktuString) => {
  if (!waktuString) return '-'
  
  const date = new Date(waktuString)
  if (isNaN(date.getTime())) return waktuString
  
  const jam = date.getHours().toString().padStart(2, '0')
  const menit = date.getMinutes().toString().padStart(2, '0')
  const detik = date.getSeconds().toString().padStart(2, '0')
  
  const hari = date.toLocaleDateString('id-ID', { day: '2-digit', month: 'short', year: 'numeric' })
  
  return `${hari} - ${jam}:${menit}:${detik} WIB`
}
</script>
<!-- === NUXT DASHBOARD ADMIN - DCFMIS - Saeful Hamdi (shamdi.rh@gmail.com) === -->