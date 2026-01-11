<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Mall;
use Illuminate\Http\Request;

class MallController extends Controller
{
    /**
     * Get all active malls with parking availability
     * 
     * Returns only malls with status = 'active'
     */
    public function index()
    {
        try {
            $malls = Mall::where('mall.status', 'active')  // ✅ Specify table name
                ->select([
                    'mall.id_mall',
                    'mall.nama_mall',
                    'mall.alamat_lengkap',
                    'mall.latitude',
                    'mall.longitude',
                    'mall.google_maps_url',
                    'mall.status',
                    'mall.kapasitas',
                    'mall.has_slot_reservation_enabled'
                ])
                ->leftJoin('parkiran', 'mall.id_mall', '=', 'parkiran.id_mall')
                ->leftJoin('parking_floors', 'parkiran.id_parkiran', '=', 'parking_floors.id_parkiran')
                ->selectRaw('COALESCE(SUM(parking_floors.available_slots), 0) as available_slots')
                ->where('parkiran.status', '=', 'Tersedia')
                ->groupBy(
                    'mall.id_mall',
                    'mall.nama_mall',
                    'mall.alamat_lengkap',
                    'mall.latitude',
                    'mall.longitude',
                    'mall.google_maps_url',
                    'mall.status',
                    'mall.kapasitas',
                    'mall.has_slot_reservation_enabled'
                )
                ->get()
                ->map(function ($mall) {
                    // Get tarif for this mall
                    $tarifs = \App\Models\TarifParkir::where('id_mall', $mall->id_mall)
                        ->select(['jenis_kendaraan', 'satu_jam_pertama', 'tarif_parkir_per_jam'])
                        ->get()
                        ->map(function($tarif) {
                            return [
                                'jenis_kendaraan' => $tarif->jenis_kendaraan,
                                'satu_jam_pertama' => (float) $tarif->satu_jam_pertama,
                                'tarif_parkir_per_jam' => (float) $tarif->tarif_parkir_per_jam,
                            ];
                        });

                    return [
                        'id_mall' => $mall->id_mall,
                        'nama_mall' => $mall->nama_mall,
                        'alamat_lengkap' => $mall->alamat_lengkap,
                        'latitude' => $mall->latitude ? (float) $mall->latitude : null,
                        'longitude' => $mall->longitude ? (float) $mall->longitude : null,
                        'google_maps_url' => $mall->google_maps_url,
                        'status' => $mall->status,
                        'kapasitas' => $mall->kapasitas,
                        'available_slots' => (int) $mall->available_slots,
                        'has_slot_reservation_enabled' => (bool) $mall->has_slot_reservation_enabled,
                        'tarif' => $tarifs,
                    ];
                });

            return response()->json([
                'success' => true,
                'message' => 'Malls retrieved successfully',
                'data' => $malls
            ]);
        } catch (\Exception $e) {
            \Log::error('Error fetching malls: ' . $e->getMessage());
            \Log::error('Stack trace: ' . $e->getTraceAsString());
            
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch malls',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get single mall details
     */
    public function show($id)
    {
        try {
            $mall = Mall::where('status', 'active')->findOrFail($id);

            $availableSlots = $mall->parkiran()
                ->where('status', 'Tersedia')
                ->count();

            // Get tarif for this mall
            $tarifs = \App\Models\TarifParkir::where('id_mall', $id)
                ->select(['jenis_kendaraan', 'satu_jam_pertama', 'tarif_parkir_per_jam'])
                ->get()
                ->map(function($tarif) {
                    return [
                        'jenis_kendaraan' => $tarif->jenis_kendaraan,
                        'satu_jam_pertama' => (float) $tarif->satu_jam_pertama,
                        'tarif_parkir_per_jam' => (float) $tarif->tarif_parkir_per_jam,
                    ];
                });

            return response()->json([
                'success' => true,
                'message' => 'Mall details retrieved successfully',
                'data' => [
                    'id_mall' => $mall->id_mall,
                    'nama_mall' => $mall->nama_mall,
                    'alamat_lengkap' => $mall->alamat_lengkap,
                    'latitude' => $mall->latitude ? (float) $mall->latitude : null,
                    'longitude' => $mall->longitude ? (float) $mall->longitude : null,
                    'google_maps_url' => $mall->google_maps_url,
                    'status' => $mall->status,
                    'kapasitas' => $mall->kapasitas,
                    'available_slots' => $availableSlots,
                    'has_slot_reservation_enabled' => (bool) $mall->has_slot_reservation_enabled,
                    'parkiran' => $mall->parkiran,
                    'tarif' => $tarifs,
                ]
            ]);
        } catch (\Exception $e) {
            \Log::error('Error fetching mall details: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Mall not found',
                'error' => $e->getMessage()
            ], 404);
        }
    }

    public function getParkiran($id)
    {
        try {
            $mall = Mall::where('status', 'active')->findOrFail($id);
            $parkiran = $mall->parkiran()
                ->select(['id_parkiran', 'nama_parkiran', 'lantai', 'kapasitas', 'status'])
                ->get();

            return response()->json([
                'success' => true,
                'message' => 'Parking areas retrieved successfully',
                'data' => $parkiran
            ]);
        } catch (\Exception $e) {
            \Log::error('Error fetching parking areas: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch parking areas',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function getTarif($id)
    {
        try {
            $mall = Mall::where('status', 'active')->findOrFail($id);
            $tarif = $mall->tarifParkir()
                ->select(['id_tarif', 'jenis_kendaraan', 'tarif_per_jam', 'tarif_maksimal'])
                ->get();

            return response()->json([
                'success' => true,
                'message' => 'Parking rates retrieved successfully',
                'data' => $tarif
            ]);
        } catch (\Exception $e) {
            \Log::error('Error fetching parking rates: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch parking rates',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
