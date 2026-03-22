# Jest & Vitest Mastery Guide

Comprehensive reference for JavaScript/TypeScript unit and integration testing with Jest and Vitest.

---

## Table of Contents

1. [Configuration](#configuration)
2. [Matchers](#matchers)
3. [Mocking](#mocking)
4. [Snapshot Testing](#snapshot-testing)
5. [Timers](#timers)
6. [Async Testing](#async-testing)
7. [Performance Optimization](#performance-optimization)
8. [Migration from Jest to Vitest](#migration-from-jest-to-vitest)

---

## Configuration

### Jest Configuration

```js
// jest.config.js
/** @type {import('jest').Config} */
module.exports = {
  // Environment
  testEnvironment: 'jsdom',             // or 'node' for backend
  testEnvironmentOptions: {
    url: 'http://localhost:3000',
  },

  // File patterns
  testMatch: ['**/__tests__/**/*.[jt]s?(x)', '**/?(*.)+(spec|test).[jt]s?(x)'],
  testPathIgnorePatterns: ['/node_modules/', '/dist/'],

  // Transforms
  transform: {
    '^.+\\.tsx?$': 'ts-jest',           // TypeScript support
    '^.+\\.jsx?$': 'babel-jest',        // Babel support
  },
  transformIgnorePatterns: ['/node_modules/(?!(@scope/pkg)/)'],

  // Module resolution
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '\\.(css|less|scss)$': 'identity-obj-proxy',
    '\\.(jpg|png|svg)$': '<rootDir>/__mocks__/fileMock.js',
  },
  moduleDirectories: ['node_modules', 'src'],

  // Coverage
  collectCoverageFrom: [
    'src/**/*.{ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/index.ts',
  ],
  coverageThreshold: {
    global: { branches: 80, functions: 80, lines: 80, statements: 80 },
  },

  // Setup
  setupFilesAfterSetup: ['<rootDir>/jest.setup.ts'],
  globalSetup: '<rootDir>/jest.globalSetup.ts',
  globalTeardown: '<rootDir>/jest.globalTeardown.ts',

  // Performance
  maxWorkers: '50%',
  cache: true,
  cacheDirectory: '/tmp/jest-cache',
};
```

### Vitest Configuration

```ts
// vitest.config.ts
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    // Environment
    environment: 'jsdom',               // or 'happy-dom' (faster)
    environmentOptions: {
      jsdom: { url: 'http://localhost:3000' },
    },

    // Globals (Jest-compatible API without imports)
    globals: true,

    // File patterns
    include: ['src/**/*.{test,spec}.{ts,tsx}'],
    exclude: ['node_modules', 'dist', 'e2e'],

    // Setup
    setupFiles: ['./vitest.setup.ts'],
    globalSetup: ['./vitest.globalSetup.ts'],

    // Coverage (via v8 or istanbul)
    coverage: {
      provider: 'v8',                   // or 'istanbul'
      reporter: ['text', 'json', 'html', 'lcov'],
      include: ['src/**/*.{ts,tsx}'],
      exclude: ['src/**/*.d.ts', 'src/**/*.test.*'],
      thresholds: {
        branches: 80,
        functions: 80,
        lines: 80,
        statements: 80,
      },
    },

    // Aliases (inherited from Vite resolve.alias)
    alias: {
      '@': '/src',
    },

    // Performance
    pool: 'threads',                    // 'threads' | 'forks' | 'vmThreads'
    poolOptions: {
      threads: { maxThreads: 4, minThreads: 1 },
    },

    // Reporter
    reporters: ['verbose', 'json'],
    outputFile: { json: './test-results.json' },
  },
});
```

### TypeScript Setup for Vitest Globals

```json
// tsconfig.json
{
  "compilerOptions": {
    "types": ["vitest/globals"]
  }
}
```

---

## Matchers

### Common Matchers (Jest & Vitest)

```ts
// Equality
expect(value).toBe(primitive);                  // Object.is strict equality
expect(value).toEqual(object);                  // Deep equality (ignores undefined props)
expect(value).toStrictEqual(object);            // Deep equality (checks undefined props, array holes)
expect(value).not.toBe(other);                  // Negation

// Truthiness
expect(value).toBeTruthy();
expect(value).toBeFalsy();
expect(value).toBeNull();
expect(value).toBeUndefined();
expect(value).toBeDefined();
expect(value).toBeNaN();

// Numbers
expect(num).toBeGreaterThan(3);
expect(num).toBeGreaterThanOrEqual(3);
expect(num).toBeLessThan(5);
expect(num).toBeCloseTo(0.3, 5);               // Floating-point precision

// Strings
expect(str).toMatch(/regex/);
expect(str).toMatch('substring');
expect(str).toContain('substring');
expect(str).toHaveLength(5);

// Arrays & Iterables
expect(arr).toContain(item);                    // Uses Object.is
expect(arr).toContainEqual(item);               // Uses deep equality
expect(arr).toHaveLength(3);
expect(arr).toEqual(expect.arrayContaining([1, 2]));

// Objects
expect(obj).toHaveProperty('key');
expect(obj).toHaveProperty('nested.key', value);
expect(obj).toMatchObject({ subset: true });
expect(obj).toEqual(expect.objectContaining({ key: value }));

// Exceptions
expect(() => fn()).toThrow();
expect(() => fn()).toThrow('message');
expect(() => fn()).toThrow(ErrorType);
expect(() => fn()).toThrow(/regex/);

// Types
expect(value).toBeInstanceOf(Class);
expect(typeof value).toBe('string');
```

### Asymmetric Matchers

```ts
expect(obj).toEqual({
  id: expect.any(Number),
  name: expect.any(String),
  email: expect.stringContaining('@'),
  tags: expect.arrayContaining(['important']),
  metadata: expect.objectContaining({ version: 2 }),
  timestamp: expect.stringMatching(/^\d{4}-\d{2}-\d{2}$/),
  optional: expect.anything(),                  // Anything except null/undefined
});
```

### Custom Matchers

```ts
// Jest
expect.extend({
  toBeWithinRange(received: number, floor: number, ceiling: number) {
    const pass = received >= floor && received <= ceiling;
    return {
      pass,
      message: () =>
        `expected ${received} ${pass ? 'not ' : ''}to be within range ${floor} - ${ceiling}`,
    };
  },
});

// TypeScript declaration
declare global {
  namespace jest {
    interface Matchers<R> {
      toBeWithinRange(floor: number, ceiling: number): R;
    }
  }
}

// Usage
expect(100).toBeWithinRange(90, 110);
```

```ts
// Vitest custom matcher
import { expect } from 'vitest';

expect.extend({
  toBeWithinRange(received: number, floor: number, ceiling: number) {
    const pass = received >= floor && received <= ceiling;
    return {
      pass,
      message: () =>
        `expected ${received} ${pass ? 'not ' : ''}to be within range ${floor} - ${ceiling}`,
    };
  },
});

// TypeScript: vitest.d.ts
import 'vitest';
declare module 'vitest' {
  interface Assertion<T = any> {
    toBeWithinRange(floor: number, ceiling: number): T;
  }
}
```

---

## Mocking

### Function Mocks

```ts
// Create mock function
const mockFn = jest.fn();                       // Jest
const mockFn = vi.fn();                         // Vitest

// With implementation
const mockFn = jest.fn((x: number) => x * 2);
const mockFn = vi.fn((x: number) => x * 2);

// Chain return values
mockFn
  .mockReturnValueOnce(10)
  .mockReturnValueOnce(20)
  .mockReturnValue(99);                         // Default after once calls

// Async return values
mockFn.mockResolvedValue({ data: 'ok' });
mockFn.mockResolvedValueOnce({ data: 'first' });
mockFn.mockRejectedValue(new Error('fail'));

// Assertions
expect(mockFn).toHaveBeenCalled();
expect(mockFn).toHaveBeenCalledTimes(3);
expect(mockFn).toHaveBeenCalledWith('arg1', 'arg2');
expect(mockFn).toHaveBeenLastCalledWith('arg');
expect(mockFn).toHaveBeenNthCalledWith(1, 'first-call-arg');
expect(mockFn).toHaveReturnedWith(value);

// Access call history
mockFn.mock.calls;                              // [['arg1'], ['arg2']]
mockFn.mock.results;                            // [{ type: 'return', value: 10 }]
mockFn.mock.instances;                          // 'this' context for each call

// Reset
mockFn.mockClear();                             // Clear calls/results history
mockFn.mockReset();                             // Clear + remove implementation
mockFn.mockRestore();                           // Reset to original (spyOn only)
```

### Module Mocking

```ts
// --- Jest ---

// Auto-mock entire module
jest.mock('./utils');

// Manual mock with factory
jest.mock('./api', () => ({
  fetchUser: jest.fn().mockResolvedValue({ id: 1, name: 'Test' }),
  fetchPosts: jest.fn().mockResolvedValue([]),
}));

// Partial mock (keep some real implementations)
jest.mock('./utils', () => ({
  ...jest.requireActual('./utils'),
  formatDate: jest.fn().mockReturnValue('2025-01-01'),
}));

// ES module mock
jest.unstable_mockModule('./esm-module', () => ({
  default: jest.fn(),
  namedExport: jest.fn(),
}));

// --- Vitest ---

// Auto-mock entire module
vi.mock('./utils');

// Manual mock with factory
vi.mock('./api', () => ({
  fetchUser: vi.fn().mockResolvedValue({ id: 1, name: 'Test' }),
  fetchPosts: vi.fn().mockResolvedValue([]),
}));

// Partial mock
vi.mock('./utils', async () => {
  const actual = await vi.importActual('./utils');
  return {
    ...actual,
    formatDate: vi.fn().mockReturnValue('2025-01-01'),
  };
});

// Dynamic import mock (ESM-native)
vi.mock('./module', async (importOriginal) => {
  const mod = await importOriginal<typeof import('./module')>();
  return { ...mod, someFunc: vi.fn() };
});
```

### Spy on Methods

```ts
// Jest
const spy = jest.spyOn(object, 'method');
const spy = jest.spyOn(object, 'method').mockReturnValue('mocked');
const spy = jest.spyOn(object, 'getter', 'get').mockReturnValue('value');

// Vitest
const spy = vi.spyOn(object, 'method');
const spy = vi.spyOn(object, 'method').mockReturnValue('mocked');
const spy = vi.spyOn(object, 'getter', 'get').mockReturnValue('value');

// Restore original implementation
spy.mockRestore();
```

### Mocking Classes

```ts
jest.mock('./Database', () => {
  return jest.fn().mockImplementation(() => ({
    connect: jest.fn().mockResolvedValue(true),
    query: jest.fn().mockResolvedValue([]),
    disconnect: jest.fn(),
  }));
});

// Verify constructor calls
const Database = require('./Database');
expect(Database).toHaveBeenCalledWith('connection-string');
```

### Mocking Global Objects

```ts
// Jest
const originalFetch = global.fetch;
beforeEach(() => {
  global.fetch = jest.fn().mockResolvedValue({
    ok: true,
    json: () => Promise.resolve({ data: 'test' }),
  });
});
afterEach(() => {
  global.fetch = originalFetch;
});

// Vitest (stubGlobal)
beforeEach(() => {
  vi.stubGlobal('fetch', vi.fn().mockResolvedValue({
    ok: true,
    json: () => Promise.resolve({ data: 'test' }),
  }));
});
afterEach(() => {
  vi.unstubAllGlobals();
});
```

---

## Snapshot Testing

### Basic Snapshots

```ts
// Inline snapshots (auto-filled by test runner)
expect(result).toMatchInlineSnapshot();

// File-based snapshots (__snapshots__/*.snap)
expect(result).toMatchSnapshot();

// Named snapshots
expect(result).toMatchSnapshot('descriptive name');
```

### Snapshot Best Practices

```ts
// Snapshot serializers for custom types
expect.addSnapshotSerializer({
  test: (val) => val instanceof Date,
  serialize: (val) => `Date<${val.toISOString()}>`,
});

// Property matchers for dynamic values
expect(user).toMatchSnapshot({
  id: expect.any(Number),
  createdAt: expect.any(Date),
  token: expect.any(String),
});

// Update snapshots: jest --updateSnapshot / vitest --update
```

### Snapshot with React Components

```tsx
import { render } from '@testing-library/react';

test('renders button correctly', () => {
  const { container } = render(<Button variant="primary">Click me</Button>);
  expect(container.firstChild).toMatchSnapshot();
});

// Prefer inline snapshots for small components
test('renders label', () => {
  const { container } = render(<Label>Name</Label>);
  expect(container.innerHTML).toMatchInlineSnapshot(
    `"<label class=\\"label\\">Name</label>"`
  );
});
```

---

## Timers

### Fake Timers

```ts
// --- Jest ---
beforeEach(() => {
  jest.useFakeTimers();
});

afterEach(() => {
  jest.useRealTimers();
});

test('debounce calls function after delay', () => {
  const fn = jest.fn();
  const debounced = debounce(fn, 300);

  debounced();
  expect(fn).not.toHaveBeenCalled();

  jest.advanceTimersByTime(300);
  expect(fn).toHaveBeenCalledTimes(1);
});

// Advance all timers
jest.runAllTimers();                            // Run all pending timers
jest.runOnlyPendingTimers();                    // Run only currently pending
jest.advanceTimersByTime(1000);                 // Advance by ms
jest.advanceTimersToNextTimer();                // Jump to next timer

// --- Vitest ---
beforeEach(() => {
  vi.useFakeTimers();
});

afterEach(() => {
  vi.useRealTimers();
});

test('interval fires repeatedly', () => {
  const fn = vi.fn();
  setInterval(fn, 1000);

  vi.advanceTimersByTime(3000);
  expect(fn).toHaveBeenCalledTimes(3);
});

// Fake Date
vi.setSystemTime(new Date('2025-06-15T12:00:00Z'));
expect(new Date().toISOString()).toBe('2025-06-15T12:00:00.000Z');
vi.useRealTimers();   // Restores real Date as well
```

### Timer Configuration

```ts
// Jest: selective faking
jest.useFakeTimers({
  doNotFake: ['nextTick', 'setImmediate'],
  timerLimit: 1000,                             // Max timers to prevent infinite loops
  now: new Date('2025-01-01'),                  // Fake Date.now
});

// Vitest: selective faking
vi.useFakeTimers({
  toFake: ['setTimeout', 'setInterval', 'Date'],
  now: new Date('2025-01-01'),
});
```

---

## Async Testing

### Promises

```ts
// Return the promise
test('fetches data', () => {
  return fetchData().then((data) => {
    expect(data).toBe('expected');
  });
});

// Async/await (preferred)
test('fetches data', async () => {
  const data = await fetchData();
  expect(data).toBe('expected');
});

// Rejected promises
test('fails with error', async () => {
  await expect(fetchBadData()).rejects.toThrow('Not found');
  await expect(fetchBadData()).rejects.toEqual(new Error('Not found'));
});

// Resolved promises
test('resolves correctly', async () => {
  await expect(fetchData()).resolves.toBe('expected');
  await expect(fetchData()).resolves.toMatchObject({ status: 'ok' });
});
```

### Testing Event Emitters and Callbacks

```ts
test('emits event', (done) => {
  const emitter = new MyEmitter();
  emitter.on('data', (value) => {
    try {
      expect(value).toBe('hello');
      done();
    } catch (error) {
      done(error);
    }
  });
  emitter.emit('data', 'hello');
});

// Modern approach with promises
test('emits event', async () => {
  const emitter = new MyEmitter();
  const promise = new Promise((resolve) => emitter.on('data', resolve));
  emitter.emit('data', 'hello');
  await expect(promise).resolves.toBe('hello');
});
```

### Waiting for State Changes

```ts
import { waitFor } from '@testing-library/react';

test('updates state after fetch', async () => {
  render(<UserProfile userId={1} />);

  await waitFor(() => {
    expect(screen.getByText('John Doe')).toBeInTheDocument();
  }, { timeout: 3000 });
});

// Vitest: vi.waitFor (built-in)
test('retries until condition passes', async () => {
  await vi.waitFor(() => {
    expect(getStatus()).toBe('ready');
  }, { timeout: 5000, interval: 100 });
});
```

### Concurrent Tests (Vitest)

```ts
// Run tests in the same file concurrently
describe.concurrent('math operations', () => {
  it('adds numbers', async () => {
    expect(add(1, 2)).toBe(3);
  });

  it('multiplies numbers', async () => {
    expect(multiply(2, 3)).toBe(6);
  });
});
```

---

## Performance Optimization

### Jest Optimization

```bash
# Shard tests across CI nodes
jest --shard=1/3          # Node 1 of 3
jest --shard=2/3          # Node 2 of 3
jest --shard=3/3          # Node 3 of 3

# Run only changed files
jest --onlyChanged        # Files changed since last commit
jest --changedSince=main  # Files changed since branch point

# Worker configuration
jest --maxWorkers=50%     # Use half of available CPUs
jest --maxWorkers=4       # Explicit worker count
jest --runInBand          # Single-threaded (useful for debugging)

# Cache optimization
jest --clearCache         # Clear the transform cache
jest --cache              # Enable cache (default)

# Bail early
jest --bail=3             # Stop after 3 failures
```

```js
// jest.config.js optimizations
module.exports = {
  // Use faster transformer
  transform: {
    '^.+\\.tsx?$': ['@swc/jest'],       // SWC is 20-70x faster than ts-jest
  },

  // Limit module resolution
  modulePathIgnorePatterns: ['<rootDir>/dist/'],
  watchPathIgnorePatterns: ['<rootDir>/node_modules/'],

  // Parallel test files
  maxWorkers: '50%',
};
```

### Vitest Optimization

```bash
# Shard tests
vitest --shard=1/3
vitest --shard=2/3

# Run related tests only
vitest related src/utils.ts

# Run by file pattern
vitest run src/components/

# Reporter for CI
vitest --reporter=json --outputFile=results.json
```

```ts
// vitest.config.ts optimizations
export default defineConfig({
  test: {
    // Thread pool (fastest for CPU-bound)
    pool: 'threads',
    poolOptions: {
      threads: {
        maxThreads: 8,
        minThreads: 2,
        useAtomics: true,               // Better thread synchronization
      },
    },

    // Fork pool (better isolation, slightly slower)
    // pool: 'forks',

    // Isolate test files (disable for speed, enable for safety)
    isolate: false,                     // Faster but shares module state

    // Deps optimization
    deps: {
      optimizer: {
        web: { include: ['@testing-library/react'] },
      },
    },

    // Sequence for faster feedback
    sequence: {
      shuffle: true,                    // Detect order dependencies
    },
  },
});
```

### CI Pipeline Examples

```yaml
# GitHub Actions: Jest with sharding
jobs:
  test:
    strategy:
      matrix:
        shard: [1, 2, 3, 4]
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npx jest --shard=${{ matrix.shard }}/4 --ci --coverage
      - uses: actions/upload-artifact@v4
        with:
          name: coverage-${{ matrix.shard }}
          path: coverage/

  merge-coverage:
    needs: test
    steps:
      - uses: actions/download-artifact@v4
      - run: npx nyc merge coverage/ merged-coverage.json
      - run: npx nyc report --reporter=lcov --temp-dir=merged-coverage.json
```

---

## Migration from Jest to Vitest

### Step-by-Step Migration

**1. Install Vitest**

```bash
npm install -D vitest @vitest/coverage-v8
# For UI testing
npm install -D @vitest/ui
# For React
npm install -D happy-dom   # or jsdom
```

**2. Create vitest.config.ts**

```ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,                      // Enable Jest-compatible globals
    environment: 'happy-dom',
    setupFiles: ['./src/test/setup.ts'],
    css: true,
  },
});
```

**3. Update package.json scripts**

```json
{
  "scripts": {
    "test": "vitest",
    "test:run": "vitest run",
    "test:coverage": "vitest run --coverage",
    "test:ui": "vitest --ui"
  }
}
```

**4. API Mapping Reference**

| Jest | Vitest |
|------|--------|
| `jest.fn()` | `vi.fn()` |
| `jest.mock()` | `vi.mock()` |
| `jest.spyOn()` | `vi.spyOn()` |
| `jest.useFakeTimers()` | `vi.useFakeTimers()` |
| `jest.useRealTimers()` | `vi.useRealTimers()` |
| `jest.clearAllMocks()` | `vi.clearAllMocks()` |
| `jest.resetAllMocks()` | `vi.resetAllMocks()` |
| `jest.restoreAllMocks()` | `vi.restoreAllMocks()` |
| `jest.requireActual()` | `vi.importActual()` |
| `jest.requireMock()` | `vi.importMock()` |
| `jest.advanceTimersByTime()` | `vi.advanceTimersByTime()` |
| `jest.runAllTimers()` | `vi.runAllTimers()` |

**5. Automated Codemod**

```bash
# Use codemod to replace jest.* with vi.*
npx vitest-codemod --jest-to-vitest ./src
```

**6. Common Migration Gotchas**

```ts
// Jest: mock hoisting is automatic
jest.mock('./module');    // Hoisted to top of file

// Vitest: mock hoisting is also automatic with vi.mock()
vi.mock('./module');      // Also hoisted

// BUT: vi.mock factory runs in a different scope
// This DOES NOT work:
const mockValue = 'test';
vi.mock('./module', () => ({
  getValue: () => mockValue,  // Error: mockValue is not defined
}));

// This DOES work (use vi.hoisted):
const { mockValue } = vi.hoisted(() => ({
  mockValue: 'test',
}));
vi.mock('./module', () => ({
  getValue: () => mockValue,  // Works
}));
```

```ts
// Jest: module-scoped mock state
// Vitest: each test file is isolated by default (can be disabled)

// Jest: done callback for async
test('async', (done) => { /* ... */ done(); });
// Vitest: same syntax supported

// Jest: manual mocks in __mocks__/ directory
// Vitest: same convention supported

// Jest: moduleNameMapper in config
// Vitest: resolve.alias in vite config (shared with app)
```

### Running Both During Migration

```json
{
  "scripts": {
    "test:jest": "jest --config jest.config.js",
    "test:vitest": "vitest run",
    "test": "npm run test:vitest"
  }
}
```

---

## Quick Reference Card

```
Jest                          Vitest
jest.config.js                vitest.config.ts
__mocks__/                    __mocks__/ (same)
jest.setup.ts                 setupFiles: [...]
jest --watch                  vitest (watch by default)
jest --watchAll               vitest --watch
jest --run                    vitest run
jest --coverage               vitest --coverage
jest --verbose                vitest --reporter=verbose
jest --bail                   vitest --bail
jest --shard=1/N              vitest --shard=1/N
@jest/globals                 vitest (or globals: true)
ts-jest / babel-jest          Native (Vite transforms)
jest-environment-jsdom        environment: 'jsdom'
```
