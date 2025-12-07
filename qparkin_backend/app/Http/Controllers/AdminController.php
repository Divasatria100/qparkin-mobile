<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\TransaksiParkir;
use App\Models\Mall;
use App\Models\Parkiran;
use App\Models\AdminMall;
use App\Models\User;

class AdminController extends Controller
{
    public function dashboard()
    {
        $user = Auth::user();
        if (!$user) {
            abort(403, 'Unauthorized.');
        }

        // cek apakah user adalah admin mall (method jika ada, fallback ke role)
        $isAdmin = false;
        if (method_exists($user, 'isAdminMall')) {
            $isAdmin = (bool) $user->isAdminMall();
        } else {
            $isAdmin = (isset($user->role) && $user->role === 'admin_mall');
        }

        if (! $isAdmin) {
            abort(403, 'Unauthorized access.');
        }

        // dapatkan id user secara fleksibel
        $userId = $user->id_user ?? $user->id ?? null;

        // ambil admin_mall - pakai relasi jika ada, fallback query manual
        $adminMall = $user->adminMall ?? AdminMall::where('id_user', $userId)->first();

        if (! $adminMall) {
            abort(404, 'Admin mall data not found.');
        }

        $mall = Mall::find($adminMall->id_mall);
        if (! $mall) {
            abort(404, 'Mall not found.');
        }

        $mallId = $mall->id_mall;

        // Transaksi / pendapatan
        $pendapatanHarian = TransaksiParkir::where('id_mall', $mallId)
            ->whereDate('waktu_keluar', today())
            ->sum('biaya');

        $pendapatanMingguan = TransaksiParkir::where('id_mall', $mallId)
            ->whereBetween('waktu_keluar', [now()->startOfWeek(), now()->endOfWeek()])
            ->sum('biaya');

        $pendapatanBulanan = TransaksiParkir::where('id_mall', $mallId)
            ->whereMonth('waktu_keluar', now()->month)
            ->whereYear('waktu_keluar', now()->year)
            ->sum('biaya');

        // Counts kendaraan
        $transaksiHariIni = TransaksiParkir::where('id_mall', $mallId)
            ->whereDate('waktu_masuk', today())
            ->count();

        $masuk = $transaksiHariIni;
        $keluar = TransaksiParkir::where('id_mall', $mallId)
            ->whereDate('waktu_keluar', today())
            ->count();

        $aktif = TransaksiParkir::where('id_mall', $mallId)
            ->whereNull('waktu_keluar')
            ->count();

        // Kapasitas / slot tersisa
        $parkiranTersedia = Parkiran::where('id_mall', $mallId)->sum('kapasitas');
        $kapasitasTersisa = $parkiranTersedia;

        // Transaksi terbaru (5)
        $transaksiTerbaru = TransaksiParkir::with('kendaraan')
            ->where('id_mall', $mallId)
            ->orderBy('id_transaksi', 'DESC')
            ->limit(5)
            ->get();

        // Notifikasi (safe: hanya jika model Notifikasi ada)
        $notifBelumDibaca = 0;
        if (class_exists(\App\Models\Notifikasi::class)) {
            $notifBelumDibaca = \App\Models\Notifikasi::where('id_user', $userId)
                ->where('status', 'belum')
                ->count();
        }

        return view('admin.dashboard', compact(
            'mall',
            'pendapatanHarian',
            'pendapatanMingguan',
            'pendapatanBulanan',
            'transaksiHariIni',
            'masuk',
            'keluar',
            'aktif',
            'parkiranTersedia',
            'kapasitasTersisa',
            'transaksiTerbaru',
            'notifBelumDibaca'
        ));
    }
    public function profile()
    {
        $user = Auth::user();
        $userId = $user->id_user ?? $user->id ?? null;
        
        // Load relasi adminMall dan mall
        if (!isset($user->adminMall)) {
            $user->load('adminMall.mall');
        }
        
        return view('admin.profile', compact('user'));
    }

    public function editProfile()
    {
        $user = Auth::user();
        $userId = $user->id_user ?? $user->id ?? null;
        
        // Load relasi adminMall dan mall
        if (!isset($user->adminMall)) {
            $user->load('adminMall.mall');
        }
        
        return view('admin.edit-informasi', compact('user'));
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

        return redirect()->route('admin.profile')->with('success', 'Profil berhasil diperbarui');
    }

    public function editPhoto()
    {
        $user = Auth::user();
        return view('admin.ubah-foto', compact('user'));
    }

