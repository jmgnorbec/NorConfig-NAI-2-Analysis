# React Patterns

**Pattern Type:** Frontend Component Design  
**Best For:** React 18+ applications  
**Source:** Habit Tracker  
**Complexity:** ⭐⭐⭐☆☆

---

## Overview

Modern React patterns using hooks, functional components, and composition. Covers component design, state management, prop patterns, event handling, and performance optimization.

**Key Principles:**
- Functional components (no classes)
- Hooks for state and effects
- Composition over inheritance
- Props for configuration
- Controlled components for forms

---

## Component Patterns

### 1. Presentational Component

**Pure UI components with no business logic:**

```jsx
export function HabitCard({ habit, onComplete, onDelete }) {
  return (
    <div className="bg-white rounded-lg shadow-sm p-4">
      <div className="flex items-center justify-between">
        <div>
          <h3 className="font-semibold text-gray-900">{habit.name}</h3>
          <p className="text-sm text-gray-500">{habit.description}</p>
        </div>
        
        <div className="flex gap-2">
          <button
            onClick={() => onComplete(habit.id)}
            className="px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600"
          >
            Complete
          </button>
          <button
            onClick={() => onDelete(habit.id)}
            className="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600"
          >
            Delete
          </button>
        </div>
      </div>
    </div>
  );
}
```

**Characteristics:**
- ✅ No state (stateless)
- ✅ Props for data and callbacks
- ✅ No API calls
- ✅ Reusable and testable

---

### 2. Container Component

**Components with business logic and data fetching:**

```jsx
import { useState } from 'react';
import { useHabits, useCompleteHabit, useDeleteHabit } from '../hooks/useHabits';
import { HabitCard } from './HabitCard';
import { Spinner } from '../../../components/ui/Spinner';

export function HabitList() {
  const { data: habits, isLoading, error } = useHabits();
  const { mutate: completeHabit } = useCompleteHabit();
  const { mutate: deleteHabit } = useDeleteHabit();
  const [selectedId, setSelectedId] = useState(null);

  if (isLoading) return <Spinner />;
  if (error) return <div className="text-red-600">Error: {error.message}</div>;
  if (!habits || habits.length === 0) {
    return <div className="text-gray-500 text-center py-8">No habits yet</div>;
  }

  return (
    <div className="space-y-4">
      {habits.map((habit) => (
        <HabitCard
          key={habit.id}
          habit={habit}
          onComplete={completeHabit}
          onDelete={deleteHabit}
          isSelected={selectedId === habit.id}
          onSelect={setSelectedId}
        />
      ))}
    </div>
  );
}
```

**Characteristics:**
- ✅ Has state (useState, useQuery)
- ✅ Data fetching (hooks)
- ✅ Event handlers
- ✅ Composes presentational components

---

### 3. Compound Component

**Components with subcomponents for flexibility:**

```jsx
export function Card({ children, className }) {
  return (
    <div className={clsx('bg-white rounded-lg shadow-sm border', className)}>
      {children}
    </div>
  );
}

Card.Header = function CardHeader({ children, className }) {
  return (
    <div className={clsx('px-4 py-3 border-b border-gray-200', className)}>
      {children}
    </div>
  );
};

Card.Body = function CardBody({ children, className }) {
  return <div className={clsx('px-4 py-3', className)}>{children}</div>;
};

Card.Footer = function CardFooter({ children, className }) {
  return (
    <div className={clsx('px-4 py-3 border-t border-gray-200', className)}>
      {children}
    </div>
  );
};
```

**Usage:**
```jsx
<Card>
  <Card.Header>
    <h2 className="font-semibold">Create Habit</h2>
  </Card.Header>
  <Card.Body>
    <HabitForm />
  </Card.Body>
  <Card.Footer>
    <Button>Save</Button>
  </Card.Footer>
</Card>
```

**Benefits:**
- ✅ Flexible composition
- ✅ Clear structure
- ✅ Dot notation (Card.Header)

---

### 4. Render Props (Legacy Pattern)

**Modern alternative: Custom hooks**

```jsx
// ❌ Old: Render props
<DataFetcher
  url="/habits"
  render={(data, loading) => (
    loading ? <Spinner /> : <HabitList habits={data} />
  )}
/>

// ✅ New: Custom hooks
function HabitList() {
  const { data, isLoading } = useHabits();
  if (isLoading) return <Spinner />;
  return <div>...</div>;
}
```

---

## Hook Patterns

### 1. useState

**Simple state management:**

```jsx
import { useState } from 'react';

function HabitForm() {
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [color, setColor] = useState('#10B981');
  const [error, setError] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!name.trim()) {
      setError('Name is required');
      return;
    }
    // Submit form...
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        value={name}
        onChange={(e) => setName(e.target.value)}
        placeholder="Habit name"
      />
      {error && <p className="text-red-600">{error}</p>}
    </form>
  );
}
```

