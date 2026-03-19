---
name: wireframe
description: |
  Wireframing and prototyping skill. Activates when user needs to plan UI layouts before coding, generate lo-fi ASCII wireframes in markdown, map component hierarchies, design navigation flows, plan responsive breakpoints, specify interactive prototypes, build screen inventories and sitemaps, extract design tokens from mockups, translate Figma designs to code structure, or define page grids. Triggers on: /godmode:wireframe, "wireframe", "prototype", "layout plan", "screen flow", "sitemap", "page structure", "Figma to code", or when the orchestrator detects UI planning is needed before implementation.
---

# Wireframe — Wireframing & Prototyping

## When to Activate
- User invokes `/godmode:wireframe`
- User says "wireframe," "prototype," "layout plan," "screen flow," "page structure"
- When starting a new feature or page that needs UI planning before code
- When a designer hands off mockups and the developer needs a structural translation plan
- When building a screen inventory or sitemap for a new project
- When planning navigation flows between screens
- When defining responsive behavior across breakpoints before implementation
- When `/godmode:think` or `/godmode:plan` identifies UI structure as the next step
- When translating Figma designs into component architecture

## Workflow

### Step 1: Gather UI Context
Understand what is being built before producing wireframes:

```
WIREFRAME CONTEXT:
Project: <name and purpose>
Scope: <single screen | feature flow | full application>
Target users: <who will use this>
Platform: <web | mobile | desktop | responsive all>
Framework: <React/Vue/Angular/Svelte/vanilla>
Design source: <Figma file | verbal description | competitor reference | none>
Existing screens: <N screens already built>
New screens needed: <N screens to design>

Content priorities:
  1. <primary content/action for this screen>
  2. <secondary content/action>
  3. <tertiary content/action>

Constraints:
  - Viewport range: <min-width> to <max-width>
  - Must match existing design system: <yes/no>
  - Accessibility requirements: <WCAG AA / WCAG AAA / none specified>
  - Key interactions: <list primary user actions>
```

### Step 2: Screen Inventory & Sitemap
Map every screen in the application and how they connect:

#### Screen Inventory
```
SCREEN INVENTORY:
┌──────────────────────────────────────────────────────────────────────────┐
│ ID    │ Screen Name         │ Purpose                  │ Status          │
├──────────────────────────────────────────────────────────────────────────┤
│ S-01  │ Landing Page        │ Convert visitors         │ NEW / EXISTS    │
│ S-02  │ Sign Up             │ Account creation         │ NEW / EXISTS    │
│ S-03  │ Login               │ Authentication           │ NEW / EXISTS    │
│ S-04  │ Dashboard           │ Overview & navigation    │ NEW / EXISTS    │
│ S-05  │ Settings            │ User preferences         │ NEW / EXISTS    │
│ S-06  │ Profile             │ User info management     │ NEW / EXISTS    │
│ S-07  │ [Feature] List      │ Browse items             │ NEW / EXISTS    │
│ S-08  │ [Feature] Detail    │ View single item         │ NEW / EXISTS    │
│ S-09  │ [Feature] Create    │ Add new item             │ NEW / EXISTS    │
│ S-10  │ [Feature] Edit      │ Modify existing item     │ NEW / EXISTS    │
│ S-11  │ Error / 404         │ Handle missing routes    │ NEW / EXISTS    │
│ S-12  │ Empty State         │ No data placeholder      │ NEW / EXISTS    │
└──────────────────────────────────────────────────────────────────────────┘

Total screens: <N>
New to build: <N>
Existing to modify: <N>
```

#### Sitemap Diagram
```
SITEMAP:
[Landing Page]
  ├── [Sign Up] ──► [Onboarding] ──► [Dashboard]
  ├── [Login] ──► [Dashboard]
  │
  └── [Public Pages]
       ├── [Pricing]
       ├── [About]
       └── [Contact]

[Dashboard] (authenticated)
  ├── [Feature A]
  │    ├── [List View]
  │    ├── [Detail View]
  │    ├── [Create]
  │    └── [Edit]
  │
  ├── [Feature B]
  │    ├── [List View]
  │    └── [Detail View]
  │
  ├── [Settings]
  │    ├── [Profile]
  │    ├── [Account]
  │    ├── [Billing]
  │    └── [Notifications]
  │
  └── [Admin] (role-gated)
       ├── [User Management]
       └── [System Config]

Legend:
  [ ] = Screen
  ──► = Navigation flow
  (condition) = Access requirement
```

### Step 3: Navigation Flow Diagrams
Map how users move between screens for key tasks:

#### Task Flow Template
```
FLOW: <Task Name> (e.g., "User creates a new project")

START
  │
  ▼
[Dashboard]
  │ clicks "New Project"
  ▼
[Create Project — Step 1: Name & Description]
  │ fills form, clicks "Next"
  ▼
[Create Project — Step 2: Team Members]
  │ adds members, clicks "Next"
  ▼
┌─────────────────────────────────┐
│ DECISION: Add integrations?      │
├──── Yes ────┬──── No ───────────┤
│             │                    │
▼             │                    │
[Step 3:      │                    │
Integrations] │                    │
│ configures  │                    │
│ clicks Next │                    │
└─────┬───────┘                    │
      │                            │
      ▼                            ▼
[Review & Confirm]
  │ clicks "Create"
  ▼
[Project Detail] ◄── SUCCESS
  │
  ▼
END

Error paths:
  - Validation error at Step 1 → inline error, stay on Step 1
  - Network failure at Create → toast error, retry button
  - Duplicate name at Create → modal with rename option
```

