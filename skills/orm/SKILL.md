---
name: orm
description: |
  ORM and data access optimization skill. Activates when a developer needs to select, configure, or optimize an ORM or data access layer. Covers ORM selection (Prisma, Drizzle, TypeORM, SQLAlchemy, GORM, ActiveRecord), query builder patterns, N+1 query detection and resolution, connection pooling configuration, and transaction management patterns. Triggers on: /godmode:orm, "which ORM", "N+1 query", "connection pool", "transaction", "query builder", "data access layer", or when database access code needs architectural guidance or performance optimization.
---

# ORM -- ORM & Data Access Optimization

## When to Activate
- User invokes `/godmode:orm`
- User says "which ORM should I use?", "Prisma vs Drizzle?", "ORM selection"
- User encounters N+1 query problems or slow database queries caused by the ORM
- User asks about connection pooling, pool sizing, or connection management
- User needs transaction management patterns (nested, distributed, saga)
- User asks about query builder patterns or raw SQL escape hatches
- User wants to audit ORM usage for performance issues
- User needs to configure an ORM for production readiness
- Godmode orchestrator detects ORM-related performance bottlenecks

## Workflow

### Step 1: Detect Data Access Environment

Identify the project's ORM, database, and current data access patterns:

```
DATA ACCESS ENVIRONMENT:
Language:        <TypeScript | Python | Go | Ruby | Java | C# | Rust | PHP>
ORM/DAL:        <Prisma | Drizzle | TypeORM | Sequelize | SQLAlchemy | Django ORM | GORM | ActiveRecord | Diesel | Eloquent | None>
Database:        <PostgreSQL | MySQL | SQLite | SQL Server | MongoDB | CockroachDB | PlanetScale>
Connection:      <direct | pooler (PgBouncer, ProxySQL) | serverless (Neon, PlanetScale) | edge>
Detection:       <how detected -- prisma/schema.prisma, drizzle.config.ts, models.py, etc.>
Schema location: <path to schema/model definitions>
Migration tool:  <built-in | separate (knex, alembic, goose)>
Query logging:   <enabled | disabled>
```

Scan the codebase for data access patterns:
```bash
# Detect ORM from config files
ls prisma/schema.prisma drizzle.config.ts ormconfig.ts typeorm.config.ts 2>/dev/null
ls alembic.ini config/database.yml sqlalchemy.cfg 2>/dev/null

# Count model/entity definitions
find src/ -name "*.entity.ts" -o -name "*.model.ts" -o -name "*.model.py" | wc -l

# Detect query patterns
grep -rn "findMany\|findUnique\|findFirst\|createMany" src/ --include="*.ts" -l   # Prisma
grep -rn "select()\|from()\|innerJoin\|leftJoin" src/ --include="*.ts" -l          # Drizzle/Knex
grep -rn "\.objects\.\|\.filter(\|\.exclude(" src/ --include="*.py" -l              # Django
grep -rn "\.query\.\|\.createQueryBuilder\|getRepository" src/ --include="*.ts" -l # TypeORM

# Detect N+1 patterns (queries inside loops)
grep -rn "for.*await.*find\|\.forEach.*await.*find\|\.map.*await.*find" src/ --include="*.ts" --include="*.tsx" -l

# Check connection configuration
grep -rn "pool\|connection_limit\|max_connections\|pool_size" src/ --include="*.ts" --include="*.py" --include="*.rb" --include="*.go" -l
```

### Step 2: ORM Selection Guide

#### 2a: ORM Comparison Matrix

```
ORM SELECTION MATRIX (TypeScript/JavaScript):
+-------------------+--------+--------+---------+----------+
| Criteria          | Prisma | Drizzle| TypeORM | Sequelize|
+-------------------+--------+--------+---------+----------+
| Type safety       | ★★★★★ | ★★★★★ | ★★★☆☆  | ★★☆☆☆   |
| SQL control       | ★★☆☆☆ | ★★★★★ | ★★★★☆  | ★★★☆☆   |
| Migration UX      | ★★★★★ | ★★★★☆ | ★★★☆☆  | ★★★☆☆   |
| Raw SQL escape    | ★★★☆☆ | ★★★★★ | ★★★★★  | ★★★★☆   |
| Relations         | ★★★★★ | ★★★★☆ | ★★★★★  | ★★★★☆   |
| Performance       | ★★★☆☆ | ★★★★★ | ★★★☆☆  | ★★★☆☆   |
| Bundle size       | Heavy  | Light  | Heavy   | Heavy    |
|                   | (engine)| (~30KB)| (~500KB)| (~300KB)|
| Edge/serverless   | ★★★★☆ | ★★★★★ | ★★☆☆☆  | ★★☆☆☆   |
| Learning curve    | Gentle | Medium | Steep   | Medium   |
| Ecosystem         | ★★★★★ | ★★★★☆ | ★★★★☆  | ★★★★☆   |
+-------------------+--------+--------+---------+----------+

RECOMMENDATION:
- Maximum type safety, great DX, schema-first      -> Prisma
- SQL-first, maximum performance, edge deployment   -> Drizzle
- Decorator-based, NestJS integration, legacy compat -> TypeORM
- Legacy project, Sequelize already in use          -> Sequelize (don't migrate without reason)
```

