---
name: state
description: |
  State management design and implementation skill. Activates when a developer needs to design, implement, or refactor application state architecture. Covers frontend state (Redux, Zustand, Jotai, MobX, Pinia, Signals), server state (React Query, SWR, Apollo Client), state machines (XState, Robot), optimistic updates, cache synchronization, and state persistence/hydration. Triggers on: /godmode:state, "manage state", "state management", "global state", "server cache", "optimistic update", "state machine", or when application state patterns need architectural guidance.
---

# State -- State Management Design & Implementation

## When to Activate
- User invokes `/godmode:state`
- User says "manage state," "global state," "where should I put this state?"
- User asks about Redux, Zustand, Jotai, MobX, Pinia, Signals, or any state library
- User needs server state management (React Query, SWR, Apollo Client, RTK Query)
- User wants to design a state machine (XState, Robot)
- User needs optimistic updates, cache invalidation, or cache synchronization
- User asks about state persistence, hydration, or SSR state transfer
- User encounters stale state, race conditions, or state synchronization bugs
- Godmode orchestrator detects state management patterns that need improvement

## Workflow

### Step 1: Audit Current State Architecture

Identify the project's current state management approach, framework, and pain points:

```
STATE AUDIT:
Framework:          <React | Vue | Svelte | Angular | Solid | Qwik | Vanilla>
State libraries:    <Redux | Zustand | Jotai | MobX | Pinia | Signals | Context | None>
Server state:       <React Query | SWR | Apollo Client | RTK Query | None>
State machines:     <XState | Robot | Custom | None>
Routing state:      <URL params | search params | hash | none>
Form state:         <React Hook Form | Formik | Vuelidate | Custom | Unmanaged>
Persistence:        <localStorage | sessionStorage | IndexedDB | cookies | none>
SSR hydration:      <yes | no | partial>
Pain points:        <prop drilling | stale data | race conditions | over-rendering | complexity>
```

Scan the codebase for state patterns:
```bash
# Detect state management libraries
grep -r "from 'redux\|from 'zustand\|from 'jotai\|from 'mobx\|from '@tanstack/react-query\|from 'swr\|from 'xstate\|from '@apollo/client\|from 'pinia\|from '@preact/signals\|from '@angular/signals" src/ --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" --include="*.vue" -l

# Count state-related files
find src/ -name "*.store.*" -o -name "*.slice.*" -o -name "*.atom.*" -o -name "*.machine.*" -o -name "*Store.*" -o -name "*Context.*" | wc -l

# Detect prop drilling (components receiving 5+ props)
grep -rn "interface.*Props" src/ --include="*.tsx" --include="*.ts" -A 10 | grep -c ";"

# Detect Context usage (potential performance issues)
grep -rn "createContext\|useContext\|React.createContext" src/ --include="*.ts" --include="*.tsx" -l
```

### Step 2: Classify State by Category

All application state falls into one of these categories. Correct classification drives correct tool selection:

```
STATE CLASSIFICATION:
+-------------------+------------------+----------------------------------+----------------------------+
| Category          | Lifetime         | Examples                         | Recommended Tool           |
+-------------------+------------------+----------------------------------+----------------------------+
| Server state      | Cache lifetime   | API data, user profiles,         | React Query, SWR,          |
|                   |                  | product listings, search results | Apollo Client, RTK Query   |
+-------------------+------------------+----------------------------------+----------------------------+
| Client state      | Session/tab      | UI toggles, sidebar open/close,  | Zustand, Jotai, Signals,   |
| (UI)              |                  | active tab, modal visibility     | useState, Pinia            |
+-------------------+------------------+----------------------------------+----------------------------+
| Client state      | Session/tab      | Shopping cart, form wizard,       | Zustand, Redux, MobX,      |
| (Domain)          |                  | multi-step workflow, selections  | Pinia                      |
+-------------------+------------------+----------------------------------+----------------------------+
| Form state        | Component mount  | Input values, validation errors, | React Hook Form, Formik,   |
|                   |                  | dirty/touched tracking           | Vuelidate, native          |
+-------------------+------------------+----------------------------------+----------------------------+
| URL state         | Navigation       | Filters, pagination, sort order, | URL search params, router   |
|                   |                  | selected item IDs                | state                      |
+-------------------+------------------+----------------------------------+----------------------------+
| Persisted state   | Cross-session    | Theme preference, auth tokens,   | localStorage + Zustand     |
|                   |                  | draft content, feature flags     | persist, IndexedDB         |
+-------------------+------------------+----------------------------------+----------------------------+
| Computed/derived  | Reactive         | Filtered lists, totals, search   | Selectors, computed,       |
|                   |                  | results from local data          | useMemo, derived atoms     |
+-------------------+------------------+----------------------------------+----------------------------+
| Machine state     | Process lifetime | Auth flow, checkout wizard,      | XState, Robot, custom      |
|                   |                  | file upload, WebSocket lifecycle  | finite state machine       |
+-------------------+------------------+----------------------------------+----------------------------+
```

