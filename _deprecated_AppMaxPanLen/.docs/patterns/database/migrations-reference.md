# Manual SQL Migrations Pattern

**Pattern Type:** Database Schema Evolution  
**Complexity:** Medium  
**Best For:** Production systems requiring precise schema control, audit trails, rollback capability

---

## Overview

Manual SQL migrations provide explicit, version-controlled database schema changes without ORM magic. Each migration is a standalone `.sql` file with idempotent DDL statements.

### Manual vs ORM-Generated Migrations

| Aspect | Manual SQL | Alembic/Django ORM |
|--------|------------|-------------------|
| Control | Full control over SQL | Generated, may need manual edits |
| Review | Easy to read & review | Requires understanding ORM |
| Complexity | Handles complex DDL | May struggle with advanced features |
| Portability | Database-specific | Abstracted (but limited) |
| Audit trail | Clear, explicit SQL | Generated code |
| Learning curve | SQL knowledge required | ORM knowledge required |

**Use manual migrations when:**
- Production systems requiring precise control
- Complex schema changes (partitioning, triggers, functions)
- Team has strong SQL skills
- Database-specific features needed (PostgreSQL schemas, JSONB indexes)
- Need explicit, reviewable migration files

---

## Migration File Structure

### Naming Convention

```
migrations/
├── _TEMPLATE_next_migration.sql    # Template for new migrations
├── 0001_auth_bootstrap.sql          # Bootstrap schema
├── 0002_add_user_phone.sql
├── 0003_credentials_table.sql
├── 0004_oauth_state_table.sql
└── 9999_health_check.sql            # Sentinel migration
```

**Pattern:** `<SEQ>_<description>.sql`
- **SEQ**: 4-digit sequence number (0001, 0002, etc.)
- **description**: Snake_case description
- **9999**: Reserved for health checks, test queries

---

## Migration Template

### Template File

**`migrations/_TEMPLATE_next_migration.sql`** - Copy this for new migrations

```sql
-- Template for next manual migration
-- Copy this file, rename to 000X_short_description.sql, and fill placeholders.
-- Wrap DDL in a transaction; keep idempotent with IF NOT EXISTS / ON CONFLICT.

BEGIN;

-- 1) Your DDL changes go here -------------------------------------------------
-- Examples:
-- (a) Add a nullable column:
ALTER TABLE auth.users ADD COLUMN IF NOT EXISTS phone text;

-- (b) Add a NOT NULL column with backfill:
ALTER TABLE auth.users ADD COLUMN IF NOT EXISTS is_verified boolean;
UPDATE auth.users SET is_verified = false WHERE is_verified IS NULL;
ALTER TABLE auth.users ALTER COLUMN is_verified SET NOT NULL;
ALTER TABLE auth.users ALTER COLUMN is_verified SET DEFAULT false;

-- (c) Create a new table:
CREATE TABLE IF NOT EXISTS auth.sessions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    token_hash bytea NOT NULL,
    expires_at timestamptz NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- (d) Add index:
CREATE INDEX IF NOT EXISTS idx_sessions_user ON auth.sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_expires ON auth.sessions(expires_at);

-- (e) Add constraint:
ALTER TABLE auth.users ADD CONSTRAINT email_lowercase CHECK (email = LOWER(email));

-- 2) Record this migration in migration_history -------------------------------
-- Replace <SEQ>, <FILENAME>
INSERT INTO auth.migration_history(schema_name, file_seq, name, checksum, notes)
VALUES ('auth', <SEQ>, '<FILENAME>', md5('<FILENAME>'), 'Describe change here')
ON CONFLICT (schema_name, file_seq) DO NOTHING;

-- Recommended: verification (optional) ---------------------------------------
-- SELECT schema_name, file_seq, name, applied_at 
-- FROM auth.migration_history 
-- ORDER BY file_seq DESC LIMIT 5;

COMMIT;
```

**Key principles:**
- **BEGIN/COMMIT**: Wrap in transaction
- **Idempotent**: Safe to run multiple times (`IF NOT EXISTS`, `ON CONFLICT DO NOTHING`)
- **Record migration**: Track applied migrations
- **Verification**: Optional SELECT to confirm success

---

## Migration Tracking Table

### Schema

```sql
-- Create migration tracking table (part of bootstrap)
CREATE TABLE IF NOT EXISTS auth.migration_history (
    id serial PRIMARY KEY,
    schema_name text NOT NULL,
    file_seq integer NOT NULL,
    name text NOT NULL,
    checksum text NOT NULL,
    notes text,
    applied_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (schema_name, file_seq)
);

CREATE INDEX IF NOT EXISTS idx_migration_history_schema 
ON auth.migration_history(schema_name, file_seq DESC);
```

