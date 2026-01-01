# Design Document - Vehicle Edit Feature

## Overview

Fitur Edit Kendaraan memungkinkan pengguna untuk mengubah informasi kendaraan yang sudah terdaftar tanpa perlu menghapus dan menambahkan ulang. Implementasi ini menggunakan pendekatan reuse dengan menambahkan mode edit pada halaman `VehicleSelectionPage` (tambah_kendaraan.dart) yang sudah ada, sehingga menghindari duplikasi kode dan menjaga konsistensi UI/UX.

### Key Design Principles

1. **Code Reuse**: Menggunakan satu halaman untuk dua mode operasi (add dan edit)
2. **Data Integrity**: Field kritis (jenis kendaraan, plat nomor) tidak dapat diubah saat edit
3. **Backward Compatibility**: Mode add tetap berfungsi seperti sebelumnya
4. **Consistent UX**: UI/UX yang konsisten antara mode add dan edit
5. **API Integration**: Menggunakan endpoint PUT yang sudah ada di backend

## Architecture

### Component Structure

```
VehicleDetailPage
    ↓ (navigasi dengan parameter)
VehicleSelectionPage (tambah_kendaraan.dart)
    ├── Mode Detection (isEditMode)
    ├── Data Prefilling (vehicle object)
    ├── Field State Management (editable vs read-only)
    ├── Form Validation
    └── API Integration
        ├── POST /api/kendaraan (add mode)
        └── PUT /api/kendaraan/{id} (edit mode)
```

### State Management Flow

```
VehicleDetailPage
    ↓
Navigator.push(VehicleSelectionPage(
    isEditMode: true,
    vehicle: vehicleObject
))
    ↓
VehicleSelectionPage._initState()
    ├── Detect mode (isEditMode)
    ├── Prefill form fields (if edit mode)
    └── Set field states (editable/read-only)
    ↓
User edits form
    ↓
User submits
    ↓
ProfileProvider.updateVehicle() (edit mode)
or
ProfileProvider.addVehicle() (add mode)
    ↓
Navigator.pop() + Success notification
```

## Components and Interfaces

### 1. VehicleSelectionPage (Modified)

**File**: `lib/presentation/screens/tambah_kendaraan.dart`

**Constructor Parameters**:
```dart
class VehicleSelectionPage extends StatefulWidget {
  final bool isEditMode;
  final VehicleModel? vehicle;
  
  const VehicleSelectionPage({
    super.key,
    this.isEditMode = false,
    this.vehicle,
  });
}
```

**State Variables** (additions):
```dart
class _VehicleSelectionPageState extends State<VehicleSelectionPage> {
  // Existing variables...
  
  // New: Track if in edit mode
  late bool _isEditMode;
  late VehicleModel? _editingVehicle;
  
  // New: Track original photo URL for edit mode
  String? _originalPhotoUrl;
}
```

**Key Methods** (modifications):

```dart
@override
void initState() {
  super.initState();
  
  // Detect mode
  _isEditMode = widget.isEditMode;
  _editingVehicle = widget.vehicle;
  
  // Prefill data if in edit mode
  if (_isEditMode && _editingVehicle != null) {
    _prefillFormData();
  }
  
  // Set default status if add mode
  if (!_isEditMode) {
    selectedVehicleStatus = vehicleStatuses[0];
  }
}

void _prefillFormData() {
  final vehicle = _editingVehicle!;
  
  // Prefill text fields
  brandController.text = vehicle.merk;
  typeController.text = vehicle.tipe;
  plateController.text = vehicle.platNomor;
  colorController.text = vehicle.warna ?? '';
  
  // Set vehicle type (read-only in edit mode)
  selectedVehicleType = vehicle.jenisKendaraan;
  
  // Set vehicle status
  selectedVehicleStatus = vehicle.isActive 
      ? "Kendaraan Utama" 
      : "Kendaraan Tamu";
  
  // Store original photo URL
  _originalPhotoUrl = vehicle.fotoUrl;
}

Future<void> _submitForm() async {
  // Validation (same for both modes)
  if (!_validateForm()) return;
  
  setState(() {
    isLoading = true;
  });
  
  try {
    final provider = context.read<ProfileProvider>();
    
    if (_isEditMode) {
      // Edit mode: use updateVehicle
      await provider.updateVehicle(
        id: _editingVehicle!.idKendaraan,
        merk: brandController.text.trim(),
        tipe: typeController.text.trim(),
        warna: colorController.text.trim(),
        isActive: selectedVehicleStatus == "Kendaraan Utama",
        foto: selectedImage, // null if not changed
      );
      
      if (mounted) {
        _showSnackbar('Kendaraan berhasil diperbarui!', isError: false);
        Navigator.of(context).pop(true);
      }
    } else {
      // Add mode: use addVehicle (existing logic)
      await provider.addVehicle(
        platNomor: plateController.text.trim().toUpperCase(),
        jenisKendaraan: selectedVehicleType!,
        merk: brandController.text.trim(),
        tipe: typeController.text.trim(),
        warna: colorController.text.trim(),
        isActive: selectedVehicleStatus == "Kendaraan Utama",
        foto: selectedImage,
      );
      
      if (mounted) {
        _showSnackbar('Kendaraan berhasil ditambahkan!', isError: false);
        Navigator.of(context).pop(true);
      }
    }
  } catch (e) {
    if (mounted) {
      _showSnackbar(
        _isEditMode 
            ? 'Gagal memperbarui kendaraan: $e' 
            : 'Gagal menambahkan kendaraan: $e',
        isError: true
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}
```

