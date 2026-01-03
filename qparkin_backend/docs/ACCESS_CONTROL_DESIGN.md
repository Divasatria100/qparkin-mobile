# QParkin Access Control Design

## Overview
Sistem access control untuk QParkin menggunakan Role-Based Access Control (RBAC) dengan 4 level utama: Super Admin, Mall Manager, Security/Operator, dan Regular User.

## Role Hierarchy

```
Super Admin (Level 1)
├── Mall Manager (Level 2)
│   ├── Security/Operator (Level 3)
│   └── Regular User (Level 4)
```

## Roles & Permissions

### 1. Super Admin
**Akses penuh ke seluruh sistem**
- ✅ Manajemen mall (CRUD)
- ✅ Approve/reject pengajuan mall baru
- ✅ Lihat laporan global semua mall
- ✅ Manajemen user dan role assignment
- ✅ System configuration
- ✅ Audit logs

**Routes:**
- `/superadmin/*` - Full access
- `/admin/*` - Read access untuk monitoring

### 2. Mall Manager (Admin)
**Mengelola operasional mall tertentu**
- ✅ Dashboard mall analytics
- ✅ Manajemen parkiran (CRUD)
- ✅ Manajemen tarif parkir
- ✅ Lihat dan kelola tiket parkir
- ✅ Notifikasi mall
- ✅ Profile management
- ❌ Tidak bisa akses mall lain
- ❌ Tidak bisa approve pengajuan

**Routes:**
- `/admin/*` - Scoped to assigned mall only

### 3. Security/Operator
**Operasional harian parkir**
- ✅ Lihat dashboard (read-only)
- ✅ Scan QR dan validasi tiket
- ✅ Lihat status parkiran real-time
- ✅ Input manual entry/exit
- ✅ Basic notifications
- ❌ Tidak bisa ubah tarif
- ❌ Tidak bisa kelola parkiran

**Routes:**
- `/operator/*` - Limited operational access

### 4. Regular User
**Pengguna mobile app**
- ✅ Login/register via mobile
- ✅ Booking slot parkir
- ✅ Generate QR tiket
- ✅ Payment processing
- ✅ History parkir
- ❌ Tidak ada akses web admin

**Routes:**
- API endpoints only (`/api/user/*`)

## Permission Matrix

| Feature | Super Admin | Mall Manager | Security | User |
|---------|-------------|--------------|----------|------|
| Mall Management | CRUD | Read (own) | Read (own) | - |
| Parkiran Management | CRUD | CRUD (own) | Read (own) | - |
| Tarif Management | CRUD | CRUD (own) | Read (own) | - |
| Tiket Management | CRUD | CRUD (own) | Read/Update (own) | CRUD (own) |
| User Management | CRUD | Read (own mall) | - | Read (self) |
| Reports | Global | Own mall | Own mall | Own history |
| Notifications | System | Mall | Operational | Personal |

## Database Schema

### roles table
```sql
id | name | level | description
1  | superadmin | 1 | Super Administrator
2  | admin | 2 | Mall Manager
3  | operator | 3 | Security/Operator
4  | user | 4 | Regular User
```

### permissions table
```sql
id | name | resource | action
1  | mall.create | mall | create
2  | mall.read | mall | read
3  | mall.update | mall | update
4  | mall.delete | mall | delete
5  | parkiran.create | parkiran | create
...
```

### role_permissions table
```sql
role_id | permission_id
1       | 1,2,3,4,5,6,7,8...  (all)
2       | 2,5,6,7,9,10,11...  (mall scoped)
3       | 2,6,10,14...        (read mostly)
4       | 18,19,20...         (user scoped)
```

### user_roles table
```sql
user_id | role_id | mall_id | assigned_at
1       | 1       | null    | 2024-01-01
2       | 2       | 1       | 2024-01-01
3       | 3       | 1       | 2024-01-01
```

## Implementation Strategy

### Phase 1: Core RBAC
1. Create migration files
2. Implement Role & Permission models
3. Create middleware for role checking
4. Update existing routes with role middleware

### Phase 2: Mall Scoping
1. Add mall_id to user assignments
2. Implement mall-scoped queries
3. Update controllers with scope filtering
4. Add mall selection for multi-mall users

### Phase 3: Fine-grained Permissions
1. Implement permission-based checks
2. Create policy classes
3. Add UI permission indicators
4. Implement audit logging

### Phase 4: Advanced Features
1. Role inheritance
2. Temporary role assignments
3. Permission delegation
4. Advanced audit trails

## Security Considerations

### Authentication
- JWT tokens for API (mobile)
- Session-based for web admin
- 2FA for Super Admin accounts
- Password policies enforcement

### Authorization
- Role-based middleware on all routes
- Mall-scoped data access
- Permission checks in controllers
- CSRF protection on forms

### Data Protection
- Encrypt sensitive data
- Audit all admin actions
- Rate limiting on API endpoints
- Input validation & sanitization

## Testing Strategy

### Unit Tests
- Role assignment logic
- Permission checking methods
- Mall scoping queries
- Policy class methods

### Feature Tests
- Route access by role
- Data visibility by scope
- Permission enforcement
- Cross-mall data isolation

### Integration Tests
- End-to-end user flows
- Role switching scenarios
- Multi-mall user access
- API authentication flows

## Monitoring & Auditing

### Audit Logs
- User login/logout
- Role changes
- Permission grants/revokes
- Data modifications
- Failed access attempts

### Metrics
- Role distribution
- Permission usage
- Access patterns
- Security incidents

### Alerts
- Suspicious access patterns
- Failed authentication attempts
- Privilege escalation attempts
- Data export activities