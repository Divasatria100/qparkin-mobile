# Vehicle Management Quick Reference

## Quick Start

### Add the dependency:
```bash
flutter pub get
```

### Import required packages:
```dart
import 'package:provider/provider.dart';
import '../../logic/providers/profile_provider.dart';
import '../../data/models/vehicle_model.dart';
```

## Common Tasks

### 1. Navigate to Add Vehicle Page
```dart
final result = await Navigator.of(context).push<bool>(
  PageTransitions.slideFromRight(
    page: const VehicleSelectionPage(),
  ),
);

if (result == true) {
  // Vehicle was added successfully
  context.read<ProfileProvider>().fetchVehicles();
}
```

### 2. Add a Vehicle
```dart
final newVehicle = VehicleModel(
  idKendaraan: 'temp_id', // Backend will assign real ID
  platNomor: 'B 1234 XYZ',
  jenisKendaraan: 'Roda Empat',
  merk: 'Toyota',
  tipe: 'Avanza',
  warna: 'Hitam',
  isActive: true,
);

await context.read<ProfileProvider>().addVehicle(newVehicle);
```

### 3. Delete a Vehicle
```dart
await context.read<ProfileProvider>().deleteVehicle(vehicleId);
```

### 4. Set Active Vehicle
```dart
await context.read<ProfileProvider>().setActiveVehicle(vehicleId);
```

### 5. Get Vehicle List
```dart
final vehicles = context.watch<ProfileProvider>().vehicles;
```

### 6. Refresh Vehicle List
```dart
await context.read<ProfileProvider>().fetchVehicles();
```

## Validation

### Plate Number Format
```dart
final plateRegex = RegExp(r'^[A-Z]{1,2}\s?\d{1,4}\s?[A-Z]{1,3}$', caseSensitive: false);
bool isValid = plateRegex.hasMatch(plateNumber);
```

**Valid Examples:**
- B 1234 XYZ
- AB 123 CD
- D 5678 EF

**Invalid Examples:**
- 1234 ABC (no prefix)
- B-1234-XYZ (wrong separator)
- B 12345 XYZ (too many digits)

## Vehicle Types

```dart
const vehicleTypes = [
  'Roda Dua',           // Two-wheeler (motorcycle, scooter)
  'Roda Tiga',          // Three-wheeler (tricycle)
  'Roda Empat',         // Four-wheeler (car, SUV)
  'Lebih dari Enam',    // More than six wheels (truck, bus)
];
```

## Vehicle Status

```dart
const vehicleStatuses = [
  'Kendaraan Utama',    // Main vehicle (frequently used)
  'Kendaraan Tamu',     // Guest vehicle (backup/guest)
];
```

## Icons Mapping

```dart
IconData getVehicleIcon(String jenisKendaraan) {
  switch (jenisKendaraan.toLowerCase()) {
    case 'roda dua':
      return Icons.two_wheeler;
    case 'roda tiga':
      return Icons.electric_rickshaw;
    case 'roda empat':
      return Icons.directions_car;
    default:
      return Icons.local_shipping;
  }
}
```

## Snackbar Messages

### Success Message
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Kendaraan berhasil ditambahkan!'),
    backgroundColor: Color(0xFF4CAF50),
    behavior: SnackBarBehavior.floating,
  ),
);
```

### Error Message
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Gagal menambahkan kendaraan'),
    backgroundColor: Colors.red[400],
    behavior: SnackBarBehavior.floating,
  ),
);
```

## Color Scheme

```dart
// Primary colors
const primaryPurple = Color(0xFF573ED1);
const lightPurple = Color(0xFF7C5ED1);

// Success
const successGreen = Color(0xFF4CAF50);

// Error
const errorRed = Colors.red; // or Colors.red[400]

// Neutral
const greyBorder = Colors.grey.shade200;
const greyText = Colors.grey.shade600;
```

## Common Patterns

### Loading State
```dart
Consumer<ProfileProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF573ED1)),
        ),
      );
    }
    
    return YourContent();
  },
)
```

