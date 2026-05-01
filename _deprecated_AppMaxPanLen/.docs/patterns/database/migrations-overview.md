# Manual SQL Migrations - Overview

**Pattern Type:** Database Schema Evolution  
**Complexity:** Medium  
**Read Time:** 2-3 minutes  
**Best For:** Production systems requiring explicit schema control, audit trails, no ORM dependency

---

## When to Use Manual Migrations

### ✅ Use Manual SQL Migrations for:
- **Production databases** - Full control over schema changes
- **Team collaboration** - Easy to review SQL in PRs
- **Complex DDL** - Partitioning, triggers, stored procedures
- **Database-specific features** - PostgreSQL schemas, JSONB indexes, array types
- **Audit requirements** - Clear history of schema changes
- **No ORM overhead** - Don't need Alembic/Django migrations

### ❌ Don't Use Manual Migrations for:
- **ORM-heavy projects** - If using SQLAlchemy models heavily, Alembic easier
- **Rapid prototyping** - Manual migrations slow down schema experimentation
- **Simple SQLite apps** - Just use `Base.metadata.create_all()` for MVPs
- **Generated migrations needed** - When you want auto-generated from models

### Manual SQL vs Alembic

| Factor | Manual SQL | Alembic |
|--------|------------|---------|
| Control | Full control | Generated code |
| Review | Easy (plain SQL) | Requires ORM knowledge |
| Complexity | Handles anything | May need manual edits |
| Learning curve | SQL knowledge | ORM + migration tool |
| Portability | Database-specific | Abstracted |

**Rule of thumb**: Use manual migrations for production systems with complex schemas.

---

## Essential Pattern

### Migration File Structure

```
migrations/
├── _TEMPLATE_next_migration.sql    # Template to copy
├── 0001_auth_bootstrap.sql         # Initial schema
├── 0002_add_user_phone.sql
├── 0003_credentials_table.sql
└── 0004_add_indexes.sql
```

**Naming**: `<SEQ>_<description>.sql` (4-digit sequence, snake_case description)

### Minimal Migration Template

```sql
-- File: migrations/0002_add_user_phone.sql
-- Add phone column to users table
BEGIN;

-- 1) Your DDL changes
ALTER TABLE auth.users ADD COLUMN IF NOT EXISTS phone text;
CREATE INDEX IF NOT EXISTS idx_users_phone ON auth.users(phone) WHERE phone IS NOT NULL;

-- 2) Record migration
INSERT INTO auth.migration_history(schema_name, file_seq, name, checksum, notes)
VALUES ('auth', 2, '0002_add_user_phone.sql', md5('0002_add_user_phone.sql'), 'Add phone column to users')
ON CONFLICT (schema_name, file_seq) DO NOTHING;

COMMIT;
```

**Key principles**:
- **BEGIN/COMMIT**: Atomic transactions
- **IF NOT EXISTS**: Idempotent (safe to re-run)
- **ON CONFLICT DO NOTHING**: Track migrations without duplicates

---

## Idempotent Patterns

### Safe DDL (Can Run Multiple Times)

```sql
-- ✅ Idempotent patterns
CREATE SCHEMA IF NOT EXISTS auth;
CREATE TABLE IF NOT EXISTS auth.users (...);
ALTER TABLE auth.users ADD COLUMN IF NOT EXISTS phone text;
CREATE INDEX IF NOT EXISTS idx_users_email ON auth.users(email);

-- ✅ Idempotent migration tracking
INSERT INTO auth.migration_history (...) ON CONFLICT (schema_name, file_seq) DO NOTHING;
```

### Unsafe DDL (Avoid)

```sql
-- ❌ NOT idempotent - fails on second run
CREATE TABLE auth.users (...);  -- Error: relation already exists
ALTER TABLE auth.users ADD COLUMN phone text;  -- Error: column already exists
INSERT INTO auth.migration_history (...);  -- Error: unique violation
```

**Golden rule**: Every SQL statement must be safe to run multiple times.

---

## Common Migration Patterns

### Add Nullable Column

```sql
-- Simple: just add column
ALTER TABLE auth.users ADD COLUMN IF NOT EXISTS phone text;
```

### Add NOT NULL Column (Requires Backfill)

```sql
-- Step 1: Add nullable column
ALTER TABLE auth.users ADD COLUMN IF NOT EXISTS is_active boolean;

-- Step 2: Backfill existing rows
UPDATE auth.users SET is_active = true WHERE is_active IS NULL;

-- Step 3: Make NOT NULL
ALTER TABLE auth.users ALTER COLUMN is_active SET DEFAULT true;
ALTER TABLE auth.users ALTER COLUMN is_active SET NOT NULL;
```

