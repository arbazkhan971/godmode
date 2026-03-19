# Supabase Developer Guide

How to use Godmode's full skill set to build, optimize, and secure applications with Supabase as the backend platform.

---

## Setup

```bash
/godmode:setup
# Godmode auto-detects Supabase via supabase/ directory, .env with SUPABASE_URL, or supabase/config.toml
```

### Example `.godmode/config.yaml`
```yaml
platform: supabase
project_ref: your-project-ref
region: us-east-1
framework: nextjs                # or remix, sveltekit, nuxt, flutter
test_command: npm test
verify_command: curl -s https://your-project.supabase.co/rest/v1/ -H "apikey: $SUPABASE_ANON_KEY"
local_dev: true                  # use supabase CLI for local development
```

---

## Supabase as Backend with Godmode

### Skill-to-Feature Mapping

| Supabase Feature | Godmode Skills | How They Work Together |
|-----------------|---------------|----------------------|
| **Database (PostgreSQL)** | `query`, `migrate`, `infra`, `optimize` | `/godmode:query` optimizes SQL queries, designs indexes, and detects N+1 patterns in PostgREST usage. `/godmode:migrate` generates and manages Supabase migrations. `/godmode:infra` provisions database extensions and configures connection pooling. |
| **Auth** | `auth`, `secure`, `build` | `/godmode:auth` configures authentication providers (email, OAuth, SAML). `/godmode:secure` audits auth policies and token handling. `/godmode:build` implements auth flows with Supabase client SDKs. |
| **Storage** | `infra`, `secure`, `optimize` | `/godmode:infra` creates storage buckets with policies. `/godmode:secure` audits bucket access policies and signed URL expiration. `/godmode:optimize` configures image transformations and CDN caching. |
| **Realtime** | `build`, `optimize`, `observe` | `/godmode:build` implements Realtime subscriptions with proper channel management. `/godmode:optimize` minimizes broadcast payloads and subscription overhead. `/godmode:observe` monitors Realtime connection counts and message throughput. |
| **Edge Functions** | `build`, `deploy`, `test` | `/godmode:build` creates Deno-based edge functions with proper error handling and typing. `/godmode:deploy` manages function deployment and versioning. `/godmode:test` writes unit and integration tests for edge functions. |

---

## Auth

### Authentication Setup

```bash
/godmode:auth "Configure authentication for SaaS application with Supabase"

# Godmode produces:
# - Email/password signup with confirmation
# - OAuth providers (Google, GitHub, etc.)
# - Magic link authentication
# - Phone/SMS authentication
# - Multi-factor authentication (TOTP)
# - Custom claims via auth hooks
```

### Auth Patterns

```bash
/godmode:build "Implement auth flows with Supabase"

# Godmode produces:
# - lib/supabase/server.ts        — Server-side Supabase client (SSR-safe)
# - lib/supabase/client.ts        — Browser-side Supabase client
# - lib/supabase/middleware.ts     — Session refresh middleware
# - app/auth/login/page.tsx        — Login form with email + OAuth
# - app/auth/signup/page.tsx       — Signup with email confirmation
# - app/auth/callback/route.ts     — OAuth callback handler
# - app/auth/reset/page.tsx        — Password reset flow
```

### Session Management

```bash
/godmode:secure "Audit Supabase session management"

# Godmode checks:
# - Server-side session validation (not just client-side)
# - Token refresh middleware for SSR frameworks
# - Secure cookie configuration (httpOnly, sameSite, secure)
# - Session timeout and idle timeout policies
# - Auth helper usage (createServerClient vs. createBrowserClient)
# - PKCE flow for OAuth (default in Supabase Auth v2)
```

---

## Storage

### Storage Configuration

```bash
/godmode:infra "Configure Supabase Storage for user uploads"

# Godmode produces:
# - Storage bucket with access policies:
#     supabase/migrations/create_storage_buckets.sql
#
# - Upload policies:
#     -- Users can upload to their own folder
#     CREATE POLICY "user_upload" ON storage.objects
#       FOR INSERT TO authenticated
#       WITH CHECK (bucket_id = 'uploads' AND (storage.foldername(name))[1] = auth.uid()::text);
#
#     -- Users can read their own files
#     CREATE POLICY "user_read" ON storage.objects
#       FOR SELECT TO authenticated
#       USING (bucket_id = 'uploads' AND (storage.foldername(name))[1] = auth.uid()::text);
#
# - Image transformation configuration
# - Signed URL generation for private files
# - Client-side upload with progress tracking
```

