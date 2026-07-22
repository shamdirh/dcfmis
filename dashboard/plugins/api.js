export default defineNuxtPlugin((nuxtApp) => {
  const api = $fetch.create({
//    baseURL: 'http://localhost:8080', // Otomatis mengarah ke port Golang
    baseURL: 'https://labs-api-dcfmis.net', // Otomatis mengarah ke port Golang
    onRequest({ request, options }) {
      options.headers = options.headers || {}
      // Kunci KTP resmi Nuxt untuk menembus Middleware Golang
      options.headers['X-App-Token'] = '[o0Ht1407!=5437ul=@K8R{*?zQL36;}0o]123'
    }
  })

  return {
    provide: {
      api
    }
  }
})
// === NUXT DASHBOARD ADMIN - DCFMIS - Saeful Hamdi (shamdi.rh@gmail.com) ===