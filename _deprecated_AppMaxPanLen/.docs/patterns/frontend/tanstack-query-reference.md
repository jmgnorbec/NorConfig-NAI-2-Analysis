# TanStack Query Patterns

**Pattern Type:** Data Fetching & Caching  
**Best For:** React applications with API integration  
**Source:** Habit Tracker  
**Complexity:** ⭐⭐⭐⭐☆

---

## Overview

TanStack Query (formerly React Query) is a powerful data fetching and caching library for React. It handles API state management, caching, background updates, and optimistic updates with minimal boilerplate.

**Key Features:**
- Automatic caching and cache invalidation
- Background refetching
- Optimistic updates
- Request deduplication
- Loading and error states
- Devtools for debugging

---

## Installation & Setup

### Install TanStack Query

```bash
npm install @tanstack/react-query
```

---

### QueryClient Setup

**`main.jsx`:**
```jsx
import React from 'react';
import ReactDOM from 'react-dom/client';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';
import App from './App';

// Create QueryClient
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5,  // 5 minutes
      retry: 1,
      refetchOnWindowFocus: false,
    },
  },
});

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <QueryClientProvider client={queryClient}>
      <App />
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  </React.StrictMode>
);
```

**Configuration options:**
- `staleTime`: How long data is fresh (default: 0)
- `cacheTime`: How long cached data persists (default: 5 minutes)
- `retry`: Number of retries on failure (default: 3)
- `refetchOnWindowFocus`: Refetch when window regains focus (default: true)

---

## Query Patterns (GET Requests)

### 1. Basic Query

**Fetch list of habits:**

```jsx
import { useQuery } from '@tanstack/react-query';

function useHabits() {
  return useQuery({
    queryKey: ['habits'],
    queryFn: async () => {
      const response = await fetch('/api/habits');
      if (!response.ok) {
        throw new Error('Failed to fetch habits');
      }
      const data = await response.json();
      return data.habits;
    },
  });
}

// Usage
function HabitList() {
  const { data: habits, isLoading, error } = useHabits();

  if (isLoading) return <Spinner />;
  if (error) return <div>Error: {error.message}</div>;

  return (
    <div>
      {habits.map(habit => (
        <HabitCard key={habit.id} habit={habit} />
      ))}
    </div>
  );
}
```

**Query states:**
- `isLoading`: No data yet (initial fetch)
- `isFetching`: Background refetch
- `isError`: Query failed
- `isSuccess`: Query succeeded
- `data`: Query result
- `error`: Error object

---

### 2. Query with Parameters

**Fetch single habit by ID:**

```jsx
function useHabit(id) {
  return useQuery({
    queryKey: ['habits', id],
    queryFn: async () => {
      const response = await fetch(`/api/habits/${id}`);
      if (!response.ok) {
        throw new Error('Habit not found');
      }
      return response.json();
    },
    enabled: !!id,  // Only run if id exists
  });
}

// Usage
function HabitDetail({ habitId }) {
  const { data: habit, isLoading } = useHabit(habitId);

  if (isLoading) return <Spinner />;

  return (
    <div>
      <h2>{habit.name}</h2>
      <p>{habit.description}</p>
    </div>
  );
}
```

**Key points:**
- `queryKey: ['habits', id]` - Include parameters in key
- `enabled: !!id` - Conditional query execution

---

### 3. Query with Filters

**Fetch completions with date range:**

```jsx
function useCompletions(habitId, startDate, endDate) {
  return useQuery({
    queryKey: ['completions', habitId, startDate, endDate],
    queryFn: async () => {
      const params = new URLSearchParams();
      if (startDate) params.append('start', startDate);
      if (endDate) params.append('end', endDate);
      
      const response = await fetch(`/api/habits/${habitId}/completions?${params}`);
      return response.json();
    },
    enabled: !!habitId,
  });
}
```

---

### 4. Dependent Queries

**Fetch data that depends on another query:**

```jsx
function HabitDetails({ habitId }) {
  // First query: Get habit
  const { data: habit } = useQuery({
    queryKey: ['habits', habitId],
    queryFn: () => fetchHabit(habitId),
  });

  // Second query: Get completions (dependent on habit)
  const { data: completions } = useQuery({
    queryKey: ['completions', habit?.id],
    queryFn: () => fetchCompletions(habit.id),
    enabled: !!habit?.id,  // Only run after habit is fetched
  });

  return <div>...</div>;
}
```

