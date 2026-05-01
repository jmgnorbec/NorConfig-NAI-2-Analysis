# Feature-Folder Structure - Overview

**Pattern Type:** Frontend Architecture  
**Complexity:** Intermediate  
**Read Time:** ~3 minutes  
**Best For:** React applications with multiple features (3+ distinct screens/modules)

---

## When to Use This Pattern

### ✅ Use Feature Folders When

- **Multi-feature applications** (habits + calendar + settings)
- **Growing codebase** (more than 10-15 components)
- **Team collaboration** (multiple developers, clear ownership)
- **Modular business domains** (features can be understood independently)
- **Need clear boundaries** (isolate feature logic from shared utilities)

### ❌ Don't Use Feature Folders When

- **Tiny apps** (< 3 features, flat structure is simpler)
- **Prototypes** (premature abstraction adds complexity)
- **Single-page apps** (one main view, minimal features)
- **Team unfamiliar with pattern** (learning curve not worth it for small projects)

### vs. Layer-Based Structure

| Aspect | Layer-Based (❌) | Feature-Based (✅) |
|--------|------------------|-------------------|
| **Organization** | By file type (components/, hooks/) | By business feature (habits/, calendar/) |
| **Finding code** | Search across folders | All related code together |
| **Boundaries** | None (everything is global) | Clear (feature exports via index.js) |
| **Removing feature** | Hunt across folders | Delete one folder |
| **Team ownership** | Unclear | Feature team owns one folder |

**Key insight:** Feature folders trade initial setup complexity for long-term maintainability.

---

## Essential Structure

### Traditional Layer-Based (Avoid)

```
src/
├── components/
│   ├── HabitCard.jsx
│   ├── HabitForm.jsx
│   ├── Calendar.jsx
│   └── CalendarDay.jsx
├── hooks/
│   ├── useHabits.js
│   └── useCompletions.js
└── api/
    ├── habits.js
    └── completions.js
```

**Problems:**
- ❌ Hard to locate related code
- ❌ No feature boundaries (everything is global)
- ❌ Difficult to remove features cleanly

### Feature-Based Structure (Recommended)

```
src/
├── App.jsx
├── features/
│   ├── habits/
│   │   ├── index.js              # Public API (exports)
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
│       │   └── CalendarDay.jsx
│       ├── hooks/
│       │   └── useCompletions.js
│       └── utils/
│           └── date.js
│
└── components/                   # Shared UI components
    └── ui/
        ├── Button.jsx
        ├── Card.jsx
        └── Spinner.jsx
```

**Benefits:**
- ✅ All feature code in one place
- ✅ Clear boundaries (controlled exports)
- ✅ Easy to remove features (delete folder)
- ✅ Team ownership (habits team owns habits/)

---

## Minimal Working Example

### 1. Feature Folder Structure

**`src/features/habits/`:**
```
habits/
├── index.js              # Public exports (controlled API)
├── components/
│   ├── HabitCard.jsx     # Internal component
│   ├── HabitForm.jsx     # Internal component
│   └── HabitList.jsx     # Main component (exported)
├── hooks/
│   └── useHabits.js      # Data fetching (exported)
└── api/
    └── habits.js         # API client (internal)
```

### 2. Feature Public API

**`src/features/habits/index.js`:**
```javascript
// Export only what other features need
export { HabitList } from './components/HabitList';
export { useHabits, useCreateHabit } from './hooks/useHabits';

// HabitCard, HabitForm, API client remain private (not exported)
```

**Why?** Control what's public vs private. Other features can't depend on internal components.

### 3. Using Feature from App

**`src/App.jsx`:**
```jsx
import { HabitList } from './features/habits';        // ✅ Public API
// import { HabitCard } from './features/habits/components/HabitCard';  ❌ Internal, don't import

export default function App() {
  return (
    <div>
      <h1>My Habits</h1>
      <HabitList />
    </div>
  );
}
```

### 4. Feature Components

**`src/features/habits/components/HabitList.jsx`:**
```jsx
import { useHabits } from '../hooks/useHabits';      // Relative import (within feature)
import { HabitCard } from './HabitCard';             // Internal component
import { Button } from '../../../components/ui/Button';  // Shared component

export function HabitList() {
  const { data: habits, isLoading } = useHabits();

  if (isLoading) return <div>Loading...</div>;

  return (
    <div>
      {habits.map(habit => (
        <HabitCard key={habit.id} habit={habit} />
      ))}
      <Button>Add Habit</Button>
    </div>
  );
}
```

### 5. Feature Hooks

