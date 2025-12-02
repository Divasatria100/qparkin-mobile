# Profile Page Quick Reference Guide

## For Developers

Quick reference for working with the Profile Page enhancement features.

---

## 🚀 Quick Start

### Using ProfileProvider

```dart
// Get provider (non-reactive)
final provider = Provider.of<ProfileProvider>(context, listen: false);

// Get provider (reactive)
final provider = Provider.of<ProfileProvider>(context);

// Using Consumer
Consumer<ProfileProvider>(
  builder: (context, provider, child) {
    return Text(provider.user?.name ?? '');
  },
)
```

### Fetching Data

```dart
// Fetch user data
await provider.fetchUserData();

// Fetch vehicles
await provider.fetchVehicles();

// Refresh all
await provider.refreshAll();
```

### Vehicle Operations

```dart
// Add vehicle
await provider.addVehicle(newVehicle);

// Update vehicle
await provider.updateVehicle(updatedVehicle);

// Delete vehicle
await provider.deleteVehicle(vehicleId);

// Set active vehicle
await provider.setActiveVehicle(vehicleId);
```

---

## 🎨 Using Reusable Components

### AnimatedCard

```dart
AnimatedCard(
  onTap: () => navigate(),
  child: YourContent(),
)
```

### GradientHeader

```dart
GradientHeader(
  child: Column(
    children: [
      Text('Title'),
      Text('Subtitle'),
    ],
  ),
)
```

### EmptyStateWidget

```dart
EmptyStateWidget(
  icon: Icons.inbox,
  title: 'No Items',
  description: 'Add your first item',
  actionText: 'Add Item',
  onAction: () => addItem(),
)
```

---

## 📊 State Management

### Check States

```dart
if (provider.isLoading) {
  return LoadingWidget();
}

if (provider.hasError) {
  return ErrorWidget(message: provider.errorMessage!);
}

if (provider.vehicles.isEmpty) {
  return EmptyStateWidget(...);
}

return ContentWidget();
```

### Handle Errors

```dart
try {
  await provider.fetchUserData();
} catch (e) {
  // Error is stored in provider.errorMessage
  // Show error UI or snackbar
}

// Clear error
provider.clearError();
```

---

## ♿ Accessibility

### Add Semantic Labels

```dart
Semantics(
  label: 'Button description',
  hint: 'What happens when tapped',
  button: true,
  child: YourButton(),
)
```

### Announce Changes

```dart
Semantics.announce(
  'Profile updated successfully',
  TextDirection.ltr,
);
```

### Ensure Touch Targets

```dart
// Minimum 48dp
ElevatedButton(
  style: ElevatedButton.styleFrom(
    minimumSize: Size(double.infinity, 48),
  ),
  child: Text('Button'),
)
```

---

## 🧪 Testing

### Unit Test

```dart
test('fetchUserData updates user', () async {
  final provider = ProfileProvider();
  await provider.fetchUserData();
  expect(provider.user, isNotNull);
});
```

### Widget Test

```dart
testWidgets('Shows user name', (tester) async {
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => ProfileProvider(),
      child: MaterialApp(home: ProfilePage()),
    ),
  );
  
  expect(find.text('John Doe'), findsOneWidget);
});
```

---

## 🎯 Common Patterns

### Pull-to-Refresh

```dart
RefreshIndicator(
  onRefresh: () => provider.refreshAll(),
  child: SingleChildScrollView(
    physics: AlwaysScrollableScrollPhysics(),
    child: content,
  ),
)
```

### Loading State

```dart
if (provider.isLoading) {
  return ProfilePageShimmer();
}
```

### Error State with Retry

```dart
if (provider.hasError) {
  return EmptyStateWidget(
    icon: Icons.error_outline,
    title: 'Error',
    description: provider.errorMessage!,
    actionText: 'Retry',
    onAction: () {
      provider.clearError();
      provider.refreshAll();
    },
  );
}
```

### Swipe-to-Delete

```dart
Dismissible(
  key: Key(vehicle.id),
  direction: DismissDirection.endToStart,
  confirmDismiss: (direction) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Vehicle?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  },
  onDismissed: (direction) {
    provider.deleteVehicle(vehicle.id);
  },
  background: Container(
    color: Colors.red,
    alignment: Alignment.centerRight,
    padding: EdgeInsets.only(right: 20),
    child: Icon(Icons.delete, color: Colors.white),
  ),
  child: VehicleCard(vehicle: vehicle),
)
```

