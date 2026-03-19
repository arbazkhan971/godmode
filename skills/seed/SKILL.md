---
name: seed
description: Database seeding, test fixtures, factory patterns, fake data generation. Use when user mentions seed data, fixtures, factories, test data, Faker, FactoryBot, database population.
---

# Seed -- Database Seeding & Test Data Generation

## When to Activate
- User invokes `/godmode:seed`
- User says "seed the database", "generate test data", "create fixtures"
- User asks about factory patterns (FactoryBot, fishery, factory_boy, Bogus)
- User needs fake data generation (Faker.js, Faker Python, go-faker)
- User asks about idempotent seed scripts or environment-aware seeding
- User needs to populate a database for development, staging, or demo
- User asks about data anonymization for production snapshots
- User needs deterministic/reproducible test data
- User wants to seed large datasets efficiently (batch inserts, streaming)
- Godmode orchestrator detects empty databases or missing test data

## Workflow

### Step 1: Detect Seeding Environment

Identify the project's stack, database, ORM, and existing seeding patterns:

```
SEEDING ENVIRONMENT:
Language:        <TypeScript | Python | Go | Ruby | Java | C# | Rust | PHP>
ORM/DAL:        <Prisma | Drizzle | TypeORM | Sequelize | SQLAlchemy | Django ORM | GORM | ActiveRecord | Eloquent | None>
Database:        <PostgreSQL | MySQL | SQLite | SQL Server | MongoDB>
Existing seeds:  <path to seed files, or "none detected">
Factory lib:     <FactoryBot | fishery | factory_boy | Bogus | rosie | none>
Faker lib:       <@faker-js/faker | Faker (Python) | go-faker | Bogus | none>
Test framework:  <Jest | Vitest | pytest | RSpec | Go testing | xUnit>
Environments:    <dev | staging | demo | production-snapshot>
Detection:       <how detected -- prisma/seed.ts, db/seeds.rb, management commands, etc.>
```

Scan the codebase for existing seeding infrastructure:
```bash
# Detect seed files and directories
ls prisma/seed.ts prisma/seed.js db/seeds.rb db/seeds/ scripts/seed* 2>/dev/null
find . -maxdepth 3 -name "seed*" -o -name "factory*" -o -name "fixture*" 2>/dev/null | head -20

# Detect factory/fixture libraries in dependencies
grep -E "factory_bot|fishery|@faker-js|faker|rosie|factory_boy|bogus" package.json Gemfile requirements.txt go.mod 2>/dev/null

# Detect existing factory definitions
find . -maxdepth 4 -name "*.factory.ts" -o -name "*.factory.js" -o -name "*_factory.rb" -o -name "factories.py" -o -name "*Factory.cs" 2>/dev/null | head -20

# Detect fixture files
find . -maxdepth 4 -name "*.fixture.ts" -o -name "fixtures.json" -o -name "*.yaml" -path "*/fixtures/*" 2>/dev/null | head -20

# Detect existing seed scripts
grep -rn "createMany\|insertMany\|bulk_create\|insert_all\|create_list" --include="*.ts" --include="*.py" --include="*.rb" -l 2>/dev/null | head -10

# Check for Prisma seed configuration
grep -A2 "seed" prisma/package.json package.json 2>/dev/null
```

### Step 2: Factory Pattern Implementation

#### 2a: Factory Library Selection

```
FACTORY LIBRARY MATRIX:
+--------------------+----------------+----------------+-------------------+
| Language           | Primary        | Alternative    | Built-in Approach |
+--------------------+----------------+----------------+-------------------+
| TypeScript/JS      | fishery        | rosie, teste   | Plain functions   |
| Python             | factory_boy    | model_bakery   | pytest fixtures   |
| Ruby               | FactoryBot     | Fabrication    | fixtures (YAML)   |
| Go                 | go-factory     | gofakeit       | Table-driven      |
| C#                 | Bogus          | AutoFixture    | Builder pattern   |
| Java               | Instancio      | EasyRandom     | Builder pattern   |
| PHP                | Eloquent factories | Foundry    | Seeders           |
+--------------------+----------------+----------------+-------------------+
```

#### 2b: Factory Patterns by Language

```typescript
// ========== TypeScript: fishery ==========
// npm install fishery @faker-js/faker

import { Factory } from 'fishery';
import { faker } from '@faker-js/faker';

// Base user factory
const userFactory = Factory.define<User>(({ sequence, params, transientParams }) => {
  const firstName = params.firstName ?? faker.person.firstName();
  const lastName = params.lastName ?? faker.person.lastName();

  return {
    id: sequence,
    email: params.email ?? faker.internet.email({ firstName, lastName }),
    firstName,
    lastName,
    role: params.role ?? 'member',
    avatarUrl: faker.image.avatar(),
    createdAt: faker.date.past({ years: 1 }),
    isActive: true,
  };
});

// Factory with traits (named variations)
const adminFactory = userFactory.params({ role: 'admin' });
const inactiveFactory = userFactory.params({ isActive: false });

// Factory with associations
const postFactory = Factory.define<Post>(({ sequence, associations }) => ({
  id: sequence,
  title: faker.lorem.sentence(),
  body: faker.lorem.paragraphs(3),
  slug: faker.helpers.slugify(faker.lorem.sentence()).toLowerCase(),
  status: 'draft',
  author: associations.author || userFactory.build(),
  authorId: associations.author?.id ?? 0,
  tags: faker.helpers.arrayElements(['typescript', 'nodejs', 'react', 'postgres', 'testing'], { min: 1, max: 3 }),
  publishedAt: null,
  createdAt: faker.date.past({ years: 1 }),
}));

// Published post trait
const publishedPostFactory = postFactory.params({
  status: 'published',
  publishedAt: faker.date.past({ years: 1 }),
});

// Usage
const user = userFactory.build();                           // Single instance
const users = userFactory.buildList(10);                     // List of 10
const admin = adminFactory.build();                          // Admin variant
const post = postFactory.build({ author: admin });           // With association
const publishedPosts = publishedPostFactory.buildList(5);    // Published posts

// Create in database (with async create method)
const userWithDbFactory = Factory.define<User>(({ sequence }) => ({
  id: sequence,
  email: faker.internet.email(),
  firstName: faker.person.firstName(),
  lastName: faker.person.lastName(),
  role: 'member',
  avatarUrl: faker.image.avatar(),
  createdAt: new Date(),
  isActive: true,
}));

// Override create to persist
class UserFactory extends Factory<User> {
  async create(params?: Partial<User>): Promise<User> {
    const user = this.build(params);
    return prisma.user.create({ data: user });
  }
}
```