```
ORM SELECTION MATRIX (Python):
+-------------------+------------+-----------+-----------+
| Criteria          | SQLAlchemy | Django ORM| Tortoise  |
+-------------------+------------+-----------+-----------+
| Flexibility       | ★★★★★     | ★★★☆☆    | ★★★☆☆    |
| SQL control       | ★★★★★     | ★★★☆☆    | ★★★☆☆    |
| Async support     | ★★★★☆     | ★★★☆☆    | ★★★★★    |
| Migration         | ★★★★★     | ★★★★★    | ★★★☆☆    |
|                   | (Alembic)  | (built-in)|           |
| Performance       | ★★★★☆     | ★★★★☆    | ★★★★☆    |
| Learning curve    | Steep      | Gentle    | Medium    |
+-------------------+------------+-----------+-----------+

RECOMMENDATION:
- FastAPI / general Python                          -> SQLAlchemy 2.0
- Django project                                    -> Django ORM (always)
- Async-first Python (FastAPI, Sanic)               -> SQLAlchemy async or Tortoise
```

```
ORM SELECTION MATRIX (Other Languages):
+-------------------+-----------+----------------+----------+
| Language          | Primary   | Alternative    | Raw SQL  |
+-------------------+-----------+----------------+----------+
| Go                | GORM      | Ent, sqlc      | sqlx     |
| Ruby              | ActiveRecord | Sequel      | pg gem   |
| Java              | Hibernate | jOOQ, MyBatis  | JDBC     |
| C#                | EF Core   | Dapper         | ADO.NET  |
| Rust              | Diesel    | SeaORM, sqlx   | tokio-pg |
| PHP               | Eloquent  | Doctrine       | PDO      |
+-------------------+-----------+----------------+----------+
```

### Step 3: N+1 Query Detection and Resolution

#### 3a: Detect N+1 Patterns

```
N+1 DETECTION CHECKLIST:
[ ] Enable query logging in the ORM
[ ] Load a page that displays a list with related data
[ ] Count the number of SQL queries executed
[ ] If count = 1 (parent) + N (children), you have an N+1

QUERY LOG SETUP:
```

```typescript
// Prisma: enable query logging
const prisma = new PrismaClient({
  log: [
    { emit: 'event', level: 'query' },
  ],
});
prisma.$on('query', (e) => {
  console.log(`Query: ${e.query}`);
  console.log(`Duration: ${e.duration}ms`);
});

// Drizzle: enable logging
import { drizzle } from 'drizzle-orm/node-postgres';
const db = drizzle(pool, { logger: true });

// TypeORM: enable logging
const dataSource = new DataSource({
  // ...
  logging: ['query', 'slow_query'],
  maxQueryExecutionTime: 1000, // Log queries > 1s
});
```

```python
# Django: log all queries
import logging
logging.getLogger('django.db.backends').setLevel(logging.DEBUG)

# Django: count queries in a block
from django.test.utils import override_settings
from django.db import connection, reset_queries

reset_queries()
# ... your code ...
print(f"Queries executed: {len(connection.queries)}")

# SQLAlchemy: enable echo
engine = create_engine("postgresql://...", echo=True)
```

```ruby
# Rails: detect N+1 with Bullet gem
# Gemfile: gem 'bullet'
# config/environments/development.rb:
config.after_initialize do
  Bullet.enable = true
  Bullet.alert = true
  Bullet.console = true
  Bullet.rails_logger = true
end
```

#### 3b: Fix N+1 Patterns

```
N+1 RESOLUTION BY ORM:
```

