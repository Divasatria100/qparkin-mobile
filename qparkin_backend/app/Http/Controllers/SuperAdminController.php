<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use App\Models\Mall;
use App\Models\User;
use App\Models\TransaksiParkir;
use App\Models\AdminMall;
use Carbon\Carbon;

class SuperAdminController extends Controller
{
    public function dashboard()
    {
        // Total Mall Terdaftar
        $totalMalls = Mall::count();
        $lastMonthMalls = Mall::where('created_at', '>=', Carbon::now()->subMonth())->count();
        
        // Total Pendapatan Sistem
        $totalRevenue = TransaksiParkir::whereNotNull('biaya')->sum('biaya');
        $lastMonthRevenue = TransaksiParkir::whereNotNull('biaya')
            ->where('waktu_masuk', '>=', Carbon::now()->subMonth())
            ->sum('biaya');
        $previousMonthRevenue = TransaksiParkir::whereNotNull('biaya')
            ->whereBetween('waktu_masuk', [Carbon::now()->subMonths(2), Carbon::now()->subMonth()])
            ->sum('biaya');
        $revenueGrowth = $previousMonthRevenue > 0 
            ? round((($lastMonthRevenue - $previousMonthRevenue) / $previousMonthRevenue) * 100, 1) 
            : 0;
        
        // Admin Aktif
        $activeAdmins = AdminMall::whereHas('user', function($q) {
            $q->where('status', 'active');
        })->count();
        $lastMonthAdmins = AdminMall::where('created_at', '>=', Carbon::now()->subMonth())->count();
        
        // Pengajuan Akun Baru
        $pendingRequests = User::where('application_status', 'pending')->count();
        
        // Transaksi Hari Ini
        $todayTransactions = TransaksiParkir::whereDate('waktu_masuk', today())->count();
        $yesterdayTransactions = TransaksiParkir::whereDate('waktu_masuk', Carbon::yesterday())->count();
        $transactionGrowth = $yesterdayTransactions > 0 
            ? round((($todayTransactions - $yesterdayTransactions) / $yesterdayTransactions) * 100, 1) 
            : 0;
        
        // Pengguna Aktif
        $activeUsers = User::where('role', 'customer')
            ->where('status', 'active')
            ->count();
        $lastMonthUsers = User::where('role', 'customer')
            ->where('created_at', '>=', Carbon::now()->subMonth())
            ->count();
        $userGrowth = $activeUsers > 0 
            ? round(($lastMonthUsers / $activeUsers) * 100, 1) 
            : 0;

        // Recent Activities - ambil dari berbagai tabel
        $recentActivities = collect();
        
        // Admin baru ditambahkan
        $newAdmins = AdminMall::with(['user', 'mall'])
            ->whereNotNull('created_at')
            ->orderBy('created_at', 'desc')
            ->limit(2)
            ->get()
            ->map(function($admin) {
                return (object)[
                    'time' => Carbon::parse($admin->created_at)->diffForHumans(),
                    'description' => 'Admin baru ditambahkan: ' . ($admin->user->name ?? 'N/A'),
                    'location' => $admin->mall->nama_mall ?? 'N/A',
                    'created_at' => $admin->created_at
                ];
            });
        
        // Pengajuan pending
        $pendingUsers = User::where('application_status', 'pending')
            ->whereNotNull('applied_at')
            ->orderBy('applied_at', 'desc')
            ->limit(2)
            ->get()
            ->map(function($user) {
                return (object)[
                    'time' => Carbon::parse($user->applied_at)->diffForHumans(),
                    'description' => 'Pengajuan akun baru: ' . ($user->name ?? 'N/A'),
                    'location' => $user->requested_mall_name ?? 'Menunggu verifikasi',
                    'created_at' => $user->applied_at
                ];
            });
        
        // Mall baru terdaftar
        $newMalls = Mall::whereNotNull('created_at')
            ->orderBy('created_at', 'desc')
            ->limit(2)
            ->get()
            ->map(function($mall) {
                return (object)[
                    'time' => Carbon::parse($mall->created_at)->diffForHumans(),
                    'description' => 'Mall baru terdaftar',
                    'location' => $mall->nama_mall ?? 'N/A',
                    'created_at' => $mall->created_at
                ];
            });
        
        $recentActivities = $recentActivities
            ->merge($newAdmins)
            ->merge($pendingUsers)
            ->merge($newMalls)
            ->sortByDesc('created_at')
            ->take(6);

        // Top 5 Malls berdasarkan pendapatan
        $topMalls = Mall::select('mall.id_mall', 'mall.nama_mall')
            ->leftJoin('transaksi_parkir', 'mall.id_mall', '=', 'transaksi_parkir.id_mall')
            ->selectRaw('COALESCE(SUM(transaksi_parkir.biaya), 0) as total_revenue')
            ->selectRaw('COUNT(transaksi_parkir.id_transaksi) as transaction_count')
            ->groupBy('mall.id_mall', 'mall.nama_mall')
            ->orderBy('total_revenue', 'DESC')
            ->limit(5)
            ->get()
            ->map(function($mall, $index) {
                // Hitung growth berdasarkan bulan lalu
                $lastMonthRevenue = TransaksiParkir::where('id_mall', $mall->id_mall)
                    ->whereNotNull('biaya')
                    ->whereBetween('waktu_masuk', [Carbon::now()->subMonths(2), Carbon::now()->subMonth()])
                    ->sum('biaya');
                
                $thisMonthRevenue = TransaksiParkir::where('id_mall', $mall->id_mall)
                    ->whereNotNull('biaya')
                    ->where('waktu_masuk', '>=', Carbon::now()->subMonth())
                    ->sum('biaya');
                
                $growth = $lastMonthRevenue > 0 
                    ? round((($thisMonthRevenue - $lastMonthRevenue) / $lastMonthRevenue) * 100, 1) 
                    : 0;
                
                return (object)[
                    'rank' => $index + 1,
                    'name' => $mall->nama_mall ?? 'N/A',
                    'revenue' => $mall->total_revenue,
                    'growth' => $growth
                ];
            });

        return view('superadmin.dashboard', compact(
            'totalMalls',
            'lastMonthMalls',
            'totalRevenue',
            'revenueGrowth',
            'activeAdmins',
            'lastMonthAdmins',
            'pendingRequests',
            'todayTransactions',
            'transactionGrowth',
            'activeUsers',
            'userGrowth',
            'recentActivities',
            'topMalls'
        ));
    }

