export default defineNuxtRouteMiddleware((to, from) => {
    // Membaca cookie yang baru saja kita simpan di halaman login
    const token = useCookie('token')
    
    // Jika tidak ada token dan user mencoba mengakses halaman selain login, lempar ke login
    if (!token.value && to.path !== '/login') {
        return navigateTo('/login')
    }

    // Jika sudah punya token tapi mencoba mengakses halaman login, lempar ke beranda
    if (token.value && to.path === '/login') {
        return navigateTo('/')
    }
})
// === NUXT DASHBOARD ADMIN - DCFMIS - Saeful Hamdi (shamdi.rh@gmail.com) ===