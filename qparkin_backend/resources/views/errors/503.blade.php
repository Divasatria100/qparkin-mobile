<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Layanan Tidak Tersedia - QParkIn</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 min-h-screen flex items-center justify-center">
    <div class="bg-white p-8 rounded-lg shadow-md text-center max-w-md">
        <div class="text-6xl font-bold text-blue-600 mb-4">503</div>
        <h1 class="text-2xl font-semibold mb-4">Layanan Tidak Tersedia</h1>
        <p class="text-gray-600 mb-6">Sistem sedang dalam pemeliharaan. Silakan coba lagi nanti.</p>
        <div class="bg-blue-50 p-4 rounded mb-4">
            <p class="text-blue-800">Perkiraan waktu selesai: 30 menit</p>
        </div>
        <a href="{{ url('/') }}" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
            Refresh Halaman
        </a>
    </div>
</body>
</html>