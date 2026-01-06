# 📱 FLUTTER UI COMPONENTS REFERENCE - QPARKIN

**Tujuan:** Panduan cepat untuk mengambil screenshot komponen UI Flutter untuk dokumentasi PPT

**Tanggal:** 6 Januari 2025

---

## 📋 DAFTAR ISI

1. [MaterialApp - Struktur Aplikasi Utama](#1-materialapp)
2. [Scaffold & AppBar - Struktur Layar](#2-scaffold--appbar)
3. [Navigator - Navigasi Antar Halaman](#3-navigator)
4. [TextFormField & Validator - Form Input](#4-textformfield--validator)
5. [AlertDialog - Dialog Konfirmasi](#5-alertdialog)
6. [SnackBar - Feedback Sistem](#6-snackbar)

---

## 1. MATERIALAPP - Struktur Aplikasi Utama

### 📄 File: `qparkin_app/lib/main.dart`

**Baris 91-125:** MaterialApp dengan routes dan theme

```dart
MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'QParkin Mobile',
  theme: ThemeData(
    primarySwatch: Colors.blue,
    useMaterial3: true,
  ),
  home: FutureBuilder(...),
  initialRoute: '/about',
  routes: { 
    '/about': (context) => const AboutPage(),
    LoginScreen.routeName: (context) => const LoginScreen(),
    SignUpScreen.routeName: (context) => const SignUpScreen(),
    '/home': (context) => const HomePage(),
    '/map': (context) => const MapPage(),
    '/activity': (context) => const ActivityPage(),
    '/profile': (context) => const ProfilePage(),
    '/list-kendaraan': (context) => const VehicleListPage(),
    '/point': (context) => const PointPage(),
    '/notifikasi': (context) => const NotificationScreen(),
  },
)
```

**Fungsi:** 
- Root widget aplikasi
- Definisi routes untuk navigasi
- Konfigurasi theme global
- FutureBuilder untuk cek status login

**Screenshot untuk PPT:**
- Struktur routes aplikasi
- Theme configuration

---


## 2. SCAFFOLD & APPBAR - Struktur Layar

### A. Login Screen

**📄 File:** `qparkin_app/lib/presentation/screens/login_screen.dart`

**Baris 176-179:** Scaffold dengan background color
```dart
return Scaffold(
  backgroundColor: Colors.grey.shade50,
  resizeToAvoidBottomInset: true,
  body: SafeArea(...)
)
```

**Fungsi:** Struktur halaman login dengan background abu-abu terang

**Screenshot:** Halaman login lengkap

---

### B. Home Page

**📄 File:** `qparkin_app/lib/presentation/screens/home_page.dart`

**Baris 377-380:** Scaffold tanpa AppBar (custom header)
```dart
return Scaffold(
  body: SingleChildScrollView(
    child: Column(...)
  )
)
```

**Fungsi:** Halaman utama dengan scroll view, tanpa AppBar standar

**Screenshot:** Home page dengan custom header

---

### C. Booking Page

**📄 File:** `qparkin_app/lib/presentation/screens/booking_page.dart`

**Baris 164-168:** Scaffold dengan AppBar custom
```dart
return Scaffold(
  appBar: _buildAppBar(),
  body: _buildBody(),
);
```

**Baris 176-198:** AppBar dengan back button dan title
```dart
return AppBar(
  centerTitle: true,
  title: Text(
    'Booking Parkir',
    style: TextStyle(
      fontSize: titleFontSize,
      fontWeight: FontWeight.bold,
    ),
  ),
  leading: Container(
    margin: const EdgeInsets.all(8),
    decoration: BoxDecoration(...),
    child: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.pop(context),
      tooltip: 'Kembali',
    ),
  ),
)
```

**Fungsi:** 
- AppBar dengan judul centered
- Custom back button dengan styling
- Responsive font size

**Screenshot:** Booking page dengan AppBar

---

### D. Activity Page

**📄 File:** `qparkin_app/lib/presentation/screens/activity_page.dart`

**Baris 150-157:** Scaffold dengan AppBar dan tabs
```dart
child: Scaffold(
  appBar: AppBar(
    centerTitle: true,
    title: const Text(
      'Aktivitas Parkir',
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
)
```

**Fungsi:** Halaman aktivitas dengan title bold

**Screenshot:** Activity page dengan tab Active/History

---

### E. Profile Page

**📄 File:** `qparkin_app/lib/presentation/screens/profile_page.dart`

**Baris 152-155:** Scaffold dengan RefreshIndicator
```dart
return Scaffold(
  backgroundColor: Colors.white,
  body: RefreshIndicator(
    onRefresh: () async {...},
  )
)
```

**Fungsi:** 
- Profile page dengan pull-to-refresh
- Background putih
- Loading state handling

**Screenshot:** Profile page dengan menu

---

### F. Map Page

**📄 File:** `qparkin_app/lib/presentation/screens/map_page.dart`

**Baris 256-263:** Scaffold dengan AppBar custom
```dart
child: Scaffold(
  appBar: AppBar(
    automaticallyImplyLeading: false,
    centerTitle: true,
    title: const Text(
      'Pilih Lokasi Parkir',
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
)
```

**Fungsi:** 
- Map page tanpa back button (automaticallyImplyLeading: false)
- Title centered

**Screenshot:** Map page dengan markers

---

### G. Point Page

**📄 File:** `qparkin_app/lib/presentation/screens/point_page.dart`

**Baris 216-221:** Scaffold dengan AppBar purple
```dart
return Scaffold(
  backgroundColor: Colors.grey[50],
  appBar: AppBar(
    title: const Text('Poin Saya'),
    backgroundColor: const Color.fromRGBO(87, 62, 209, 1),
  ),
)
```

**Fungsi:** Point page dengan AppBar warna ungu brand

**Screenshot:** Point page dengan saldo dan history

---

### H. Edit Profile Page

**📄 File:** `qparkin_app/lib/presentation/screens/edit_profile_page.dart`

**Baris 311-318:** Scaffold dengan AppBar purple
```dart
return Scaffold(
  backgroundColor: const Color(0xFFF5F5F5),
  appBar: AppBar(
    backgroundColor: const Color(0xFF573ED1),
    elevation: 0,
    title: const Text('Edit Profil'),
  ),
)
```

**Fungsi:** Edit profile dengan AppBar purple dan background abu

**Screenshot:** Form edit profile

---


## 3. NAVIGATOR - Navigasi Antar Halaman

### A. Navigator.push() - Pindah ke Halaman Baru

#### 1. Map Page → Booking Page

**📄 File:** `qparkin_app/lib/presentation/screens/map_page.dart`

**Baris 223-226:** Push ke Booking Page dengan animasi
```dart
Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => BookingPage(mall: _selectedMall!),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    },
  ),
);
```

**Fungsi:** Navigasi dengan slide animation dari kanan ke kiri

**Screenshot:** Transisi dari Map ke Booking

---

#### 2. Home Page → Map Page

**📄 File:** `qparkin_app/lib/presentation/screens/home_page.dart`

**Baris 356-358:** Push ke Map Page
```dart
onTap: () {
  Navigator.pushNamed(context, '/map');
},
```

**Fungsi:** Navigasi menggunakan named route

**Screenshot:** Button "Booking Sekarang" di Home

---

#### 3. Profile Page → Edit Profile

**📄 File:** `qparkin_app/lib/presentation/screens/profile_page.dart`

**Baris 405-410:** Push dengan custom transition
```dart
await navigator.push(
  PageTransitions.slideFromRight(
    page: const EditProfilePage(),
  ),
);
```

**Fungsi:** Navigasi dengan slide transition custom

**Screenshot:** Menu Edit Profile

---

#### 4. Profile Page → Vehicle List

**📄 File:** `qparkin_app/lib/presentation/screens/profile_page.dart`

**Baris 548-552:** Push ke Vehicle List
```dart
navigator.push(
  PageTransitions.slideFromRight(
    page: const VehicleListPage(),
  ),
);
```

**Fungsi:** Navigasi ke halaman list kendaraan

**Screenshot:** Menu "Kendaraan Saya"

---

#### 5. Vehicle Detail → Edit Vehicle

**📄 File:** `qparkin_app/lib/presentation/screens/vehicle_detail_page.dart`

**Baris 480-485:** Push ke Edit Vehicle
```dart
final result = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => VehicleSelectionPage(
      mode: VehicleSelectionMode.edit,
      existingVehicle: widget.vehicle,
    ),
  ),
);
```

**Fungsi:** Navigasi ke form edit dengan data existing

**Screenshot:** Button Edit di Vehicle Detail

---

### B. Navigator.pop() - Kembali ke Halaman Sebelumnya

#### 1. Booking Page → Back

**📄 File:** `qparkin_app/lib/presentation/screens/booking_page.dart`

**Baris 195-197:** Pop dengan back button
```dart
onPressed: () => Navigator.pop(context),
tooltip: 'Kembali',
iconSize: 24,
```

**Fungsi:** Kembali ke halaman sebelumnya (Map Page)

**Screenshot:** Back button di AppBar Booking

---

#### 2. Close Dialog

**📄 File:** `qparkin_app/lib/presentation/screens/booking_page.dart`

**Baris 667-669:** Pop untuk close dialog
```dart
TextButton(
  onPressed: () => Navigator.pop(context),
  child: const Text('Tutup'),
)
```

**Fungsi:** Menutup dialog konfirmasi

**Screenshot:** Dialog dengan button Tutup

---

#### 3. Success Booking → Pop Multiple

**📄 File:** `qparkin_app/lib/presentation/screens/booking_page.dart`

**Baris 1208-1210:** Pop booking page setelah success
```dart
// Pop the booking page first
Navigator.pop(context);

// Show confirmation dialog as full-screen route
```

**Fungsi:** Pop halaman booking sebelum show dialog success

**Screenshot:** Flow setelah booking berhasil

---

#### 4. Choose Vehicle → Pop with Result

**📄 File:** `qparkin_app/lib/presentation/screens/choose_vehicle.dart`

**Baris 82-84:** Pop dengan return value
```dart
setState(() {
  _selectedVehicleIndex = index;
});
Navigator.pop(context);
```

**Fungsi:** Kembali dengan membawa data kendaraan terpilih

**Screenshot:** Dialog pilih kendaraan

---

### C. Navigator.pushReplacement() - Replace Halaman

#### 1. Signup → Login

**📄 File:** `qparkin_app/lib/presentation/screens/signup_screen.dart`

**Baris 199-201:** Replace ke Login setelah registrasi
```dart
// Navigasi ke login
Navigator.pushReplacementNamed(context, LoginScreen.routeName);
```

**Fungsi:** Replace signup page dengan login (tidak bisa back)

**Screenshot:** Flow setelah registrasi berhasil

---

#### 2. Login → Signup

**📄 File:** `qparkin_app/lib/presentation/screens/login_screen.dart`

**Baris 461-464:** Replace ke Signup
```dart
onPressed: () => Navigator.pushReplacementNamed(
  context,
  SignUpScreen.routeName,
)
```

**Fungsi:** Replace login dengan signup

**Screenshot:** Button "Belum punya akun?"

---

#### 3. Booking Success → Activity

**📄 File:** `qparkin_app/lib/presentation/screens/booking_page.dart`

**Baris 1231-1235:** Replace ke Activity Page
```dart
Navigator.pushReplacementNamed(
  context,
  '/activity',
  arguments: {'initialTab': 0},
);
```

**Fungsi:** Replace booking dengan activity page setelah success

**Screenshot:** Button "Lihat Detail" di success dialog

---

#### 4. Activity → Home (Back Button)

**📄 File:** `qparkin_app/lib/presentation/screens/activity_page.dart`

**Baris 147-149:** Replace dengan Home saat back
```dart
onWillPop: () async {
  Navigator.pushReplacementNamed(context, '/home');
  return false;
},
```

**Fungsi:** Prevent default back, replace dengan home

**Screenshot:** Back button behavior di Activity

---

### D. Navigator.pushAndRemoveUntil() - Clear Stack

#### 1. Logout → About Page

**📄 File:** `qparkin_app/lib/presentation/screens/profile_page.dart`

**Baris 916-921:** Clear stack dan ke About
```dart
navigator.pushAndRemoveUntil(
  MaterialPageRoute(
    builder: (context) => const AboutPage(),
  ),
  (route) => false,
);
```

**Fungsi:** Logout dan clear semua navigation stack

**Screenshot:** Flow logout

---

#### 2. About → Login

**📄 File:** `qparkin_app/lib/presentation/screens/about_page.dart`

**Baris 98-100:** Replace ke Login
```dart
onPressed: () {
  Navigator.pushReplacementNamed(context, LoginScreen.routeName);
},
```

**Fungsi:** Dari About page ke Login

**Screenshot:** Button "Mulai" di About Page

---


## 4. TEXTFORMFIELD & VALIDATOR - Form Input

### A. Login Screen

**📄 File:** `qparkin_app/lib/presentation/screens/login_screen.dart`

#### 1. Phone Number Field

**Baris 323-326:** Phone field dengan validator
```dart
PhoneField(
  phoneCtrl: _phoneCtrl,
  validator: Validators.phone,
),
```

**Fungsi:** Input nomor HP dengan validasi format

**Screenshot:** Field nomor HP di login

---

#### 2. PIN Field

**Baris 332-351:** PIN field dengan obscure text
```dart
TextFormField(
  controller: _pinCtrl,
  keyboardType: TextInputType.number,
  obscureText: _obscurePin,
  maxLength: 6,
  decoration: InputDecoration(
    labelText: 'PIN (6 digit)',
    hintText: 'Masukkan PIN Anda',
    prefixIcon: const Icon(Icons.lock_outline),
    suffixIcon: IconButton(
      icon: Icon(_obscurePin ? Icons.visibility_off : Icons.visibility),
      onPressed: () => setState(() => _obscurePin = !_obscurePin),
    ),
  ),
  validator: Validators.pin6,
),
```

**Fungsi:** 
- Input PIN 6 digit
- Toggle visibility
- Validasi PIN

**Screenshot:** Field PIN dengan toggle visibility

---

### B. Signup Screen

**📄 File:** `qparkin_app/lib/presentation/screens/signup_screen.dart`

#### 1. Name Field

**Baris 351-357:** Name field dengan validator
```dart
TextFormField(
  controller: _nameCtrl,
  decoration: _nameDecoration(),
  validator: (v) =>
      Validators.required(v, label: 'Nama'),
),
```

**Fungsi:** Input nama dengan validasi required

**Screenshot:** Field nama di signup

---

#### 2. Phone Field

**Baris 415-418:** Phone field
```dart
PhoneField(
  phoneCtrl: _phoneCtrl,
  validator: Validators.phone,
),
```

**Fungsi:** Input nomor HP dengan validasi

**Screenshot:** Field nomor HP di signup

---

#### 3. PIN Field

**Baris 425-456:** PIN field dengan obscure
```dart
TextFormField(
  controller: _pinCtrl,
  keyboardType: TextInputType.number,
  obscureText: _obscurePin,
  maxLength: 6,
  decoration: InputDecoration(
    labelText: 'PIN (6 digit)',
    hintText: 'Buat PIN untuk login',
    prefixIcon: const Icon(Icons.lock_outline),
    suffixIcon: IconButton(
      icon: Icon(_obscurePin ? Icons.visibility_off : Icons.visibility),
      onPressed: () => setState(() => _obscurePin = !_obscurePin),
    ),
  ),
  validator: Validators.pin6,
),
```

**Fungsi:** Input PIN dengan validasi 6 digit

**Screenshot:** Field PIN di signup

---

### C. Edit Profile Page

**📄 File:** `qparkin_app/lib/presentation/screens/edit_profile_page.dart`

#### 1. Name Field

**Baris 408-433:** Name field dengan custom decoration
```dart
TextFormField(
  controller: _nameController,
  decoration: InputDecoration(
    hintText: 'Masukkan nama lengkap Anda',
    hintStyle: TextStyle(
      color: Colors.grey[400],
      fontSize: 14,
    ),
    border: InputBorder.none,
    contentPadding: EdgeInsets.zero,
  ),
  style: const TextStyle(
    fontSize: 14,
  ),
  validator: (value) => Validators.required(value, label: 'Nama'),
),
```

**Fungsi:** Input nama dengan validasi required

**Screenshot:** Form edit nama

---

#### 2. Email Field

**Baris 468-494:** Email field dengan validator custom
```dart
TextFormField(
  controller: _emailController,
  keyboardType: TextInputType.emailAddress,
  decoration: InputDecoration(
    hintText: 'Masukkan alamat email Anda, opsional',
    hintStyle: TextStyle(
      color: Colors.grey[400],
      fontSize: 14,
    ),
    border: InputBorder.none,
    contentPadding: EdgeInsets.zero,
  ),
  style: const TextStyle(
    fontSize: 14,
  ),
  validator: _validateEmail,
),
```

**Fungsi:** Input email dengan validasi format (opsional)

**Screenshot:** Form edit email

---

#### 3. Phone Field

**Baris 541-567:** Phone field dengan validator custom
```dart
TextFormField(
  controller: _phoneController,
  keyboardType: TextInputType.phone,
  decoration: InputDecoration(
    hintText: 'Masukkan nomor telepon Anda, opsional',
    hintStyle: TextStyle(
      color: Colors.grey[400],
      fontSize: 14,
    ),
    border: InputBorder.none,
    contentPadding: EdgeInsets.zero,
  ),
  style: const TextStyle(
    fontSize: 14,
  ),
  validator: _validatePhone,
),
```

**Fungsi:** Input phone dengan validasi format (opsional)

**Screenshot:** Form edit phone

---

### D. Validators Class

**📄 File:** `qparkin_app/lib/utils/validators.dart` (implied)

#### Common Validators:

1. **Validators.required()**
   - Validasi field tidak boleh kosong
   - Return: "Nama tidak boleh kosong"

2. **Validators.phone**
   - Validasi format nomor HP Indonesia
   - Return: "Nomor HP tidak valid"

3. **Validators.pin6**
   - Validasi PIN harus 6 digit
   - Return: "PIN harus 6 digit"

4. **Custom _validateEmail()**
   - Validasi format email (opsional)
   - Return: "Format email tidak valid"

5. **Custom _validatePhone()**
   - Validasi format phone (opsional)
   - Return: "Format nomor telepon tidak valid"

**Screenshot:** Error messages dari validators

---

### E. Form Decoration Examples

#### 1. Standard Decoration (Login/Signup)

```dart
InputDecoration(
  labelText: 'PIN (6 digit)',
  hintText: 'Masukkan PIN Anda',
  prefixIcon: const Icon(Icons.lock_outline),
  suffixIcon: IconButton(...),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
  ),
)
```

**Screenshot:** Field dengan border dan icons

---

#### 2. Minimal Decoration (Edit Profile)

```dart
InputDecoration(
  hintText: 'Masukkan nama lengkap Anda',
  hintStyle: TextStyle(color: Colors.grey[400]),
  border: InputBorder.none,
  contentPadding: EdgeInsets.zero,
)
```

**Screenshot:** Field tanpa border (clean design)

---


## 5. ALERTDIALOG - Dialog Konfirmasi

### A. Logout Confirmation

**📄 File:** `qparkin_app/lib/presentation/screens/profile_page.dart`

**Baris 796-850:** Dialog konfirmasi logout
```dart
child: AlertDialog(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  title: Row(
    children: const [
      Icon(Icons.logout, color: Color(0xFF573ED1)),
      SizedBox(width: 12),
      Text('Konfirmasi Keluar'),
    ],
  ),
  content: const Text(
    'Apakah Anda yakin ingin keluar dari aplikasi?',
    style: TextStyle(fontSize: 14),
  ),
  actions: [
    TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Batal'),
    ),
    ElevatedButton(
      onPressed: () async {
        Navigator.pop(context); // Close dialog
        await _performLogout();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF573ED1),
      ),
      child: const Text('Ya, Keluar'),
    ),
  ],
)
```

**Fungsi:** 
- Konfirmasi sebelum logout
- 2 actions: Batal dan Ya, Keluar
- Custom styling dengan icon

**Screenshot:** Dialog logout dengan 2 buttons

---

### B. Delete Vehicle Confirmation

**📄 File:** `qparkin_app/lib/presentation/screens/vehicle_detail_page.dart`

**Baris 501-540:** Dialog konfirmasi hapus kendaraan
```dart
return AlertDialog(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  title: const Text(
    'Hapus Kendaraan',
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
  ),
  content: Text(
    'Apakah Anda yakin ingin menghapus ${vehicle.merk} ${vehicle.tipe}?',
    style: const TextStyle(fontSize: 14),
  ),
  actions: [
    TextButton(
      onPressed: () => Navigator.pop(dialogContext),
      child: const Text('Batal'),
    ),
    ElevatedButton(
      onPressed: () async {
        Navigator.pop(dialogContext);
        await _handleDelete(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
      ),
      child: const Text('Hapus'),
    ),
  ],
);
```

**Fungsi:** 
- Konfirmasi sebelum hapus kendaraan
- Button hapus berwarna merah (danger)
- Menampilkan nama kendaraan yang akan dihapus

**Screenshot:** Dialog hapus kendaraan

---

### C. Delete Vehicle from List

**📄 File:** `qparkin_app/lib/presentation/screens/list_kendaraan.dart`

**Baris 54-90:** Dialog konfirmasi hapus dari list
```dart
return AlertDialog(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  title: Row(
    children: const [
      Icon(Icons.warning_amber_rounded, color: Colors.orange),
      SizedBox(width: 12),
      Text('Hapus Kendaraan'),
    ],
  ),
  content: Text(
    'Apakah Anda yakin ingin menghapus ${vehicle.merk} ${vehicle.tipe}?',
  ),
  actions: [
    TextButton(
      onPressed: () => Navigator.pop(dialogContext),
      child: const Text('Batal'),
    ),
    ElevatedButton(
      onPressed: () {
        Navigator.pop(dialogContext);
        _deleteVehicle(vehicle);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
      ),
      child: const Text('Hapus'),
    ),
  ],
);
```

**Fungsi:** 
- Dialog dengan warning icon
- Konfirmasi hapus dari list kendaraan

**Screenshot:** Dialog dengan warning icon

---

### D. Login Failed Dialog

**📄 File:** `qparkin_app/lib/presentation/screens/login_screen.dart`

**Baris 109-120:** Dialog error login
```dart
builder: (ctx) => AlertDialog(
  title: const Text('Login Gagal'),
  content: Text(message),
  actions: [
    TextButton(
      onPressed: () => Navigator.pop(ctx),
      child: const Text('OK'),
    ),
  ],
)
```

**Fungsi:** 
- Menampilkan error message
- Simple dialog dengan 1 button OK

**Screenshot:** Dialog error login

---

### E. Custom Duration Picker Dialog

**📄 File:** `qparkin_app/lib/presentation/screens/booking_page.dart`

**Baris 687-750:** Dialog pilih durasi custom
```dart
builder: (context) => AlertDialog(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  title: const Text('Pilih Durasi Custom'),
  content: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Hour picker
      Row(
        children: [
          const Text('Jam: '),
          DropdownButton<int>(
            value: selectedHours,
            items: List.generate(24, (i) => 
              DropdownMenuItem(value: i, child: Text('$i'))
            ),
            onChanged: (value) {
              setState(() => selectedHours = value!);
            },
          ),
        ],
      ),
      // Minute picker
      Row(
        children: [
          const Text('Menit: '),
          DropdownButton<int>(
            value: selectedMinutes,
            items: [0, 15, 30, 45].map((i) => 
              DropdownMenuItem(value: i, child: Text('$i'))
            ).toList(),
            onChanged: (value) {
              setState(() => selectedMinutes = value!);
            },
          ),
        ],
      ),
    ],
  ),
  actions: [
    TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Batal'),
    ),
    ElevatedButton(
      onPressed: () {
        final duration = Duration(
          hours: selectedHours,
          minutes: selectedMinutes,
        );
        Navigator.pop(context, duration);
      },
      child: const Text('OK'),
    ),
  ],
)
```

**Fungsi:** 
- Dialog dengan dropdown pickers
- Pilih jam dan menit
- Return Duration object

**Screenshot:** Dialog custom duration picker

---

### F. Unsaved Changes Dialog

**📄 File:** `qparkin_app/lib/presentation/screens/edit_profile_page.dart`

**Baris 241-280:** Dialog konfirmasi keluar tanpa save
```dart
builder: (context) => AlertDialog(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  title: const Text(
    'Perubahan Belum Disimpan',
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
  content: const Text(
    'Anda memiliki perubahan yang belum disimpan. '
    'Apakah Anda yakin ingin keluar?',
  ),
  actions: [
    TextButton(
      onPressed: () => Navigator.pop(context, false),
      child: const Text('Tetap di Sini'),
    ),
    ElevatedButton(
      onPressed: () => Navigator.pop(context, true),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
      ),
      child: const Text('Keluar'),
    ),
  ],
);
```

**Fungsi:** 
- Konfirmasi keluar dengan unsaved changes
- Return bool untuk decision

**Screenshot:** Dialog unsaved changes

---

### G. Slot Unavailable Dialog

**📄 File:** `qparkin_app/lib/presentation/screens/booking_page.dart`

**Baris 514-600:** Dialog slot tidak tersedia
```dart
builder: (context) => AlertDialog(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  title: Row(
    children: const [
      Icon(Icons.warning_amber_rounded, color: Colors.orange),
      SizedBox(width: 12),
      Text('Slot Tidak Tersedia'),
    ],
  ),
  content: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Maaf, tidak ada slot parkir yang tersedia untuk waktu yang Anda pilih.',
      ),
      const SizedBox(height: 16),
      const Text(
        'Saran:',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const Text('• Pilih waktu yang berbeda'),
      const Text('• Pilih mall lain'),
    ],
  ),
  actions: [
    TextButton(
      onPressed: () {
        Navigator.pop(context);
        Navigator.pop(context); // Back to mall selection
      },
      child: const Text('Pilih Mall Lain'),
    ),
    ElevatedButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Ubah Waktu'),
    ),
  ],
);
```

**Fungsi:** 
- Informasi slot tidak tersedia
- Saran untuk user
- 2 actions: Pilih Mall Lain atau Ubah Waktu

**Screenshot:** Dialog slot unavailable dengan suggestions

---


## 6. SNACKBAR - Feedback Sistem

### A. Success Messages

#### 1. Profile Updated Success

**📄 File:** `qparkin_app/lib/presentation/screens/profile_page.dart`

**Baris 187-197:** SnackBar success refresh
```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text(
      'Data berhasil diperbarui',
      style: TextStyle(color: Colors.white),
    ),
    backgroundColor: Colors.green,
    duration: Duration(seconds: 2),
    behavior: SnackBarBehavior.floating,
  ),
);
```

**Fungsi:** 
- Feedback success setelah refresh data
- Background hijau
- Floating behavior
- Auto dismiss 2 detik

**Screenshot:** SnackBar hijau di bottom

---

#### 2. Vehicle Deleted Success

**📄 File:** `qparkin_app/lib/presentation/screens/list_kendaraan.dart`

**Baris 129-131:** SnackBar delete success
```dart
_showSnackbar('${vehicle.merk} ${vehicle.tipe} berhasil dihapus!');

// Method _showSnackbar:
void _showSnackbar(String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
```

**Fungsi:** 
- Custom method untuk show snackbar
- Dynamic color (green/red)
- Clear previous snackbars

**Screenshot:** SnackBar delete success

---

#### 3. Point Data Refreshed

**📄 File:** `qparkin_app/lib/presentation/screens/point_page.dart`

**Baris 95-102:** SnackBar refresh success
```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text('Data berhasil diperbarui'),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  ),
);
```

**Fungsi:** Feedback setelah refresh point data

**Screenshot:** SnackBar refresh point

---

#### 4. Vehicle Set Active Success

**📄 File:** `qparkin_app/lib/presentation/screens/vehicle_detail_page.dart`

**Baris 448-457:** SnackBar set active
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(
      '${vehicle.merk} ${vehicle.tipe} dijadikan kendaraan aktif',
      style: const TextStyle(color: Colors.white),
    ),
    backgroundColor: Colors.green,
    duration: const Duration(seconds: 2),
  ),
);
```

**Fungsi:** Feedback setelah set kendaraan aktif

**Screenshot:** SnackBar set active vehicle

---

### B. Error Messages

#### 1. Profile Refresh Failed

**📄 File:** `qparkin_app/lib/presentation/screens/profile_page.dart`

**Baris 172-181:** SnackBar error refresh
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(
      provider.errorMessage ?? 'Gagal memperbarui data',
      style: const TextStyle(color: Colors.white),
    ),
    backgroundColor: Colors.red,
    duration: const Duration(seconds: 3),
  ),
);
```

**Fungsi:** 
- Error message dari provider
- Background merah
- Duration 3 detik

**Screenshot:** SnackBar error merah

---

#### 2. Vehicle Delete Failed

**📄 File:** `qparkin_app/lib/presentation/screens/list_kendaraan.dart`

**Baris 131-133:** SnackBar delete error
```dart
} catch (e) {
  _showSnackbar('Gagal menghapus kendaraan', isError: true);
}
```

**Fungsi:** Error saat gagal hapus kendaraan

**Screenshot:** SnackBar error delete

---

#### 3. Set Active Vehicle Failed

**📄 File:** `qparkin_app/lib/presentation/screens/vehicle_detail_page.dart`

**Baris 463-472:** SnackBar set active error
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text(
      'Gagal mengubah kendaraan aktif',
      style: TextStyle(color: Colors.white),
    ),
    backgroundColor: Colors.red,
    duration: const Duration(seconds: 2),
  ),
);
```

**Fungsi:** Error saat gagal set active

**Screenshot:** SnackBar error set active

---

#### 4. Logout Failed

**📄 File:** `qparkin_app/lib/presentation/screens/profile_page.dart`

**Baris 932-941:** SnackBar logout error
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(
      'Gagal keluar: ${e.toString()}',
      style: const TextStyle(color: Colors.white),
    ),
    backgroundColor: Colors.red,
    duration: const Duration(seconds: 3),
  ),
);
```

**Fungsi:** Error saat logout gagal

**Screenshot:** SnackBar logout error

---

### C. Info Messages

#### 1. OTP Sent Info

**📄 File:** `qparkin_app/lib/presentation/screens/signup_screen.dart`

**Baris 164-170:** SnackBar OTP debug info
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('OTP dikirim ke: ${result['debug_email']}'),
    backgroundColor: Colors.blue,
    duration: const Duration(seconds: 3),
  ),
);
```

**Fungsi:** 
- Info email tujuan OTP (development)
- Background biru
- Duration 3 detik

**Screenshot:** SnackBar info biru

---

#### 2. Session Expired

**📄 File:** `qparkin_app/lib/presentation/screens/point_page.dart`

**Baris 81-87:** SnackBar session expired
```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text('Sesi login telah berakhir'),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.orange,
  ),
);
```

**Fungsi:** Info session expired

**Screenshot:** SnackBar orange session

---

#### 3. No Internet Connection

**📄 File:** `qparkin_app/lib/presentation/screens/point_page.dart`

**Baris 108-116:** SnackBar no internet
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(requiresInternet
        ? 'Memerlukan koneksi internet. Periksa koneksi Anda.'
        : 'Gagal memuat data: ${e.toString()}'),
    duration: const Duration(seconds: 3),
    backgroundColor: Colors.orange,
  ),
);
```