```typescript
// ========== PRISMA ==========
// BAD: N+1 (1 query for posts + N queries for authors)
const posts = await prisma.post.findMany();
for (const post of posts) {
  const author = await prisma.user.findUnique({
    where: { id: post.authorId },
  });
}

// GOOD: Eager loading with include (1 query with JOIN)
const posts = await prisma.post.findMany({
  include: { author: true },
});

// GOOD: Select only needed fields
const posts = await prisma.post.findMany({
  select: {
    id: true,
    title: true,
    author: {
      select: { id: true, name: true },
    },
  },
});

// ========== DRIZZLE ==========
// BAD: N+1
const posts = await db.select().from(postsTable);
for (const post of posts) {
  const author = await db.select().from(usersTable)
    .where(eq(usersTable.id, post.authorId));
}

// GOOD: JOIN
const postsWithAuthors = await db
  .select({
    post: postsTable,
    author: {
      id: usersTable.id,
      name: usersTable.name,
    },
  })
  .from(postsTable)
  .leftJoin(usersTable, eq(postsTable.authorId, usersTable.id));

// GOOD: Relational queries (Drizzle relational API)
const postsWithAuthors = await db.query.posts.findMany({
  with: { author: true },
});

// ========== TYPEORM ==========
// BAD: N+1
const posts = await postRepository.find();
for (const post of posts) {
  const author = await userRepository.findOne({
    where: { id: post.authorId },
  });
}

// GOOD: Eager loading with relations
const posts = await postRepository.find({
  relations: ['author'],
});

// GOOD: QueryBuilder with JOIN
const posts = await postRepository
  .createQueryBuilder('post')
  .leftJoinAndSelect('post.author', 'author')
  .getMany();
```

```python
# ========== DJANGO ORM ==========
# BAD: N+1
posts = Post.objects.all()
for post in posts:
    print(post.author.name)  # Hits DB for each post

# GOOD: select_related (SQL JOIN, for ForeignKey/OneToOne)
posts = Post.objects.select_related('author').all()

# GOOD: prefetch_related (separate query + Python join, for ManyToMany/reverse FK)
posts = Post.objects.prefetch_related('comments').all()

# GOOD: combined
posts = Post.objects.select_related('author').prefetch_related('tags', 'comments').all()

# ========== SQLALCHEMY ==========
# BAD: N+1 (lazy loading by default)
posts = session.query(Post).all()
for post in posts:
    print(post.author.name)  # Lazy load triggers query

# GOOD: joinedload (SQL JOIN)
from sqlalchemy.orm import joinedload
posts = session.query(Post).options(joinedload(Post.author)).all()

# GOOD: selectinload (separate SELECT ... WHERE id IN (...))
from sqlalchemy.orm import selectinload
posts = session.query(Post).options(selectinload(Post.comments)).all()

# GOOD: SQLAlchemy 2.0 style
from sqlalchemy import select
stmt = select(Post).options(joinedload(Post.author))
posts = session.scalars(stmt).unique().all()
```

```ruby
# ========== ACTIVE RECORD ==========
# BAD: N+1
Post.all.each { |post| puts post.author.name }

# GOOD: includes (Rails decides JOIN vs separate query)
Post.includes(:author).each { |post| puts post.author.name }

# GOOD: eager_load (forces LEFT OUTER JOIN)
Post.eager_load(:author).each { |post| puts post.author.name }

# GOOD: preload (forces separate query)
Post.preload(:comments).each { |post| puts post.comments.size }

# Nested eager loading
Post.includes(author: :organization, comments: :user).all
```

```go
// ========== GORM ==========
// BAD: N+1
var posts []Post
db.Find(&posts)
for _, post := range posts {
    var author User
    db.First(&author, post.AuthorID)  // N queries
}

// GOOD: Preload
var posts []Post
db.Preload("Author").Find(&posts)

// GOOD: Joins (single query)
var posts []Post
db.Joins("Author").Find(&posts)

// Nested preload
db.Preload("Author.Organization").Preload("Comments.User").Find(&posts)
```

### Step 4: Connection Pooling Configuration

#### 4a: Pool Sizing

```
CONNECTION POOL SIZING:
Formula: pool_size = (core_count * 2) + effective_spindle_count
         (for SSDs, effective_spindle_count = 1)
         Typical: 10-20 connections per application instance

Example:
  4 CPU cores, SSD storage -> pool_size = (4 * 2) + 1 = 9 (round to 10)
  8 CPU cores, SSD storage -> pool_size = (8 * 2) + 1 = 17 (round to 20)

POOL CONFIGURATION:
+-------------------+-------------------+-------------------+
| Parameter         | Development       | Production        |
+-------------------+-------------------+-------------------+
| min_connections   | 1                 | 5                 |
| max_connections   | 5                 | 20                |
| idle_timeout      | 30s               | 300s (5 min)      |
| connection_timeout| 5s                | 10s               |
| max_lifetime      | 1800s (30 min)    | 3600s (1 hour)    |
| statement_timeout | 30s               | 60s               |
+-------------------+-------------------+-------------------+

WARNING: More connections != better performance
  - PostgreSQL degrades above ~100 active connections
  - Use PgBouncer or pgpool for connection multiplexing
  - Each idle connection uses ~10MB of PostgreSQL memory
  - Serverless functions need external pooling (PgBouncer, Neon, Supabase pooler)
```

