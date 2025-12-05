# Profile Page Features Documentation

## Overview

The Profile Page is a comprehensive user account management interface in the QPARKIN application. It provides users with access to their personal information, vehicle management, points tracking, and account settings.

## Features

### 1. User Profile Display

**Description:** Shows user's personal information in an attractive, easy-to-read format.

**Components:**
- Profile photo with caching
- User name and email
- Account creation date
- Points balance

**Implementation:**
```dart
// Located in: lib/presentation/screens/profile_page.dart
Consumer<ProfileProvider>(
  builder: (context, provider, child) {
    final user = provider.user;
    return UserInfoCard(
      name: user.name,
      email: user.email,
      photoUrl: user.photoUrl,
    );
  },
)
```

**User Benefits:**
- Quick access to account information
- Visual confirmation of logged-in account
- Easy identification of account status

---

### 2. Points Integration

**Description:** Displays user's reward points with navigation to points history.

**Components:**
- PremiumPointsCard with gradient styling
- Real-time points updates
- Tap to view points history

**Implementation:**
```dart
PremiumPointsCard(
  points: provider.user?.saldoPoin ?? 0,
  variant: PointsCardVariant.gradient,
  onTap: () => Navigator.pushNamed(context, '/points-history'),
)
```

**User Benefits:**
- Track rewards earned from parking
- Quick access to points history
- Visual feedback on points changes

**Related Requirements:** 6.1, 6.2, 6.3, 6.4, 6.5

---

### 3. Vehicle Management

**Description:** Complete CRUD operations for managing registered vehicles.

#### 3.1 Vehicle List Display

Shows all registered vehicles with visual indicators for the active vehicle.

**Features:**
- Vehicle icon based on type (car/motorcycle)
- Vehicle name, plate number, and type
- "Aktif" badge for active vehicle
- Swipe-to-delete functionality

**Implementation:**
```dart
ListView.builder(
  itemCount: provider.vehicles.length,
  itemBuilder: (context, index) {
    final vehicle = provider.vehicles[index];
    return Dismissible(
      key: Key(vehicle.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => showDeleteConfirmation(context),
      onDismissed: (direction) => provider.deleteVehicle(vehicle.id),
      child: VehicleCard(
        vehicle: vehicle,
        isActive: vehicle.isActive,
        onTap: () => navigateToVehicleDetail(vehicle),
      ),
    );
  },
)
```

#### 3.2 Add Vehicle

Allows users to register new vehicles.

**Fields:**
- Vehicle name
- License plate number
- Vehicle type (car/motorcycle)

**Validation:**
- Required fields check
- Plate number format validation
- Duplicate plate check

#### 3.3 Edit Vehicle

Update existing vehicle information.

**Features:**
- Pre-filled form with current data
- Same validation as add vehicle
- Immediate UI update on save

#### 3.4 Delete Vehicle

Remove vehicles from account with confirmation.

**Safety Features:**
- Confirmation dialog before deletion
- Undo option via snackbar
- Automatic active vehicle reassignment

#### 3.5 Set Active Vehicle

Designate which vehicle is currently in use.

**Behavior:**
- Only one vehicle can be active at a time
- Active vehicle used for parking transactions
- Visual indicator on vehicle card

**Related Requirements:** 5.1, 5.2, 5.3, 5.4, 5.5, 10.1-10.5

---

### 4. Profile Editing

**Description:** Allows users to update their personal information.

**Editable Fields:**
- Full name
- Email address
- Phone number
- Profile photo

**Features:**
- Form validation
- Image picker for photo upload
- Real-time validation feedback
- Loading state during save

**Implementation:**
```dart
// Located in: lib/presentation/screens/edit_profile_page.dart
ElevatedButton(
  onPressed: isValid ? () async {
    final updatedUser = currentUser.copyWith(
      name: nameController.text,
      email: emailController.text,
      phoneNumber: phoneController.text,
    );
    await provider.updateUser(updatedUser);
  } : null,
  child: Text('Simpan'),
)
```

**Validation Rules:**
- Name: Required, min 3 characters
- Email: Required, valid email format
- Phone: Optional, valid phone format
- Photo: Optional, max 5MB