**Key rule:** If data comes from a server, it is server state. Do NOT put it in Redux/Zustand/Pinia. Use a server-state tool (React Query, SWR, Apollo). This single distinction eliminates 80% of state management complexity.

### Step 3: Select State Management Solution

#### 3a: Frontend State Library Selection

```
FRONTEND STATE DECISION MATRIX:
+---------------+----------+--------+----------+--------+---------+----------+
| Criteria      | Redux TK | Zustand| Jotai    | MobX   | Pinia   | Signals  |
+---------------+----------+--------+----------+--------+---------+----------+
| Bundle size   | ~11KB    | ~1KB   | ~2KB     | ~16KB  | ~2KB    | ~1KB     |
| Boilerplate   | Medium   | Low    | Low      | Low    | Low     | Low      |
| DevTools      | Excellent| Good   | Good     | Good   | Excellent| Minimal |
| TypeScript    | Excellent| Excellent| Excellent| Good  | Excellent| Excellent|
| SSR support   | Good     | Good   | Good     | Fair   | Excellent| Good    |
| Learning curve| Steep    | Gentle | Gentle   | Medium | Gentle  | Gentle   |
| Best for      | Large    | Medium | Atomic   | Complex| Vue     | Fine-    |
|               | teams    | apps   | state    | domain | apps    | grained  |
+---------------+----------+--------+----------+--------+---------+----------+

RECOMMENDATION:
- Large team, complex domain, need time-travel debugging -> Redux Toolkit
- Medium app, want minimal boilerplate                   -> Zustand
- Atomic/granular state, independent pieces              -> Jotai
- Complex domain objects with observable patterns        -> MobX
- Vue.js application                                     -> Pinia
- Fine-grained reactivity, maximum performance           -> Signals (@preact/signals, @angular/signals, solid signals)
- Simple app, few shared state pieces                    -> React Context + useReducer (no library needed)
```

#### 3b: Server State Library Selection

```
SERVER STATE DECISION MATRIX:
+------------------+-------------+--------+--------------+----------+
| Criteria         | React Query | SWR    | Apollo Client| RTK Query|
+------------------+-------------+--------+--------------+----------+
| Protocol         | Any (REST,  | Any    | GraphQL      | Any      |
|                  | GraphQL)    |        | (primary)    |          |
+------------------+-------------+--------+--------------+----------+
| Cache control    | Fine-grained| Basic  | Normalized   | Tag-based|
| Devtools         | Excellent   | None   | Excellent    | Good     |
| Optimistic UI    | Built-in    | Manual | Built-in     | Built-in |
| Offline support  | Plugin      | Manual | Built-in     | Manual   |
| SSR/SSG          | Excellent   | Good   | Excellent    | Good     |
| Bundle size      | ~12KB       | ~4KB   | ~33KB        | ~11KB    |
| Best for         | REST APIs   | Simple | GraphQL      | Redux    |
|                  |             | fetch  | APIs         | users    |
+------------------+-------------+--------+--------------+----------+

RECOMMENDATION:
- REST API, need full cache control & devtools  -> React Query (@tanstack/react-query)
- Simple data fetching, minimal config          -> SWR
- GraphQL API                                   -> Apollo Client
- Already using Redux Toolkit                   -> RTK Query
```

