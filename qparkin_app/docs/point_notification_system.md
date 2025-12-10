# Point Notification System Documentation

## Overview

The point notification system provides real-time feedback to users when their point balance changes. This includes notifications for:
- Points earned from parking transactions
- Points used for payments
- Penalty deductions

## Components

### 1. NotificationHelper (`lib/utils/notification_helper.dart`)

Utility class for displaying point-related notifications.

#### Methods:

**showPointsEarned()**
```dart
NotificationHelper.showPointsEarned(
  context,
  points: 50,
  onViewDetails: () {
    Navigator.pushNamed(context, '/point');
  },
);
```

**showPointsUsed()**
```dart
NotificationHelper.showPointsUsed(
  context,
  points: 100,
  remainingBalance: 450,
  onViewDetails: () {
    Navigator.pushNamed(context, '/point');
  },
);
```

**showPenaltyDeduction()**
```dart
NotificationHelper.showPenaltyDeduction(
  context,
  points: 25,
  reason: 'Melebihi durasi booking (overstay)',
  onViewDetails: () {
    Navigator.pushNamed(context, '/point');
  },
);
```

**showSnackbar()**
```dart
NotificationHelper.showSnackbar(
  context,
  message: 'Data berhasil diperbarui',
  isError: false,
);
```

### 2. NotificationProvider (`lib/logic/providers/notification_provider.dart`)

State management for notification badges and unread indicators.

#### Properties:
- `hasUnreadPointChanges`: Boolean indicating if there are unread point changes
- `_lastKnownBalance`: Tracks the last known balance to detect changes

#### Methods:

**markPointsChanged(int newBalance)**
- Called when points change
- Marks notifications as unread if balance changed
- Caches state to SharedPreferences

**markPointChangesAsRead()**
- Called when user opens point page
- Clears unread indicator
- Updates cached state

**initializeBalance(int balance)**
- Sets initial balance on app start
- Prevents false notifications on first load

### 3. PointProvider Integration

The PointProvider automatically triggers notifications when:
- Balance is fetched and has changed
- Points are used for payment
- Data is refreshed

#### Automatic Notification Triggers:

```dart
// In fetchBalance()
if (oldBalance != null && oldBalance != balance) {
  _notificationProvider?.markPointsChanged(balance);
}

// In usePoints()
if (success) {
  final newBalance = _balance! - amount;
  _notificationProvider?.markPointsChanged(newBalance);
}
```

### 4. Badge Icon Widget (`lib/presentation/widgets/badge_icon.dart`)

Reusable widget for showing notification badges on icons.

```dart
BadgeIcon(
  icon: Icons.star,
  showBadge: hasUnreadNotifications,
  iconSize: 24,
  iconColor: Colors.blue,
)
```

## Usage Examples

### Example 1: Show notification after parking payment

```dart
// In payment completion handler
final pointsEarned = calculatePointsFromTransaction(transaction);

NotificationHelper.showPointsEarned(
  context,
  points: pointsEarned,
  onViewDetails: () {
    Navigator.pushNamed(context, '/point');
  },
);

// Update point balance
await pointProvider.fetchBalance();
```

### Example 2: Show notification when using points

```dart
// In payment page after using points
final success = await pointProvider.usePoints(
  amount: pointsToUse,
  transactionId: transactionId,
);

if (success) {
  NotificationHelper.showPointsUsed(
    context,
    points: pointsToUse,
    remainingBalance: pointProvider.balance ?? 0,
    onViewDetails: () {
      Navigator.pushNamed(context, '/point');
    },
  );
}
```

### Example 3: Show penalty notification

```dart
// When penalty is detected
NotificationHelper.showPenaltyDeduction(
  context,
  points: penaltyAmount,
  reason: 'Melebihi durasi booking (overstay)',
  onViewDetails: () {
    Navigator.pushNamed(context, '/point');
  },
);

// Refresh point data
await pointProvider.fetchBalance();
```

### Example 4: Add badge to navigation icon

