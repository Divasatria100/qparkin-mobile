# Booking Parkiran Quick Reference

## Quick Fix Commands

### 1. Run Flutter App with Logging
```bash
cd qparkin_app
flutter run --dart-define=API_URL=http://192.168.0.101:8000
```

### 2. Test API Endpoint
```bash
curl -X GET "http://192.168.0.101:8000/api/mall/4/parkiran" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 3. Check Database
```sql
SELECT * FROM parkiran WHERE id_mall = 4;
```

---

## Error Messages & Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| "Data parkiran tidak tersedia" | No `id_parkiran` in mall data | Check logs, verify database has parkiran |
| `❌ No parkiran found` | Database has no parkiran for mall | Create parkiran via Admin Dashboard |
| `❌ Unauthorized (401)` | Token invalid or expired | Re-login to get fresh token |
| `❌ Parkiran has no ID` | Database row missing `id_parkiran` | Check database schema |
| HTTP 422 validation error | Missing `id_parkiran` or `durasi_booking` | Fixed in `booking_request.dart` |
| HTTP 405 method not allowed | Wrong API endpoint | Fixed - use `/api/booking` not `/api/booking/create` |

---

## Key Log Messages

### ✅ Success Pattern
```
[BookingProvider] Fetching parkiran for mall: 4
[BookingService] Parkiran response status: 200
[BookingService] ✅ Found 1 parkiran
[BookingProvider] ✅ Parkiran ID set successfully: 1
```

### ❌ Failure Pattern
```
[BookingProvider] Fetching parkiran for mall: 4
[BookingService] Parkiran response status: 404
[BookingService] ❌ Parkiran not found (404)
[BookingProvider] ❌ WARNING: No parkiran found for mall 4
```

---

## API Endpoint Details

**URL**: `GET /api/mall/{id}/parkiran`

**Headers**:
- `Accept: application/json`
- `Authorization: Bearer {token}`

**Success Response** (200):
```json
{
  "success": true,
  "data": [
    {
      "id_parkiran": 1,
      "nama_parkiran": "Parkiran Mall A",
      "status": "Tersedia"
    }
  ]
}
```

---

## Database Structure

```
mall (id_mall)
  └─ parkiran (id_parkiran, id_mall)  [1-to-1 relationship]
      └─ parking_floors (id_floor, id_parkiran)
          └─ parking_slots (id_slot, id_floor)
```

**Business Rule**: Each mall has exactly 1 parkiran.

---

## Booking Flow

1. User selects mall from map → `id_mall`
2. BookingPage initializes → fetches `id_parkiran`
3. User confirms booking → uses `id_parkiran` (NOT `id_mall`)
4. Backend creates booking with `id_parkiran`

---

## Files to Check

### Flutter (qparkin_app)
- `lib/logic/providers/booking_provider.dart` - `_fetchParkiranForMall()`
- `lib/data/services/booking_service.dart` - `getParkiranForMall()`
- `lib/presentation/screens/booking_page.dart` - `_initializeAuthData()`
- `lib/data/models/booking_request.dart` - `idMall` field (uses `id_parkiran`)

### Backend (qparkin_backend)
- `app/Http/Controllers/Api/MallController.php` - `getParkiran()`
- `routes/api.php` - Route definition
- `app/Models/Mall.php` - `parkiran()` relationship
- `app/Models/Parkiran.php` - Model definition

---

## Quick Troubleshooting

### Issue: "Data parkiran tidak tersedia"

**Step 1**: Check logs for parkiran fetch
```
Look for: [BookingProvider] Fetching parkiran for mall: X
```

**Step 2**: Verify API response
```bash
curl -X GET "http://192.168.0.101:8000/api/mall/4/parkiran" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Step 3**: Check database
```sql
SELECT * FROM parkiran WHERE id_mall = 4;
```

**Step 4**: Create parkiran if missing
- Go to Admin Dashboard → Parkiran
- Click "Tambah Parkiran"
- Select mall and fill details
- Save

---

## Enhanced Logging (Applied ✅)

### BookingProvider
- ✅ Log API request details
- ✅ Log response structure
- ✅ Log extracted `id_parkiran`
- ✅ Log success/failure indicators
- ✅ Log stack traces on errors

### BookingService
- ✅ Log request URL
- ✅ Log response status and body
- ✅ Log parsed JSON
- ✅ Handle 404, 401, 500 errors
- ✅ Log stack traces on exceptions

---

## Debug Checklist

- [ ] Enhanced logging shows parkiran fetch attempt
- [ ] API returns 200 with parkiran data
- [ ] `id_parkiran` is extracted and stored
- [ ] Booking confirmation uses `id_parkiran`
- [ ] No error "Data parkiran tidak tersedia"
- [ ] Booking is created successfully

---

## Related Documentation

- `BOOKING_PARKIRAN_ID_FIX_SUMMARY.md` - Complete fix summary
- `BOOKING_PARKIRAN_DEBUG_GUIDE.md` - Detailed debugging guide
- `test-parkiran-fetch-debug.bat` - API test script
- `BOOKING_API_ENDPOINT_FIX.md` - Previous endpoint fixes
- `BOOKING_422_ERROR_COMPLETE_FIX.md` - Complete fix details
- `PARKIRAN_ONE_PER_MALL_LIMIT.md` - Business logic

---

**Last Updated**: 2026-01-12

**Status**: ✅ Enhanced logging applied, ready for testing

**Next Action**: Run the app and report log output
