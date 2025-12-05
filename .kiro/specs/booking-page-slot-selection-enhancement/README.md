# Booking Page Slot Selection & Time/Duration Enhancement

## Overview

This specification defines two major UX/UI enhancements to the QPARKIN Booking Page:

### 1. Slot Selection Feature
Allows drivers to choose specific parking locations by:
- Selecting parking floor with availability information
- Viewing available slots in grid or list view
- Selecting preferred parking slot visually
- Seeing real-time slot availability updates

### 2. Modern Time & Duration Design
Improves the booking time selection with:
- Unified card design combining time and duration
- Enhanced date picker with better visual hierarchy
- Larger, more prominent duration selection chips (80x56px)
- Clear calculated end time display
- Modern, touch-friendly interface

## Key Benefits

**For Users:**
- More control over parking location
- Better visibility of available options
- Easier time and duration selection
- Clearer booking information

**For Business:**
- Reduced parking conflicts
- Better space utilization
- Improved user satisfaction
- More accurate booking data

## Quick Start

### Prerequisites
- Existing QPARKIN booking implementation
- Flutter 3.0+ with Dart
- Laravel backend with MySQL database
- Understanding of Provider state management

### Implementation Order

1. **Data Layer** (Tasks 1-2)
   - Create ParkingFloorModel and ParkingSlotModel
   - Extend BookingService with slot APIs
   - Estimated time: 2-3 days

2. **State Management** (Task 3)
   - Update BookingProvider with slot state
   - Implement floor and slot selection logic
   - Estimated time: 2-3 days

3. **UI Components** (Tasks 4-8)
   - Create FloorSelectorWidget
   - Create SlotGridWidget and SlotListWidget
   - Create UnifiedTimeDurationCard
   - Estimated time: 5-7 days

4. **Integration** (Tasks 9-10)
   - Update BookingPage layout
   - Integrate new components
   - Update confirmation dialog
   - Estimated time: 2-3 days

5. **Polish** (Tasks 11-13)
   - Implement accessibility features
   - Add error handling
   - Optimize performance
   - Estimated time: 3-4 days

6. **Documentation & Testing** (Tasks 14-17)
   - Update documentation
   - Database migration
   - End-to-end testing
   - Estimated time: 2-3 days

**Total Estimated Time: 16-23 days**

## Document Structure

```
.kiro/specs/booking-page-slot-selection-enhancement/
├── README.md           # This file - overview and quick start
├── requirements.md     # Detailed requirements with acceptance criteria
├── design.md          # Technical design and architecture
└── tasks.md           # Implementation task breakdown
```

## Key Design Decisions

### Slot Selection
- **Grid View**: 4-6 columns responsive grid for visual slot selection
- **List View**: Alternative accessible list view for screen readers
- **Color Coding**: Green (available), Grey (occupied), Yellow (reserved), Red (disabled)
- **Real-time Updates**: 15-second polling for slot availability
- **Caching**: 5-minute cache for floor data, 2-minute for slots

### Time & Duration
- **Unified Card**: Single card (elevation 3) containing both selectors
- **Large Chips**: 80x56px minimum for easy tapping
- **Purple Theme**: Consistent 0xFF573ED1 accent color
- **Animations**: 200-300ms transitions for smooth UX
- **Accessibility**: 48dp minimum touch targets, 4.5:1 contrast ratio

## API Endpoints

### New Endpoints Required

1. **GET /api/parking/floors/{mallId}**
   - Returns list of parking floors with availability
   - Response includes floor number, name, total/available slots

2. **GET /api/parking/slots/{floorId}**
   - Returns list of slots for specific floor
   - Supports vehicle type filtering
   - Response includes slot code, status, type, position

3. **POST /api/parking/slots/reserve**
   - Temporarily reserves slot during booking
   - 5-minute reservation timeout
   - Prevents double-booking

### Updated Endpoints

1. **POST /api/booking/create**
   - Now accepts optional `id_slot` parameter
   - Falls back to auto-assignment if not provided
   - Validates slot availability before booking

## Database Changes

### New/Updated Tables

```sql
-- Add slot_id to booking table (nullable for backward compatibility)
ALTER TABLE booking 
ADD COLUMN id_slot VARCHAR(50) NULL,
ADD FOREIGN KEY (id_slot) REFERENCES parkiran(id_parkiran);

-- Add slot_id to transaksi_parkir table
ALTER TABLE transaksi_parkir
ADD COLUMN id_slot VARCHAR(50) NULL,
ADD FOREIGN KEY (id_slot) REFERENCES parkiran(id_parkiran);

-- Add feature flag to mall table
ALTER TABLE mall
ADD COLUMN has_slot_selection_enabled BOOLEAN DEFAULT FALSE;
```

## Migration Strategy

### Phase 1: Optional Slot Selection
- Add nullable slot_id columns
- Implement UI with feature flag
- Support both manual and auto-assignment
- Test with subset of malls

### Phase 2: Gradual Rollout
- Enable for high-traffic malls first
- Monitor performance and user feedback
- Adjust based on data

### Phase 3: Full Deployment
- Enable for all malls
- Make slot selection mandatory
- Update constraints (NOT NULL)
- Remove old TimeDurationPicker

## Testing Requirements

### Unit Tests
- ParkingFloorModel and ParkingSlotModel
- BookingProvider slot selection methods
- Validation logic

### Widget Tests
- FloorSelectorWidget
- SlotGridWidget and SlotListWidget
- UnifiedTimeDurationCard
- DurationChip component

### Integration Tests
- Complete slot selection flow
- Time/duration selection flow
- Booking with slot
- Error scenarios

### Accessibility Tests
- Screen reader navigation
- Keyboard navigation
- Color contrast
- Focus indicators

**Target Coverage: 80% minimum**

## Performance Targets

- Floor list load: < 1 second
- Slot grid load: < 1.5 seconds
- Slot selection response: < 200ms
- Scroll performance: 60fps
- Memory usage: < 100MB increase

## Accessibility Compliance

- WCAG 2.1 Level AA compliance
- Minimum 4.5:1 color contrast
- 48dp minimum touch targets
- Screen reader support
- Keyboard navigation
- Semantic labels for all elements

## Next Steps

1. **Review Requirements**: Read `requirements.md` for detailed acceptance criteria
2. **Study Design**: Review `design.md` for technical architecture
3. **Start Implementation**: Follow `tasks.md` in sequential order
4. **Test Incrementally**: Write tests as you implement features
5. **Document Changes**: Update docs as you build

## Questions or Issues?

Refer to:
- SKPPL documentation: `qparkin_app/assets/docs/skppl_qparkin.md`
- Existing booking implementation: `qparkin_app/lib/presentation/screens/booking_page.dart`
- Current provider: `qparkin_app/lib/logic/providers/booking_provider.dart`
- Design system: `.kiro/specs/booking-page-implementation/design.md`

## Success Criteria

✅ Users can select specific parking slots
✅ Floor and slot availability displayed in real-time
✅ Time and duration selection is intuitive and modern
✅ All accessibility requirements met
✅ Performance targets achieved
✅ 80%+ test coverage
✅ Zero critical bugs in production
✅ Positive user feedback on new features