### Step 4: Design State Architecture

#### 4a: Store Structure Design

For the selected library, design the store structure:

```
STORE ARCHITECTURE:
Root:
├── server state (React Query / SWR / Apollo)
│   ├── ['users', userId]          # User profile cache
│   ├── ['products', filters]      # Product listing cache
│   ├── ['orders', { page, limit }] # Paginated order cache
│   └── ['notifications']          # Notification feed cache
│
├── client state (Zustand / Redux / Jotai)
│   ├── ui/
│   │   ├── sidebar: { isOpen, width }
│   │   ├── modal: { activeModal, props }
│   │   └── theme: { mode, accent }
│   ├── domain/
│   │   ├── cart: { items, appliedCoupon }
│   │   └── wizard: { step, data, completedSteps }
│   └── auth/
│       ├── user: { id, email, role }
│       └── session: { token, expiresAt }
│
├── URL state (router)
│   ├── /products?category=X&sort=Y&page=N
│   └── /orders/:id
│
└── persisted state (localStorage + sync)
    ├── theme preference
    ├── recent searches
    └── draft content
```

#### 4b: Zustand Store Example

```typescript
// stores/cart.store.ts
import { create } from 'zustand';
import { devtools, persist, subscribeWithSelector } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';

interface CartItem {
  productId: string;
  name: string;
  price: number;
  quantity: number;
}

interface CartState {
  items: CartItem[];
  couponCode: string | null;
  // Computed (derived in selectors, not stored)
  // Actions
  addItem: (item: Omit<CartItem, 'quantity'>) => void;
  removeItem: (productId: string) => void;
  updateQuantity: (productId: string, quantity: number) => void;
  applyCoupon: (code: string) => void;
  clearCart: () => void;
}

export const useCartStore = create<CartState>()(
  devtools(
    persist(
      subscribeWithSelector(
        immer((set, get) => ({
          items: [],
          couponCode: null,

          addItem: (item) =>
            set((state) => {
              const existing = state.items.find(
                (i) => i.productId === item.productId,
              );
              if (existing) {
                existing.quantity += 1;
              } else {
                state.items.push({ ...item, quantity: 1 });
              }
            }),

          removeItem: (productId) =>
            set((state) => {
              state.items = state.items.filter(
                (i) => i.productId !== productId,
              );
            }),

          updateQuantity: (productId, quantity) =>
            set((state) => {
              const item = state.items.find(
                (i) => i.productId === productId,
              );
              if (item) {
                item.quantity = Math.max(0, quantity);
              }
            }),

          applyCoupon: (code) => set({ couponCode: code }),
          clearCart: () => set({ items: [], couponCode: null }),
        })),
      ),
      { name: 'cart-storage' },
    ),
    { name: 'CartStore' },
  ),
);

// Selectors (derived state -- computed outside the store)
export const selectCartTotal = (state: CartState) =>
  state.items.reduce((sum, item) => sum + item.price * item.quantity, 0);

export const selectCartItemCount = (state: CartState) =>
  state.items.reduce((sum, item) => sum + item.quantity, 0);

export const selectCartItem = (productId: string) => (state: CartState) =>
  state.items.find((i) => i.productId === productId);
```

#### 4c: Redux Toolkit Slice Example

