# RENCANA AUDITING SISTEM QPARKIN

## 1. TUJUAN AUDITING

### 1.1 Tujuan Umum
Melakukan evaluasi menyeluruh terhadap keamanan sistem Qparkin untuk:
- Mengidentifikasi kerentanan keamanan pada aplikasi mobile dan backend
- Memastikan integritas data transaksi dan keuangan
- Memvalidasi implementasi kontrol akses dan autentikasi
- Mendeteksi potensi unauthorized access dan data leakage
- Memberikan rekomendasi perbaikan keamanan

### 1.2 Tujuan Spesifik

**A. Keamanan Autentikasi**
- Validasi kekuatan mekanisme PIN 6 digit
- Evaluasi penyimpanan token dan kredensial
- Pengujian session management dan token expiration
- Analisis implementasi "Remember Me" feature

**B. Keamanan API**
- Identifikasi endpoint yang tidak terproteksi
- Validasi authorization pada setiap endpoint
- Pengujian rate limiting dan abuse prevention
- Analisis input validation dan sanitization

**C. Integritas Data**
- Verifikasi konsistensi data transaksi
- Validasi perhitungan biaya dan poin
- Pengujian trigger dan constraint database
- Analisis audit trail untuk perubahan data kritis

**D. Keamanan Komunikasi**
- Validasi implementasi HTTPS/TLS
- Pengujian SSL certificate pinning
- Analisis enkripsi data in-transit
- Evaluasi keamanan API_URL configuration

---

## 2. RUANG LINGKUP AUDITING

### 2.1 Komponen yang Diaudit

#### A. Aplikasi Mobile (Flutter)

**Services Layer:**
- `auth_service.dart` - Autentikasi dan manajemen token
- `booking_service.dart` - Operasi booking dan slot reservation
- `parking_service.dart` - Manajemen parkir aktif
- `profile_service.dart` - Manajemen profil dan kendaraan
- `vehicle_service.dart` - Operasi kendaraan
- `qr_service.dart` - Generasi dan validasi QR code

**Security Utilities:**
- `security_utils.dart` - Enkripsi dan hashing
- `validators.dart` - Validasi input (PIN, email, dll)

**Data Models:**
- `user_model.dart` - Model data pengguna
- `booking_model.dart` - Model data booking
- `active_parking_model.dart` - Model parkir aktif
- `vehicle_model.dart` - Model kendaraan

**Storage:**
- Flutter Secure Storage implementation
- Token dan credential management

#### B. Backend API (Laravel)
**Endpoint Autentikasi:**
- POST `/api/auth/login`
- POST `/api/auth/register`
- POST `/api/auth/logout` (jika ada)
- POST `/api/auth/refresh` (jika ada)

**Endpoint Booking:**
- POST `/api/booking/create`
- GET `/api/booking/check-availability`
- GET `/api/booking/check-active`

**Endpoint Parking:**
- GET `/api/parking/active`
- GET `/api/parking/floors/{mallId}`
- GET `/api/parking/slots/{floorId}/visualization`
- POST `/api/parking/slots/reserve-random`

**Endpoint Profile:**
- GET `/api/profile/user`
- PUT `/api/profile/user`
- GET `/api/profile/vehicles`
- POST `/api/profile/vehicles` (jika ada)
- DELETE `/api/profile/vehicles/{id}` (jika ada)

#### C. Database (MySQL)
**Tabel Kritis:**
- `user`, `customer`, `admin_mall`, `super_admin`
- `transaksi_parkir`, `pembayaran`, `riwayat_poin`
- `booking`, `parkiran`, `tarif_parkir`
- `kendaraan`, `mall`, `gerbang`

**Database Objects:**
- Triggers untuk otomatisasi
- Stored procedures (jika ada)
- Views untuk reporting
- Indexes untuk performa

### 2.2 Aspek yang Tidak Termasuk Audit
- Infrastruktur server dan network (di luar scope aplikasi)
- Perangkat keras IoT/gerbang parkir (belum diimplementasikan)
- Payment gateway eksternal (simulasi saja)
- Third-party services (Google Sign-In, Maps)

---

## 3. METODE DAN PENDEKATAN AUDITING

### 3.1 Code Review (Static Analysis)

**Tujuan:** Identifikasi kerentanan keamanan melalui analisis kode sumber