#### Navigation Structure
```
NAVIGATION ARCHITECTURE:
┌──────────────────────────────────────────────────────────────┐
│ Level          │ Pattern         │ Screens                    │
├──────────────────────────────────────────────────────────────┤
│ Global nav     │ Sidebar / Topbar│ Always visible (auth)      │
│ Section nav    │ Tabs / Sub-nav  │ Within feature sections    │
│ Contextual nav │ Breadcrumbs     │ Detail/edit views          │
│ Action nav     │ FAB / Toolbar   │ Create/edit screens        │
│ Utility nav    │ User menu       │ Settings, profile, logout  │
│ Mobile nav     │ Bottom tabs     │ Top 4-5 destinations       │
└──────────────────────────────────────────────────────────────┘

Navigation rules:
- Maximum <N> items in global nav
- Current section highlighted
- Breadcrumbs on screens deeper than 2 levels
- Mobile: bottom tabs for primary, hamburger for secondary
- Back button behavior: <native history / explicit back>
```

### Step 4: Lo-Fi Wireframe Generation
Produce ASCII wireframes in markdown for each screen. These are structural blueprints, not visual designs.

#### Desktop Wireframe Template
```
WIREFRAME: <Screen Name> — Desktop (1280px)
┌─────────────────────────────────────────────────────────────────────┐
│ ┌─ TOPBAR ────────────────────────────────────────────────────────┐ │
│ │ [Logo]          [Search.............]    [Bell] [Avatar ▼]      │ │
│ └─────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│ ┌─ SIDEBAR ──┐  ┌─ MAIN CONTENT ──────────────────────────────────┐│
│ │            │  │                                                  ││
│ │ Dashboard  │  │  Page Title                    [+ New] [Filter]  ││
│ │ Projects ● │  │  ─────────────────────────────────────────────── ││
│ │ Tasks      │  │                                                  ││
│ │ Messages   │  │  ┌─ CARD ─────┐  ┌─ CARD ─────┐  ┌─ CARD ────┐ ││
│ │ Reports    │  │  │ [Image]    │  │ [Image]    │  │ [Image]   │ ││
│ │            │  │  │ Title      │  │ Title      │  │ Title     │ ││
│ │ ────────── │  │  │ Subtitle   │  │ Subtitle   │  │ Subtitle  │ ││
│ │ Settings   │  │  │ [Tag][Tag] │  │ [Tag][Tag] │  │ [Tag]     │ ││
│ │ Help       │  │  │ [Action]   │  │ [Action]   │  │ [Action]  │ ││
│ │            │  │  └────────────┘  └────────────┘  └───────────┘ ││
│ │            │  │                                                  ││
│ │            │  │  ┌─ CARD ─────┐  ┌─ CARD ─────┐  ┌─ CARD ────┐ ││
│ │            │  │  │ [Image]    │  │ [Image]    │  │ [Image]   │ ││
│ │            │  │  │ Title      │  │ Title      │  │ Title     │ ││
│ │            │  │  │ Subtitle   │  │ Subtitle   │  │ Subtitle  │ ││
│ │            │  │  │ [Tag][Tag] │  │ [Tag][Tag] │  │ [Tag]     │ ││
│ │            │  │  │ [Action]   │  │ [Action]   │  │ [Action]  │ ││
│ │            │  │  └────────────┘  └────────────┘  └───────────┘ ││
│ │            │  │                                                  ││
│ │            │  │  ◄ 1  2  3  ... 12 ►          Showing 1-6 of 72 ││
│ └────────────┘  └──────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────────┘

ANNOTATIONS:
  [Logo] = Clickable, navigates to Dashboard
  [Search] = Global search with typeahead (Ctrl+K shortcut)
  [Bell] = Notification center, badge count when unread
  [Avatar ▼] = Dropdown: Profile, Settings, Logout
  ● = Active nav indicator
  [+ New] = Primary CTA, opens Create modal
  [Filter] = Dropdown filter by status, date, tag
  [Tag] = Clickable, filters list by tag
  [Action] = Context menu: Edit, Duplicate, Archive, Delete
  ◄ ► = Pagination controls
```

#### Mobile Wireframe Template
```
WIREFRAME: <Screen Name> — Mobile (375px)
┌───────────────────────────┐
│ ┌─ TOPBAR ──────────────┐ │
│ │ [☰]  App Name  [Bell] │ │
│ └───────────────────────┘ │
│                            │
│ [Search..................] │
│                            │
│ Page Title      [+ New]    │
│ ─────────────────────────  │
│                            │
│ ┌─ CARD ───────────────┐  │
│ │ [Image]  Title        │  │
│ │          Subtitle     │  │
│ │          [Tag] [Tag]  │  │
│ │          [Action ▼]   │  │
│ └───────────────────────┘  │
│                            │
│ ┌─ CARD ───────────────┐  │
│ │ [Image]  Title        │  │
│ │          Subtitle     │  │
│ │          [Tag] [Tag]  │  │
│ │          [Action ▼]   │  │
│ └───────────────────────┘  │
│                            │
│ ┌─ CARD ───────────────┐  │
│ │ [Image]  Title        │  │
│ │          Subtitle     │  │
│ │          [Tag] [Tag]  │  │
│ │          [Action ▼]   │  │
│ └───────────────────────┘  │
│                            │
│ [Load More]                │
│                            │
│ ┌─ BOTTOM NAV ─────────┐  │
│ │ [Home] [Search]       │  │
│ │ [Add]  [Inbox] [Menu] │  │
│ └───────────────────────┘  │
└───────────────────────────┘

ANNOTATIONS:
  [☰] = Hamburger menu, opens sidebar as overlay
  [+ New] = Compact CTA, same as desktop
  Cards = Horizontal layout (image left, content right)
  [Action ▼] = Bottom sheet with actions on tap
  [Load More] = Infinite scroll or tap-to-load (replaces pagination)
  Bottom Nav = Persistent, 5 max destinations
```