### Create Table with Foreign Keys

```sql
CREATE TABLE IF NOT EXISTS auth.credentials (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    created_by uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name text NOT NULL,
    provider text NOT NULL CHECK (provider IN ('ms365', 'googlews')),
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (created_by, name)
);

-- Don't forget indexes on foreign keys!
CREATE INDEX IF NOT EXISTS idx_credentials_user ON auth.credentials(created_by);
```

### Add Index

```sql
-- Regular index
CREATE INDEX IF NOT EXISTS idx_users_email ON auth.users(email);

-- Partial index (saves space)
CREATE INDEX IF NOT EXISTS idx_users_active ON auth.users(email) WHERE is_active = true;

-- Composite index
CREATE INDEX IF NOT EXISTS idx_completions_habit_date ON completions(habit_id, completed_at);
```

---

## Migration Tracking Table

```sql
-- Create tracking table (in bootstrap migration)
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

**Why track migrations?**
- Know which migrations applied
- Detect gaps in sequence
- Audit trail for compliance
- Prevent duplicate application

---

## Running Migrations

### Docker Exec (Development)

```bash
# Run single migration
docker exec -it auth psql -h postgres -U app_root -d app_db \
  -f /auth/migrations/0002_add_user_phone.sql

# Check migration history
docker exec -it auth psql -h postgres -U app_root -d app_db \
  -c "SELECT * FROM auth.migration_history ORDER BY file_seq DESC LIMIT 5;"
```

### Python Script (Automated)

```python
# scripts/run_migrations.py
import os
import glob
import psycopg

def run_migrations(schema: str, migrations_dir: str):
    dsn = os.environ['DATABASE_URL']
    
    with psycopg.connect(dsn) as conn:
        # Get applied migrations
        with conn.cursor() as cur:
            cur.execute("""
                SELECT file_seq FROM auth.migration_history
                WHERE schema_name = %s
            """, (schema,))
            applied = {row[0] for row in cur.fetchall()}
        
        # Run pending migrations
        files = sorted(glob.glob(f"{migrations_dir}/*.sql"))
        for filepath in files:
            if "_TEMPLATE_" in filepath:
                continue
            
            filename = os.path.basename(filepath)
            seq = int(filename[:4])
            
            if seq in applied:
                print(f"⏭️  Skip {filename}")
                continue
            
            print(f"▶️  Run {filename}")
            with open(filepath) as f:
                conn.execute(f.read())
            conn.commit()
            print(f"✅ Applied {filename}")

if __name__ == "__main__":
    run_migrations("auth", "./auth/migrations")
```

---

## Top 5 Gotchas

### 1. Forgetting IF NOT EXISTS
**Problem**: Migration fails on second run

**Solution**: Always use `IF NOT EXISTS` / `IF EXISTS`

### 2. Adding NOT NULL Without Backfill
**Problem**: `ERROR: column contains null values`

**Solution**: Add nullable → backfill → set NOT NULL

### 3. Missing Index on Foreign Keys
**Problem**: Slow CASCADE deletes, slow joins

**Solution**: Always index foreign key columns

### 4. Not Using Transactions
**Problem**: Partial migration applied on error

**Solution**: Wrap in BEGIN/COMMIT

### 5. Modifying Applied Migrations
**Problem**: Inconsistent schema across environments

**Solution**: Never edit applied migrations, create new migration

---

## Quick Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `relation already exists` | Missing `IF NOT EXISTS` | Add `IF NOT EXISTS` |
| `column contains null values` | Adding NOT NULL without backfill | Backfill first, then set NOT NULL |
| `unique violation` on migration_history | Migration ran twice | Use `ON CONFLICT DO NOTHING` |
| `foreign key constraint failed` | Referenced record deleted | Check CASCADE settings |
| Migration applied but not in history | Forgot to INSERT into migration_history | Always record migrations |

---

## 📎 Complete Reference

For comprehensive implementation details:

**📎 Reference**: [migrations-reference.md](migrations-reference.md)  
**When to load**: Writing complex migrations, rollback strategies, data backfills  
**Key content**:
- Complete migration template with all patterns
- Bootstrap migration examples
- Rollback strategies (forward-only vs two-file)
- Data migration patterns (backfill, data transformation)
- Health check migration (read-only verification)
- Conditional DDL with PL/pgSQL
- Complete Python runner script
- Migration best practices and troubleshooting

---

**Pattern Version:** 1.0.0  
**Last Updated:** 2026-03-07  
**Extracted From:** Enterprise application v0.2.11 (Auth & API migrations)
