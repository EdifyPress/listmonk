# Row-Level Security (RLS) Scripts

This directory contains SQL scripts for managing PostgreSQL Row-Level Security in ListMonk.

## Files

### Policy Management

- **`create-policies.sql`**: Defines RLS policies for all tables
  - Creates `get_current_rls_marker()` helper function
  - Defines SELECT, INSERT, UPDATE, DELETE policies
  - **Run BEFORE enabling RLS**

- **`enable-rls.sql`**: Activates RLS enforcement on tables
  - Must be run AFTER policies are created
  - After this, session variables are REQUIRED

- **`disable-rls.sql`**: Deactivates RLS enforcement
  - Use for troubleshooting or reverting to single-tenant

### Testing & Migration

- **`test-rls.sql`**: Comprehensive RLS verification
  - Creates test data with different markers
  - Verifies isolation between tenants
  - Checks for data leakage

- **`migrate-data.sql`**: Helper for assigning markers to existing data
  - Template with multiple examples
  - Customize based on your business logic

## Usage Order

For new installations:

```bash
# 1. Run ListMonk migration (adds columns)
./listmonk --upgrade

# 2. Create policies
psql -U listmonk -d listmonk_db -f create-policies.sql

# 3. Enable RLS
psql -U listmonk -d listmonk_db -f enable-rls.sql

# 4. Test
psql -U listmonk -d listmonk_db -f test-rls.sql
```

For existing installations:

```bash
# 1. Run migration
./listmonk --upgrade

# 2. Assign markers to existing data
# Edit migrate-data.sql first!
psql -U listmonk -d listmonk_db -f migrate-data.sql

# 3. Create policies
psql -U listmonk -d listmonk_db -f create-policies.sql

# 4. Enable RLS
psql -U listmonk -d listmonk_db -f enable-rls.sql

# 5. Test
psql -U listmonk -d listmonk_db -f test-rls.sql
```

## Troubleshooting

If things go wrong:

```bash
# Disable RLS to restore access
psql -U listmonk -d listmonk_db -f disable-rls.sql

# Check what went wrong
psql -U listmonk -d listmonk_db

# In psql:
SELECT * FROM pg_policies WHERE schemaname = 'public';
SHOW app.current_marker;
```

## See Also

- [../docs/rls-setup.md](../docs/rls-setup.md) - Complete setup guide
- [PostgreSQL RLS Docs](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