#### Tablet Wireframe Template
```
WIREFRAME: <Screen Name> — Tablet (768px)
┌────────────────────────────────────────────────┐
│ ┌─ TOPBAR ───────────────────────────────────┐ │
│ │ [Logo]   [Search............]  [Bell] [Av] │ │
│ └────────────────────────────────────────────┘ │
│                                                 │
│ ┌─ RAIL ┐  ┌─ MAIN CONTENT ──────────────────┐│
│ │ [ico]  │  │                                  ││
│ │ [ico]● │  │  Page Title        [+ New][Filt] ││
│ │ [ico]  │  │  ──────────────────────────────  ││
│ │ [ico]  │  │                                  ││
│ │ [ico]  │  │  ┌─ CARD ─────┐  ┌─ CARD ─────┐ ││
│ │        │  │  │ [Image]    │  │ [Image]    │ ││
│ │ ────── │  │  │ Title      │  │ Title      │ ││
│ │ [ico]  │  │  │ Subtitle   │  │ Subtitle   │ ││
│ │ [ico]  │  │  │ [Tag][Tag] │  │ [Tag][Tag] │ ││
│ │        │  │  │ [Action]   │  │ [Action]   │ ││
│ └────────┘  │  └────────────┘  └────────────┘ ││
│             │                                  ││
│             │  ┌─ CARD ─────┐  ┌─ CARD ─────┐ ││
│             │  │ [Image]    │  │ [Image]    │ ││
│             │  │ Title      │  │ Title      │ ││
│             │  │ Subtitle   │  │ Subtitle   │ ││
│             │  │ [Tag][Tag] │  │ [Tag][Tag] │ ││
│             │  │ [Action]   │  │ [Action]   │ ││
│             │  └────────────┘  └────────────┘ ││
│             │                                  ││
│             │  ◄ 1  2  3  ... 12 ►             ││
│             └──────────────────────────────────┘│
└────────────────────────────────────────────────┘

ANNOTATIONS:
  RAIL = Collapsed sidebar, icons only, expand on hover/tap
  ● = Active indicator on icon
  2-column card grid (instead of 3 on desktop)
  Topbar condensed — avatar initials only
```

### Step 5: Component Layout Planning
Break each wireframe into a component hierarchy:

#### Component Hierarchy Map
```
COMPONENT HIERARCHY: <Screen Name>
├── AppShell
│   ├── Topbar
│   │   ├── Logo
│   │   ├── GlobalSearch
│   │   ├── NotificationBell (badge count)
│   │   └── UserMenu (Avatar + Dropdown)
│   │       ├── MenuItem: Profile
│   │       ├── MenuItem: Settings
│   │       └── MenuItem: Logout
│   │
│   ├── Sidebar (desktop) / BottomNav (mobile) / Rail (tablet)
│   │   ├── NavItem: Dashboard
│   │   ├── NavItem: Projects (active)
│   │   ├── NavItem: Tasks
│   │   ├── NavItem: Messages
│   │   ├── NavItem: Reports
│   │   ├── Divider
│   │   ├── NavItem: Settings
│   │   └── NavItem: Help
│   │
│   └── MainContent
│       ├── PageHeader
│       │   ├── PageTitle
│       │   ├── PrimaryAction: [+ New Project]
│       │   └── FilterDropdown
│       │
│       ├── CardGrid (responsive: 1-col / 2-col / 3-col)
│       │   └── ProjectCard (repeated)
│       │       ├── CardImage
│       │       ├── CardTitle
│       │       ├── CardSubtitle
│       │       ├── TagList
│       │       │   └── Tag (repeated)
│       │       └── CardActions (context menu)
│       │
│       └── Pagination
│           ├── PrevButton
│           ├── PageNumbers
│           ├── NextButton
│           └── ResultCount
```

#### Component Responsibility Matrix
```
COMPONENT RESPONSIBILITIES:
┌────────────────────────────────────────────────────────────────────────────┐
│ Component        │ Data         │ State         │ Events                    │
├────────────────────────────────────────────────────────────────────────────┤
│ AppShell         │ auth user    │ sidebar open  │ -                         │
│ Topbar           │ user, notifs │ search open   │ onSearch, onNotifClick    │
│ Sidebar          │ nav items    │ active item   │ onNavClick                │
│ PageHeader       │ title, count │ filter state  │ onFilter, onCreate        │
│ CardGrid         │ items[]      │ -             │ -                         │
│ ProjectCard      │ project      │ menu open     │ onEdit, onDelete, onClick │
│ Pagination       │ total, page  │ current page  │ onPageChange              │
│ GlobalSearch     │ results[]    │ query, open   │ onSearch, onSelect        │
│ FilterDropdown   │ options[]    │ selected[]    │ onFilterChange            │
│ NotificationBell │ notifs[]     │ open          │ onOpen, onMarkRead        │
│ UserMenu         │ user         │ open          │ onLogout, onProfile       │
└────────────────────────────────────────────────────────────────────────────┘
```

### Step 6: Page Structure & Grid Systems
Define the underlying grid and spacing structure for layouts:

#### Grid System Definition
```
GRID SYSTEM:
┌────────────────────────────────────────────────────────┐
│ Property        │ Mobile    │ Tablet    │ Desktop       │
├────────────────────────────────────────────────────────┤
│ Viewport range  │ 320-767px │ 768-1279px│ 1280px+       │
│ Columns         │ 4         │ 8         │ 12            │
│ Gutter          │ 16px      │ 24px      │ 24px          │
│ Margin          │ 16px      │ 32px      │ auto (max-w)  │
│ Max content w   │ 100%      │ 100%      │ 1280px        │
│ Column width    │ fluid     │ fluid     │ fluid         │
│ Sidebar width   │ 0 (hidden)│ 64px(rail)│ 240px         │
│ Content area    │ 4 cols    │ 7 cols    │ 10 cols       │
└────────────────────────────────────────────────────────┘
```

