# 5. Database Schema

Our backend utilizes **Supabase** (PostgreSQL) for structured data and real-time sockets.

## Tables

### `users`
Managed by Supabase Auth (`auth.users`).

### `profiles`
Extended profile information for both citizens and admins.
- `id` (uuid)
- `full_name` (text)
- `role` (text) - `'civilian'` or `'admin'`
- `zone` (text)

### `reports`
The core civic incidents reported by users.
- `id` (uuid)
- `user_id` (uuid, Foreign Key)
- `title` (text)
- `description` (text)
- `category` (text)
- `status` (text) - `'pending'`, `'in_progress'`, `'resolved'`
- `lat` (float8)
- `lng` (float8)

## Security

We employ **Row Level Security (RLS)** to protect data:
- **Profiles:** Anyone can read profiles. Users can only update their own profile.
- **Reports:** Anyone can read public reports. Citizens can only create reports. Admins can update report statuses.

We use a database Trigger (`handle_new_user`) that automatically provisions a `profile` row whenever a new user signs up via Supabase Auth.

---

[⬅️ Previous: Offline Mesh Network](04_mesh_network.md) | [Return to Home 🏠](../README.md)
