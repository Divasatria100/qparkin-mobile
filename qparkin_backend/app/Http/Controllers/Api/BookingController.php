<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class BookingController extends Controller
{
    public function index(Request $request)
    {
        return response()->json([
            'success' => true,
            'data' => []
        ]);
    }

    public function store(Request $request)
    {
        return response()->json([
            'success' => true,
            'message' => 'Booking created successfully'
        ], 201);
    }

    public function show($id)
    {
        return response()->json([
            'success' => true,
            'data' => []
        ]);
    }

    public function cancel($id)
    {
        return response()->json([
            'success' => true,
            'message' => 'Booking cancelled successfully'
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