#### Page Layout Templates
```
LAYOUT TEMPLATE: Sidebar + Content (default)
┌──────────────────────────────────────────────────────────┐
│                        TOPBAR (h: 64px)                   │
├──────────┬───────────────────────────────────────────────┤
│ SIDEBAR  │                                               │
│ (w: 240) │              CONTENT AREA                     │
│          │    ┌──────────────────────────────────────┐   │
│          │    │  PAGE HEADER (h: auto)                │   │
│          │    ├──────────────────────────────────────┤   │
│          │    │                                      │   │
│          │    │  SCROLLABLE CONTENT                   │   │
│          │    │  (flex: 1, overflow-y: auto)          │   │
│          │    │                                      │   │
│          │    │  padding: var(--spacing-6)            │   │
│          │    │  max-width: 1200px                    │   │
│          │    │                                      │   │
│          │    └──────────────────────────────────────┘   │
│          │                                               │
└──────────┴───────────────────────────────────────────────┘

LAYOUT TEMPLATE: Full Width (landing, marketing)
┌──────────────────────────────────────────────────────────┐
│                    TOPBAR (transparent)                    │
├──────────────────────────────────────────────────────────┤
│                                                           │
│  HERO SECTION (full bleed, h: 80vh)                       │
│                                                           │
├──────────────────────────────────────────────────────────┤
│                                                           │
│  CONTENT SECTION (max-w: 1280px, centered)                │
│                                                           │
├──────────────────────────────────────────────────────────┤
│                                                           │
│  CTA SECTION (full bleed, bg: primary)                    │
│                                                           │
├──────────────────────────────────────────────────────────┤
│                    FOOTER                                  │
└──────────────────────────────────────────────────────────┘

LAYOUT TEMPLATE: Detail View (split pane)
┌──────────────────────────────────────────────────────────┐
│                        TOPBAR                             │
├──────────┬────────────────────────┬──────────────────────┤
│ SIDEBAR  │    PRIMARY CONTENT     │   DETAIL PANEL       │
│          │    (2/3 width)         │   (1/3 width)        │
│          │                        │                      │
│          │    List / Table        │   Selected item      │
│          │    with selection      │   details, actions   │
│          │                        │                      │
│          │                        │   On mobile: full    │
│          │                        │   screen overlay     │
└──────────┴────────────────────────┴──────────────────────┘
```

### Step 7: Responsive Breakpoint Planning
Define how each screen transforms across breakpoints:

#### Breakpoint Behavior Matrix
```
RESPONSIVE PLAN: <Screen Name>
┌─────────────────────────────────────────────────────────────────────────┐
│ Element          │ Mobile (< 768)  │ Tablet (768-1279) │ Desktop (1280+)│
├─────────────────────────────────────────────────────────────────────────┤
│ Navigation       │ Bottom tabs     │ Icon rail (64px)  │ Sidebar (240px)│
│ Search           │ Full-width bar  │ Topbar inline     │ Topbar inline  │
│ Page title       │ Left-aligned    │ Left-aligned      │ Left-aligned   │
│ Primary CTA      │ Compact icon    │ Icon + label      │ Full button    │
│ Card grid        │ 1 column        │ 2 columns         │ 3 columns      │
│ Card layout      │ Horizontal      │ Vertical          │ Vertical       │
│ Card image       │ 80px thumbnail  │ Full-width top    │ Full-width top │
│ Filters          │ Bottom sheet    │ Dropdown           │ Dropdown       │
│ Pagination       │ Load more btn   │ Page numbers      │ Page numbers   │
│ Detail panel     │ Full screen     │ Slide-over (50%)  │ Inline (1/3)   │
│ Data tables      │ Card stack      │ Horizontal scroll │ Full table     │
│ Modals           │ Full screen     │ Centered (600px)  │ Centered (600px│
│ Sidebar content  │ Hidden (drawer) │ Collapsed (rail)  │ Expanded       │
│ Spacing (gap)    │ 12px            │ 16px              │ 24px           │
│ Typography scale │ 0.875-1.5rem    │ 1-2rem            │ 1-2.5rem       │
└─────────────────────────────────────────────────────────────────────────┘

BREAKPOINT TRANSITIONS:
  Mobile → Tablet (768px):
    - Bottom nav disappears, icon rail appears
    - Cards switch from 1-col horizontal to 2-col vertical
    - Filter moves from bottom sheet to dropdown

  Tablet → Desktop (1280px):
    - Icon rail expands to full sidebar with labels
    - Cards switch from 2-col to 3-col
    - Detail panel goes from slide-over to inline
```

#### Responsive Wireframe Comparison
```
RESPONSIVE COMPARISON: Dashboard

MOBILE (375px)          TABLET (768px)             DESKTOP (1280px)
┌─────────────┐  ┌──────────────────────┐  ┌──────────────────────────────┐
│ [☰] App [🔔]│  │ Logo  Search  [🔔][A]│  │ Logo     Search       [🔔][A]│
├─────────────┤  ├───┬──────────────────┤  ├─────────┬────────────────────┤
│ [Search...] │  │[i]│ Title    [+][Fil]│  │ Dash    │ Title     [+][Fil]│
│ Title  [+]  │  │[i]│                  │  │ Proj  ● │                    │
│ ─────────── │  │[i]│ ┌────┐  ┌────┐  │  │ Tasks   │ ┌────┐┌────┐┌───┐│
│ ┌─────────┐ │  │[i]│ │Card│  │Card│  │  │ Msgs    │ │Card││Card││Car││
│ │[I] Title│ │  │[i]│ │    │  │    │  │  │ Reprt   │ │    ││    ││   ││
│ │    Desc │ │  │   │ └────┘  └────┘  │  │ ─────── │ └────┘└────┘└───┘│
│ └─────────┘ │  │   │ ┌────┐  ┌────┐  │  │ Settng  │ ┌────┐┌────┐┌───┐│
│ ┌─────────┐ │  │   │ │Card│  │Card│  │  │ Help    │ │Card││Card││Car││
│ │[I] Title│ │  │   │ │    │  │    │  │  │         │ │    ││    ││   ││
│ │    Desc │ │  │   │ └────┘  └────┘  │  │         │ └────┘└────┘└───┘│
│ └─────────┘ │  │   │                  │  │         │                    │
│ [Load More] │  │   │  ◄ 1 2 3 ... ►  │  │         │  ◄ 1 2 3 ... 12 ► │
├─────────────┤  └───┴──────────────────┘  └─────────┴────────────────────┘
│[H][S][+][I][M]│
└─────────────┘
```

