# Vehicle Data Flow & Design Explanation

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                         UI Layer                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ List Page    │  │ Add Page     │  │ Detail Page  │      │
│  │ (View)       │  │ (Create)     │  │ (View/Edit)  │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                  │                  │              │
└─────────┼──────────────────┼──────────────────┼──────────────┘
          │                  │                  │
          └──────────────────┼──────────────────┘
                             │
                    ┌────────▼────────┐
                    │ ProfileProvider │ ◄─── State Management
                    │  (ChangeNotifier)│
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ ProfileService  │ ◄─── Business Logic
                    │  (API Calls)    │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  Backend API    │ ◄─── Data Source
                    │  (Laravel)      │
                    └─────────────────┘
```

## Data Flow Explanation

### 1. Adding a Vehicle

```
User Action → UI Validation → Provider → Service → API → Database
     ↓            ↓              ↓          ↓        ↓        ↓
  Tap Add    Check fields   addVehicle   POST    Store    Return ID
     ↓            ↓              ↓          ↓        ↓        ↓
  Fill Form  Show errors   notifyListeners Response Success  Update UI
```

**Step-by-Step:**

1. **User fills form** in `tambah_kendaraan.dart`
   - Selects vehicle type (required)
   - Enters brand, type, plate number (required)
   - Optionally adds photo and color
   - Selects vehicle status

2. **Client-side validation**
   - Check required fields
   - Validate plate number format
   - Show immediate feedback

3. **Submit to ProfileProvider**
   ```dart
   await context.read<ProfileProvider>().addVehicle(newVehicle);
   ```

4. **Provider processes request**
   - Calls ProfileService (when implemented)
   - Updates local state
   - Notifies all listeners

5. **Service makes API call** (future implementation)
   ```dart
   POST /api/vehicles
   {
     "plat_nomor": "B 1234 XYZ",
     "jenis_kendaraan": "Roda Empat",
     "merk": "Toyota",
     "tipe": "Avanza",
     "warna": "Hitam",
     "is_active": true
   }
   ```

6. **Backend processes**
   - Validates data
   - Assigns unique ID
   - Sets timestamps (created_at, updated_at)
   - Stores in database
   - Returns vehicle with ID

7. **UI updates automatically**
   - Provider notifies listeners
   - List page rebuilds
   - Shows success message

### 2. Viewing Vehicle List

```
Page Load → Fetch Data → Display → User Interaction
    ↓           ↓           ↓            ↓
 initState  fetchVehicles  Build UI   Tap/Swipe
    ↓           ↓           ↓            ↓
  Provider    API Call    Consumer    Navigate
```

**Step-by-Step:**

1. **Page initialization**
   ```dart
   @override
   void initState() {
     super.initState();
     WidgetsBinding.instance.addPostFrameCallback((_) {
       context.read<ProfileProvider>().fetchVehicles();
     });
   }
   ```

2. **Provider fetches data**
   - Sets loading state
   - Calls API
   - Updates vehicle list
   - Notifies listeners

3. **UI rebuilds with Consumer**
   ```dart
   Consumer<ProfileProvider>(
     builder: (context, provider, child) {
       if (provider.isLoading) return LoadingWidget();
       if (provider.vehicles.isEmpty) return EmptyState();
       return VehicleList(vehicles: provider.vehicles);
     },
   )
   ```

4. **User interactions**
   - Tap card → Navigate to detail
   - Tap delete → Show confirmation
   - Pull down → Refresh list
   - Tap FAB → Navigate to add page

### 3. Deleting a Vehicle

```
User Tap → Confirmation → Provider → Service → API → Database
    ↓          ↓             ↓          ↓        ↓        ↓
 Delete    Show Dialog  deleteVehicle DELETE  Remove   Success
    ↓          ↓             ↓          ↓        ↓        ↓
 Confirm   User Choice  notifyListeners Response Update  Rebuild UI
```

**Step-by-Step:**

1. **User taps delete icon**
   - Shows confirmation dialog
   - Displays vehicle details

2. **User confirms deletion**
   ```dart
   await context.read<ProfileProvider>().deleteVehicle(vehicleId);
   ```

3. **Provider removes vehicle**
   - Calls API to delete
   - Removes from local list
   - Notifies listeners

4. **UI updates**
   - List rebuilds without deleted vehicle
   - Shows success message

## Timestamp Management

### Created At (Input Time)
```
User submits form
       ↓
Backend receives request
       ↓
Backend sets: created_at = NOW()
       ↓
Stored in database
       ↓
Returned to client
       ↓
