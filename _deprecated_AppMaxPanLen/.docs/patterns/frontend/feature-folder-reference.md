# Feature-Folder Structure Pattern

**Pattern Type:** Frontend Architecture  
**Best For:** React applications with multiple features  
**Source:** Habit Tracker  
**Complexity:** ⭐⭐⭐☆☆

---

## Overview

Feature-folder structure organizes frontend code by business features rather than technical layers. Each feature contains all related components, hooks, API clients, and utilities in a self-contained module.

**Key Characteristics:**
- Feature-based organization (not layer-based)
- Encapsulation and clear boundaries
- Reusable through exports
- Scalable for growing applications
- Easy to understand and navigate

---

## When to Use

### ✅ Use Feature Folders For:
- **Multi-feature applications** (more than 3-4 screens)
- **Team-based development** (multiple developers)
- **Modular business domains** (habits, calendar, settings)
- **Growing codebases** (easier to scale)
- **Shared components** (need clear boundaries)

### ❌ Don't Use Feature Folders For:
- **Tiny apps** (< 3 features, use flat structure)
- **Prototypes** (premature abstraction)
- **Single-page apps** (one main view)

---

## Basic Structure

### Traditional Layer-Based (❌ Avoid)

```
src/
├── components/
│   ├── HabitCard.jsx
│   ├── HabitForm.jsx
│   ├── HabitList.jsx
│   ├── Calendar.jsx
│   └── CalendarDay.jsx
├── hooks/
│   ├── useHabits.js
│   └── useCompletions.js
├── api/
│   ├── habits.js
│   └── completions.js
└── utils/
    └── date.js
```

**Problems:**
- ❌ Hard to find related code
- ❌ No feature boundaries
- ❌ Everything is global
- ❌ Difficult to remove features
- ❌ No clear ownership

---

### Feature-Based Structure (✅ Recommended)

```
src/
├── App.jsx
├── main.jsx
├── features/
│   ├── habits/
│   │   ├── index.js              # Public API
│   │   ├── components/
│   │   │   ├── HabitCard.jsx
│   │   │   ├── HabitForm.jsx
│   │   │   └── HabitList.jsx
│   │   ├── hooks/
│   │   │   └── useHabits.js
│   │   └── api/
│   │       └── habits.js
│   │
│   └── calendar/
│       ├── index.js              # Public API
│       ├── components/
│       │   ├── Calendar.jsx
│       │   ├── CalendarGrid.jsx
│       │   └── CalendarDay.jsx
│       ├── hooks/
│       │   └── useCompletions.js
│       └── utils/
│           └── date.js
│
├── components/                   # Shared UI components
│   └── ui/
│       ├── Button.jsx
│       ├── Card.jsx
│       └── ConfirmDialog.jsx
│
├── lib/                          # Shared utilities
│   └── api.js
│
└── pages/                        # Page-level components
    └── Dashboard.jsx
```

**Benefits:**
- ✅ Clear feature boundaries
- ✅ Easy to find code
- ✅ Self-contained features
- ✅ Reusable through exports
- ✅ Easy to delete features

---

## Feature Module Structure

### Standard Feature Layout

```
features/
└── habits/
    ├── index.js              # Public exports (API surface)
    ├── components/
    │   ├── HabitCard.jsx     # Feature-specific components
    │   ├── HabitForm.jsx
    │   └── HabitList.jsx
    ├── hooks/
    │   └── useHabits.js      # Custom React hooks
    ├── api/
    │   └── habits.js         # API client functions
    ├── utils/
    │   └── validation.js     # Feature utilities (optional)
    └── types/
        └── habit.ts          # TypeScript types (optional)
```

---

### Public API (index.js)

**Export only what other features need:**

```javascript
// features/habits/index.js

// Export components
export { HabitCard } from './components/HabitCard';
export { HabitForm } from './components/HabitForm';
export { HabitList } from './components/HabitList';

// Export hooks
export {
  useHabits,
  useHabit,
  useCreateHabit,
  useUpdateHabit,
  useDeleteHabit,
  useCompleteHabit,
  useUncompleteHabit,
  useSkipHabit,
} from './hooks/useHabits';

// Don't export:
// - Internal components (HabitCardHeader, HabitCardActions)
// - API functions (fetchHabits, createHabit) - use hooks instead
// - Utilities (unless needed by other features)
```

**Principle:** Feature's public API = what can be imported elsewhere

---

## Components Organization

### Feature Components