```python
# ========== Python: factory_boy ==========
# pip install factory_boy faker

import factory
from factory import fuzzy
from datetime import datetime, timedelta

class UserFactory(factory.Factory):
    class Meta:
        model = User  # SQLAlchemy / Django model

    id = factory.Sequence(lambda n: n + 1)
    email = factory.LazyAttribute(lambda o: f"{o.first_name.lower()}.{o.last_name.lower()}@example.com")
    first_name = factory.Faker("first_name")
    last_name = factory.Faker("last_name")
    role = "member"
    is_active = True
    created_at = factory.LazyFunction(datetime.utcnow)

    class Params:
        admin = factory.Trait(role="admin")
        inactive = factory.Trait(is_active=False)

# Factory with associations (SubFactory)
class PostFactory(factory.Factory):
    class Meta:
        model = Post

    id = factory.Sequence(lambda n: n + 1)
    title = factory.Faker("sentence")
    body = factory.Faker("paragraphs", nb=3)
    slug = factory.LazyAttribute(lambda o: o.title.lower().replace(" ", "-").rstrip("."))
    status = "draft"
    author = factory.SubFactory(UserFactory)
    created_at = factory.LazyFunction(datetime.utcnow)
    published_at = None

    class Params:
        published = factory.Trait(
            status="published",
            published_at=factory.LazyFunction(datetime.utcnow),
        )

# For Django: use DjangoModelFactory (persists automatically)
class UserFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = "auth.User"

    username = factory.Sequence(lambda n: f"user_{n}")
    email = factory.LazyAttribute(lambda o: f"{o.username}@example.com")

# Usage
user = UserFactory()                          # Create in DB (Django)
user = UserFactory.build()                    # Build without saving
admin = UserFactory(admin=True)               # Use trait
users = UserFactory.create_batch(10)          # Batch create
post = PostFactory(published=True, author=admin)  # With trait and association
```

```ruby
# ========== Ruby: FactoryBot ==========
# gem 'factory_bot_rails'
# gem 'faker'

FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    email      { "#{first_name.downcase}.#{last_name.downcase}@example.com" }
    role       { "member" }
    is_active  { true }
    created_at { Faker::Time.backward(days: 365) }

    trait :admin do
      role { "admin" }
    end

    trait :inactive do
      is_active { false }
    end

    # Nested factory
    factory :admin_user, traits: [:admin]
  end

  factory :post do
    title        { Faker::Lorem.sentence }
    body         { Faker::Lorem.paragraphs(number: 3).join("\n\n") }
    slug         { title.parameterize }
    status       { "draft" }
    association  :author, factory: :user
    published_at { nil }

    trait :published do
      status       { "published" }
      published_at { Faker::Time.backward(days: 30) }
    end
  end
end

# Usage
user = create(:user)                             # Persist to DB
user = build(:user)                              # Build without saving
admin = create(:user, :admin)                    # With trait
posts = create_list(:post, 5, :published)        # Batch with trait
post = create(:post, author: admin)              # Explicit association
```

```go
// ========== Go: Table-driven factories with gofakeit ==========
// go get github.com/brianvoss/gofakeit/v7

package factories

import (
    "fmt"
    "github.com/brianvoss/gofakeit/v7"
    "time"
)

type UserBuilder struct {
    user User
}

func NewUserBuilder() *UserBuilder {
    return &UserBuilder{
        user: User{
            Email:     gofakeit.Email(),
            FirstName: gofakeit.FirstName(),
            LastName:  gofakeit.LastName(),
            Role:      "member",
            IsActive:  true,
            CreatedAt: gofakeit.DateRange(
                time.Now().AddDate(-1, 0, 0),
                time.Now(),
            ),
        },
    }
}

func (b *UserBuilder) Admin() *UserBuilder {
    b.user.Role = "admin"
    return b
}

func (b *UserBuilder) Inactive() *UserBuilder {
    b.user.IsActive = false
    return b
}

func (b *UserBuilder) WithEmail(email string) *UserBuilder {
    b.user.Email = email
    return b
}

func (b *UserBuilder) Build() User {
    return b.user
}

func (b *UserBuilder) Create(db *gorm.DB) (User, error) {
    user := b.Build()
    result := db.Create(&user)
    return user, result.Error
}

// Batch creation
func CreateUsers(db *gorm.DB, count int) ([]User, error) {
    users := make([]User, count)
    for i := range users {
        users[i] = NewUserBuilder().Build()
    }
    result := db.CreateInBatches(users, 100) // Batch size 100
    return users, result.Error
}
```

```csharp
// ========== C#: Bogus ==========
// dotnet add package Bogus

using Bogus;

var userFaker = new Faker<User>()
    .RuleFor(u => u.Id, f => f.IndexFaker + 1)
    .RuleFor(u => u.Email, (f, u) => f.Internet.Email(u.FirstName, u.LastName))
    .RuleFor(u => u.FirstName, f => f.Name.FirstName())
    .RuleFor(u => u.LastName, f => f.Name.LastName())
    .RuleFor(u => u.Role, f => "member")
    .RuleFor(u => u.IsActive, true)
    .RuleFor(u => u.CreatedAt, f => f.Date.Past(1));

// Generate
var user = userFaker.Generate();
var users = userFaker.Generate(10);

// Admin variant
var adminFaker = userFaker.Clone()
    .RuleFor(u => u.Role, "admin");

// Post with association
var postFaker = new Faker<Post>()
    .RuleFor(p => p.Title, f => f.Lorem.Sentence())
    .RuleFor(p => p.Body, f => f.Lorem.Paragraphs(3))
    .RuleFor(p => p.Status, "draft")
    .RuleFor(p => p.Author, f => userFaker.Generate())
    .RuleFor(p => p.CreatedAt, f => f.Date.Past(1));
```