**Fokus Area:**
1. **Hardcoded Credentials**
   - Pencarian string password, API key, secret
   - Validasi environment variable usage
   - Analisis default values yang tidak aman

2. **Input Validation**
   - Validasi semua input user di client dan server
   - Sanitization untuk SQL injection prevention
   - XSS prevention pada output

3. **Error Handling**
   - Analisis error messages yang terlalu verbose
   - Validasi exception handling yang proper
   - Logging sensitive data

4. **Authentication & Authorization**
   - Validasi token generation dan validation
   - Analisis session management
   - Role-based access control implementation

**Tools:**
- Manual code review
- Flutter Analyzer
- Dart Code Metrics
- SonarQube (jika tersedia)

### 3.2 Dynamic Testing (Penetration Testing)

**Tujuan:** Identifikasi kerentanan melalui pengujian runtime

**Test Cases:**

**A. Authentication Testing**

1. Brute force attack pada PIN login
2. Session hijacking dan token theft
3. Token expiration testing
4. Concurrent login testing
5. Password reset vulnerability

**B. Authorization Testing**
1. Horizontal privilege escalation (akses data user lain)
2. Vertical privilege escalation (customer → admin)
3. Direct object reference (IDOR)
4. Missing function level access control

**C. API Security Testing**
1. Rate limiting bypass
2. Mass assignment vulnerability
3. API abuse (excessive requests)
4. Parameter tampering
5. Response manipulation

**D. Data Integrity Testing**
1. Manipulasi biaya parkir
2. Manipulasi saldo poin
3. Booking conflict scenarios
4. Race condition pada slot reservation
5. Transaction rollback testing

**Tools:**
- Postman/Insomnia untuk API testing
- Burp Suite untuk intercepting requests
- OWASP ZAP untuk automated scanning
- Custom scripts untuk specific scenarios

### 3.3 Database Auditing

**Tujuan:** Memastikan integritas dan keamanan data

**Audit Procedures:**

**A. Access Control Audit**
1. Review database user privileges
2. Validasi least privilege principle
3. Audit stored procedures permissions
4. Review trigger execution rights

**B. Data Integrity Audit**
1. Validasi foreign key constraints
2. Pengujian trigger functionality
3. Analisis data consistency
4. Orphaned records detection

**C. Audit Trail Review**
1. Analisis log perubahan data kritis
2. Review unauthorized access attempts
3. Validasi timestamp accuracy
4. Anomaly detection

**D. Encryption Audit**
1. Validasi password hashing (bcrypt/Argon2)
2. Review encryption at rest
3. Validasi sensitive data masking
4. Key management review

**Tools:**
- MySQL Workbench
- Database audit logs
- Custom SQL queries untuk anomaly detection

### 3.4 Security Configuration Review

**Tujuan:** Validasi konfigurasi keamanan sistem

**Checklist:**

**A. Mobile App Configuration**
- [ ] API_URL tidak hardcoded
- [ ] SSL certificate pinning implemented
- [ ] Debug mode disabled di production
- [ ] Obfuscation enabled
- [ ] Secure storage properly configured
- [ ] Biometric authentication (jika ada)

**B. Backend Configuration**
- [ ] HTTPS enforced
- [ ] CORS properly configured
- [ ] Rate limiting enabled
- [ ] Input validation middleware
- [ ] Error handling tidak expose stack trace
- [ ] Logging tidak mencatat sensitive data
- [ ] Database credentials tidak di version control

**C. Database Configuration**
- [ ] Strong password policy
- [ ] Remote access restricted
- [ ] Backup encryption enabled
- [ ] Audit logging enabled
- [ ] SSL/TLS for connections

---

## 4. JADWAL DAN TIMELINE AUDITING

### Phase 1: Preparation (Week 1)
- Setup audit environment
- Collect documentation (SKPPL, API docs)
- Prepare audit tools
- Define test scenarios

### Phase 2: Static Analysis (Week 2)
- Code review (mobile app)
- Code review (backend API)
- Configuration review
- Documentation review

### Phase 3: Dynamic Testing (Week 3-4)
- Authentication testing
- Authorization testing
- API security testing
- Data integrity testing

### Phase 4: Database Audit (Week 5)
- Access control audit
- Data integrity validation
- Audit trail review
- Encryption validation

