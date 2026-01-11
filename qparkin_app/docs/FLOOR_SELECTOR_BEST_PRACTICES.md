# Floor Selector - Best Practices & Implementation Guide

## Problem Solved
**Issue:** Floor selector tidak muncul karena `has_slot_reservation_enabled = false` di database.

**Solution:** Enable feature flag di database + Implementasi best practice untuk UI.

---

## Best Practice #1: Graceful Degradation

### Current Implementation (Feature Flag Based)
```dart
Widget _buildSlotReservationSection(BookingProvider provider, double spacing) {
  // ❌ PROBLEM: Hides entire UI if feature disabled
  if (!provider.isSlotReservationEnabled) {
    return const SizedBox.shrink();
  }
  
  return Column(
    children: [
      FloorSelectorWidget(...),
      SlotVisualizationWidget(...),
    ],
  );
}
```

**Issues:**
- All-or-nothing approach
- No feedback to user why feature is hidden
- Hard to debug

### Recommended: Progressive Enhancement
```dart
Widget _buildSlotReservationSection(BookingProvider provider, double spacing) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Always show section header
      Text(
        'Pilih Lokasi Parkir',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: spacing * 0.75),
      
      // Show appropriate content based on feature flag
      if (provider.isSlotReservationEnabled) ...[
        // Feature enabled - show full functionality
        FloorSelectorWidget(
          floors: provider.floors,
          selectedFloor: provider.selectedFloor,
          isLoading: provider.isLoadingFloors,
          onFloorSelected: (floor) => _handleFloorSelection(floor, provider),
        ),
        
        if (provider.selectedFloor != null) ...[
          SizedBox(height: spacing),
          SlotVisualizationWidget(...),
          SizedBox(height: spacing),
          SlotReservationButton(...),
        ],
      ] else ...[
        // Feature disabled - show informative message
        _buildFeatureDisabledCard(),
      ],
    ],
  );
}

Widget _buildFeatureDisabledCard() {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(Icons.info_outline, size: 48, color: Colors.blue),
          SizedBox(height: 12),
          Text(
            'Pemilihan Slot Manual',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Fitur pemilihan lantai dan slot parkir belum tersedia untuk mall ini. '
            'Slot akan dipilihkan secara otomatis saat booking.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    ),
  );
}
```

---

## Best Practice #2: Loading States

### Always Show Skeleton/Shimmer During Load
```dart
FloorSelectorWidget(
  floors: provider.floors,
  selectedFloor: provider.selectedFloor,
  isLoading: provider.isLoadingFloors, // ✅ Show loading state
  onFloorSelected: (floor) => _handleFloorSelection(floor, provider),
  onRetry: () {
    if (_authToken != null) {
      provider.fetchFloors(token: _authToken!);
    }
  },
)
```

### FloorSelectorWidget Implementation
```dart
class FloorSelectorWidget extends StatelessWidget {
  final List<ParkingFloorModel> floors;
  final ParkingFloorModel? selectedFloor;
  final bool isLoading;
  final Function(ParkingFloorModel) onFloorSelected;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (isLoading) {
      return _buildLoadingShimmer();
    }
    
    // Empty state
    if (floors.isEmpty) {
      return _buildEmptyState();
    }
    
    // Success state - show floors
    return _buildFloorList();
  }
  
  Widget _buildLoadingShimmer() {
    return Column(
      children: List.generate(3, (index) => 
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 80,
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.layers_outlined, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'Tidak Ada Data Lantai',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Belum ada lantai parkir yang tersedia untuk mall ini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (onRetry != null) ...[
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh),
                label: Text('Coba Lagi'),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildFloorList() {
    return Column(
      children: floors.map((floor) => _buildFloorCard(floor)).toList(),
    );
  }
  
  Widget _buildFloorCard(ParkingFloorModel floor) {
    final isSelected = selectedFloor?.idFloor == floor.idFloor;
    final hasSlots = floor.availableSlots > 0;
    
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Color(0xFF573ED1) : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: hasSlots ? () => onFloorSelected(floor) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Floor icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: hasSlots 
                      ? Color(0xFF573ED1).withOpacity(0.1)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.layers,
                  color: hasSlots ? Color(0xFF573ED1) : Colors.grey,
                  size: 28,
                ),
              ),
              SizedBox(width: 16),
              
              // Floor info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      floor.floorName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: hasSlots ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${floor.availableSlots}/${floor.totalSlots} slot tersedia',
                      style: TextStyle(
                        fontSize: 14,
                        color: hasSlots ? Colors.green[700] : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Selection indicator
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Color(0xFF573ED1),
                  size: 28,
                )
              else if (!hasSlots)
                Chip(
                  label: Text('Penuh', style: TextStyle(fontSize: 12)),
                  backgroundColor: Colors.red[100],
                  labelStyle: TextStyle(color: Colors.red[700]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Best Practice #3: Error Handling

### Handle All Error States
```dart
Widget _buildSlotReservationSection(BookingProvider provider, double spacing) {
  return Column(
    children: [
      Text('Pilih Lokasi Parkir', ...),
      SizedBox(height: spacing * 0.75),
      
      // Error state
      if (provider.errorMessage != null && !provider.isLoadingFloors)
        _buildErrorCard(provider.errorMessage!, () {
          if (_authToken != null) {
            provider.fetchFloors(token: _authToken!);
          }
        }),
      
      // Loading state
      if (provider.isLoadingFloors)
        _buildLoadingShimmer(),
      
      // Success state
      if (!provider.isLoadingFloors && provider.errorMessage == null)
        FloorSelectorWidget(...),
    ],
  );
}