    public function profile()
    {
        $user = Auth::user();
        return view('superadmin.profile', compact('user'));
    }

    public function editProfile()
    {
        $user = Auth::user();
        return view('superadmin.super-edit-informasi', compact('user'));
    }

    public function updateProfile(Request $request)
    {
        $user = Auth::user();
        $userId = $user->id_user ?? $user->id;
        
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|max:255|unique:user,email,' . $userId . ',id_user',
            'nomor_hp' => 'nullable|string|max:20',
            'status' => 'nullable|in:aktif,nonaktif',
            'current_password' => 'nullable|required_with:password',
            'password' => 'nullable|min:8|confirmed',
        ]);

        // Update basic info
        $user->name = $validated['name'];
        $user->email = $validated['email'];
        
        if (isset($validated['nomor_hp'])) {
            $user->nomor_hp = $validated['nomor_hp'];
        }
        
        if (isset($validated['status'])) {
            $user->status = $validated['status'];
        }

        // Update password if provided
        if ($request->filled('password')) {
            if (!\Hash::check($request->current_password, $user->password)) {
                return back()->withErrors(['current_password' => 'Kata sandi saat ini tidak sesuai']);
            }
            $user->password = \Hash::make($validated['password']);
        }

        $user->save();

        return redirect()->route('superadmin.profile')->with('success', 'Profil berhasil diperbarui');
    }

    public function editPhoto()
    {
        $user = Auth::user();
        return view('superadmin.super-ubah-foto', compact('user'));
    }

    public function updatePhoto(Request $request)
    {
        $user = Auth::user();
        
        $validated = $request->validate([
            'avatar' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        // Delete old avatar if exists
        if ($user->avatar && \Storage::disk('public')->exists($user->avatar)) {
            \Storage::disk('public')->delete($user->avatar);
        }

        // Store new avatar
        $path = $request->file('avatar')->store('avatars', 'public');
        
        $user->avatar = $path;
        $user->save();

        return redirect()->route('superadmin.profile')->with('success', 'Foto profil berhasil diperbarui');
    }

    public function editSecurity()
    {
        $user = Auth::user();
        return view('superadmin.super-ubah-keamanan', compact('user'));
    }

    public function mall()
    {
        $malls = Mall::with(['adminMall.user', 'parkiran', 'transaksiParkir', 'tarifParkir'])->get();
        return view('superadmin.mall', compact('malls'));
    }

    public function createMall()
    {
        return view('superadmin.super-tambah-mall');
    }

    public function storeMall(Request $request)
    {
        $validated = $request->validate([
            'nama_mall' => 'required|string|max:255',
            'alamat_lengkap' => 'required|string|max:255',
            'latitude' => 'nullable|numeric|between:-90,90',
            'longitude' => 'nullable|numeric|between:-180,180',
            'kapasitas' => 'required|integer|min:1',
            'alamat_gmaps' => 'nullable|string',
            'has_slot_reservation_enabled' => 'nullable|boolean',
            'admin_name' => 'nullable|string|max:255',
            'admin_email' => 'nullable|email|unique:user,email',
            'admin_phone' => 'nullable|string|max:20',
            'admin_password' => 'nullable|min:8',
        ]);

        \DB::beginTransaction();
        try {
            // Create mall
            $mall = Mall::create([
                'nama_mall' => $validated['nama_mall'],
                'alamat_lengkap' => $validated['alamat_lengkap'],
                'latitude' => $validated['latitude'] ?? null,
                'longitude' => $validated['longitude'] ?? null,
                'kapasitas' => $validated['kapasitas'],
                'alamat_gmaps' => $validated['alamat_gmaps'] ?? null,
                'has_slot_reservation_enabled' => $validated['has_slot_reservation_enabled'] ?? false,
                'status' => 'active',
            ]);

            // Create admin if provided
            if ($request->filled('admin_email') && $request->filled('admin_password')) {
                $user = User::create([
                    'name' => $validated['admin_name'] ?? 'Admin ' . $mall->nama_mall,
                    'email' => $validated['admin_email'],
                    'password' => \Hash::make($validated['admin_password']),
                    'no_hp' => $validated['admin_phone'] ?? null,
                    'role' => 'admin_mall',
                    'status' => 'aktif',
                ]);

                AdminMall::create([
                    'id_user' => $user->id_user,
                    'id_mall' => $mall->id_mall,
                    'hak_akses' => 'full',
                ]);
            }

            \DB::commit();
            return redirect()->route('superadmin.mall')->with('success', 'Mall berhasil ditambahkan');
        } catch (\Exception $e) {
            \DB::rollBack();
            return back()->withErrors(['error' => 'Gagal menambahkan mall: ' . $e->getMessage()])->withInput();
        }
    }

    public function detailMall($id)
    {
        $mall = Mall::with(['adminMall.user', 'parkiran', 'transaksiParkir', 'tarifParkir'])->findOrFail($id);
        return view('superadmin.super-detail-mall', compact('mall'));
    }

    public function editMall($id)
    {
        $mall = Mall::with(['adminMall.user', 'parkiran'])->findOrFail($id);
        return view('superadmin.super-edit-mall', compact('mall'));
    }

    public function updateMall(Request $request, $id)
    {
        $mall = Mall::findOrFail($id);
        
        $validated = $request->validate([
            'nama_mall' => 'required|string|max:255',
            'alamat_lengkap' => 'required|string|max:255',
            'latitude' => 'nullable|numeric|between:-90,90',
            'longitude' => 'nullable|numeric|between:-180,180',
            'kapasitas' => 'required|integer|min:1',
            'alamat_gmaps' => 'nullable|string',
            'has_slot_reservation_enabled' => 'nullable|boolean',
        ]);

        $mall->update([
            'nama_mall' => $validated['nama_mall'],
            'alamat_lengkap' => $validated['alamat_lengkap'],
            'latitude' => $validated['latitude'] ?? $mall->latitude,
            'longitude' => $validated['longitude'] ?? $mall->longitude,
            'kapasitas' => $validated['kapasitas'],
            'alamat_gmaps' => $validated['alamat_gmaps'] ?? null,
            'has_slot_reservation_enabled' => $validated['has_slot_reservation_enabled'] ?? false,
        ]);

        return redirect()->route('superadmin.mall.detail', $mall->id_mall)->with('success', 'Mall berhasil diperbarui');
    }

    public function deleteMall($id)
    {
        \DB::beginTransaction();
        try {
            $mall = Mall::findOrFail($id);
            
            // Check if mall has active transactions
            if ($mall->transaksiParkir()->whereNull('waktu_keluar')->count() > 0) {
                return response()->json([
                    'success' => false,
                    'message' => 'Tidak dapat menghapus mall dengan transaksi aktif'
                ], 400);
            }
            
            // Delete related data
            $mall->adminMall()->delete();
            $mall->parkiran()->delete();
            $mall->tarifParkir()->delete();
            $mall->delete();
            
            \DB::commit();
            return response()->json([
                'success' => true,
                'message' => 'Mall berhasil dihapus'
            ]);
        } catch (\Exception $e) {
            \DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Gagal menghapus mall: ' . $e->getMessage()
            ], 500);
        }
    }

    public function pengajuan()
    {
        $requests = User::where('application_status', 'pending')
            ->whereNotNull('applied_at')
            ->orderBy('applied_at', 'desc')
            ->get();
        
        return view('superadmin.pengajuan', compact('requests'));
    }

    public function detailPengajuan($id)
    {
        $request = User::findOrFail($id);
        return view('superadmin.pengajuan-detail', compact('request'));
    }

    public function approvePengajuan(Request $request, $id)
    {
        DB::beginTransaction();
        try {
            $user = User::findOrFail($id);
            
            // Validasi status pending
            if ($user->application_status !== 'pending') {
                if ($request->expectsJson()) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Pengajuan ini sudah diproses sebelumnya.'
                    ], 400);
                }
                return back()->withErrors(['error' => 'Pengajuan ini sudah diproses sebelumnya.']);
            }
            
            // Parse application notes untuk mendapatkan koordinat dan foto
            $applicationNotes = json_decode($user->application_notes, true) ?? [];
            $latitude = $applicationNotes['latitude'] ?? null;
            $longitude = $applicationNotes['longitude'] ?? null;
            $photoPath = $applicationNotes['photo_path'] ?? null;
            
            // Set default coordinates if not provided (Jakarta center)
            if (empty($latitude) || empty($longitude)) {
                $latitude = -6.2088;
                $longitude = 106.8456;
                \Log::warning('No coordinates provided for mall, using default Jakarta coordinates', [
                    'user_id' => $user->id_user,
                    'mall_name' => $user->requested_mall_name
                ]);
            }
            
            // Generate Google Maps URL
            $googleMapsUrl = null;
            if ($latitude && $longitude) {
                $googleMapsUrl = Mall::generateGoogleMapsUrl($latitude, $longitude);
            }
            
            // 1. Buat Mall baru dengan koordinat lengkap
            $mall = Mall::create([
                'nama_mall' => $user->requested_mall_name,
                'alamat_lengkap' => $user->requested_mall_location,
                'latitude' => $latitude,
                'longitude' => $longitude,
                'google_maps_url' => $googleMapsUrl,
                'status' => 'active',
                'kapasitas' => 100,  // Default capacity
                'has_slot_reservation_enabled' => false,
            ]);
            
            // Skip coordinate validation - coordinates are optional or use default
            // Mall can be updated with correct coordinates later by admin
            
            // 2. Update user menjadi admin_mall
            $user->update([
                'role' => 'admin_mall',
                'status' => 'aktif',
                'application_status' => 'approved',
                'reviewed_at' => now(),
                'reviewed_by' => Auth::id(),
            ]);
            
            // 3. Buat entry di admin_mall (link user dengan mall)
            AdminMall::create([
                'id_user' => $user->id_user,
                'id_mall' => $mall->id_mall,
                'hak_akses' => 'full',
            ]);
            
            DB::commit();
            
            \Log::info('Mall approved successfully', [
                'mall_id' => $mall->id_mall,
                'mall_name' => $mall->nama_mall,
                'user_id' => $user->id_user,
                'coordinates' => [
                    'lat' => $mall->latitude,
                    'lng' => $mall->longitude
                ],
                'photo_path' => $photoPath
            ]);
            
            if ($request->expectsJson()) {
                return response()->json([
                    'success' => true,
                    'message' => 'Pengajuan berhasil disetujui',
                    'data' => [
                        'mall_id' => $mall->id_mall,
                        'mall_name' => $mall->nama_mall,
                        'status' => $mall->status,
                        'google_maps_url' => $mall->google_maps_url
                    ]
                ]);
            }
            
            return redirect()->route('superadmin.pengajuan')
                ->with('success', 'Pengajuan berhasil disetujui. Mall telah ditambahkan dan siap digunakan di aplikasi mobile.');
                
        } catch (\Exception $e) {
            DB::rollBack();
            \Log::error('Error approving application', [
                'error' => $e->getMessage(),
                'user_id' => $id,
                'trace' => $e->getTraceAsString()
            ]);
            
            if ($request->expectsJson()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Terjadi kesalahan: ' . $e->getMessage()
                ], 500);
            }
            
            return back()->withErrors(['error' => 'Gagal menyetujui pengajuan: ' . $e->getMessage()]);
        }
    }

    public function rejectPengajuan($id)
    {
        $user = User::findOrFail($id);
        $user->status = 'rejected';
        $user->save();

        return redirect()->route('superadmin.pengajuan')->with('success', 'Pengajuan ditolak');
    }

    public function laporan()
    {
        // KPI Data
        $totalTransactions = TransaksiParkir::count();
        $totalRevenue = TransaksiParkir::whereNotNull('biaya')->sum('biaya');
        $averagePerMall = Mall::count() > 0 ? $totalRevenue / Mall::count() : 0;
        
        // Active Users (customers with transactions in last 30 days)
        $activeUsers = User::where('role', 'customer')
            ->whereHas('transaksiParkir', function($q) {
                $q->where('waktu_masuk', '>=', Carbon::now()->subDays(30));
            })
            ->count();
        
        // Average parking duration
        $avgParkingDuration = TransaksiParkir::whereNotNull('waktu_keluar')
            ->whereNotNull('waktu_masuk')
            ->selectRaw('AVG(TIMESTAMPDIFF(MINUTE, waktu_masuk, waktu_keluar)) as avg_minutes')
            ->value('avg_minutes');
        $avgParkingHours = $avgParkingDuration ? round($avgParkingDuration / 60, 1) : 0;
        
        // Growth calculations (last 30 days vs previous 30 days)
        $currentPeriodRevenue = TransaksiParkir::whereNotNull('biaya')
            ->where('waktu_masuk', '>=', Carbon::now()->subDays(30))
            ->sum('biaya');
        $previousPeriodRevenue = TransaksiParkir::whereNotNull('biaya')
            ->whereBetween('waktu_masuk', [Carbon::now()->subDays(60), Carbon::now()->subDays(30)])
            ->sum('biaya');
        $revenueGrowth = $previousPeriodRevenue > 0 
            ? round((($currentPeriodRevenue - $previousPeriodRevenue) / $previousPeriodRevenue) * 100, 1) 
            : 0;
        
        $currentPeriodTransactions = TransaksiParkir::where('waktu_masuk', '>=', Carbon::now()->subDays(30))->count();
        $previousPeriodTransactions = TransaksiParkir::whereBetween('waktu_masuk', [Carbon::now()->subDays(60), Carbon::now()->subDays(30)])->count();
        $transactionGrowth = $previousPeriodTransactions > 0 
            ? round((($currentPeriodTransactions - $previousPeriodTransactions) / $previousPeriodTransactions) * 100, 1) 
            : 0;
        
        $currentPeriodUsers = User::where('role', 'customer')
            ->where('created_at', '>=', Carbon::now()->subDays(30))
            ->count();
        $previousPeriodUsers = User::where('role', 'customer')
            ->whereBetween('created_at', [Carbon::now()->subDays(60), Carbon::now()->subDays(30)])
            ->count();
        $userGrowth = $previousPeriodUsers > 0 
            ? round((($currentPeriodUsers - $previousPeriodUsers) / $previousPeriodUsers) * 100, 1) 
            : 0;
        
        // Mall Performance with ranking
        $mallPerformance = Mall::select('mall.*')
            ->leftJoin('transaksi_parkir', 'mall.id_mall', '=', 'transaksi_parkir.id_mall')
            ->selectRaw('mall.*, 
                COALESCE(SUM(transaksi_parkir.biaya), 0) as total_revenue,
                COUNT(transaksi_parkir.id_transaksi) as total_transactions')
            ->groupBy('mall.id_mall', 'mall.nama_mall', 'mall.lokasi', 'mall.kapasitas', 'mall.alamat_gmaps', 'mall.has_slot_reservation_enabled', 'mall.created_at', 'mall.updated_at')
            ->orderBy('total_revenue', 'DESC')
            ->get()
            ->map(function($mall, $index) {
                // Calculate growth for each mall
                $currentRevenue = TransaksiParkir::where('id_mall', $mall->id_mall)
                    ->whereNotNull('biaya')
                    ->where('waktu_masuk', '>=', Carbon::now()->subDays(30))
                    ->sum('biaya');
                $previousRevenue = TransaksiParkir::where('id_mall', $mall->id_mall)
                    ->whereNotNull('biaya')
                    ->whereBetween('waktu_masuk', [Carbon::now()->subDays(60), Carbon::now()->subDays(30)])
                    ->sum('biaya');
                
                $growth = $previousRevenue > 0 
                    ? round((($currentRevenue - $previousRevenue) / $previousRevenue) * 100, 1) 
                    : 0;
                
                return (object)[
                    'id_mall' => $mall->id_mall,
                    'nama_mall' => $mall->nama_mall,
                    'total_revenue' => $mall->total_revenue,
                    'total_transactions' => $mall->total_transactions,
                    'growth' => $growth,
                    'ranking' => $index + 1,
                    'rating' => rand(40, 50) / 10 // Mock rating for now
                ];
            });
        
        // Chart data for last 7 days
        $chartData = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = Carbon::now()->subDays($i);
            $revenue = TransaksiParkir::whereNotNull('biaya')
                ->whereDate('waktu_masuk', $date)
                ->sum('biaya');
            $transactions = TransaksiParkir::whereDate('waktu_masuk', $date)->count();
            
            $chartData[] = [
                'date' => $date->format('Y-m-d'),
                'revenue' => $revenue,
                'transactions' => $transactions
            ];
        }

        return view('superadmin.laporan', compact(
            'totalTransactions',
            'totalRevenue',
            'averagePerMall',
            'activeUsers',
            'avgParkingHours',
            'revenueGrowth',
            'transactionGrowth',
            'userGrowth',
            'mallPerformance',
            'chartData'
        ));
    }
}