#### 4b: Configuration Examples

```typescript
// Prisma: connection pool
// prisma/schema.prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
  // Connection pool settings via URL params:
  // DATABASE_URL="postgresql://user:pass@host:5432/db?connection_limit=20&pool_timeout=10"
}

// Prisma with PgBouncer (serverless)
datasource db {
  provider  = "postgresql"
  url       = env("DATABASE_URL")       // PgBouncer URL
  directUrl = env("DIRECT_DATABASE_URL") // Direct for migrations
}
```

```typescript
// Drizzle: with node-postgres pool
import { Pool } from 'pg';
import { drizzle } from 'drizzle-orm/node-postgres';

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 20,                    // Maximum connections
  min: 5,                     // Minimum idle connections
  idleTimeoutMillis: 300000,  // Close idle connections after 5 min
  connectionTimeoutMillis: 10000, // Timeout waiting for connection
  maxLifetimeMillis: 3600000, // Recycle connections after 1 hour
  statement_timeout: 60000,   // Kill queries after 60s
});

const db = drizzle(pool);
```

```python
# SQLAlchemy: connection pool
from sqlalchemy import create_engine

engine = create_engine(
    "postgresql://user:pass@host:5432/db",
    pool_size=20,           # Maximum persistent connections
    max_overflow=10,        # Extra connections when pool is full
    pool_timeout=30,        # Seconds to wait for a connection
    pool_recycle=3600,      # Recycle connections after 1 hour
    pool_pre_ping=True,     # Test connections before use (handles stale connections)
    echo=False,             # SQL logging (True for debugging)
)
```

```ruby
# Rails: database.yml
production:
  adapter: postgresql
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  timeout: 5000
  checkout_timeout: 10
  reaping_frequency: 30
  idle_timeout: 300
```

```go
// GORM: connection pool
import (
    "gorm.io/driver/postgres"
    "gorm.io/gorm"
)

db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
sqlDB, _ := db.DB()

sqlDB.SetMaxOpenConns(20)                  // Maximum open connections
sqlDB.SetMaxIdleConns(5)                   // Maximum idle connections
sqlDB.SetConnMaxLifetime(time.Hour)        // Maximum connection lifetime
sqlDB.SetConnMaxIdleTime(5 * time.Minute)  // Maximum idle time
```

### Step 5: Transaction Management Patterns

#### 5a: Basic Transaction Patterns

```typescript
// Prisma: interactive transaction
const result = await prisma.$transaction(async (tx) => {
  const order = await tx.order.create({
    data: { customerId, status: 'pending', total: 0 },
  });

  const items = await Promise.all(
    cartItems.map((item) =>
      tx.orderItem.create({
        data: {
          orderId: order.id,
          productId: item.productId,
          quantity: item.quantity,
          price: item.price,
        },
      }),
    ),
  );

  const total = items.reduce((sum, i) => sum + i.price * i.quantity, 0);
  const updatedOrder = await tx.order.update({
    where: { id: order.id },
    data: { total, status: 'confirmed' },
  });

  // Decrement inventory (with optimistic locking)
  for (const item of cartItems) {
    const product = await tx.product.update({
      where: {
        id: item.productId,
        stock: { gte: item.quantity }, // Guard: sufficient stock
      },
      data: {
        stock: { decrement: item.quantity },
      },
    });
    if (!product) {
      throw new Error(`Insufficient stock for product ${item.productId}`);
    }
  }

  return updatedOrder;
}, {
  maxWait: 5000,    // Max time to wait for transaction slot
  timeout: 10000,   // Max transaction duration
  isolationLevel: 'Serializable', // Strictest isolation for financial operations
});
```

```python
# SQLAlchemy: session-based transaction
from sqlalchemy.orm import Session

with Session(engine) as session:
    try:
        order = Order(customer_id=customer_id, status="pending", total=0)
        session.add(order)
        session.flush()  # Get order.id without committing

        total = 0
        for item in cart_items:
            order_item = OrderItem(
                order_id=order.id,
                product_id=item.product_id,
                quantity=item.quantity,
                price=item.price,
            )
            session.add(order_item)
            total += item.price * item.quantity

            # Decrement stock with row-level lock
            product = session.query(Product).filter_by(
                id=item.product_id
            ).with_for_update().one()

            if product.stock < item.quantity:
                raise ValueError(f"Insufficient stock for {product.name}")
            product.stock -= item.quantity

        order.total = total
        order.status = "confirmed"
        session.commit()
    except Exception:
        session.rollback()
        raise
```