---

## 📝 Code Snippets

### Create User Model

```dart
final user = UserModel(
  id: '123',
  name: 'John Doe',
  email: 'john@example.com',
  phoneNumber: '081234567890',
  photoUrl: 'https://example.com/photo.jpg',
  saldoPoin: 1000,
  createdAt: DateTime.now(),
);
```

### Create Vehicle Model

```dart
final vehicle = VehicleModel(
  id: '456',
  userId: '123',
  name: 'My Car',
  plate: 'B1234XYZ',
  type: 'car',
  isActive: true,
  createdAt: DateTime.now(),
);
```

### Update User

```dart
final updatedUser = currentUser.copyWith(
  name: 'New Name',
  email: 'newemail@example.com',
);
await provider.updateUser(updatedUser);
```

### Navigate to Edit Profile

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => EditProfilePage(user: provider.user!),
  ),
).then((_) {
  // Refresh data after returning
  provider.fetchUserData();
});
```

---

## 🐛 Troubleshooting

### Provider not updating UI

```dart
// Make sure you're using Consumer or listening
Consumer<ProfileProvider>(
  builder: (context, provider, child) {
    return Text(provider.user?.name ?? '');
  },
)

// Or
final provider = Provider.of<ProfileProvider>(context); // listen: true (default)
```

### Data not refreshing

```dart
// Use listen: false for operations
final provider = Provider.of<ProfileProvider>(context, listen: false);
await provider.fetchUserData();
```

### Navigation not working

```dart
// Make sure CurvedNavigationBar is properly configured
CurvedNavigationBar(
  index: 4, // Current page index
  onTap: (index) => NavigationUtils.handleNavigation(context, index, 4),
)
```

### Images not loading

```dart
// Check CachedProfileImage implementation
CachedProfileImage(
  imageUrl: user.photoUrl,
  size: 80,
  placeholder: CircularProgressIndicator(),
  errorWidget: Icon(Icons.person),
)
```

---

## 📚 File Locations

```
lib/
├── logic/providers/
│   └── profile_provider.dart          # State management
├── data/
│   ├── models/
│   │   ├── user_model.dart            # User data model
│   │   └── vehicle_model.dart         # Vehicle data model
│   └── services/
│       └── profile_service.dart       # API communication
├── presentation/
│   ├── screens/
│   │   ├── profile_page.dart          # Main profile page
│   │   ├── edit_profile_page.dart     # Edit profile form
│   │   └── vehicle_detail_page.dart   # Vehicle details
│   └── widgets/
│       ├── common/
│       │   ├── animated_card.dart     # Animated card component
│       │   ├── gradient_header.dart   # Gradient header component
│       │   └── empty_state_widget.dart # Empty state component
│       └── profile/
│           ├── vehicle_card.dart      # Vehicle card component
│           └── profile_shimmer_loading.dart # Loading states
└── utils/
    └── navigation_utils.dart          # Navigation helpers
```

---

## 🔗 Related Documentation

- [ProfileProvider API](./profile_provider_api.md) - Complete API reference
- [Reusable Components Guide](./reusable_components_guide.md) - Component documentation
- [Profile Page Features](./profile_page_features.md) - Feature overview
- [Accessibility Features](./profile_accessibility_features.md) - Accessibility guide

---

## 💡 Tips

1. **Always use const constructors** when possible for performance
2. **Clear errors before retry** to reset error state
3. **Use Consumer for reactive UI** to avoid unnecessary rebuilds
4. **Test with screen readers** to ensure accessibility
5. **Follow 8dp grid system** for consistent spacing
6. **Use semantic labels** on all interactive elements
7. **Handle all states** (loading, error, empty, success)
8. **Provide user feedback** for all actions (snackbars, dialogs)

---

## 📞 Support

Need help? Check these resources:
- [Full Documentation](./profile_page_features.md)
- [API Reference](./profile_provider_api.md)
- [Testing Guide](./accessibility_testing_guide.md)
- [Troubleshooting](./troubleshooting.md)

---

**Last Updated:** December 2024
**Version:** 1.0.0
