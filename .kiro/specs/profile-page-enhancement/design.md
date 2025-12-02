# Design Document - Profile Page Enhancement

## Overview

The Profile Page Enhancement project aims to modernize the QPARKIN profile page by implementing design consistency, proper state management, and reusable components. This design follows the established patterns from home_page, activity_page, and map_page while introducing profile-specific features.

The enhancement focuses on three key areas:
1. **Design Consistency**: Aligning visual elements, navigation, and interactions with other pages
2. **State Management**: Implementing Provider pattern for reactive data management
3. **Component Reusability**: Extracting and creating reusable widgets for use across the application

## Architecture

### Component Hierarchy

```
ProfilePage (StatefulWidget)
├── ProfileProvider (ChangeNotifier)
│   ├── User Data Management
│   ├── Vehicle List Management
│   └── State Management (loading, error, success)
├── RefreshIndicator
│   └── SingleChildScrollView
│       ├── GradientHeader (Reusable)
│       │   ├── Profile Title
│       │   ├── User Info Section
│       │   └── PremiumPointsCard
│       ├── Vehicle Section
│       │   ├── Section Header
│       │   └── Vehicle Cards (AnimatedCard)
│       └── Menu Sections
│           ├── Account Section
│           └── Other Section
└── CurvedNavigationBar
```

### File Structure

```
lib/
├── presentation/
│   ├── screens/
│   │   ├── profile_page.dart (Enhanced)
│   │   ├── edit_profile_page.dart (New)
│   │   ├── list_kendaraan.dart (Enhanced)
│   │   └── vehicle_detail_page.dart (New)
│   └── widgets/
│       ├── profile/
│       │   ├── profile_header.dart (New)
│       │   ├── user_info_card.dart (New)
│       │   ├── vehicle_card.dart (New)
│       │   ├── profile_menu_section.dart (New)
│       │   └── profile_shimmer_loading.dart (New)
│       └── common/
│           ├── animated_card.dart (Extracted)
│           ├── gradient_header.dart (New)
│           └── empty_state_widget.dart (New)
├── logic/
│   └── providers/
│       └── profile_provider.dart (New)
└── data/
    ├── models/
    │   └── user_model.dart (Enhanced)
    └── services/
        └── profile_service.dart (New)
```

## Components and Interfaces

### 1. ProfileProvider (State Management)

**Purpose**: Centralized state management for profile-related data and operations.

**Interface**:
```dart
class ProfileProvider extends ChangeNotifier {
  // Private state
  UserModel? _user;
  List<VehicleModel> _vehicles = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastSyncTime;
  
  // Getters
  UserModel? get user => _user;
  List<VehicleModel> get vehicles => _vehicles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  DateTime? get lastSyncTime => _lastSyncTime;
  
  // User operations
  Future<void> fetchUserData();
  Future<void> updateUser(UserModel user);
  
  // Vehicle operations
  Future<void> fetchVehicles();
  Future<void> addVehicle(VehicleModel vehicle);
  Future<void> updateVehicle(VehicleModel vehicle);
  Future<void> deleteVehicle(String vehicleId);
  Future<void> setActiveVehicle(String vehicleId);
  
  // Utility methods
  void clearError();
  Future<void> refreshAll();
}
```

**Responsibilities**:
- Manage user profile data
- Handle vehicle CRUD operations
- Track loading and error states
- Notify listeners on state changes
- Handle API communication through ProfileService

### 2. AnimatedCard (Extracted Component)

**Purpose**: Provide consistent micro-interaction feedback for tappable elements.

**Interface**:
```dart
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsets? padding;
  
  const AnimatedCard({
    required this.child,
    this.onTap,
    this.borderRadius = 16,
    this.padding,
  });
}
```

**Behavior**:
- Scale animation (0.97) on tap down
- Shadow elevation change on press
- Ripple effect with brand color (0xFF573ED1)
- 150ms animation duration with easeInOut curve

### 3. GradientHeader (New Component)

**Purpose**: Reusable gradient header component for consistent branding.

**Interface**:
```dart
class GradientHeader extends StatelessWidget {
  final Widget child;
  final double height;
  final EdgeInsets padding;
  final List<Color>? gradientColors;
  
  const GradientHeader({
    required this.child,
    this.height = 180,
    this.padding = const EdgeInsets.fromLTRB(20, 40, 20, 100),
    this.gradientColors,
  });
}
```

