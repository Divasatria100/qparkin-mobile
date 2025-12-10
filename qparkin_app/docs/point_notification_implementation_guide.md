# Point Notification System - Implementation Guide

## Overview

The point notification system has been fully implemented to provide real-time feedback to users when their point balance changes. This guide explains how the system works and how to use it throughout the QPARKIN app.

## Requirements Fulfilled

✅ **Requirement 7.1**: Points earned notification after parking payment  
✅ **Requirement 7.2**: Points used notification after payment with points  
✅ **Requirement 7.3**: Penalty warning notification when points are deducted  
✅ **Requirement 7.4**: "Lihat Detail" button in all notifications  
✅ **Requirement 7.5**: Badge indicator on point page icon when points change  

## Architecture

### Component Overview

```
┌─────────────────────────────────────────────────────────┐
│                   User Interface                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  HomePage    │  │  PointPage   │  │ PaymentPage  │  │
│  │ (with badge) │  │ (marks read) │  │(uses points) │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│              Notification Components                     │
│  ┌──────────────────────────────────────────────────┐   │
│  │  NotificationHelper (Dialogs & Snackbars)        │   │
│  │  PointNotificationIntegration (Convenience API)  │   │
│  │  BadgeIcon (Visual indicator)                    │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                State Management                          │
│  ┌──────────────┐  ┌──────────────────────────────┐    │
│  │Notification  │  │     PointProvider            │    │
│  │Provider      │←─│  (tracks balance changes)    │    │
│  │(badge state) │  │                              │    │
│  └──────────────┘  └──────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

### Data Flow

1. **Point Balance Changes**:
   ```
   Backend API → PointProvider.fetchBalance() 
   → Detects change → NotificationProvider.markPointsChanged()
   → Badge appears on HomePage
   ```

2. **User Opens Point Page**:
   ```
   User taps PremiumPointsCard → Navigate to PointPage
   → PointPage.initState() → PointProvider.markNotificationsAsRead()
   → Badge disappears
   ```

3. **Notification Display**:
   ```
   Event occurs (earn/use/penalty) → NotificationHelper.show*()
   → Dialog appears with "Lihat Detail" button
   → User taps button → Navigate to PointPage
   ```

## Implementation Details

### 1. NotificationProvider

**Location**: `lib/logic/providers/notification_provider.dart`

**Purpose**: Manages badge state and tracks point changes

**Key Methods**:
- `markPointsChanged(int newBalance)`: Call when points change
- `markPointChangesAsRead()`: Call when user opens point page
- `initializeBalance(int balance)`: Call on app start

**State Persistence**: Uses SharedPreferences to persist badge state across app restarts

### 2. NotificationHelper

**Location**: `lib/utils/notification_helper.dart`

**Purpose**: Displays notification dialogs and snackbars

**Key Methods**:
- `showPointsEarned()`: Green dialog with celebration icon
- `showPointsUsed()`: Blue dialog with checkmark icon
- `showPenaltyDeduction()`: Orange dialog with warning icon
- `showSnackbar()`: Quick feedback message

**Features**:
- Beautiful, branded dialogs with icons
- "Lihat Detail" button navigates to point page
- Dismissible with "Tutup" button
- Accessible with semantic labels

### 3. PointNotificationIntegration

**Location**: `lib/utils/point_notification_integration.dart`

**Purpose**: Convenience API for triggering notifications

**Key Methods**:
- `notifyPointsEarned()`: Shows dialog + refreshes balance
- `notifyPointsUsed()`: Shows dialog with remaining balance
- `notifyPenalty()`: Shows warning + refreshes balance
- `showSuccess()` / `showError()`: Quick snackbar messages

### 4. BadgeIcon Widget

**Location**: `lib/presentation/widgets/badge_icon.dart`

**Purpose**: Reusable badge indicator for icons

**Usage**:
```dart
BadgeIcon(
  icon: Icons.star,
  showBadge: true,
  iconSize: 24,
  iconColor: Colors.blue,
)
```

### 5. PremiumPointsCard with Badge

**Location**: `lib/presentation/widgets/premium_points_card.dart`

**Enhancement**: Added `showBadge` parameter to display notification indicator

**Usage in HomePage**:
```dart
Consumer2<PointProvider, NotificationProvider>(
  builder: (context, pointProvider, notificationProvider, _) {
    return PremiumPointsCard(
      points: pointProvider.balance ?? 0,
      showBadge: notificationProvider.hasUnreadPointChanges,
      onTap: () => Navigator.pushNamed(context, '/point'),
    );
  },
)
```

## Integration Points

### A. HomePage Integration

**File**: `lib/presentation/screens/home_page.dart`

**Changes**:
1. Added imports for `PointProvider` and `NotificationProvider`
2. Wrapped `PremiumPointsCard` with `Consumer2` to listen to both providers
3. Added `_initializePointData()` to fetch balance on page load
4. Updated `onTap` to navigate to `/point` route

**Result**: Badge appears on points card when balance changes

### B. PointPage Integration

**File**: `lib/presentation/screens/point_page.dart`

**Existing Implementation**:
- Already calls `markNotificationsAsRead()` in `initState()`
- Automatically clears badge when page is opened

**Result**: Badge disappears when user views point page

### C. PointProvider Integration

**File**: `lib/logic/providers/point_provider.dart`

**Existing Implementation**:
- Automatically calls `markPointsChanged()` when balance changes
- Integrated with `NotificationProvider` via constructor injection
- Tracks balance changes in `fetchBalance()` and `usePoints()`

**Result**: Badge state updates automatically on point changes

## Usage Examples

### Example 1: Show Notification After Parking Payment

```dart
// In parking transaction completion handler
import 'package:qparkin_app/utils/point_notification_integration.dart';