---

### 5. Parallel Queries

**Fetch multiple resources simultaneously:**

```jsx
function Dashboard() {
  const habits = useQuery({
    queryKey: ['habits'],
    queryFn: fetchHabits,
  });

  const stats = useQuery({
    queryKey: ['stats'],
    queryFn: fetchStats,
  });

  const goals = useQuery({
    queryKey: ['goals'],
    queryFn: fetchGoals,
  });

  if (habits.isLoading || stats.isLoading || goals.isLoading) {
    return <Spinner />;
  }

  return (
    <div>
      <HabitList habits={habits.data} />
      <StatsCard stats={stats.data} />
      <GoalsList goals={goals.data} />
    </div>
  );
}
```

**Alternative: useQueries for dynamic parallel:**
```jsx
function MultiHabitView({ habitIds }) {
  const queries = useQueries({
    queries: habitIds.map(id => ({
      queryKey: ['habits', id],
      queryFn: () => fetchHabit(id),
    })),
  });

  const isLoading = queries.some(q => q.isLoading);
  const habits = queries.map(q => q.data);

  return <div>...</div>;
}
```

---

## Mutation Patterns (POST/PUT/DELETE)

### 1. Basic Mutation

**Create new habit:**

```jsx
import { useMutation, useQueryClient } from '@tanstack/react-query';

function useCreateHabit() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (data) => {
      const response = await fetch('/api/habits', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      });
      if (!response.ok) throw new Error('Failed to create habit');
      return response.json();
    },
    onSuccess: () => {
      // Invalidate and refetch habits list
      queryClient.invalidateQueries({ queryKey: ['habits'] });
    },
  });
}

// Usage
function HabitForm() {
  const { mutate, isPending, error } = useCreateHabit();

  const handleSubmit = (e) => {
    e.preventDefault();
    mutate({
      name: 'Morning Run',
      color: '#10B981',
    });
  };

  return (
    <form onSubmit={handleSubmit}>
      <button type="submit" disabled={isPending}>
        {isPending ? 'Creating...' : 'Create Habit'}
      </button>
      {error && <p className="text-red-600">{error.message}</p>}
    </form>
  );
}
```

**Mutation states:**
- `isPending`: Mutation in progress
- `isSuccess`: Mutation succeeded
- `isError`: Mutation failed
- `data`: Mutation result
- `error`: Error object

---

### 2. Mutation with Callbacks

**Handle success and error:**

```jsx
function HabitForm({ onSuccess }) {
  const { mutate } = useCreateHabit();

  const handleSubmit = (data) => {
    mutate(data, {
      onSuccess: (newHabit) => {
        console.log('Created:', newHabit);
        onSuccess?.();
      },
      onError: (error) => {
        console.error('Failed:', error);
        alert('Failed to create habit');
      },
    });
  };

  return <form onSubmit={handleSubmit}>...</form>;
}
```

---

### 3. Update Mutation

**Update existing habit:**

```jsx
function useUpdateHabit() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ id, data }) => {
      const response = await fetch(`/api/habits/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      });
      return response.json();
    },
    onSuccess: (updatedHabit, { id }) => {
      // Invalidate list
      queryClient.invalidateQueries({ queryKey: ['habits'] });
      
      // Invalidate specific habit
      queryClient.invalidateQueries({ queryKey: ['habits', id] });
    },
  });
}

// Usage
function EditHabitForm({ habit }) {
  const { mutate, isPending } = useUpdateHabit();

  const handleSubmit = (formData) => {
    mutate({
      id: habit.id,
      data: formData,
    });
  };

  return <form onSubmit={handleSubmit}>...</form>;
}
```

---

### 4. Delete Mutation

**Delete habit:**

```jsx
function useDeleteHabit() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (id) => {
      const response = await fetch(`/api/habits/${id}`, {
        method: 'DELETE',
      });
      if (!response.ok) throw new Error('Failed to delete');
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['habits'] });
    },
  });
}

