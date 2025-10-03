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