### Step 3: Seed Script Architecture

#### 3a: Idempotent Seed Script Pattern

```
IDEMPOTENT SEED SCRIPT RULES:
1. ALWAYS use upsert (insert or update) instead of plain insert
2. Use a stable identifier (slug, email, external_id) -- NOT auto-increment IDs
3. Run seeds in dependency order (users before posts, categories before products)
4. Wrap each logical group in a transaction
5. Log what was created vs. skipped vs. updated
6. Make seeds re-runnable: running twice produces the same result as running once
```

```typescript
// ========== TypeScript/Prisma: Idempotent seed script ==========
// prisma/seed.ts

import { PrismaClient } from '@prisma/client';
import { faker } from '@faker-js/faker';

const prisma = new PrismaClient();

// Deterministic seed for reproducibility
faker.seed(42);

async function main() {
  console.log('🌱 Starting database seed...');
  const startTime = Date.now();

  // Phase 1: Reference data (idempotent upserts)
  await seedRoles();
  await seedCategories();

  // Phase 2: Core entities
  await seedUsers();

  // Phase 3: Dependent entities
  await seedPosts();
  await seedComments();

  const duration = ((Date.now() - startTime) / 1000).toFixed(1);
  console.log(`✅ Seed completed in ${duration}s`);
}

async function seedRoles() {
  const roles = ['admin', 'editor', 'member', 'viewer'];

  for (const name of roles) {
    await prisma.role.upsert({
      where: { name },
      update: {},           // No update needed -- reference data is static
      create: { name },
    });
  }

  console.log(`  Roles: ${roles.length} upserted`);
}

async function seedCategories() {
  const categories = [
    { slug: 'engineering', name: 'Engineering', color: '#3B82F6' },
    { slug: 'design', name: 'Design', color: '#8B5CF6' },
    { slug: 'product', name: 'Product', color: '#10B981' },
    { slug: 'devops', name: 'DevOps', color: '#F59E0B' },
  ];

  for (const cat of categories) {
    await prisma.category.upsert({
      where: { slug: cat.slug },
      update: { name: cat.name, color: cat.color },
      create: cat,
    });
  }

  console.log(`  Categories: ${categories.length} upserted`);
}

async function seedUsers() {
  // Fixed seed users (always the same for development)
  const seedUsers = [
    { email: 'admin@example.com', firstName: 'Admin', lastName: 'User', role: 'admin' },
    { email: 'editor@example.com', firstName: 'Editor', lastName: 'User', role: 'editor' },
    { email: 'member@example.com', firstName: 'Member', lastName: 'User', role: 'member' },
  ];

  for (const u of seedUsers) {
    await prisma.user.upsert({
      where: { email: u.email },
      update: { firstName: u.firstName, lastName: u.lastName },
      create: {
        email: u.email,
        firstName: u.firstName,
        lastName: u.lastName,
        role: { connect: { name: u.role } },
        avatarUrl: faker.image.avatar(),
      },
    });
  }

  // Generate additional random users
  const existingCount = await prisma.user.count();
  const targetCount = 50;
  const toCreate = Math.max(0, targetCount - existingCount);

  if (toCreate > 0) {
    const users = Array.from({ length: toCreate }, () => ({
      email: faker.internet.email(),
      firstName: faker.person.firstName(),
      lastName: faker.person.lastName(),
      avatarUrl: faker.image.avatar(),
      roleName: 'member',
    }));

    await prisma.user.createMany({
      data: users.map(u => ({
        email: u.email,
        firstName: u.firstName,
        lastName: u.lastName,
        avatarUrl: u.avatarUrl,
      })),
      skipDuplicates: true,
    });

    console.log(`  Users: ${seedUsers.length} fixed + ${toCreate} generated`);
  } else {
    console.log(`  Users: ${seedUsers.length} fixed, ${existingCount} already exist (target: ${targetCount})`);
  }
}

async function seedPosts() {
  const users = await prisma.user.findMany({ select: { id: true } });
  const categories = await prisma.category.findMany({ select: { id: true } });

  const existingCount = await prisma.post.count();
  const targetCount = 200;
  const toCreate = Math.max(0, targetCount - existingCount);

  if (toCreate > 0) {
    const posts = Array.from({ length: toCreate }, () => {
      const title = faker.lorem.sentence();
      return {
        title,
        slug: faker.helpers.slugify(title).toLowerCase(),
        body: faker.lorem.paragraphs({ min: 3, max: 8 }),
        status: faker.helpers.weightedArrayElement([
          { value: 'published', weight: 6 },
          { value: 'draft', weight: 3 },
          { value: 'archived', weight: 1 },
        ]),
        authorId: faker.helpers.arrayElement(users).id,
        categoryId: faker.helpers.arrayElement(categories).id,
        publishedAt: faker.date.past({ years: 1 }),
        createdAt: faker.date.past({ years: 2 }),
      };
    });

    // Batch insert for performance
    await prisma.post.createMany({
      data: posts,
      skipDuplicates: true,
    });

    console.log(`  Posts: ${toCreate} created`);
  } else {
    console.log(`  Posts: ${existingCount} already exist (target: ${targetCount})`);
  }
}

async function seedComments() {
  const users = await prisma.user.findMany({ select: { id: true } });
  const posts = await prisma.post.findMany({
    where: { status: 'published' },
    select: { id: true },
  });

  const existingCount = await prisma.comment.count();
  const targetCount = 500;
  const toCreate = Math.max(0, targetCount - existingCount);

  if (toCreate > 0) {
    const comments = Array.from({ length: toCreate }, () => ({
      body: faker.lorem.paragraph(),
      authorId: faker.helpers.arrayElement(users).id,
      postId: faker.helpers.arrayElement(posts).id,
      createdAt: faker.date.past({ years: 1 }),
    }));

    await prisma.comment.createMany({ data: comments });
    console.log(`  Comments: ${toCreate} created`);
  } else {
    console.log(`  Comments: ${existingCount} already exist (target: ${targetCount})`);
  }
}

main()
  .catch((e) => {
    console.error('❌ Seed failed:', e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
```

