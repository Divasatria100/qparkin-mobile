<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\User;
use App\Models\Mall;
use App\Models\TransaksiParkir;

class SuperAdminController extends Controller
{
    public function dashboard()
    {
        /** @var User $user */
        $user = Auth::user();
        
        // Pastikan user adalah super admin
        if (!$user->isSuperAdmin()) {
            abort(403, 'Unauthorized access.');
        }
        
        $totalMall = Mall::count();
        $totalAdmin = User::where('role', 'admin_mall')->count();
        $totalCustomer = User::where('role', 'customer')->count();
        $transaksiHariIni = TransaksiParkir::whereDate('waktu_masuk', today())->count();
        
        return view('superadmin.dashboard', compact('totalMall', 'totalAdmin', 'totalCustomer', 'transaksiHariIni'));
    }
}