```typescript
// store/slices/cart.slice.ts
import { createSlice, createSelector, PayloadAction } from '@reduxjs/toolkit';
import type { RootState } from '../store';

interface CartItem {
  productId: string;
  name: string;
  price: number;
  quantity: number;
}

interface CartState {
  items: CartItem[];
  couponCode: string | null;
}

const initialState: CartState = {
  items: [],
  couponCode: null,
};

export const cartSlice = createSlice({
  name: 'cart',
  initialState,
  reducers: {
    addItem: (state, action: PayloadAction<Omit<CartItem, 'quantity'>>) => {
      const existing = state.items.find(
        (i) => i.productId === action.payload.productId,
      );
      if (existing) {
        existing.quantity += 1;
      } else {
        state.items.push({ ...action.payload, quantity: 1 });
      }
    },
    removeItem: (state, action: PayloadAction<string>) => {
      state.items = state.items.filter(
        (i) => i.productId !== action.payload,
      );
    },
    updateQuantity: (
      state,
      action: PayloadAction<{ productId: string; quantity: number }>,
    ) => {
      const item = state.items.find(
        (i) => i.productId === action.payload.productId,
      );
      if (item) {
        item.quantity = Math.max(0, action.payload.quantity);
      }
    },
    applyCoupon: (state, action: PayloadAction<string>) => {
      state.couponCode = action.payload;
    },
    clearCart: () => initialState,
  },
});

export const { addItem, removeItem, updateQuantity, applyCoupon, clearCart } =
  cartSlice.actions;

// Memoized selectors
const selectCart = (state: RootState) => state.cart;

export const selectCartTotal = createSelector(selectCart, (cart) =>
  cart.items.reduce((sum, item) => sum + item.price * item.quantity, 0),
);

export const selectCartItemCount = createSelector(selectCart, (cart) =>
  cart.items.reduce((sum, item) => sum + item.quantity, 0),
);
```

#### 4d: Jotai Atoms Example

```typescript
// atoms/cart.atoms.ts
import { atom } from 'jotai';
import { atomWithStorage } from 'jotai/utils';

interface CartItem {
  productId: string;
  name: string;
  price: number;
  quantity: number;
}

// Base atom (persisted to localStorage)
export const cartItemsAtom = atomWithStorage<CartItem[]>('cart-items', []);
export const couponCodeAtom = atomWithStorage<string | null>('coupon-code', null);

// Derived atoms (computed, read-only)
export const cartTotalAtom = atom((get) =>
  get(cartItemsAtom).reduce((sum, item) => sum + item.price * item.quantity, 0),
);

export const cartItemCountAtom = atom((get) =>
  get(cartItemsAtom).reduce((sum, item) => sum + item.quantity, 0),
);

// Write atoms (actions)
export const addItemAtom = atom(
  null,
  (get, set, item: Omit<CartItem, 'quantity'>) => {
    const items = get(cartItemsAtom);
    const existing = items.find((i) => i.productId === item.productId);
    if (existing) {
      set(
        cartItemsAtom,
        items.map((i) =>
          i.productId === item.productId
            ? { ...i, quantity: i.quantity + 1 }
            : i,
        ),
      );
    } else {
      set(cartItemsAtom, [...items, { ...item, quantity: 1 }]);
    }
  },
);

export const removeItemAtom = atom(null, (get, set, productId: string) => {
  set(
    cartItemsAtom,
    get(cartItemsAtom).filter((i) => i.productId !== productId),
  );
});
```

### Step 5: Server State with React Query

#### 5a: Query Key Design

```typescript
// lib/query-keys.ts
export const queryKeys = {
  users: {
    all: ['users'] as const,
    lists: () => [...queryKeys.users.all, 'list'] as const,
    list: (filters: UserFilters) =>
      [...queryKeys.users.lists(), filters] as const,
    details: () => [...queryKeys.users.all, 'detail'] as const,
    detail: (id: string) => [...queryKeys.users.details(), id] as const,
  },
  products: {
    all: ['products'] as const,
    lists: () => [...queryKeys.products.all, 'list'] as const,
    list: (filters: ProductFilters) =>
      [...queryKeys.products.lists(), filters] as const,
    details: () => [...queryKeys.products.all, 'detail'] as const,
    detail: (id: string) => [...queryKeys.products.details(), id] as const,
    infinite: (filters: ProductFilters) =>
      [...queryKeys.products.all, 'infinite', filters] as const,
  },
  orders: {
    all: ['orders'] as const,
    list: (params: OrderParams) =>
      [...queryKeys.orders.all, 'list', params] as const,
    detail: (id: string) => [...queryKeys.orders.all, 'detail', id] as const,
  },
} as const;
```

#### 5b: Query Hook with Caching