### Storage Patterns

| Pattern | Use Case | Godmode Implementation |
|---------|----------|----------------------|
| **User Avatars** | Profile images | Public bucket, 1MB limit, image transformation for thumbnails, RLS per user |
| **Document Upload** | Private files | Private bucket, signed URLs with 1-hour expiry, virus scanning via Edge Function |
| **Public Assets** | Marketing images | Public bucket, CDN caching, image transformations for responsive sizes |
| **Backup Export** | Data export | Private bucket, temporary signed URL, auto-delete after 24 hours |

---

## Realtime

### Realtime Subscriptions

```bash
/godmode:build "Implement real-time features with Supabase Realtime"

# Godmode produces:
# - Postgres Changes (CDC):
#     Listen to INSERT/UPDATE/DELETE on specific tables
#     Filter by columns to reduce payload size
#
# - Broadcast:
#     Ephemeral messages between clients (typing indicators, cursors)
#     No database persistence, low latency
#
# - Presence:
#     Track online users in channels
#     Sync shared state across clients
```

### Realtime Patterns

```bash
/godmode:build "Real-time chat with typing indicators and presence"

# Godmode produces:
# - hooks/useRealtimeMessages.ts   — Subscribe to new messages (Postgres Changes)
# - hooks/useTypingIndicator.ts    — Broadcast typing state (Broadcast)
# - hooks/usePresence.ts           — Track online users (Presence)
# - lib/supabase/realtime.ts       — Channel management and cleanup
#
# Channel lifecycle:
#   1. Subscribe on component mount
#   2. Track presence on join
#   3. Unsubscribe and untrack on unmount
#   4. Handle reconnection gracefully
```

### Realtime Optimization

```bash
/godmode:optimize "Optimize Supabase Realtime performance"

# Godmode checks:
# - Subscribe only to needed columns (not SELECT *)
# - Use filters to reduce event volume
# - Proper channel cleanup to avoid connection leaks
# - Connection pooling strategy for high-concurrency
# - Debounce rapid state changes (typing indicators)
# - Batch UI updates for high-frequency events
```

---

## Edge Functions

### Edge Function Development

```bash
/godmode:build "Create Supabase Edge Functions for business logic"

# Godmode produces:
# - supabase/functions/process-payment/index.ts
# - supabase/functions/send-email/index.ts
# - supabase/functions/generate-pdf/index.ts
# - supabase/functions/webhook-handler/index.ts
# - supabase/functions/_shared/cors.ts            — CORS headers
# - supabase/functions/_shared/supabase-client.ts  — Admin client
# - supabase/functions/_shared/validation.ts       — Input validation
```

### Edge Function Patterns

| Pattern | Use Case | Godmode Implementation |
|---------|----------|----------------------|
| **Webhook Handler** | Stripe, GitHub, etc. | Signature verification, idempotency check, database update, response |
| **Scheduled Task** | Cron jobs | pg_cron triggers edge function, processes batch operations |
| **API Proxy** | Third-party APIs | Hide API keys, transform responses, add caching |
| **File Processing** | Image/PDF generation | Accept upload, process with Deno libraries, store in Supabase Storage |
| **Email Sending** | Transactional email | Validate payload, render template, send via Resend/SendGrid |

### Edge Function Testing

```bash
/godmode:test "Test Supabase Edge Functions"

# Godmode produces:
# - supabase/functions/process-payment/index.test.ts
# - Test setup with Supabase local instance
# - Mock external APIs (Stripe, email providers)
# - Test auth context injection
# - Integration tests against local Supabase
```

---

## PostgreSQL Optimization with `/godmode:query`

### Query Analysis

```bash
/godmode:query "Analyze and optimize Supabase database queries"

# Godmode checks:
# - EXPLAIN ANALYZE for slow queries
# - Missing indexes on filtered and joined columns
# - N+1 query patterns in PostgREST usage
# - Inefficient RPC functions
# - Connection pool utilization (PgBouncer)
# - Table bloat and vacuum statistics
```

### Index Strategy