**Fungsi:** Info no internet connection

**Screenshot:** SnackBar no internet

---

### D. SnackBar with Action

#### 1. Error with Retry

**📄 File:** `qparkin_app/lib/presentation/widgets/error_retry_widget.dart`

**Baris 139-165:** SnackBar dengan retry button
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: [
        const Icon(Icons.check_circle, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
    backgroundColor: Colors.green,
    duration: duration,
    behavior: SnackBarBehavior.floating,
    action: SnackBarAction(
      label: 'OK',
      textColor: Colors.white,
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
    ),
  ),
);
```

**Fungsi:** 
- SnackBar dengan icon
- Action button "OK"
- Floating behavior

**Screenshot:** SnackBar dengan action button

---

#### 2. Offline Indicator

**📄 File:** `qparkin_app/lib/presentation/widgets/error_retry_widget.dart`

**Baris 171-190:** SnackBar offline
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: const [
        Icon(Icons.wifi_off, color: Colors.white),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'Tidak ada koneksi internet',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
    backgroundColor: Colors.grey[800],
    duration: const Duration(seconds: 4),
    behavior: SnackBarBehavior.floating,
  ),
);
```

**Fungsi:** 
- SnackBar dengan wifi off icon
- Background dark grey
- Persistent 4 detik

**Screenshot:** SnackBar offline indicator

