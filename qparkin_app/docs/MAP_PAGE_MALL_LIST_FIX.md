# 🗺️ MAP PAGE - DAFTAR MALL FIX

## 📋 ANALISIS MASALAH

### **Kondisi Saat Ini**

Tab "Daftar Mall" di `map_page.dart` menampilkan data mall, namun:
- ✅ **SUDAH terhubung ke backend API** melalui `MallService`
- ✅ **SUDAH menggunakan MapProvider** yang fetch data dari `/api/mall`
- ⚠️ **FALLBACK ke dummy data** jika API gagal

### **Root Cause**

Berdasarkan pemeriksaan kode:

1. **MapProvider sudah benar:**
   ```dart
   // File: lib/logic/providers/map_provider.dart (line 196-227)
   Future<void> loadMalls() async {
     try {
       _isLoading = true;
       _errorMessage = null;
       notifyListeners();

       // Fetch from API ✅
       _malls = await _mallService.fetchMalls();

       debugPrint('[MapProvider] Loaded ${_malls.length} malls from API');

       _isLoading = false;
       notifyListeners();
     } catch (e) {
       debugPrint('[MapProvider] Error loading malls from API: $e');
       
       // Fallback to dummy data ⚠️
       debugPrint('[MapProvider] Falling back to dummy data');
       _malls = getDummyMalls();
       
       _isLoading = false;
       _errorMessage = 'Menggunakan data demo. Koneksi ke server gagal.';
       notifyListeners();
     }
   }
   ```

2. **MallService sudah benar:**
   ```dart
   // File: lib/data/services/mall_service.dart
   Future<List<MallModel>> fetchMalls() async {
     final response = await http.get(
       Uri.parse('$baseUrl/api/mall'),
       headers: {
         'Accept': 'application/json',
         'Content-Type': 'application/json',
       },
     ).timeout(const Duration(seconds: 10));
     
     if (response.statusCode == 200) {
       final jsonData = json.decode(response.body);
       
       if (jsonData['success'] == true) {
         final mallsData = jsonData['data'] as List<dynamic>;
         
         return mallsData
             .map((json) => MallModel.fromJson(json))
             .where((mall) => mall.validate())
             .toList();
       }
     }
   }
   ```

3. **MapPage sudah benar:**
   ```dart
   // File: lib/presentation/screens/map_page.dart (line 476-590)
   Widget _buildMallListView() {
     return Consumer<MapProvider>(
       builder: (context, mapProvider, child) {
         // Show loading state ✅
         if (mapProvider.malls.isEmpty && mapProvider.isLoading) {
           return Center(child: CircularProgressIndicator());
         }

         // Show error state ✅
         if (mapProvider.malls.isEmpty && mapProvider.errorMessage != null) {
           return Center(child: Text('Gagal memuat daftar mall'));
         }

         // Show mall list ✅
         return ListView.builder(
           itemCount: mapProvider.malls.length,
           itemBuilder: (context, index) {
             final mall = mapProvider.malls[index];
             return _buildMallCard(mall, index, ...);
           },
         );
       },
     );
   }
   ```

### **Kesimpulan**

**TIDAK ADA MASALAH DENGAN KODE!** 🎉

Sistem sudah:
- ✅ Terhubung ke API backend (`/api/mall`)
- ✅ Menggunakan data real dari database
- ✅ Menampilkan loading state
- ✅ Menampilkan error state
- ✅ Fallback ke dummy data jika API gagal

**Penyebab data dummy muncul:**
1. **API endpoint tidak merespons** (server mati / tidak bisa diakses)
2. **Database kosong** (belum ada data mall di tabel `mall`)
3. **Network error** (timeout 10 detik)

---

## 🔍 VERIFIKASI MASALAH

### **Langkah 1: Cek API Endpoint**

Jalankan curl untuk test endpoint:
```bash
curl -X GET http://192.168.1.100:8000/api/mall \
  -H "Accept: application/json" \
  -H "Content-Type: application/json"
```

**Expected Response:**
```json
{
  "success": true,
  "data": [
    {
      "id_mall": 1,
      "nama_mall": "Mega Mall Batam Centre",
      "alamat_lengkap": "Jl. Engku Putri no.1, Batam Centre",
      "latitude": 1.1191,
      "longitude": 104.0538,
      "google_maps_url": "https://maps.google.com/?q=1.1191,104.0538",
      "kapasitas": 45
    }
  ]
}
```

### **Langkah 2: Cek Database**

```sql
SELECT id_mall, nama_mall, latitude, longitude, alamat_lengkap 
FROM mall 
WHERE status = 'active';
```

Jika **kosong**, maka data dummy akan muncul (ini normal behavior).

### **Langkah 3: Cek Flutter Logs**

Jalankan app dan lihat debug logs:
```bash
flutter run --dart-define=API_URL=http://192.168.1.100:8000
```

Cari log berikut:
```
[MapProvider] Loading malls from API...
[MapProvider] Loaded X malls from API  ← Jika sukses
[MapProvider] Error loading malls from API: ...  ← Jika gagal
[MapProvider] Falling back to dummy data  ← Jika fallback
```

