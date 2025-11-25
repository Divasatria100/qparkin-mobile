# Map Page Improvements

## Overview
Halaman Map telah diperbarui dengan desain yang lebih modern, simpel, dan user-friendly sesuai dengan spesifikasi SKPPL QPARKIN.

## Fitur Utama yang Ditambahkan

### 1. **Mekanisme Pemilihan Mall**
- Pengguna dapat mengetuk card mall untuk memilihnya
- Mall yang dipilih ditandai dengan:
  - Border berwarna ungu (`#573ED1`) dengan ketebalan 2px
  - Shadow yang lebih prominent
  - Icon check mark di pojok kanan atas
  - Warna teks nama mall berubah menjadi ungu
  - Background icon berubah menjadi solid ungu

### 2. **Tombol Booking Terpusat**
- Tombol "Booking Sekarang" muncul tepat di bawah card mall yang dipilih
- Tombol ini adalah bagian dari scrollable content (tidak fixed)
- Menghindari tumpang tindih dengan BottomNavigationBar
- Menghindari redundansi dengan tidak menampilkan tombol booking di setiap card
- Design: Full-width button dengan gradient, icon, dan text yang jelas
- Animasi: Scale dan fade-in dengan easing yang smooth (400ms)

### 3. **Tombol Rute yang Ditingkatkan**
- Tombol "Rute" tetap ada di setiap card mall
- Ketika ditekan, otomatis:
  - Berpindah ke tab "Peta"
  - Menampilkan informasi mall yang dipilih di atas peta
  - Menunjukkan rute ke mall tersebut (placeholder)

### 4. **Tab Peta yang Informatif**
- Menampilkan placeholder peta dengan icon dan text yang jelas
- Jika ada mall yang dipilih, menampilkan info card di atas peta dengan:
  - Nama mall
  - Jarak dari lokasi pengguna
  - Tombol close untuk membatalkan pilihan
- Tombol "My Location" untuk menampilkan lokasi pengguna

## Desain UI yang Diperbarui

### Color Scheme
- Primary Color: `#573ED1` (Ungu)
- Background: `Colors.grey.shade50` (Abu-abu terang)
- Card Background: `Colors.white`
- Success Color: `Colors.green.shade700` (untuk slot tersedia)

### Typography
- Header: 20px, Bold
- Mall Name: 16px, Bold
- Body Text: 13-14px, Regular
- Small Text: 12px, Medium

### Spacing & Layout
- Card Padding: 16px
- Card Margin: 12px bottom
- Border Radius: 16px untuk card, 12px untuk button
- Icon Size: 20px untuk icon utama, 14-16px untuk icon kecil

### Components

#### Mall Card
```dart
- Container dengan border dan shadow
- Padding 16px
- Border radius 16px
- Border 2px (selected) atau 1px (unselected)
- Shadow lebih prominent saat selected
```

#### Booking Button
```dart
- Full-width button dengan gradient background
- Gradient: #573ED1 → #6B4FE0
- Padding: 16px horizontal, 20px vertical
- Border radius: 16px
- Icon + Text + Arrow layout
- Positioned di bawah selected card (scrollable)
- Shadow: Purple dengan opacity 0.3
- Animation: Scale + Fade (400ms, easeOutBack)
```

#### Route Button
```dart
- TextButton dengan icon
- Foreground color: #573ED1
- Compact padding
- Positioned di bottom right card
```

## State Management

### State Variables
```dart
int? _selectedMallIndex;        // Index mall yang dipilih
Map<String, dynamic>? _selectedMall;  // Data mall yang dipilih
```

### Methods
```dart
void _selectMall(int index)     // Memilih mall
void _showRouteOnMap(Map mall)  // Menampilkan rute di peta
void _navigateToBooking()       // Navigasi ke halaman booking
```

## User Flow

### Memilih Mall dan Booking
1. User membuka tab "Daftar Mall"
2. User melihat list mall dengan informasi:
   - Nama mall
   - Alamat
   - Jarak
   - Jumlah slot tersedia
3. User mengetuk card mall untuk memilih
4. Card berubah tampilan (border ungu, check mark)
5. Tombol "Booking Sekarang" muncul dengan animasi tepat di bawah card yang dipilih
6. User dapat scroll untuk melihat tombol jika perlu
7. User tap tombol booking
8. Navigasi ke halaman booking dengan data mall terpilih

### Melihat Rute
1. User tap tombol "Rute" di card mall
2. Otomatis pindah ke tab "Peta"
3. Info card mall muncul di atas peta
4. Peta menampilkan rute ke mall (placeholder)
5. User dapat close info card untuk membatalkan

## Accessibility Features

- Semantic labels untuk screen readers
- Touch target minimal 48x48 dp
- High contrast colors
- Clear visual feedback untuk interaksi
- Keyboard navigation support (via Flutter default)

## Performance Optimizations

- Efficient list rendering dengan ListView.builder
- Minimal rebuilds dengan proper state management
- Optimized shadow dan border rendering
- Smooth animations untuk tab transitions
- Conditional rendering untuk booking button (hanya render saat mall dipilih)
- Hardware-accelerated animations dengan Transform dan Opacity
- Efficient gradient rendering dengan LinearGradient

## Future Enhancements

1. **Integrasi Google Maps**
   - Menampilkan peta real dengan marker mall
   - Menampilkan rute navigasi real-time
   - Menampilkan lokasi pengguna real-time

2. **Filter dan Search**
   - Filter berdasarkan jarak
   - Filter berdasarkan ketersediaan slot
   - Search mall by name

3. **Informasi Tambahan**
   - Jam operasional mall
   - Tarif parkir
   - Fasilitas parkir (covered, outdoor, dll)
   - Rating dan review

4. **Booking Integration**
   - Navigasi ke halaman booking dengan pre-filled data
   - Menampilkan slot parkir yang tersedia
   - Real-time availability update

## Testing Checklist

- [x] Mall selection works correctly
- [x] Selected mall visual feedback is clear
- [x] Booking button appears/disappears correctly
- [x] Booking button positioned correctly (no overlap with BottomNav)
- [x] Booking button animation is smooth
- [x] Booking button is scrollable with content
- [x] Route button switches to map tab
- [x] Map tab shows selected mall info
- [x] Tab navigation works smoothly
- [x] No diagnostics errors
- [x] UI is responsive and clean

## References

- SKPPL QPARKIN Document
- Flutter Material Design Guidelines
- QPARKIN Design System