Future<void> onParkingComplete(BuildContext context, int pointsEarned) async {
  // Show notification
  await PointNotificationIntegration.notifyPointsEarned(
    context,
    pointsEarned: pointsEarned,
  );
  
  // Balance is automatically refreshed by the integration helper
}
```

### Example 2: Show Notification When Using Points

```dart
// In payment page
import 'package:qparkin_app/utils/point_notification_integration.dart';

Future<void> onUsePoints(BuildContext context, int pointsToUse) async {
  final pointProvider = context.read<PointProvider>();
  
  // Use points
  final success = await pointProvider.usePoints(
    amount: pointsToUse,
    transactionId: currentTransactionId,
  );
  
  if (success) {
    // Show notification
    await PointNotificationIntegration.notifyPointsUsed(
      context,
      pointsUsed: pointsToUse,
    );
  } else {
    // Show error
    PointNotificationIntegration.showError(
      context,
      message: 'Gagal menggunakan poin',
    );
  }
}
```

### Example 3: Show Penalty Notification

```dart
// When penalty is detected
import 'package:qparkin_app/utils/point_notification_integration.dart';

Future<void> onPenaltyDetected(
  BuildContext context,
  int penaltyPoints,
  String reason,
) async {
  // Show penalty notification
  await PointNotificationIntegration.notifyPenalty(
    context,
    penaltyPoints: penaltyPoints,
    reason: reason,
  );
  
  // Balance is automatically refreshed by the integration helper
}
```

### Example 4: Quick Feedback Messages

```dart
// Success message
PointNotificationIntegration.showSuccess(
  context,
  message: 'Data berhasil diperbarui',
);