```python
# ========== Python/Django: management command seed ==========
# app/management/commands/seed.py

from django.core.management.base import BaseCommand
from django.db import transaction
from faker import Faker

fake = Faker()
Faker.seed(42)  # Deterministic

class Command(BaseCommand):
    help = "Seed the database with development data"

    def add_arguments(self, parser):
        parser.add_argument("--env", choices=["dev", "staging", "demo"], default="dev")
        parser.add_argument("--users", type=int, default=50)
        parser.add_argument("--posts", type=int, default=200)
        parser.add_argument("--reset", action="store_true", help="Truncate tables before seeding")

    def handle(self, *args, **options):
        env = options["env"]
        self.stdout.write(f"Seeding for environment: {env}")

        if options["reset"]:
            self._truncate_tables()

        with transaction.atomic():
            self._seed_roles()
            self._seed_categories()
            users = self._seed_users(options["users"])
            self._seed_posts(options["posts"], users)

        self.stdout.write(self.style.SUCCESS("Seed completed"))

    def _seed_roles(self):
        from app.models import Role
        roles = ["admin", "editor", "member", "viewer"]
        for name in roles:
            Role.objects.update_or_create(name=name, defaults={"name": name})
        self.stdout.write(f"  Roles: {len(roles)} upserted")

    def _seed_categories(self):
        from app.models import Category
        categories = [
            {"slug": "engineering", "name": "Engineering"},
            {"slug": "design", "name": "Design"},
            {"slug": "product", "name": "Product"},
        ]
        for cat in categories:
            Category.objects.update_or_create(slug=cat["slug"], defaults=cat)
        self.stdout.write(f"  Categories: {len(categories)} upserted")

    def _seed_users(self, count):
        from app.models import User
        # Fixed users first
        admin, _ = User.objects.update_or_create(
            email="admin@example.com",
            defaults={"first_name": "Admin", "last_name": "User", "is_staff": True},
        )

        existing = User.objects.count()
        to_create = max(0, count - existing)
        users = User.objects.bulk_create(
            [
                User(
                    email=fake.unique.email(),
                    first_name=fake.first_name(),
                    last_name=fake.last_name(),
                )
                for _ in range(to_create)
            ],
            ignore_conflicts=True,
        )
        self.stdout.write(f"  Users: {len(users)} created ({existing} existed)")
        return list(User.objects.all())

    def _seed_posts(self, count, users):
        from app.models import Post, Category
        categories = list(Category.objects.all())

        existing = Post.objects.count()
        to_create = max(0, count - existing)
        Post.objects.bulk_create(
            [
                Post(
                    title=fake.sentence(),
                    body=fake.text(max_nb_chars=2000),
                    status=fake.random_element(["published", "draft", "archived"]),
                    author=fake.random_element(users),
                    category=fake.random_element(categories),
                )
                for _ in range(to_create)
            ],
            ignore_conflicts=True,
        )
        self.stdout.write(f"  Posts: {to_create} created")

    def _truncate_tables(self):
        from django.db import connection
        with connection.cursor() as cursor:
            cursor.execute("TRUNCATE TABLE app_comment, app_post, app_user, app_category, app_role CASCADE")
        self.stdout.write(self.style.WARNING("  Tables truncated"))
```

```ruby
# ========== Ruby/Rails: db/seeds.rb ==========
# Idempotent seed with progress tracking

require 'faker'

Faker::Config.random = Random.new(42)

puts "🌱 Seeding #{Rails.env} database..."

# Phase 1: Reference data
roles = %w[admin editor member viewer]
roles.each do |name|
  Role.find_or_create_by!(name: name)
end
puts "  Roles: #{roles.size} upserted"

categories = [
  { slug: 'engineering', name: 'Engineering', color: '#3B82F6' },
  { slug: 'design', name: 'Design', color: '#8B5CF6' },
  { slug: 'product', name: 'Product', color: '#10B981' },
]
categories.each do |attrs|
  Category.find_or_initialize_by(slug: attrs[:slug]).update!(attrs)
end
puts "  Categories: #{categories.size} upserted"

# Phase 2: Users
admin = User.find_or_create_by!(email: 'admin@example.com') do |u|
  u.first_name = 'Admin'
  u.last_name = 'User'
  u.role = Role.find_by(name: 'admin')
end

target_users = 50
existing_users = User.count
to_create = [target_users - existing_users, 0].max

if to_create > 0
  users_data = to_create.times.map do
    {
      email: Faker::Internet.unique.email,
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      role_id: Role.find_by(name: 'member').id,
      created_at: Time.current,
      updated_at: Time.current,
    }
  end
  User.insert_all(users_data)
  puts "  Users: #{to_create} created"
else
  puts "  Users: #{existing_users} already exist (target: #{target_users})"
end

# Phase 3: Posts
all_users = User.pluck(:id)
all_categories = Category.pluck(:id)

target_posts = 200
existing_posts = Post.count
to_create = [target_posts - existing_posts, 0].max

if to_create > 0
  posts_data = to_create.times.map do
    title = Faker::Lorem.sentence
    {
      title: title,
      slug: title.parameterize,
      body: Faker::Lorem.paragraphs(number: rand(3..8)).join("\n\n"),
      status: %w[published published published draft archived].sample,
      author_id: all_users.sample,
      category_id: all_categories.sample,
      created_at: Time.current,
      updated_at: Time.current,
    }
  end
  Post.insert_all(posts_data)
  puts "  Posts: #{to_create} created"
end

puts "✅ Seed completed"
```

#### 3b: Environment-Aware Seeding

```
ENVIRONMENT SEEDING STRATEGY:
+-------------------+-------------------+-------------------+-------------------+
| Aspect            | Development       | Staging           | Demo              |
+-------------------+-------------------+-------------------+-------------------+
| Data volume       | Minimal (50-200)  | Moderate (1K-10K) | Realistic (10K+)  |
| User accounts     | Fixed test users  | Anonymized prod   | Curated showcase   |
| Passwords         | Simple (password) | Randomized        | Demo-specific      |
| External IDs      | Fake              | Mapped from prod  | Fake               |
| Images/files      | Placeholders      | Placeholders      | Curated samples    |
| Payment data      | Test cards        | Sandbox accounts  | Visual-only        |
| Emails            | @example.com      | @example.com      | @demo.example.com  |
| Deterministic     | Yes (seed=42)     | No (randomized)   | Yes (curated)      |
| Reset frequency   | Every DB reset    | Weekly            | On demand          |
+-------------------+-------------------+-------------------+-------------------+
```