**When to use:**
- Component-local state
- UI state (modals, forms)
- Simple values (strings, numbers, booleans)

---

### 2. useEffect

**Side effects (API calls, subscriptions):**

```jsx
import { useEffect, useState } from 'react';

function HabitStats({ habitId }) {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let isMounted = true;

    async function fetchStats() {
      try {
        const data = await fetch(`/api/habits/${habitId}/stats`).then(r => r.json());
        if (isMounted) {
          setStats(data);
        }
      } catch (error) {
        console.error('Failed to fetch stats:', error);
      } finally {
        if (isMounted) {
          setLoading(false);
        }
      }
    }

    fetchStats();

    return () => {
      isMounted = false;  // Cleanup: prevent setState on unmounted component
    };
  }, [habitId]);  // Re-run when habitId changes

  if (loading) return <Spinner />;
  return <div>Streak: {stats.current_streak}</div>;
}
```

**Common use cases:**
- Data fetching (prefer TanStack Query)
- Subscriptions (WebSocket, EventSource)
- DOM manipulation (focus, scroll)
- Timers (setTimeout, setInterval)

**Cleanup pattern:**
```jsx
useEffect(() => {
  const timer = setTimeout(() => {
    console.log('Delayed action');
  }, 1000);

  return () => clearTimeout(timer);  // Cleanup
}, []);
```

---

### 3. useRef

**Refs for DOM access and mutable values:**

```jsx
import { useRef, useEffect } from 'react';

function AutoFocusInput() {
  const inputRef = useRef(null);

  useEffect(() => {
    // Focus input on mount
    inputRef.current?.focus();
  }, []);

  return <input ref={inputRef} placeholder="Auto-focused" />;
}
```

