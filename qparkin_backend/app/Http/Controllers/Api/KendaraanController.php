<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Kendaraan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class KendaraanController extends Controller
{
    /**
     * Get all vehicles for authenticated user
     * Endpoint minimal sesuai kebutuhan parkir mall
     * 
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(Request $request)
    {
        try {
            $user = $request->user();
            
            $vehicles = Kendaraan::forUser($user->id_user)
                ->orderBy('is_active', 'desc')
                ->orderBy('created_at', 'desc')
                ->get();

            return response()->json([
                'success' => true,
                'message' => 'Vehicles retrieved successfully',
                'data' => $vehicles
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve vehicles',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Store a new vehicle
     * 
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(Request $request)
    {
        try {
            $user = $request->user();

            // Validation
            $validator = Validator::make($request->all(), [
                'plat_nomor' => 'required|string|max:20|unique:kendaraan,plat',
                'jenis_kendaraan' => 'required|in:Roda Dua,Roda Tiga,Roda Empat,Lebih dari Enam',
                'merk' => 'required|string|max:50',
                'tipe' => 'required|string|max:50',
                'warna' => 'nullable|string|max:50',
                'is_active' => 'boolean',
                'foto' => 'nullable|image|mimes:jpeg,png,jpg|max:2048', // Max 2MB
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            DB::beginTransaction();

            // If this vehicle is set as active, deactivate others
            if ($request->input('is_active', false)) {
                Kendaraan::forUser($user->id_user)->update(['is_active' => false]);
            }

            // Handle photo upload
            $fotoPath = null;
            if ($request->hasFile('foto')) {
                $file = $request->file('foto');
                $filename = time() . '_' . $user->id_user . '_' . $file->getClientOriginalName();
                $fotoPath = $file->storeAs('vehicles', $filename, 'public');
            }

            // Create vehicle - last_used_at akan null sampai digunakan parkir
            $vehicle = Kendaraan::create([
                'id_user' => $user->id_user,
                'plat' => strtoupper($request->plat_nomor),
                'jenis' => $request->jenis_kendaraan,
                'merk' => $request->merk,
                'tipe' => $request->tipe,
                'warna' => $request->warna,
                'foto_path' => $fotoPath,
                'is_active' => $request->input('is_active', false),
                // last_used_at TIDAK diset - akan diupdate oleh sistem parkir
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Vehicle added successfully',
                'data' => $vehicle
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();
            
            return response()->json([
                'success' => false,
                'message' => 'Failed to add vehicle',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get specific vehicle details
     * Endpoint minimal untuk kebutuhan parkir mall
     * 
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function show(Request $request, $id)
    {
        try {
            $user = $request->user();
            
            $vehicle = Kendaraan::forUser($user->id_user)
                ->where('id_kendaraan', $id)
                ->first();

            if (!$vehicle) {
                return response()->json([
                    'success' => false,
                    'message' => 'Vehicle not found'
                ], 404);
            }

            return response()->json([
                'success' => true,
                'message' => 'Vehicle retrieved successfully',
                'data' => $vehicle
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve vehicle',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Update vehicle
     * 
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function update(Request $request, $id)
    {
        try {
            $user = $request->user();
            
            $vehicle = Kendaraan::forUser($user->id_user)
                ->where('id_kendaraan', $id)
                ->first();

            if (!$vehicle) {
                return response()->json([
                    'success' => false,
                    'message' => 'Vehicle not found'
                ], 404);
            }

            // Validation
            $validator = Validator::make($request->all(), [
                'plat_nomor' => 'sometimes|string|max:20|unique:kendaraan,plat,' . $id . ',id_kendaraan',
                'jenis_kendaraan' => 'sometimes|in:Roda Dua,Roda Tiga,Roda Empat,Lebih dari Enam',
                'merk' => 'sometimes|string|max:50',
                'tipe' => 'sometimes|string|max:50',
                'warna' => 'nullable|string|max:50',
                'is_active' => 'boolean',
                'foto' => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            DB::beginTransaction();

            // If setting as active, deactivate others
            if ($request->has('is_active') && $request->is_active) {
                Kendaraan::forUser($user->id_user)
                    ->where('id_kendaraan', '!=', $id)
                    ->update(['is_active' => false]);
            }

            // Handle photo upload
            if ($request->hasFile('foto')) {
                // Delete old photo
                if ($vehicle->foto_path) {
                    Storage::disk('public')->delete($vehicle->foto_path);
                }

                $file = $request->file('foto');
                $filename = time() . '_' . $user->id_user . '_' . $file->getClientOriginalName();
                $fotoPath = $file->storeAs('vehicles', $filename, 'public');
                $vehicle->foto_path = $fotoPath;
            }

            // Update fields
            if ($request->has('plat_nomor')) {
                $vehicle->plat = strtoupper($request->plat_nomor);
            }
            if ($request->has('jenis_kendaraan')) {
                $vehicle->jenis = $request->jenis_kendaraan;
            }
            if ($request->has('merk')) {
                $vehicle->merk = $request->merk;
            }
            if ($request->has('tipe')) {
                $vehicle->tipe = $request->tipe;
            }
            if ($request->has('warna')) {
                $vehicle->warna = $request->warna;
            }
            if ($request->has('is_active')) {
                $vehicle->is_active = $request->is_active;
            }

            $vehicle->save();

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Vehicle updated successfully',
                'data' => $vehicle->fresh()
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            
            return response()->json([
                'success' => false,
                'message' => 'Failed to update vehicle',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Delete vehicle
     * 
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy(Request $request, $id)
    {
        try {
            $user = $request->user();
            
            $vehicle = Kendaraan::forUser($user->id_user)
                ->where('id_kendaraan', $id)
                ->first();

            if (!$vehicle) {
                return response()->json([
                    'success' => false,
                    'message' => 'Vehicle not found'
                ], 404);
            }

            // Check if vehicle has active parking transactions
            $hasActiveTransaction = $vehicle->transaksiParkir()
                ->whereNull('waktu_keluar')
                ->exists();

            if ($hasActiveTransaction) {
                return response()->json([
                    'success' => false,
                    'message' => 'Cannot delete vehicle with active parking transaction'
                ], 400);
            }

            // Delete photo if exists
            if ($vehicle->foto_path) {
                Storage::disk('public')->delete($vehicle->foto_path);
            }

            $vehicle->delete();

            return response()->json([
                'success' => true,
                'message' => 'Vehicle deleted successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete vehicle',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Set vehicle as active (main vehicle)
     * 
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function setActive(Request $request, $id)
    {
        try {
            $user = $request->user();
            
            $vehicle = Kendaraan::forUser($user->id_user)
                ->where('id_kendaraan', $id)
                ->first();

            if (!$vehicle) {
                return response()->json([
                    'success' => false,
                    'message' => 'Vehicle not found'
                ], 404);
            }

            DB::beginTransaction();

            // Deactivate all other vehicles
            Kendaraan::forUser($user->id_user)
                ->where('id_kendaraan', '!=', $id)
                ->update(['is_active' => false]);

            // Activate this vehicle
            $vehicle->is_active = true;
            $vehicle->save();

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Vehicle set as active successfully',
                'data' => $vehicle
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            
            return response()->json([
                'success' => false,
                'message' => 'Failed to set vehicle as active',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
