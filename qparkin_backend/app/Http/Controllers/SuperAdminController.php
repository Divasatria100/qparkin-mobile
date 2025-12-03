<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Mall;
use App\Models\User;
use App\Models\TransaksiParkir;

class SuperAdminController extends Controller
{
    public function dashboard()
    {
        $totalMalls = Mall::count();
        $totalRevenue = TransaksiParkir::sum('biaya');
        $activeAdmins = User::where('role', 'admin_mall')->count();
        $pendingRequests = User::where('status', 'pending')->count();
        $todayTransactions = TransaksiParkir::whereDate('waktu_masuk', today())->count();
        $activeUsers = User::where('status', 'active')->count();

        $recentActivities = [];
        $topMalls = Mall::withCount('transaksiParkir')
            ->orderBy('transaksi_parkir_count', 'DESC')
            ->limit(5)
            ->get();

        return view('superadmin.dashboard', compact(
            'totalMalls',
            'totalRevenue',
            'activeAdmins',
            'pendingRequests',
            'todayTransactions',
            'activeUsers',
            'recentActivities',
            'topMalls'
        ));
    }

    public function profile()
    {
        return view('superadmin.profile');
    }

    public function editProfile()
    {
        return view('superadmin.super-edit-informasi');
    }

    public function editPhoto()
    {
        return view('superadmin.super-ubah-foto');
    }

    public function editSecurity()
    {
        return view('superadmin.super-ubah-keamanan');
    }

    public function mall()
    {
        $malls = Mall::with('adminMall.user')->get();
        return view('superadmin.mall', compact('malls'));
    }

    public function createMall()
    {
        return view('superadmin.super-tambah-mall');
    }

    public function detailMall($id)
    {
        $mall = Mall::with('adminMall.user', 'parkiran')->findOrFail($id);
        return view('superadmin.super-detail-mall', compact('mall'));
    }

    public function editMall($id)
    {
        $mall = Mall::findOrFail($id);
        return view('superadmin.super-edit-mall', compact('mall'));
    }

    public function pengajuan()
    {
        $requests = User::where('status', 'pending')->get();
        return view('superadmin.pengajuan', compact('requests'));
    }

    public function detailPengajuan($id)
    {
        $request = User::findOrFail($id);
        return view('superadmin.pengajuan-detail', compact('request'));
    }

    public function approvePengajuan($id)
    {
        $user = User::findOrFail($id);
        $user->status = 'approved';
        $user->save();

        return redirect()->route('superadmin.pengajuan')->with('success', 'Pengajuan disetujui');
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
        $totalTransactions = TransaksiParkir::count();
        $totalRevenue = TransaksiParkir::sum('biaya');
        $averagePerMall = Mall::count() > 0 ? $totalRevenue / Mall::count() : 0;

        $mallPerformance = Mall::withCount('transaksiParkir')
            ->withSum('transaksiParkir', 'biaya')
            ->orderBy('transaksi_parkir_sum_biaya', 'DESC')
            ->get();

        return view('superadmin.laporan', compact(
            'totalTransactions',
            'totalRevenue',
            'averagePerMall',
            'mallPerformance'
        ));
    }
}