```typescript
// Environment-aware seed configuration
interface SeedConfig {
  env: 'development' | 'staging' | 'demo';
  users: number;
  posts: number;
  comments: number;
  useDeterministicSeed: boolean;
  fakerSeed: number;
  batchSize: number;
  cleanFirst: boolean;
}

const SEED_CONFIGS: Record<string, SeedConfig> = {
  development: {
    env: 'development',
    users: 50,
    posts: 200,
    comments: 500,
    useDeterministicSeed: true,
    fakerSeed: 42,
    batchSize: 100,
    cleanFirst: false,
  },
  staging: {
    env: 'staging',
    users: 5000,
    posts: 20000,
    comments: 50000,
    useDeterministicSeed: false,
    fakerSeed: 0,
    batchSize: 1000,
    cleanFirst: true,
  },
  demo: {
    env: 'demo',
    users: 200,
    posts: 1000,
    comments: 3000,
    useDeterministicSeed: true,
    fakerSeed: 12345,
    batchSize: 500,
    cleanFirst: true,
  },
};

function getSeedConfig(): SeedConfig {
  const env = process.env.SEED_ENV ?? process.env.NODE_ENV ?? 'development';
  const config = SEED_CONFIGS[env];
  if (!config) {
    throw new Error(`Unknown seed environment: ${env}. Valid: ${Object.keys(SEED_CONFIGS).join(', ')}`);
  }
  return config;
}
```

### Step 4: Relationship Handling and Dependent Records

#### 4a: Dependency Order Resolution

```
SEED DEPENDENCY ORDER:
Seed entities in topological order (parents before children):

  1. Reference data     (roles, categories, tags, statuses)
  2. Independent entities (users, organizations)
  3. First-level deps    (posts -> users, projects -> organizations)
  4. Second-level deps   (comments -> posts + users, memberships -> projects + users)
  5. Many-to-many joins  (post_tags -> posts + tags)
  6. Derived data        (analytics, aggregates, search indexes)

RULE: Never seed a child before its parent exists.
RULE: Collect parent IDs after creation, pass to child seeders.
```

```typescript
// Relationship-aware seeding with collected IDs
async function seedWithRelationships(config: SeedConfig) {
  // Phase 1: Independent entities (no foreign keys)
  const orgIds = await seedOrganizations(config);
  const roleIds = await seedRoles();
  const tagIds = await seedTags();

  // Phase 2: First-level dependencies
  const userIds = await seedUsers(config, { orgIds, roleIds });
  const categoryIds = await seedCategories();

  // Phase 3: Second-level dependencies
  const postIds = await seedPosts(config, { userIds, categoryIds });

  // Phase 4: Many-to-many and deeper dependencies
  await seedPostTags({ postIds, tagIds });
  await seedComments(config, { userIds, postIds });

  // Phase 5: Derived / computed data
  await seedAnalytics({ postIds, userIds });

  return { orgIds, userIds, postIds, tagIds };
}

// Association helper: distribute children across parents realistically
function distributeAcrossParents<T>(
  parentIds: number[],
  count: number,
  distribution: 'uniform' | 'pareto' = 'pareto',
): number[] {
  if (distribution === 'uniform') {
    return Array.from({ length: count }, () =>
      faker.helpers.arrayElement(parentIds),
    );
  }

  // Pareto: 20% of parents get 80% of children (realistic)
  const hotParents = parentIds.slice(0, Math.ceil(parentIds.length * 0.2));
  const coldParents = parentIds.slice(Math.ceil(parentIds.length * 0.2));

  return Array.from({ length: count }, () => {
    if (Math.random() < 0.8 && hotParents.length > 0) {
      return faker.helpers.arrayElement(hotParents);
    }
    return faker.helpers.arrayElement(coldParents.length > 0 ? coldParents : hotParents);
  });
}
```

### Step 5: Large Dataset Seeding

#### 5a: Batch Insert Strategies

```
LARGE DATASET SEEDING RULES:
1. NEVER insert one row at a time for large datasets -- use batch inserts
2. Use createMany / bulk_create / insert_all -- NOT create in a loop
3. Batch size: 500-5000 rows per INSERT (depends on row width)
4. For 100K+ rows: use streaming or raw COPY (PostgreSQL)
5. Disable indexes and constraints during bulk load, rebuild after
6. Use transactions per batch, not one giant transaction
7. Show progress for long-running seeds
```

```typescript
// Batch seeding with progress reporting
async function seedLargeDataset(
  prisma: PrismaClient,
  count: number,
  batchSize: number = 1000,
) {
  const totalBatches = Math.ceil(count / batchSize);
  let created = 0;

  for (let batch = 0; batch < totalBatches; batch++) {
    const size = Math.min(batchSize, count - created);
    const records = Array.from({ length: size }, () => ({
      title: faker.lorem.sentence(),
      body: faker.lorem.paragraphs(3),
      authorId: faker.helpers.arrayElement(userIds),
      createdAt: faker.date.past({ years: 2 }),
    }));

    await prisma.post.createMany({
      data: records,
      skipDuplicates: true,
    });

    created += size;
    const pct = ((created / count) * 100).toFixed(0);
    process.stdout.write(`\r  Posts: ${created}/${count} (${pct}%)`);
  }

  process.stdout.write('\n');
}
```

```typescript
// PostgreSQL COPY for maximum throughput (100K+ rows)
import { pipeline } from 'stream/promises';
import { Readable } from 'stream';
import { from as copyFrom } from 'pg-copy-streams';

async function seedWithCopy(pool: Pool, count: number) {
  const client = await pool.connect();
  try {
    const copyStream = client.query(
      copyFrom(`COPY posts (title, body, author_id, created_at) FROM STDIN WITH (FORMAT csv)`)
    );

    const dataStream = Readable.from(generateCsvRows(count));
    await pipeline(dataStream, copyStream);
    console.log(`  COPY: ${count} rows inserted`);
  } finally {
    client.release();
  }
}

async function* generateCsvRows(count: number) {
  for (let i = 0; i < count; i++) {
    const title = faker.lorem.sentence().replace(/"/g, '""');
    const body = faker.lorem.paragraphs(3).replace(/"/g, '""');
    const authorId = faker.helpers.arrayElement(userIds);
    const createdAt = faker.date.past({ years: 2 }).toISOString();
    yield `"${title}","${body}",${authorId},${createdAt}\n`;
  }
}
```