#### 5b: Nested Transactions (Savepoints)

```typescript
// Prisma: nested transactions with savepoints
const result = await prisma.$transaction(async (tx) => {
  const user = await tx.user.create({ data: userData });

  try {
    // This creates a savepoint
    await tx.$transaction(async (nestedTx) => {
      await nestedTx.notification.create({
        data: { userId: user.id, type: 'welcome' },
      });
      await nestedTx.emailQueue.create({
        data: { to: user.email, template: 'welcome' },
      });
    });
  } catch (err) {
    // Notification/email failed, but user creation is NOT rolled back
    console.error('Non-critical: notification setup failed', err);
  }

  return user;
});
```

```python
# SQLAlchemy: savepoints
with Session(engine) as session:
    user = User(email="jane@example.com", name="Jane")
    session.add(user)
    session.flush()

    # Savepoint: if this fails, only this block rolls back
    savepoint = session.begin_nested()
    try:
        notification = Notification(user_id=user.id, type="welcome")
        session.add(notification)
        savepoint.commit()
    except Exception:
        savepoint.rollback()
        # user creation is preserved

    session.commit()  # Commits user (and notification if savepoint succeeded)
```

#### 5c: Distributed Transactions (Saga Pattern)

```typescript
// Saga pattern for cross-service operations
// (when you can't use a single database transaction)

interface SagaStep<T> {
  name: string;
  execute: (context: T) => Promise<T>;
  compensate: (context: T) => Promise<T>;
}

class Saga<T> {
  private steps: SagaStep<T>[] = [];
  private completedSteps: SagaStep<T>[] = [];

  addStep(step: SagaStep<T>): this {
    this.steps.push(step);
    return this;
  }

  async execute(initialContext: T): Promise<T> {
    let context = initialContext;

    for (const step of this.steps) {
      try {
        context = await step.execute(context);
        this.completedSteps.push(step);
      } catch (error) {
        console.error(`Saga step "${step.name}" failed:`, error);
        await this.compensate(context);
        throw error;
      }
    }

    return context;
  }

  private async compensate(context: T): Promise<void> {
    // Compensate in reverse order
    for (const step of [...this.completedSteps].reverse()) {
      try {
        await step.compensate(context);
      } catch (error) {
        console.error(`Compensation for "${step.name}" failed:`, error);
        // Log for manual intervention -- compensation failures are critical
      }
    }
  }
}

// Usage: Order placement saga
const orderSaga = new Saga<OrderContext>()
  .addStep({
    name: 'reserve-inventory',
    execute: async (ctx) => {
      ctx.reservationId = await inventoryService.reserve(ctx.items);
      return ctx;
    },
    compensate: async (ctx) => {
      await inventoryService.release(ctx.reservationId!);
      return ctx;
    },
  })
  .addStep({
    name: 'charge-payment',
    execute: async (ctx) => {
      ctx.paymentId = await paymentService.charge(ctx.total, ctx.paymentMethod);
      return ctx;
    },
    compensate: async (ctx) => {
      await paymentService.refund(ctx.paymentId!);
      return ctx;
    },
  })
  .addStep({
    name: 'create-order',
    execute: async (ctx) => {
      ctx.orderId = await orderService.create(ctx);
      return ctx;
    },
    compensate: async (ctx) => {
      await orderService.cancel(ctx.orderId!);
      return ctx;
    },
  });
```

### Step 6: Query Builder Patterns

#### 6a: Dynamic Query Building

```typescript
// Drizzle: composable query building
import { and, eq, gte, lte, like, desc, asc, SQL } from 'drizzle-orm';

interface TaskFilters {
  projectId?: string;
  status?: string;
  assigneeId?: string;
  search?: string;
  dueBefore?: Date;
  dueAfter?: Date;
  sortBy?: 'created_at' | 'due_date' | 'priority';
  sortOrder?: 'asc' | 'desc';
  page?: number;
  limit?: number;
}

function buildTaskQuery(filters: TaskFilters) {
  const conditions: SQL[] = [];

  if (filters.projectId) {
    conditions.push(eq(tasks.projectId, filters.projectId));
  }
  if (filters.status) {
    conditions.push(eq(tasks.status, filters.status));
  }
  if (filters.assigneeId) {
    conditions.push(eq(tasks.assigneeId, filters.assigneeId));
  }
  if (filters.search) {
    conditions.push(like(tasks.title, `%${filters.search}%`));
  }
  if (filters.dueBefore) {
    conditions.push(lte(tasks.dueDate, filters.dueBefore));
  }
  if (filters.dueAfter) {
    conditions.push(gte(tasks.dueDate, filters.dueAfter));
  }

  const sortColumn = filters.sortBy === 'due_date'
    ? tasks.dueDate
    : filters.sortBy === 'priority'
      ? tasks.priority
      : tasks.createdAt;

  const sortFn = filters.sortOrder === 'asc' ? asc : desc;
  const limit = Math.min(filters.limit ?? 20, 100);
  const offset = ((filters.page ?? 1) - 1) * limit;

  return db
    .select()
    .from(tasks)
    .where(conditions.length > 0 ? and(...conditions) : undefined)
    .orderBy(sortFn(sortColumn))
    .limit(limit)
    .offset(offset);
}
```

