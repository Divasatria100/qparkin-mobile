<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\TransaksiParkir;
use App\Models\Mall;
use App\Models\Parkiran;
use App\Models\ParkingFloor;
use App\Models\ParkingSlot;
use App\Models\AdminMall;
use App\Models\User;
use App\Models\TarifParkir;
use App\Models\RiwayatTarif;

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
            // Admin belum memiliki mall, redirect ke halaman setup
            return redirect()->route('admin.profile.edit')
                ->with('warning', 'Silakan lengkapi data mall Anda terlebih dahulu.');
        }

        $mall = Mall::find($adminMall->id_mall);
        if (! $mall) {
            // Mall tidak ditemukan, redirect ke halaman setup
            return redirect()->route('admin.profile.edit')
                ->with('error', 'Data mall tidak ditemukan. Silakan hubungi administrator.');
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

    public function tiket(Request $request)
    {
        $user = Auth::user();
        $userId = $user->id_user ?? $user->id ?? null;
        $adminMall = $user->adminMall ?? AdminMall::where('id_user', $userId)->first();
        
        if (!$adminMall) {
            abort(404, 'Admin mall data not found.');
        }

        $query = TransaksiParkir::where('id_mall', $adminMall->id_mall)
            ->with(['kendaraan.customer']);

        // Filter by status
        if ($request->has('status')) {
            if ($request->status === 'sedang_parkir') {
                $query->whereNull('waktu_keluar');
            } elseif ($request->status === 'selesai') {
                $query->whereNotNull('waktu_keluar');
            }
        }

        // Filter by date range
        if ($request->has('start_date') && $request->has('end_date')) {
            $query->whereBetween('waktu_masuk', [
                $request->start_date . ' 00:00:00',
                $request->end_date . ' 23:59:59'
            ]);
        }

        // Search
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('id_transaksi', 'like', "%{$search}%")
                  ->orWhereHas('kendaraan', function($q2) use ($search) {
                      $q2->where('plat_nomor', 'like', "%{$search}%")
                         ->orWhere('jenis_kendaraan', 'like', "%{$search}%");
                  });
            });
        }

        $tickets = $query->orderBy('id_transaksi', 'DESC')->paginate(20);

        // Export to Excel
        if ($request->has('export') && $request->export === 'excel') {
            return $this->exportTicketsToExcel($query->get());
        }

        return view('admin.tiket', compact('tickets'));
    }

    private function exportTicketsToExcel($tickets)
    {
        $filename = 'tiket_' . date('Y-m-d_His') . '.csv';
        
        header('Content-Type: text/csv');
        header('Content-Disposition: attachment; filename="' . $filename . '"');
        
        $output = fopen('php://output', 'w');
        
        // Header
        fputcsv($output, ['ID Transaksi', 'Plat Nomor', 'Jenis Kendaraan', 'Waktu Masuk', 'Waktu Keluar', 'Biaya', 'Status']);
        
        // Data
        foreach ($tickets as $ticket) {
            fputcsv($output, [
                $ticket->id_transaksi,
                $ticket->kendaraan->plat_nomor ?? '-',
                $ticket->kendaraan->jenis_kendaraan ?? '-',
                $ticket->waktu_masuk,
                $ticket->waktu_keluar ?? '-',
                $ticket->biaya ?? 0,
                $ticket->waktu_keluar ? 'Selesai' : 'Sedang Parkir'
            ]);
        }
        
        fclose($output);
        exit;
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

        $tarifs = TarifParkir::where('id_mall', $adminMall->id_mall)->get();
        
        // Get riwayat perubahan tarif
        $riwayat = collect([]);
        try {
            if (\Schema::hasTable('riwayat_tarif')) {
                $riwayat = RiwayatTarif::with('user')
                    ->where('id_mall', $adminMall->id_mall)
                    ->orderBy('created_at', 'DESC')
                    ->limit(10)
                    ->get();
            }
        } catch (\Exception $e) {
            \Log::error('Riwayat tarif error: ' . $e->getMessage());
        }
        
        return view('admin.tarif', compact('tarifs', 'riwayat'));
    }

    public function editTarif($id)
    {
        $tariff = TarifParkir::findOrFail($id);
        return view('admin.edit-tarif', compact('tariff'));
    }

    public function updateTarif(Request $request, $id)
    {
        $request->validate([
            'satu_jam_pertama' => 'required|numeric|min:0',
            'tarif_parkir_per_jam' => 'required|numeric|min:0',
        ]);

        $tarif = TarifParkir::findOrFail($id);
        $user = Auth::user();
        
        // Simpan riwayat perubahan
        RiwayatTarif::create([
            'id_tarif' => $tarif->id_tarif,
            'id_mall' => $tarif->id_mall,
            'id_user' => $user->id_user ?? $user->id ?? null,
            'jenis_kendaraan' => $tarif->jenis_kendaraan,
            'tarif_lama_jam_pertama' => $tarif->satu_jam_pertama,
            'tarif_lama_per_jam' => $tarif->tarif_parkir_per_jam,
            'tarif_baru_jam_pertama' => $request->satu_jam_pertama,
            'tarif_baru_per_jam' => $request->tarif_parkir_per_jam,
            'keterangan' => 'Perubahan tarif oleh admin',
        ]);
        
        // Update tarif
        $tarif->update([
            'satu_jam_pertama' => $request->satu_jam_pertama,
            'tarif_parkir_per_jam' => $request->tarif_parkir_per_jam,
        ]);

        return redirect()->route('admin.tarif')->with('success', 'Tarif berhasil diperbarui');
    }

    public function parkiran()
    {
        $user = Auth::user();
        $userId = $user->id_user ?? $user->id ?? null;
        $adminMall = $user->adminMall ?? AdminMall::where('id_user', $userId)->first();
        
        if (!$adminMall) {
            abort(404, 'Admin mall data not found.');
        }

        $parkingAreas = Parkiran::with('floors.slots')
            ->where('id_mall', $adminMall->id_mall)
            ->get()
            ->map(function($parkiran) {
                $parkiran->total_available = $parkiran->floors->sum('available_slots');
                $parkiran->total_occupied = $parkiran->kapasitas - $parkiran->total_available;
                return $parkiran;
            });
        
        return view('admin.parkiran', compact('parkingAreas'));
    }

    public function createParkiran()
    {
        return view('admin.tambah-parkiran');
    }

    public function storeParkiran(Request $request)
    {
        $user = Auth::user();
        $userId = $user->id_user ?? $user->id ?? null;
        $adminMall = $user->adminMall ?? AdminMall::where('id_user', $userId)->first();
        
        if (!$adminMall) {
            return response()->json(['success' => false, 'message' => 'Admin mall data not found.'], 404);
        }

        $validated = $request->validate([
            'nama_parkiran' => 'required|string|max:255',
            'kode_parkiran' => 'required|string|max:10',
            'status' => 'required|in:Tersedia,Ditutup',
            'jumlah_lantai' => 'required|integer|min:1|max:10',
            'lantai' => 'required|array',
            'lantai.*.nama' => 'required|string',
            'lantai.*.jumlah_slot' => 'required|integer|min:1',
            'lantai.*.jenis_kendaraan' => 'required|in:Roda Dua,Roda Tiga,Roda Empat,Lebih dari Enam',
            'lantai.*.status' => 'nullable|in:active,maintenance,inactive',
        ]);

        \DB::beginTransaction();
        try {
            // Calculate total capacity
            $totalKapasitas = collect($validated['lantai'])->sum('jumlah_slot');

            // Create parkiran
            $parkiran = Parkiran::create([
                'id_mall' => $adminMall->id_mall,
                'nama_parkiran' => $validated['nama_parkiran'],
                'kode_parkiran' => $validated['kode_parkiran'],
                'status' => $validated['status'],
                'jumlah_lantai' => $validated['jumlah_lantai'],
                'kapasitas' => $totalKapasitas,
            ]);

            // Create floors and slots
            foreach ($validated['lantai'] as $index => $lantaiData) {
                $floorStatus = $lantaiData['status'] ?? 'active';
                $jenisKendaraan = $lantaiData['jenis_kendaraan'];
                
                $floor = ParkingFloor::create([
                    'id_parkiran' => $parkiran->id_parkiran,
                    'floor_name' => $lantaiData['nama'],
                    'floor_number' => $index + 1,
                    'jenis_kendaraan' => $jenisKendaraan,
                    'total_slots' => $lantaiData['jumlah_slot'],
                    'available_slots' => $lantaiData['jumlah_slot'],
                    'status' => $floorStatus,
                ]);

                // Create slots for this floor
                for ($i = 1; $i <= $lantaiData['jumlah_slot']; $i++) {
                    ParkingSlot::create([
                        'id_floor' => $floor->id_floor,
                        'slot_code' => $validated['kode_parkiran'] . '-L' . ($index + 1) . '-' . str_pad($i, 3, '0', STR_PAD_LEFT),
                        'jenis_kendaraan' => $jenisKendaraan,
                        'status' => 'available',
                        'position_x' => $i,
                        'position_y' => $index + 1,
                    ]);
                }
            }

            \DB::commit();
            return response()->json(['success' => true, 'message' => 'Parkiran berhasil ditambahkan']);
        } catch (\Exception $e) {
            \DB::rollBack();
            return response()->json(['success' => false, 'message' => 'Gagal menambahkan parkiran: ' . $e->getMessage()], 500);
        }
    }

    public function detailParkiran($id)
    {
        $parkiran = Parkiran::with(['floors.slots'])->findOrFail($id);
        
        // Calculate statistics
        $parkiran->total_available = $parkiran->floors->sum('available_slots');
        $parkiran->total_occupied = $parkiran->kapasitas - $parkiran->total_available;
        $parkiran->utilization = $parkiran->kapasitas > 0 ? round(($parkiran->total_occupied / $parkiran->kapasitas) * 100, 2) : 0;
        
        return view('admin.detail-parkiran', compact('parkiran'));
    }

    public function editParkiran($id)
    {
        $parkiran = Parkiran::with('floors')->findOrFail($id);
        return view('admin.edit-parkiran', compact('parkiran'));
    }

    public function updateParkiran(Request $request, $id)
    {
        $validated = $request->validate([
            'nama_parkiran' => 'required|string|max:255',
            'kode_parkiran' => 'required|string|max:10',
            'status' => 'required|in:Tersedia,Ditutup',
            'jumlah_lantai' => 'required|integer|min:1|max:10',
            'lantai' => 'required|array',
            'lantai.*.nama' => 'required|string',
            'lantai.*.jumlah_slot' => 'required|integer|min:1',
            'lantai.*.jenis_kendaraan' => 'required|in:Roda Dua,Roda Tiga,Roda Empat,Lebih dari Enam',
            'lantai.*.status' => 'nullable|in:active,maintenance,inactive',
        ]);

        \DB::beginTransaction();
        try {
            $parkiran = Parkiran::findOrFail($id);
            
            // Calculate total capacity
            $totalKapasitas = collect($validated['lantai'])->sum('jumlah_slot');

            // Update parkiran
            $parkiran->update([
                'nama_parkiran' => $validated['nama_parkiran'],
                'kode_parkiran' => $validated['kode_parkiran'],
                'status' => $validated['status'],
                'jumlah_lantai' => $validated['jumlah_lantai'],
                'kapasitas' => $totalKapasitas,
            ]);

            // Delete old floors and slots
            foreach ($parkiran->floors as $floor) {
                $floor->slots()->delete();
                $floor->delete();
            }

            // Create new floors and slots
            foreach ($validated['lantai'] as $index => $lantaiData) {
                $floorStatus = $lantaiData['status'] ?? 'active';
                $jenisKendaraan = $lantaiData['jenis_kendaraan'];
                
                $floor = ParkingFloor::create([
                    'id_parkiran' => $parkiran->id_parkiran,
                    'floor_name' => $lantaiData['nama'],
                    'floor_number' => $index + 1,
                    'jenis_kendaraan' => $jenisKendaraan,
                    'total_slots' => $lantaiData['jumlah_slot'],
                    'available_slots' => $lantaiData['jumlah_slot'],
                    'status' => $floorStatus,
                ]);

                // Create slots
                for ($i = 1; $i <= $lantaiData['jumlah_slot']; $i++) {
                    ParkingSlot::create([
                        'id_floor' => $floor->id_floor,
                        'slot_code' => $validated['kode_parkiran'] . '-L' . ($index + 1) . '-' . str_pad($i, 3, '0', STR_PAD_LEFT),
                        'jenis_kendaraan' => $jenisKendaraan,
                        'status' => 'available',
                        'position_x' => $i,
                        'position_y' => $index + 1,
                    ]);
                }
            }

            \DB::commit();
            return response()->json(['success' => true, 'message' => 'Parkiran berhasil diperbarui']);
        } catch (\Exception $e) {
            \DB::rollBack();
            return response()->json(['success' => false, 'message' => 'Gagal memperbarui parkiran: ' . $e->getMessage()], 500);
        }
    }

    public function deleteParkiran($id)
    {
        \DB::beginTransaction();
        try {
            $parkiran = Parkiran::findOrFail($id);
            
            // Delete floors and slots
            foreach ($parkiran->floors as $floor) {
                $floor->slots()->delete();
                $floor->delete();
            }
            
            $parkiran->delete();
            
            \DB::commit();
            return response()->json(['success' => true, 'message' => 'Parkiran berhasil dihapus']);
        } catch (\Exception $e) {
            \DB::rollBack();
            return response()->json(['success' => false, 'message' => 'Gagal menghapus parkiran: ' . $e->getMessage()], 500);
        }
    }

    public function lokasiMall()
    {
        $user = Auth::user();
        $userId = $user->id_user ?? $user->id ?? null;
        $adminMall = $user->adminMall ?? AdminMall::where('id_user', $userId)->first();
        
        if (!$adminMall) {
            abort(404, 'Admin mall data not found.');
        }

        $mall = Mall::findOrFail($adminMall->id_mall);
        
        return view('admin.lokasi-mall', compact('mall'));
    }

    public function updateLokasiMall(Request $request)
    {
        $user = Auth::user();
        $userId = $user->id_user ?? $user->id ?? null;
        $adminMall = $user->adminMall ?? AdminMall::where('id_user', $userId)->first();
        
        if (!$adminMall) {
            return response()->json(['success' => false, 'message' => 'Admin mall data not found.'], 404);
        }

        $validated = $request->validate([
            'nama_mall' => 'required|string|max:100',
            'alamat_lengkap' => 'required|string|max:255',
            'google_maps_url' => 'nullable|url|max:500',
            'latitude' => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
        ]);

        try {
            $mall = Mall::findOrFail($adminMall->id_mall);
            
            // Update mall data
            $mall->nama_mall = $validated['nama_mall'];
            $mall->alamat_lengkap = $validated['alamat_lengkap'];
            $mall->latitude = $validated['latitude'];
            $mall->longitude = $validated['longitude'];
            
            // Update Google Maps URL if provided
            if (isset($validated['google_maps_url'])) {
                $mall->google_maps_url = $validated['google_maps_url'];
            }
            
            $mall->save();

            return response()->json([
                'success' => true, 
                'message' => 'Data mall berhasil diperbarui',
                'data' => [
                    'nama_mall' => $mall->nama_mall,
                    'alamat_lengkap' => $mall->alamat_lengkap,
                    'google_maps_url' => $mall->google_maps_url,
                    'latitude' => $mall->latitude,
                    'longitude' => $mall->longitude
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Gagal memperbarui data mall: ' . $e->getMessage()], 500);
        }
    }
}