### 2. VehicleDetailPage (Modified)

**File**: `lib/presentation/screens/vehicle_detail_page.dart`

**Modified Method**:
```dart
Future<void> _handleEdit(BuildContext context) async {
  // Navigate to VehicleSelectionPage in edit mode
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => VehicleSelectionPage(
        isEditMode: true,
        vehicle: vehicle,
      ),
    ),
  );
  
  // If edit was successful, pop back to previous page
  if (result == true && context.mounted) {
    Navigator.of(context).pop();
  }
}
```

### 3. ProfileProvider (No Changes Required)

The existing `updateVehicle` method already supports all required parameters:

```dart
Future<void> updateVehicle({
  required String id,
  String? platNomor,
  String? jenisKendaraan,
  String? merk,
  String? tipe,
  String? warna,
  bool? isActive,
  File? foto,
}) async
```

### 4. VehicleApiService (No Changes Required)

The existing `updateVehicle` method already handles PUT requests with multipart support for photos.

## Data Models

### VehicleModel (No Changes Required)

The existing `VehicleModel` already contains all necessary fields:

```dart
class VehicleModel {
  final String idKendaraan;
  final String platNomor;
  final String jenisKendaraan;
  final String merk;
  final String tipe;
  final String? warna;
  final String? fotoUrl;
  final bool isActive;
  final VehicleStatistics? statistics;
}
```

## UI Components

### 1. Header Section

**Add Mode**:
```dart
Text('Tambah Kendaraan')
```

**Edit Mode**:
```dart
Text('Edit Kendaraan')
```

### 2. Photo Section

**Add Mode**: Empty placeholder with "Tambah Foto" text

**Edit Mode**: 
- If vehicle has photo: Display existing photo from `fotoUrl`
- If vehicle has no photo: Empty placeholder with "Tambah Foto" text
- Allow changing or removing photo in both cases

### 3. Vehicle Type Section

**Add Mode**: Interactive grid selection (existing behavior)

**Edit Mode**: Read-only display with visual distinction
```dart
Widget _buildVehicleTypeSection() {
  if (_isEditMode) {
    // Read-only display
    return _buildReadOnlyVehicleType();
  } else {
    // Interactive grid (existing)
    return _buildInteractiveVehicleTypeGrid();
  }
}

Widget _buildReadOnlyVehicleType() {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey.shade100, // Visual distinction
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Row(
      children: [
        Icon(_getVehicleIcon(selectedVehicleType!)),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jenis Kendaraan',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              selectedVehicleType!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Spacer(),
        Icon(Icons.lock, color: Colors.grey.shade400, size: 20),
      ],
    ),
  );
}
```

### 4. Plate Number Field

**Add Mode**: Editable TextField (existing behavior)

**Edit Mode**: Read-only TextField with visual distinction
```dart
TextField(
  controller: plateController,
  enabled: !_isEditMode, // Disabled in edit mode
  decoration: InputDecoration(
    labelText: 'Plat Nomor *',
    filled: _isEditMode,
    fillColor: _isEditMode ? Colors.grey.shade100 : null,
    suffixIcon: _isEditMode 
        ? Icon(Icons.lock, color: Colors.grey.shade400, size: 20)
        : null,
  ),
)
```

### 5. Editable Fields (Merek, Tipe, Warna)

Same behavior in both modes - fully editable TextField widgets

### 6. Vehicle Status Section

Same behavior in both modes - interactive radio selection

### 7. Submit Button

