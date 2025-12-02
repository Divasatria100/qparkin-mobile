# ProfileProvider API Documentation

## Overview

`ProfileProvider` is a state management class that extends `ChangeNotifier` to manage user profile data and vehicle information in the QPARKIN application. It provides a centralized, reactive way to handle profile-related operations including data fetching, updates, and CRUD operations for vehicles.

## Location

```
lib/logic/providers/profile_provider.dart
```

## Class Definition

```dart
class ProfileProvider extends ChangeNotifier {
  // Implementation
}
```

## State Properties

### User Data

```dart
UserModel? get user
```
Returns the current user model or `null` if not loaded.

**Example:**
```dart
final provider = Provider.of<ProfileProvider>(context);
final userName = provider.user?.name ?? 'Guest';
```

### Vehicle List

```dart
List<VehicleModel> get vehicles
```
Returns the list of user's registered vehicles.

**Example:**
```dart
final provider = Provider.of<ProfileProvider>(context);
final vehicleCount = provider.vehicles.length;
```

### Loading State

```dart
bool get isLoading
```
Indicates whether an API operation is in progress.

**Example:**
```dart
if (provider.isLoading) {
  return CircularProgressIndicator();
}
```

### Error State

```dart
String? get errorMessage
bool get hasError
```
- `errorMessage`: Contains the error message if an error occurred
- `hasError`: Returns `true` if there's an active error

**Example:**
```dart
if (provider.hasError) {
  return Text(provider.errorMessage ?? 'Unknown error');
}
```

### Last Sync Time

```dart
DateTime? get lastSyncTime
```
Returns the timestamp of the last successful data sync.

**Example:**
```dart
final lastSync = provider.lastSyncTime;
if (lastSync != null) {
  print('Last synced: ${timeago.format(lastSync)}');
}
```

## Methods

### User Operations

#### fetchUserData()

Fetches user profile data from the API.

```dart
Future<void> fetchUserData()
```

**Usage:**
```dart
final provider = Provider.of<ProfileProvider>(context, listen: false);
await provider.fetchUserData();
```

**Behavior:**
- Sets `isLoading` to `true` during fetch
- Updates `user` property on success
- Sets `errorMessage` on failure
- Notifies all listeners after completion

#### updateUser()

Updates user profile information.

```dart
Future<void> updateUser(UserModel updatedUser)
```

**Parameters:**
- `updatedUser`: The updated user model with new information

**Usage:**
```dart
final updatedUser = currentUser.copyWith(
  name: 'New Name',
  email: 'newemail@example.com',
);
await provider.updateUser(updatedUser);
```

**Behavior:**
- Validates user data before sending
- Sends update request to API
- Updates local `user` property on success
- Shows success/error feedback

### Vehicle Operations

#### fetchVehicles()

Fetches the list of user's vehicles from the API.

```dart
Future<void> fetchVehicles()
```

**Usage:**
```dart
await provider.fetchVehicles();
```

**Behavior:**
- Sets `isLoading` to `true` during fetch
- Updates `vehicles` list on success
- Sets `errorMessage` on failure

#### addVehicle()

Adds a new vehicle to the user's account.

```dart
Future<void> addVehicle(VehicleModel vehicle)
```

**Parameters:**
- `vehicle`: The vehicle model to add

**Usage:**
```dart
final newVehicle = VehicleModel(
  id: '', // Will be assigned by backend
  userId: currentUser.id,
  name: 'My Car',
  plate: 'B1234XYZ',
  type: 'car',
  isActive: false,
  createdAt: DateTime.now(),
);
await provider.addVehicle(newVehicle);
```

**Behavior:**
- Validates vehicle data
- Sends create request to API
- Adds vehicle to local list on success
- Notifies listeners

#### updateVehicle()

Updates an existing vehicle's information.

```dart
Future<void> updateVehicle(VehicleModel vehicle)
```

**Parameters:**
- `vehicle`: The updated vehicle model

**Usage:**
```dart
final updatedVehicle = existingVehicle.copyWith(
  name: 'Updated Name',
  plate: 'B5678ABC',
);
await provider.updateVehicle(updatedVehicle);
```

#### deleteVehicle()

Deletes a vehicle from the user's account.

```dart
Future<void> deleteVehicle(String vehicleId)
```

**Parameters:**
- `vehicleId`: The ID of the vehicle to delete