```typescript
// hooks/use-users.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { queryKeys } from '@/lib/query-keys';
import { api } from '@/lib/api';

export function useUser(userId: string) {
  return useQuery({
    queryKey: queryKeys.users.detail(userId),
    queryFn: () => api.users.getById(userId),
    staleTime: 5 * 60 * 1000,        // Consider fresh for 5 minutes
    gcTime: 30 * 60 * 1000,           // Keep in cache for 30 minutes
    retry: 2,
    enabled: !!userId,                 // Don't fetch if no userId
  });
}

export function useUsers(filters: UserFilters) {
  return useQuery({
    queryKey: queryKeys.users.list(filters),
    queryFn: () => api.users.list(filters),
    staleTime: 2 * 60 * 1000,
    placeholderData: (previousData) => previousData, // Keep previous while fetching
  });
}

export function useUpdateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: { id: string; updates: Partial<User> }) =>
      api.users.update(data.id, data.updates),
    onSuccess: (updatedUser) => {
      // Update the specific user cache
      queryClient.setQueryData(
        queryKeys.users.detail(updatedUser.id),
        updatedUser,
      );
      // Invalidate lists (they might be sorted/filtered differently)
      queryClient.invalidateQueries({
        queryKey: queryKeys.users.lists(),
      });
    },
  });
}
```

#### 5c: Optimistic Updates

```typescript
// hooks/use-toggle-favorite.ts
export function useToggleFavorite() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (productId: string) => api.products.toggleFavorite(productId),

    // Optimistic update: update UI immediately before server responds
    onMutate: async (productId) => {
      // Cancel outgoing refetches so they don't overwrite our optimistic update
      await queryClient.cancelQueries({
        queryKey: queryKeys.products.detail(productId),
      });

      // Snapshot the previous value (for rollback)
      const previousProduct = queryClient.getQueryData<Product>(
        queryKeys.products.detail(productId),
      );

      // Optimistically update the cache
      queryClient.setQueryData<Product>(
        queryKeys.products.detail(productId),
        (old) =>
          old ? { ...old, isFavorite: !old.isFavorite } : old,
      );

      // Return context with the snapshot
      return { previousProduct };
    },

    // On error, roll back to the previous value
    onError: (_err, productId, context) => {
      if (context?.previousProduct) {
        queryClient.setQueryData(
          queryKeys.products.detail(productId),
          context.previousProduct,
        );
      }
    },

    // After success or error, refetch to ensure server/client sync
    onSettled: (_data, _error, productId) => {
      queryClient.invalidateQueries({
        queryKey: queryKeys.products.detail(productId),
      });
    },
  });
}
```

### Step 6: State Machine Design

#### 6a: When to Use a State Machine

```
STATE MACHINE DECISION:
Use a state machine when:
[x] The entity has a fixed set of states (loading, success, error, idle)
[x] Transitions between states follow strict rules (can't go from "idle" to "success")
[x] Invalid state combinations are possible ("loading AND error" should be impossible)
[x] The flow has branching logic (checkout: shipping -> payment -> review -> confirm)
[x] Complex async workflows (file upload: selecting -> uploading -> processing -> done)
[x] WebSocket/real-time lifecycle management (connecting -> connected -> disconnected -> reconnecting)

Do NOT use a state machine when:
[ ] Simple boolean toggle (isOpen, isDarkMode)
[ ] CRUD operations (React Query handles this better)
[ ] Form state (form libraries handle this better)
```

#### 6b: XState Machine Example

