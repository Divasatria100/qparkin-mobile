<!DOCTYPE html>
<html lang="id">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Super Admin - QParkIn</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>

<body class="bg-gray-100">
    <nav class="bg-blue-600 text-white p-4">
        <div class="container mx-auto flex justify-between items-center">
            <h1 class="text-xl font-bold">QParkIn - Super Admin</h1>
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
        <h2 class="text-2xl font-bold mb-6">Dashboard Super Admin</h2>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            <div class="bg-white p-6 rounded-lg shadow">
                <h3 class="text-lg font-semibold mb-2">Total Mall</h3>
                <p class="text-3xl font-bold text-blue-600">{{ $totalMall }}</p>
            </div>

            <div class="bg-white p-6 rounded-lg shadow">
                <h3 class="text-lg font-semibold mb-2">Total Admin</h3>
                <p class="text-3xl font-bold text-green-600">{{ $totalAdmin }}</p>
            </div>

            <div class="bg-white p-6 rounded-lg shadow">
                <h3 class="text-lg font-semibold mb-2">Total Customer</h3>
                <p class="text-3xl font-bold text-purple-600">{{ $totalCustomer }}</p>
            </div>

            <div class="bg-white p-6 rounded-lg shadow">
                <h3 class="text-lg font-semibold mb-2">Transaksi Hari Ini</h3>
                <p class="text-3xl font-bold text-orange-600">{{ $transaksiHariIni }}</p>
            </div>
        </div>

        <div class="bg-white p-6 rounded-lg shadow">
            <h3 class="text-lg font-semibold mb-4">Menu Super Admin</h3>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                <a href="#" class="bg-blue-100 hover:bg-blue-200 p-4 rounded-lg text-center">
                    <p class="font-semibold">Kelola Mall</p>
                </a>
                <a href="#" class="bg-blue-100 hover:bg-blue-200 p-4 rounded-lg text-center">
                    <p class="font-semibold">Kelola Admin</p>
                </a>
                <a href="#" class="bg-blue-100 hover:bg-blue-200 p-4 rounded-lg text-center">
                    <p class="font-semibold">Laporan Sistem</p>
                </a>
            </div>
        </div>
    </div>
</body>

</html>