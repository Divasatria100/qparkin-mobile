<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'Dashboard Admin') - QPARKIN</title>
    
    <!-- Base Styles -->
    <link rel="stylesheet" href="{{ asset('css/admin-dashboard.css') }}">
    @yield('styles')
</head>
<body>
    <div class="admin-container">
        <!-- Header - Fixed -->
        @include('partials.admin.header')

        <!-- Main Wrapper -->
        <div class="main-wrapper">
            <!-- Sidebar - Fixed -->
            @include('partials.admin.sidebar')

            <!-- Sidebar Overlay -->
            <div class="sidebar-overlay"></div>

            <!-- Main Content - Scrollable -->
            <main class="admin-content">
                @yield('content')

                <!-- Footer -->
                @include('partials.admin.footer')
            </main>
        </div>
    </div>

    <!-- Base Scripts -->
    <script src="{{ asset('js/admin-dashboard.js') }}"></script>
    @yield('scripts')
</body>
</html>
