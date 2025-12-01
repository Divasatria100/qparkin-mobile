<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'Dashboard Super Admin') - QPARKIN</title>
    
    <!-- Tailwind CDN -->
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@4.5.0/dist/tailwind.min.css" rel="stylesheet">
    
    <!-- Styles -->
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

    <!-- Scripts -->
    @stack('scripts')
</body>
</html>