```python
# SQLAlchemy: composable query building
from sqlalchemy import select, and_, or_, func

def build_task_query(
    project_id: str | None = None,
    status: str | None = None,
    assignee_id: str | None = None,
    search: str | None = None,
    sort_by: str = "created_at",
    sort_order: str = "desc",
    page: int = 1,
    limit: int = 20,
):
    stmt = select(Task)
    conditions = []

    if project_id:
        conditions.append(Task.project_id == project_id)
    if status:
        conditions.append(Task.status == status)
    if assignee_id:
        conditions.append(Task.assignee_id == assignee_id)
    if search:
        conditions.append(Task.title.ilike(f"%{search}%"))

    if conditions:
        stmt = stmt.where(and_(*conditions))

    sort_column = getattr(Task, sort_by, Task.created_at)
    stmt = stmt.order_by(
        sort_column.desc() if sort_order == "desc" else sort_column.asc()
    )

    stmt = stmt.limit(min(limit, 100)).offset((page - 1) * limit)
    return stmt
```

#### 6b: Raw SQL Escape Hatch

```typescript
// Prisma: raw SQL when the ORM is not enough
const result = await prisma.$queryRaw<{ id: string; name: string; task_count: number }[]>`
  SELECT u.id, u.name, COUNT(t.id)::int AS task_count
  FROM users u
  LEFT JOIN tasks t ON t.assignee_id = u.id
    AND t.status != 'cancelled'
    AND t.created_at >= ${startDate}
  WHERE u.org_id = ${orgId}
  GROUP BY u.id, u.name
  HAVING COUNT(t.id) > ${minTasks}
  ORDER BY task_count DESC
  LIMIT ${limit}
`;

// Drizzle: raw SQL with sql`` template
import { sql } from 'drizzle-orm';

const result = await db.execute(sql`
  SELECT u.id, u.name, COUNT(t.id)::int AS task_count
  FROM ${users} u
  LEFT JOIN ${tasks} t ON t.assignee_id = u.id
    AND t.status != 'cancelled'
    AND t.created_at >= ${startDate}
  WHERE u.org_id = ${orgId}
  GROUP BY u.id, u.name
  HAVING COUNT(t.id) > ${minTasks}
  ORDER BY task_count DESC
  LIMIT ${limit}
`);
```

### Step 7: Production Readiness Checklist

```
ORM PRODUCTION READINESS:
[ ] Connection pooling configured (pool size, timeouts, recycling)
[ ] Query logging enabled in staging, disabled (or sampled) in production
[ ] N+1 queries detected and fixed (eager loading where needed)
[ ] Slow query threshold set (log queries > 1s)
[ ] Statement timeout configured (prevent runaway queries)
[ ] Retry logic for transient failures (connection reset, deadlock)
[ ] Read replica routing configured (if applicable)
[ ] Migration strategy tested (up + down + up)
[ ] Soft delete hooks applied globally (if using soft delete)
[ ] Audit trail configured (created_by, updated_by, if needed)
[ ] Connection health checks enabled (pool_pre_ping or equivalent)
[ ] Prepared statement caching configured (reduces parse time)
[ ] Schema validation matches database (no drift between ORM schema and DB)
```

### Step 8: Report and Transition

```
+--------------------------------------------------------------+
|  ORM & DATA ACCESS -- <description>                           |
+--------------------------------------------------------------+
|  Language:          <language>                                 |
|  ORM:              <selected ORM>                             |
|  Database:          <engine>                                  |
|  Connection:        <direct | pooled | serverless>            |
+--------------------------------------------------------------+
|  Issues found:                                                |
|  - N+1 queries:    <N> detected, <M> fixed                   |
|  - Pool config:    <current vs recommended>                   |
|  - Transactions:   <patterns implemented>                     |
|  - Missing indexes: <N> recommended by query analysis         |
+--------------------------------------------------------------+
|  Performance improvement:                                     |
|  - Queries reduced: <before> -> <after>                       |
|  - Avg response time: <before>ms -> <after>ms                 |
|  - Connection utilization: <before>% -> <after>%              |
+--------------------------------------------------------------+
|  Files created/modified:                                      |
|  - <file path and purpose>                                    |
+--------------------------------------------------------------+
```