### Step 8: Interactive Prototype Specification
Define interactions, transitions, and states without needing a design tool:

#### Interaction Specification
```
INTERACTION SPEC: <Component / Screen>
┌────────────────────────────────────────────────────────────────────────┐
│ Trigger              │ Action                  │ Result                 │
├────────────────────────────────────────────────────────────────────────┤
│ Click [+ New]        │ Open modal              │ CreateProject modal    │
│                      │ Transition: slide up    │ Backdrop: dim 50%      │
│                      │ Duration: 200ms ease-out│ Focus: first input     │
│                      │                         │                        │
│ Click Card           │ Navigate                │ → Project Detail (S-08)│
│                      │ Transition: slide left  │ Duration: 150ms        │
│                      │                         │                        │
│ Click [Filter]       │ Open dropdown           │ Filter menu appears    │
│                      │ Transition: scale-in    │ Duration: 150ms        │
│                      │ Dismiss: click outside  │ Auto-close on select   │
│                      │                         │                        │
│ Type in [Search]     │ Show typeahead          │ Results after 300ms    │
│                      │ Debounce: 300ms         │ Max 5 results shown    │
│                      │ Escape: close           │ Enter: navigate first  │
│                      │                         │                        │
│ Long press Card (mob)│ Open context menu       │ Bottom sheet with      │
│                      │ Haptic feedback: light  │ Edit, Delete, Share    │
│                      │                         │                        │
│ Swipe left Card (mob)│ Reveal actions          │ Delete (red), Archive  │
│                      │ Threshold: 80px         │ Snap back if < 80px    │
│                      │                         │                        │
│ Scroll to bottom     │ Load more (mobile)      │ Spinner, append items  │
│                      │ Threshold: 200px from   │ No more: "End of list" │
│                      │ bottom                  │                        │
│                      │                         │                        │
│ Ctrl+K / Cmd+K       │ Open command palette    │ Global search modal    │
│                      │ Transition: fade in     │ Focus: search input    │
└────────────────────────────────────────────────────────────────────────┘
```

#### Screen State Map
```
STATES: <Screen Name>
┌────────────────────────────────────────────────────────────┐
│ State           │ Condition            │ UI Treatment        │
├────────────────────────────────────────────────────────────┤
│ Loading         │ Initial data fetch   │ Skeleton cards (6)  │
│                 │                      │ Pulsing animation   │
│                 │                      │                     │
│ Empty           │ 0 items              │ Illustration +      │
│                 │                      │ "No projects yet"   │
│                 │                      │ [Create your first] │
│                 │                      │                     │
│ Populated       │ 1+ items             │ Card grid + paging  │
│                 │                      │                     │
│ Filtered empty  │ Filters active,      │ "No results for     │
│                 │ 0 matches            │ current filters"    │
│                 │                      │ [Clear filters]     │
│                 │                      │                     │
│ Error           │ API failure          │ Error illustration  │
│                 │                      │ "Something went     │
│                 │                      │ wrong" [Retry]      │
│                 │                      │                     │
│ Offline         │ No network           │ Stale data + banner │
│                 │                      │ "You are offline"   │
│                 │                      │                     │
│ Searching       │ Query entered        │ Inline search       │
│                 │                      │ results overlay     │
│                 │                      │                     │
│ Selecting       │ Multi-select mode    │ Checkboxes on cards │
│                 │                      │ Bulk action toolbar │
└────────────────────────────────────────────────────────────┘
```

### Step 9: Design Tokens Extraction
When working from mockups or Figma files, extract the implicit design tokens:

#### Token Extraction Report
```
DESIGN TOKENS EXTRACTED FROM WIREFRAME:

COLORS (inferred from usage):
  --color-bg:              #f9fafb (page background)
  --color-surface:         #ffffff (card, modal backgrounds)
  --color-text-primary:    #111827 (headings, primary text)
  --color-text-secondary:  #6b7280 (descriptions, metadata)
  --color-primary:         #3b82f6 (CTAs, active indicators)
  --color-primary-hover:   #2563eb (button hover)
  --color-border:          #e5e7eb (card borders, dividers)
  --color-border-focus:    #3b82f6 (input focus ring)
  --color-error:           #ef4444 (delete actions, errors)
  --color-success:         #22c55e (success states)

SPACING (inferred from layout):
  --spacing-xs:   4px   (inline icon gaps)
  --spacing-sm:   8px   (tag gaps, compact padding)
  --spacing-md:   16px  (card padding, section gaps)
  --spacing-lg:   24px  (grid gutters, section padding)
  --spacing-xl:   32px  (page margins tablet)
  --spacing-2xl:  48px  (section vertical spacing)

TYPOGRAPHY (inferred from hierarchy):
  --font-size-xs:   12px  (metadata, badges)
  --font-size-sm:   14px  (secondary text, nav items)
  --font-size-base: 16px  (body text, card descriptions)
  --font-size-lg:   18px  (card titles)
  --font-size-xl:   20px  (section headings)
  --font-size-2xl:  24px  (page titles)
  --font-size-3xl:  30px  (hero headings)

BORDERS & RADIUS:
  --radius-sm:   4px   (tags, badges)
  --radius-md:   8px   (cards, inputs)
  --radius-lg:   12px  (modals, drawers)
  --radius-full: 9999px (avatars, pills)
  --border-width: 1px
  --border-color: var(--color-border)

SHADOWS:
  --shadow-sm:   0 1px 2px rgba(0,0,0,0.05)    (cards default)
  --shadow-md:   0 4px 6px rgba(0,0,0,0.07)    (cards hover)
  --shadow-lg:   0 10px 15px rgba(0,0,0,0.1)   (modals, dropdowns)
  --shadow-xl:   0 20px 25px rgba(0,0,0,0.1)   (popovers)

SIZING:
  --topbar-height:   64px
  --sidebar-width:   240px
  --rail-width:      64px
  --card-min-width:  280px
  --card-max-width:  400px
  --modal-width:     560px
  --avatar-sm:       32px
  --avatar-md:       40px
  --avatar-lg:       64px
  --icon-sm:         16px
  --icon-md:         20px
  --icon-lg:         24px
  --touch-target:    44px (minimum tappable area)
```

