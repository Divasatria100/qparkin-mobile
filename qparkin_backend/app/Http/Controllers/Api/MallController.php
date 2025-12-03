<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class MallController extends Controller
{
    public function index()
    {
        return response()->json([
            'success' => true,
            'data' => []
        ]);
    }

    public function show($id)
    {
        return response()->json([
            'success' => true,
            'data' => []
        ]);
    }

    public function getParkiran($id)
    {
        return response()->json([
            'success' => true,
            'data' => []
        ]);
    }

    public function getTarif($id)
    {
        return response()->json([
            'success' => true,
            'data' => []
        ]);
    }
}
