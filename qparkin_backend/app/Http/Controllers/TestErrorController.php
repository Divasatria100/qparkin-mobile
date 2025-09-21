<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class TestErrorController extends Controller
{
    public function show($code)
    {
        $validCodes = [403, 404, 419, 429, 500, 503];
        
        if (!in_array($code, $validCodes)) {
            return abort(404);
        }
        
        return response()->view("errors.{$code}", [], $code);
    }
    
    public function maintenance()
    {
        return response()->view('errors.offline', [], 503);
    }
}