Displayed in UI (if needed)
```

**Key Points:**
- ✅ Set by backend/system
- ✅ Never modified after creation
- ✅ Not editable by user
- ✅ Used for sorting and history

### Last Used At (Last Parking Time)
```
User parks vehicle
       ↓
Booking/Transaction created
       ↓
Backend updates: last_used_at = NOW()
       ↓
Stored in database
       ↓
Fetched with vehicle data
       ↓
Displayed in statistics
```

**Key Points:**
- ✅ System-managed field
- ✅ Updated automatically on parking
- ✅ Not shown in add/edit forms
- ✅ Used for statistics and sorting

## Design Decisions Explained

### 1. Why ProfileProvider Instead of Direct API Calls?

**Benefits:**
- ✅ Single source of truth
- ✅ Automatic UI updates
- ✅ Easy state management
- ✅ Reduced boilerplate
- ✅ Better testability

**Example:**
```dart
// ❌ Without Provider (manual state management)
class VehicleListPage extends StatefulWidget {
  @override
  State<VehicleListPage> createState() => _VehicleListPageState();
}

class _VehicleListPageState extends State<VehicleListPage> {
  List<VehicleModel> vehicles = [];
  bool isLoading = false;
  
  Future<void> fetchVehicles() async {
    setState(() => isLoading = true);
    final response = await api.getVehicles();
    setState(() {
      vehicles = response;
      isLoading = false;
    });
  }
  
  // Need to manually manage state in every method
}

// ✅ With Provider (automatic state management)
class VehicleListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        // UI automatically updates when provider changes
        return VehicleList(vehicles: provider.vehicles);
      },
    );
  }
}
```

### 2. Why Optional Photo Field?

**Reasons:**
- ✅ Reduces friction in registration
- ✅ Not essential for parking functionality
- ✅ Can be added later
- ✅ Saves storage space
- ✅ Faster form completion

**User Flow:**
```
Quick Registration (No Photo):
User → Select Type → Enter Details → Submit
Time: ~30 seconds

With Photo:
User → Select Type → Take/Choose Photo → Enter Details → Submit
Time: ~60-90 seconds
```

### 3. Why Vehicle Status Instead of Customer Type?

**Old Approach (Customer Type):**
- ❌ "Operasional", "Kantor", "Perusahaan"
- ❌ Not relevant to end users
- ❌ Confusing terminology
- ❌ Business-focused, not user-focused

**New Approach (Vehicle Status):**
- ✅ "Kendaraan Utama", "Kendaraan Tamu"
- ✅ Clear user benefit
- ✅ Aligns with "active vehicle" concept
- ✅ User-centric language

**Mapping:**
```dart
// Internal logic can still map to backend if needed
String getBackendType(String status) {
  return status == "Kendaraan Utama" ? "primary" : "guest";
}
```

### 4. Why Plate Number Validation?

**Benefits:**
- ✅ Data quality assurance
- ✅ Prevents typos
- ✅ Consistent format
- ✅ Easier verification
- ✅ Better search functionality

**Validation Logic:**
```dart
// Indonesian plate format: [1-2 letters] [1-4 digits] [1-3 letters]
// Examples: B 1234 XYZ, AB 123 CD, D 5678 EF

final plateRegex = RegExp(
  r'^[A-Z]{1,2}\s?\d{1,4}\s?[A-Z]{1,3}$',
  caseSensitive: false
);

// Accepts with or without spaces
// B1234XYZ → Valid
// B 1234 XYZ → Valid
// B-1234-XYZ → Invalid (wrong separator)
```

### 5. Why No STNK Data?

**Security Concerns:**
- ❌ STNK contains sensitive personal information
- ❌ Not necessary for parking app
- ❌ Increases data breach risk
- ❌ Compliance issues (data protection)

**Practical Reasons:**
- ❌ Users reluctant to share
- ❌ Adds complexity
- ❌ Not used in parking operations
- ❌ Maintenance burden

**What We Store Instead:**
```dart
// ✅ Minimal necessary data
{
  "plat_nomor": "B 1234 XYZ",  // Public identifier
  "jenis_kendaraan": "Roda Empat",  // For parking slot
  "merk": "Toyota",  // For identification
  "tipe": "Avanza",  // For identification
  "warna": "Hitam"  // Optional, for identification
}

// ❌ Sensitive data we DON'T store
{
  "stnk_number": "...",  // Not needed
  "owner_name": "...",  // Already have user data
  "owner_address": "...",  // Privacy concern
  "engine_number": "...",  // Not relevant
  "chassis_number": "..."  // Not relevant
}
```

## State Management Flow

### Provider Pattern
```dart
// 1. Provider holds state
class ProfileProvider extends ChangeNotifier {
  List<VehicleModel> _vehicles = [];
  
