# Cypress Mastery Guide

Comprehensive reference for end-to-end and component testing with Cypress, covering custom commands, fixtures, network stubbing, and CI/CD integration.

---

## Table of Contents

1. [Configuration & Setup](#configuration--setup)
2. [E2E Testing](#e2e-testing)
3. [Component Testing](#component-testing)
4. [Custom Commands](#custom-commands)
5. [Fixtures](#fixtures)
6. [Network Stubbing](#network-stubbing)
7. [Time Travel & Debugging](#time-travel--debugging)
8. [CI/CD Integration](#cicd-integration)

---

## Configuration & Setup

### Basic Configuration

```ts
// cypress.config.ts
import { defineConfig } from 'cypress';

export default defineConfig({
  // E2E testing configuration
  e2e: {
    baseUrl: 'http://localhost:3000',
    specPattern: 'cypress/e2e/**/*.cy.{js,jsx,ts,tsx}',
    supportFile: 'cypress/support/e2e.ts',
    viewportWidth: 1280,
    viewportHeight: 720,
    video: false,
    screenshotOnRunFailure: true,
    defaultCommandTimeout: 10000,
    requestTimeout: 10000,
    responseTimeout: 30000,
    pageLoadTimeout: 60000,

    // Retry configuration
    retries: {
      runMode: 2,           // CI retries
      openMode: 0,          // Interactive mode retries
    },

    // Environment variables
    env: {
      apiUrl: 'http://localhost:3000/api',
      coverage: false,
    },

    setupNodeEvents(on, config) {
      // Register plugins
      require('@cypress/code-coverage/task')(on, config);
      return config;
    },
  },

  // Component testing configuration
  component: {
    devServer: {
      framework: 'react',           // 'react' | 'vue' | 'angular' | 'svelte'
      bundler: 'vite',              // 'vite' | 'webpack'
    },
    specPattern: 'src/**/*.cy.{js,jsx,ts,tsx}',
    supportFile: 'cypress/support/component.ts',
  },
});
```

### Project Structure

```
cypress/
├── downloads/                  # Downloaded files
├── e2e/                        # E2E test specs
│   ├── auth/
│   │   ├── login.cy.ts
│   │   └── register.cy.ts
│   ├── dashboard/
│   │   └── dashboard.cy.ts
│   └── settings/
│       └── profile.cy.ts
├── fixtures/                   # Static test data
│   ├── users.json
│   ├── products.json
│   └── api-responses/
│       ├── login-success.json
│       └── login-error.json
├── support/
│   ├── commands.ts             # Custom commands
│   ├── e2e.ts                  # E2E support file
│   ├── component.ts            # Component support file
│   └── component-index.html    # Component test HTML
├── screenshots/                # Auto-generated screenshots
└── videos/                     # Auto-generated videos
```

### TypeScript Support

```json
// cypress/tsconfig.json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "types": ["cypress", "node"],
    "moduleResolution": "bundler",
    "strict": true
  },
  "include": ["**/*.ts", "../src/**/*.cy.ts"]
}
```

---

## E2E Testing

### Basic Test Structure

```ts
// cypress/e2e/auth/login.cy.ts
describe('Login', () => {
  beforeEach(() => {
    cy.visit('/login');
  });

  it('should login with valid credentials', () => {
    cy.get('[data-testid="email-input"]').type('user@example.com');
    cy.get('[data-testid="password-input"]').type('password123');
    cy.get('[data-testid="login-button"]').click();

    cy.url().should('include', '/dashboard');
    cy.contains('Welcome back').should('be.visible');
  });

  it('should show error for invalid credentials', () => {
    cy.get('[data-testid="email-input"]').type('user@example.com');
    cy.get('[data-testid="password-input"]').type('wrong-password');
    cy.get('[data-testid="login-button"]').click();

    cy.get('[data-testid="error-message"]')
      .should('be.visible')
      .and('contain', 'Invalid email or password');
    cy.url().should('include', '/login');
  });

  it('should validate required fields', () => {
    cy.get('[data-testid="login-button"]').click();
    cy.get('[data-testid="email-error"]').should('contain', 'Email is required');
    cy.get('[data-testid="password-error"]').should('contain', 'Password is required');
  });
});
```

### Querying Elements

```ts
// By test ID (recommended)
cy.get('[data-testid="submit-button"]');
cy.get('[data-cy="submit-button"]');

// By text content
cy.contains('Submit');
cy.contains('button', 'Submit');        // Scoped to button elements

// By CSS selector
cy.get('.btn-primary');
cy.get('#main-content');
cy.get('input[name="email"]');

// By role (accessibility)
cy.get('[role="dialog"]');
cy.get('[aria-label="Close"]');

// Chaining and scoping
cy.get('[data-testid="user-list"]')
  .find('li')
  .should('have.length', 3)
  .first()
  .should('contain', 'Alice');

// Within (scope queries to an element)
cy.get('[data-testid="sidebar"]').within(() => {
  cy.get('a').should('have.length', 5);
  cy.contains('Settings').click();
});

// Aliases
cy.get('[data-testid="user-card"]').as('userCard');
cy.get('@userCard').should('be.visible');
```

### Assertions

```ts
// Should assertions (chainable)
cy.get('input').should('have.value', 'Hello');
cy.get('button').should('be.disabled');
cy.get('.error').should('not.exist');
cy.get('.modal').should('be.visible');
cy.get('.list').should('have.length', 3);
cy.get('a').should('have.attr', 'href', '/about');
cy.get('div').should('have.class', 'active');
cy.get('p').should('contain.text', 'Welcome');
cy.get('input').should('have.css', 'color', 'rgb(255, 0, 0)');

// Multiple assertions
cy.get('[data-testid="user-card"]')
  .should('be.visible')
  .and('contain', 'Alice')
  .and('have.class', 'active');

// Callback assertions
cy.get('[data-testid="price"]').should(($el) => {
  const price = parseFloat($el.text().replace('$', ''));
  expect(price).to.be.greaterThan(0);
  expect(price).to.be.lessThan(1000);
});

// Retry until assertion passes
cy.get('[data-testid="loading"]').should('not.exist');
cy.get('[data-testid="data-table"]').should('be.visible');
```

### Working with Forms

```ts
// Text input
cy.get('input[name="name"]').type('John Doe');
cy.get('input[name="name"]').clear().type('Jane Doe');

// Special characters
cy.get('input').type('{enter}');
cy.get('input').type('{selectall}{backspace}');
cy.get('input').type('{ctrl+a}');
cy.get('textarea').type('Line 1{enter}Line 2');

// Select dropdown
cy.get('select[name="country"]').select('United States');
cy.get('select').select(['Option 1', 'Option 3']);    // Multi-select

// Checkboxes and radio buttons
cy.get('[type="checkbox"]').check();
cy.get('[type="checkbox"]').uncheck();
cy.get('[type="radio"][value="option1"]').check();

// File upload
cy.get('input[type="file"]').selectFile('cypress/fixtures/image.png');
cy.get('input[type="file"]').selectFile([
  'cypress/fixtures/file1.pdf',
  'cypress/fixtures/file2.pdf',
]);

// Drag and drop
cy.get('[data-testid="draggable"]').selectFile('fixture.png', {
  action: 'drag-drop',
});

// Focus and blur
cy.get('input').focus();
cy.get('input').blur();
```

### Navigation and URL

```ts
// Navigation
cy.visit('/login');
cy.visit('/login', { timeout: 30000 });
cy.visit('/login', {
  headers: { 'Accept-Language': 'en-US' },
  qs: { redirect: '/dashboard' },
});

// URL assertions
cy.url().should('include', '/dashboard');
cy.url().should('eq', 'http://localhost:3000/dashboard');
cy.location('pathname').should('eq', '/dashboard');
cy.location('search').should('include', 'page=1');
cy.location('hash').should('eq', '#section-1');

// Back and forward
cy.go('back');
cy.go('forward');
cy.go(-2);                                      // Go back 2 pages

// Reload
cy.reload();
cy.reload(true);                                 // Hard reload (clear cache)
```

---

## Component Testing

### React Component Testing

```tsx
// src/components/Button.cy.tsx
import Button from './Button';

describe('Button Component', () => {
  it('renders with text', () => {
    cy.mount(<Button>Click me</Button>);
    cy.get('button').should('contain', 'Click me');
  });

  it('handles click events', () => {
    const onClick = cy.stub().as('clickHandler');
    cy.mount(<Button onClick={onClick}>Click me</Button>);
    cy.get('button').click();
    cy.get('@clickHandler').should('have.been.calledOnce');
  });

  it('renders different variants', () => {
    cy.mount(<Button variant="primary">Primary</Button>);
    cy.get('button').should('have.class', 'btn-primary');

    cy.mount(<Button variant="secondary">Secondary</Button>);
    cy.get('button').should('have.class', 'btn-secondary');
  });

  it('can be disabled', () => {
    cy.mount(<Button disabled>Disabled</Button>);
    cy.get('button').should('be.disabled');
  });

  it('shows loading state', () => {
    cy.mount(<Button loading>Submit</Button>);
    cy.get('[data-testid="spinner"]').should('be.visible');
    cy.get('button').should('be.disabled');
  });
});
```

### Testing with Context/Providers

```tsx
// src/components/UserProfile.cy.tsx
import { UserProfile } from './UserProfile';
import { AuthProvider } from '../contexts/AuthContext';
import { ThemeProvider } from '../contexts/ThemeContext';

const mountWithProviders = (component: React.ReactNode, options = {}) => {
  const { user = { name: 'Alice', role: 'admin' }, theme = 'light' } = options;

  return cy.mount(
    <ThemeProvider theme={theme}>
      <AuthProvider user={user}>
        {component}
      </AuthProvider>
    </ThemeProvider>
  );
};

describe('UserProfile', () => {
  it('displays user name', () => {
    mountWithProviders(<UserProfile />);
    cy.contains('Alice').should('be.visible');
  });

  it('shows admin badge for admin users', () => {
    mountWithProviders(<UserProfile />, { user: { name: 'Admin', role: 'admin' } });
    cy.get('[data-testid="admin-badge"]').should('be.visible');
  });

  it('applies dark theme', () => {
    mountWithProviders(<UserProfile />, { theme: 'dark' });
    cy.get('[data-testid="profile-card"]').should('have.class', 'dark');
  });
});
```

### Testing with Routing

```tsx
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import UserPage from './UserPage';

describe('UserPage', () => {
  it('renders user details from URL params', () => {
    cy.mount(
      <MemoryRouter initialEntries={['/users/42']}>
        <Routes>
          <Route path="/users/:id" element={<UserPage />} />
        </Routes>
      </MemoryRouter>
    );

    cy.get('[data-testid="user-id"]').should('contain', '42');
  });
});
```

### Testing with Redux/Zustand

```tsx
import { Provider } from 'react-redux';
import { configureStore } from '@reduxjs/toolkit';
import { Counter } from './Counter';
import counterReducer from '../store/counterSlice';

describe('Counter', () => {
  const createTestStore = (initialState = {}) => {
    return configureStore({
      reducer: { counter: counterReducer },
      preloadedState: { counter: { value: 0, ...initialState } },
    });
  };

  it('increments counter', () => {
    const store = createTestStore();
    cy.mount(
      <Provider store={store}>
        <Counter />
      </Provider>
    );

    cy.get('[data-testid="count"]').should('contain', '0');
    cy.get('[data-testid="increment"]').click();
    cy.get('[data-testid="count"]').should('contain', '1');
  });

  it('starts with initial value', () => {
    const store = createTestStore({ value: 42 });
    cy.mount(
      <Provider store={store}>
        <Counter />
      </Provider>
    );

    cy.get('[data-testid="count"]').should('contain', '42');
  });
});
```

---

## Custom Commands

### Defining Custom Commands

```ts
// cypress/support/commands.ts

// Login command
Cypress.Commands.add('login', (email: string, password: string) => {
  cy.session([email, password], () => {
    cy.visit('/login');
    cy.get('[data-testid="email-input"]').type(email);
    cy.get('[data-testid="password-input"]').type(password);
    cy.get('[data-testid="login-button"]').click();
    cy.url().should('include', '/dashboard');
  });
});

// API login (faster, no UI)
Cypress.Commands.add('loginViaAPI', (email: string, password: string) => {
  cy.session([email, password], () => {
    cy.request('POST', '/api/auth/login', { email, password }).then((resp) => {
      window.localStorage.setItem('authToken', resp.body.token);
    });
  });
});

// Data attribute selector shorthand
Cypress.Commands.add('getByTestId', (testId: string) => {
  return cy.get(`[data-testid="${testId}"]`);
});

// Drag and drop
Cypress.Commands.add('dragTo', { prevSubject: 'element' }, (subject, target) => {
  cy.wrap(subject).trigger('dragstart');
  cy.get(target).trigger('drop');
  cy.wrap(subject).trigger('dragend');
});

// Wait for API
Cypress.Commands.add('waitForApi', (alias: string) => {
  cy.wait(`@${alias}`).then((interception) => {
    expect(interception.response.statusCode).to.be.oneOf([200, 201]);
    return interception.response.body;
  });
});

// Assert toast notification
Cypress.Commands.add('shouldShowToast', (message: string, type = 'success') => {
  cy.get(`[data-testid="toast-${type}"]`)
    .should('be.visible')
    .and('contain', message);
});
```

### TypeScript Declarations

```ts
// cypress/support/index.d.ts
declare namespace Cypress {
  interface Chainable {
    /**
     * Login via UI with session caching
     */
    login(email: string, password: string): Chainable<void>;

    /**
     * Login via API (faster)
     */
    loginViaAPI(email: string, password: string): Chainable<void>;

    /**
     * Get element by data-testid attribute
     */
    getByTestId(testId: string): Chainable<JQuery<HTMLElement>>;

    /**
     * Drag element to target
     */
    dragTo(target: string): Chainable<JQuery<HTMLElement>>;

    /**
     * Wait for API call and assert success
     */
    waitForApi(alias: string): Chainable<any>;

    /**
     * Assert a toast notification is shown
     */
    shouldShowToast(message: string, type?: string): Chainable<void>;
  }
}
```

### Using Custom Commands

```ts
describe('Dashboard', () => {
  beforeEach(() => {
    cy.loginViaAPI('admin@example.com', 'password');
    cy.visit('/dashboard');
  });

  it('shows user data', () => {
    cy.getByTestId('user-name').should('contain', 'Admin');
    cy.getByTestId('user-role').should('contain', 'Administrator');
  });

  it('creates a new item', () => {
    cy.intercept('POST', '/api/items').as('createItem');
    cy.getByTestId('new-item-button').click();
    cy.getByTestId('item-name-input').type('New Item');
    cy.getByTestId('save-button').click();
    cy.waitForApi('createItem');
    cy.shouldShowToast('Item created successfully');
  });
});
```

### Overriding Built-in Commands

```ts
// Override visit to always wait for network idle
Cypress.Commands.overwrite('visit', (originalFn, url, options) => {
  return originalFn(url, {
    ...options,
    onBeforeLoad(win) {
      // Inject test utilities
      win.testMode = true;
      options?.onBeforeLoad?.(win);
    },
  });
});
```

---

## Fixtures

### Static Fixtures

```json
// cypress/fixtures/users.json
[
  {
    "id": 1,
    "name": "Alice Johnson",
    "email": "alice@example.com",
    "role": "admin"
  },
  {
    "id": 2,
    "name": "Bob Smith",
    "email": "bob@example.com",
    "role": "user"
  }
]
```

```ts
// Using fixtures in tests
describe('Users', () => {
  it('displays users from fixture', () => {
    cy.fixture('users').then((users) => {
      cy.intercept('GET', '/api/users', users).as('getUsers');
    });

    cy.visit('/users');
    cy.wait('@getUsers');
    cy.get('[data-testid="user-row"]').should('have.length', 2);
    cy.contains('Alice Johnson').should('be.visible');
  });

  // Shorthand using fixture in intercept
  it('loads users with fixture shorthand', () => {
    cy.intercept('GET', '/api/users', { fixture: 'users.json' }).as('getUsers');
    cy.visit('/users');
    cy.wait('@getUsers');
  });

  // Modify fixture data
  it('modifies fixture data', () => {
    cy.fixture('users').then((users) => {
      users[0].name = 'Modified Name';
      cy.intercept('GET', '/api/users', users);
    });
  });
});
```

### Dynamic Fixtures with Factories

```ts
// cypress/support/factories.ts
let idCounter = 0;

export function createUser(overrides = {}) {
  idCounter += 1;
  return {
    id: idCounter,
    name: `User ${idCounter}`,
    email: `user${idCounter}@example.com`,
    role: 'user',
    createdAt: new Date().toISOString(),
    ...overrides,
  };
}

export function createUsers(count: number, overrides = {}) {
  return Array.from({ length: count }, () => createUser(overrides));
}

export function createProduct(overrides = {}) {
  idCounter += 1;
  return {
    id: idCounter,
    name: `Product ${idCounter}`,
    price: Math.floor(Math.random() * 10000) / 100,
    inStock: true,
    ...overrides,
  };
}
```

```ts
// Usage in tests
import { createUser, createUsers } from '../support/factories';

describe('User Management', () => {
  it('handles empty state', () => {
    cy.intercept('GET', '/api/users', []).as('getUsers');
    cy.visit('/users');
    cy.wait('@getUsers');
    cy.contains('No users found').should('be.visible');
  });

  it('handles many users', () => {
    const users = createUsers(50);
    cy.intercept('GET', '/api/users', users).as('getUsers');
    cy.visit('/users');
    cy.wait('@getUsers');
    cy.get('[data-testid="user-row"]').should('have.length', 50);
  });

  it('displays admin badge', () => {
    const admin = createUser({ role: 'admin', name: 'Admin User' });
    cy.intercept('GET', '/api/users/1', admin).as('getUser');
    cy.visit('/users/1');
    cy.wait('@getUser');
    cy.get('[data-testid="admin-badge"]').should('be.visible');
  });
});
```

---

## Network Stubbing

### cy.intercept Basics

```ts
// Intercept and stub response
cy.intercept('GET', '/api/users', {
  statusCode: 200,
  body: [{ id: 1, name: 'Alice' }],
}).as('getUsers');

// Match by URL pattern
cy.intercept('GET', '/api/users/*', { fixture: 'user.json' });

// Match by glob pattern
cy.intercept('GET', '**/api/users/**', { body: [] });

// Match by regex
cy.intercept('GET', /\/api\/users\/\d+/, { fixture: 'user.json' });

// Match by route matcher object
cy.intercept({
  method: 'POST',
  url: '/api/users',
  headers: { 'Content-Type': 'application/json' },
}, {
  statusCode: 201,
  body: { id: 42, name: 'New User' },
}).as('createUser');
```

### Dynamic Response Handling

```ts
// Use a function for dynamic responses
cy.intercept('GET', '/api/users/*', (req) => {
  const userId = req.url.split('/').pop();
  req.reply({
    statusCode: 200,
    body: { id: parseInt(userId), name: `User ${userId}` },
  });
}).as('getUser');

// Modify the request before it goes to the server
cy.intercept('POST', '/api/users', (req) => {
  req.headers['Authorization'] = 'Bearer test-token';
  req.body.timestamp = Date.now();
  // Don't call req.reply() to let it go to the real server
}).as('createUser');

// Modify the real response
cy.intercept('GET', '/api/users', (req) => {
  req.continue((res) => {
    // Modify response from real server
    res.body.push({ id: 999, name: 'Injected User' });
    res.send();
  });
}).as('getUsers');

// Delay response
cy.intercept('GET', '/api/users', (req) => {
  req.reply({
    statusCode: 200,
    body: [],
    delay: 2000,           // 2 second delay
  });
}).as('slowRequest');

// Throttle response
cy.intercept('GET', '/api/large-file', (req) => {
  req.reply({
    statusCode: 200,
    body: largeData,
    throttleKbps: 50,      // Simulate slow network
  });
});
```

### Error Responses

```ts
// Simulate server errors
cy.intercept('GET', '/api/users', {
  statusCode: 500,
  body: { error: 'Internal Server Error' },
}).as('serverError');

// Simulate network failure
cy.intercept('GET', '/api/users', { forceNetworkError: true }).as('networkError');

// Simulate timeout
cy.intercept('GET', '/api/users', (req) => {
  req.reply({
    statusCode: 200,
    body: [],
    delay: 60000,          // Exceed client timeout
  });
}).as('timeout');

// Conditional error responses
let requestCount = 0;
cy.intercept('GET', '/api/users', (req) => {
  requestCount += 1;
  if (requestCount <= 2) {
    req.reply({ statusCode: 503, body: 'Service Unavailable' });
  } else {
    req.reply({ statusCode: 200, body: [{ id: 1, name: 'Alice' }] });
  }
}).as('retryableRequest');
```

### Waiting for Requests

```ts
// Wait for a single request
cy.intercept('POST', '/api/users').as('createUser');
cy.get('[data-testid="submit"]').click();
cy.wait('@createUser').then((interception) => {
  expect(interception.request.body).to.deep.include({ name: 'Alice' });
  expect(interception.response.statusCode).to.equal(201);
});

// Wait for multiple requests
cy.intercept('GET', '/api/users').as('getUsers');
cy.intercept('GET', '/api/posts').as('getPosts');
cy.visit('/dashboard');
cy.wait(['@getUsers', '@getPosts']);

// Wait for the same alias multiple times
cy.intercept('GET', '/api/data*').as('getData');
cy.get('[data-testid="load-more"]').click();
cy.wait('@getData');
cy.get('[data-testid="load-more"]').click();
cy.wait('@getData');

// Assert on request body
cy.wait('@createUser').its('request.body').should('deep.include', {
  name: 'Alice',
  email: 'alice@example.com',
});

// Assert on response headers
cy.wait('@getUsers').its('response.headers').should('have.property', 'content-type')
  .and('include', 'application/json');
```

---

## Time Travel & Debugging

### Cypress Clock

```ts
// Freeze time
cy.clock(new Date('2025-06-15T12:00:00Z'));

cy.visit('/dashboard');
cy.contains('June 15, 2025').should('be.visible');

// Advance time
cy.tick(60000);                         // Advance 1 minute
cy.contains('12:01 PM').should('be.visible');

// Control specific timers
cy.clock(Date.now(), ['setTimeout', 'setInterval']);

// Restore real clock
cy.clock().then((clock) => {
  clock.restore();
});
```

### Debugging

```ts
// Pause execution
cy.get('[data-testid="button"]').click();
cy.pause();                              // Opens debugger in Cypress UI
cy.get('[data-testid="result"]').should('be.visible');

// Debug (like console.log in chain)
cy.get('[data-testid="list"]')
  .debug()                               // Logs subject to console
  .find('li')
  .should('have.length', 3);

// Log to Cypress command log
cy.log('About to perform critical action');
cy.get('[data-testid="delete-button"]').click();

// Then for inspecting values
cy.get('[data-testid="count"]').invoke('text').then((text) => {
  cy.log(`Current count: ${text}`);
  const count = parseInt(text, 10);
  expect(count).to.be.greaterThan(0);
});

// Screenshot at specific point
cy.screenshot('before-submit');
cy.get('[data-testid="submit"]').click();
cy.screenshot('after-submit');

// Conditional testing
cy.get('body').then(($body) => {
  if ($body.find('[data-testid="modal"]').length > 0) {
    cy.get('[data-testid="modal-close"]').click();
  }
});
```

### Cypress Studio (Record Tests)

```ts
// cypress.config.ts
export default defineConfig({
  e2e: {
    experimentalStudio: true,
  },
});

// Tests can be recorded interactively in the Cypress UI
// Click "Add Commands to Test" in the Cypress runner
```

### Command Log Snapshots

```ts
// Each command creates a snapshot that you can inspect
// in the Cypress Test Runner by clicking on it

// Custom log entries
Cypress.Commands.add('apiRequest', (method, url, body) => {
  Cypress.log({
    name: 'API Request',
    displayName: `${method} ${url}`,
    message: JSON.stringify(body),
    consoleProps: () => ({
      Method: method,
      URL: url,
      Body: body,
    }),
  });

  return cy.request(method, url, body);
});
```

---

## CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/cypress.yml
name: Cypress Tests
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  cypress:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        containers: [1, 2, 3, 4]
    steps:
      - uses: actions/checkout@v4

      - uses: cypress-io/github-action@v6
        with:
          build: npm run build
          start: npm run start
          wait-on: 'http://localhost:3000'
          wait-on-timeout: 120
          record: true
          parallel: true
          group: 'E2E Tests'
          browser: chrome
        env:
          CYPRESS_RECORD_KEY: ${{ secrets.CYPRESS_RECORD_KEY }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: cypress-screenshots-${{ matrix.containers }}
          path: cypress/screenshots
          retention-days: 7

      - uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: cypress-videos-${{ matrix.containers }}
          path: cypress/videos
          retention-days: 7
```

### GitHub Actions (Component + E2E)

```yaml
name: Cypress Tests
on: [push, pull_request]

jobs:
  component-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: cypress-io/github-action@v6
        with:
          component: true
          browser: chrome

  e2e-tests:
    runs-on: ubuntu-latest
    needs: component-tests
    strategy:
      matrix:
        browser: [chrome, firefox, edge]
    steps:
      - uses: actions/checkout@v4
      - uses: cypress-io/github-action@v6
        with:
          build: npm run build
          start: npm run start
          wait-on: 'http://localhost:3000'
          browser: ${{ matrix.browser }}
```

### GitLab CI

```yaml
# .gitlab-ci.yml
cypress:
  image: cypress/browsers:latest
  stage: test
  parallel: 4
  script:
    - npm ci
    - npm run build
    - npm run start &
    - npx wait-on http://localhost:3000
    - npx cypress run --record --parallel --group "GitLab CI" --ci-build-id $CI_PIPELINE_ID
  artifacts:
    when: on_failure
    paths:
      - cypress/screenshots
      - cypress/videos
    expire_in: 3 days
  variables:
    CYPRESS_RECORD_KEY: $CYPRESS_RECORD_KEY
```

### Docker

```dockerfile
# Dockerfile.cypress
FROM cypress/included:13.13.0

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .

ENTRYPOINT ["cypress", "run"]
```

```yaml
# docker-compose.cypress.yml
services:
  app:
    build: .
    ports:
      - "3000:3000"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000"]
      interval: 10s
      timeout: 5s
      retries: 5

  cypress:
    build:
      dockerfile: Dockerfile.cypress
    depends_on:
      app:
        condition: service_healthy
    environment:
      - CYPRESS_baseUrl=http://app:3000
    volumes:
      - ./cypress/screenshots:/app/cypress/screenshots
      - ./cypress/videos:/app/cypress/videos
```

### Parallelization Without Cypress Cloud

```bash
# Using cypress-split (free parallelization)
npm install cypress-split --save-dev
```

```ts
// cypress.config.ts
import { defineConfig } from 'cypress';
import cypressSplit from 'cypress-split';

export default defineConfig({
  e2e: {
    setupNodeEvents(on, config) {
      cypressSplit(on, config);
      return config;
    },
  },
});
```

```yaml
# GitHub Actions with cypress-split
jobs:
  test:
    strategy:
      matrix:
        container: [1, 2, 3, 4]
    steps:
      - uses: actions/checkout@v4
      - uses: cypress-io/github-action@v6
        with:
          start: npm start
          wait-on: 'http://localhost:3000'
        env:
          SPLIT: ${{ strategy.job-total }}
          SPLIT_INDEX: ${{ strategy.job-index }}
```

---

## Advanced Patterns

### Session Management

```ts
// cy.session caches and restores login state
Cypress.Commands.add('login', (username: string) => {
  cy.session(username, () => {
    cy.visit('/login');
    cy.get('#username').type(username);
    cy.get('#password').type('password123');
    cy.get('button[type="submit"]').click();
    cy.url().should('include', '/dashboard');
  }, {
    validate() {
      // Validate session is still active
      cy.request('/api/auth/me').its('status').should('eq', 200);
    },
    cacheAcrossSpecs: true,
  });
});
```

### Testing Iframes

```ts
// Custom command for iframe interaction
Cypress.Commands.add('iframe', (selector: string) => {
  return cy.get(selector)
    .its('0.contentDocument.body')
    .should('not.be.empty')
    .then(cy.wrap);
});

// Usage
cy.iframe('#payment-iframe').find('#card-number').type('4242424242424242');
```

### Testing Clipboard

```ts
it('copies text to clipboard', () => {
  cy.visit('/share');

  // Grant clipboard permissions
  cy.wrap(
    Cypress.automation('remote:debugger:protocol', {
      command: 'Browser.grantPermissions',
      params: {
        permissions: ['clipboardReadWrite', 'clipboardSanitizedWrite'],
        origin: window.location.origin,
      },
    })
  );

  cy.get('[data-testid="copy-button"]').click();

  cy.window().then((win) => {
    win.navigator.clipboard.readText().then((text) => {
      expect(text).to.equal('https://example.com/shared-link');
    });
  });
});
```

### Retry-ability Pattern

```ts
// Cypress automatically retries commands that query the DOM
// but NOT commands that change state

// Good: retries until assertion passes
cy.get('[data-testid="status"]').should('contain', 'Complete');

// Good: retries the entire chain
cy.get('[data-testid="list"]')
  .find('li')
  .should('have.length', 5);

// Bad: .then() breaks retryability
cy.get('[data-testid="list"]')
  .then(($list) => {
    // This won't retry
    expect($list.find('li')).to.have.length(5);
  });

// Good: use .should() callback instead
cy.get('[data-testid="list"]').should(($list) => {
  // This WILL retry
  expect($list.find('li')).to.have.length(5);
});
```

### Environment-Based Configuration

```ts
// cypress.config.ts
export default defineConfig({
  e2e: {
    setupNodeEvents(on, config) {
      const envName = config.env.environment || 'local';

      const envConfig = {
        local: {
          baseUrl: 'http://localhost:3000',
          env: { apiUrl: 'http://localhost:3000/api' },
        },
        staging: {
          baseUrl: 'https://staging.example.com',
          env: { apiUrl: 'https://staging.example.com/api' },
        },
        production: {
          baseUrl: 'https://example.com',
          env: { apiUrl: 'https://example.com/api' },
        },
      };

      return { ...config, ...envConfig[envName] };
    },
  },
});
```

```bash
# Run against specific environment
cypress run --env environment=staging
```

---

## Quick Reference Card

```
Command                          Description
─────────────────────────────────────────────────────────────
cy.visit(url)                    Navigate to URL
cy.get(selector)                 Get element(s) by selector
cy.contains(text)                Find element by text content
cy.find(selector)                Find within previous subject
cy.within(fn)                    Scope commands to element

cy.type(text)                    Type into input
cy.click()                       Click element
cy.clear()                       Clear input
cy.check() / cy.uncheck()       Check/uncheck checkbox
cy.select(value)                 Select dropdown option

cy.should(assertion)             Assert on element
cy.and(assertion)                Chain assertions
cy.its(property)                 Get property value
cy.invoke(method)                Call method on subject
cy.then(fn)                      Work with yielded subject

cy.intercept(method, url, resp)  Stub network requests
cy.wait(alias)                   Wait for aliased request
cy.request(method, url)          Make HTTP request directly

cy.fixture(path)                 Load fixture file
cy.session(id, fn)               Cache/restore session
cy.clock(time)                   Control time
cy.tick(ms)                      Advance time

cy.screenshot(name)              Take screenshot
cy.pause()                       Pause test execution
cy.debug()                       Log subject to console
cy.log(message)                  Log to command log

npx cypress open                 Open interactive runner
npx cypress run                  Run tests headlessly
npx cypress run --browser chrome Run in specific browser
npx cypress run --spec "path"    Run specific spec file
npx cypress run --record         Record to Cypress Cloud
npx cypress run --parallel       Parallelize with Cloud
```