### Step 10: Figma-to-Code Translation Guidance
When a Figma file exists, provide a structured translation plan:

#### Figma Analysis Framework
```
FIGMA-TO-CODE TRANSLATION:

SOURCE: <Figma file name / URL>
PAGES ANALYZED: <N>
FRAMES ANALYZED: <N>

LAYER MAPPING:
┌──────────────────────────────────────────────────────────────────────┐
│ Figma Layer / Frame       │ Code Component        │ Notes             │
├──────────────────────────────────────────────────────────────────────┤
│ Frame "Hero Section"      │ <HeroSection />       │ Full-bleed layout │
│  ├── "Headline"           │   <h1>                │ fluid-3xl token   │
│  ├── "Subheadline"        │   <p>                 │ fluid-lg token    │
│  ├── "CTA Button"         │   <Button variant=    │ primary, size=lg  │
│  │                        │     "primary" />      │                   │
│  └── "Hero Image"         │   <picture> srcset    │ art direction     │
│                           │                       │                   │
│ Frame "Feature Grid"      │ <FeatureGrid />       │ auto-fit grid     │
│  └── "Feature Card" (x3)  │   <FeatureCard />     │ min 300px cols    │
│       ├── "Icon"          │     <Icon name={} />  │ from icon system  │
│       ├── "Title"         │     <h3>              │ font-size-lg      │
│       └── "Description"   │     <p>               │ font-size-base    │
│                           │                       │                   │
│ Frame "Testimonials"      │ <TestimonialCarousel/>│ horizontal scroll │
│  └── "Testimonial" (x5)   │   <TestimonialCard /> │ scroll-snap       │
│       ├── "Avatar"        │     <Avatar />        │ 48px, rounded     │
│       ├── "Quote"         │     <blockquote>      │ font-style-italic │
│       └── "Attribution"   │     <cite>            │ font-size-sm      │
└──────────────────────────────────────────────────────────────────────┘

FIGMA VARIANTS → CODE PROPS:
┌──────────────────────────────────────────────────────────────────────┐
│ Figma Component   │ Variant Property  │ Code Prop                    │
├──────────────────────────────────────────────────────────────────────┤
│ Button            │ Type: Primary     │ variant="primary"            │
│                   │ Type: Secondary   │ variant="secondary"          │
│                   │ Type: Ghost       │ variant="ghost"              │
│                   │ Size: Small       │ size="sm"                    │
│                   │ Size: Medium      │ size="md"                    │
│                   │ Size: Large       │ size="lg"                    │
│                   │ State: Disabled   │ disabled={true}              │
│                   │ State: Loading    │ loading={true}               │
│                   │                   │                              │
│ Input             │ State: Default    │ (default)                    │
│                   │ State: Focused    │ :focus-visible CSS           │
│                   │ State: Error      │ error={true}                 │
│                   │ State: Disabled   │ disabled={true}              │
│                   │ Has Icon: Yes     │ icon={<Icon />}              │
│                   │ Has Label: Yes    │ label="..."                  │
└──────────────────────────────────────────────────────────────────────┘

FIGMA AUTO-LAYOUT → CSS:
  - Horizontal, gap 16, padding 24 → display: flex; gap: 16px; padding: 24px;
  - Vertical, gap 8, fill container → display: flex; flex-direction: column; gap: 8px; width: 100%;
  - Wrap, gap 12                    → display: flex; flex-wrap: wrap; gap: 12px;
  - Grid 3 cols, gap 24            → display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px;

FIGMA CONSTRAINTS → CSS:
  - Left & Right, Fill              → width: 100%;
  - Center                          → margin-inline: auto;
  - Scale                           → width: <percentage>;
  - Fixed width                     → width: <px>; (prefer max-width)

IMPLEMENTATION ORDER:
  1. Extract tokens → create token CSS files
  2. Build atoms → Button, Input, Icon, Avatar, Badge
  3. Build molecules → Card, FormField, SearchBar
  4. Build organisms → Header, Sidebar, FeatureGrid
  5. Build templates → PageLayout, MarketingLayout
  6. Assemble pages → LandingPage, DashboardPage
```

### Step 11: Wireframe Summary Report

```
+---------------------------------------------------------------------+
|  WIREFRAME REPORT — <project>                                        |
+---------------------------------------------------------------------+
|  Scope: <single screen / feature / full app>                         |
|  Screens: <N> total (<N> new, <N> modified)                          |
|  Flows: <N> user flows mapped                                        |
|                                                                      |
|  Screen Inventory:                                                   |
|  <list screens with IDs>                                             |
|                                                                      |
|  Navigation:                                                         |
|  Pattern: <sidebar / topbar / bottom tabs>                           |
|  Levels: <N> navigation levels                                       |
|  Mobile strategy: <bottom tabs + hamburger / drawer / tabs>          |
|                                                                      |
|  Components:                                                         |
|  Unique components identified: <N>                                   |
|  Atoms: <N>  Molecules: <N>  Organisms: <N>  Templates: <N>         |
|                                                                      |
|  Grid System:                                                        |
|  Mobile: <N>-col  Tablet: <N>-col  Desktop: <N>-col                 |
|  Gutter: <size>  Margin: <size>  Max-width: <size>                   |
|                                                                      |
|  Responsive Strategy:                                                |
|  Approach: <mobile-first / desktop-first / intrinsic>                |
|  Breakpoints: <list breakpoints>                                     |
|  Major transforms: <N> layout changes across breakpoints             |
|                                                                      |
|  Tokens Extracted: <N> tokens across <N> categories                  |
|                                                                      |
|  Figma Translation:                                                  |
|  Components mapped: <N>/<N> Figma components                         |
|  Variants mapped: <N> variant-to-prop mappings                       |
|                                                                      |
|  Interactive States:                                                 |
|  Interactions defined: <N>                                           |
|  Screen states covered: <N> states per screen avg                    |
|                                                                      |
|  Next Steps:                                                         |
|  1. <first implementation action>                                    |
|  2. <second implementation action>                                   |
|  3. <third implementation action>                                    |
+---------------------------------------------------------------------+
```

