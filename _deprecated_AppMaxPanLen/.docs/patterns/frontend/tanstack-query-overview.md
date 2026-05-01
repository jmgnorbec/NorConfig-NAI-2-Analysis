# TanStack Query Patterns - Overview

**Pattern Type:** Data Fetching & State Management  
**Complexity:** Intermediate to Advanced  
**Read Time:** ~3 minutes  
**Best For:** React applications with API integration and client-side caching needs

---

## When to Use TanStack Query

### ✅ Use TanStack Query When

- **API-driven applications** (frequent data fetching from backend)
- **Need caching** (avoid refetching same data repeatedly)
- **Real-time updates** (background refetching, polling, sync)
- **Optimistic updates** (update UI before API confirms)
- **Complex loading states** (isLoading, isFetching, isError patterns)
- **Request deduplication** (multiple components fetching same data)

### ❌ Don't Use TanStack Query When

- **Static sites** (no API calls)
- **Simple apps** (1-2 API endpoints, useState + useEffect is fine)
- **Server-side rendering only** (use server data fetching directly)
- **GraphQL with Apollo** (Apollo already handles caching)

### vs. Manual useEffect + useState

| Approach | Caching | Loading States | Refetching | Optimistic Updates | Code |
|----------|---------|----------------|------------|-------------------|------|
| **useState + useEffect** | Manual | Manual | Manual | Complex | Verbose |
| **TanStack Query** | Automatic | Built-in | Built-in | Built-in | Minimal |

**Key insight:** TanStack Query eliminates 80% of data-fetching boilerplate.

---

## Essential Configuration

### Installation

```bash
npm install @tanstack/react-query
npm install --save-dev @tanstack/react-query-devtools
```

### QueryClient Setup

**`src/main.jsx`:**
```jsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5,    // 5 min: Data fresh for 5 minutes
      cacheTime: 1000 * 60 * 10,   // 10 min: Keep in cache for 10 minutes
      retry: 1,                     // Retry failed requests once
      refetchOnWindowFocus: false,  // Don't refetch on window focus
    },
  },
});

ReactDOM.createRoot(document.getElementById('root')).render(
  <QueryClientProvider client={queryClient}>
    <App />
    <ReactQueryDevtools initialIsOpen={false} />
  </QueryClientProvider>
);
```

**Key options:**
- **staleTime**: How long data is "fresh" (no refetch needed)
- **cacheTime**: How long cached data persists in memory
- **retry**: Number of retries on failure
- **refetchOnWindowFocus**: Auto-refetch when tab regains focus

---

## Minimal Working Examples

### 1. Basic Query (GET Request)

```javascript
import { useQuery } from '@tanstack/react-query';

function useHabits() {
  return useQuery({
    queryKey: ['habits'],  // Unique cache key
    queryFn: async () => {
      const res = await fetch('/api/habits');
      if (!res.ok) throw new Error('Failed to fetch');
      return res.json();
    },
  });
}

// Usage
function HabitList() {
  const { data, isLoading, error } = useHabits();

  if (isLoading) return <Spinner />;
  if (error) return <div>Error: {error.message}</div>;

  return (
    <div>
      {data.map(habit => <HabitCard key={habit.id} habit={habit} />)}
    </div>
  );
}
```

**Key features:**
- ✅ Automatic caching (no duplicate requests)
- ✅ Loading/error states built-in
- ✅ Background refetching

### 2. Query with Parameters

```javascript
function useHabit(habitId) {
  return useQuery({
    queryKey: ['habits', habitId],  // Include param in key
    queryFn: async () => {
      const res = await fetch(`/api/habits/${habitId}`);
      if (!res.ok) throw new Error('Failed to fetch habit');
      return res.json();
    },
    enabled: !!habitId,  // Only run if habitId exists
  });
}

// Usage
function HabitDetail({ id }) {
  const { data: habit } = useHabit(id);
  return <div>{habit?.name}</div>;
}
```

### 3. Mutation (POST/PUT/DELETE)

```javascript
import { useMutation, useQueryClient } from '@tanstack/react-query';

function useCreateHabit() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (newHabit) => {
      const res = await fetch('/api/habits', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newHabit),
      });
      if (!res.ok) throw new Error('Failed to create habit');
      return res.json();
    },
    onSuccess: () => {
      // Invalidate and refetch habits list after successful creation
      queryClient.invalidateQueries({ queryKey: ['habits'] });
    },
  });
}

// Usage
function HabitForm() {
  const { mutate, isLoading } = useCreateHabit();

  const handleSubmit = (e) => {
    e.preventDefault();
    mutate({ name: 'Meditate', description: 'Daily meditation' });
  };

  return (
    <form onSubmit={handleSubmit}>
      <button disabled={isLoading}>
        {isLoading ? 'Creating...' : 'Create Habit'}
      </button>
    </form>
  );
}
```

### 4. Optimistic Update