Commit: `"orm: optimize <description> data access layer"`

## Key Behaviors

1. **The ORM is a tool, not a religion.** Use the ORM for 90% of queries. Use raw SQL for the 10% where the ORM generates bad SQL. Every ORM has a raw SQL escape hatch -- know how to use it.
2. **Enable query logging in development.** You cannot fix N+1 queries you cannot see. Every ORM has a logging option. Turn it on. Watch the query count on every page load.
3. **Eager load relationships at the query site, not globally.** Global eager loading wastes resources when the relationship is not needed. Load at the point of use: `include`, `select_related`, `Preload`, `includes`.
4. **Connection pools are bounded resources.** More connections does not mean more throughput. PostgreSQL performance degrades above ~100 connections. Size your pool based on CPU cores, not request volume.
5. **Transactions should be as short as possible.** Long transactions hold locks, block other queries, and increase deadlock probability. Do computation outside the transaction, write inside.
6. **Optimistic locking for concurrent updates.** Use a version column or timestamp to detect conflicting updates. Pessimistic locking (SELECT FOR UPDATE) is correct but reduces concurrency.
7. **Separate read and write models when scale demands it.** Route reads to replicas, writes to primary. Most ORMs support this natively or through middleware.
8. **Monitor connection pool metrics in production.** Track: active connections, idle connections, wait time, timeout count, connection errors. Alert when pool utilization exceeds 80%.
9. **Test transactions under concurrency.** A transaction that works with one user may deadlock with ten concurrent users. Test with realistic concurrency.
10. **Migrations and ORM schema must stay in sync.** If you change the ORM schema, generate a migration. If you write a raw migration, update the ORM schema. Drift between the two causes runtime errors.

## Example Usage

### Selecting an ORM for a new project
```
User: /godmode:orm I'm starting a new TypeScript project with PostgreSQL.
      Prisma or Drizzle?

ORM: Analyzing your requirements...

Questions:
1. Is this serverless/edge deployed? -> Drizzle (smaller bundle, no engine)
2. Do you need complex raw SQL? -> Drizzle (SQL-first API)
3. Do you want maximum DX and type safety with less SQL control? -> Prisma
4. Do you need a visual schema editor? -> Prisma (Prisma Studio)

RECOMMENDATION for your case:
Project: REST API, deployed on Vercel Edge Functions, 20 tables
-> Drizzle

Rationale:
- Edge deployment: Drizzle is ~30KB, Prisma engine is ~2MB
- SQL-first: Your team knows SQL, Drizzle maps 1:1
- Performance: Drizzle generates direct SQL, no query engine overhead
- Migrations: drizzle-kit generates SQL migrations you can review
```

### Fixing N+1 queries in a Prisma project
```
User: /godmode:orm My API endpoint takes 2 seconds. I think it's an N+1 problem.

ORM: Enabling query logging...

Found 127 queries on a single endpoint:
  1x  SELECT * FROM orders WHERE customer_id = ?          (parent query)
  42x SELECT * FROM order_items WHERE order_id = ?          (N+1: items)
  42x SELECT * FROM products WHERE id = ?                   (N+1: products)
  42x SELECT * FROM shipping WHERE order_id = ?             (N+1: shipping)

FIX:
const orders = await prisma.order.findMany({
  where: { customerId },
  include: {
    items: { include: { product: true } },
    shipping: true,
  },
});

RESULT: 127 queries -> 1 query (with JOINs)
Time: 2,100ms -> 45ms (47x improvement)
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Interactive ORM selection and configuration workflow |
| `--select` | ORM selection guide with comparison matrix |
| `--n-plus-one` | Scan codebase for N+1 query patterns |
| `--pool` | Configure connection pooling for production |
| `--transactions` | Design transaction management patterns |
| `--query-builder` | Implement dynamic query building patterns |
| `--raw-sql` | Add raw SQL for queries the ORM handles poorly |
| `--audit` | Full audit of ORM usage, performance, and configuration |
| `--migrate` | Migrate from one ORM to another |
| `--replica` | Set up read replica routing |
| `--logging` | Configure query logging and slow query detection |
| `--report` | Generate full data access layer report |

## HARD RULES

1. **NEVER mix ORMs in the same project.** One project, one ORM. Prisma + TypeORM = schema drift, migration conflicts, pool contention.
2. **NEVER set pool size >= max_connections.** Coordinate across all app instances: `pool_size_per_instance * instance_count < max_connections * 0.8`.
3. **NEVER lazy-load in a loop.** If you see `for ... await find` or `for post in posts: post.author`, that is an N+1. Fix it before committing.
4. **NEVER hold a transaction open during I/O.** No HTTP calls, no email sends, no file uploads inside a database transaction. Compute outside, write inside.
5. **NEVER use SELECT * through the ORM in production.** Select only the columns you need. Use `select:` (Prisma), `select()` (Drizzle), `.only()` (Django), `.pluck()` (Rails).
6. **NEVER disable foreign key constraints.** Orphaned data is worse than any perceived performance gain.
7. **ALWAYS enable query logging in development.** You cannot fix N+1 queries you cannot see.
8. **ALWAYS test migrations with up + down + up cycle.** A migration that cannot be reversed is a deployment risk.
9. **NEVER retry on constraint violations or syntax errors.** Only retry on transient failures (connection reset, deadlock, timeout).

## Explicit Loop Protocol

ORM optimization is iterative -- detect, fix, verify, repeat:

```
current_iteration = 0
issues_remaining = []  # populated by initial scan