**Usage:**
```dart
await provider.deleteVehicle('vehicle-123');
```

**Behavior:**
- Sends delete request to API
- Removes vehicle from local list on success
- If deleted vehicle was active, sets another vehicle as active

#### setActiveVehicle()

Sets a specific vehicle as the active vehicle.

```dart
Future<void> setActiveVehicle(String vehicleId)
```

**Parameters:**
- `vehicleId`: The ID of the vehicle to set as active

**Usage:**
```dart
await provider.setActiveVehicle('vehicle-456');
```

**Behavior:**
- Only one vehicle can be active at a time
- Updates all vehicles' `isActive` status
- Sends update to API

### Utility Methods

#### clearError()

Clears the current error state.

```dart
void clearError()
```

**Usage:**
```dart
provider.clearError();
```

**Use Case:**
- Clear error before retrying an operation
- Dismiss error messages manually

#### refreshAll()

Refreshes both user data and vehicle list.

```dart
Future<void> refreshAll()
```

**Usage:**
```dart
await provider.refreshAll();
```

**Behavior:**
- Calls both `fetchUserData()` and `fetchVehicles()`
- Updates `lastSyncTime` on success
- Useful for pull-to-refresh functionality

## Integration Example

### Basic Setup

```dart
// In main.dart or app initialization
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ProfileProvider()),
    // Other providers...
  ],
  child: MyApp(),
)
```

### Using in a Widget

```dart
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Fetch data on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ProfileProvider>(context, listen: false);
      provider.fetchUserData();
      provider.fetchVehicles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return ProfilePageShimmer();
        }

        if (provider.hasError) {
          return ErrorStateWidget(
            message: provider.errorMessage!,
            onRetry: () => provider.refreshAll(),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.refreshAll(),
          child: SingleChildScrollView(
            child: Column(
              children: [
                UserInfoCard(user: provider.user!),
                VehicleList(vehicles: provider.vehicles),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

## Error Handling

The provider handles various error scenarios:

### Network Errors
```dart
// No internet connection
"Tidak dapat terhubung ke server. Periksa koneksi internet Anda."

// Timeout
"Permintaan timeout. Coba lagi."
```

### Validation Errors
```dart
// Invalid data
"Data tidak valid. Silakan coba lagi."
```

### Server Errors
```dart
// Generic server error
"Terjadi kesalahan. Silakan coba lagi."
```

## Best Practices

1. **Always use `listen: false` for operations**
   ```dart
   final provider = Provider.of<ProfileProvider>(context, listen: false);
   await provider.fetchUserData();
   ```

2. **Use Consumer for reactive UI**
   ```dart
   Consumer<ProfileProvider>(
     builder: (context, provider, child) {
       return Text(provider.user?.name ?? '');
     },
   )
   ```

3. **Handle loading and error states**
   ```dart
   if (provider.isLoading) return LoadingWidget();
   if (provider.hasError) return ErrorWidget();
   return ContentWidget();
   ```

4. **Clear errors before retry**
   ```dart
   void retry() {
     provider.clearError();
     provider.fetchUserData();
   }
   ```

5. **Use refreshAll() for pull-to-refresh**
   ```dart
   RefreshIndicator(
     onRefresh: () => provider.refreshAll(),
     child: content,
   )
   ```

## Testing

### Unit Test Example

```dart
test('fetchUserData updates user on success', () async {
  final provider = ProfileProvider();
  
  await provider.fetchUserData();
  
  expect(provider.user, isNotNull);
  expect(provider.isLoading, false);
  expect(provider.hasError, false);
});
```

### Widget Test Example

```dart
testWidgets('ProfilePage shows user name', (tester) async {
  final provider = ProfileProvider();
  
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: provider,
      child: MaterialApp(home: ProfilePage()),
    ),
  );
  
  await tester.pumpAndSettle();
  
  expect(find.text(provider.user!.name), findsOneWidget);
});
```

## Related Documentation

- [UserModel Documentation](../data/models/user_model.dart)
- [VehicleModel Documentation](../data/models/vehicle_model.dart)
- [ProfileService Documentation](../data/services/profile_service.dart)
- [State Management Guide](./state_management_guide.md)

## Version History

- **v1.0.0** (2024-12): Initial implementation with user and vehicle management
- **v1.1.0** (2024-12): Added `lastSyncTime` and `refreshAll()` method
