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

        /* Mobile Sidebar */
        .mobile-sidebar {
            transform: translateX(-100%);
            transition: transform 0.3s ease-in-out;
        }

        .mobile-sidebar.active {
            transform: translateX(0);
        }

        /* Responsive Table */
        @media (max-width: 768px) {
            .responsive-table {
                display: block;
                overflow-x: auto;
                white-space: nowrap;
            }
        }

        /* TV Optimization */
        @media (min-width: 1920px) {
            .container-tv {
                max-width: 1800px;
                margin: 0 auto;
            }
        }
    </style>
</head>
<body class="bg-gradient-animated min-h-screen">
    @include('layouts.header')
    <div class="flex">
        @include('layouts.sidebar')
        <!-- Main Content -->
        <main class="flex-1 p-3 sm:p-4 lg:p-6 space-y-4 sm:space-y-6 w-full lg:w-auto container-tv">
            
            <!-- Stats Cards - Pendapatan -->
            <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-3 sm:gap-4 lg:gap-6 animate-fade-in">
                <div class="glass rounded-xl sm:rounded-2xl p-4 sm:p-6 shadow-xl transform hover:scale-105 transition-all duration-300">
                    <div class="flex items-center justify-between">
                        <div class="flex-1">
                            <p class="text-xs sm:text-sm text-gray-600 font-semibold">Pendapatan Harian</p>
                            <h3 class="text-xl sm:text-2xl xl:text-3xl font-bold text-gray-800 mt-1 sm:mt-2"> Rp {{ number_format($pendapatanHarian, 0, ',', '.') }}</h3>
                             <!-- <p class="text-sm text-green-600 mt-1">↑ 12% dari kemarin</p> -->
                        </div>
                        <div class="w-12 h-12 sm:w-16 sm:h-16 rounded-full bg-gradient-to-br from-green-400 to-green-600 flex items-center justify-center shadow-lg flex-shrink-0 ml-2">
                            <svg class="w-6 h-6 sm:w-8 sm:h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                        </div>
                    </div>
                </div>

                <div class="glass rounded-xl sm:rounded-2xl p-4 sm:p-6 shadow-xl transform hover:scale-105 transition-all duration-300">
                    <div class="flex items-center justify-between">
                        <div class="flex-1">
                            <p class="text-xs sm:text-sm text-gray-600 font-semibold">Pendapatan Mingguan</p>
                            <h3 class="text-xl sm:text-2xl xl:text-3xl font-bold text-gray-800 mt-1 sm:mt-2">Rp {{ number_format($pendapatanMingguan, 0, ',', '.') }}</h3>
                        </div>
                        <div class="w-12 h-12 sm:w-16 sm:h-16 rounded-full bg-gradient-to-br from-blue-400 to-blue-600 flex items-center justify-center shadow-lg flex-shrink-0 ml-2">
                            <svg class="w-6 h-6 sm:w-8 sm:h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                            </svg>
                        </div>
                    </div>
                </div>

                <div class="glass rounded-xl sm:rounded-2xl p-4 sm:p-6 shadow-xl transform hover:scale-105 transition-all duration-300 sm:col-span-2 xl:col-span-1">
                    <div class="flex items-center justify-between">
                        <div class="flex-1">
                            <p class="text-xs sm:text-sm text-gray-600 font-semibold">Pendapatan Bulanan</p>
                            <h3 class="text-xl sm:text-2xl xl:text-3xl font-bold text-gray-800 mt-1 sm:mt-2">Rp {{ number_format($pendapatanBulanan, 0, ',', '.') }}
                            </h3>
                        </div>
                        <div class="w-12 h-12 sm:w-16 sm:h-16 rounded-full bg-gradient-to-br from-purple-400 to-purple-600 flex items-center justify-center shadow-lg flex-shrink-0 ml-2">
                            <svg class="w-6 h-6 sm:w-8 sm:h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
                            </svg>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Stats Cards - Kendaraan -->
            <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-3 sm:gap-4 lg:gap-6 animate-fade-in" style="animation-delay: 0.1s;">
                <div class="glass rounded-xl sm:rounded-2xl p-4 sm:p-6 shadow-xl transform hover:scale-105 transition-all duration-300">
                    <div class="flex items-center justify-between">
                        <div class="flex-1">
                            <p class="text-xs sm:text-sm text-gray-600 font-semibold">Kendaraan Masuk</p>
                            <h3 class="text-xl sm:text-2xl xl:text-3xl font-bold text-gray-800 mt-1 sm:mt-2">{{ $masuk }}</h3>
                            <p class="text-xs sm:text-sm text-gray-500 mt-1">Hari ini</p>
                        </div>
                        <div class="w-12 h-12 sm:w-16 sm:h-16 rounded-full bg-gradient-to-br from-cyan-400 to-cyan-600 flex items-center justify-center shadow-lg flex-shrink-0 ml-2">
                            <svg class="w-6 h-6 sm:w-8 sm:h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1" />
                            </svg>
                        </div>
                    </div>
                </div>

                <div class="glass rounded-xl sm:rounded-2xl p-4 sm:p-6 shadow-xl transform hover:scale-105 transition-all duration-300">
                    <div class="flex items-center justify-between">
                        <div class="flex-1">
                            <p class="text-xs sm:text-sm text-gray-600 font-semibold">Kendaraan Keluar</p>
                            <h3 class="text-xl sm:text-2xl xl:text-3xl font-bold text-gray-800 mt-1 sm:mt-2">{{ $keluar }}</h3>
                            <p class="text-xs sm:text-sm text-gray-500 mt-1">Hari ini</p>
                        </div>
                        <div class="w-12 h-12 sm:w-16 sm:h-16 rounded-full bg-gradient-to-br from-orange-400 to-orange-600 flex items-center justify-center shadow-lg flex-shrink-0 ml-2">
                            <svg class="w-6 h-6 sm:w-8 sm:h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                            </svg>
                        </div>
                    </div>
                </div>

                <div class="glass rounded-xl sm:rounded-2xl p-4 sm:p-6 shadow-xl transform hover:scale-105 transition-all duration-300 sm:col-span-2 xl:col-span-1">
                    <div class="flex items-center justify-between">
                        <div class="flex-1">
                            <p class="text-xs sm:text-sm text-gray-600 font-semibold">Sedang Parkir</p>
                            <h3 class="text-xl sm:text-2xl xl:text-3xl font-bold text-gray-800 mt-1 sm:mt-2">{{ $aktif }}</h3>
                            <p class="text-xs sm:text-sm text-gray-500 mt-1">Slot tersisa: {{ $kapasitasTersisa - $aktif }}</p>
                        </div>
                        <div class="w-12 h-12 sm:w-16 sm:h-16 rounded-full bg-gradient-to-br from-pink-400 to-pink-600 flex items-center justify-center shadow-lg animate-pulse-slow flex-shrink-0 ml-2">
                            <svg class="w-6 h-6 sm:w-8 sm:h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7v8a2 2 0 002 2h6M8 7V5a2 2 0 012-2h4.586a1 1 0 01.707.293l4.414 4.414a1 1 0 01.293.707V15a2 2 0 01-2 2h-2M8 7H6a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2v-2" />
                            </svg>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Riwayat Transaksi Parkir -->
            <div class="glass rounded-xl sm:rounded-2xl p-4 sm:p-6 shadow-xl animate-fade-in" style="animation-delay: 0.2s;">
                <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between mb-4 sm:mb-6 gap-3">
                    <h2 class="text-lg sm:text-xl xl:text-2xl font-bold text-gray-800">Riwayat Transaksi Terbaru</h2>
                    <a href="#" class="text-blue-600 hover:text-blue-700 font-semibold flex items-center text-sm sm:text-base">
                        Lihat Semua
                        <svg class="w-4 h-4 ml-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                        </svg>
                    </a>
                </div>

                <div class="overflow-x-auto responsive-table -mx-4 sm:mx-0">
                    <div class="inline-block min-w-full align-middle">
                        <table class="w-full">
                            <thead>
                                <tr class="border-b border-gray-200">
                                    <th class="text-left py-2 sm:py-3 px-2 sm:px-4 text-xs sm:text-sm font-semibold text-gray-600 whitespace-nowrap">ID</th>
                                    <th class="text-left py-2 sm:py-3 px-2 sm:px-4 text-xs sm:text-sm font-semibold text-gray-600 whitespace-nowrap">Plat</th>
                                    <th class="text-left py-2 sm:py-3 px-2 sm:px-4 text-xs sm:text-sm font-semibold text-gray-600 whitespace-nowrap">Jenis</th>
                                    <th class="text-left py-2 sm:py-3 px-2 sm:px-4 text-xs sm:text-sm font-semibold text-gray-600 whitespace-nowrap">Masuk</th>
                                    <th class="text-left py-2 sm:py-3 px-2 sm:px-4 text-xs sm:text-sm font-semibold text-gray-600 whitespace-nowrap">Keluar</th>
                                    <th class="text-left py-2 sm:py-3 px-2 sm:px-4 text-xs sm:text-sm font-semibold text-gray-600 whitespace-nowrap">Durasi</th>
                                    <th class="text-left py-2 sm:py-3 px-2 sm:px-4 text-xs sm:text-sm font-semibold text-gray-600 whitespace-nowrap">Biaya</th>
                                    <th class="text-left py-2 sm:py-3 px-2 sm:px-4 text-xs sm:text-sm font-semibold text-gray-600 whitespace-nowrap">Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                 @forelse ($transaksiTerbaru as $trx)
                                <tr class="border-b border-gray-100 hover:bg-gray-50">
                                    <td class="py-3 sm:py-4 px-2 sm:px-4 text-xs sm:text-sm text-gray-800 whitespace-nowrap">{{ $trx->id_transaksi }}</td>
                                    <td class="py-3 sm:py-4 px-2 sm:px-4 text-xs sm:text-sm text-gray-800 whitespace-nowrap">{{ $trx->kendaraan->plat ?? '-' }}</td>
                                    <td class="py-3 sm:py-4 px-2 sm:px-4 text-xs sm:text-sm text-gray-800 whitespace-nowrap">{{ $trx->kendaraan->jenis ?? '-' }}</td>
                                    <td class="py-3 sm:py-4 px-2 sm:px-4 text-xs sm:text-sm text-gray-600 whitespace-nowrap">{{ $trx->waktu_masuk }}</td>
                                    <td class="py-3 sm:py-4 px-2 sm:px-4 text-xs sm:text-sm text-gray-600 whitespace-nowrap">{{ $trx->waktu_keluar ?? '-' }}</td>
                                    <td class="py-3 sm:py-4 px-2 sm:px-4 text-xs sm:text-sm text-gray-600 whitespace-nowrap">{{ $trx->durasi ?? '-' }}</td>
                                    <td class="py-3 sm:py-4 px-2 sm:px-4 text-xs sm:text-sm font-semibold text-gray-800 whitespace-nowrap">
                                         @if($trx->biaya)
                                            Rp {{ number_format($trx->biaya, 0, ',', '.') }}
                                        @else
                                            -
                                        @endif
                                    </td>
                                    <td class="py-3 sm:py-4 px-2 sm:px-4 whitespace-nowrap">
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
            </div>
        </main>
    </div>
    @include('layouts.footer')
</body>
</html>