**`features/habits/components/HabitCard.jsx`:**
```jsx
import { useState } from 'react';
import { Check, Flame, Pencil, Trash2 } from 'lucide-react';
import clsx from 'clsx';
import { Card } from '../../../components/ui/Card';
import { useCompleteHabit, useDeleteHabit } from '../hooks/useHabits';
import { ConfirmDialog } from '../../../components/ui/ConfirmDialog';

export function HabitCard({ habit }) {
  const [showDeleteDialog, setShowDeleteDialog] = useState(false);
  const { mutate: complete, isPending } = useCompleteHabit();
  const { mutate: deleteHabit } = useDeleteHabit();

  return (
    <Card className="overflow-hidden">
      <div className="flex items-stretch">
        <div className="w-2" style={{ backgroundColor: habit.color }} />
        
        <div className="flex-1 p-4">
          <h3 className="font-semibold">{habit.name}</h3>
          <p className="text-sm text-gray-500">{habit.description}</p>
          
          <div className="flex items-center gap-2 mt-4">
            <Flame className="w-4 h-4 text-orange-500" />
            <span className="text-sm font-medium">{habit.current_streak} day streak</span>
          </div>
        </div>

        <button
          onClick={() => complete({ id: habit.id, date: new Date() })}
          disabled={isPending}
          className={clsx(
            'w-10 h-10 rounded-full flex items-center justify-center',
            habit.completed_today
              ? 'bg-green-500 text-white'
              : 'border-2 border-gray-300 hover:border-green-500'
          )}
        >
          {habit.completed_today && <Check className="w-5 h-5" />}
        </button>
      </div>

      <ConfirmDialog
        open={showDeleteDialog}
        onClose={() => setShowDeleteDialog(false)}
        onConfirm={() => deleteHabit(habit.id)}
        title="Delete Habit"
        message={`Are you sure you want to delete "${habit.name}"?`}
      />
    </Card>
  );
}
```

**Key patterns:**
- Feature components import from `../hooks/` (relative)
- Feature components import shared UI from `../../../components/ui/` (absolute)
- Feature components use icons from lucide-react
- Feature components manage local state (dialogs, forms)

---

### Shared Components

**Shared UI lives outside features:**

```
components/
└── ui/
    ├── Button.jsx
    ├── Card.jsx
    ├── ConfirmDialog.jsx
    └── Spinner.jsx
```

**`components/ui/Card.jsx`:**
```jsx
import clsx from 'clsx';

export function Card({ children, className }) {
  return (
    <div className={clsx('bg-white rounded-lg shadow-sm border border-gray-200', className)}>
      {children}
    </div>
  );
}

Card.Header = function CardHeader({ children, className }) {
  return <div className={clsx('px-4 py-3 border-b border-gray-200', className)}>{children}</div>;
};

Card.Body = function CardBody({ children, className }) {
  return <div className={clsx('px-4 py-3', className)}>{children}</div>;
};
```

**When to create shared components:**
- Used by 2+ features
- Generic UI primitives (Button, Card, Input)
- No business logic
- Highly reusable

---

## Hooks Organization

### Feature Hooks

**`features/habits/hooks/useHabits.js`:**
```javascript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { fetchHabits, createHabit, deleteHabit } from '../api/habits';

export function useHabits() {
  return useQuery({
    queryKey: ['habits'],
    queryFn: async () => {
      const data = await fetchHabits();
      return data.habits;
    },
  });
}

export function useCreateHabit() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: createHabit,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['habits'] });
    },
  });
}

export function useDeleteHabit() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: deleteHabit,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['habits'] });
    },
  });
}
```

**Hook patterns:**
- One hook per operation (useHabits, useCreateHabit)
- Hooks encapsulate API calls
- Hooks manage cache invalidation
- Hooks return loading/error states

---

### Shared Hooks

**Custom hooks used across features:**

```
lib/
└── hooks/
    ├── useDebounce.js
    ├── useLocalStorage.js
    └── useMediaQuery.js
```

---

## API Client Organization

### Feature API Client

**`features/habits/api/habits.js`:**
```javascript
import { request } from '../../../lib/api';

export async function fetchHabits() {
  return request('/habits');
}

export async function fetchHabit(id) {
  return request(`/habits/${id}`);
}

export async function createHabit(data) {
  return request('/habits', {
    method: 'POST',
    body: JSON.stringify(data),
  });
}

export async function updateHabit(id, data) {
  return request(`/habits/${id}`, {
    method: 'PUT',
    body: JSON.stringify(data),
  });
}

export async function deleteHabit(id) {
  return request(`/habits/${id}`, {
    method: 'DELETE',
  });
}
```