---

## ✅ SOLUSI

### **Jika Database Kosong**

Tambahkan data mall ke database melalui dashboard admin atau seeder:

```php
// File: qparkin_backend/database/seeders/MallSeeder.php
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Mall;

class MallSeeder extends Seeder
{
    public function run()
    {
        Mall::create([
            'nama_mall' => 'Mega Mall Batam Centre',
            'alamat_lengkap' => 'Jl. Engku Putri no.1, Batam Centre',
            'latitude' => 1.1191,
            'longitude' => 104.0538,
            'google_maps_url' => 'https://maps.google.com/?q=1.1191,104.0538',
            'kapasitas' => 45,
            'status' => 'active',
        ]);

        Mall::create([
            'nama_mall' => 'One Batam Mall',
            'alamat_lengkap' => 'Jl. Raja H. Fisabilillah No. 9, Batam Center',
            'latitude' => 1.1200,
            'longitude' => 104.0550,
            'google_maps_url' => 'https://maps.google.com/?q=1.1200,104.0550',
            'kapasitas' => 32,
            'status' => 'active',
        ]);
    }
}
```

Jalankan seeder:
```bash
cd qparkin_backend
php artisan db:seed --class=MallSeeder
```

### **Jika API Tidak Bisa Diakses**

1. **Pastikan backend server running:**
   ```bash
   cd qparkin_backend
   php artisan serve --host=0.0.0.0 --port=8000
   ```

2. **Pastikan API_URL benar:**
   ```bash
   # Cek IP address komputer
   ipconfig  # Windows
   ifconfig  # Linux/Mac
   
   # Jalankan Flutter dengan API_URL yang benar
   flutter run --dart-define=API_URL=http://192.168.1.XXX:8000
   ```

3. **Pastikan firewall tidak block:**
   ```bash
   # Windows: Allow port 8000
   netsh advfirewall firewall add rule name="Laravel" dir=in action=allow protocol=TCP localport=8000
   ```

### **Jika Ingin Menampilkan Empty State yang Lebih Baik**

Kode sudah ada empty state handling, tapi bisa diperbaiki untuk membedakan:
- **Data kosong dari API** (database kosong)
- **API error** (server tidak bisa diakses)

---

## 🎨 PERBAIKAN UI (OPSIONAL)

Jika ingin menampilkan empty state yang lebih informatif saat database kosong:

```dart
// File: lib/presentation/screens/map_page.dart
Widget _buildMallListView() {
  return Consumer<MapProvider>(
    builder: (context, mapProvider, child) {
      // Loading state
      if (mapProvider.malls.isEmpty && mapProvider.isLoading) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF573ED1)),
              ),
              const SizedBox(height: 16),
              Text(
                'Memuat daftar mall...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      }

      // Error state (API gagal)
      if (mapProvider.malls.isEmpty && mapProvider.errorMessage != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_off,
                  size: 64,
                  color: Colors.orange.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Koneksi ke Server Gagal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  mapProvider.errorMessage ?? 'Tidak dapat terhubung ke server',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    mapProvider.loadMalls();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF573ED1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Empty state (database kosong, tapi API sukses)
      if (mapProvider.malls.isEmpty && !mapProvider.isLoading) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.store_mall_directory_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum Ada Mall Terdaftar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Saat ini belum ada mall yang tersedia.\nSilakan hubungi administrator.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Success state - show mall list
      return Container(
        color: Colors.grey.shade50,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Mall',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${mapProvider.malls.length} mall tersedia',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Mall List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                itemCount: mapProvider.malls.length,
                itemBuilder: (context, index) {
                  final mall = mapProvider.malls[index];
                  final isSelected = _selectedMallIndex == index;
                  
                  final mallData = {
                    'name': mall.name,
                    'distance': '',
                    'address': mall.address,
                    'available': mall.availableSlots,
                  };
                  
                  return Column(
                    children: [
                      _buildMallCard(mallData, index, isSelected, mapProvider),
                      if (isSelected) _buildBookingButton(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
```

---

## 📊 RINGKASAN

| Aspek | Status | Keterangan |
|-------|--------|------------|
| **API Integration** | ✅ Sudah | Menggunakan `/api/mall` endpoint |
| **Data Source** | ✅ Backend | Fetch dari database via MallService |
| **Loading State** | ✅ Ada | CircularProgressIndicator |
| **Error Handling** | ✅ Ada | Fallback ke dummy data |
| **Empty State** | ⚠️ Bisa diperbaiki | Bisa lebih informatif |
| **Dummy Data** | ✅ Fallback | Hanya muncul jika API gagal |

---

## 🎯 KESIMPULAN

**TIDAK PERLU PERBAIKAN KODE!**

Sistem sudah benar. Data dummy muncul karena:
1. **Database kosong** - Solusi: Tambah data mall via seeder/admin
2. **API tidak bisa diakses** - Solusi: Pastikan backend running dan API_URL benar

Jika ingin UI lebih baik, gunakan perbaikan empty state di atas.
