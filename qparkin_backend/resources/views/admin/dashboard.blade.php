<!DOCTYPE html>
<html lang="id">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Admin - QParkIn</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>

<body class="bg-gray-100">
    <nav class="bg-blue-600 text-white p-4">
        <div class="container mx-auto flex justify-between items-center">
            <h1 class="text-xl font-bold">QParkIn - Admin {{ $mall->nama_mall }}</h1>
            <div>
                <span class="mr-4">Hai, {{ auth()->user()->nama }}</span>
                <form method="POST" action="{{ route('logout') }}" class="inline">
                    @csrf
                    <button type="submit" class="bg-blue-700 hover:bg-blue-800 px-4 py-2 rounded text-white">Logout</button>
                </form>
            </div>
        </div>
    </nav>

    <div class="container mx-auto p-4">
        <h2 class="text-2xl font-bold mb-6">Dashboard</h2>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
            <div class="bg-white p-6 rounded-lg shadow">
                <h3 class="text-lg font-semibold mb-2">Transaksi Hari Ini</h3>
                <p class="text-3xl font-bold text-blue-600">{{ $transaksiHariIni }}</p>
            </div>

            <div class="bg-white p-6 rounded-lg shadow">
                <h3 class="text-lg font-semibold mb-2">Slot Parkir Tersedia</h3>
                <p class="text-3xl font-bold text-green-600">{{ $parkiranTersedia }}</p>
            </div>
        </div>

        <div class="bg-white p-6 rounded-lg shadow">
            <h3 class="text-lg font-semibold mb-4">Menu Admin</h3>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                <a href="#" class="bg-blue-100 hover:bg-blue-200 p-4 rounded-lg text-center">
                    <p class="font-semibold">Kelola Parkir</p>
                </a>
                <a href="#" class="bg-blue-100 hover:bg-blue-200 p-4 rounded-lg text-center">
                    <p class="font-semibold">Lihat Transaksi</p>
                </a>
                <a href="#" class="bg-blue-100 hover:bg-blue-200 p-4 rounded-lg text-center">
                    <p class="font-semibold">Kelola Tarif</p>
                </a>
            </div>
        </div>
    </div>
</body>

</html>