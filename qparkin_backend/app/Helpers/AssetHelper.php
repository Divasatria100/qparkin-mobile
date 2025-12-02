<?php

if (!function_exists('asset_version')) {
    function asset_version($path)
    {
        $fullPath = public_path($path);
        $version = file_exists($fullPath) ? filemtime($fullPath) : time();
        return asset($path) . '?v=' . $version;
    }
}
