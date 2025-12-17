# Task 15.3: Backend API Implementation Checklist

## Overview
Implementasi API endpoints untuk Slot Reservation System setelah database migration selesai.

---

## 🎯 Objectives

- [ ] Create API endpoints untuk floor listing
- [ ] Create API endpoints untuk slot visualization
- [ ] Create API endpoints untuk slot reservation
- [ ] Update booking endpoint untuk support slot_id dan reservation_id
- [ ] Implement validation dan error handling
- [ ] Create background jobs untuk cleanup
- [ ] Write API tests

---

## 📝 Implementation Tasks

### 1. Controllers

#### 1.1 ParkingFloorController
- [ ] Create controller: `php artisan make:controller Api/ParkingFloorController`
- [ ] Implement `index($mallId)` - Get floors for mall
- [ ] Implement `show($floorId)` - Get floor details
- [ ] Add validation
- [ ] Add error handling
- [ ] Return JSON responses with proper status codes

**Endpoints**:
```php
GET /api/parking/floors/{mallId}
GET /api/parking/floors/{floorId}/details
```

#### 1.2 ParkingSlotController
- [ ] Create controller: `php artisan make:controller Api/ParkingSlotController`
- [ ] Implement `visualization($floorId)` - Get slots for visualization
- [ ] Support query params: `vehicle_type`, `status`
- [ ] Implement caching (2 minutes)
- [ ] Add pagination if needed
- [ ] Return slot grid data

**Endpoints**:
```php
GET /api/parking/slots/{floorId}/visualization?vehicle_type=Roda+Empat
```

#### 1.3 SlotReservationController
- [ ] Create controller: `php artisan make:controller Api/SlotReservationController`
- [ ] Implement `reserveRandom()` - Reserve random available slot
- [ ] Implement `show($reservationId)` - Get reservation details
- [ ] Implement `cancel($reservationId)` - Cancel reservation
- [ ] Validate user ownership
- [ ] Handle no slots available error
- [ ] Return reservation with expiration time

**Endpoints**:
```php
POST   /api/parking/slots/reserve-random
GET    /api/parking/reservations/{reservationId}
DELETE /api/parking/reservations/{reservationId}
```

#### 1.4 Update BookingController
- [ ] Update `store()` method to accept `id_slot` and `reservation_id`
- [ ] Validate reservation before creating booking
- [ ] Check reservation expiration
- [ ] Confirm reservation on successful booking
- [ ] Mark slot as occupied
- [ ] Handle fallback if no slot provided (backward compatibility)

**Updated Endpoint**:
```php
POST /api/booking
Body: {
  "id_user": 1,
  "id_kendaraan": 1,
  "id_mall": 1,
  "id_slot": 25,              // NEW (optional)
  "reservation_id": "uuid",   // NEW (optional)
  "waktu_mulai": "...",
  "durasi_booking": 120
}
```

---

### 2. Request Validation

#### 2.1 ReserveSlotRequest
- [ ] Create: `php artisan make:request ReserveSlotRequest`
- [ ] Validate: `id_floor`, `id_user`, `id_kendaraan`, `jenis_kendaraan`
- [ ] Check floor exists and active
- [ ] Check user has no active reservation
- [ ] Check vehicle type matches floor

#### 2.2 CreateBookingRequest (Update)
- [ ] Add optional validation for `id_slot` and `reservation_id`
- [ ] Validate reservation exists and not expired
- [ ] Validate slot belongs to selected mall/parkiran

---

### 3. Services

#### 3.1 SlotReservationService
- [ ] Create service class
- [ ] Method: `findAvailableSlot($floorId, $jenisKendaraan)`
- [ ] Method: `reserveSlot($slotId, $userId, $kendaraanId, $floorId)`
- [ ] Method: `confirmReservation($reservationId)`
- [ ] Method: `cancelReservation($reservationId)`
- [ ] Method: `expireReservation($reservationId)`
- [ ] Handle concurrent reservation attempts
- [ ] Use database transactions

#### 3.2 SlotVisualizationService
- [ ] Create service class
- [ ] Method: `getFloorVisualization($floorId, $vehicleType = null)`
- [ ] Implement caching strategy
- [ ] Format slot data for frontend grid
- [ ] Include availability statistics

---

### 4. Resources (API Responses)

#### 4.1 ParkingFloorResource
- [ ] Create: `php artisan make:resource ParkingFloorResource`
- [ ] Format floor data with availability percentage
- [ ] Include slot counts

#### 4.2 ParkingSlotResource
- [ ] Create: `php artisan make:resource ParkingSlotResource`
- [ ] Format slot data for visualization
- [ ] Include position coordinates

#### 4.3 SlotReservationResource
- [ ] Create: `php artisan make:resource SlotReservationResource`
- [ ] Include reservation details
- [ ] Calculate remaining time
- [ ] Include slot and floor information

---

### 5. Routes

#### 5.1 API Routes
- [ ] Add routes to `routes/api.php`
- [ ] Group under `parking` prefix
- [ ] Apply `auth:sanctum` middleware
- [ ] Apply rate limiting

```php
Route::middleware('auth:sanctum')->prefix('parking')->group(function () {
    // Floors
    Route::get('floors/{mallId}', [ParkingFloorController::class, 'index']);
    Route::get('floors/{floorId}/details', [ParkingFloorController::class, 'show']);
    
    // Slots
    Route::get('slots/{floorId}/visualization', [ParkingSlotController::class, 'visualization']);
    
    // Reservations
    Route::post('slots/reserve-random', [SlotReservationController::class, 'reserveRandom']);
    Route::get('reservations/{reservationId}', [SlotReservationController::class, 'show']);
    Route::delete('reservations/{reservationId}', [SlotReservationController::class, 'cancel']);
});
```

