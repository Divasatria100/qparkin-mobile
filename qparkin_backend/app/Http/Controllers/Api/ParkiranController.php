<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class ParkiranController extends Controller
{
    public function checkAvailability($id)
    {
        return response()->json([
            'success' => true,
            'data' => [
                'available' => true,
                'slots' => 0
            ]
        ]);
    }
}
