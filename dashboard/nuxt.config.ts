// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({

  runtimeConfig: {
    public: {
      // otomatis membaca nilai NUXT_PUBLIC_API_BASE dari file .env
      apiBase: process.env.NUXT_PUBLIC_API_BASE || 'http://localhost:8080'
    }
  },

  modules: [
    '@nuxtjs/tailwindcss'
  ],	
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true }
})
// === NUXT DASHBOARD ADMIN - DCFMIS - Saeful Hamdi (shamdi.rh@gmail.com) === 