**Default Gradient Colors**:
- Color(0xFF42CBF8) - Light blue
- Color(0xFF573ED1) - Primary purple
- Color(0xFF39108A) - Dark purple

### 4. VehicleCard (New Component)

**Purpose**: Display vehicle information with interactive feedback.

**Interface**:
```dart
class VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  final bool isActive;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  
  const VehicleCard({
    required this.vehicle,
    this.isActive = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });
}
```

**Visual Elements**:
- Vehicle icon with colored background
- Vehicle name, type, and plate number
- "Aktif" badge for active vehicle
- Swipe-to-delete functionality (Dismissible)

### 5. EmptyStateWidget (New Component)

**Purpose**: Reusable empty state display for various scenarios.

**Interface**:
```dart
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String actionText;
  final VoidCallback? onAction;
  final Color? iconColor;
  
  const EmptyStateWidget({
    required this.title,
    required this.description,
    required this.icon,
    this.actionText = 'Tambah Sekarang',
    this.onAction,
    this.iconColor,
  });
}
```

### 6. ProfileShimmerLoading (New Component)

**Purpose**: Loading state placeholders for profile page.

**Components**:
```dart
class ProfilePageShimmer extends StatelessWidget {
  // Full page shimmer loading
}

class VehicleCardShimmer extends StatelessWidget {
  // Individual vehicle card shimmer
}

class UserInfoShimmer extends StatelessWidget {
  // User information section shimmer
}
```

## Data Models

### UserModel (Enhanced)

```dart
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? photoUrl;
  final int saldoPoin;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.photoUrl,
    this.saldoPoin = 0,
    required this.createdAt,
    this.updatedAt,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  UserModel copyWith({...});
}
```

### VehicleModel (Enhanced)