// Usage
function HabitCard({ habit }) {
  const { mutate: deleteHabit, isPending } = useDeleteHabit();

  const handleDelete = () => {
    if (confirm('Delete this habit?')) {
      deleteHabit(habit.id);
    }
  };

  return (
    <div>
      <h3>{habit.name}</h3>
      <button onClick={handleDelete} disabled={isPending}>
        {isPending ? 'Deleting...' : 'Delete'}
      </button>
    </div>
  );
}
```

---

## Cache Management

### 1. Invalidate Queries

**Force refetch by invalidating cache:**

```jsx
function useCompleteHabit() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, date }) => completeHabit(id, date),
    onSuccess: (_, { id }) => {
      // Invalidate related queries
      queryClient.invalidateQueries({ queryKey: ['habits'] });
      queryClient.invalidateQueries({ queryKey: ['completions', id] });
      queryClient.invalidateQueries({ queryKey: ['stats'] });
    },
  });
}
```

**Invalidation patterns:**
```jsx
// Exact match
queryClient.invalidateQueries({ queryKey: ['habits'] });

// Prefix match (all habit queries)
queryClient.invalidateQueries({ queryKey: ['habits'] });  // Matches ['habits'], ['habits', 1], etc.

// With predicate
queryClient.invalidateQueries({
  predicate: (query) => query.queryKey[0] === 'habits' && query.queryKey[1] > 10,
});
```

---

### 2. Set Query Data

**Manually update cache after mutation:**

```jsx
function useCreateHabit() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: createHabit,
    onSuccess: (newHabit) => {
      // Get current habits from cache
      const habits = queryClient.getQueryData(['habits']) || [];
      
      // Add new habit to cache
      queryClient.setQueryData(['habits'], [...habits, newHabit]);
    },
  });
}
```

---

### 3. Optimistic Updates

**Update UI immediately, rollback on error:**

```jsx
function useCompleteHabit() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, date }) => completeHabit(id, date),
    
    onMutate: async ({ id }) => {
      // Cancel outgoing refetches
      await queryClient.cancelQueries({ queryKey: ['habits'] });

      // Snapshot current value
      const previousHabits = queryClient.getQueryData(['habits']);

      // Optimistically update cache
      queryClient.setQueryData(['habits'], (old) =>
        old.map((habit) =>
          habit.id === id
            ? { ...habit, completed_today: true, current_streak: habit.current_streak + 1 }
            : habit
        )
      );

      // Return context for rollback
      return { previousHabits };
    },
    
    onError: (err, variables, context) => {
      // Rollback on error
      queryClient.setQueryData(['habits'], context.previousHabits);
    },
    
    onSettled: () => {
      // Refetch to ensure consistency
      queryClient.invalidateQueries({ queryKey: ['habits'] });
    },
  });
}
```

**Optimistic update flow:**
1. `onMutate`: Update cache immediately (before API call)
2. `onError`: Rollback if mutation fails
3. `onSettled`: Refetch to sync with server

---

### 4. Prefetching

**Preload data before user navigates:**

```jsx
function HabitCard({ habit }) {
  const queryClient = useQueryClient();

  const handleMouseEnter = () => {
    // Prefetch habit details on hover
    queryClient.prefetchQuery({
      queryKey: ['habits', habit.id],
      queryFn: () => fetchHabit(habit.id),
      staleTime: 1000 * 60 * 5,  // 5 minutes
    });
  };

  return (
    <div onMouseEnter={handleMouseEnter}>
      <Link to={`/habits/${habit.id}`}>{habit.name}</Link>
    </div>
  );
}
```

---

## API Client Pattern

### Centralized API Functions

**`features/habits/api/habits.js`:**
```javascript
import { request } from '../../../lib/api';

export const fetchHabits = () => request('/habits/');

export const fetchHabit = (id) => request(`/habits/${id}`);

export const createHabit = (data) =>
  request('/habits/', {
    method: 'POST',
    body: JSON.stringify(data),
  });

export const updateHabit = (id, data) =>
  request(`/habits/${id}`, {
    method: 'PUT',
    body: JSON.stringify(data),
  });

export const deleteHabit = (id) =>
  request(`/habits/${id}`, {
    method: 'DELETE',
  });

export const completeHabit = (id, date) =>
  request(`/habits/${id}/complete`, {
    method: 'POST',
    body: JSON.stringify({ date }),
  });
```

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

### Custom Hooks

**`features/habits/hooks/useHabits.js`:**
```javascript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import * as api from '../api/habits';

export function useHabits() {
  return useQuery({
    queryKey: ['habits'],
    queryFn: async () => {
      const data = await api.fetchHabits();
      return data.habits;
    },
  });
}

export function useHabit(id) {
  return useQuery({
    queryKey: ['habits', id],
    queryFn: () => api.fetchHabit(id),
    enabled: !!id,
  });
}

