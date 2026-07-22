<template>
  <div class="min-h-screen flex items-center justify-center bg-cover bg-center relative" style="background-color: #031D44;">
    <div class="relative z-10 w-full max-w-md p-8 rounded-2xl shadow-[0_0_40px_rgba(27,76,80,0.4)] border" style="background-color: #103B3E; border-color: #1B4C50;">
      <div class="text-center mb-8">
        <div class="w-24 h-24 flex items-center justify-center mx-auto mb-4">
          <img src="/logo.png" alt="Logo PUSDAT" class="w-full h-full object-contain drop-shadow-md" />
        </div>
        <p class="text-sm font-bold tracking-widest mt-1 opacity-70" style="color: #CDEDF6;">Data Center <br>Facility Management Information System</p>
      </div>

      <form v-if="step === 1" @submit.prevent="handleLogin" class="space-y-5 animate-fade-in">
        <div>
          <label class="block text-xs font-bold uppercase tracking-wider mb-1" style="color: #CDEDF6;">Email</label>
          <input v-model="form.email" type="email" required class="w-full rounded-lg p-3 text-sm outline-none transition font-bold" style="background-color: #031D44; border: 1px solid #1B4C50; color: #CDEDF6;" placeholder="admin@kotabogor.go.id">
        </div>
        <div>
          <label class="block text-xs font-bold uppercase tracking-wider mb-1" style="color: #CDEDF6;">Password</label>
          <input v-model="form.password" type="password" required class="w-full rounded-lg p-3 text-sm outline-none transition font-bold tracking-widest" style="background-color: #031D44; border: 1px solid #1B4C50; color: #CDEDF6;" placeholder="••••••••">
        </div>
        <button type="submit" :disabled="isLoading" class="w-full font-bold py-3 rounded-lg transition disabled:opacity-50 mt-4 tracking-wider uppercase text-[#031D44] hover:opacity-90" style="background-color: #CDEDF6;">
          {{ isLoading ? 'Memverifikasi...' : 'Lanjutkan ➔' }}
        </button>
      </form>

      <form v-if="step === 2" @submit.prevent="verifyMath" class="space-y-5 animate-fade-in text-center">
        <div class="mb-2"><span class="text-4xl">🤖</span></div>
        <h3 class="text-lg font-bold" style="color: #CDEDF6;">Verifikasi Keamanan</h3>
        <p class="text-xs opacity-80" style="color: #CDEDF6;">Buktikan Anda bukan robot dengan menyelesaikan perhitungan di bawah ini.</p>
        
        <div class="mt-6 bg-[#031D44] border border-[#1B4C50] rounded-xl p-5 shadow-inner">
          <div class="text-xs font-bold uppercase tracking-widest mb-3 opacity-60" style="color: #CDEDF6;">Berapa hasil dari:</div>
          <div class="text-4xl font-black font-mono tracking-widest flex items-center justify-center gap-3" style="color: #CDEDF6;">
            <span>{{ mathChallenge.num1 }}</span>
            <span class="text-[#1B4C50]">{{ mathChallenge.operator }}</span>
            <span>{{ mathChallenge.num2 }}</span>
          </div>
        </div>

        <div class="mt-4">
          <input v-model="form.answer" type="number" required class="w-1/2 mx-auto rounded-lg p-3 text-3xl font-mono text-center font-bold outline-none transition" style="background-color: #031D44; border: 2px solid #1B4C50; color: #CDEDF6;" placeholder="?">
        </div>

        <div class="flex gap-3 mt-6">
          <button type="button" @click="step = 1" class="w-1/3 font-bold py-3 rounded-lg transition text-sm text-[#CDEDF6] hover:bg-[#031D44]" style="border: 1px solid #1B4C50;">Batal</button>
          <button type="submit" :disabled="isLoading" class="w-2/3 font-bold py-3 rounded-lg transition disabled:opacity-50 text-sm text-[#031D44] hover:opacity-90 uppercase tracking-widest" style="background-color: #CDEDF6;">
            {{ isLoading ? 'Mengecek...' : 'Masuk Dashboard' }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const step = ref(1) 
const isLoading = ref(false)

const form = ref({ 
  email: '', 
  password: '', 
  answer: '',           
  challenge_token: ''   
})

const mathChallenge = ref({ num1: 0, num2: 0, operator: '+' })

const config = useRuntimeConfig()
const API_URL = config.public.apiBase

const headersConfig = {
  'Content-Type': 'application/json',
  'X-App-Token': '[o0Ht1407!=5437ul=@K8R{*?zQL36;}0o]123'
}

const handleLogin = async () => {
  isLoading.value = true
  try {
    const response = await $fetch(`${API_URL}/api/auth/login-step1`, { 
      method: 'POST', 
      headers: headersConfig, 
      body: { email: form.value.email, password: form.value.password } 
    })
    const data = typeof response === 'string' ? JSON.parse(response) : response
    mathChallenge.value.num1 = data.math.num1
    mathChallenge.value.num2 = data.math.num2
    mathChallenge.value.operator = data.math.operator
    form.value.challenge_token = data.math.token 
    form.value.answer = '' 
    step.value = 2 
  } catch (error) {
    alert(error.response?._data || "Email atau Kata Sandi salah!")
  } finally {
    isLoading.value = false
  }
}

const verifyMath = async () => {
  isLoading.value = true
  let success = false
  let responseData = null
  
  try {
    const response = await $fetch(`${API_URL}/api/auth/verify-math`, { 
      method: 'POST', 
      headers: headersConfig, 
      body: {
        email: form.value.email,
        password: form.value.password,
        answer: String(form.value.answer), 
        challenge_token: form.value.challenge_token
      }
    })
    success = true
    responseData = typeof response === 'string' ? JSON.parse(response) : response
  } catch (error) {
    alert(error.response?._data || "Jawaban salah! Silakan coba lagi.")
    step.value = 1 
  } finally {
    isLoading.value = false
  }

  if (success && responseData) {
    useCookie('token').value = responseData.token || 'TOKEN_OTORISASI_VALID_SISTEM'
    useCookie('user_role').value = responseData.role_id 
    // PERBAIKAN: Menyimpan identitas ke cookie 
    useCookie('user_email').value = responseData.email || form.value.email
    useCookie('user_nama').value = responseData.nama_lengkap
    useCookie('user_jabatan').value = responseData.jabatan

    return navigateTo('/')
  }
}
</script>

<style scoped>
.animate-fade-in { animation: fadeIn 0.4s ease-in-out; }
@keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
input[type=number]::-webkit-inner-spin-button, 
input[type=number]::-webkit-outer-spin-button { -webkit-appearance: none; margin: 0; }
</style>
<!-- === NUXT DASHBOARD ADMIN - DCFMIS - Saeful Hamdi (shamdi.rh@gmail.com) === -->