```dart
class VehicleModel {
  final String id;
  final String userId;
  final String name;
  final String plate;
  final String type;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  VehicleModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.plate,
    required this.type,
    this.isActive = false,
    required this.createdAt,
    this.updatedAt,
  });
  
  factory VehicleModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  VehicleModel copyWith({...});
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Navigation Consistency

*For any* page navigation action from the profile page, the navigation behavior should match the behavior of other pages using NavigationUtils.handleNavigation

**Validates: Requirements 1.2, 1.3**

### Property 2: Visual Consistency

*For any* gradient header rendered in the application, the gradient colors should be identical across all pages

**Validates: Requirements 2.1**

### Property 3: AnimatedCard Interaction

*For any* tappable element using AnimatedCard, the scale animation and duration should be consistent (0.97 scale, 150ms duration)

**Validates: Requirements 2.2**

### Property 4: State Management Reactivity

*For any* data change in ProfileProvider, all listening widgets should receive notifications and update accordingly

**Validates: Requirements 3.2, 3.3**

### Property 5: Loading State Display

*For any* API call in progress, the UI should display shimmer loading placeholders and disable user interactions

**Validates: Requirements 4.1**

### Property 6: Error State Recovery

*For any* error state displayed, a retry button should be present and functional

**Validates: Requirements 4.2**

### Property 7: Empty State Guidance

*For any* empty vehicle list, an empty state with clear guidance should be displayed

**Validates: Requirements 4.3**

### Property 8: Active Vehicle Indicator

*For any* vehicle list display, exactly one vehicle should have the "Aktif" badge if vehicles exist

**Validates: Requirements 5.2**

### Property 9: Vehicle Card Interaction

*For any* vehicle card tap, the AnimatedCard feedback should be triggered before navigation

**Validates: Requirements 5.1, 5.3**

### Property 10: Points Display Reactivity

*For any* points value change, the PremiumPointsCard should update to reflect the new value

**Validates: Requirements 6.2**

### Property 11: Form Validation

*For any* profile edit form submission, all fields should be validated before API call

**Validates: Requirements 7.4**

### Property 12: Accessibility Labels

*For any* interactive element, semantic labels and hints should be present for screen readers

**Validates: Requirements 8.1, 8.2**

### Property 13: Touch Target Size

*For any* interactive button or card, the minimum touch target size should be 48dp

**Validates: Requirements 8.3**

### Property 14: Component Reusability

*For any* AnimatedCard, GradientHeader, or EmptyStateWidget usage, the component should accept customization parameters

**Validates: Requirements 9.5**

### Property 15: Vehicle Deletion Confirmation

*For any* vehicle deletion action, a confirmation dialog should be displayed before execution

**Validates: Requirements 10.4**

### Property 16: Logout Data Clearing

*For any* logout action, all user data should be cleared from local storage before navigation

**Validates: Requirements 11.2**

### Property 17: Refresh Indicator

*For any* pull-to-refresh action, both user data and vehicle list should be reloaded

**Validates: Requirements 12.2**

## Error Handling

### Network Errors

**Scenarios**:
- No internet connection
- API timeout
- Server errors (500, 502, 503)

**Handling**:
```dart
try {
  await profileService.fetchUserData();
} on NetworkException catch (e) {
  _errorMessage = 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
  notifyListeners();
} on TimeoutException catch (e) {
  _errorMessage = 'Permintaan timeout. Coba lagi.';
  notifyListeners();
} catch (e) {
  _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
  notifyListeners();
}
```

### Validation Errors

**Scenarios**:
- Invalid email format
- Empty required fields
- Invalid phone number format

**Handling**:
- Display error messages below form fields
- Prevent form submission until validation passes
- Use Flutter's Form validation system

### Data Integrity Errors

**Scenarios**:
- Malformed JSON response
- Missing required fields
- Type mismatches

**Handling**:
```dart
try {
  final user = UserModel.fromJson(json);
} on FormatException catch (e) {
  _errorMessage = 'Data tidak valid. Silakan coba lagi.';
  notifyListeners();
}
```

## Testing Strategy

### Unit Tests

**ProfileProvider Tests**:
- Test fetchUserData success and failure scenarios
- Test vehicle CRUD operations
- Test state management (loading, error, success)
- Test error clearing functionality
- Test refresh functionality

**Model Tests**:
- Test UserModel.fromJson and toJson
- Test VehicleModel.fromJson and toJson
- Test copyWith methods
- Test model validation

**Service Tests**:
- Test ProfileService API calls
- Test error handling in service layer
- Test data transformation

### Widget Tests

**ProfilePage Tests**:
- Test rendering with different states (loading, error, success, empty)
- Test navigation to other pages
- Test pull-to-refresh functionality
- Test bottom navigation interaction

**Component Tests**:
- Test AnimatedCard animation behavior
- Test VehicleCard rendering with active/inactive states
- Test EmptyStateWidget rendering
- Test GradientHeader rendering

**Form Tests**:
- Test EditProfilePage form validation
- Test form submission
- Test error display

### Integration Tests

**Profile Management Flow**:
1. Load profile page
2. Verify user data and vehicles display
3. Edit profile information
4. Verify changes are saved and reflected
5. Add new vehicle
6. Verify vehicle appears in list
7. Delete vehicle
8. Verify vehicle is removed

**Error Recovery Flow**:
1. Simulate network error
2. Verify error state displays
3. Tap retry button
4. Verify data loads successfully

### Accessibility Tests

**Screen Reader Tests**:
- Test with TalkBack (Android) and VoiceOver (iOS)
- Verify all interactive elements are announced
- Verify semantic labels are meaningful
- Verify navigation flow is logical

**Touch Target Tests**:
- Verify all buttons meet 48dp minimum size
- Test with large text settings
- Test with display zoom enabled

### Property-Based Testing

**Testing Framework**: Use `flutter_test` with custom property testing utilities

**Test Configuration**:
- Minimum 100 iterations per property test
- Random data generation for user and vehicle models
- Edge case coverage (empty lists, null values, extreme values)

**Property Test Examples**:

```dart
// Property 4: State Management Reactivity
test('Property 4: ProfileProvider notifies listeners on data change', () {
  final provider = ProfileProvider();
  int notificationCount = 0;
  
  provider.addListener(() {
    notificationCount++;
  });
  
  // Generate random user data
  for (int i = 0; i < 100; i++) {
    final randomUser = generateRandomUser();
    provider.updateUser(randomUser);
  }
  
  expect(notificationCount, equals(100));
});

