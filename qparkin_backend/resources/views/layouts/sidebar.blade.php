<!-- !-- Sidebar -->
<aside id="sidebar" class="sidebar-glass w-64 min-h-screen text-white p-4 sm:p-6 fixed lg:sticky top-0 z-40 mobile-sidebar lg:transform-none">
    <!-- Close button for mobile -->
    <button id="close-sidebar" class="lg:hidden absolute top-4 right-4 text-white">
        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
        </svg>
    </button>

    <nav class="space-y-2 mt-8 lg:mt-0">
        <a href="#" class="flex items-center space-x-3 px-3 sm:px-4 py-2 sm:py-3 rounded-xl bg-white/20 hover:bg-white/30 transition-all duration-300 transform hover:scale-105 text-sm sm:text-base">
            <svg class="w-4 h-4 sm:w-5 sm:h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
            </svg>
            <span class="font-semibold">Profile</span>
        </a>

        <a href="#" class="flex items-center space-x-3 px-3 sm:px-4 py-2 sm:py-3 rounded-xl bg-gradient-to-r from-blue-500 to-purple-600 shadow-lg transition-all duration-300 transform hover:scale-105 text-sm sm:text-base">
            <svg class="w-4 h-4 sm:w-5 sm:h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
            </svg>
            <span class="font-semibold">Dashboard</span>
        </a>

        <a href="#" class="flex items-center space-x-3 px-3 sm:px-4 py-2 sm:py-3 rounded-xl hover:bg-white/20 transition-all duration-300 transform hover:scale-105 text-sm sm:text-base">
            <svg class="w-4 h-4 sm:w-5 sm:h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
            </svg>
            <span class="font-semibold">Notifikasi</span>
            <span class="ml-auto bg-red-500 text-white text-xs px-2 py-1 rounded-full">3</span>
        </a>

        <a href="#" class="flex items-center space-x-3 px-3 sm:px-4 py-2 sm:py-3 rounded-xl hover:bg-white/20 transition-all duration-300 transform hover:scale-105 text-sm sm:text-base">
            <svg class="w-4 h-4 sm:w-5 sm:h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7v8a2 2 0 002 2h6M8 7V5a2 2 0 012-2h4.586a1 1 0 01.707.293l4.414 4.414a1 1 0 01.293.707V15a2 2 0 01-2 2h-2M8 7H6a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2v-2" />
            </svg>
            <span class="font-semibold hidden xl:inline">Manajemen Kendaraan</span>
            <span class="font-semibold xl:hidden">Kendaraan</span>
        </a>

        <a href="#" class="flex items-center space-x-3 px-3 sm:px-4 py-2 sm:py-3 rounded-xl hover:bg-white/20 transition-all duration-300 transform hover:scale-105 text-sm sm:text-base">
            <svg class="w-4 h-4 sm:w-5 sm:h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <span class="font-semibold hidden xl:inline">Manajemen Tarif</span>
            <span class="font-semibold xl:hidden">Tarif</span>
        </a>

        <a href="#" class="flex items-center space-x-3 px-3 sm:px-4 py-2 sm:py-3 rounded-xl hover:bg-white/20 transition-all duration-300 transform hover:scale-105 text-sm sm:text-base">
            <svg class="w-4 h-4 sm:w-5 sm:h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
            </svg>
            <span class="font-semibold hidden xl:inline">Manajemen Parkir</span>
            <span class="font-semibold xl:hidden">Parkir</span>
        </a>

        <div class="pt-4 sm:pt-6 mt-4 sm:mt-6 border-t border-white/20">
            <a href="#" class="flex items-center space-x-3 px-3 sm:px-4 py-2 sm:py-3 rounded-xl hover:bg-red-500/20 text-red-200 hover:text-white transition-all duration-300 transform hover:scale-105 text-sm sm:text-base">
                <svg class="w-4 h-4 sm:w-5 sm:h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                </svg>
                <span class="font-semibold">Keluar</span>
            </a>
        </div>
    </nav>
</aside>