```typescript
// machines/checkout.machine.ts
import { createMachine, assign } from 'xstate';

interface CheckoutContext {
  shippingAddress: ShippingAddress | null;
  paymentMethod: PaymentMethod | null;
  orderSummary: OrderSummary | null;
  error: string | null;
}

type CheckoutEvent =
  | { type: 'SUBMIT_SHIPPING'; address: ShippingAddress }
  | { type: 'SUBMIT_PAYMENT'; payment: PaymentMethod }
  | { type: 'CONFIRM_ORDER' }
  | { type: 'BACK' }
  | { type: 'RETRY' }
  | { type: 'CANCEL' };

export const checkoutMachine = createMachine({
  id: 'checkout',
  initial: 'shipping',
  context: {
    shippingAddress: null,
    paymentMethod: null,
    orderSummary: null,
    error: null,
  } satisfies CheckoutContext,
  states: {
    shipping: {
      on: {
        SUBMIT_SHIPPING: {
          target: 'payment',
          actions: assign({
            shippingAddress: (_, event) => event.address,
          }),
        },
        CANCEL: 'cancelled',
      },
    },
    payment: {
      on: {
        SUBMIT_PAYMENT: {
          target: 'review',
          actions: assign({
            paymentMethod: (_, event) => event.payment,
          }),
        },
        BACK: 'shipping',
        CANCEL: 'cancelled',
      },
    },
    review: {
      on: {
        CONFIRM_ORDER: 'submitting',
        BACK: 'payment',
        CANCEL: 'cancelled',
      },
    },
    submitting: {
      invoke: {
        src: 'submitOrder',
        onDone: {
          target: 'success',
          actions: assign({
            orderSummary: (_, event) => event.data,
          }),
        },
        onError: {
          target: 'error',
          actions: assign({
            error: (_, event) => event.data?.message ?? 'Order failed',
          }),
        },
      },
    },
    success: {
      type: 'final',
    },
    error: {
      on: {
        RETRY: 'submitting',
        BACK: 'review',
        CANCEL: 'cancelled',
      },
    },
    cancelled: {
      type: 'final',
    },
  },
});
```

### Step 7: State Persistence and Hydration

#### 7a: Persistence Strategy

```
PERSISTENCE STRATEGY:
+-------------------+-------------------+---------------+-------------------+
| Storage           | Capacity          | Speed         | Use Case          |
+-------------------+-------------------+---------------+-------------------+
| localStorage      | ~5-10 MB          | Synchronous   | Theme, prefs,     |
|                   |                   |               | small state       |
+-------------------+-------------------+---------------+-------------------+
| sessionStorage    | ~5-10 MB          | Synchronous   | Tab-specific,     |
|                   |                   |               | form drafts       |
+-------------------+-------------------+---------------+-------------------+
| IndexedDB         | ~50MB-unlimited   | Async         | Large datasets,   |
|                   |                   |               | offline data      |
+-------------------+-------------------+---------------+-------------------+
| cookies           | ~4 KB             | Synchronous   | Auth tokens,      |
|                   |                   |               | SSR-accessible    |
+-------------------+-------------------+---------------+-------------------+
| URL params        | ~2 KB practical   | Synchronous   | Shareable state   |
|                   |                   |               | (filters, pages)  |
+-------------------+-------------------+---------------+-------------------+
```

#### 7b: SSR Hydration Pattern

```typescript
// Zustand with SSR hydration (Next.js)
// stores/app.store.ts
import { create } from 'zustand';

interface AppState {
  theme: 'light' | 'dark';
  locale: string;
  setTheme: (theme: 'light' | 'dark') => void;
  setLocale: (locale: string) => void;
}

export const useAppStore = create<AppState>()((set) => ({
  theme: 'light',
  locale: 'en',
  setTheme: (theme) => set({ theme }),
  setLocale: (locale) => set({ locale }),
}));

// Server component passes initial state
// app/layout.tsx
export default function RootLayout({ children }: { children: React.ReactNode }) {
  const theme = cookies().get('theme')?.value ?? 'light';
  const locale = headers().get('accept-language')?.split(',')[0] ?? 'en';

  return (
    <StoreHydrator initialState={{ theme, locale }}>
      {children}
    </StoreHydrator>
  );
}

// components/store-hydrator.tsx
'use client';
import { useRef } from 'react';
import { useAppStore } from '@/stores/app.store';

export function StoreHydrator({
  initialState,
  children,
}: {
  initialState: Partial<ReturnType<typeof useAppStore.getState>>;
  children: React.ReactNode;
}) {
  const initialized = useRef(false);
  if (!initialized.current) {
    useAppStore.setState(initialState);
    initialized.current = true;
  }
  return <>{children}</>;
}
```

