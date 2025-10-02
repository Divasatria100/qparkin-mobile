<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Admin - QParkIn</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    animation: {
                        'fade-in': 'fadeIn 0.5s ease-in-out',
                        'slide-in': 'slideIn 0.5s ease-out',
                        'pulse-slow': 'pulse 3s ease-in-out infinite',
                    },
                    keyframes: {
                        fadeIn: {
                            '0%': { opacity: '0', transform: 'translateY(10px)' },
                            '100%': { opacity: '1', transform: 'translateY(0)' }
                        },
                        slideIn: {
                            '0%': { transform: 'translateX(-20px)', opacity: '0' },
                            '100%': { transform: 'translateX(0)', opacity: '1' }
                        }
                    }
                }
            }
        }
    </script>
    <style>
        .bg-gradient-animated {
            background: linear-gradient(-45deg, #667eea, #573ED1, #42CBF8, #39108A);
            background-size: 400% 400%;
            animation: gradientShift 15s ease infinite;
        }

        @keyframes gradientShift {
            0%, 100% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
        }

        .glass {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.3);
        }

        .sidebar-glass {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border-right: 1px solid rgba(255, 255, 255, 0.2);
        }
    </style>
</head>
<body class="bg-gradient-animated min-h-screen">
    
    <!-- Header -->
    <header class="glass shadow-lg sticky top-0 z-50 animate-fade-in">
        <div class="px-6 py-4">
            <div class="flex items-center justify-between">
                <div class="flex items-center space-x-4">
                    <div class="w-12 h-12 rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center text-white font-bold text-xl shadow-lg">
                        
                    </div>
                    <div>
                        <h1 class="text-2xl font-bold text-gray-800">QParkIn</h1>
                        <p class="text-sm text-gray-600">{{ $mall->nama_mall ?? 'Mall Tidak Ditemukan' }}</p>
                    </div>
                </div>
                <div class="flex items-center space-x-4">
                    <div class="text-right">
                        <p class="text-sm text-gray-600">{{ $mall->nama_mall ?? '' }}</p>
                        <p class="text-lg font-semibold text-gray-800">{{ Auth::user()->name }}</p>
                    </div>
                    <div class="w-10 h-10 rounded-full bg-gradient-to-br from-purple-500 to-blue-600 flex items-center justify-center text-white font-bold">
                        {{ strtoupper(substr(Auth::user()->name, 0, 2)) }}
                    </div>
                </div>
            </div>
        </div>
    </header>

    <div class="flex">
        <!-- Sidebar -->
        <aside class="sidebar-glass w-64 min-h-screen text-white p-6 animate-slide-in">
            <nav class="space-y-2">
                <a href="#" class="flex items-center space-x-3 px-4 py-3 rounded-xl bg-white/20 hover:bg-white/30 transition-all duration-300 transform hover:scale-105">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                    </svg>
                    <span class="font-semibold">Profile</span>
                </a>

                <a href="#" class="flex items-center space-x-3 px-4 py-3 rounded-xl bg-gradient-to-r from-blue-500 to-purple-600 shadow-lg transition-all duration-300 transform hover:scale-105">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
                    </svg>
                    <span class="font-semibold">Dashboard</span>
                </a>

                <a href="#" class="flex items-center space-x-3 px-4 py-3 rounded-xl hover:bg-white/20 transition-all duration-300 transform hover:scale-105">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
                    </svg>
                    <span class="font-semibold">Notifikasi</span>
                    <span class="ml-auto bg-red-500 text-white text-xs px-2 py-1 rounded-full">
                        {{ $notifBelumDibaca }}
                    </span>
                </a>

                <a href="#" class="flex items-center space-x-3 px-4 py-3 rounded-xl hover:bg-white/20 transition-all duration-300 transform hover:scale-105">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7v8a2 2 0 002 2h6M8 7V5a2 2 0 012-2h4.586a1 1 0 01.707.293l4.414 4.414a1 1 0 01.293.707V15a2 2 0 01-2 2h-2M8 7H6a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2v-2" />
                    </svg>
                    <span class="font-semibold">Manajemen Kendaraan</span>
                </a>

                <a href="#" class="flex items-center space-x-3 px-4 py-3 rounded-xl hover:bg-white/20 transition-all duration-300 transform hover:scale-105">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                    <span class="font-semibold">Manajemen Tarif</span>
                </a>

                <a href="#" class="flex items-center space-x-3 px-4 py-3 rounded-xl hover:bg-white/20 transition-all duration-300 transform hover:scale-105">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                    </svg>
                    <span class="font-semibold">Manajemen Parkir</span>
                </a>

                <div class="pt-6 mt-6 border-t border-white/20">
                    <a href="#" class="flex items-center space-x-3 px-4 py-3 rounded-xl hover:bg-red-500/20 text-red-200 hover:text-white transition-all duration-300 transform hover:scale-105">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                        </svg>
                        <span class="font-semibold">Keluar</span>
                    </a>
                </div>
            </nav>
        </aside>

        <!-- Main Content -->
        <main class="flex-1 p-6 space-y-6">
            
            <!-- Stats Cards - Pendapatan -->
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6 animate-fade-in">
                <div class="glass rounded-2xl p-6 shadow-xl transform hover:scale-105 transition-all duration-300">
                    <div class="flex items-center justify-between">
                        <div>
                        <p class="text-sm text-gray-600 font-semibold">Pendapatan Harian</p>
                        <h3 class="text-3xl font-bold text-gray-800 mt-2">
                            Rp {{ number_format($pendapatanHarian, 0, ',', '.') }}
                        </h3>
                        <!-- <p class="text-sm text-green-600 mt-1">↑ 12% dari kemarin</p> -->
                        </div>
                        <div class="w-16 h-16 rounded-full bg-gradient-to-br from-green-400 to-green-600 flex items-center justify-center shadow-lg">
                            <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                        </div>
                    </div>
                </div>

                <div class="glass rounded-2xl p-6 shadow-xl transform hover:scale-105 transition-all duration-300">
                    <div class="flex items-center justify-between">
                        <div>
                        <p class="text-sm text-gray-600 font-semibold">Pendapatan Mingguan</p>
                        <h3 class="text-3xl font-bold text-gray-800 mt-2">
                            Rp {{ number_format($pendapatanMingguan, 0, ',', '.') }}
                        </h3>
                        <!-- <p class="text-sm text-green-600 mt-1">↑ 8% dari minggu lalu</p> -->
                        </div>
                        <div class="w-16 h-16 rounded-full bg-gradient-to-br from-blue-400 to-blue-600 flex items-center justify-center shadow-lg">
                            <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                            </svg>
                        </div>
                    </div>
                </div>

                <div class="glass rounded-2xl p-6 shadow-xl transform hover:scale-105 transition-all duration-300">
                    <div class="flex items-center justify-between">
                        <div>
                        <p class="text-sm text-gray-600 font-semibold">Pendapatan Bulanan</p>
                        <h3 class="text-3xl font-bold text-gray-800 mt-2">
                            Rp {{ number_format($pendapatanBulanan, 0, ',', '.') }}
                        </h3>
                        <!-- <p class="text-sm text-green-600 mt-1">↑ 15% dari bulan lalu</p> -->
                        </div>
                        <div class="w-16 h-16 rounded-full bg-gradient-to-br from-purple-400 to-purple-600 flex items-center justify-center shadow-lg">
                            <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
                            </svg>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Stats Cards - Kendaraan -->
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6 animate-fade-in" style="animation-delay: 0.1s;">
                <div class="glass rounded-2xl p-6 shadow-xl transform hover:scale-105 transition-all duration-300">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm text-gray-600 font-semibold">Kendaraan Masuk</p>
                            <h3 class="text-3xl font-bold text-gray-800 mt-2">{{ $masuk }}</h3>
                            <p class="text-sm text-gray-500 mt-1">Hari ini</p>
                        </div>
                        <div class="w-16 h-16 rounded-full bg-gradient-to-br from-cyan-400 to-cyan-600 flex items-center justify-center shadow-lg">
                            <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1" />
                            </svg>
                        </div>
                    </div>
                </div>

                <div class="glass rounded-2xl p-6 shadow-xl transform hover:scale-105 transition-all duration-300">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm text-gray-600 font-semibold">Kendaraan Keluar</p>
                            <h3 class="text-3xl font-bold text-gray-800 mt-2">{{ $keluar }}</h3>
                            <p class="text-sm text-gray-500 mt-1">Hari ini</p>
                        </div>
                        <div class="w-16 h-16 rounded-full bg-gradient-to-br from-orange-400 to-orange-600 flex items-center justify-center shadow-lg">
                            <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                            </svg>
                        </div>
                    </div>
                </div>

                <div class="glass rounded-2xl p-6 shadow-xl transform hover:scale-105 transition-all duration-300">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm text-gray-600 font-semibold">Sedang Parkir</p>
                            <h3 class="text-3xl font-bold text-gray-800 mt-2">{{ $aktif }}</h3>
                            <p class="text-sm text-gray-500 mt-1">Slot tersisa: {{ $kapasitasTersisa - $aktif }}</p>
                        </div>
                        <div class="w-16 h-16 rounded-full bg-gradient-to-br from-pink-400 to-pink-600 flex items-center justify-center shadow-lg animate-pulse-slow">
                            <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7v8a2 2 0 002 2h6M8 7V5a2 2 0 012-2h4.586a1 1 0 01.707.293l4.414 4.414a1 1 0 01.293.707V15a2 2 0 01-2 2h-2M8 7H6a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2v-2" />
                            </svg>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Riwayat Transaksi Parkir -->
            <div class="glass rounded-2xl p-6 shadow-xl animate-fade-in" style="animation-delay: 0.2s;">
                <div class="flex items-center justify-between mb-6">
                    <h2 class="text-2xl font-bold text-gray-800">Riwayat Transaksi Terbaru</h2>
                    <a href="#" class="text-blue-600 hover:text-blue-700 font-semibold flex items-center">
                        Lihat Semua
                        <svg class="w-4 h-4 ml-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                        </svg>
                    </a>
                </div>

                <div class="overflow-x-auto">
                    <table class="w-full">
                        <thead>
                            <tr class="border-b border-gray-200">
                                <th class="text-left py-3 px-4 text-sm font-semibold text-gray-600">ID</th>
                                <th class="text-left py-3 px-4 text-sm font-semibold text-gray-600">Plat</th>
                                <th class="text-left py-3 px-4 text-sm font-semibold text-gray-600">Jenis</th>
                                <th class="text-left py-3 px-4 text-sm font-semibold text-gray-600">Masuk</th>
                                <th class="text-left py-3 px-4 text-sm font-semibold text-gray-600">Keluar</th>
                                <th class="text-left py-3 px-4 text-sm font-semibold text-gray-600">Durasi</th>
                                <th class="text-left py-3 px-4 text-sm font-semibold text-gray-600">Biaya</th>
                                <th class="text-left py-3 px-4 text-sm font-semibold text-gray-600">Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse ($transaksiTerbaru as $trx)
                                <tr class="border-b border-gray-100">
                                    <td class="py-4 px-4 text-sm text-gray-800">{{ $trx->id_transaksi }}</td>
                                    <td class="py-4 px-4 text-sm text-gray-800">{{ $trx->kendaraan->plat ?? '-' }}</td>
                                    <td class="py-4 px-4 text-sm text-gray-800">{{ $trx->kendaraan->jenis ?? '-' }}</td>
                                    <td class="py-4 px-4 text-sm text-gray-600">{{ $trx->waktu_masuk }}</td>
                                    <td class="py-4 px-4 text-sm text-gray-600">{{ $trx->waktu_keluar ?? '-' }}</td>
                                    <td class="py-4 px-4 text-sm text-gray-600">{{ $trx->durasi ?? '-' }}</td>
                                    <td class="py-4 px-4 text-sm font-semibold text-gray-800">
                                        @if($trx->biaya)
                                            Rp {{ number_format($trx->biaya, 0, ',', '.') }}
                                        @else
                                            -
                                        @endif
                                    </td>
                                    <td class="py-4 px-4">
                                        @if($trx->waktu_keluar)
                                            <span class="px-3 py-1 rounded-full text-xs font-semibold bg-green-100 text-green-700">
                                                Selesai
                                            </span>
                                        @else
                                            <span class="px-3 py-1 rounded-full text-xs font-semibold bg-blue-100 text-blue-700">
                                                Aktif
                                            </span>
                                        @endif
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="8" class="text-center py-4 text-gray-600">
                                        Tidak ada transaksi.
                                    </td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>

        </main>
    </div>

    <!-- Footer -->
    <footer class="glass mt-6 py-4 animate-fade-in" style="animation-delay: 0.3s;">
        <div class="container mx-auto px-6">
            <p class="text-center text-gray-600 text-sm">
                &copy; 2025 QParkIn. Solusi Parkir Terbaik.
            </p>
        </div>
    </footer>

</body>
</html>