**Columns:**
- **schema_name**: `auth`, `api` (for multi-service apps)
- **file_seq**: Migration sequence number (1, 2, 3...)
- **name**: Filename (e.g., `0001_auth_bootstrap.sql`)
- **checksum**: `md5(filename)` for integrity
- **notes**: Human-readable description
- **applied_at**: Timestamp

---

## Example Migrations

### Bootstrap Migration

**`migrations/0001_auth_bootstrap.sql`** - Initial schema

```sql
-- Manual bootstrap for Auth schema
-- Creates core auth tables: users, credentials, oauth_state
-- Idempotent: uses IF NOT EXISTS and ON CONFLICT where applicable

BEGIN;

-- 1) Ensure schema exists
CREATE SCHEMA IF NOT EXISTS auth;

-- 2) Grant privileges to application user
GRANT USAGE ON SCHEMA auth TO app_root;
GRANT CREATE ON SCHEMA auth TO app_root;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA auth TO app_root;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA auth TO app_root;

-- Set default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA auth 
GRANT ALL PRIVILEGES ON TABLES TO app_root;

ALTER DEFAULT PRIVILEGES IN SCHEMA auth 
GRANT ALL PRIVILEGES ON SEQUENCES TO app_root;

-- 3) Core tables
CREATE TABLE IF NOT EXISTS auth.users (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    email text UNIQUE NOT NULL,
    phone text,
    role text NOT NULL DEFAULT 'user' CHECK (role IN ('user','admin','super-user')),
    is_active boolean NOT NULL DEFAULT true,
    verified_at timestamptz,
    last_login_at timestamptz,
    created_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT email_lowercase CHECK (email = LOWER(email))
);

CREATE INDEX IF NOT EXISTS idx_users_email ON auth.users(email);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON auth.users(created_at DESC);

-- 4) Migration tracking table
CREATE TABLE IF NOT EXISTS auth.migration_history (
    id serial PRIMARY KEY,
    schema_name text NOT NULL,
    file_seq integer NOT NULL,
    name text NOT NULL,
    checksum text NOT NULL,
    notes text,
    applied_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (schema_name, file_seq)
);

-- 5) Record this migration
INSERT INTO auth.migration_history(schema_name, file_seq, name, checksum, notes)
VALUES ('auth', 1, '0001_auth_bootstrap.sql', md5('0001_auth_bootstrap.sql'), 'Create auth schema, users table, migration tracking')
ON CONFLICT (schema_name, file_seq) DO NOTHING;

COMMIT;
```

---

### Add Column Migration

**`migrations/0002_add_user_phone.sql`** - Add nullable column

```sql
BEGIN;

-- Add phone column (nullable)
ALTER TABLE auth.users ADD COLUMN IF NOT EXISTS phone text;

-- Optional: Add index
CREATE INDEX IF NOT EXISTS idx_users_phone ON auth.users(phone) WHERE phone IS NOT NULL;

-- Record migration
INSERT INTO auth.migration_history(schema_name, file_seq, name, checksum, notes)
VALUES ('auth', 2, '0002_add_user_phone.sql', md5('0002_add_user_phone.sql'), 'Add phone column to users table')
ON CONFLICT (schema_name, file_seq) DO NOTHING;

COMMIT;
```

---

### Add NOT NULL Column with Backfill

**`migrations/0003_add_is_active.sql`** - Add NOT NULL column

```sql
BEGIN;

-- Step 1: Add nullable column
ALTER TABLE auth.users ADD COLUMN IF NOT EXISTS is_active boolean;

-- Step 2: Backfill existing rows
UPDATE auth.users SET is_active = true WHERE is_active IS NULL;

-- Step 3: Make NOT NULL with default
ALTER TABLE auth.users ALTER COLUMN is_active SET DEFAULT true;
ALTER TABLE auth.users ALTER COLUMN is_active SET NOT NULL;

-- Record migration
INSERT INTO auth.migration_history(schema_name, file_seq, name, checksum, notes)
VALUES ('auth', 3, '0003_add_is_active.sql', md5('0003_add_is_active.sql'), 'Add is_active column with backfill')
ON CONFLICT (schema_name, file_seq) DO NOTHING;

COMMIT;
```

**Important:** Always backfill before setting NOT NULL to avoid errors on existing rows.

---

### Create New Table

**`migrations/0004_credentials_table.sql`** - New table with foreign keys

