# Material UI (MUI) Patterns - Overview

**Pattern Type:** Component Library  
**Complexity:** Intermediate  
**Read Time:** ~3 minutes  
**Best For:** Rapid development, consistent design, enterprise applications

---

## When to Use MUI

### ✅ Use MUI When

- **Rapid UI development** (pre-built components with Material Design)
- **Consistent design system** (Google Material Design out of the box)
- **Enterprise/admin applications** (forms, tables, dialogs)
- **Accessibility required** (ARIA labels, keyboard navigation built-in)
- **TypeScript project** (excellent TypeScript support)
- **Responsive design** (Grid, breakpoints built-in)

### ❌ Don't Use MUI When

- **Highly custom design** (non-Material Design aesthetic)
- **Bundle size critical** (~400KB minified is too large)
- **Existing design system** (Tailwind, custom CSS already established)
- **Need extremely fast load times** (lightweight alternatives: Mantine, Chakra)
- **Team unfamiliar with Material Design** (steeper learning curve)

### vs. Other UI Libraries

| Library | Bundle Size | Customization | Learning Curve | Best For |
|---------|-------------|---------------|----------------|----------|
| **MUI** | ~400KB | Theme system | Medium | Enterprise apps |
| **Tailwind** | ~10KB | Full control | Low | Custom designs |
| **Chakra** | ~150KB | Component props | Low | Rapid prototyping |
| **Ant Design** | ~500KB | Limited | Medium | Admin dashboards |

**Key insight:** MUI trades bundle size for development speed and consistency.

---

## Essential Configuration

### Installation

```bash
# Core packages
npm install @mui/material @emotion/react @emotion/styled

# Optional: Icons
npm install @mui/icons-material

# Optional: Date pickers
npm install @mui/x-date-pickers dayjs
```

### Theme Setup

**`src/theme/theme.ts`:**
```typescript
import { createTheme } from '@mui/material/styles';

export const theme = createTheme({
  // Color palette
  palette: {
    mode: 'light',
    primary: {
      main: '#1976d2',  // Blue
      light: '#42a5f5',
      dark: '#1565c0',
    },
    secondary: {
      main: '#dc004e',  // Pink
    },
    background: {
      default: '#f5f5f7',  // Light gray
      paper: '#ffffff',     // White cards
    },
  },
  
  // Typography
  typography: {
    fontFamily: '"Inter", "Roboto", "Helvetica", "Arial", sans-serif',
    h1: { fontSize: '2.5rem', fontWeight: 600 },
    h2: { fontSize: '2rem', fontWeight: 600 },
    h3: { fontSize: '1.75rem', fontWeight: 600 },
    body1: { fontSize: '1rem', lineHeight: 1.5 },
    button: { textTransform: 'none' },  // Disable UPPERCASE buttons
  },
  
  // Shape
  shape: {
    borderRadius: 8,  // Rounded corners
  },
  
  // Component defaults
  components: {
    MuiButton: {
      defaultProps: {
        disableElevation: true,  // Flat buttons
      },
    },
    MuiCard: {
      defaultProps: {
        elevation: 1,  // Subtle shadow
      },
    },
  },
});
```

### App Setup

**`src/App.tsx`:**
```typescript
import { ThemeProvider } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import { theme } from './theme/theme';

export default function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />  {/* Normalize CSS, apply theme background */}
      {/* Your app content */}
    </ThemeProvider>
  );
}
```

**Critical:** Always wrap app in `ThemeProvider` + `CssBaseline`.

---

## Minimal Working Examples

### 1. Basic Components

```tsx
import { Button, TextField, Card, CardContent, Typography } from '@mui/material';

export function SimpleCard() {
  return (
    <Card>
      <CardContent>
        <Typography variant="h5" gutterBottom>
          Welcome
        </Typography>
        <Typography variant="body1" color="text.secondary">
          This is a Material UI card component.
        </Typography>
        <Button variant="contained" sx={{ mt: 2 }}>
          Get Started
        </Button>
      </CardContent>
    </Card>
  );
}
```

### 2. Form with Validation

```tsx
import { TextField, Button, Box } from '@mui/material';
import { useState } from 'react';

export function LoginForm() {
  const [email, setEmail] = useState('');
  const [error, setError] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!email.includes('@')) {
      setError('Invalid email');
      return;
    }
    // Submit form
  };

  return (
    <Box component="form" onSubmit={handleSubmit} sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
      <TextField
        label="Email"
        type="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        error={!!error}
        helperText={error}
        required
      />
      <Button type="submit" variant="contained">
        Login
      </Button>
    </Box>
  );
}
```

### 3. Responsive Layout with Grid

```tsx
import { Grid, Card, CardContent, Typography } from '@mui/material';

export function Dashboard() {
  return (
    <Grid container spacing={3}>
      <Grid item xs={12} md={6} lg={4}>
        <Card>
          <CardContent>
            <Typography variant="h6">Metric 1</Typography>
            <Typography variant="h3">42</Typography>
          </CardContent>
        </Card>
      </Grid>
      
      <Grid item xs={12} md={6} lg={4}>
        <Card>
          <CardContent>
            <Typography variant="h6">Metric 2</Typography>
            <Typography variant="h3">87</Typography>
          </CardContent>
        </Card>
      </Grid>
    </Grid>
  );
}
```

**Grid breakpoints:**
- `xs`: 0-600px (mobile)
- `sm`: 600-900px (tablet)
- `md`: 900-1200px (laptop)
- `lg`: 1200-1536px (desktop)
- `xl`: 1536px+ (wide screen)