**Add Mode**:
```dart
Text('Tambahkan Kendaraan')
```

**Edit Mode**:
```dart
Text('Simpan Perubahan')
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Edit mode initialization with data prefilling

*For any* VehicleModel object, when VehicleSelectionPage is initialized with isEditMode=true and that vehicle object, all form fields should be prefilled with the corresponding values from the vehicle object.

**Validates: Requirements 1.1, 1.2**

### Property 2: Mode-specific field editability

*For any* field that should be read-only in edit mode (jenis kendaraan, plat nomor), when a user attempts to interact with that field in edit mode, the field value should remain unchanged.

**Validates: Requirements 2.3, 2.4**

### Property 3: Editable fields accept changes in edit mode

*For any* editable field (merek, tipe, warna) in edit mode, when a user inputs new text, the field value should update to reflect the new input.

**Validates: Requirements 3.1, 3.2, 3.3**

### Property 4: Photo manipulation in edit mode

*For any* vehicle in edit mode, when a user selects a new photo or removes the existing photo, the photo preview should update accordingly, and the new photo state should be submitted with the form.

**Validates: Requirements 3.4, 7.2**

### Property 5: Status selection in edit mode

*For any* vehicle in edit mode, when a user selects a different status option, the selected status should change and be submitted with the form.

**Validates: Requirements 3.5**

### Property 6: Add mode backward compatibility

*For any* form submission in add mode (isEditMode=false or null), the system should call ProfileProvider.addVehicle with POST request, maintaining existing behavior.

**Validates: Requirements 1.5**

### Property 7: Provider state update after successful edit

*For any* successful edit operation, the ProfileProvider's vehicle list should be updated to reflect the changes made to the vehicle.

**Validates: Requirements 5.2**

### Property 8: API error handling in edit mode

*For any* API error during edit operation, the system should display an error message and not navigate away from the page, allowing the user to retry.

**Validates: Requirements 5.4**

### Property 9: Form validation in edit mode

*For any* form submission attempt with invalid data (empty required fields) in edit mode, the system should prevent API call and display appropriate error messages.

**Validates: Requirements 6.4**

### Property 10: Valid data submission in edit mode

*For any* form submission with all valid data in edit mode, the system should call ProfileProvider.updateVehicle and navigate back on success.

**Validates: Requirements 6.5**

### Property 11: Photo preservation when unchanged

*For any* vehicle with existing photo in edit mode, when the user submits without changing the photo, the original photo URL should be preserved in the updated vehicle.

**Validates: Requirements 7.4**

## Error Handling

### Validation Errors

**Empty Required Fields**:
- Merek: "Masukkan merek kendaraan"
- Tipe: "Masukkan tipe kendaraan"
- Warna: "Warna kendaraan wajib diisi"
- Plat Nomor (add mode only): "Masukkan plat nomor kendaraan"
- Jenis Kendaraan (add mode only): "Pilih jenis kendaraan terlebih dahulu"

**Invalid Format**:
- Plat Nomor (add mode only): "Format plat nomor tidak valid (contoh: B 1234 XYZ)"

### API Errors

**Network Errors**:
- Display: "Koneksi internet bermasalah. Silakan periksa koneksi Anda."
- Action: Allow retry

**Server Errors (500)**:
- Display: "Server sedang bermasalah. Silakan coba beberapa saat lagi."
- Action: Allow retry

**Not Found (404)**:
- Display: "Kendaraan tidak ditemukan."
- Action: Navigate back to previous page

**Validation Errors (422)**:
- Display: Specific error messages from API
- Action: Allow correction and retry

**Unauthorized (401)**:
- Display: "Sesi Anda telah berakhir. Silakan login kembali."
- Action: Navigate to login page

### Photo Upload Errors

**File Too Large**:
- Display: "Ukuran foto terlalu besar. Maksimal 5MB."
- Action: Allow selecting different photo

**Invalid Format**:
- Display: "Format foto tidak didukung. Gunakan JPG atau PNG."
- Action: Allow selecting different photo

**Upload Failed**:
- Display: "Gagal mengunggah foto. Silakan coba lagi."
- Action: Allow retry

## Testing Strategy

### Unit Tests

1. **Mode Detection Tests**
   - Test isEditMode parameter correctly sets internal state
   - Test null/false isEditMode defaults to add mode
   - Test vehicle parameter is correctly stored

2. **Data Prefilling Tests**
   - Test all fields are prefilled with vehicle data in edit mode
   - Test empty/null fields are handled gracefully
   - Test photo URL is correctly loaded

3. **Field State Tests**
   - Test jenis kendaraan field is disabled in edit mode
   - Test plat nomor field is disabled in edit mode
   - Test editable fields remain enabled in edit mode
   - Test all fields are enabled in add mode

4. **Validation Tests**
   - Test empty merek shows error in edit mode
   - Test empty tipe shows error in edit mode
   - Test empty warna shows error in edit mode
   - Test validation prevents submission with invalid data

5. **Submit Logic Tests**
   - Test edit mode calls ProfileProvider.updateVehicle
   - Test add mode calls ProfileProvider.addVehicle
   - Test correct parameters are passed to provider methods
   - Test navigation occurs after successful submission

6. **UI Text Tests**
   - Test header shows "Edit Kendaraan" in edit mode
   - Test header shows "Tambah Kendaraan" in add mode
   - Test button shows "Simpan Perubahan" in edit mode
   - Test button shows "Tambahkan Kendaraan" in add mode

### Property-Based Tests

Property-based tests will use the `test` package with custom generators for VehicleModel objects.

**Test Configuration**: Each property test should run minimum 100 iterations.

**Property Test 1: Edit mode data prefilling**
```dart
// Feature: vehicle-edit-feature, Property 1: Edit mode initialization with data prefilling
test('Property 1: Edit mode prefills all fields correctly', () {
  // Generate random vehicles and verify prefilling
  for (int i = 0; i < 100; i++) {
    final vehicle = generateRandomVehicle();
    // Test that all fields match vehicle data
  }
});
```
**Validates: Requirements 1.1, 1.2**

**Property Test 2: Read-only field immutability**
```dart
// Feature: vehicle-edit-feature, Property 2: Mode-specific field editability
test('Property 2: Read-only fields cannot be changed in edit mode', () {
  // Generate random vehicles and attempt to change read-only fields
  for (int i = 0; i < 100; i++) {
    final vehicle = generateRandomVehicle();
    // Test that jenis and plat remain unchanged after interaction
  }
});
```
**Validates: Requirements 2.3, 2.4**

**Property Test 3: Editable fields accept input**
```dart
// Feature: vehicle-edit-feature, Property 3: Editable fields accept changes in edit mode
test('Property 3: Editable fields update with new input', () {
  // Generate random vehicles and random new values
  for (int i = 0; i < 100; i++) {
    final vehicle = generateRandomVehicle();
    final newMerk = generateRandomString();
    // Test that editable fields update correctly
  }
});
```
**Validates: Requirements 3.1, 3.2, 3.3**

**Property Test 4: Photo state management**
```dart
// Feature: vehicle-edit-feature, Property 4: Photo manipulation in edit mode
test('Property 4: Photo changes are tracked correctly', () {
  // Generate random vehicles with/without photos
  for (int i = 0; i < 100; i++) {
    final vehicle = generateRandomVehicle();
    // Test photo selection, removal, and preservation
  }
});
```
**Validates: Requirements 3.4, 7.2**

**Property Test 5: Status selection**
```dart
// Feature: vehicle-edit-feature, Property 5: Status selection in edit mode
test('Property 5: Status changes are applied correctly', () {
  // Generate random vehicles with different statuses
  for (int i = 0; i < 100; i++) {
    final vehicle = generateRandomVehicle();
    // Test status toggle and submission
  }
});
```
**Validates: Requirements 3.5**

**Property Test 6: Add mode compatibility**
```dart
// Feature: vehicle-edit-feature, Property 6: Add mode backward compatibility
test('Property 6: Add mode uses POST request', () {
  // Test with isEditMode=false and null
  for (int i = 0; i < 100; i++) {
    // Verify addVehicle is called, not updateVehicle
  }
});
```
**Validates: Requirements 1.5**

**Property Test 7: Provider state synchronization**
```dart
// Feature: vehicle-edit-feature, Property 7: Provider state update after successful edit
test('Property 7: Provider updates after successful edit', () {
  // Generate random vehicles and edits
  for (int i = 0; i < 100; i++) {
    final vehicle = generateRandomVehicle();
    final updates = generateRandomUpdates();
    // Verify provider's vehicle list reflects changes
  }
});
```
**Validates: Requirements 5.2**

**Property Test 8: Error handling**
```dart
// Feature: vehicle-edit-feature, Property 8: API error handling in edit mode
test('Property 8: Errors are displayed and allow retry', () {
  // Generate random API errors
  for (int i = 0; i < 100; i++) {
    final error = generateRandomApiError();
    // Verify error message shown and no navigation
  }
});
```
**Validates: Requirements 5.4**

**Property Test 9: Validation enforcement**
```dart
// Feature: vehicle-edit-feature, Property 9: Form validation in edit mode
test('Property 9: Invalid data prevents submission', () {
  // Generate random invalid form states
  for (int i = 0; i < 100; i++) {
    final invalidData = generateInvalidFormData();
    // Verify no API call and error messages shown
  }
});
```
**Validates: Requirements 6.4**

**Property Test 10: Valid submission**
```dart
// Feature: vehicle-edit-feature, Property 10: Valid data submission in edit mode
test('Property 10: Valid data triggers update and navigation', () {
  // Generate random valid form data
  for (int i = 0; i < 100; i++) {
    final validData = generateValidFormData();
    // Verify updateVehicle called and navigation occurs
  }
});
```
**Validates: Requirements 6.5**

**Property Test 11: Photo preservation**
```dart
// Feature: vehicle-edit-feature, Property 11: Photo preservation when unchanged
test('Property 11: Unchanged photo is preserved', () {
  // Generate random vehicles with photos
  for (int i = 0; i < 100; i++) {
    final vehicle = generateRandomVehicleWithPhoto();
    // Submit without changing photo
    // Verify original photo URL is maintained
  }
});
```
**Validates: Requirements 7.4**

### Integration Tests

1. **Full Edit Flow Test**
   - Navigate from VehicleDetailPage to edit mode
   - Modify vehicle data
   - Submit changes
   - Verify data persists and UI updates

2. **Navigation Flow Test**
   - Test back button behavior (no save)
   - Test successful save navigation
   - Test error state navigation

3. **Photo Upload Flow Test**
   - Select photo in edit mode
   - Submit with new photo
   - Verify photo is uploaded and URL updated

### Widget Tests

1. **VehicleSelectionPage Widget Tests**
   - Test widget builds correctly in add mode
   - Test widget builds correctly in edit mode
   - Test read-only fields have correct styling
   - Test button text changes based on mode
   - Test header text changes based on mode

2. **VehicleDetailPage Widget Tests**
   - Test edit button navigates correctly
   - Test edit button passes correct parameters

## Performance Considerations

### Image Loading

- Use `CachedNetworkImage` for existing vehicle photos in edit mode
- Implement placeholder and error widgets for better UX
- Compress images before upload (already implemented in add mode)

### Form State Management

- Use `TextEditingController` for efficient text field management
- Dispose controllers properly to prevent memory leaks
- Use `setState` judiciously to minimize rebuilds

### API Calls

- Implement loading states during API calls
- Use timeout for API requests (30 seconds)
- Cache vehicle data to reduce unnecessary API calls

## Security Considerations

### Data Validation

- Validate all input on client side before submission
- Rely on backend validation as final authority
- Sanitize user input to prevent injection attacks

### Authentication

- Ensure auth token is included in all API requests
- Handle 401 errors by redirecting to login
- Implement token refresh if needed

### Photo Upload

- Validate file type and size before upload
- Use secure HTTPS for all API communication
- Implement proper error handling for upload failures

## Accessibility

### Screen Reader Support

- Add semantic labels to all interactive elements
- Provide hints for read-only fields explaining why they can't be edited
- Announce mode changes ("Edit mode" vs "Add mode")

### Keyboard Navigation

- Ensure all interactive elements are keyboard accessible
- Implement proper tab order
- Skip read-only fields in tab navigation in edit mode

### Visual Accessibility

- Maintain sufficient color contrast for read-only fields
- Use icons in addition to color to indicate read-only state
- Ensure touch targets are at least 44x44 points

## Migration Strategy

### Phase 1: Core Implementation
1. Modify VehicleSelectionPage to accept mode parameters
2. Implement data prefilling logic
3. Implement read-only field rendering
4. Update submit logic to handle both modes

### Phase 2: Navigation Integration
1. Update VehicleDetailPage edit button
2. Test navigation flow
3. Verify data passing between pages

### Phase 3: Testing
1. Write unit tests for new functionality
2. Write property-based tests
3. Write integration tests
4. Perform manual testing

### Phase 4: Polish
1. Refine UI for read-only fields
2. Improve error messages
3. Add loading states
4. Optimize performance

## Future Enhancements

1. **Batch Edit**: Allow editing multiple vehicles at once
2. **Edit History**: Track changes made to vehicles over time
3. **Undo/Redo**: Allow users to undo changes before submitting
4. **Draft Saving**: Save incomplete edits as drafts
5. **Conflict Resolution**: Handle concurrent edits by multiple users
