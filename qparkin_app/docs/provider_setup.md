# Provider Setup Documentation

## Overview
Dokumen ini menjelaskan setup Provider untuk aplikasi QParkin Mobile, khususnya untuk `ActiveParkingProvider` yang mengelola state parkir aktif.

## Provider Architecture

### ActiveParkingProvider
Provider ini mengelola:
- Data parkir aktif pengguna
- Timer state untuk durasi parkir
- Refresh otomatis setiap 30 detik
- Error handling dan retry mechanism
- State persistence

## Setup di main.dart

Provider didaftarkan di level root aplikasi menggunakan `MultiProvider`:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (_) => ActiveParkingProvider(
        parkingService: ParkingService(),
      ),
    ),
  ],
  child: MaterialApp(...),
)
```

### Mengapa di Root Level?
1. **Global Access**: Semua screen dapat mengakses provider tanpa perlu pass data
2. **State Persistence**: State tetap ada saat navigasi antar screen
3. **Single Instance**: Hanya satu instance provider untuk seluruh aplikasi
4. **Automatic Disposal**: Provider otomatis di-dispose saat aplikasi ditutup

## Penggunaan di Screen

### ActivityPage
ActivityPage menggunakan provider dengan dua cara:

1. **Provider.of** untuk akses tanpa rebuild:
```dart
final provider = Provider.of<ActiveParkingProvider>(context, listen: false);
await provider.fetchActiveParking();
```

2. **Consumer** untuk reactive UI:
```dart
Consumer<ActiveParkingProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) {
      return LoadingWidget();
    }
    return DataWidget(data: provider.activeParking);
  },
)
```

## Testing

### Integration Tests
Integration tests membuat provider instance sendiri:
```dart
final testProvider = ActiveParkingProvider(parkingService: mockService);

await tester.pumpWidget(
  MaterialApp(
    home: ChangeNotifierProvider<ActiveParkingProvider>.value(
      value: testProvider,
      child: const ActivityPage(),
    ),
  ),
);
```

### Unit Tests
Unit tests langsung test provider tanpa UI:
```dart
final provider = ActiveParkingProvider(parkingService: mockService);
await provider.fetchActiveParking();
expect(provider.activeParking, isNotNull);
```

## Troubleshooting

### ProviderNotFoundException
**Masalah**: `Error: Could not find the correct Provider<ActiveParkingProvider>`

**Solusi**: 
- Pastikan `MultiProvider` ada di `main.dart` membungkus `MaterialApp`
- Pastikan `ChangeNotifierProvider` untuk `ActiveParkingProvider` sudah didaftarkan
- Pastikan screen yang menggunakan provider adalah child dari `MaterialApp`

### Provider Disposed Error
**Masalah**: `A ActiveParkingProvider was used after being disposed`

**Solusi**:
- Jangan simpan reference ke provider di variable
- Gunakan `Provider.of` atau `Consumer` setiap kali butuh akses
- Pastikan tidak ada async operation yang berjalan setelah dispose

## Best Practices

1. **Listen Parameter**: 
   - Gunakan `listen: false` jika hanya perlu call method
   - Gunakan `listen: true` (default) jika perlu rebuild saat state berubah

2. **Consumer vs Provider.of**:
   - Gunakan `Consumer` untuk rebuild sebagian widget tree
   - Gunakan `Provider.of` untuk akses di method/callback

3. **Error Handling**:
   - Selalu handle error dari provider
   - Tampilkan feedback ke user (snackbar, dialog, dll)
   - Sediakan retry mechanism

4. **Performance**:
   - Gunakan `Consumer` hanya untuk widget yang perlu rebuild
   - Gunakan `child` parameter di `Consumer` untuk widget static
   - Hindari rebuild seluruh screen jika tidak perlu

## Related Files

- `lib/main.dart` - Provider registration
- `lib/logic/providers/active_parking_provider.dart` - Provider implementation
- `lib/presentation/screens/activity_page.dart` - Provider usage example
- `test/integration/activity_page_integration_test.dart` - Integration tests
- `test/providers/active_parking_provider_test.dart` - Unit tests