# Initial scan
SCAN codebase for: N+1 patterns, missing indexes, pool misconfig, unoptimized queries
issues_remaining = scan_results

WHILE issues_remaining is not empty AND current_iteration < 10:
    current_iteration += 1
    issue = issues_remaining.pop(0)

    1. DIAGNOSE: enable query logging, reproduce, count queries
    2. FIX: apply eager loading / add index / tune pool / rewrite query
    3. VERIFY: re-run with query logging, confirm query count reduced
    4. MEASURE: before/after response time and query count
    5. IF verification fails OR regression detected:
        issues_remaining.append(issue)  # retry
    6. REPORT: "Issue {issue.type}: {FIXED|RETRY} -- {before}ms -> {after}ms -- iteration {current_iteration}"

OUTPUT: Full data access layer report with before/after metrics.
```

## Multi-Agent Dispatch

For large codebases with many data access patterns, dispatch parallel agents:

```
MULTI-AGENT ORM OPTIMIZATION:
Dispatch 2-3 agents in parallel worktrees.

Agent 1 (worktree: orm-n-plus-one):
  - Scan all endpoints/services for N+1 query patterns
  - Add eager loading (include/select_related/Preload) to each
  - Verify with query logging: before/after query counts

Agent 2 (worktree: orm-pool-config):
  - Audit connection pool settings across all environments
  - Configure production pool sizes based on CPU cores
  - Add connection health checks and monitoring
  - Set statement timeouts and max lifetimes

Agent 3 (worktree: orm-transactions):
  - Audit transaction patterns for correctness
  - Add optimistic locking where concurrent updates occur
  - Implement saga pattern for cross-service operations
  - Add retry logic for transient failures

MERGE ORDER: n-plus-one -> pool-config -> transactions
CONFLICT ZONES: ORM config files, middleware registration, service constructors
```

## Anti-Patterns

- **Do NOT use the ORM for everything.** Complex reporting queries, recursive CTEs, window functions, and bulk operations are often better as raw SQL. The ORM is for CRUD, not analytics.
- **Do NOT lazy-load in a loop.** Accessing a relationship in a for loop triggers a query per iteration. Always eager-load relationships you know you will need.
- **Do NOT open connections without a pool.** Creating a new connection per request is 10-100x slower than using a pooled connection. Always use a connection pool.
- **Do NOT hold transactions open during I/O.** Do not make HTTP calls, send emails, or wait for user input inside a database transaction. Compute outside, write inside.
- **Do NOT use SELECT * through the ORM.** Select only the columns you need. ORMs that load full objects by default waste bandwidth and memory.
- **Do NOT ignore the generated SQL.** The prettiest ORM code can generate terrible SQL. Log the SQL, read it, run EXPLAIN on it.
- **Do NOT disable foreign key constraints for "flexibility."** Foreign keys are not a performance problem. Orphaned data is. Keep constraints on.
- **Do NOT set pool size to max_connections.** If you have 3 app instances each with pool_size=100 and PostgreSQL max_connections=100, the third instance gets zero connections. Coordinate pool sizes across instances.
- **Do NOT retry on every error.** Retry on transient errors (connection reset, deadlock). Do NOT retry on constraint violations or syntax errors -- those will never succeed.
- **Do NOT mix ORMs in the same project.** Using Prisma AND TypeORM on the same database creates schema drift, migration conflicts, and connection pool contention. Pick one.


## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run ORM tasks sequentially: N+1 fixes, then pool config, then transaction patterns.
- Use branch isolation per task: `git checkout -b godmode-orm-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
