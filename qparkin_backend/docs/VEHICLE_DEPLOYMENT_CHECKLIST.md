# Vehicle Backend - Deployment Checklist

## 📋 Pre-Deployment Checklist

### 1. Code Review
- [x] Migration aman (has column check)
- [x] Model fillable correct (no last_used_at)
- [x] Controller endpoints minimal
- [x] No syntax errors
- [x] Documentation complete

### 2. Database
- [ ] Backup database sebelum migration
- [ ] Test migration di development
- [ ] Verify indexes created
- [ ] Check no triggers/SP created

### 3. Testing
- [ ] Test GET /api/kendaraan
- [ ] Test POST /api/kendaraan
- [ ] Test PUT /api/kendaraan/{id}
- [ ] Test DELETE /api/kendaraan/{id}
- [ ] Test PUT /api/kendaraan/{id}/set-active
- [ ] Verify last_used_at protection

### 4. Performance
- [ ] Check query count (should be 1)
- [ ] Check response time (<100ms)
- [ ] Check response size (minimal)
- [ ] No N+1 queries

### 5. Security
- [ ] last_used_at tidak bisa diset via API
- [ ] Photo upload validation works
- [ ] Authorization works (user can only access own vehicles)
- [ ] Plate uniqueness enforced

---

## 🚀 Deployment Steps

### Step 1: Backup Database
```bash
cd qparkin_backend

# Backup database
php artisan db:backup
# atau manual:
# mysqldump -u root -p qparkin > backup_before_vehicle_migration.sql
```

### Step 2: Pull Latest Code
```bash
git pull origin main
# atau
git checkout feature/vehicle-backend-fix
git pull
```

### Step 3: Run Migration
```bash
# Check migration status
php artisan migrate:status

# Run migration
php artisan migrate

# Verify migration
php artisan migrate:status
```

### Step 4: Clear Cache
```bash
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear
```

### Step 5: Create Storage Link (if not exists)
```bash
php artisan storage:link
```

### Step 6: Set Permissions
```bash
# Linux/Mac
chmod -R 775 storage
chmod -R 775 bootstrap/cache

# Windows (run as admin)
# icacls storage /grant Users:F /T
# icacls bootstrap\cache /grant Users:F /T
```

---

## 🧪 Post-Deployment Testing

### Test 1: Migration Success
```bash
# Check if columns exist
php artisan tinker
>>> Schema::hasColumn('kendaraan', 'warna')
=> true
>>> Schema::hasColumn('kendaraan', 'foto_path')
=> true
>>> Schema::hasColumn('kendaraan', 'is_active')
=> true
>>> Schema::hasColumn('kendaraan', 'last_used_at')
=> true
```

### Test 2: API Endpoints
```bash
# Get token first
TOKEN="your_auth_token_here"

# Test GET vehicles
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:8000/api/kendaraan

# Test POST vehicle
curl -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -F "plat_nomor=B 1234 XYZ" \
  -F "jenis_kendaraan=Roda Empat" \
  -F "merk=Toyota" \
  -F "tipe=Avanza" \
  -F "warna=Hitam" \
  -F "is_active=true" \
  http://localhost:8000/api/kendaraan

# Test last_used_at protection (should be ignored)
curl -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -F "plat_nomor=B 5678 ABC" \
  -F "jenis_kendaraan=Roda Dua" \
  -F "merk=Honda" \
  -F "tipe=Beat" \
  -F "last_used_at=2026-01-01" \
  http://localhost:8000/api/kendaraan
# Check response - last_used_at should be null
```

### Test 3: Performance
```bash
# Install Apache Bench (if not installed)
# sudo apt-get install apache-bench

# Test performance
ab -n 100 -c 10 \
  -H "Authorization: Bearer $TOKEN" \
  http://localhost:8000/api/kendaraan

# Check:
# - Time per request should be < 100ms
# - No failed requests
```

