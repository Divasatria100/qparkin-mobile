<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kesalahan Server - QParkIn</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 min-h-screen flex items-center justify-center">
    <div class="bg-white p-8 rounded-lg shadow-md text-center max-w-md">
        <div class="text-6xl font-bold text-red-600 mb-4">500</div>
        <h1 class="text-2xl font-semibold mb-4">Kesalahan Server</h1>
        <p class="text-gray-600 mb-6">Terjadi kesalahan pada server. Silakan coba lagi nanti.</p>
        <div class="space-y-3">
            <button onclick="window.location.reload()" class="block w-full bg-red-500 hover:bg-red-600 text-white font-bold py-2 px-4 rounded">
                Coba Lagi
            </button>
            <a href="{{ url('/') }}" class="block bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
                Ke Dashboard
            </a>
            <a href="mailto:support@qparkin.com" class="block text-blue-500 hover:text-blue-700">
                Hubungi Support
            </a>
        </div>
    </div>
</body>
</html>