```bash
/godmode:query "Design index strategy for Supabase tables"

# Godmode produces:
# - B-tree indexes for equality and range queries
# - GIN indexes for JSONB columns and full-text search
# - Partial indexes for filtered queries (WHERE status = 'active')
# - Composite indexes matching common query patterns
# - Covering indexes to enable index-only scans
#
# Example migration:
# supabase/migrations/20240101000000_optimize_indexes.sql
#
# -- Composite index for common listing query
# CREATE INDEX CONCURRENTLY idx_orders_user_status
#   ON orders (user_id, status)
#   WHERE deleted_at IS NULL;
#
# -- GIN index for JSONB metadata queries
# CREATE INDEX CONCURRENTLY idx_products_metadata
#   ON products USING gin (metadata jsonb_path_ops);
#
# -- Full-text search index
# CREATE INDEX CONCURRENTLY idx_posts_fts
#   ON posts USING gin (to_tsvector('english', title || ' ' || content));
```

### Database Functions (RPC)

```bash
/godmode:build "Create optimized Supabase RPC functions"

# Godmode produces:
# - Complex queries as Postgres functions (avoid multiple PostgREST calls)
# - Security definer vs. security invoker based on use case
# - Proper parameter validation inside functions
# - SET search_path for security
# - RETURNS TABLE for complex result sets
#
# Example:
# CREATE OR REPLACE FUNCTION get_user_dashboard(p_user_id uuid)
# RETURNS TABLE (
#   total_orders bigint,
#   total_spent numeric,
#   recent_orders jsonb,
#   pending_count bigint
# )
# LANGUAGE plpgsql
# SECURITY DEFINER
# SET search_path = public
# AS $$
# BEGIN
#   RETURN QUERY
#   SELECT
#     count(*),
#     coalesce(sum(total), 0),
#     jsonb_agg(row_to_json(o.*) ORDER BY o.created_at DESC) FILTER (WHERE rn <= 5),
#     count(*) FILTER (WHERE status = 'pending')
#   FROM (
#     SELECT *, row_number() OVER (ORDER BY created_at DESC) as rn
#     FROM orders
#     WHERE user_id = p_user_id
#   ) o;
# END;
# $$;
```

### Migration Management

```bash
/godmode:migrate "Create and manage Supabase database migrations"

# Godmode workflow:
# 1. Generate migration: supabase migration new <name>
# 2. Write SQL in supabase/migrations/<timestamp>_<name>.sql
# 3. Test locally: supabase db reset
# 4. Diff check: supabase db diff
# 5. Deploy: supabase db push (staging) → supabase db push (production)
#
# Godmode enforces:
# - Backward-compatible changes (no dropping columns in use)
# - CREATE INDEX CONCURRENTLY for production indexes
# - Transaction-safe migration steps
# - Seed data separation from schema changes
# - Rollback scripts for critical migrations
```

---

## Row-Level Security Design

### RLS Fundamentals

```bash
/godmode:secure "Design row-level security policies for multi-tenant SaaS"

# Godmode produces comprehensive RLS policies:
#
# -- Enable RLS on all tables
# ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
# ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
# ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
```

### RLS Policy Patterns

#### Tenant Isolation

```sql
-- Users can only see their organization's data
CREATE POLICY "tenant_isolation" ON projects
  FOR ALL TO authenticated
  USING (
    organization_id IN (
      SELECT organization_id FROM organization_members
      WHERE user_id = auth.uid()
    )
  );
```

#### Role-Based Access

```sql
-- Only admins can delete projects
CREATE POLICY "admin_delete" ON projects
  FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM organization_members
      WHERE user_id = auth.uid()
        AND organization_id = projects.organization_id
        AND role = 'admin'
    )
  );

-- Members can read, admins can write
CREATE POLICY "member_read" ON projects
  FOR SELECT TO authenticated
  USING (
    organization_id IN (
      SELECT organization_id FROM organization_members
      WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "admin_write" ON projects
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM organization_members
      WHERE user_id = auth.uid()
        AND organization_id = projects.organization_id
        AND role IN ('admin', 'editor')
    )
  );
```

#### Hierarchical Access

```sql
-- Users can see tasks in projects they have access to
CREATE POLICY "task_access" ON tasks
  FOR SELECT TO authenticated
  USING (
    project_id IN (
      SELECT p.id FROM projects p
      JOIN organization_members om ON om.organization_id = p.organization_id
      WHERE om.user_id = auth.uid()
    )
  );
```

### RLS Performance Optimization