### 4. Dialog (Modal)

```tsx
import { Dialog, DialogTitle, DialogContent, DialogActions, Button } from '@mui/material';

export function ConfirmDialog({ open, onClose, onConfirm }) {
  return (
    <Dialog open={open} onClose={onClose}>
      <DialogTitle>Confirm Action</DialogTitle>
      <DialogContent>
        Are you sure you want to proceed?
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose}>Cancel</Button>
        <Button onClick={onConfirm} variant="contained" color="error">
          Confirm
        </Button>
      </DialogActions>
    </Dialog>
  );
}
```

---

## Common Operations

### Styling with `sx` Prop

```tsx
// Inline styles (preferred for one-off styling)
<Box sx={{ 
  padding: 2,                    // Spacing unit: 2 * 8px = 16px
  backgroundColor: 'primary.main',  // Theme color
  borderRadius: 1,               // 1 * 8px = 8px
  display: 'flex',
  gap: 2,
}}>
  Content
</Box>

// Responsive values
<Typography sx={{ 
  fontSize: { xs: '1rem', md: '1.5rem' }  // Small on mobile, large on desktop
}}>
  Text
</Typography>
```

### Icons

```tsx
import { Edit, Delete, Add } from '@mui/icons-material';

<Button startIcon={<Add />}>Add Item</Button>
<IconButton><Edit /></IconButton>
<Delete color="error" />
```

### Snackbar (Notifications)

```tsx
import { Snackbar, Alert } from '@mui/material';
import { useState } from 'react';

export function Notifications() {
  const [open, setOpen] = useState(false);

  return (
    <Snackbar 
      open={open} 
      autoHideDuration={6000} 
      onClose={() => setOpen(false)}
      anchorOrigin={{ vertical: 'bottom', horizontal: 'center' }}
    >
      <Alert severity="success" onClose={() => setOpen(false)}>
        Operation successful!
      </Alert>
    </Snackbar>
  );
}
```

---

## Top 5 Gotchas

### 1. Forgetting CssBaseline ⚠️

```tsx
// ❌ Wrong: Theme background not applied
<ThemeProvider theme={theme}>
  <App />
</ThemeProvider>

// ✅ Correct: CssBaseline applies theme defaults
<ThemeProvider theme={theme}>
  <CssBaseline />
  <App />
</ThemeProvider>
```

**Impact:** Background colors, margins, typography not applied.

### 2. Large Bundle Size (Not Tree-Shaking)

```tsx
// ❌ Wrong: Imports all of MUI (~1MB)
import { Button } from '@mui/material';

// ✅ Better: Direct imports (tree-shaking works)
import Button from '@mui/material/Button';
```

**Impact:** ~600KB larger bundle. Use Vite/webpack 5 for automatic tree-shaking.

### 3. Spacing Units Confusion

```tsx
// ❌ Wrong: sx={{ padding: '16px' }}  (hardcoded pixels)
<Box sx={{ padding: '16px' }}>Content</Box>

// ✅ Correct: sx={{ padding: 2 }}  (2 * 8px theme spacing)
<Box sx={{ padding: 2 }}>Content</Box>
```

**Impact:** Inconsistent spacing, theme changes don't propagate.

### 4. Typography Variant Not Set

```tsx
// ❌ Wrong: No semantic HTML, default styling
<Typography>Some text</Typography>  
// Renders: <p>Some text</p> with default styles

// ✅ Correct: Specify variant for semantics
<Typography variant="h5" component="h1">Title</Typography>
// Renders: <h1> with h5 styling
```

**Impact:** Poor accessibility, inconsistent text styling.

### 5. Dialog Not Closing on Backdrop Click

```tsx
// ❌ Wrong: Dialog doesn't close on backdrop click
<Dialog open={open}>
  <DialogContent>Content</DialogContent>
</Dialog>

// ✅ Correct: Provide onClose handler
<Dialog open={open} onClose={() => setOpen(false)}>
  <DialogContent>Content</DialogContent>
</Dialog>
```

**Impact:** Poor UX, users can't dismiss dialog intuitively.

---

## Quick Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Theme colors not applied | Missing CssBaseline | Add `<CssBaseline />` inside ThemeProvider |
| Large bundle size | Not tree-shaking | Use direct imports or configure bundler |
| Inconsistent spacing | Hardcoded pixels | Use theme spacing: `sx={{ padding: 2 }}` |
| Button text uppercase | Default MUI setting | Set `button: { textTransform: 'none' }` in theme |
| Form field too small | No fullWidth prop | Add `fullWidth` prop to TextField |
| Dialog won't close | No onClose handler | Pass `onClose` to Dialog component |

---

## References

📎 **Reference**: [mui-reference.md](mui-reference.md)  
**When to load**: Advanced theming (custom colors, dark mode, dynamic themes), complex components (DataGrid, Autocomplete, DatePicker), advanced layouts (AppBar, Drawer, navigation), form patterns (Formik integration, validation), performance optimization, custom component styling (~1,100 lines)

📎 **Related patterns**:
- [react-patterns.md](react-patterns.md) - Component design fundamentals
- [feature-folder-structure.md](feature-folder-structure.md) - Organizing MUI components
- [bff-pattern.md](bff-pattern.md) - Backend integration

---

**Pattern Type:** Component Library  
**Last Updated:** 2026-03-07  
**Complexity:** Intermediate ⭐⭐⭐☆☆