// Error message
PointNotificationIntegration.showError(
  context,
  message: 'Gagal memuat data',
);
```

## Testing Checklist

### Manual Testing

- [ ] **Badge Appearance**
  1. Open app and note current point balance
  2. Trigger a point change (via backend or mock)
  3. Return to home page
  4. Verify red badge appears on PremiumPointsCard
  5. Tap the card to open point page
  6. Verify badge disappears

- [ ] **Points Earned Notification**
  1. Complete a parking transaction
  2. Verify green dialog appears with correct point amount
  3. Verify "Lihat Detail" button is present
  4. Tap "Lihat Detail"
  5. Verify navigation to point page
  6. Verify new points appear in history

- [ ] **Points Used Notification**
  1. Use points for payment
  2. Verify blue dialog appears with points used and remaining balance
  3. Verify "Lihat Detail" button is present
  4. Tap "Lihat Detail"
  5. Verify navigation to point page
  6. Verify point usage appears in history

- [ ] **Penalty Notification**
  1. Trigger a penalty (e.g., overstay)
  2. Verify orange warning dialog appears
  3. Verify penalty reason is clearly displayed
  4. Verify "Lihat Detail" button is present
  5. Tap "Lihat Detail"
  6. Verify navigation to point page
  7. Verify penalty deduction appears in history

- [ ] **Badge Persistence**
  1. Trigger a point change
  2. Verify badge appears
  3. Close app completely
  4. Reopen app
  5. Verify badge still appears
  6. Open point page
  7. Verify badge disappears
  8. Close and reopen app
  9. Verify badge remains hidden

- [ ] **Accessibility**
  1. Enable TalkBack/VoiceOver
  2. Navigate to PremiumPointsCard
  3. Verify semantic label mentions badge when present
  4. Trigger notification dialog
  5. Verify all elements are properly labeled
  6. Verify "Lihat Detail" button is accessible

### Automated Testing

See `test/widgets/badge_icon_test.dart` for badge widget tests.

## Troubleshooting

### Badge Not Appearing

**Possible Causes**:
1. NotificationProvider not registered in main.dart
2. PointProvider not calling markPointsChanged()
3. SharedPreferences not initialized

**Solution**:
```dart
// Verify in main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => NotificationProvider()),
    ChangeNotifierProxyProvider<NotificationProvider, PointProvider>(
      create: (context) => PointProvider(
        notificationProvider: context.read<NotificationProvider>(),
      ),
      update: (context, notificationProvider, previous) =>
        previous ?? PointProvider(
          notificationProvider: notificationProvider,
        ),
    ),
  ],
)
```

### Badge Not Disappearing

**Possible Causes**:
1. PointPage not calling markNotificationsAsRead()
2. Navigation not properly configured

**Solution**:
```dart
// Verify in PointPage.initState()
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _markNotificationsAsRead();
  });
}

void _markNotificationsAsRead() {
  final provider = context.read<PointProvider>();
  provider.markNotificationsAsRead();
}
```

### Notifications Not Showing

**Possible Causes**:
1. Context is invalid when calling NotificationHelper
2. Dialog is being blocked by another overlay
3. Navigation routes not configured

**Solution**:
```dart
// Ensure context is mounted
if (context.mounted) {
  NotificationHelper.showPointsEarned(context, points: 50);
}

// Verify routes in main.dart
routes: {
  '/point': (context) => const PointPage(),
}
```

## Performance Considerations

1. **Badge State Caching**: Badge state is cached in SharedPreferences to avoid unnecessary rebuilds
2. **Selective Rebuilds**: Using `Consumer2` ensures only the PremiumPointsCard rebuilds when state changes
3. **Debounced Updates**: Point balance changes are debounced to prevent rapid successive notifications

## Future Enhancements

1. **Push Notifications**: Integrate with Firebase Cloud Messaging for background notifications
2. **Notification History**: Store notification history for later viewing
3. **Customizable Notifications**: Allow users to configure notification preferences
4. **Rich Notifications**: Add animations or lottie files for more engaging notifications
5. **Sound/Haptic Feedback**: Add audio and vibration feedback for notifications

## Conclusion

The point notification system is now fully implemented and integrated throughout the QPARKIN app. Users will receive timely feedback when their points change, with clear visual indicators and easy navigation to view details.

All requirements (7.1-7.5) have been fulfilled:
- ✅ Points earned notifications
- ✅ Points used notifications
- ✅ Penalty warnings
- ✅ "Lihat Detail" navigation
- ✅ Badge indicators

The system is production-ready and follows Flutter best practices for state management, accessibility, and user experience.