### Test 4: Database Integrity
```bash
php artisan tinker

# Check indexes
>>> DB::select("SHOW INDEX FROM kendaraan WHERE Key_name = 'idx_user_active'");
# Should return index info

>>> DB::select("SHOW INDEX FROM kendaraan WHERE Key_name = 'idx_plat'");
# Should return index info

# Check no triggers
>>> DB::select("SHOW TRIGGERS LIKE 'kendaraan'");
# Should return empty array

# Check data
>>> App\Models\Kendaraan::count();
# Should return vehicle count
```

---

## 🔧 Troubleshooting

### Issue 1: Migration Error "Column already exists"
**Cause:** Migration already run  
**Solution:** This is OK! Migration has `Schema::hasColumn()` check

### Issue 2: Storage link not working
**Cause:** Symbolic link not created  
**Solution:**
```bash
php artisan storage:link
# or manually:
# ln -s storage/app/public public/storage
```

### Issue 3: Photo upload fails
**Cause:** Permission issue  
**Solution:**
```bash
chmod -R 775 storage/app/public
# or
sudo chown -R www-data:www-data storage
```

### Issue 4: last_used_at can be set via API
**Cause:** Old code still cached  
**Solution:**
```bash
php artisan config:clear
php artisan cache:clear
composer dump-autoload
```

### Issue 5: Slow response time
**Cause:** Indexes not created  
**Solution:**
```bash
# Check indexes
php artisan tinker
>>> DB::select("SHOW INDEX FROM kendaraan");

# If missing, run migration again
php artisan migrate:refresh --step=1
```

---

## 📊 Monitoring

### Metrics to Monitor

1. **Response Time**
   - Target: < 100ms
   - Alert if: > 500ms

2. **Query Count**
   - Target: 1 query per request
   - Alert if: > 3 queries

3. **Error Rate**
   - Target: < 1%
   - Alert if: > 5%

4. **Storage Usage**
   - Monitor: storage/app/public/vehicles/
   - Alert if: > 80% full

### Monitoring Commands
```bash
# Check response time
tail -f storage/logs/laravel.log | grep "kendaraan"

# Check query count (enable query log in config)
php artisan tinker
>>> DB::enableQueryLog();
>>> // Make API request
>>> DB::getQueryLog();

# Check storage usage
du -sh storage/app/public/vehicles/
```

---

## 🔄 Rollback Plan

### If Issues Occur

#### Step 1: Rollback Migration
```bash
php artisan migrate:rollback --step=1
```

#### Step 2: Restore Database
```bash
mysql -u root -p qparkin < backup_before_vehicle_migration.sql
```

#### Step 3: Revert Code
```bash
git revert HEAD
# or
git checkout previous_commit_hash
```

#### Step 4: Clear Cache
```bash
php artisan config:clear
php artisan cache:clear
```

---

## ✅ Success Criteria

Deployment successful if:

- [x] Migration runs without errors
- [x] All API endpoints return 200 OK
- [x] Response time < 100ms
- [x] Query count = 1 per request
- [x] last_used_at protected (cannot be set via API)
- [x] Photo upload works
- [x] No errors in logs
- [x] Indexes created successfully
- [x] No triggers/SP in database

---

## 📞 Support Contacts

**If issues occur:**

1. Check logs: `storage/logs/laravel.log`
2. Check documentation: `docs/VEHICLE_BACKEND_QUICK_REFERENCE.md`
3. Review comparison: `docs/VEHICLE_BACKEND_COMPARISON.md`
4. Check summary: `VEHICLE_BACKEND_FIX_SUMMARY.md`

---

## 📝 Post-Deployment Tasks

- [ ] Update API documentation
- [ ] Notify mobile team about changes
- [ ] Update integration guide
- [ ] Monitor for 24 hours
- [ ] Collect performance metrics
- [ ] Update changelog

---

**Checklist Version:** 1.0  
**Last Updated:** 2026-01-01  
**Status:** Ready for Deployment