### Step 12: Commit and Transition
1. If wireframes were produced:
   - Save wireframes: `docs/wireframes/<project>-wireframes.md`
   - Commit: `"wireframe: <project> — <N> screens wireframed with responsive breakpoints"`
2. If sitemap was produced:
   - Save sitemap: `docs/wireframes/<project>-sitemap.md`
   - Commit: `"wireframe: <project> — sitemap and screen inventory (<N> screens)"`
3. If Figma translation was completed:
   - Save mapping: `docs/wireframes/<project>-figma-mapping.md`
   - Commit: `"wireframe: <project> — Figma-to-code component mapping (<N> components)"`
4. If design tokens were extracted:
   - Save tokens: `docs/wireframes/<project>-tokens.md`
   - Commit: `"wireframe: <project> — design tokens extracted (<N> tokens)"`
5. Transition suggestions:
   - "Wireframes complete. Run `/godmode:ui` to build the component library."
   - "Wireframes complete. Run `/godmode:responsive` to implement responsive layouts."
   - "Wireframes complete. Run `/godmode:designsystem` to formalize the design tokens."
   - "Wireframes complete. Run `/godmode:scaffold` to generate project structure from the wireframes."

## Key Behaviors

1. **Structure before pixels.** Wireframes define information hierarchy, component boundaries, and user flow — not colors, fonts, or visual polish. If a wireframe looks "designed," it is too detailed. Keep it lo-fi.
2. **Every screen has states.** A screen is not one static view. It has loading, empty, populated, error, and offline states at minimum. Define all states in the wireframe, not just the happy path.
3. **Responsive is not optional.** Every wireframe must show at least mobile and desktop variants. If the wireframe only exists at one breakpoint, it is incomplete. Define how every major element transforms.
4. **Components emerge from wireframes.** The wireframe is where you discover the component hierarchy. If two screens share the same card layout, that is a reusable component. Identify it explicitly.
5. **Navigation flow is architecture.** How screens connect is as important as what is on each screen. Every wireframe set must include a navigation flow showing how users move between screens and what triggers transitions.
6. **Annotate intent, not implementation.** Wireframe annotations explain what an element does and why, not how to code it. "[Search] — global search with typeahead, Ctrl+K shortcut" is good. "Use React portal with debounced input" belongs in implementation, not wireframes.
7. **Tokens extracted early save time later.** Extracting spacing, typography, and color patterns from wireframes before coding prevents ad-hoc values from creeping in. The wireframe phase is where the design token vocabulary is established.

## Example Usage

### Wireframe a new feature
```
User: /godmode:wireframe Wireframe a project management dashboard.
      Sidebar nav, card grid for projects, search, and filters.

Wireframe: Gathering context...

WIREFRAME CONTEXT:
Project: Project Management Dashboard
Scope: Single feature (dashboard screen)
Platform: Responsive web
Framework: React + Tailwind

Producing wireframes...

SCREEN INVENTORY:
  S-01: Dashboard (card grid overview)
  S-02: Project Detail
  S-03: Create Project (modal)

WIREFRAME: Dashboard — Desktop (1280px)
┌─────────────────────────────────────────────────────────┐
│ [Logo]        [Search........]       [Bell] [Avatar ▼]  │
├──────────┬──────────────────────────────────────────────┤
│ Dashboard│  My Projects (24)        [+ New] [Filter ▼]  │
│ Projects●│  ────────────────────────────────────────── │
│ Tasks    │  ┌─ Card ──┐ ┌─ Card ──┐ ┌─ Card ──┐       │
│ Team     │  │ Title   │ │ Title   │ │ Title   │       │
│ Reports  │  │ 3 tasks │ │ 7 tasks │ │ 1 task  │       │
│          │  │ [Team]  │ │ [Team]  │ │ [Team]  │       │
│ Settings │  └─────────┘ └─────────┘ └─────────┘       │
└──────────┴──────────────────────────────────────────────┘

WIREFRAME: Dashboard — Mobile (375px)
┌─────────────────────┐
│ [☰] Dashboard [🔔]  │
│ [Search...........]  │
│ My Projects   [+]   │
│ ┌───────────────┐   │
│ │ Title  3 tasks│   │
│ │ [Team avatars]│   │
│ └───────────────┘   │
│ ┌───────────────┐   │
│ │ Title  7 tasks│   │
│ │ [Team avatars]│   │
│ └───────────────┘   │
│ [Load more]         │
├─────────────────────┤
│[🏠][📋][+][👤][≡]  │
└─────────────────────┘

COMPONENT HIERARCHY:
├── AppShell
│   ├── Topbar (Logo, Search, Notifications, UserMenu)
│   ├── Sidebar / BottomNav
│   └── MainContent
│       ├── PageHeader (title, count, CTA, filter)
│       ├── ProjectCardGrid
│       │   └── ProjectCard (title, task count, team avatars)
│       └── Pagination / LoadMore

RESPONSIVE PLAN:
  Mobile: Bottom nav, 1-col cards, load-more
  Tablet: Icon rail, 2-col cards, pagination
  Desktop: Full sidebar, 3-col cards, pagination

Tokens extracted: 24 tokens (6 colors, 6 spacing, 6 type, 3 radius, 3 shadow)

Next: Run /godmode:ui to build these components.
```