```sql
BEGIN;

-- Credentials table
CREATE TABLE IF NOT EXISTS auth.credentials (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    created_by uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name text NOT NULL,
    display_name text,
    provider text NOT NULL CHECK (provider IN ('ms365', 'googlews', 'github')),
    client_id text,
    encrypted_client_secret bytea,
    scopes text[],  -- PostgreSQL array
    redirect_uri text,
    authorization_url text,
    token_url text,
    tenant_id text,
    status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'connected', 'error', 'disconnected')),
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (created_by, name)  -- Unique per user
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_credentials_user ON auth.credentials(created_by);
CREATE INDEX IF NOT EXISTS idx_credentials_provider ON auth.credentials(provider);
CREATE INDEX IF NOT EXISTS idx_credentials_status ON auth.credentials(status) WHERE status = 'connected';

-- Record migration
INSERT INTO auth.migration_history(schema_name, file_seq, name, checksum, notes)
VALUES ('auth', 4, '0004_credentials_table.sql', md5('0004_credentials_table.sql'), 'Create credentials table')
ON CONFLICT (schema_name, file_seq) DO NOTHING;

COMMIT;
```

---

## Running Migrations

### Manual Execution

```bash
# Run migration file directly
docker exec -it auth psql -h postgres -U app_root -d app_db -f /auth/migrations/0001_auth_bootstrap.sql

# Or with PostgreSQL client
psql -h localhost -U app_root -d app_db -f migrations/0001_auth_bootstrap.sql

# Run all pending migrations
for file in migrations/*.sql; do
    if [[ "$file" != *"_TEMPLATE_"* && "$file" != *"9999_"* ]]; then
        echo "Running $file..."
        psql -h localhost -U app_root -d app_db -f "$file"
    fi
done
```

### Python Script

**`scripts/run_migrations.py`** - Automated migration runner

```python
import os
import glob
import psycopg

def get_applied_migrations(conn, schema: str) -> set:
    """Get list of applied migrations."""
    with conn.cursor() as cur:
        cur.execute("""
            SELECT file_seq FROM auth.migration_history
            WHERE schema_name = %s
        """, (schema,))
        return {row[0] for row in cur.fetchall()}


def run_migrations(schema: str, migrations_dir: str):
    """Run pending migrations."""
    dsn = os.environ['DATABASE_URL']
    
    with psycopg.connect(dsn) as conn:
        applied = get_applied_migrations(conn, schema)
        
        # Get migration files (sorted)
        files = sorted(glob.glob(f"{migrations_dir}/*.sql"))
        files = [f for f in files if "_TEMPLATE_" not in f and "9999_" not in f]
        
        for filepath in files:
            filename = os.path.basename(filepath)
            seq = int(filename[:4])  # Extract sequence number
            
            if seq in applied:
                print(f"⏭️  Skipping {filename} (already applied)")
                continue
            
            print(f"▶️  Running {filename}...")
            with open(filepath) as f:
                sql = f.read()
            
            try:
                conn.execute(sql)
                conn.commit()
                print(f"✅ Applied {filename}")
            except Exception as e:
                conn.rollback()
                print(f"❌ Failed {filename}: {e}")
                raise


if __name__ == "__main__":
    run_migrations("auth", "./auth/migrations")
```

```bash
# Usage
python scripts/run_migrations.py
```

---

## Idempotent Patterns

### Safe DDL Statements

```sql
-- ✅ Idempotent: Safe to run multiple times
CREATE SCHEMA IF NOT EXISTS auth;
CREATE TABLE IF NOT EXISTS auth.users (...);
CREATE INDEX IF NOT EXISTS idx_users_email ON auth.users(email);
ALTER TABLE auth.users ADD COLUMN IF NOT EXISTS phone text;

-- ✅ Idempotent: Track migrations
INSERT INTO auth.migration_history (...) 
ON CONFLICT (schema_name, file_seq) DO NOTHING;

-- ✅ Idempotent: Conditional column NOT NULL
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'auth' AND table_name = 'users' 
        AND column_name = 'is_active' AND is_nullable = 'YES'
    ) THEN
        ALTER TABLE auth.users ALTER COLUMN is_active SET NOT NULL;
    END IF;
END $$;
```

### Non-Idempotent (Avoid)

```sql
-- ❌ NOT idempotent: Fails on second run
CREATE TABLE auth.users (...);  -- Error: relation already exists
ALTER TABLE auth.users ADD COLUMN phone text;  -- Error: column already exists

-- ❌ NOT idempotent: Duplicate inserts
INSERT INTO auth.migration_history (...);  -- Error: unique violation
```

**Rule:** Always use `IF NOT EXISTS`, `IF EXISTS`, or `ON CONFLICT` for idempotence.

---

## Migration Best Practices

### ✅ Do

1. **Wrap in BEGIN/COMMIT** - Atomic migrations (all or nothing)
2. **Use IF NOT EXISTS** - Idempotent DDL
3. **Backfill before NOT NULL** - Prevent errors on existing data
4. **Index foreign keys** - Critical for CASCADE operations
5. **Track migrations** - Record in `migration_history`
6. **Test locally first** - Run on dev database before production
7. **Sequential numbering** - 0001, 0002, 0003 (gaps OK)
8. **Descriptive names** - `add_user_phone`, not `migration_2`