---

### E. Validation Error SnackBar

#### 1. Duration Validation

**📄 File:** `qparkin_app/lib/presentation/widgets/time_duration_picker.dart`

**Baris 197-203:** SnackBar validation error
```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text('Durasi minimal 30 menit'),
    backgroundColor: Colors.red,
    duration: Duration(seconds: 2),
  ),
);
```

**Fungsi:** Error validasi durasi minimal

**Screenshot:** SnackBar validation error

---

#### 2. QR Code Error

**📄 File:** `qparkin_app/lib/presentation/widgets/qr_exit_button.dart`

**Baris 46-52:** SnackBar QR error
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Gagal menampilkan QR code: ${e.toString()}'),
    backgroundColor: Colors.red,
    duration: const Duration(seconds: 3),
  ),
);
```

**Fungsi:** Error saat generate QR code

**Screenshot:** SnackBar QR error

---

### F. SnackBar Best Practices

#### Key Properties:

1. **content** - Widget untuk konten (biasanya Text)
2. **backgroundColor** - Warna background
   - Green: Success
   - Red: Error
   - Blue: Info
   - Orange: Warning
3. **duration** - Durasi tampil (default 4 detik)
4. **behavior** - SnackBarBehavior.floating untuk floating style
5. **action** - SnackBarAction untuk button action

#### Common Patterns:

```dart
// Success
backgroundColor: Colors.green
duration: Duration(seconds: 2)

