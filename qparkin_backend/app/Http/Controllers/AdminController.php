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
}
