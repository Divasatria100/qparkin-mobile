<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class MallSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * NOTE: Mall data seeding has been DISABLED.
     * 
     * Mall data is now created through the Admin Mall Registration flow:
     * 1. Admin Mall registers via /signup page
     * 2. SuperAdmin approves the registration via /super/pengajuan-akun
     * 3. Mall data is automatically created upon approval
     * 
     * This ensures:
     * - 1 Admin Mall = 1 Mall (business logic)
     * - Proper admin-mall relationship
     * - Real-world registration workflow
     * 
     * If you need test data for development:
     * - Use the admin mall registration flow
     * - Or manually insert data via SQL if needed for testing
     * 
     * Previous seeder data (for reference):
     * - Mega Mall Batam Centre
     * - One Batam Mall
     * - SNL Food Bengkong
     */
    public function run(): void
    {
        // Seeder disabled - mall data created via admin mall registration
        // See: AdminMallRegistrationController and SuperAdminController
    }
}