```bash
/godmode:optimize "Optimize RLS policy performance"

# Godmode checks:
# - Security barrier overhead on complex policies
# - Index support for policy WHERE clauses
# - Materialized helper views for membership lookups
# - auth.uid() call caching within transaction
# - Policy evaluation order optimization
# - EXPLAIN ANALYZE with RLS enabled vs. disabled
#
# Performance pattern — use a security definer function:
#
# CREATE OR REPLACE FUNCTION get_user_org_ids()
# RETURNS setof uuid
# LANGUAGE sql
# SECURITY DEFINER
# SET search_path = public
# STABLE
# AS $$
#   SELECT organization_id
#   FROM organization_members
#   WHERE user_id = auth.uid();
# $$;
#
# -- Fast policy using the helper function
# CREATE POLICY "tenant_isolation" ON projects
#   FOR ALL TO authenticated
#   USING (organization_id IN (SELECT get_user_org_ids()));
```

### RLS Audit

```bash
/godmode:secure "Audit RLS policies for security gaps"

# Godmode checks:
# - Tables with RLS disabled (security risk)
# - Missing policies for specific operations (INSERT, UPDATE, DELETE)
# - Policies that reference auth.uid() correctly
# - Service role bypass usage (should be server-side only)
# - Anon role access (public data only)
# - Policy conflicts and overlaps
# - Force row-level security for table owners
# - Test RLS with different user contexts
```

---

## Local Development

```bash
/godmode:setup "Configure Supabase local development"

# Godmode produces:
# - supabase/config.toml with local settings
# - supabase/seed.sql with development data
# - Docker-based local Supabase (supabase start)
# - Local auth with test users
# - Local storage buckets
# - Local Edge Functions with hot reload
# - Environment variable management (.env.local)
```

### Development Workflow

```
┌──────────┐   ┌────────────┐   ┌──────────┐   ┌─────────┐   ┌──────────┐
│  Write   │──▶│  Test      │──▶│  Migrate │──▶│ Deploy  │──▶│ Verify   │
│Migration │   │  Locally   │   │ to       │   │ Edge    │   │Production│
│  + RLS   │   │  (reset)   │   │ Staging  │   │Functions│   │          │
└──────────┘   └────────────┘   └──────────┘   └─────────┘   └──────────┘
```

---

## Common Architectures

### SaaS Application

```bash
/godmode:think "Design multi-tenant SaaS with Supabase"
/godmode:plan
/godmode:build

# Godmode produces:
# - Supabase Auth with organization-based multi-tenancy
# - RLS policies for tenant isolation
# - Stripe integration via Edge Functions
# - Real-time collaboration features
# - File storage with per-tenant buckets
# - Database functions for complex business logic
# - Row-level audit logging
```

### Real-Time Collaboration

```bash
/godmode:think "Design collaborative document editor with Supabase"
/godmode:plan
/godmode:build

# Godmode produces:
# - Realtime Broadcast for cursor positions and selections
# - Realtime Presence for online user tracking
# - Postgres Changes for document sync
# - Conflict resolution strategy (CRDT or OT)
# - Storage for document attachments
# - RLS for document-level access control
```

### Mobile Backend

```bash
/godmode:think "Design mobile backend with Supabase"
/godmode:plan
/godmode:build

# Godmode produces:
# - Supabase Auth with social OAuth + phone auth
# - Offline-first sync strategy
# - Push notifications via Edge Functions
# - Image optimization and storage
# - RLS for user data isolation
# - Edge Functions for business logic
```

---

## Observability

```bash
/godmode:observe "Monitor Supabase project health"

# Godmode monitors:
# - Database connection pool utilization
# - Query performance (pg_stat_statements)
# - Auth request success/failure rates
# - Storage bandwidth and request counts
# - Realtime connection counts and message throughput
# - Edge Function invocation counts and error rates
# - Database size and growth rate
```

---

## Quick Reference

| Task | Command |
|------|---------|
| Database optimization | `/godmode:query "Optimize Supabase queries"` |
| Migration management | `/godmode:migrate "Supabase migration for <change>"` |
| RLS policy design | `/godmode:secure "RLS policies for <table>"` |
| Auth configuration | `/godmode:auth "Supabase Auth for <provider>"` |
| Edge Functions | `/godmode:build "Edge Function for <task>"` |
| Realtime features | `/godmode:build "Realtime <feature>"` |
| Storage setup | `/godmode:infra "Supabase Storage for <use case>"` |
| Security audit | `/godmode:secure "Supabase security review"` |
| Local development | `/godmode:setup "Supabase local dev"` |
| Performance tuning | `/godmode:optimize "Supabase performance"` |
