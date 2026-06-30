# BrgyPulse Database Setup

## Prerequisites
- A [Supabase](https://supabase.com) project (free tier works)

## Setup Steps

### 1. Create the schema
Go to your Supabase Dashboard → **SQL Editor** → paste and run:
```
database/schema.sql
```

### 2. Apply RLS policies
In the same SQL Editor, run:
```
database/policies.sql
```

### 3. Seed demo data (optional)
For hackathon demo, run:
```
database/seed.sql
```

> **Note:** Seed data inserts profiles directly (bypassing auth triggers).
> Use the **service role key** in the SQL editor for this to work with RLS.

### 4. Create storage bucket
In Supabase Dashboard → **Storage** → Create a new bucket:
- Name: `report-photos`
- Public: Yes

### 5. Configure your Flutter apps
Copy `.env.example` to `.env` in both `brgy_pulse/` and `brgy_pulse_admin/`:

```bash
cp brgy_pulse/.env.example brgy_pulse/.env
cp brgy_pulse_admin/.env.example brgy_pulse_admin/.env
```

Fill in your Supabase project URL and anon key from:
**Supabase Dashboard → Settings → API**

### 6. Run the apps
```bash
cd brgy_pulse && flutter run -d chrome
cd brgy_pulse_admin && flutter run -d chrome
```

## Schema Overview

| Table | Records | Purpose |
|---|---|---|
| `profiles` | Auto-created on signup | User accounts |
| `officials` | Manual setup | Barangay staff with points |
| `reports` | Created by civilians | Community reports |
| `announcements` | Created by officials | Barangay news posts |
| `broadcasts` | Created by officials | Emergency alerts |
| `ratings` | Created by civilians | 1-5 star ratings of officials |

## Row Level Security
- **Read:** All tables are publicly readable
- **Write:** Authenticated users can create reports and ratings
- **Admin:** Officials can update any report (claim/resolve)
