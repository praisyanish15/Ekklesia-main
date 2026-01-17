# Supabase Setup Instructions

## Update Existing Database Tables (IMPORTANT)

If you already have an existing database, you need to add new columns for themes and payment features. Run these ALTER TABLE commands in your Supabase SQL Editor:

```sql
-- Add theme column to churches table
ALTER TABLE public.churches
ADD COLUMN IF NOT EXISTS theme TEXT DEFAULT 'spiritual_blue',
ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION,
ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION,
ADD COLUMN IF NOT EXISTS payment_qr_code_url TEXT,
ADD COLUMN IF NOT EXISTS upi_id TEXT,
ADD COLUMN IF NOT EXISTS razorpay_key_id TEXT;

-- Add church_id to profiles table (if not exists)
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS church_id UUID;
```

## Disable Email Confirmation (IMPORTANT)

To allow users to sign in without email verification, follow these steps:

### Step 1: Open Supabase Dashboard
1. Go to https://supabase.com/dashboard
2. Select your Ekklesia project

### Step 2: Disable Email Confirmation
1. Click on **Authentication** in the left sidebar
2. Click on **Providers**
3. Find **Email** provider and click on it
4. Scroll down to find **Confirm email**
5. **Uncheck** the "Confirm email" checkbox
6. Click **Save**

### Alternative: Auto-confirm emails via SQL

If you prefer to keep email confirmation enabled but want to auto-confirm test users, run this SQL in the SQL Editor:

```sql
-- Auto-confirm all existing users
UPDATE auth.users
SET email_confirmed_at = NOW()
WHERE email_confirmed_at IS NULL;
```

### Step 3: Test Sign In
1. Try signing in with an existing account
2. If you still get "Email not confirmed" error, the user was created before disabling confirmation
3. Either:
   - Create a new account (will work immediately)
   - Run the SQL command above to confirm existing users

---

## SQL Syntax Error Fix

If you're getting a SQL syntax error, it's likely from the database setup. To fix:

### Option 1: Run SQL Incrementally
Instead of running the entire `database_setup.sql` file at once, run it in sections:

1. Open Supabase Dashboard → SQL Editor
2. Copy and paste each `CREATE TABLE` statement one at a time
3. Run each section separately

### Option 2: Check for Common Issues
Look for these common SQL errors:

1. **Trailing commas**:
   ```sql
   -- BAD
   CREATE TABLE example (
     id UUID,
     name TEXT,  -- ❌ comma before closing parenthesis
   );

   -- GOOD
   CREATE TABLE example (
     id UUID,
     name TEXT   -- ✅ no comma
   );
   ```

2. **Missing semicolons**: Each SQL statement should end with `;`

3. **Quote issues**: Use single quotes `'` for strings, not double quotes `"`

### Option 3: Find the Exact Error
The error message shows `LINE 11:` - this tells you which line has the issue.

1. Count down to line 11 in the SQL you're running
2. Look for syntax issues around that line
3. Common issues:
   - Extra or missing comma
   - Unclosed parenthesis
   - Missing data type
   - Reserved keyword used as column name

---

## Quick Fixes

### If users can't sign in:
```bash
# Go to Supabase Dashboard → Authentication → Providers → Email
# Uncheck "Confirm email" → Save
```

### If you get SQL errors:
```bash
# Run the database_setup.sql in smaller chunks
# Or use the Supabase Table Editor to create tables via UI
```

### Need to reset everything?
```sql
-- ⚠️ WARNING: This deletes all data!
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;

-- Then run database_setup.sql again
```

---

## Contact

If issues persist:
1. Check the Supabase logs: Dashboard → Logs
2. Check the browser console for errors
3. Verify your Supabase URL and anon key in your `.env` or config file

