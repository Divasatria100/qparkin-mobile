<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'Dashboard Super Admin') - QPARKIN</title>
    
    <!-- Base Dashboard Styles -->
    <link rel="stylesheet" href="{{ asset('css/super-dashboard.css') }}">
    
    <!-- Page Specific Styles -->
    @stack('styles')
</head>
<body>
    <div class="admin-container">
        <!-- Header - Fixed -->
        @include('partials.superadmin.header')

        <!-- Main Wrapper -->
        <div class="main-wrapper">
            <!-- Sidebar - Fixed -->
            @include('partials.superadmin.sidebar')

            <!-- Sidebar Overlay -->
            <div class="sidebar-overlay"></div>

            <!-- Main Content - Scrollable -->
            <main class="admin-content">
                <!-- Breadcrumb -->
                <div class="breadcrumb">
                    @yield('breadcrumb')
                </div>

                @yield('content')

                <!-- Footer -->
                @include('partials.superadmin.footer')
            </main>
        </div>
    </div>

    <!-- Base Dashboard Scripts -->
    <script src="{{ asset('js/super-dashboard.js') }}"></script>
    
    <!-- Page Specific Scripts -->
    @stack('scripts')
</body>
</html>