```python
# Python: bulk insert with progress
from itertools import islice

def seed_large_dataset(session, model_class, count, batch_size=1000):
    """Seed large datasets with batch inserts and progress."""
    created = 0
    while created < count:
        size = min(batch_size, count - created)
        records = [
            model_class(
                title=fake.sentence(),
                body=fake.text(max_nb_chars=2000),
                author_id=random.choice(user_ids),
                created_at=fake.date_time_this_year(),
            )
            for _ in range(size)
        ]
        session.bulk_save_objects(records)
        session.commit()
        created += size
        print(f"\r  {model_class.__name__}: {created}/{count} ({created*100//count}%)", end="")
    print()
```

#### 5b: Performance Optimization for Bulk Seeds

```sql
-- PostgreSQL: optimize bulk seeding
-- BEFORE seeding:
SET session_replication_role = 'replica';    -- Disable FK checks
ALTER TABLE posts DISABLE TRIGGER ALL;       -- Disable triggers

-- Seed data here...

-- AFTER seeding:
ALTER TABLE posts ENABLE TRIGGER ALL;        -- Re-enable triggers
SET session_replication_role = 'origin';     -- Re-enable FK checks
REINDEX TABLE posts;                         -- Rebuild indexes
ANALYZE posts;                               -- Update query planner stats
```

```typescript
// Prisma: raw SQL for bulk optimization
async function optimizedBulkSeed(prisma: PrismaClient) {
  // Disable constraints for speed
  await prisma.$executeRawUnsafe(`SET session_replication_role = 'replica'`);

  try {
    await seedLargeDataset(prisma, 100000, 5000);
  } finally {
    // Always re-enable constraints
    await prisma.$executeRawUnsafe(`SET session_replication_role = 'origin'`);
    // Rebuild indexes and stats
    await prisma.$executeRawUnsafe(`REINDEX TABLE posts`);
    await prisma.$executeRawUnsafe(`ANALYZE posts`);
  }
}
```

### Step 6: Deterministic Seeds for Reproducibility

```
DETERMINISTIC SEEDING RULES:
1. Set a fixed seed on the Faker/random instance: faker.seed(42)
2. Use sequences (factory.Sequence) instead of random IDs
3. Fixed seed = same data every run = reproducible tests
4. Use different seeds for different environments
5. Document the seed value in the seed script
6. For tests: reset the seed before each test suite
```

```typescript
// Deterministic seeding with faker.seed()
import { faker } from '@faker-js/faker';

// Same seed = same sequence of fake data every time
faker.seed(42);

// These will produce IDENTICAL values on every run:
faker.person.firstName();   // Always "Horace" (with seed 42)
faker.person.lastName();    // Always "Homenick"
faker.internet.email();     // Always same email

// Per-test deterministic data
function createTestUser(seed: number): User {
  faker.seed(seed);
  return {
    email: faker.internet.email(),
    firstName: faker.person.firstName(),
    lastName: faker.person.lastName(),
  };
}

// user1 will always be identical across runs
const user1 = createTestUser(1001);
const user2 = createTestUser(1002);
```

```python
# Python: deterministic with Faker seed
from faker import Faker
import random

fake = Faker()
Faker.seed(42)
random.seed(42)

# Same values every run
fake.name()    # Always the same name
fake.email()   # Always the same email

# Per-test isolation in pytest
import pytest

@pytest.fixture(autouse=True)
def reset_faker_seed():
    Faker.seed(42)
    random.seed(42)
    yield
```

```ruby
# Ruby: deterministic seeds
Faker::Config.random = Random.new(42)

# Reset per test (RSpec)
RSpec.configure do |config|
  config.before(:each) do
    Faker::Config.random = Random.new(42)
    Faker::UniqueGenerator.clear
  end
end
```

### Step 7: Data Anonymization for Production Snapshots

#### 7a: Anonymization Strategy

```
PRODUCTION SNAPSHOT ANONYMIZATION:
+---------------------+------------------------+---------------------------+
| Data Type           | Anonymization Method   | Example                   |
+---------------------+------------------------+---------------------------+
| Email               | Faker replacement      | jane@co.com -> user42@x.c |
| Name                | Faker replacement      | Jane Doe -> Alice Smith   |
| Phone               | Faker replacement      | +1-555-1234 -> +1-555-xxx|
| Address             | Faker replacement      | 123 Main St -> 456 Oak Av|
| SSN/Tax ID          | Format-preserving hash | 123-45-6789 -> 987-65-xxxx|
| Credit card         | REMOVE entirely        | Never keep card numbers   |
| Password hash       | Replace with known hash| bcrypt("anonymized")      |
| IP address          | Subnet masking         | 192.168.1.42 -> 192.168.0.0|
| Free text (notes)   | Faker lorem replacement| Actual notes -> lorem text|
| Dates               | Shift by random offset | ±30 days, preserve order  |
| Financial amounts   | Add random noise ±10%  | $100.00 -> $93.42         |
| API keys/tokens     | REMOVE entirely        | Replace with "REDACTED"   |
| URLs                | Domain replacement     | real.com/x -> example.com |
+---------------------+------------------------+---------------------------+

RULES:
1. NEVER copy production data without anonymization
2. Anonymize in a separate database, never in production
3. Test that anonymized data still passes application validation
4. Keep referential integrity (same user ID maps to same fake name)
5. Use deterministic mapping (hash-based) so re-runs produce same output
6. Verify anonymization before granting access to snapshot
```

