<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile Admin - QParkIn</title>
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
                        Q
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
                <a href="{{ route('admin.profile') }}" class="flex items-center space-x-3 px-4 py-3 rounded-xl bg-gradient-to-r from-blue-500 to-purple-600 shadow-lg transition-all duration-300 transform hover:scale-105">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                    </svg>
                    <span class="font-semibold">Profile</span>
                </a>

                <a href="{{ route('admin.dashboard') }}" class="flex items-center space-x-3 px-4 py-3 rounded-xl hover:bg-white/20 transition-all duration-300 transform hover:scale-105">
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
                        {{ $notifBelumDibaca ?? 0 }}
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
                    <a href="{{ route('logout') }}" class="flex items-center space-x-3 px-4 py-3 rounded-xl hover:bg-red-500/20 text-red-200 hover:text-white transition-all duration-300 transform hover:scale-105">
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
            
            <!-- Profile Header Card -->
            <div class="glass rounded-2xl p-8 shadow-xl animate-fade-in">
                <div class="flex items-center space-x-6">
                    <div class="relative">
                        <div class="w-32 h-32 rounded-full bg-gradient-to-br from-purple-500 to-blue-600 flex items-center justify-center text-white font-bold text-5xl shadow-xl">
                            {{ strtoupper(substr(Auth::user()->name, 0, 2)) }}
                        </div>
                        <button class="absolute bottom-0 right-0 w-10 h-10 bg-blue-600 hover:bg-blue-700 rounded-full flex items-center justify-center shadow-lg transition-all duration-300 transform hover:scale-110">
                            <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
                            </svg>
                        </button>
                    </div>
                    <div class="flex-1">
                        <h2 class="text-3xl font-bold text-gray-800 mb-2">{{ Auth::user()->name }}</h2>
                        <p class="text-lg text-gray-600 mb-1">{{ ucfirst(str_replace('_', ' ', Auth::user()->role)) }}</p>
                        <div class="flex items-center space-x-4 text-sm text-gray-600">
                            <span class="flex items-center">
                                <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
                                </svg>
                                {{ $mall->nama_mall ?? 'Mall Tidak Ditemukan' }}
                            </span>
                            <span class="flex items-center">
                                <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                                Bergabung sejak {{ Auth::user()->created_at->format('d F Y') }}
                            </span>
                        </div>
                    </div>
                    <div>
                        <span class="px-4 py-2 rounded-full text-sm font-semibold {{ Auth::user()->status == 'aktif' ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700' }}">
                            Status: {{ ucfirst(Auth::user()->status) }}
                        </span>
                    </div>
                </div>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <!-- Personal Information -->
                <div class="lg:col-span-2 glass rounded-2xl p-6 shadow-xl animate-fade-in" style="animation-delay: 0.1s;">
                    <div class="flex items-center justify-between mb-6">
                        <h3 class="text-xl font-bold text-gray-800">Informasi Personal</h3>
                        <button id="editBtn" class="px-4 py-2 bg-gradient-to-r from-blue-500 to-purple-600 text-white rounded-xl font-semibold hover:shadow-lg transition-all duration-300 transform hover:scale-105">
                            Edit Profile
                        </button>
                    </div>

                    <form id="profileForm" method="POST" action="{{ route('admin.profile.update') }}" class="space-y-4">
                        @csrf
                        @method('PUT')
                        
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <label class="block text-sm font-semibold text-gray-700 mb-2">
                                    <span class="flex items-center">
                                        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                                        </svg>
                                        Nama Lengkap
                                    </span>
                                </label>
                                <input type="text" name="name" value="{{ Auth::user()->name }}" disabled class="w-full px-4 py-3 border border-gray-300 rounded-xl bg-gray-50 text-gray-700 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-70" />
                            </div>

                            <div>
                                <label class="block text-sm font-semibold text-gray-700 mb-2">
                                    <span class="flex items-center">
                                        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                                        </svg>
                                        Email
                                    </span>
                                </label>
                                <input type="email" name="email" value="{{ Auth::user()->email ?? 'Belum diatur' }}" disabled class="w-full px-4 py-3 border border-gray-300 rounded-xl bg-gray-50 text-gray-700 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-70" />
                            </div>

                            <div>
                                <label class="block text-sm font-semibold text-gray-700 mb-2">
                                    <span class="flex items-center">
                                        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                                        </svg>
                                        No. Telepon
                                    </span>
                                </label>
                                <input type="tel" name="no_hp" value="{{ Auth::user()->no_hp ?? 'Belum diatur' }}" disabled class="w-full px-4 py-3 border border-gray-300 rounded-xl bg-gray-50 text-gray-700 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-70" />
                            </div>

                            <div>
                                <label class="block text-sm font-semibold text-gray-700 mb-2">
                                    <span class="flex items-center">
                                        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                                        </svg>
                                        Posisi
                                    </span>
                                </label>
                                <input type="text" value="{{ ucfirst(str_replace('_', ' ', Auth::user()->role)) }}" disabled class="w-full px-4 py-3 border border-gray-300 rounded-xl bg-gray-50 text-gray-700 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-70" />
                            </div>

                            <div class="md:col-span-2">
                                <label class="block text-sm font-semibold text-gray-700 mb-2">
                                    <span class="flex items-center">
                                        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                                        </svg>
                                        Lokasi Mall
                                    </span>
                                </label>
                                <input type="text" value="{{ $mall->lokasi ?? 'Lokasi tidak tersedia' }}" disabled class="w-full px-4 py-3 border border-gray-300 rounded-xl bg-gray-50 text-gray-700 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-70" />
                            </div>
                        </div>

                        <div class="pt-4 hidden" id="saveBtn">
                            <button type="submit" class="w-full px-6 py-3 bg-gradient-to-r from-green-500 to-green-600 text-white rounded-xl font-semibold hover:shadow-lg transition-all duration-300 transform hover:scale-105">
                                Simpan Perubahan
                            </button>
                        </div>
                    </form>
                </div>

                <!-- Stats & Activity -->
                <div class="space-y-6">
                    <!-- Quick Stats -->
                    <div class="glass rounded-2xl p-6 shadow-xl animate-fade-in" style="animation-delay: 0.2s;">
                        <h3 class="text-xl font-bold text-gray-800 mb-4">Statistik Poin</h3>
                        <div class="space-y-4">
                            <div class="flex items-center justify-between p-3 bg-blue-50 rounded-xl">
                                <div class="flex items-center space-x-3">
                                    <div class="w-10 h-10 rounded-full bg-blue-500 flex items-center justify-center">
                                        <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
                                        </svg>
                                    </div>
                                    <div>
                                        <p class="text-xs text-gray-600">Saldo Poin</p>
                                        <p class="text-lg font-bold text-gray-800">{{ number_format(Auth::user()->saldo_poin, 0, ',', '.') }}</p>
                                    </div>
                                </div>
                            </div>

                            <div class="flex items-center justify-between p-3 bg-green-50 rounded-xl">
                                <div class="flex items-center space-x-3">
                                    <div class="w-10 h-10 rounded-full bg-green-500 flex items-center justify-center">
                                        <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                                        </svg>
                                    </div>
                                    <div>
                                        <p class="text-xs text-gray-600">Transaksi Bulan Ini</p>
                                        <p class="text-lg font-bold text-gray-800">{{ $totalTransaksiBulanIni ?? 0 }}</p>
                                    </div>
                                </div>
                            </div>

                            <div class="flex items-center justify-between p-3 bg-purple-50 rounded-xl">
                                <div class="flex items-center space-x-3">
                                    <div class="w-10 h-10 rounded-full bg-purple-500 flex items-center justify-center">
                                        <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 3.055A9.001 9.001 0 1020.945 13H11V3.055z" />
                                        </svg>
                                    </div>
                                    <div>
                                        <p class="text-xs text-gray-600">Poin Diperoleh</p>
                                        <p class="text-lg font-bold text-gray-800">{{ $poinDiperolehBulanIni ?? 0 }}</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Security -->
                    <div class="glass rounded-2xl p-6 shadow-xl animate-fade-in" style="animation-delay: 0.3s;">
                        <h3 class="text-xl font-bold text-gray-800 mb-4">Keamanan Akun</h3>
                        <div class="space-y-3">
                            <button class="w-full flex items-center justify-between p-3 rounded-xl hover:bg-gray-50 transition-all duration-300 group">
                                <div class="flex items-center space-x-3">
                                    <svg class="w-5 h-5 text-gray-600 group-hover:text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                                    </svg>
                                    <span class="text-sm font-semibold text-gray-700">Ubah Password</span>
                                </div>
                                <svg class="w-4 h-4 text-gray-400 group-hover:text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                                </svg>
                            </button>

                            <button class="w-full flex items-center justify-between p-3 rounded-xl hover:bg-gray-50 transition-all duration-300 group">
                                <div class="flex items-center space-x-3">
                                    <svg class="w-5 h-5 text-gray-600 group-hover:text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                                    </svg>
                                    <span class="text-sm font-semibold text-gray-700">Verifikasi 2-Faktor</span>
                                </div>
                                <svg class="w-4 h-4 text-gray-400 group-hover:text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                                </svg>
                            </button>
                        </div>
                    </div>
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

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const editBtn = document.getElementById('editBtn');
            const saveBtn = document.getElementById('saveBtn');
            const formInputs = document.querySelectorAll('#profileForm input[disabled]');
            
            editBtn.addEventListener('click', function() {
                // Enable all form inputs
                formInputs.forEach(input => {
                    input.disabled = false;
                    input.classList.remove('bg-gray-50', 'disabled:opacity-70');
                    input.classList.add('bg-white');
                });
                
                // Show save button
                saveBtn.classList.remove('hidden');
                
                // Hide edit button
                editBtn.classList.add('hidden');
            });
        });
    </script>
</body>
</html>