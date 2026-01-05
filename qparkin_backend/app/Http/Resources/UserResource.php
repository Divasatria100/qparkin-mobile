<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => (string) $this->id_user,
            'name' => $this->name,
            'email' => $this->email,
            'phone_number' => $this->nomor_hp,
            'photo_url' => $this->avatar,
            'saldo_poin' => (int) $this->saldo_poin,
            'role' => $this->role,
            'status' => $this->status,
            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
        ];
    }
}