```typescript
// Anonymization script for PostgreSQL production snapshot
import { faker } from '@faker-js/faker';
import crypto from 'crypto';

// Deterministic anonymization: same input always produces same output
function deterministicFake(input: string, type: 'email' | 'name' | 'phone'): string {
  const hash = crypto.createHash('sha256').update(input + 'salt_v1').digest('hex');
  const seed = parseInt(hash.substring(0, 8), 16);
  faker.seed(seed);

  switch (type) {
    case 'email':
      return faker.internet.email();
    case 'name':
      return faker.person.fullName();
    case 'phone':
      return faker.phone.number();
  }
}

// SQL-based anonymization (run against a COPY of production)
const ANONYMIZATION_QUERIES = [
  // Users: replace PII
  `UPDATE users SET
    email = 'user_' || id || '@example.com',
    first_name = 'User',
    last_name = 'Number' || id,
    phone = NULL,
    avatar_url = NULL,
    password_hash = '$2b$10$anonymized_hash_for_development'
  `,

  // Remove sensitive tokens
  `UPDATE users SET
    api_key = NULL,
    reset_token = NULL,
    verification_token = NULL
  `,

  // Anonymize addresses
  `UPDATE addresses SET
    street = 'Street ' || id,
    city = 'Anytown',
    state = 'CA',
    zip = '00000',
    phone = NULL
  `,

  // Anonymize financial data (add noise, preserve magnitude)
  `UPDATE orders SET
    total = total * (0.9 + random() * 0.2)
  `,

  // Remove free-text PII
  `UPDATE support_tickets SET
    description = 'Anonymized ticket content for ticket #' || id
  `,

  // Remove API integrations
  `DELETE FROM oauth_tokens`,
  `DELETE FROM webhooks`,

  // Shift dates by random offset (preserve relative ordering)
  `UPDATE events SET
    created_at = created_at + (random() * interval '30 days' - interval '15 days')
  `,
];
```

### Step 8: Cleanup Strategies

```
SEED DATA CLEANUP STRATEGIES:
+--------------------+---------------------------+----------------------------------+
| Strategy           | When to Use               | Implementation                   |
+--------------------+---------------------------+----------------------------------+
| Truncate cascade   | Full reset                | TRUNCATE table CASCADE           |
| Delete by marker   | Selective cleanup         | DELETE WHERE source = 'seed'     |
| Transaction rollback| Per-test cleanup          | BEGIN; seed; test; ROLLBACK      |
| Database drop/create| CI pipelines             | DROP DB; CREATE DB; MIGRATE      |
| Snapshot restore   | Fast reset to known state | pg_restore from dump             |
+--------------------+---------------------------+----------------------------------+
```

```typescript
// Cleanup utilities
async function cleanupSeededData(prisma: PrismaClient, strategy: 'truncate' | 'marker' | 'snapshot') {
  switch (strategy) {
    case 'truncate':
      // Nuclear option: truncate all tables in dependency order (children first)
      await prisma.$executeRawUnsafe(`
        TRUNCATE TABLE comments, post_tags, posts, users, categories, roles CASCADE
      `);
      break;

    case 'marker':
      // Surgical: only delete rows tagged as seeded
      await prisma.comment.deleteMany({ where: { source: 'seed' } });
      await prisma.post.deleteMany({ where: { source: 'seed' } });
      await prisma.user.deleteMany({ where: { source: 'seed' } });
      break;

    case 'snapshot':
      // Restore from a known-good snapshot
      // Run externally: pg_restore -d mydb --clean snapshot.dump
      throw new Error('Snapshot restore must be run via CLI: pg_restore -d mydb --clean snapshot.dump');
  }
}

// Per-test cleanup with transaction rollback (fastest)
// Jest/Vitest helper
function withCleanDatabase(fn: (prisma: PrismaClient) => Promise<void>) {
  return async () => {
    await prisma.$transaction(async (tx) => {
      await fn(tx as unknown as PrismaClient);
      throw new RollbackError(); // Force rollback
    }).catch((e) => {
      if (!(e instanceof RollbackError)) throw e;
    });
  };
}

class RollbackError extends Error {
  constructor() { super('Intentional rollback for test cleanup'); }
}
```

```python
# pytest: database cleanup fixtures
import pytest
from sqlalchemy import text

@pytest.fixture
def db_session(engine):
    """Per-test transaction rollback for clean state."""
    connection = engine.connect()
    transaction = connection.begin()
    session = Session(bind=connection)

    yield session

    session.close()
    transaction.rollback()  # Undo all changes from this test
    connection.close()

@pytest.fixture
def seeded_db(db_session):
    """Pre-seeded database for integration tests."""
    from tests.factories import UserFactory, PostFactory
    users = UserFactory.create_batch(10, session=db_session)
    PostFactory.create_batch(50, session=db_session, author=users[0])
    db_session.flush()
    return db_session
```

```ruby
# RSpec: database cleaner configuration
# spec/support/database_cleaner.rb
RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)  # Clean slate at suite start
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
```

### Step 9: Report and Transition

```
+--------------------------------------------------------------+
|  SEED -- <description>                                        |
+--------------------------------------------------------------+
|  Language:        <language>                                   |
|  ORM:            <ORM>                                        |
|  Database:        <engine>                                    |
|  Environment:     <dev | staging | demo>                      |
+--------------------------------------------------------------+
|  Seed infrastructure:                                         |
|  - Factory lib:   <library or "plain functions">              |
|  - Faker lib:     <library>                                   |
|  - Deterministic:  <yes (seed=42) | no>                       |
|  - Idempotent:     <yes | no>                                 |
+--------------------------------------------------------------+
|  Data seeded:                                                 |
|  - <Entity>:       <count> records                            |
|  - <Entity>:       <count> records                            |
|  - Total:          <total> records in <duration>              |
+--------------------------------------------------------------+
|  Files created/modified:                                      |
|  - <file path and purpose>                                    |
+--------------------------------------------------------------+
```

Commit: `"seed: add <description> seeding infrastructure"`

## Key Behaviors

