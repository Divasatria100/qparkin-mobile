<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sesi Kedaluwarsa - QParkIn</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 min-h-screen flex items-center justify-center">
    <div class="bg-white p-8 rounded-lg shadow-md text-center max-w-md">
        <div class="text-6xl font-bold text-yellow-600 mb-4">419</div>
        <h1 class="text-2xl font-semibold mb-4">Sesi Kedaluwarsa</h1>
        <p class="text-gray-600 mb-6">Sesi Anda telah berakhir. Silakan refresh halaman dan coba lagi.</p>
        <button onclick="window.location.reload()" class="bg-yellow-500 hover:bg-yellow-600 text-white font-bold py-2 px-4 rounded mr-2">
            Refresh Halaman
        </button>
        <a href="{{ url('/') }}" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
            Ke Dashboard
        </a>
    </div>
</body>
</html>