  List<VehicleModel> get vehicles => _vehicles;
  
  Future<void> addVehicle(VehicleModel vehicle) async {
    _vehicles.add(vehicle);
    notifyListeners();  // ← Triggers UI rebuild
  }
}

// 2. UI listens to changes
Consumer<ProfileProvider>(
  builder: (context, provider, child) {
    // Rebuilds automatically when notifyListeners() is called
    return ListView(
      children: provider.vehicles.map((v) => VehicleCard(v)).toList(),
    );
  },
)

// 3. UI triggers actions
ElevatedButton(
  onPressed: () {
    context.read<ProfileProvider>().addVehicle(newVehicle);
    // ↑ This calls notifyListeners() internally
    // ↓ Which triggers Consumer to rebuild
  },
)
```

### Why This Works Well

**Automatic Updates:**
```
Add Vehicle Page → Provider.addVehicle() → notifyListeners()
                                                  ↓
                                          All Consumers rebuild
                                                  ↓
                                    ┌─────────────┴─────────────┐
                                    ↓                           ↓
                            List Page updates          Detail Page updates
```

**Single Source of Truth:**
```
                    ┌─────────────────┐
                    │ ProfileProvider │ ← Single state holder
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              ↓              ↓              ↓
         List Page      Add Page      Detail Page
         (reads)        (writes)      (reads/writes)
```

## Error Handling Strategy

### Layered Error Handling
```
UI Layer:
  ↓ User-friendly messages
  ↓ Visual feedback
  ↓ Retry options

Provider Layer:
  ↓ Catch exceptions
  ↓ Convert to user messages
  ↓ Update error state

Service Layer:
  ↓ API error handling
  ↓ Network error handling
  ↓ Timeout handling

API Layer:
  ↓ HTTP status codes
  ↓ Error responses
  ↓ Validation errors
```

### Example Error Flow
```dart
// 1. API returns error
Response: 422 Unprocessable Entity
{
  "message": "Validation failed",
  "errors": {
    "plat_nomor": ["Plat nomor sudah terdaftar"]
  }
}

// 2. Service catches and throws
throw Exception("Plat nomor sudah terdaftar");

// 3. Provider catches and converts
catch (e) {
  _errorMessage = _getUserFriendlyError(e.toString());
  notifyListeners();
}

// 4. UI displays to user
SnackBar(
  content: Text("Plat nomor sudah terdaftar"),
  backgroundColor: Colors.red[400],
)
```

## Performance Considerations

### Optimizations Implemented

1. **Lazy Loading**
   ```dart
   // Only fetch when needed
   @override
   void initState() {
     super.initState();
     WidgetsBinding.instance.addPostFrameCallback((_) {
       context.read<ProfileProvider>().fetchVehicles();
     });
   }
   ```

2. **Image Compression**
   ```dart
   final XFile? image = await picker.pickImage(
     source: ImageSource.camera,
     maxWidth: 1024,  // ← Limit size
     maxHeight: 1024,
     imageQuality: 85,  // ← Compress
   );
   ```

3. **Efficient Rebuilds**
   ```dart
   // Only rebuild when vehicles change
   Consumer<ProfileProvider>(
     builder: (context, provider, child) {
       return VehicleList(vehicles: provider.vehicles);
     },
   )
   ```

4. **Unmodifiable Lists**
   ```dart
   // Prevent accidental modifications
   List<VehicleModel> get vehicles => List.unmodifiable(_vehicles);
   ```

## Testing Strategy

### Unit Tests
- ✅ Plate number validation
- ✅ Vehicle model serialization
- ✅ Provider state changes

### Widget Tests
- ✅ Form rendering
- ✅ Validation messages
- ✅ Button states
- ✅ Navigation

### Integration Tests
- ✅ Complete add flow
- ✅ List refresh
- ✅ Delete flow
- ✅ Provider integration

## Conclusion

The vehicle management system is designed with:
- ✅ **Clear separation of concerns** (UI, State, Service, API)
- ✅ **Automatic state management** (Provider pattern)
- ✅ **User-centric design** (simple, clear, focused)
- ✅ **Data quality** (validation, consistent format)
- ✅ **Security** (minimal sensitive data)
- ✅ **Performance** (optimized images, efficient rebuilds)
- ✅ **Maintainability** (clean code, good documentation)

This architecture makes it easy to:
- Add new features
- Fix bugs
- Test components
- Scale the application
- Onboard new developers