#### 7c: Cache Synchronization

```typescript
// Real-time cache sync with WebSocket + React Query
// lib/realtime-sync.ts
import { useEffect } from 'react';
import { useQueryClient } from '@tanstack/react-query';
import { queryKeys } from '@/lib/query-keys';

export function useRealtimeSync() {
  const queryClient = useQueryClient();

  useEffect(() => {
    const ws = new WebSocket(process.env.NEXT_PUBLIC_WS_URL!);

    ws.onmessage = (event) => {
      const message = JSON.parse(event.data);

      switch (message.type) {
        case 'ORDER_UPDATED':
          // Update specific order in cache
          queryClient.setQueryData(
            queryKeys.orders.detail(message.payload.id),
            message.payload,
          );
          // Invalidate order lists (re-fetch to get correct ordering)
          queryClient.invalidateQueries({
            queryKey: queryKeys.orders.all,
            exact: false,
          });
          break;

        case 'NOTIFICATION':
          // Invalidate notification cache to trigger re-fetch
          queryClient.invalidateQueries({
            queryKey: ['notifications'],
          });
          break;

        case 'BULK_UPDATE':
          // For large changes, just invalidate everything in the scope
          queryClient.invalidateQueries({
            queryKey: [message.payload.entity],
          });
          break;
      }
    };

    return () => ws.close();
  }, [queryClient]);
}
```

### Step 8: Report and Transition

```
+--------------------------------------------------------------+
|  STATE MANAGEMENT DESIGN -- <description>                     |
+--------------------------------------------------------------+
|  Framework:         <framework>                               |
|  Client state:      <library selected>                        |
|  Server state:      <library selected>                        |
|  State machines:    <library selected, if applicable>         |
+--------------------------------------------------------------+
|  State categories identified:                                 |
|  - Server state:   <N> query keys                             |
|  - Client (UI):    <N> stores/atoms                           |
|  - Client (domain):<N> stores/atoms                           |
|  - URL state:      <N> parameters                             |
|  - Persisted:      <N> items                                  |
|  - State machines: <N> machines                               |
+--------------------------------------------------------------+
|  Architecture decisions:                                      |
|  1. <decision and rationale>                                  |
|  2. <decision and rationale>                                  |
+--------------------------------------------------------------+
|  Files created/modified:                                      |
|  - <file path and purpose>                                    |
+--------------------------------------------------------------+
```

Commit: `"state: design <description> state architecture"`

## Key Behaviors

1. **Classify state before choosing a tool.** The single most important decision is separating server state from client state. Server state goes in React Query/SWR/Apollo. Client state goes in Zustand/Redux/Jotai.
2. **Minimize state.** If it can be computed from other state, it is derived state -- use selectors, not stored values. If it can live in the URL, put it in the URL. Less state means fewer bugs.
3. **Colocate state.** State should live as close to where it is used as possible. useState > Zustand store > Redux global. Only lift state when two distant components genuinely need it.
4. **Server state is a cache, not a store.** You do not own server data. You cache it. It can become stale. React Query/SWR handle staleness, refetching, and garbage collection. Redux does not.
5. **Optimistic updates need rollback.** Every optimistic update must have an onError rollback path. Snapshot previous state before mutating. Invalidate after settling.
6. **State machines prevent impossible states.** If you find yourself writing `isLoading && !isError && !isSuccess`, you need a state machine. A machine can only be in one state at a time.
7. **Persistence is not free.** localStorage is synchronous and blocks the main thread. IndexedDB is async but complex. Choose based on data size and access pattern.
8. **Selectors prevent re-renders.** Always access store state through selectors that pick only what the component needs. Never subscribe to the entire store.
9. **URL state is shareable state.** Filters, pagination, sort order, and selected items should be in the URL so users can share and bookmark.
10. **Hydration must be idempotent.** SSR hydration should produce the same result whether it runs once or twice. No side effects in hydration logic.

## Example Usage