**`src/features/habits/hooks/useHabits.js`:**
```javascript
import { useQuery } from '@tanstack/react-query';
import { habitsApi } from '../api/habits';  // Internal API client

export function useHabits() {
  return useQuery({
    queryKey: ['habits'],
    queryFn: habitsApi.list
  });
}

export function useCreateHabit() {
  return useMutation({
    mutationFn: habitsApi.create
  });
}
```

### 6. Feature API Client

**`src/features/habits/api/habits.js`:**
```javascript
// Internal API client (not exported from index.js)
const BASE_URL = '/api/habits';

export const habitsApi = {
  list: async () => {
    const res = await fetch(BASE_URL);
    return res.json();
  },
  
  create: async (data) => {
    const res = await fetch(BASE_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
    return res.json();
  }
};
```

---

## Common Operations

### Adding a New Feature

```bash
# 1. Create feature folder
mkdir -p src/features/settings

# 2. Create structure
src/features/settings/
├── index.js
├── components/
│   └── SettingsForm.jsx
└── hooks/
    └── useSettings.js

# 3. Export public API
# src/features/settings/index.js
export { SettingsForm } from './components/SettingsForm';
export { useSettings } from './hooks/useSettings';
```

### Feature-to-Feature Communication

```jsx
// ❌ Wrong: Direct import (tight coupling)
import { HabitCard } from '../habits/components/HabitCard';

// ✅ Correct: Via shared state or callbacks
// Pass data via props, context, or state management
<Calendar habits={habits} onDateClick={handleDateClick} />

// Or use custom events, global state (Zustand, Redux)
```

### Removing a Feature

```bash
# Simply delete the feature folder
rm -rf src/features/old-feature

# Remove imports from App.jsx
# Done! All feature code removed
```

---

## Top 5 Gotchas

### 1. Importing Internal Components ⚠️

```jsx
// ❌ Wrong: Bypass public API
import { HabitCard } from './features/habits/components/HabitCard';

// ✅ Correct: Use public exports only
import { HabitCard } from './features/habits';  // Only if exported in index.js
```

**Impact:** Tight coupling, breaks encapsulation.

### 2. Feature Index Not Exporting Key Items

```javascript
// ❌ Wrong: Empty or incomplete index.js
export { HabitList } from './components/HabitList';
// Forgot to export useHabits hook!

// ✅ Correct: Export all public APIs
export { HabitList } from './components/HabitList';
export { useHabits, useCreateHabit } from './hooks/useHabits';
```

**Impact:** Other parts of app can't use feature properly.

### 3. Shared Components in Feature Folder

```jsx
// ❌ Wrong: UI components in feature folder
src/features/habits/components/Button.jsx  // This is shared!

// ✅ Correct: Move to shared components
src/components/ui/Button.jsx
```

**Impact:** Component hidden in feature, not reusable.

### 4. Circular Dependencies Between Features

```jsx
// ❌ Wrong: habits imports from calendar, calendar imports from habits
// src/features/habits/index.js
import { Calendar } from '../calendar';

// src/features/calendar/index.js
import { HabitList } from '../habits';  // Circular!

// ✅ Correct: Use composition in parent
// src/App.jsx
import { HabitList } from './features/habits';
import { Calendar } from './features/calendar';
<div>
  <HabitList />
  <Calendar />
</div>
```

**Impact:** Build errors, runtime errors, difficult to maintain.

### 5. Deep Relative Import Paths

```jsx
// ❌ Wrong: Too many ../..
import { Button } from '../../../../components/ui/Button';

// ✅ Correct: Use path aliases (vite.config.js or tsconfig.json)
import { Button } from '@/components/ui/Button';

// vite.config.js
resolve: {
  alias: {
    '@': '/src'
  }
}
```

**Impact:** Hard to read, brittle when moving files.

---

## Quick Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Import error for feature component | Not exported in index.js | Add export to feature's index.js |
| Circular dependency error | Features import from each other | Compose in parent component |
| Long relative paths ../../../../ | No path aliases configured | Configure @ alias in vite.config.js |
| Can't find shared component | Placed in feature folder | Move to src/components/ui/ |
| Feature code scattered | Forgot to move hooks/api | Move all related code into feature folder |

---

## References

📎 **Reference**: [feature-folder-reference.md](feature-folder-reference.md)  
**When to load**: Advanced feature patterns (nested features, cross-feature communication), path aliases setup, feature-based routing, testing strategies, migration from layer-based structure, monorepo considerations (~660 lines)

📎 **Related patterns**:
- [react-patterns.md](react-patterns.md) - Component design within features
- [tanstack-query-patterns.md](tanstack-query-patterns.md) - Data fetching in features
- [testing-pyramid.md](../testing/testing-pyramid.md) - Feature testing strategies

---

**Pattern Type:** Frontend Architecture  
**Last Updated:** 2026-03-07  
**Complexity:** Intermediate ⭐⭐⭐☆☆