    public function editSecurity()
    {
        $user = Auth::user();
        return view('admin.ubah-keamanan', compact('user'));
    }

    public function notifikasi(Request $request)
    {
        $user = Auth::user();
        $userId = $user->id_user ?? $user->id;
        
        $category = $request->get('category', 'all');
        $notifications = collect([]);
        $unreadCount = 0;
        
        try {
            // Check if table exists
            if (\Schema::hasTable('notifikasi')) {
                // Query notifikasi dengan filter kategori
                $query = \App\Models\Notifikasi::where('id_user', $userId)
                    ->orderBy('created_at', 'DESC');
                
                if ($category && $category !== 'all') {
                    $query->where('kategori', $category);
                }
                
                $notifications = $query->get();
                $unreadCount = \App\Models\Notifikasi::where('id_user', $userId)
                    ->where('status', 'belum')
                    ->count();
            }
        } catch (\Exception $e) {
            \Log::error('Notifikasi error: ' . $e->getMessage());
        }
        
        return view('admin.notifikasi', compact('notifications', 'unreadCount', 'category'));
    }

    public function markNotificationAsRead($id)
    {
        $notification = \App\Models\Notifikasi::findOrFail($id);
        $notification->markAsRead();
        
        return response()->json(['success' => true]);
    }

    public function markAllNotificationsAsRead()
    {
        $user = Auth::user();
        $userId = $user->id_user ?? $user->id;
        
        \App\Models\Notifikasi::where('id_user', $userId)
            ->where('status', 'belum')
            ->update([
                'status' => 'sudah',
                'dibaca_pada' => now()
            ]);
        
        return response()->json(['success' => true]);
    }

    public function deleteNotification($id)
    {
        $notification = \App\Models\Notifikasi::findOrFail($id);
        $notification->delete();
        
        return response()->json(['success' => true]);
    }

    public function clearAllNotifications()
    {
        $user = Auth::user();
        $userId = $user->id_user ?? $user->id;
        
        \App\Models\Notifikasi::where('id_user', $userId)->delete();
        
        return response()->json(['success' => true]);
    }

    public function tiket()
    {
        $user = Auth::user();
        $userId = $user->id_user ?? $user->id ?? null;
        $adminMall = $user->adminMall ?? AdminMall::where('id_user', $userId)->first();
        
        if (!$adminMall) {
            abort(404, 'Admin mall data not found.');
        }

        $tickets = TransaksiParkir::where('id_mall', $adminMall->id_mall)
            ->with('kendaraan')
            ->orderBy('id_transaksi', 'DESC')
            ->paginate(20);

        return view('admin.tiket', compact('tickets'));
    }

    public function tiketDetail($id)
    {
        $ticket = TransaksiParkir::with('kendaraan')->findOrFail($id);
        return view('admin.detail-tiket', compact('ticket'));
    }

    public function tarif()
    {
        $user = Auth::user();
        $userId = $user->id_user ?? $user->id ?? null;
        $adminMall = $user->adminMall ?? AdminMall::where('id_user', $userId)->first();
        
        if (!$adminMall) {
            abort(404, 'Admin mall data not found.');
        }

        $tariffs = \App\Models\Tarif::where('id_mall', $adminMall->id_mall)->get();
        return view('admin.tarif', compact('tariffs'));
    }

    public function editTarif($id)
    {
        $tariff = \App\Models\Tarif::findOrFail($id);
        return view('admin.edit-tarif', compact('tariff'));
    }

    public function updateTarif(Request $request, $id)
    {
        // Logic untuk update tarif
        return redirect()->route('admin.tarif')->with('success', 'Tarif updated successfully');
    }

    public function parkiran()
    {
        $user = Auth::user();
        $userId = $user->id_user ?? $user->id ?? null;
        $adminMall = $user->adminMall ?? AdminMall::where('id_user', $userId)->first();
        
        if (!$adminMall) {
            abort(404, 'Admin mall data not found.');
        }

        $parkingAreas = Parkiran::where('id_mall', $adminMall->id_mall)->get();
        return view('admin.parkiran', compact('parkingAreas'));
    }

    public function createParkiran()
    {
        return view('admin.tambah-parkiran');
    }

    public function detailParkiran($id)
    {
        $parkiran = Parkiran::findOrFail($id);
        return view('admin.detail-parkiran', compact('parkiran'));
    }

    public function editParkiran($id)
    {
        $parkiran = Parkiran::findOrFail($id);
        return view('admin.edit-parkiran', compact('parkiran'));
    }
}