export function useCreateHabit() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: api.createHabit,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['habits'] });
    },
  });
}

export function useUpdateHabit() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, data }) => api.updateHabit(id, data),
    onSuccess: (_, { id }) => {
      queryClient.invalidateQueries({ queryKey: ['habits'] });
      queryClient.invalidateQueries({ queryKey: ['habits', id] });
    },
  });
}

export function useDeleteHabit() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: api.deleteHabit,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['habits'] });
    },
  });
}

export function useCompleteHabit() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, date }) => api.completeHabit(id, date),
    onSuccess: (_, { id }) => {
      queryClient.invalidateQueries({ queryKey: ['habits'] });
      queryClient.invalidateQueries({ queryKey: ['completions', id] });
    },
  });
}
```

**Pattern benefits:**
- ✅ Separation of concerns (API vs hooks)
- ✅ Reusable API functions (testable)
- ✅ Consistent query keys
- ✅ Centralized cache invalidation

---

## Error Handling

### Query Errors

```jsx
function HabitList() {
  const { data, isLoading, error, isError } = useHabits();

  if (isLoading) return <Spinner />;
  
  if (isError) {
    return (
      <div className="bg-red-50 border border-red-200 rounded p-4">
        <h3 className="text-red-800 font-semibold">Failed to load habits</h3>
        <p className="text-red-600">{error.message}</p>
      </div>
    );
  }

  return <div>...</div>;
}
```

---

### Mutation Errors

```jsx
function HabitForm() {
  const { mutate, isPending, error } = useCreateHabit();

  return (
    <form onSubmit={(e) => {
      e.preventDefault();
      mutate({ name: 'Exercise' });
    }}>
      {error && (
        <div className="bg-red-50 border border-red-200 rounded p-3 mb-4">
          <p className="text-red-600">{error.message}</p>
        </div>
      )}
      <button type="submit" disabled={isPending}>
        Create
      </button>
    </form>
  );
}
```

---

### Global Error Handler

```jsx
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      onError: (error) => {
        console.error('Query error:', error);
        toast.error(error.message);
      },
    },
    mutations: {
      onError: (error) => {
        console.error('Mutation error:', error);
        toast.error(error.message);
      },
    },
  },
});
```

---

## Devtools

**Install devtools:**
```bash
npm install @tanstack/react-query-devtools
```

**Add to app:**
```jsx
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';

<QueryClientProvider client={queryClient}>
  <App />
  <ReactQueryDevtools initialIsOpen={false} />
</QueryClientProvider>
```

**Devtools features:**
- Query inspector
- Cache visualization
- Mutation tracking
- Refetch controls

---

## Best Practices

### ✅ Do:
- **Use custom hooks** for queries and mutations
- **Include all dependencies** in query keys
- **Invalidate related queries** after mutations
- **Handle loading and error states**
- **Enable queries conditionally** (enabled option)
- **Prefetch predictable navigation**
- **Use optimistic updates** for instant feedback

### ❌ Don't:
- **Fetch in useEffect** (use useQuery)
- **Store API data in useState** (let TanStack Query manage it)
- **Forget to invalidate** after mutations
- **Use unstable query keys** (avoid inline objects)
- **Over-invalidate** (be specific)
- **Skip error handling**

---

## Query Key Conventions

**Good query keys:**
```javascript
✅ ['habits']
✅ ['habits', habitId]
✅ ['completions', habitId]
✅ ['completions', habitId, startDate, endDate]
✅ ['stats', 'monthly', userId]
```

**Bad query keys:**
```javascript
❌ 'habits'  // String instead of array
❌ ['habits', { id: habitId }]  // Object (unstable reference)
❌ ['data']  // Too generic
```

---

## Source References

**Extracted from:**
- Habit Tracker: `frontend/src/features/habits/hooks/useHabits.js` (query/mutation patterns)
- Habit Tracker: `frontend/src/features/habits/api/habits.js` (API client)
- Habit Tracker: `frontend/src/lib/api.js` (request utility)

**Related Patterns:**
- 📎 [React Patterns](react-patterns.md) - Component design
- 📎 [Feature-Folder Structure](feature-folder-structure.md) - Hook organization
- 📎 [BFF Pattern](bff-pattern.md) - Backend-for-frontend API

---

**Pattern Version:** 1.0.0  
**Last Updated:** March 7, 2026  
**Source Project:** Habit Tracker v1.0.0