### ❌ Don't

1. **Don't skip transactions** - Risk partial application
2. **Don't forget idempotence** - Must be safe to re-run
3. **Don't add NOT NULL directly** - Backfill first
4. **Don't delete old migrations** - Keep for audit trail
5. **Don't modify applied migrations** - Create new migration instead
6. **Don't run manually in production** - Use automated script
7. **Don't forget to commit** - Wrap in transaction
8. **Don't use DROP without care** - Data loss risk

---

## Rollback Strategy

### Forward-Only Migrations (Recommended)

**Philosophy:** Migrations move forward only. To undo, create a new migration.

```sql
-- Migration 0005: Add column
ALTER TABLE auth.users ADD COLUMN IF NOT EXISTS preferences jsonb;

-- Migration 0006: Remove column (rollback 0005)
ALTER TABLE auth.users DROP COLUMN IF EXISTS preferences;
```

**Pros:**
- Clear audit trail
- No rollback complexity
- Easier to reason about

**Cons:**
- Can't undo quickly in emergency

---

### Two-File Rollback (Alternative)

```
migrations/
├── 0005_add_preferences_up.sql      # Apply migration
└── 0005_add_preferences_down.sql    # Rollback migration
```

**Up:**
```sql
BEGIN;
ALTER TABLE auth.users ADD COLUMN IF NOT EXISTS preferences jsonb;
INSERT INTO auth.migration_history (...) VALUES (5, ...);
COMMIT;
```

**Down:**
```sql
BEGIN;
ALTER TABLE auth.users DROP COLUMN IF EXISTS preferences;
DELETE FROM auth.migration_history WHERE schema_name = 'auth' AND file_seq = 5;
COMMIT;
```

---

## Health Check Migration

**`migrations/9999_health_check.sql`** - Sentinel migration for testing

```sql
-- Health check migration - always safe to run
-- Used to verify database connectivity and migration system

BEGIN;

-- Query migration history
SELECT schema_name, file_seq, name, applied_at
FROM auth.migration_history
ORDER BY file_seq DESC
LIMIT 5;

-- No INSERT - this is read-only
ROLLBACK;  -- Rollback because we don't want to record this
```

```bash
# Test database connection
psql -h postgres -U app_root -d app_db -f migrations/9999_health_check.sql
```

---

## Troubleshooting

### Issue: Migration fails midway

**Symptom:** Partial schema changes applied

**Solution:**
```sql
-- Always wrap in transaction
BEGIN;
-- ... DDL statements
COMMIT;

-- If migration fails, entire transaction rolls back
```

### Issue: Column already exists error

**Symptom:** `ERROR: column "phone" of relation "users" already exists`

**Solution:**
```sql
-- Use IF NOT EXISTS
ALTER TABLE auth.users ADD COLUMN IF NOT EXISTS phone text;
```

### Issue: Can't add NOT NULL column

**Symptom:** `ERROR: column "is_active" contains null values`

**Solution:**
```sql
-- Add nullable, backfill, then set NOT NULL
ALTER TABLE auth.users ADD COLUMN IF NOT EXISTS is_active boolean;
UPDATE auth.users SET is_active = true WHERE is_active IS NULL;
ALTER TABLE auth.users ALTER COLUMN is_active SET NOT NULL;
```

---

## References

### Source Code
- **Enterprise Auth Service Migrations**: `<enterprise-app>/auth/migrations/`
  - `_TEMPLATE_next_migration.sql`: Migration template
  - `0001_auth_bootstrap.sql`: Bootstrap migration
  - Migration history tracking pattern
  
- **Enterprise API Service Migrations**: `<enterprise-app>/api/migrations/`
  - Schema-specific migrations
  - Webhook subscriptions, events tables

### Related Patterns
- 📎 [PostgreSQL Patterns](./postgresql-patterns.md) - Database connection and queries
- 📎 [Database Service Pattern](./service-pattern.md) - Centralized DB operations
- 📎 [SQLite Setup](./sqlite-setup.md) - SQLite doesn't need migrations (use ORM)

### External Resources
- [PostgreSQL DDL Documentation](https://www.postgresql.org/docs/current/ddl.html)
- [PostgreSQL Transactions](https://www.postgresql.org/docs/current/tutorial-transactions.html)
- [Idempotent DDL Best Practices](https://wiki.postgresql.org/wiki/Don't_Do_This)

---

**Pattern Version:** 1.0.0  
**Last Updated:** 2026-01-28  
**Extracted From:** Enterprise application v0.2.11 (Auth & API services)
