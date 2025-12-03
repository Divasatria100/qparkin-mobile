<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class TransaksiController extends Controller
{
    public function index(Request $request)
    {
        return response()->json([
            'success' => true,
            'data' => []
        ]);
    }

    public function masuk(Request $request)
    {
        return response()->json([
            'success' => true,
            'message' => 'Entry recorded successfully'
        ], 201);
    }

    public function keluar(Request $request)
    {
        return response()->json([
            'success' => true,
            'message' => 'Exit recorded successfully'
        ]);
    }

    public function show($id)
    {
        return response()->json([
            'success' => true,
            'data' => []
        ]);
    }

    public function getActive(Request $request)
    {
        return response()->json([
            'success' => true,
            'data' => []
        ]);
    }
}