1. **Seeds must be idempotent.** Running the seed script twice must produce the same result as running it once. Use upsert, `skipDuplicates`, `update_or_create`, `find_or_create_by`. Never blindly insert.
2. **Use factories for tests, seed scripts for environments.** Factories generate one-off objects in tests. Seed scripts populate entire environments. They solve different problems. Use both.
3. **Seed in dependency order.** Parents before children. Roles before users. Users before posts. Posts before comments. Violating this causes foreign key errors.
4. **Use deterministic seeds for development.** `faker.seed(42)` means every developer gets the same fake data. This makes bugs reproducible and screenshots consistent.
5. **Batch insert for performance.** One INSERT with 1000 rows is 100x faster than 1000 individual INSERTs. Use `createMany`, `bulk_create`, `insert_all`. Never create in a loop for large datasets.
6. **Tag seeded data.** Add a `source: 'seed'` column or use known email patterns (`@example.com`) so seeded data can be identified and cleaned up selectively.
7. **Environment-specific volumes.** Development needs 50 users. Staging needs 5000. Demo needs curated showcase data. One seed script, multiple configurations.
8. **Never seed production with fake data.** Production seeding is limited to reference data (roles, permissions, system settings). Everything else comes from real users.
9. **Anonymize before snapshotting.** If you copy production data for development, anonymize it first. Replace emails, names, phones, addresses. Remove tokens and credentials entirely.
10. **Clean up after tests.** Transaction rollback is fastest (no I/O). Truncate is nuclear but clean. Delete-by-marker is surgical. Choose based on test isolation requirements.

## Example Usage

### Setting up seed infrastructure for a new project
```
User: /godmode:seed I need to set up database seeding for my Prisma + PostgreSQL project.

Seed: Detecting project setup...

Found: Prisma 5.x, PostgreSQL, no existing seed infrastructure.

I'll create:
1. prisma/seed.ts with idempotent upserts
2. src/factories/ with fishery + @faker-js/faker factories
3. Environment configs for dev/staging/demo
4. package.json seed command

Setting faker.seed(42) for deterministic development data.
Seeding: roles -> categories -> users (50) -> posts (200) -> comments (500)
```

### Generating large test datasets
```
User: /godmode:seed I need 100K realistic orders for performance testing.

Seed: For 100K+ rows, switching to batch + COPY strategy:

1. Batch size: 5000 rows per INSERT
2. Disable FK constraints during load
3. Streaming CSV generation for COPY
4. Rebuild indexes after load
5. ANALYZE for query planner

Estimated time: ~30 seconds for 100K orders + 500K order items.
```

### Anonymizing production data
```
User: /godmode:seed I need a copy of production for local dev. How do I anonymize it?

Seed: Production snapshot anonymization plan:

1. pg_dump production -> staging_snapshot.dump
2. pg_restore into isolated database
3. Run anonymization queries:
   - Users: emails -> user_N@example.com, names -> faker
   - Payments: amounts -> ±10% noise, card numbers -> REMOVED
   - Tokens/keys: DELETE entirely
4. Verify: no real emails, no real names, no credentials
5. pg_dump anonymized -> dev_snapshot.dump
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Interactive seed setup workflow |
| `--factory` | Set up factory pattern (fishery, factory_boy, FactoryBot, Bogus) |
| `--faker` | Configure fake data generation |
| `--script` | Create idempotent seed script for the project |
| `--env` | Configure environment-specific seeding (dev/staging/demo) |
| `--large` | Optimize for large dataset seeding (batch, COPY, streaming) |
| `--deterministic` | Set up reproducible seeds with fixed faker seed |
| `--anonymize` | Create production data anonymization pipeline |
| `--cleanup` | Configure seed data cleanup strategies |
| `--fixtures` | Set up test fixtures for the test framework |
| `--relationships` | Handle complex association seeding |
| `--report` | Generate seed infrastructure report |

## HARD RULES

1. NEVER seed production databases with development data. Environment guards (`if (env === 'production') throw`) must exist at the top of every seed script.
2. ALWAYS use a fixed faker seed (e.g., `faker.seed(42)`) for deterministic output. Without it, every developer gets different data, screenshots differ, and bugs become unreproducible.
3. NEVER use auto-increment IDs as stable references in seed scripts. IDs change between runs. Use slugs, emails, or external identifiers for upsert matching.
4. ALWAYS use batch inserts (`createMany`, `bulk_create`, `insert_all`). Single-row inserts in a loop turn a 2-second seed into a 5-minute seed.
5. NEVER include real user data (names, emails, addresses) in seed files. Use faker-generated data. Seed files are committed to version control and are not private.
6. ALWAYS make seeds idempotent with upsert logic. Running the seed twice must not create duplicate data or fail on unique constraints.
7. NEVER seed without wrapping in a transaction. A partial seed (half the users, none of the posts) is worse than no seed. Atomic commit or full rollback.
8. ALWAYS provide a `--reset` flag that truncates tables before seeding. Developers need a clean-slate option without manually dropping the database.

## Anti-Patterns

- **Do NOT insert one row at a time in a loop.** Use batch inserts (`createMany`, `bulk_create`, `insert_all`). Inserting 10,000 rows one at a time takes minutes. Batch inserting takes seconds.
- **Do NOT use auto-increment IDs as stable identifiers in seeds.** IDs change between runs. Use slugs, emails, or external identifiers for upsert matching.
- **Do NOT seed without a fixed faker seed in development.** Without `faker.seed(42)`, every developer gets different data. Bugs become unreproducible. Screenshots become inconsistent.
- **Do NOT copy production data without anonymizing it.** Real emails, real names, real payment info in development databases violate privacy laws and create security risks.
- **Do NOT seed children before parents.** Foreign key constraints will reject the insert. Always seed in dependency order: reference data, then independent entities, then dependent entities.
- **Do NOT put seed logic in migrations.** Migrations change schema. Seeds populate data. Mixing them makes migrations non-reversible and seeds non-repeatable.
- **Do NOT use random data for demo environments.** Demo environments need curated, realistic-looking data that tells a story. Random lorem ipsum looks unprofessional.
- **Do NOT skip cleanup in tests.** Leftover seed data from one test pollutes the next test. Use transaction rollback, truncate, or delete-by-marker after every test.
- **Do NOT seed the same data in every environment.** Development needs 50 users. Staging needs 5000. Production needs zero fake users. Use environment-specific configs.
- **Do NOT ignore foreign key constraints during seeding.** If your seed script fails on FK constraints, your dependency order is wrong. Fix the order instead of disabling constraints (except for bulk COPY operations where you re-enable immediately after).