---

### 6. Background Jobs

#### 6.1 ExpireReservationsJob
- [ ] Create: `php artisan make:job ExpireReservationsJob`
- [ ] Find expired reservations
- [ ] Mark as expired
- [ ] Release slots
- [ ] Log expired reservations

#### 6.2 Schedule Job
- [ ] Add to `app/Console/Kernel.php`
- [ ] Run every minute
- [ ] Add logging

```php
$schedule->job(new ExpireReservationsJob)->everyMinute();
```

---

### 7. Error Handling

#### 7.1 Custom Exceptions
- [ ] `NoSlotsAvailableException`
- [ ] `ReservationExpiredException`
- [ ] `ReservationNotFoundException`
- [ ] `SlotAlreadyReservedException`

#### 7.2 Error Responses
- [ ] Standardize error response format
- [ ] Include error codes
- [ ] Provide helpful messages

```json
{
  "success": false,
  "error": {
    "code": "NO_SLOTS_AVAILABLE",
    "message": "Tidak ada slot tersedia di lantai ini",
    "suggestion": "Coba lantai lain atau tunggu beberapa saat"
  }
}
```

---

### 8. Testing

#### 8.1 Unit Tests
- [ ] Test `SlotReservationService` methods
- [ ] Test model helper methods
- [ ] Test reservation expiration logic
- [ ] Test slot status transitions

#### 8.2 Feature Tests
- [ ] Test GET floors endpoint
- [ ] Test GET slot visualization endpoint
- [ ] Test POST reserve slot endpoint
- [ ] Test booking with slot
- [ ] Test booking without slot (backward compatibility)
- [ ] Test reservation expiration
- [ ] Test concurrent reservations
- [ ] Test error scenarios

#### 8.3 Integration Tests
- [ ] Test complete booking flow with slot
- [ ] Test reservation timeout
- [ ] Test slot release on cancellation

---

### 9. Documentation

#### 9.1 API Documentation
- [ ] Document all endpoints in Postman/Swagger
- [ ] Include request/response examples
- [ ] Document error codes
- [ ] Add authentication requirements

#### 9.2 Code Documentation
- [ ] PHPDoc comments for all methods
- [ ] Inline comments for complex logic
- [ ] README updates

---

### 10. Performance Optimization

#### 10.1 Caching
- [ ] Cache floor data (5 minutes)
- [ ] Cache slot visualization (2 minutes)
- [ ] Implement cache invalidation on updates

#### 10.2 Database Optimization
- [ ] Use eager loading for relationships
- [ ] Optimize queries with indexes
- [ ] Use database transactions for reservations

#### 10.3 Rate Limiting
- [ ] Apply rate limiting to reservation endpoint
- [ ] Prevent spam reservations

---

## 🧪 Testing Checklist

### Manual Testing
- [ ] Test floor listing with Postman
- [ ] Test slot visualization with different filters
- [ ] Test random slot reservation
- [ ] Test reservation expiration (wait 5 minutes)
- [ ] Test booking with valid reservation
- [ ] Test booking with expired reservation
- [ ] Test concurrent reservations (multiple users)
- [ ] Test no slots available scenario
- [ ] Test feature flag (enabled/disabled mall)

### Automated Testing
- [ ] Run unit tests: `php artisan test --filter=SlotReservation`
- [ ] Run feature tests: `php artisan test --filter=Api`
- [ ] Check code coverage
- [ ] Run static analysis: `./vendor/bin/phpstan analyse`

---

## 📋 Deployment Checklist

### Pre-Deployment
- [ ] All tests passing
- [ ] Code reviewed
- [ ] Documentation updated
- [ ] Environment variables configured
- [ ] Scheduled job configured

### Deployment
- [ ] Deploy code to staging
- [ ] Test on staging environment
- [ ] Enable feature flag for test mall
- [ ] Monitor logs and errors
- [ ] Deploy to production
- [ ] Gradual rollout per mall

### Post-Deployment
- [ ] Monitor API response times
- [ ] Monitor reservation expiration job
- [ ] Check error rates
- [ ] Gather user feedback

---

## 🎯 Success Criteria

- [ ] All API endpoints working correctly
- [ ] Reservation timeout working (5 minutes)
- [ ] Slot status updates correctly
- [ ] Backward compatibility maintained
- [ ] No performance degradation
- [ ] All tests passing
- [ ] Documentation complete
- [ ] Zero critical bugs

---

## 📚 Reference Files

- Migration Guide: `docs/SLOT_RESERVATION_MIGRATION_GUIDE.md`
- Quick Start: `docs/SLOT_RESERVATION_QUICK_START.md`
- Models: `app/Models/ParkingFloor.php`, `ParkingSlot.php`, `SlotReservation.php`
- Existing Booking Controller: `app/Http/Controllers/Api/BookingController.php`

---

## 🚀 Quick Commands

```bash
# Create controllers
php artisan make:controller Api/ParkingFloorController
php artisan make:controller Api/ParkingSlotController
php artisan make:controller Api/SlotReservationController

# Create requests
php artisan make:request ReserveSlotRequest

# Create resources
php artisan make:resource ParkingFloorResource
php artisan make:resource ParkingSlotResource
php artisan make:resource SlotReservationResource

# Create job
php artisan make:job ExpireReservationsJob

# Run tests
php artisan test
php artisan test --filter=SlotReservation

# Check routes
php artisan route:list --path=parking
```

---

**Status**: Ready to Start  
**Estimated Time**: 8-12 hours  
**Priority**: High  
**Dependencies**: Task 15.1 & 15.2 (Completed ✅)