**API client patterns:**
- One function per endpoint
- Use shared `request()` utility
- Return promises (handled by hooks)
- Export for testing

---

### Shared API Utility

**`lib/api.js`:**
```javascript
const API_BASE = '/api';

export async function request(endpoint, options = {}) {
  const response = await fetch(`${API_BASE}${endpoint}`, {
    headers: {
      'Content-Type': 'application/json',
      ...options.headers,
    },
    ...options,
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(error.detail || 'An error occurred');
  }

  if (response.status === 204) return null;
  return response.json();
}
```

---

## Pages Organization

### Page Components

**Pages compose features:**

```
pages/
├── Dashboard.jsx
├── Settings.jsx
└── Profile.jsx
```

**`pages/Dashboard.jsx`:**
```jsx
import { useState } from 'react';
import { Plus } from 'lucide-react';
import { HabitList, HabitForm } from '../features/habits';
import { Button } from '../components/ui/Button';
import { Card } from '../components/ui/Card';

export function Dashboard() {
  const [showForm, setShowForm] = useState(false);

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white shadow-sm">
        <div className="max-w-3xl mx-auto px-4 py-4 flex items-center justify-between">
          <h1 className="text-xl font-bold">Habit Tracker</h1>
          <Button onClick={() => setShowForm(true)}>
            <Plus className="w-4 h-4 mr-2" />
            Add Habit
          </Button>
        </div>
      </header>

      <main className="max-w-3xl mx-auto px-4 py-6">
        <HabitList />
      </main>

      {showForm && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
          <Card className="w-full max-w-md">
            <Card.Header>
              <h2 className="font-semibold text-lg">Create New Habit</h2>
            </Card.Header>
            <Card.Body>
              <HabitForm onSuccess={() => setShowForm(false)} />
            </Card.Body>
          </Card>
        </div>
      )}
    </div>
  );
}
```

**Page patterns:**
- Import from feature public API (`features/habits`)
- Compose multiple features
- Handle page-level state (modals, routing)
- Use shared components for layout

---

## Import Conventions

### Absolute vs Relative Imports

```javascript
// ✅ Feature-internal imports (relative)
import { useHabits } from '../hooks/useHabits';
import { HabitCard } from './HabitCard';

// ✅ Cross-feature imports (absolute via index.js)
import { HabitList } from '../features/habits';
import { Calendar } from '../features/calendar';

// ✅ Shared components (absolute)
import { Button } from '../components/ui/Button';
import { Card } from '../components/ui/Card';

// ✅ Shared utilities (absolute)
import { request } from '../lib/api';
import { formatDate } from '../lib/utils';
```

---

### Import Order

```javascript
// 1. React
import { useState, useEffect } from 'react';

// 2. External libraries
import { format } from 'date-fns';
import { Check, X } from 'lucide-react';
import clsx from 'clsx';

// 3. Features (other)
import { Calendar } from '../features/calendar';

// 4. Components (shared)
import { Button } from '../components/ui/Button';
import { Card } from '../components/ui/Card';

// 5. Hooks (local)
import { useHabits } from '../hooks/useHabits';

// 6. API (local)
import { fetchHabits } from '../api/habits';

// 7. Utils (local)
import { validateHabit } from '../utils/validation';
```

---

## TypeScript Structure (Optional)

### With TypeScript

```
features/
└── habits/
    ├── index.ts
    ├── components/
    │   ├── HabitCard.tsx
    │   ├── HabitForm.tsx
    │   └── HabitList.tsx
    ├── hooks/
    │   └── useHabits.ts
    ├── api/
    │   └── habits.ts
    └── types/
        └── habit.ts         # Feature-specific types
```

**`features/habits/types/habit.ts`:**
```typescript
export interface Habit {
  id: number;
  name: string;
  description?: string;
  color: string;
  current_streak: number;
  longest_streak: number;
  completed_today: boolean;
  created_at: string;
  updated_at: string;
}

export interface HabitCreate {
  name: string;
  description?: string;
  color: string;
}

export interface HabitUpdate {
  name?: string;
  description?: string;
  color?: string;
}
```

---

## Feature Dependencies

### Cross-Feature Communication

**❌ Don't import internal files:**
```javascript
// ❌ Bad: Importing internal component
import { HabitCard } from '../features/habits/components/HabitCard';

// ❌ Bad: Importing internal API
import { fetchHabits } from '../features/habits/api/habits';
```