### Translate a Figma design to code plan
```
User: /godmode:wireframe --figma I have a Figma design for a landing page.
      Help me plan the component structure.

Wireframe: Analyzing Figma structure...

FIGMA-TO-CODE TRANSLATION:
  Frames analyzed: 3 (Desktop, Tablet, Mobile)
  Components found: 12 Figma components

Layer mapping:
  Hero Section → <HeroSection />
    CTA Button → <Button variant="primary" size="lg" />
  Feature Grid → <FeatureGrid /> (CSS Grid auto-fit)
    Feature Card → <FeatureCard /> (Icon + Title + Desc)
  Testimonials → <TestimonialCarousel /> (scroll-snap)
  Pricing Table → <PricingSection />
    Price Card → <PriceCard /> (3 variants: basic/pro/enterprise)
  Footer → <Footer /> (4-col grid → 2-col tablet → 1-col mobile)

Variant mappings: 8 Figma variants → React props
Token extraction: 32 tokens from Figma styles

Implementation order:
  1. Tokens (from Figma styles)
  2. Atoms (Button, Icon, Badge)
  3. Cards (FeatureCard, PriceCard, TestimonialCard)
  4. Sections (Hero, Features, Testimonials, Pricing, Footer)
  5. Page assembly (LandingPage)

Next: Run /godmode:designsystem --tokens to formalize the extracted tokens.
```

### Plan a multi-screen flow
```
User: /godmode:wireframe --flow Map the checkout flow for an e-commerce app.

Wireframe: Mapping checkout flow...

FLOW: Checkout (4 screens, 2 decision points)

[Cart] → [Shipping Info] → [Payment] → [Review & Confirm] → [Order Complete]
                │                │
           Save address?    Save card?
           ├ Yes: autofill  ├ Yes: store
           └ No: manual     └ No: one-time

Screen states per step:
  Cart: empty, populated, updating quantity, applying coupon
  Shipping: form default, validation errors, address lookup
  Payment: form default, card validation, processing
  Review: summary, editing, submitting, error
  Complete: success, order number, suggested products

Wireframes produced for all 5 screens at mobile + desktop.
Navigation: back button at each step, progress indicator (1/4, 2/4...).
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full wireframe workflow — context, inventory, wireframes, components |
| `--screen <name>` | Wireframe a single screen at all breakpoints |
| `--flow <name>` | Map a specific user flow with screen transitions |
| `--sitemap` | Screen inventory and sitemap only |
| `--components` | Component hierarchy extraction from existing screens |
| `--responsive` | Responsive breakpoint plan for existing wireframes |
| `--figma` | Figma-to-code translation and component mapping |
| `--tokens` | Design token extraction from wireframes or mockups |
| `--states` | Screen state map (loading, empty, error, etc.) |
| `--interactions` | Interactive prototype specification |
| `--grid` | Page structure and grid system definition |
| `--inventory` | Screen inventory audit of existing application |

## HARD RULES

1. **NEVER add visual design to wireframes.** Wireframes show structure, not aesthetics. Use placeholder tokens like `[primary color]` and `body text`, not exact colors or fonts.
2. **NEVER wireframe only the happy path.** Every screen must show zero-data, loading, error, and populated states.
3. **NEVER skip the mobile wireframe.** Mobile constraints force prioritization decisions that improve the desktop design. Wireframe mobile first or simultaneously.
4. **ALWAYS decompose wireframes into a component hierarchy.** A wireframe that is not broken into reusable components is a picture, not architecture.
5. **ALWAYS define navigation flows before or alongside individual screens.** A screen makes no sense without knowing how the user arrived and where they can go.
6. **ALWAYS audit existing patterns first.** If the app already has a sidebar layout and card grid, reuse those patterns. New structural patterns create inconsistency.
7. **NEVER create wireframes that cannot be built.** Layouts requiring five nested scroll containers and three overlapping z-index layers are not helpful. Use standard layout techniques.
8. **ALWAYS include screen state maps** showing all states per screen (default, loading, empty, error, success, partial).

## Auto-Detection

On activation, detect the wireframing context:

```bash
# Detect existing UI framework
grep -r "react\|vue\|svelte\|@angular" package.json 2>/dev/null

# Detect component library
grep -r "radix\|shadcn\|chakra\|mantine\|headless" package.json 2>/dev/null

# Detect existing routes/pages
find src/ -path "*/pages/*" -o -path "*/routes/*" -o -path "*/views/*" 2>/dev/null | head -15

# Detect design system files
find . -name "*.figma" -o -name "tokens.*" -o -name "theme.*" 2>/dev/null

# Count existing components
find src/ -name "*.tsx" -o -name "*.vue" -o -name "*.svelte" 2>/dev/null | wc -l
```

## Anti-Patterns

- **Do NOT add visual design to wireframes.** Wireframes show structure, not aesthetics. The moment you specify exact colors, gradients, or font faces in a wireframe, you have crossed into visual design. Use placeholder tokens like `[primary color]` and `body text` instead.
- **Do NOT wireframe only the happy path.** A screen with data is the easiest case. What does the screen look like with zero items? During loading? After an error? If your wireframe does not answer these questions, it is incomplete.
- **Do NOT skip the mobile wireframe.** "We will figure out mobile later" means "we will redesign everything later." Mobile constraints force prioritization decisions that improve the desktop design too. Wireframe mobile first or at the same time.
- **Do NOT produce wireframes without a component hierarchy.** A wireframe that is not decomposed into components is a picture, not an architecture document. Every wireframe must identify which elements are reusable components and how they nest.
- **Do NOT confuse wireframes with prototypes.** Wireframes define structure and content priority. Prototypes define interaction and motion. Produce wireframes first, then add interaction specs as a separate layer. Trying to do both at once muddies the structural decisions.
- **Do NOT wireframe in isolation from the navigation model.** A screen makes no sense without knowing how the user arrived and where they can go next. Define navigation flows before or alongside individual screen wireframes.
- **Do NOT ignore existing patterns.** If the application already has a sidebar layout, card grid, and modal pattern, the new wireframe should reuse those patterns. Inventing new structural patterns for every new screen creates inconsistency. Audit what exists first.
- **Do NOT create wireframes that cannot be built.** ASCII wireframes showing a layout that requires five nested scroll containers and three overlapping z-index layers are not helpful. The wireframe should be implementable with standard layout techniques (Grid, Flexbox, standard stacking context).
