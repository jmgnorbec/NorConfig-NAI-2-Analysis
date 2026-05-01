# React Patterns - Overview

**Pattern Type:** Frontend Component Design  
**Complexity:** Beginner to Intermediate  
**Read Time:** ~3 minutes  
**Best For:** React 18+ applications using functional components and hooks

---

## When to Use These Patterns

### ✅ Use React Patterns When

- **Modern React development** (React 18+, functional components)
- **Component-based architecture** (reusable UI building blocks)
- **State management needs** (useState, useReducer, context)
- **Side effects handling** (useEffect for API calls, subscriptions)
- **Performance optimization** (useMemo, useCallback for expensive operations)

### ❌ Don't Use These Patterns When

- **Server-only rendering** (use server components, no client state)
- **Static sites** (no interactivity, plain HTML/CSS sufficient)
- **Legacy React apps** (already using class components consistently)

### Core Principles

- **Functional components** (no classes)
- **Hooks for state and effects** (useState, useEffect, custom hooks)
- **Composition over inheritance** (compose components, don't extend)
- **Props for configuration** (pass data down)
- **Controlled components** (React state as source of truth)

---

## Essential Component Patterns

### 1. Presentational vs Container Components

**Presentational (UI only):**
- No state or business logic
- Receive data via props
- Reusable across features
- Easy to test

**Container (logic):**
- Handle state and data fetching
- Contain business logic
- Pass data to presentational components
- Compose multiple components

### 2. Props Patterns

```typescript
// Basic props
interface ButtonProps {
  label: string;
  onClick: () => void;
}

// Optional props with defaults
interface CardProps {
  title: string;
  description?: string;  // Optional
  variant?: 'default' | 'outlined';
}

// Children props (composition)
interface LayoutProps {
  children: React.ReactNode;
}

// Function props (callbacks)
interface FormProps {
  onSubmit: (data: FormData) => void;
}
```

---

## Minimal Working Examples

### 1. Presentational Component

**Pure UI component:**
```jsx
export function HabitCard({ habit, onComplete, onDelete }) {
  return (
    <div className="bg-white rounded-lg shadow p-4">
      <h3 className="font-semibold">{habit.name}</h3>
      <p className="text-gray-600">{habit.description}</p>
      
      <div className="flex gap-2 mt-4">
        <button
          onClick={() => onComplete(habit.id)}
          className="px-4 py-2 bg-green-500 text-white rounded"
        >
          Complete
        </button>
        <button
          onClick={() => onDelete(habit.id)}
          className="px-4 py-2 bg-red-500 text-white rounded"
        >
          Delete
        </button>
      </div>
    </div>
  );
}
```

**Characteristics:**
- ✅ Stateless (no useState)
- ✅ Props for data and callbacks
- ✅ No API calls or side effects
- ✅ Reusable and testable

### 2. Container Component with State

**Component with business logic:**
```jsx
import { useState } from 'react';
import { useHabits, useCompleteHabit } from '../hooks/useHabits';
import { HabitCard } from './HabitCard';
import { Spinner } from '../../../components/ui/Spinner';

export function HabitList() {
  const { data: habits, isLoading } = useHabits();
  const { mutate: completeHabit } = useCompleteHabit();
  const [selectedId, setSelectedId] = useState(null);

  if (isLoading) return <Spinner />;

  return (
    <div className="space-y-4">
      {habits.map((habit) => (
        <HabitCard
          key={habit.id}
          habit={habit}
          onComplete={() => completeHabit(habit.id)}
          onDelete={() => setSelectedId(habit.id)}
        />
      ))}
    </div>
  );
}
```

### 3. Custom Hook (Reusable Logic)

**Extract stateful logic:**
```jsx
import { useState, useEffect } from 'react';

export function useDebounce(value, delay = 500) {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    return () => clearTimeout(timer);  // Cleanup
  }, [value, delay]);

  return debouncedValue;
}

// Usage
function SearchInput() {
  const [search, setSearch] = useState('');
  const debouncedSearch = useDebounce(search, 300);

  useEffect(() => {
    // API call only fires after 300ms of no typing
    fetchResults(debouncedSearch);
  }, [debouncedSearch]);

  return <input value={search} onChange={e => setSearch(e.target.value)} />;
}
```

### 4. Context for Global State

**Avoid prop drilling:**
```jsx
import { createContext, useContext, useState } from 'react';

const ThemeContext = createContext();

export function ThemeProvider({ children }) {
  const [theme, setTheme] = useState('light');

  return (
    <ThemeContext.Provider value={{ theme, setTheme }}>
      {children}
    </ThemeContext.Provider>
  );
}

// Custom hook for consuming context
export function useTheme() {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('useTheme must be used within ThemeProvider');
  }
  return context;
}

// Usage
function Header() {
  const { theme, setTheme } = useTheme();
  return <button onClick={() => setTheme(theme === 'light' ? 'dark' : 'light')}>
    Toggle Theme
  </button>;
}
```

---

## Common Operations

### State Management

```jsx
// Simple state
const [count, setCount] = useState(0);

// Object state (immutable updates)
const [user, setUser] = useState({ name: '', email: '' });
setUser(prev => ({ ...prev, email: 'new@example.com' }));

// Array state (immutable updates)
const [items, setItems] = useState([]);
setItems(prev => [...prev, newItem]);           // Add
setItems(prev => prev.filter(item => item.id !== id));  // Remove
```

### Side Effects

```jsx
import { useEffect } from 'react';

// Run once on mount
useEffect(() => {
  fetchData();
}, []);  // Empty deps = mount only

// Run when dependency changes
useEffect(() => {
  fetchUser(userId);
}, [userId]);  // Re-run when userId changes

// Cleanup (subscriptions, timers)
useEffect(() => {
  const subscription = subscribe();
  return () => subscription.unsubscribe();  // Cleanup
}, []);
```

### Conditional Rendering

```jsx
// If-else with ternary
{isLoading ? <Spinner /> : <Content data={data} />}

// If only with &&
{error && <ErrorMessage error={error} />}

// Multiple conditions
{isLoading ? (
  <Spinner />
) : error ? (
  <ErrorMessage error={error} />
) : (
  <Content data={data} />
)}
```

### Lists and Keys

```jsx
// Always use unique keys for lists
{habits.map(habit => (
  <HabitCard key={habit.id} habit={habit} />
))}

// Index as key only if items NEVER reorder/filter
{items.map((item, index) => (
  <div key={index}>{item}</div>  // ⚠️ Use with caution
))}
```

---

## Top 5 Gotchas

### 1. Mutating State Directly ⚠️

```jsx
// ❌ Wrong: Mutates state
const [user, setUser] = useState({ name: 'John' });
user.name = 'Jane';  // Don't mutate!
setUser(user);       // React won't detect change

// ✅ Correct: Create new object
setUser({ ...user, name: 'Jane' });
```

**Impact:** React doesn't detect change, component doesn't re-render.

### 2. Missing useEffect Dependencies

```jsx
// ❌ Wrong: userId not in deps
useEffect(() => {
  fetchUser(userId);
}, []);  // ESLint warning!

// ✅ Correct: Include all dependencies
useEffect(() => {
  fetchUser(userId);
}, [userId]);
```

**Impact:** Stale data, component doesn't react to changes.

### 3. Using Index as Key in Dynamic Lists

```jsx
// ❌ Wrong: Index keys break when list reorders
{items.map((item, index) => (
  <Item key={index} item={item} />
))}

// ✅ Correct: Use stable unique ID
{items.map(item => (
  <Item key={item.id} item={item} />
))}
```

**Impact:** React loses track of components, state gets mixed up.

### 4. Infinite useEffect Loop

```jsx
// ❌ Wrong: Creates infinite loop
const [data, setData] = useState([]);
useEffect(() => {
  setData([...data, newItem]);  // Triggers re-render → runs again!
}, [data]);  // Depends on data it modifies

// ✅ Correct: Use functional update
useEffect(() => {
  // Only run on specific trigger
}, [specificTrigger]);

// Or use callback form
setData(prev => [...prev, newItem]);
```

**Impact:** Component re-renders infinitely, browser freezes.

### 5. Forgetting Cleanup in useEffect

```jsx
// ❌ Wrong: Timer keeps running after unmount
useEffect(() => {
  const timer = setInterval(() => console.log('tick'), 1000);
}, []);

// ✅ Correct: Return cleanup function
useEffect(() => {
  const timer = setInterval(() => console.log('tick'), 1000);
  return () => clearInterval(timer);  // Cleanup
}, []);
```

**Impact:** Memory leaks, timers/subscriptions never cleaned up.

---

## Quick Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Component doesn't re-render | Mutating state directly | Use `setState` with new object/array |
| Stale data in useEffect | Missing dependency | Add to dependency array |
| List items mixed up | Index as key | Use unique `item.id` as key |
| Infinite re-renders | State update in useEffect depends on same state | Remove state from dependencies or use functional update |
| Memory leak warning | No cleanup function | Return cleanup function from useEffect |
| "Cannot read property of undefined" | Accessing data before loaded | Add conditional rendering: `{data && <Component />}` |

---

## References

📎 **Reference**: [react-reference.md](react-reference.md)  
**When to load**: Implementing advanced patterns (render props, HOCs, compound components), performance optimization (useMemo, useCallback, React.memo), complex state management (useReducer, context patterns), advanced hooks, testing strategies (~800 lines)

📎 **Related patterns**:
- [tanstack-query-patterns.md](tanstack-query-patterns.md) - Data fetching with React
- [feature-folder-structure.md](feature-folder-structure.md) - Organizing React code
- [mui-patterns.md](mui-patterns.md) - Material UI component library

---

**Pattern Type:** Frontend Component Design  
**Last Updated:** 2026-03-07  
**Complexity:** Beginner to Intermediate ⭐⭐⭐☆☆