```dart
// In navigation bar widget
Consumer<NotificationProvider>(
  builder: (context, notificationProvider, child) {
    return BadgeIcon(
      icon: Icons.star,
      showBadge: notificationProvider.hasUnreadPointChanges,
      iconSize: 24,
      iconColor: isActive ? activeColor : inactiveColor,
    );
  },
)
```

## Integration with Existing Pages

### Point Page Integration

The PointPage automatically marks notifications as read when opened:

```dart
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

### Payment Page Integration

To show notifications when points are used:

```dart
// After successful payment with points
if (pointsUsed > 0) {
  NotificationHelper.showPointsUsed(
    context,
    points: pointsUsed,
    remainingBalance: newBalance,
    onViewDetails: () {
      Navigator.pushNamed(context, '/point');
    },
  );
}
```

### Parking Transaction Completion

To show notifications when points are earned:

```dart
// After parking transaction is completed
final pointsEarned = transaction.pointsEarned;

if (pointsEarned > 0) {
  NotificationHelper.showPointsEarned(
    context,
    points: pointsEarned,
    onViewDetails: () {
      Navigator.pushNamed(context, '/point');
    },
  );
}
```

## Navigation Badge Implementation

To add badge indicators to navigation items, wrap the icon with BadgeIcon and consume NotificationProvider:

```dart
// Example for bottom navigation bar
BottomNavigationBarItem(
  icon: Consumer<NotificationProvider>(
    builder: (context, notificationProvider, _) {
      return BadgeIcon(
        icon: Icons.star_outline,
        showBadge: notificationProvider.hasUnreadPointChanges,
        iconSize: 24,
      );
    },
  ),
  label: 'Poin',
)
```

## Requirements Mapping

- **Requirement 7.1**: Points earned notification - `NotificationHelper.showPointsEarned()`
- **Requirement 7.2**: Points used notification - `NotificationHelper.showPointsUsed()`
- **Requirement 7.3**: Penalty notification - `NotificationHelper.showPenaltyDeduction()`
- **Requirement 7.4**: "Lihat Detail" button - All notification dialogs include this button
- **Requirement 7.5**: Badge indicator - `NotificationProvider` + `BadgeIcon` widget

## Testing

### Manual Testing Checklist

1. **Points Earned Notification**
   - [ ] Complete a parking transaction
   - [ ] Verify notification appears with correct point amount
   - [ ] Tap "Lihat Detail" button
   - [ ] Verify navigation to point page
   - [ ] Verify badge appears on point icon

2. **Points Used Notification**
   - [ ] Use points for payment
   - [ ] Verify notification shows points used and remaining balance
   - [ ] Tap "Lihat Detail" button
   - [ ] Verify navigation to point page

3. **Penalty Notification**
   - [ ] Trigger a penalty (e.g., overstay)
   - [ ] Verify warning notification appears
   - [ ] Verify reason is clearly displayed
   - [ ] Tap "Lihat Detail" button
   - [ ] Verify navigation to point page

4. **Badge Indicator**
   - [ ] Verify badge appears when points change
   - [ ] Open point page
   - [ ] Verify badge disappears
   - [ ] Close and reopen app
   - [ ] Verify badge state persists correctly

## Future Enhancements

1. **Push Notifications**: Integrate with Firebase Cloud Messaging for background notifications
2. **Notification History**: Store notification history for later viewing
3. **Notification Preferences**: Allow users to customize notification settings
4. **Sound/Vibration**: Add haptic feedback for notifications
5. **Rich Notifications**: Add images or animations to notifications

## Troubleshooting

### Badge not appearing
- Verify NotificationProvider is registered in main.dart
- Check that markPointsChanged() is being called
- Verify SharedPreferences permissions

### Notifications not showing
- Ensure context is valid when calling NotificationHelper
- Check that dialogs are not being blocked by other overlays
- Verify navigation routes are properly configured

### State not persisting
- Check SharedPreferences initialization
- Verify cache keys are consistent
- Check for errors in console logs