### Empty State
```dart
if (vehicles.isEmpty) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.directions_car_outlined, size: 80, color: Colors.grey.shade300),
        SizedBox(height: 16),
        Text('Belum Ada Kendaraan', style: TextStyle(fontSize: 18)),
      ],
    ),
  );
}
```

### Confirmation Dialog
```dart
final confirmed = await showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Hapus Kendaraan'),
    content: Text('Apakah Anda yakin?'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: Text('Batal'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, true),
        child: Text('Hapus'),
      ),
    ],
  ),
);

if (confirmed == true) {
  // Proceed with deletion
}
```

## Error Handling

```dart
try {
  await context.read<ProfileProvider>().addVehicle(vehicle);
  // Show success message
} catch (e) {
  // Show error message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Gagal menambahkan kendaraan: $e'),
      backgroundColor: Colors.red[400],
    ),
  );
}
```

## Image Picker Usage

### Pick from Camera
```dart
final ImagePicker picker = ImagePicker();
final XFile? image = await picker.pickImage(
  source: ImageSource.camera,
  maxWidth: 1024,
  maxHeight: 1024,
  imageQuality: 85,
);

if (image != null) {
  setState(() {
    selectedImage = File(image.path);
  });
}
```

### Pick from Gallery
```dart
final XFile? image = await picker.pickImage(
  source: ImageSource.gallery,
  maxWidth: 1024,
  maxHeight: 1024,
  imageQuality: 85,
);
```

## Testing Snippets

### Mock Vehicle Data
```dart
final mockVehicle = VehicleModel(
  idKendaraan: '1',
  platNomor: 'B 1234 XYZ',
  jenisKendaraan: 'Roda Empat',
  merk: 'Toyota',
  tipe: 'Avanza',
  warna: 'Hitam',
  isActive: true,
);
```

### Test Plate Number Validation
```dart
test('validates plate number format', () {
  final regex = RegExp(r'^[A-Z]{1,2}\s?\d{1,4}\s?[A-Z]{1,3}$', caseSensitive: false);
  
  expect(regex.hasMatch('B 1234 XYZ'), true);
  expect(regex.hasMatch('AB 123 CD'), true);
  expect(regex.hasMatch('1234 ABC'), false);
  expect(regex.hasMatch('B-1234-XYZ'), false);
});
```

## Troubleshooting

### Issue: Image picker not working
**Solution:** Add permissions to AndroidManifest.xml and Info.plist
```xml
<!-- Android -->
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

```xml
<!-- iOS -->
<key>NSCameraUsageDescription</key>
<string>Aplikasi memerlukan akses kamera untuk foto kendaraan</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Aplikasi memerlukan akses galeri untuk foto kendaraan</string>
```

### Issue: Provider not updating UI
**Solution:** Use `context.watch<ProfileProvider>()` in build method or wrap with `Consumer`

### Issue: Navigation not working
**Solution:** Ensure PageTransitions is imported and context is valid

## Best Practices

1. **Always validate input** before submitting
2. **Show loading states** during async operations
3. **Handle errors gracefully** with user-friendly messages
4. **Use consistent styling** across all pages
5. **Provide feedback** for all user actions
6. **Test on different screen sizes**
7. **Consider accessibility** in all UI elements
8. **Keep forms simple** and focused
9. **Use proper state management** (Provider)
10. **Document your code** for future maintainers

## Related Files

- `lib/presentation/screens/tambah_kendaraan.dart` - Add vehicle page
- `lib/presentation/screens/list_kendaraan.dart` - Vehicle list page
- `lib/presentation/screens/vehicle_detail_page.dart` - Vehicle detail page
- `lib/data/models/vehicle_model.dart` - Vehicle data model
- `lib/logic/providers/profile_provider.dart` - State management
- `lib/utils/page_transitions.dart` - Navigation animations

## Support

For questions or issues, refer to:
- Main documentation: `docs/vehicle_management_update_summary.md`
- Profile documentation: `docs/PROFILE_DOCUMENTATION_README.md`
- Reusable components: `docs/reusable_components_guide.md`
