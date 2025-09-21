<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Terlalu Banyak Permintaan - QParkIn</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 min-h-screen flex items-center justify-center">
    <div class="bg-white p-8 rounded-lg shadow-md text-center max-w-md">
        <div class="text-6xl font-bold text-orange-600 mb-4">429</div>
        <h1 class="text-2xl font-semibold mb-4">Terlalu Banyak Permintaan</h1>
        <p class="text-gray-600 mb-6">Anda telah melakukan terlalu banyak permintaan. Silakan coba lagi nanti.</p>
        <div class="space-y-3">
            <button onclick="window.location.reload()" class="block w-full bg-orange-500 hover:bg-orange-600 text-white font-bold py-2 px-4 rounded">
                Coba Lagi
            </button>
            <a href="{{ url('/') }}" class="block bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
                Ke Dashboard
            </a>
        </div>
    </div>
</body>
</html>