// Error
backgroundColor: Colors.red
duration: Duration(seconds: 3)

// Info
backgroundColor: Colors.blue
duration: Duration(seconds: 3)

// Warning
backgroundColor: Colors.orange
duration: Duration(seconds: 3)
```

**Screenshot:** Berbagai warna SnackBar

---


## 7. QUICK REFERENCE TABLE

### File Locations Summary

| Komponen | File Path | Baris Kode | Fungsi |
|----------|-----------|------------|--------|
| **MaterialApp** | `lib/main.dart` | 91-125 | Root app dengan routes |
| **Login Scaffold** | `lib/presentation/screens/login_screen.dart` | 176-179 | Struktur halaman login |
| **Home Scaffold** | `lib/presentation/screens/home_page.dart` | 377-380 | Halaman utama |
| **Booking AppBar** | `lib/presentation/screens/booking_page.dart` | 176-198 | AppBar dengan back button |
| **Activity AppBar** | `lib/presentation/screens/activity_page.dart` | 151-157 | AppBar dengan title |
| **Profile Scaffold** | `lib/presentation/screens/profile_page.dart` | 152-155 | Profile dengan refresh |
| **Map AppBar** | `lib/presentation/screens/map_page.dart` | 257-263 | AppBar tanpa back |
| **Point AppBar** | `lib/presentation/screens/point_page.dart` | 218-221 | AppBar purple |
| **Edit Profile AppBar** | `lib/presentation/screens/edit_profile_page.dart` | 313-318 | AppBar purple |
| **Push to Booking** | `lib/presentation/screens/map_page.dart` | 223-226 | Navigasi dengan animasi |
| **Push to Map** | `lib/presentation/screens/home_page.dart` | 356-358 | Named route |
| **Push to Edit** | `lib/presentation/screens/profile_page.dart` | 405-410 | Custom transition |
| **Pop Back** | `lib/presentation/screens/booking_page.dart` | 195-197 | Back button |
| **Pop Dialog** | `lib/presentation/screens/booking_page.dart` | 667-669 | Close dialog |
| **Replace to Login** | `lib/presentation/screens/signup_screen.dart` | 199-201 | After signup |
| **Replace to Activity** | `lib/presentation/screens/booking_page.dart` | 1231-1235 | After booking |
| **Clear Stack Logout** | `lib/presentation/screens/profile_page.dart` | 916-921 | Logout flow |
| **Phone Field** | `lib/presentation/screens/login_screen.dart` | 323-326 | Input nomor HP |
| **PIN Field** | `lib/presentation/screens/login_screen.dart` | 332-351 | Input PIN obscure |
| **Name Field** | `lib/presentation/screens/signup_screen.dart` | 351-357 | Input nama |
| **Email Field** | `lib/presentation/screens/edit_profile_page.dart` | 468-494 | Input email |
| **Logout Dialog** | `lib/presentation/screens/profile_page.dart` | 796-850 | Konfirmasi logout |
| **Delete Vehicle** | `lib/presentation/screens/vehicle_detail_page.dart` | 501-540 | Konfirmasi hapus |
| **Login Error** | `lib/presentation/screens/login_screen.dart` | 109-120 | Error dialog |
| **Custom Duration** | `lib/presentation/screens/booking_page.dart` | 687-750 | Picker dialog |
| **Unsaved Changes** | `lib/presentation/screens/edit_profile_page.dart` | 241-280 | Konfirmasi keluar |
| **Slot Unavailable** | `lib/presentation/screens/booking_page.dart` | 514-600 | Info dialog |
| **Success SnackBar** | `lib/presentation/screens/profile_page.dart` | 187-197 | Feedback hijau |
| **Error SnackBar** | `lib/presentation/screens/profile_page.dart` | 172-181 | Feedback merah |
| **Info SnackBar** | `lib/presentation/screens/signup_screen.dart` | 164-170 | Feedback biru |
| **Warning SnackBar** | `lib/presentation/screens/point_page.dart` | 81-87 | Feedback orange |
| **SnackBar with Action** | `lib/presentation/widgets/error_retry_widget.dart` | 139-165 | Dengan button |

---

## 8. SCREENSHOT CHECKLIST UNTUK PPT

### Slide 1: Struktur Aplikasi (MaterialApp)
- [ ] File `main.dart` baris 91-125
- [ ] Highlight: routes definition
- [ ] Highlight: theme configuration

### Slide 2: Scaffold & AppBar
- [ ] Login screen (login_screen.dart:176-179)
- [ ] Home page (home_page.dart:377-380)
- [ ] Booking page dengan AppBar (booking_page.dart:176-198)
- [ ] Activity page dengan AppBar (activity_page.dart:151-157)

### Slide 3: Navigasi - Push
- [ ] Map → Booking dengan animasi (map_page.dart:223-226)
- [ ] Home → Map named route (home_page.dart:356-358)
- [ ] Profile → Edit custom transition (profile_page.dart:405-410)

### Slide 4: Navigasi - Pop & Replace
- [ ] Back button di Booking (booking_page.dart:195-197)
- [ ] Close dialog (booking_page.dart:667-669)
- [ ] Replace Signup → Login (signup_screen.dart:199-201)
- [ ] Clear stack logout (profile_page.dart:916-921)

### Slide 5: Form Input - TextFormField
- [ ] Phone field dengan validator (login_screen.dart:323-326)
- [ ] PIN field dengan obscure (login_screen.dart:332-351)
- [ ] Name field (signup_screen.dart:351-357)
- [ ] Email field (edit_profile_page.dart:468-494)

### Slide 6: Validator
- [ ] Validators.phone
- [ ] Validators.pin6
- [ ] Validators.required
- [ ] Custom email validator
- [ ] Error messages

### Slide 7: AlertDialog - Konfirmasi
- [ ] Logout dialog (profile_page.dart:796-850)
- [ ] Delete vehicle dialog (vehicle_detail_page.dart:501-540)
- [ ] Unsaved changes dialog (edit_profile_page.dart:241-280)

### Slide 8: AlertDialog - Info & Custom
- [ ] Login error dialog (login_screen.dart:109-120)
- [ ] Custom duration picker (booking_page.dart:687-750)
- [ ] Slot unavailable dialog (booking_page.dart:514-600)

### Slide 9: SnackBar - Success & Error
- [ ] Success green (profile_page.dart:187-197)
- [ ] Error red (profile_page.dart:172-181)
- [ ] Delete success (list_kendaraan.dart:129-131)
- [ ] Set active success (vehicle_detail_page.dart:448-457)

### Slide 10: SnackBar - Info & Warning
- [ ] Info blue OTP (signup_screen.dart:164-170)
- [ ] Warning orange session (point_page.dart:81-87)
- [ ] No internet (point_page.dart:108-116)
- [ ] SnackBar with action (error_retry_widget.dart:139-165)

---

## 9. TIPS SCREENSHOT

### Untuk MaterialApp & Routes:
1. Buka `main.dart`
2. Scroll ke baris 91
3. Screenshot code block MaterialApp
4. Highlight routes definition

### Untuk Scaffold & AppBar:
1. Buka file screen yang dimaksud
2. Cari keyword "Scaffold("
3. Screenshot dari Scaffold sampai AppBar
4. Highlight struktur widget tree

### Untuk Navigator:
1. Buka file yang dimaksud
2. Cari keyword "Navigator.push" atau "Navigator.pop"
3. Screenshot method call lengkap
4. Highlight parameter penting (route, context)

### Untuk TextFormField:
1. Buka file screen
2. Cari keyword "TextFormField"
3. Screenshot dari TextFormField sampai validator
4. Highlight decoration dan validator

### Untuk AlertDialog:
1. Buka file yang dimaksud
2. Cari keyword "AlertDialog("
3. Screenshot dari AlertDialog sampai actions
4. Highlight title, content, actions

### Untuk SnackBar:
1. Buka file yang dimaksud
2. Cari keyword "showSnackBar"
3. Screenshot dari showSnackBar sampai closing bracket
4. Highlight content, backgroundColor, duration

---

## 10. COMMAND UNTUK MEMBUKA FILE

### Windows Command Prompt:
```cmd
cd qparkin_app
code lib/main.dart
code lib/presentation/screens/login_screen.dart
code lib/presentation/screens/home_page.dart
code lib/presentation/screens/booking_page.dart
code lib/presentation/screens/activity_page.dart
code lib/presentation/screens/profile_page.dart
```

### VS Code Quick Open (Ctrl+P):
```
main.dart
login_screen.dart
home_page.dart
booking_page.dart
activity_page.dart
profile_page.dart
map_page.dart
point_page.dart
edit_profile_page.dart
vehicle_detail_page.dart
list_kendaraan.dart
signup_screen.dart
```

### Go to Line (Ctrl+G):
```
Setelah buka file, tekan Ctrl+G dan ketik nomor baris
Contoh: 176 untuk login_screen.dart Scaffold
```

---

## 11. EXPORT UNTUK PPT

### Format Screenshot:
- **Resolution:** 1920x1080 atau 1280x720
- **Format:** PNG (untuk kualitas terbaik)
- **Zoom:** 150% di VS Code untuk readability
- **Theme:** Dark theme atau Light theme (konsisten)

### Tools Screenshot:
- **Windows:** Snipping Tool (Win+Shift+S)
- **VS Code:** Built-in screenshot extension
- **Browser DevTools:** Untuk UI screenshot

### Naming Convention:
```
01_materialapp_routes.png
02_scaffold_login.png
03_appbar_booking.png
04_navigator_push_map.png
05_navigator_pop_back.png
06_textformfield_phone.png
07_validator_pin.png
08_alertdialog_logout.png
09_snackbar_success.png
10_snackbar_error.png
```

---

**END OF DOCUMENT**

**Total Files Referenced:** 15 files  
**Total Code Locations:** 60+ locations  
**Ready for:** PPT Documentation & Presentation