// Property 8: Active Vehicle Indicator
test('Property 8: Exactly one vehicle should be active', () {
  for (int i = 0; i < 100; i++) {
    final vehicles = generateRandomVehicleList();
    final activeCount = vehicles.where((v) => v.isActive).length;
    
    if (vehicles.isNotEmpty) {
      expect(activeCount, equals(1));
    } else {
      expect(activeCount, equals(0));
    }
  }
});
```

## Performance Considerations

### Optimization Strategies

1. **Use const constructors** wherever possible to reduce widget rebuilds
2. **Implement lazy loading** for vehicle images
3. **Cache user data** in SharedPreferences to reduce API calls
4. **Use ListView.builder** for large vehicle lists
5. **Debounce search** and filter operations
6. **Optimize image sizes** for different screen densities

### Memory Management

- Dispose controllers and listeners properly
- Clear cached images when memory pressure is high
- Limit the number of simultaneous API calls
- Use weak references for large data structures

### Rendering Performance

- Avoid expensive operations in build methods
- Use RepaintBoundary for complex widgets
- Minimize widget tree depth
- Use keys appropriately for list items

## Security Considerations

### Data Protection

- Validate all user inputs before sending to API
- Sanitize image uploads to prevent malicious files
- Use HTTPS for all API communication
- Store sensitive data in FlutterSecureStorage

### Authentication

- Verify user authentication before profile operations
- Handle token expiration gracefully
- Implement automatic token refresh
- Clear authentication data on logout

### Privacy

- Request permissions before accessing device features
- Provide clear privacy policy links
- Allow users to delete their data
- Implement data encryption for local storage

## Accessibility Guidelines

### WCAG 2.1 AA Compliance

**Perceivable**:
- Provide text alternatives for images
- Use sufficient color contrast (4.5:1 for normal text)
- Support text resizing up to 200%
- Avoid using color as the only visual means of conveying information

**Operable**:
- Make all functionality available from keyboard
- Provide users enough time to read and use content
- Do not use content that causes seizures
- Provide ways to help users navigate and find content

**Understandable**:
- Make text readable and understandable
- Make content appear and operate in predictable ways
- Help users avoid and correct mistakes

**Robust**:
- Maximize compatibility with current and future user tools
- Use semantic HTML/Flutter widgets
- Provide meaningful labels and hints

### Implementation Checklist

- [ ] All images have semantic labels
- [ ] All buttons have semantic labels and hints
- [ ] Minimum touch target size is 48dp
- [ ] Color contrast meets WCAG AA standards
- [ ] Screen reader navigation is logical
- [ ] Form errors are announced to screen readers
- [ ] Loading states are announced
- [ ] Success/error feedback is accessible

## Design Patterns

### Provider Pattern

Used for state management to provide reactive data flow and separation of concerns.

**Benefits**:
- Centralized state management
- Easy testing
- Reactive UI updates
- Separation of business logic from UI

### Repository Pattern

Used in ProfileService to abstract data sources and provide a clean API.

**Benefits**:
- Separation of data access logic
- Easy to mock for testing
- Flexible data source switching
- Consistent error handling

### Factory Pattern

Used in model classes for JSON deserialization.

**Benefits**:
- Consistent object creation
- Error handling during parsing
- Type safety
- Easy to extend

## Migration Strategy

### Phase 1: Foundation (Week 1)

1. Extract AnimatedCard to common widgets
2. Create GradientHeader component
3. Implement ProfileProvider
4. Add CurvedNavigationBar to profile page

### Phase 2: Enhancement (Week 2)

1. Implement shimmer loading states
2. Create VehicleCard component
3. Add pull-to-refresh functionality
4. Implement error states with retry

### Phase 3: Features (Week 3)

1. Create EditProfilePage
2. Implement vehicle detail page
3. Add swipe-to-delete for vehicles
4. Integrate points display
5. Add logout functionality

### Phase 4: Polish (Week 4)

1. Add accessibility features
2. Implement empty states
3. Optimize performance
4. Write comprehensive tests
5. Documentation updates

## Success Metrics

### Technical Metrics

- **Code Reusability**: 80% of components reusable across app
- **Test Coverage**: >90% for profile-related code
- **Performance**: Page load time <2 seconds
- **Bundle Size**: No significant increase in app size

### User Experience Metrics

- **Consistency Score**: 100% design pattern alignment
- **Accessibility Score**: WCAG 2.1 AA compliance
- **Error Rate**: <1% for profile operations
- **User Satisfaction**: Improved app store ratings

### Business Metrics

- **User Engagement**: Increased profile page usage
- **Feature Adoption**: Vehicle management feature usage
- **Retention**: Improved user retention rates
- **Support Tickets**: Reduced profile-related support requests