Widget _buildErrorCard(String message, VoidCallback onRetry) {
  return Card(
    color: Colors.red[50],
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[700]),
          SizedBox(height: 12),
          Text(
            'Gagal Memuat Data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red[900],
            ),
          ),
          SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red[700]),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: Icon(Icons.refresh),
            label: Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
            ),
          ),
        ],
      ),
    ),
  );
}
```

---

## Best Practice #4: Accessibility

### Add Semantic Labels
```dart
Semantics(
  label: 'Pilih lantai parkir ${floor.floorName}',
  hint: '${floor.availableSlots} dari ${floor.totalSlots} slot tersedia',
  button: true,
  enabled: floor.availableSlots > 0,
  child: InkWell(
    onTap: () => onFloorSelected(floor),
    child: _buildFloorCard(floor),
  ),
)
```

---

## Best Practice #5: Performance Optimization

### Use ListView.builder for Large Lists
```dart
Widget _buildFloorList() {
  return ListView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemCount: floors.length,
    itemBuilder: (context, index) {
      return _buildFloorCard(floors[index]);
    },
  );
}
```

### Debounce API Calls
```dart
Timer? _debounceTimer;

void _handleFloorSelection(ParkingFloorModel floor, BookingProvider provider) {
  // Cancel previous timer
  _debounceTimer?.cancel();
  
  // Set new timer
  _debounceTimer = Timer(Duration(milliseconds: 300), () {
    provider.selectFloor(floor, token: _authToken);
    
    if (_authToken != null) {
      provider.startSlotRefreshTimer(token: _authToken!);
    }
  });
}
```

---

## Recommended Implementation

### Simplified booking_page.dart
```dart
Widget _buildSlotReservationSection(BookingProvider provider, double spacing) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Section header
      Text(
        'Pilih Lokasi Parkir',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      SizedBox(height: spacing * 0.75),
      
      // Content based on state
      _buildFloorSelectorContent(provider, spacing),
    ],
  );
}

Widget _buildFloorSelectorContent(BookingProvider provider, double spacing) {
  // Feature disabled
  if (!provider.isSlotReservationEnabled) {
    return _buildFeatureDisabledCard();
  }
  
  // Error state
  if (provider.errorMessage != null && !provider.isLoadingFloors) {
    return _buildErrorCard(
      provider.errorMessage!,
      () {
        if (_authToken != null) {
          provider.fetchFloors(token: _authToken!);
        }
      },
    );
  }
  
  // Loading state
  if (provider.isLoadingFloors) {
    return _buildLoadingShimmer();
  }
  
  // Empty state
  if (provider.floors.isEmpty) {
    return _buildEmptyState();
  }
  
  // Success state - show floors
  return Column(
    children: [
      FloorSelectorWidget(
        floors: provider.floors,
        selectedFloor: provider.selectedFloor,
        onFloorSelected: (floor) => _handleFloorSelection(floor, provider),
      ),
      
      if (provider.selectedFloor != null) ...[
        SizedBox(height: spacing),
        SlotVisualizationWidget(...),
        SizedBox(height: spacing),
        SlotReservationButton(...),
      ],
      
      if (provider.hasReservedSlot) ...[
        SizedBox(height: spacing),
        ReservedSlotInfoCard(...),
      ],
    ],
  );
}
```

---

## Testing Checklist

### After Enabling Feature Flag

1. **Hot restart Flutter app** (bukan hot reload!)
2. **Verify debug logs:**
   ```
   [BookingProvider] isSlotReservationEnabled: true
   [BookingProvider] Fetching floors for mall: 4
   [BookingProvider] SUCCESS: Loaded 3 floors
   ```
3. **Verify UI:**
   - ✅ Section "Pilih Lokasi Parkir" visible
   - ✅ 3 floor cards displayed
   - ✅ Each card shows slot availability
   - ✅ Cards are clickable
   - ✅ Selected card has border highlight
4. **Test interactions:**
   - Click floor → Slot visualization appears
   - Click "Reservasi Slot Random" → Slot reserved
   - Reserved slot info card appears

---

## Summary

### What Was Wrong
- `has_slot_reservation_enabled = false` in database
- Guard condition hid entire UI section
- No feedback to user

### What Was Fixed
- ✅ Enabled feature flag in database
- ✅ Added debug logging
- ✅ Documented best practices

### Best Practices Applied
1. **Graceful Degradation** - Show informative message when feature disabled
2. **Loading States** - Shimmer/skeleton during data fetch
3. **Error Handling** - Retry button and clear error messages
4. **Accessibility** - Semantic labels for screen readers
5. **Performance** - ListView.builder and debouncing

---

**Status:** ✅ FIXED - Feature flag enabled, UI will now show floor selector

**Date:** 2026-01-11