**Related Requirements:** 7.1, 7.2, 7.3, 7.4, 7.5

---

### 5. State Management

**Description:** Reactive data management using Provider pattern.

**States:**
- Loading: Shimmer placeholders
- Success: Display data
- Error: Error message with retry
- Empty: Empty state with guidance

**Implementation:**
```dart
if (provider.isLoading) {
  return ProfilePageShimmer();
}

if (provider.hasError) {
  return EmptyStateWidget(
    icon: Icons.error_outline,
    title: 'Terjadi Kesalahan',
    description: provider.errorMessage!,
    actionText: 'Coba Lagi',
    onAction: () => provider.refreshAll(),
  );
}

if (provider.vehicles.isEmpty) {
  return EmptyStateWidget(
    icon: Icons.directions_car_outlined,
    title: 'Tidak ada kendaraan',
    description: 'Tambahkan kendaraan pertama Anda.',
    actionText: 'Tambah Kendaraan',
    onAction: () => navigateToAddVehicle(),
  );
}

return ProfileContent(provider: provider);
```

**Related Requirements:** 3.1, 3.2, 3.3, 3.4, 3.5, 4.1, 4.2, 4.3

---

### 6. Pull-to-Refresh

**Description:** Manual data refresh by pulling down on the page.

**Features:**
- Refreshes both user data and vehicle list
- Brand-colored loading indicator
- Success/error feedback
- Updates last sync timestamp

**Implementation:**
```dart
RefreshIndicator(
  color: Color(0xFF573ED1),
  onRefresh: () => provider.refreshAll(),
  child: SingleChildScrollView(
    physics: AlwaysScrollableScrollPhysics(),
    child: content,
  ),
)
```

**Related Requirements:** 4.4, 12.1, 12.2, 12.3, 12.4, 12.5

---

### 7. Navigation Consistency

**Description:** Consistent bottom navigation across all main pages.

**Features:**
- CurvedNavigationBar at bottom
- Profile tab highlighted when active
- Smooth transitions between pages
- Maintains navigation stack

**Implementation:**
```dart
CurvedNavigationBar(
  index: 4, // Profile page index
  items: [
    Icon(Icons.home),
    Icon(Icons.history),
    Icon(Icons.qr_code_scanner),
    Icon(Icons.map),
    Icon(Icons.person),
  ],
  onTap: (index) => NavigationUtils.handleNavigation(context, index, 4),
)
```

**Related Requirements:** 1.1, 1.2, 1.3, 1.4

---

### 8. Accessibility Features

**Description:** Full support for users with accessibility needs.

#### 8.1 Screen Reader Support

**Features:**
- Semantic labels on all interactive elements
- Meaningful button descriptions
- State change announcements
- Logical navigation order

**Example:**
```dart
Semantics(
  label: 'Edit profile button',
  hint: 'Double tap to edit your profile information',
  button: true,
  child: IconButton(
    icon: Icon(Icons.edit),
    onPressed: () => navigateToEditProfile(),
  ),
)
```

#### 8.2 Touch Target Sizes

**Features:**
- Minimum 48dp touch targets
- Adequate spacing between elements
- Works with large text settings
- Compatible with display zoom

#### 8.3 Visual Accessibility

**Features:**
- High contrast text (4.5:1 ratio)
- Clear visual hierarchy
- Color not sole indicator
- Scalable text support

**Related Requirements:** 8.1, 8.2, 8.3, 8.4, 8.5

---

### 9. Logout Functionality

**Description:** Secure logout with data clearing.

**Features:**
- Confirmation dialog
- Clears all local data
- Removes authentication tokens
- Clears navigation stack
- Returns to login page

**Implementation:**
```dart
void logout() async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Keluar'),
      content: Text('Apakah Anda yakin ingin keluar?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: Text('Keluar'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    await SharedPreferences.getInstance().then((prefs) => prefs.clear());
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}
```

**Related Requirements:** 11.1, 11.2, 11.3, 11.4, 11.5

---

### 10. Image Caching

**Description:** Optimized profile photo loading and caching.

**Features:**
- Cached network images
- Placeholder during loading
- Error fallback image
- Memory-efficient caching

