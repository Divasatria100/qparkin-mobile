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

        // Pastikan user adalah admin mall
        if (!$user->isAdminMall()) {
            abort(403, 'Unauthorized access.');
        }

        $adminMall = $user->adminMall; // Pastikan relasi adminMall sudah didefinisikan di model User

        if (!$adminMall) {
            abort(404, 'Admin mall data not found.');
        }

        $mall = $adminMall->mall;

        $transaksiHariIni = \App\Models\TransaksiParkir::where('id_mall', $mall->id_mall)
            ->whereDate('waktu_masuk', today())
            ->count();

        $parkiranTersedia = \App\Models\Parkiran::where('id_mall', $mall->id_mall)
            ->sum('kapasitas');

        return view('admin.dashboard', compact('mall', 'transaksiHariIni', 'parkiranTersedia'));
    }
}