**Mutable value (doesn't trigger re-render):**
```jsx
function Timer() {
  const [count, setCount] = useState(0);
  const intervalRef = useRef(null);

  const start = () => {
    intervalRef.current = setInterval(() => {
      setCount(c => c + 1);
    }, 1000);
  };

  const stop = () => {
    if (intervalRef.current) {
      clearInterval(intervalRef.current);
      intervalRef.current = null;
    }
  };

  useEffect(() => {
    return () => stop();  // Cleanup on unmount
  }, []);

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={start}>Start</button>
      <button onClick={stop}>Stop</button>
    </div>
  );
}
```

---

### 4. Custom Hooks

**Extract reusable logic:**

```jsx
// hooks/useLocalStorage.js
import { useState, useEffect } from 'react';

export function useLocalStorage(key, initialValue) {
  const [storedValue, setStoredValue] = useState(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      console.error(error);
      return initialValue;
    }
  });

  const setValue = (value) => {
    try {
      const valueToStore = value instanceof Function ? value(storedValue) : value;
      setStoredValue(valueToStore);
      window.localStorage.setItem(key, JSON.stringify(valueToStore));
    } catch (error) {
      console.error(error);
    }
  };

  return [storedValue, setValue];
}
```

**Usage:**
```jsx
function Settings() {
  const [theme, setTheme] = useLocalStorage('theme', 'light');

  return (
    <button onClick={() => setTheme(theme === 'light' ? 'dark' : 'light')}>
      Toggle Theme (current: {theme})
    </button>
  );
}
```

---

## Props Patterns

### 1. Destructuring Props

```jsx
// ✅ Good: Destructure in parameters
function HabitCard({ habit, onComplete, onDelete, className }) {
  return (
    <div className={className}>
      <h3>{habit.name}</h3>
      <button onClick={() => onComplete(habit.id)}>Complete</button>
    </div>
  );
}

// ❌ Bad: Props object
function HabitCard(props) {
  return (
    <div className={props.className}>
      <h3>{props.habit.name}</h3>
      <button onClick={() => props.onComplete(props.habit.id)}>Complete</button>
    </div>
  );
}
```

---

### 2. Default Props

```jsx
function Button({
  children,
  variant = 'primary',
  size = 'md',
  disabled = false,
  ...props
}) {
  return (
    <button
      className={clsx(
        'px-4 py-2 rounded-lg',
        variant === 'primary' && 'bg-blue-500 text-white',
        variant === 'secondary' && 'bg-gray-200 text-gray-800',
        size === 'sm' && 'text-sm',
        size === 'lg' && 'text-lg'
      )}
      disabled={disabled}
      {...props}
    >
      {children}
    </button>
  );
}
```

---

### 3. Spread Props

```jsx
function Input({ className, ...props }) {
  return (
    <input
      className={clsx('px-3 py-2 border rounded-lg', className)}
      {...props}  // Pass all other props to input
    />
  );
}

// Usage: Any input prop works
<Input
  type="email"
  placeholder="Enter email"
  maxLength={100}
  autoComplete="email"
/>
```

---

### 4. Children Prop

```jsx
function Container({ children, className }) {
  return (
    <div className={clsx('max-w-3xl mx-auto px-4', className)}>
      {children}
    </div>
  );
}

// Usage
<Container>
  <h1>Title</h1>
  <p>Content</p>
</Container>
```

---

### 5. Render Function Props

```jsx
function List({ items, renderItem, emptyMessage = 'No items' }) {
  if (items.length === 0) {
    return <div className="text-gray-500">{emptyMessage}</div>;
  }

  return (
    <div className="space-y-2">
      {items.map((item, index) => (
        <div key={item.id || index}>{renderItem(item, index)}</div>
      ))}
    </div>
  );
}

// Usage
<List
  items={habits}
  renderItem={(habit) => <HabitCard habit={habit} />}
  emptyMessage="No habits yet. Create your first one!"
/>
```

---

## Form Patterns

### 1. Controlled Components

```jsx
function HabitForm({ onSuccess }) {
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [color, setColor] = useState('#10B981');

  const handleSubmit = (e) => {
    e.preventDefault();
    
    const data = {
      name: name.trim(),
      description: description.trim(),
      color,
    };
    
    // Submit to API
    createHabit(data).then(() => {
      setName('');
      setDescription('');
      setColor('#10B981');
      onSuccess?.();
    });
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        value={name}
        onChange={(e) => setName(e.target.value)}
        placeholder="Habit name"
      />
      <textarea
        value={description}
        onChange={(e) => setDescription(e.target.value)}
        placeholder="Description"
      />
      <button type="submit">Create</button>
    </form>
  );
}
```

---

### 2. Form Validation

```jsx
function HabitForm() {
  const [name, setName] = useState('');
  const [error, setError] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    setError('');

    // Validation
    if (!name.trim()) {
      setError('Name is required');
      return;
    }

    if (name.length < 3) {
      setError('Name must be at least 3 characters');
      return;
    }

    // Submit form...
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        value={name}
        onChange={(e) => {
          setName(e.target.value);
          setError('');  // Clear error on change
        }}
        placeholder="Habit name"
        className={error ? 'border-red-500' : 'border-gray-300'}
      />
      {error && (
        <p className="text-sm text-red-600" role="alert">
          {error}
        </p>
      )}
      <button type="submit">Create</button>
    </form>
  );
}
```

---

### 3. Loading States

```jsx
function HabitForm() {
  const [name, setName] = useState('');
  const { mutate: createHabit, isPending } = useCreateHabit();

  const handleSubmit = (e) => {
    e.preventDefault();
    createHabit({ name });
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        value={name}
        onChange={(e) => setName(e.target.value)}
        disabled={isPending}
      />
      <button type="submit" disabled={isPending}>
        {isPending ? 'Creating...' : 'Create Habit'}
      </button>
    </form>
  );
}
```

---

## Conditional Rendering

### 1. If-Else

```jsx
function HabitList() {
  const { data: habits, isLoading } = useHabits();

  if (isLoading) {
    return <Spinner />;
  }

  if (!habits || habits.length === 0) {
    return <div>No habits yet</div>;
  }

  return (
    <div>
      {habits.map(habit => (
        <HabitCard key={habit.id} habit={habit} />
      ))}
    </div>
  );
}
```

---

### 2. Ternary Operator

```jsx
function HabitCard({ habit }) {
  return (
    <div>
      <h3>{habit.name}</h3>
      {habit.completed_today ? (
        <span className="text-green-500">✓ Completed</span>
      ) : (
        <button>Mark Complete</button>
      )}
    </div>
  );
}
```

---

### 3. Logical AND

```jsx
function HabitCard({ habit }) {
  return (
    <div>
      <h3>{habit.name}</h3>
      {habit.description && (
        <p className="text-gray-500">{habit.description}</p>
      )}
      {habit.current_streak > 0 && (
        <span>🔥 {habit.current_streak} day streak</span>
      )}
    </div>
  );
}
```

---

## List Rendering

### 1. Map with Key

```jsx
function HabitList({ habits }) {
  return (
    <div className="space-y-4">
      {habits.map((habit) => (
        <HabitCard key={habit.id} habit={habit} />
      ))}
    </div>
  );
}
```

**Key rules:**
- ✅ Use unique ID (habit.id)
- ❌ Don't use index (unstable)
- ❌ Don't use random values

---

### 2. Empty State

```jsx
function HabitList({ habits }) {
  if (habits.length === 0) {
    return (
      <div className="text-center py-12">
        <p className="text-gray-500 mb-4">No habits yet</p>
        <Button onClick={() => setShowForm(true)}>
          Create Your First Habit
        </Button>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {habits.map(habit => (
        <HabitCard key={habit.id} habit={habit} />
      ))}
    </div>
  );
}
```

---

## Event Handling

### 1. Basic Events

```jsx
function Button({ onClick, children }) {
  const handleClick = (e) => {
    console.log('Button clicked', e);
    onClick?.(e);  // Optional chaining
  };

  return (
    <button onClick={handleClick}>
      {children}
    </button>
  );
}
```

---

### 2. Preventing Default

```jsx
function HabitForm({ onSubmit }) {
  const handleSubmit = (e) => {
    e.preventDefault();  // Prevent page reload
    onSubmit?.();
  };

  return <form onSubmit={handleSubmit}>...</form>;
}
```

---

### 3. Event with Parameters

```jsx
function HabitList({ habits }) {
  const handleComplete = (habitId) => {
    console.log('Completing habit:', habitId);
    // API call...
  };

  return (
    <div>
      {habits.map(habit => (
        <button
          key={habit.id}
          onClick={() => handleComplete(habit.id)}
        >
          Complete
        </button>
      ))}
    </div>
  );
}
```

---

## Performance Optimization

### 1. useMemo

**Memoize expensive calculations:**

```jsx
import { useMemo } from 'react';

function HabitStats({ completions }) {
  const stats = useMemo(() => {
    // Expensive calculation
    const total = completions.length;
    const thisMonth = completions.filter(c => isThisMonth(c.date)).length;
    const rate = (thisMonth / 30) * 100;
    
    return { total, thisMonth, rate };
  }, [completions]);  // Only recalculate when completions change

  return (
    <div>
      <p>Total: {stats.total}</p>
      <p>This month: {stats.thisMonth}</p>
      <p>Rate: {stats.rate.toFixed(1)}%</p>
    </div>
  );
}
```

---

### 2. useCallback

**Memoize callback functions:**

```jsx
import { useCallback } from 'react';

function HabitList() {
  const { data: habits } = useHabits();
  const { mutate: deleteHabit } = useDeleteHabit();

  // Memoize callback to prevent re-renders
  const handleDelete = useCallback((id) => {
    if (confirm('Delete this habit?')) {
      deleteHabit(id);
    }
  }, [deleteHabit]);

  return (
    <div>
      {habits.map(habit => (
        <HabitCard
          key={habit.id}
          habit={habit}
          onDelete={handleDelete}
        />
      ))}
    </div>
  );
}
```

---

### 3. React.memo

**Prevent re-renders of pure components:**

```jsx
import { memo } from 'react';

const HabitCard = memo(function HabitCard({ habit, onComplete }) {
  console.log('Rendering HabitCard:', habit.id);
  
  return (
    <div>
      <h3>{habit.name}</h3>
      <button onClick={() => onComplete(habit.id)}>Complete</button>
    </div>
  );
});

// Only re-renders if habit or onComplete changes
```

---

## Error Boundaries

**Catch errors in component tree:**

```jsx
import { Component } from 'react';

class ErrorBoundary extends Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }

  componentDidCatch(error, errorInfo) {
    console.error('Error caught by boundary:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="p-4 bg-red-50 border border-red-200 rounded">
          <h2 className="text-red-800 font-semibold">Something went wrong</h2>
          <p className="text-red-600">{this.state.error?.message}</p>
        </div>
      );
    }

    return this.props.children;
  }
}

// Usage
<ErrorBoundary>
  <HabitList />
</ErrorBoundary>
```

---

## Best Practices

### ✅ Do:
- **Use functional components** (no classes)
- **Destructure props** (clear interface)
- **Extract custom hooks** (reusable logic)
- **Use keys in lists** (stable identity)
- **Keep components small** (< 200 lines)
- **Colocate state** (as close as possible to usage)
- **Name event handlers** with "handle" prefix (handleClick)

### ❌ Don't:
- **Mutate state directly** (use setState)
- **Use index as key** (unstable)
- **Put business logic in components** (use hooks)
- **Create inline functions in render** (use useCallback)
- **Fetch in useEffect** (use TanStack Query)
- **Over-optimize** (profile before memoizing)

---

## Source References

**Extracted from:**
- Habit Tracker: `frontend/src/features/habits/components/` (component patterns)
- Habit Tracker: `frontend/src/features/habits/hooks/useHabits.js` (custom hooks)
- Habit Tracker: `frontend/src/components/ui/` (compound components)

**Related Patterns:**
- 📎 [Feature-Folder Structure](feature-folder-structure.md) - Code organization
- 📎 [TanStack Query Patterns](tanstack-query-patterns.md) - Data fetching
- 📎 [MUI Patterns](mui-patterns.md) - Material UI components

---

**Pattern Version:** 1.0.0  
**Last Updated:** March 7, 2026  
**Source Project:** Habit Tracker v1.0.0