```javascript
function useCompleteHabit() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ habitId, date }) => {
      const res = await fetch('/api/completions', {
        method: 'POST',
        body: JSON.stringify({ habit_id: habitId, date }),
      });
      return res.json();
    },
    onMutate: async ({ habitId }) => {
      // Cancel ongoing queries
      await queryClient.cancelQueries({ queryKey: ['habits'] });

      // Snapshot previous value
      const previous = queryClient.getQueryData(['habits']);

      // Optimistically update UI
      queryClient.setQueryData(['habits'], (old) =>
        old.map(h => h.id === habitId ? { ...h, completed: true } : h)
      );

      return { previous };  // Return rollback data
    },
    onError: (err, variables, context) => {
      // Rollback on error
      queryClient.setQueryData(['habits'], context.previous);
    },
    onSettled: () => {
      // Refetch after mutation (success or failure)
      queryClient.invalidateQueries({ queryKey: ['habits'] });
    },
  });
}
```

---

## Common Operations

### Invalidating Queries (Force Refetch)

```javascript
const queryClient = useQueryClient();

// Invalidate specific query
queryClient.invalidateQueries({ queryKey: ['habits'] });

// Invalidate multiple queries
queryClient.invalidateQueries({ queryKey: ['habits', 'completions'] });

// Invalidate all queries
queryClient.invalidateQueries();
```

### Manual Cache Updates

```javascript
// Get cached data
const habits = queryClient.getQueryData(['habits']);

// Set cached data
queryClient.setQueryData(['habits'], newHabits);

// Update cached data
queryClient.setQueryData(['habits'], (old) => [...old, newHabit]);
```

### Dependent Queries

```javascript
// Query B depends on Query A
function useHabitCompletions(habitId) {
  const { data: habit } = useHabit(habitId);

  return useQuery({
    queryKey: ['completions', habitId],
    queryFn: () => fetchCompletions(habitId),
    enabled: !!habit,  // Only run if habit loaded
  });
}
```

### Polling (Background Refetching)

```javascript
useQuery({
  queryKey: ['habits'],
  queryFn: fetchHabits,
  refetchInterval: 30000,  // Refetch every 30 seconds
  refetchIntervalInBackground: true  // Continue when tab not focused
});
```

---

## Top 5 Gotchas

### 1. Forgetting Query Key ⚠️

```javascript
// ❌ Wrong: No query key
useQuery({ queryFn: fetchHabits });

// ✅ Correct: Always include queryKey
useQuery({ 
  queryKey: ['habits'], 
  queryFn: fetchHabits 
});
```

**Impact:** Query not cached, duplicate requests, React errors.

### 2. Query Key Not Matching Parameters

```javascript
// ❌ Wrong: habitId not in key
function useHabit(habitId) {
  return useQuery({
    queryKey: ['habit'],  // Same key for all IDs!
    queryFn: () => fetchHabit(habitId)
  });
}

// ✅ Correct: Include habitId in key
function useHabit(habitId) {
  return useQuery({
    queryKey: ['habit', habitId],  // Unique key per ID
    queryFn: () => fetchHabit(habitId)
  });
}
```

**Impact:** Wrong data displayed, cache collisions.

### 3. Not Invalidating After Mutation

```javascript
// ❌ Wrong: List doesn't update after create
useMutation({
  mutationFn: createHabit
});

// ✅ Correct: Invalidate queries on success
useMutation({
  mutationFn: createHabit,
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['habits'] });
  }
});
```

**Impact:** UI shows stale data, new item not visible.

### 4. Throwing Non-Error Objects

```javascript
// ❌ Wrong: Throw string
queryFn: async () => {
  const res = await fetch('/api/habits');
  if (!res.ok) throw 'Failed';  // String, not Error!
}

// ✅ Correct: Throw Error object
queryFn: async () => {
  const res = await fetch('/api/habits');
  if (!res.ok) throw new Error('Failed to fetch habits');
}
```

**Impact:** Error handling breaks, devtools show confusing errors.

### 5. Using Mutation Result Immediately

```javascript
// ❌ Wrong: mutate() is async, data not available immediately
const { mutate } = useCreateHabit();
mutate(newHabit);
console.log(habits);  // Still old data!

// ✅ Correct: Use onSuccess callback or query invalidation
const { mutate } = useCreateHabit();
mutate(newHabit, {
  onSuccess: (data) => {
    console.log('New habit created:', data);
  }
});
```

**Impact:** Race conditions, reading stale data.

---

## Quick Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Duplicate API calls | Missing queryKey | Add unique queryKey to useQuery |
| Wrong data for different IDs | Query key doesn't include ID | Add ID to queryKey: `['habit', habitId]` |
| List doesn't update after create | No invalidation | Call `invalidateQueries` in onSuccess |
| Query never runs | enabled is false | Check enabled condition: `enabled: !!param` |
| Error not caught | Throwing string | Throw Error object: `throw new Error(message)` |
| staleTime/cacheTime not working | Set in wrong place | Set in QueryClient defaultOptions |

---

## References

📎 **Reference**: [tanstack-query-reference.md](tanstack-query-reference.md)  
**When to load**: Advanced patterns (infinite queries, paginated queries, parallel queries), optimistic update strategies, custom hooks patterns, SSR/SSG integration, mutation queues, error retry strategies, cache persistence, devtools usage (~700 lines)

📎 **Related patterns**:
- [react-patterns.md](react-patterns.md) - Component integration
- [feature-folder-structure.md](feature-folder-structure.md) - Organizing query hooks
- [bff-pattern.md](bff-pattern.md) - Backend integration

---

**Pattern Type:** Data Fetching & State Management  
**Last Updated:** 2026-03-07  
**Complexity:** Intermediate to Advanced ⭐⭐⭐⭐☆