**Implementation:**
```dart
CachedProfileImage(
  imageUrl: user.photoUrl,
  size: 80,
  placeholder: CircularProgressIndicator(),
  errorWidget: Icon(Icons.person, size: 40),
)
```

**Benefits:**
- Faster page loads
- Reduced data usage
- Better offline experience
- Improved performance

---

### 11. Vehicle Statistics (Enhancement)

**Description:** Display usage statistics for each vehicle.

**Metrics:**
- Total parking sessions
- Total parking time
- Total amount spent
- Last used date

**Implementation:**
```dart
VehicleStatisticsCard(
  vehicle: vehicle,
  statistics: VehicleStatistics(
    parkingCount: 15,
    totalDuration: Duration(hours: 23, minutes: 45),
    totalCost: 125000,
    lastUsed: DateTime.now().subtract(Duration(days: 2)),
  ),
)
```

---

## User Flows

### First-Time User Flow

1. User opens profile page
2. Sees empty vehicle list
3. Taps "Tambah Kendaraan"
4. Fills vehicle form
5. Saves vehicle
6. Returns to profile with vehicle displayed

### Edit Profile Flow

1. User taps "Ubah informasi akun"
2. Navigates to edit profile page
3. Updates desired fields
4. Taps "Simpan"
5. Sees loading indicator
6. Returns to profile with updated data

### Delete Vehicle Flow

1. User swipes vehicle card left
2. Sees delete confirmation dialog
3. Confirms deletion
4. Vehicle removed from list
5. Sees undo snackbar
6. Can undo within 3 seconds

### Error Recovery Flow

1. Network error occurs
2. Error state displayed
3. User taps "Coba Lagi"
4. Data reloads
5. Success state displayed

---

## Technical Architecture

### File Structure

```
lib/
├── presentation/
│   ├── screens/
│   │   ├── profile_page.dart
│   │   ├── edit_profile_page.dart
│   │   └── vehicle_detail_page.dart
│   └── widgets/
│       ├── profile/
│       │   ├── vehicle_card.dart
│       │   └── profile_shimmer_loading.dart
│       └── common/
│           ├── animated_card.dart
│           ├── gradient_header.dart
│           └── empty_state_widget.dart
├── logic/
│   └── providers/
│       └── profile_provider.dart
└── data/
    ├── models/
    │   ├── user_model.dart
    │   └── vehicle_model.dart
    └── services/
        └── profile_service.dart
```

### Data Flow

```
UI (ProfilePage)
    ↓
Consumer<ProfileProvider>
    ↓
ProfileProvider (State Management)
    ↓
ProfileService (API Communication)
    ↓
Backend API
```

---

## Performance Metrics

- **Page Load Time:** < 2 seconds
- **Refresh Time:** < 1 second
- **Image Load Time:** < 500ms (cached)
- **Animation Duration:** 150ms (micro-interactions)

---

## Testing Coverage

- **Unit Tests:** ProfileProvider, Models, Services
- **Widget Tests:** All UI components
- **Integration Tests:** Complete user flows
- **Accessibility Tests:** Screen reader, touch targets
- **Property-Based Tests:** State management, validation

---

## Future Enhancements

1. **Profile Themes:** Allow users to customize app theme
2. **Vehicle Photos:** Add photos to vehicle cards
3. **Parking History:** Per-vehicle parking history
4. **Export Data:** Export profile and vehicle data
5. **Social Features:** Share profile or achievements
6. **Biometric Auth:** Fingerprint/Face ID for profile access

---

## Related Documentation

- [ProfileProvider API](./profile_provider_api.md)
- [Reusable Components Guide](./reusable_components_guide.md)
- [Accessibility Features](./accessibility_features.md)
- [State Management Guide](./state_management_guide.md)

---

## Support

For issues or questions about profile page features:
- Check the [FAQ](./faq.md)
- Review [Troubleshooting Guide](./troubleshooting.md)
- Contact development team

---

## Version History

- **v1.0.0** (2024-12): Initial profile page implementation
- **v1.1.0** (2024-12): Added vehicle management features
- **v1.2.0** (2024-12): Enhanced accessibility support
- **v1.3.0** (2024-12): Added image caching and statistics