**✅ Import from public API:**
```javascript
// ✅ Good: Import from feature's public API
import { HabitCard } from '../features/habits';

// ✅ Good: Use hook instead of API directly
import { useHabits } from '../features/habits';
```

---

### Feature Coupling

**Keep features loosely coupled:**

```
✅ Low Coupling:
- habits/ uses generic Button, Card from components/ui/
- calendar/ uses generic date utilities from lib/
- Features communicate via props and events

❌ High Coupling:
- habits/ imports internal components from calendar/
- Direct API calls between features
- Shared state between features (use context if needed)
```

---

## Scaling Patterns

### Small App (< 5 features)

```
src/
├── features/
│   ├── habits/
│   └── calendar/
├── components/ui/
├── lib/
└── pages/
```

---

### Medium App (5-15 features)

```
src/
├── features/
│   ├── habits/
│   ├── calendar/
│   ├── goals/
│   ├── stats/
│   └── settings/
├── components/
│   ├── ui/
│   └── layout/
├── lib/
├── pages/
└── contexts/         # Global state (auth, theme)
```

---

### Large App (15+ features)

```
src/
├── features/
│   ├── habits/
│   ├── calendar/
│   ├── goals/
│   ├── stats/
│   ├── settings/
│   ├── auth/
│   ├── notifications/
│   └── ...
├── components/
│   ├── ui/
│   ├── layout/
│   └── data-display/
├── lib/
│   ├── api/
│   ├── hooks/
│   └── utils/
├── pages/
├── contexts/
└── services/         # External integrations
```

---

## Migration Strategy

### From Flat to Feature-Based

**Step 1: Create feature folders**
```bash
mkdir -p src/features/habits/{components,hooks,api}
```

**Step 2: Move related files**
```bash
mv src/components/Habit*.jsx src/features/habits/components/
mv src/hooks/useHabits.js src/features/habits/hooks/
mv src/api/habits.js src/features/habits/api/
```

**Step 3: Create public API**
```javascript
// src/features/habits/index.js
export * from './components/HabitCard';
export * from './hooks/useHabits';
```

**Step 4: Update imports**
```javascript
// Before
import { HabitCard } from './components/HabitCard';

// After
import { HabitCard } from './features/habits';
```

**Step 5: Repeat for other features**

---

## Best Practices

### ✅ Do:
- **One feature = one business domain**
- **Export via index.js** (public API)
- **Import from public API** (not internals)
- **Keep features independent** (low coupling)
- **Use shared components** for cross-feature UI
- **Colocate related code** (components, hooks, API)
- **Delete features easily** (self-contained)

### ❌ Don't:
- **Mix multiple features** in one folder
- **Import internal files** from other features
- **Create deep nesting** (max 3-4 levels)
- **Put everything in shared** (feature-specific stays in feature)
- **Create circular dependencies** (features importing each other)
- **Skip public API** (export directly from components)

---

## Common Pitfalls

### Pitfall 1: Feature Folders That Are Too Small

```javascript
// ❌ Bad: One component per feature (too granular)
features/
├── habit-card/
│   └── HabitCard.jsx
├── habit-form/
│   └── HabitForm.jsx
└── habit-list/
    └── HabitList.jsx

// ✅ Good: Group related functionality
features/
└── habits/
    └── components/
        ├── HabitCard.jsx
        ├── HabitForm.jsx
        └── HabitList.jsx
```

---

### Pitfall 2: Generic Names

```javascript
// ❌ Bad: Generic names
features/
├── data/
├── forms/
└── lists/

// ✅ Good: Business domain names
features/
├── habits/
├── calendar/
└── goals/
```

---

### Pitfall 3: Leaking Implementation

```javascript
// ❌ Bad: Exposing internal API functions
export { fetchHabits, createHabit } from './api/habits';

// ✅ Good: Expose hooks only
export { useHabits, useCreateHabit } from './hooks/useHabits';
```

---

## Source References

**Extracted from:**
- Habit Tracker: `frontend/src/features/` (habits, calendar structure)
- Habit Tracker: `frontend/src/features/habits/index.js` (public API pattern)
- Habit Tracker: `frontend/src/pages/Dashboard.jsx` (page composition)

**Related Patterns:**
- 📎 [React Patterns](react-patterns.md) - Component design
- 📎 [TanStack Query Patterns](tanstack-query-patterns.md) - Data fetching
- 📎 [Frontend Testing Patterns](../testing/frontend-testing-patterns.md) - Testing feature folders

---

**Pattern Version:** 1.0.0  
**Last Updated:** March 7, 2026  
**Source Project:** Habit Tracker v1.0.0