### Designing state for a new feature
```
User: /godmode:state I'm building a dashboard with real-time order tracking,
      user preferences, and filtering. What state architecture should I use?

State: Analyzing requirements...

STATE CLASSIFICATION:
- Orders data (from API, real-time updates)     -> Server state (React Query + WebSocket sync)
- User preferences (theme, layout)              -> Persisted client state (Zustand + persist)
- Dashboard filters (date range, status)        -> URL state (search params)
- Active order detail (selected from list)       -> URL state (route param)
- Sidebar collapsed                              -> Client UI state (Zustand)

ARCHITECTURE:
1. React Query for all order data (staleTime: 30s for dashboard freshness)
2. WebSocket listener that invalidates order queries on real-time events
3. Zustand store with persist middleware for user preferences
4. URL search params for filters (shareable, bookmarkable)
5. No Redux needed -- no complex domain state

Files to create:
- lib/query-keys.ts            (query key factory)
- hooks/use-orders.ts          (React Query hooks)
- hooks/use-realtime-sync.ts   (WebSocket cache sync)
- stores/preferences.store.ts  (Zustand persisted store)
```

### Migrating from Redux to React Query + Zustand
```
User: /godmode:state Our Redux store has 40 slices and it's getting unmaintainable.
      Most slices just cache API data. How do I migrate?

State: Auditing current Redux store...

Found 40 slices:
- 32 slices are server state (API caching) -> Migrate to React Query
- 5 slices are UI state (modals, sidebar, theme) -> Migrate to Zustand
- 3 slices are domain state (cart, wizard, editor) -> Keep in Zustand

MIGRATION PLAN:
Phase 1: Add React Query alongside Redux (no removals)
Phase 2: Migrate server-state slices one at a time (32 slices)
Phase 3: Move UI state to Zustand (5 slices)
Phase 4: Move domain state to Zustand (3 slices)
Phase 5: Remove Redux entirely

Estimated reduction: 40 Redux slices -> 0 Redux + 8 Zustand stores + React Query
Lines of code eliminated: ~3,200 (reducers, actions, selectors, thunks)
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Interactive state management design workflow |
| `--audit` | Audit current state architecture and identify issues |
| `--classify` | Classify all state in the codebase by category |
| `--migrate` | Generate migration plan from one state library to another |
| `--optimistic` | Design optimistic update patterns for mutations |
| `--machine` | Design a state machine for a complex workflow |
| `--persist` | Set up state persistence and hydration |
| `--ssr` | Design SSR-compatible state with hydration |
| `--realtime` | Set up real-time state synchronization (WebSocket/SSE) |
| `--devtools` | Configure state debugging tools |
| `--selectors` | Optimize selectors to prevent unnecessary re-renders |
| `--report` | Generate full state architecture report |

## Anti-Patterns

- **Do NOT put server data in Redux/Zustand/Pinia.** API data is server state. It belongs in React Query/SWR/Apollo. These tools handle caching, staleness, refetching, and garbage collection. Redux does not.
- **Do NOT store derived state.** If `totalPrice` can be computed from `items`, compute it in a selector. Storing it creates sync bugs.
- **Do NOT use Context for frequently-changing state.** React Context re-renders ALL consumers on ANY change. Use Zustand, Jotai, or Signals for state that changes often.
- **Do NOT subscribe to the entire store.** `useStore()` re-renders on every state change. Always use selectors: `useStore((s) => s.count)`.
- **Do NOT put form state in global stores.** Form state is local. Use React Hook Form or similar. Only persist form drafts if explicitly needed.
- **Do NOT use optimistic updates without rollback.** If the server rejects the mutation, the UI must revert. Always implement onError rollback.
- **Do NOT mix state management paradigms randomly.** Pick one client state library and one server state library. Do not use Redux AND Zustand AND Jotai in the same project.
- **Do NOT persist sensitive data in localStorage.** Auth tokens in localStorage are vulnerable to XSS. Use httpOnly cookies for auth.
- **Do NOT ignore hydration mismatches.** Server-rendered HTML must match the first client render. Use `useEffect` for client-only state to avoid hydration errors.
- **Do NOT create a store for every component.** Stores are for shared state. If only one component uses the state, use local `useState`.