### Phase 5: Reporting (Week 6)
- Compile findings
- Risk assessment
- Recommendations
- Final report presentation

---

## 5. DELIVERABLES

### 5.1 Audit Report
**Struktur:**
1. Executive Summary
2. Audit Scope and Methodology
3. Findings and Vulnerabilities
   - Critical (CVSS 9.0-10.0)
   - High (CVSS 7.0-8.9)
   - Medium (CVSS 4.0-6.9)
   - Low (CVSS 0.1-3.9)
4. Risk Assessment
5. Recommendations
6. Remediation Plan
7. Appendices (test cases, logs, screenshots)

### 5.2 Technical Documentation
- Vulnerability details dengan PoC
- Code snippets yang bermasalah
- Recommended fixes
- Security best practices guide

### 5.3 Compliance Checklist
- OWASP Mobile Top 10 compliance
- OWASP API Security Top 10 compliance
- Data protection compliance (GDPR-like)

---

## 6. KRITERIA SUKSES AUDIT

### 6.1 Quantitative Metrics
- Zero critical vulnerabilities
- < 3 high severity vulnerabilities
- < 10 medium severity vulnerabilities
- 100% endpoint authorization coverage
- 100% input validation coverage

### 6.2 Qualitative Metrics
- Proper error handling implementation
- Comprehensive audit logging
- Secure configuration across all components
- Documentation completeness
- Team security awareness

---

## 7. RISK ASSESSMENT FRAMEWORK

### 7.1 Risk Scoring
**Impact Levels:**
- **Critical (5):** Data breach, financial loss, system compromise
- **High (4):** Unauthorized access, data manipulation
- **Medium (3):** Information disclosure, service disruption
- **Low (2):** Minor information leakage
- **Minimal (1):** Cosmetic issues

**Likelihood Levels:**
- **Very High (5):** Easily exploitable, no authentication required
- **High (4):** Exploitable with basic skills
- **Medium (3):** Requires specific conditions
- **Low (2):** Difficult to exploit
- **Very Low (1):** Theoretical vulnerability

**Risk Score = Impact × Likelihood**

### 7.2 Prioritization Matrix
| Risk Score | Priority | Action Required |
|------------|----------|-----------------|
| 20-25 | Critical | Immediate fix required |
| 15-19 | High | Fix within 1 week |
| 10-14 | Medium | Fix within 1 month |
| 5-9 | Low | Fix in next release |
| 1-4 | Minimal | Document and monitor |

---

## 8. STAKEHOLDER COMMUNICATION

### 8.1 Reporting Frequency
- **Daily:** Critical findings (immediate notification)
- **Weekly:** Progress updates
- **Bi-weekly:** Interim findings report
- **Final:** Comprehensive audit report

### 8.2 Communication Channels
- Email untuk formal reports
- Slack/Teams untuk daily updates
- Meeting untuk critical findings discussion
- Documentation portal untuk knowledge sharing

---

## APPENDIX A: AUDIT CHECKLIST

### Authentication & Session Management
- [ ] Password/PIN strength requirements
- [ ] Account lockout mechanism
- [ ] Session timeout implementation
- [ ] Token expiration and refresh
- [ ] Secure token storage
- [ ] Multi-factor authentication (if applicable)

### Authorization
- [ ] Role-based access control
- [ ] Function-level authorization
- [ ] Direct object reference protection
- [ ] Privilege escalation prevention

### Data Protection
- [ ] Encryption at rest
- [ ] Encryption in transit (TLS 1.2+)
- [ ] Sensitive data masking
- [ ] Secure data deletion

### API Security
- [ ] Input validation
- [ ] Output encoding
- [ ] Rate limiting
- [ ] CORS configuration
- [ ] API versioning
- [ ] Error handling

### Database Security
- [ ] Parameterized queries
- [ ] Least privilege access
- [ ] Audit logging
- [ ] Backup encryption
- [ ] Connection encryption

### Logging & Monitoring
- [ ] Security event logging
- [ ] Audit trail completeness
- [ ] Log protection
- [ ] Anomaly detection
- [ ] Incident response plan

---

**Document Version:** 1.0  
**Last Updated:** 14 Desember 2025  
**Next Review:** Setelah completion audit
