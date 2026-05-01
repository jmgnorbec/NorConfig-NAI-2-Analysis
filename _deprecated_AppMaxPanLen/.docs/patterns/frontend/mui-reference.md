# Material UI (MUI) Patterns

**Pattern Type:** Frontend Architecture  
**Complexity:** Intermediate  
**Best For:** Rapid development, consistent design system, enterprise applications

---

## Overview

Material UI (MUI) is a popular React component library implementing Google's Material Design. It provides pre-built, customizable components with built-in accessibility, theming, and responsive design.

### When to Use

**✅ Use MUI when:**
- Need rapid UI development with consistent design
- Building enterprise/admin applications
- Want accessibility out of the box (ARIA labels, keyboard navigation)
- Team prefers opinionated design system
- Need responsive design with minimal custom CSS
- Want TypeScript support with strong typing

**❌ Don't use MUI when:**
- Need highly custom, non-Material Design UI
- Bundle size is critical concern (MUI is ~400KB minified)
- Design system already established (Tailwind, custom CSS)
- Target audience needs extremely fast load times
- Team unfamiliar with Material Design principles

---

## Installation

```bash
# Install MUI core + dependencies
npm install @mui/material @emotion/react @emotion/styled

# Install MUI icons (optional)
npm install @mui/icons-material

# For date pickers (optional)
npm install @mui/x-date-pickers
```

---

## Theme Setup

### Basic Theme Configuration

**`src/theme/theme.ts`** - Custom theme with brand colors

```typescript
import { ThemeOptions } from '@mui/material/styles';

interface BrandOptions {
  primary?: string;
}

/**
 * Build MUI theme with custom branding
 */
export function buildTheme(opts: BrandOptions = {}): ThemeOptions {
  const primary = opts.primary ?? '#1976d2'; // Default MUI blue
  
  return {
    // Color palette
    palette: {
      mode: 'light',
      primary: {
        main: primary,
        light: lighten(primary, 0.15),
        dark: darken(primary, 0.2),
        contrastText: '#ffffff',
      },
      secondary: {
        main: '#dc004e',
        light: '#e33371',
        dark: '#9a0036',
        contrastText: '#ffffff',
      },
      background: {
        default: '#f5f5f7',  // Light gray background
        paper: '#ffffff',     // White paper surfaces
      },
      text: {
        primary: '#1a1a1a',   // Near-black text
        secondary: '#6e6e73', // Gray secondary text
      },
      divider: '#e8e8ed',     // Light divider lines
      error: { main: '#ff3b30' },
      warning: { main: '#ff9500' },
      success: { main: '#34c759' },
      info: { main: primary },
    },
    
    // Shape (border radius)
    shape: {
      borderRadius: 6, // Slightly rounded corners
    },
    
    // Typography
    typography: {
      fontFamily: [
        '-apple-system',
        'BlinkMacSystemFont',
        '"Segoe UI"',
        'Roboto',
        'sans-serif',
      ].join(','),
      h1: { fontWeight: 600, fontSize: '2rem', letterSpacing: '-0.02em' },
      h2: { fontWeight: 600, fontSize: '1.75rem', letterSpacing: '-0.01em' },
      h3: { fontWeight: 600, fontSize: '1.5rem' },
      h4: { fontWeight: 600, fontSize: '1.25rem' },
      h5: { fontWeight: 600, fontSize: '1.125rem' },
      h6: { fontWeight: 600, fontSize: '1rem' },
      body1: { fontSize: '0.9375rem', lineHeight: 1.6 },
      body2: { fontSize: '0.875rem', lineHeight: 1.6 },
      button: { textTransform: 'none', fontWeight: 500, fontSize: '0.875rem' },
    },
    
    // Component overrides
    components: {
      MuiButton: {
        styleOverrides: {
          root: {
            borderRadius: 6,
            padding: '7px 14px',
            boxShadow: 'none',
            '&:hover': { boxShadow: '0 1px 2px 0 rgb(0 0 0 / 0.05)' },
          },
          outlined: {
            borderColor: '#e8e8ed', // Custom border color
          },
        },
      },
      MuiCard: {
        styleOverrides: {
          root: {
            boxShadow: '0 1px 2px 0 rgb(0 0 0 / 0.05)',
            borderRadius: 8,
            border: '1px solid #e8e8ed',
          },
        },
      },
      MuiDrawer: {
        styleOverrides: {
          paper: {
            borderRight: '1px solid #e8e8ed',
            backgroundColor: '#fafafa',
          },
        },
      },
      MuiContainer: {
        defaultProps: {
          maxWidth: 'lg', // Default container width
        },
      },
    },
  };
}

// Utility functions for color manipulation
function lighten(hex: string, amt: number): string {
  return adjustColor(hex, amt);
}

function darken(hex: string, amt: number): string {
  return adjustColor(hex, -amt);
}

function adjustColor(hex: string, amt: number): string {
  const c = hex.replace('#', '');
  const num = parseInt(c, 16);
  let r = (num >> 16) + Math.round(255 * amt);
  let g = ((num >> 8) & 0x00ff) + Math.round(255 * amt);
  let b = (num & 0x0000ff) + Math.round(255 * amt);
  r = Math.min(255, Math.max(0, r));
  g = Math.min(255, Math.max(0, g));
  b = Math.min(255, Math.max(0, b));
  return '#' + ((r << 16) | (g << 8) | b).toString(16).padStart(6, '0');
}
```

**Key concepts:**
- **Palette**: Brand colors, background, text colors
- **Typography**: Font family, sizes, weights
- **Component overrides**: Customize default component styles
- **Shape**: Global border radius
- **lighten/darken utilities**: Programmatic color variations

---

### Apply Theme in App

**`src/main.tsx`** - Wrap app with ThemeProvider

```typescript
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { ThemeProvider, CssBaseline, createTheme } from '@mui/material';
import { buildTheme } from './theme/theme';
import App from './App';

// Create theme instance
const theme = createTheme(buildTheme({ primary: '#1E6BFF' }));

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <ThemeProvider theme={theme}>
      <CssBaseline /> {/* Reset browser styles + apply theme background */}
      <App />
    </ThemeProvider>
  </StrictMode>
);
```

**Key concepts:**
- **ThemeProvider**: Makes theme available to all components via React context
- **CssBaseline**: Normalizes browser styles + applies theme defaults
- **createTheme**: Merges custom theme with MUI defaults

---

## Component Patterns

### 1. Dialog (Modal)

**Dialog for forms, confirmations, detailed views**

```typescript
import { useState } from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  TextField,
  MenuItem,
  FormControl,
  InputLabel,
  Select,
  Grid,
} from '@mui/material';

interface CreateUserDialogProps {
  open: boolean;
  onClose: () => void;
  onCreate: (userData: {
    email: string;
    role: 'user' | 'admin' | 'super-user';
  }) => Promise<void>;
}

export default function CreateUserDialog({ open, onClose, onCreate }: CreateUserDialogProps) {
  const [email, setEmail] = useState('');
  const [role, setRole] = useState<'user' | 'admin' | 'super-user'>('user');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async () => {
    setError(null);
    
    // Validation
    if (!email) {
      setError('Email is required');
      return;
    }

    try {
      setLoading(true);
      await onCreate({ email, role });
      handleClose(); // Close on success
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to create user');
    } finally {
      setLoading(false);
    }
  };

  const handleClose = () => {
    // Reset form state on close
    setEmail('');
    setRole('user');
    setError(null);
    onClose();
  };

  return (
    <Dialog
      open={open}
      onClose={handleClose}
      maxWidth="sm"  // xs, sm, md, lg, xl
      fullWidth      // Use maxWidth as full width
    >
      <DialogTitle>Create New User</DialogTitle>
      
      <DialogContent>
        <Grid container spacing={2} sx={{ mt: 0.5 }}>
          <Grid item xs={12}>
            <TextField
              fullWidth
              required
              label="Email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              error={!!error && !email}
              helperText={!email && error ? 'Email is required' : ''}
            />
          </Grid>
          
          <Grid item xs={12}>
            <FormControl fullWidth required>
              <InputLabel>Role</InputLabel>
              <Select
                value={role}
                label="Role"
                onChange={(e) => setRole(e.target.value as 'user' | 'admin' | 'super-user')}
              >
                <MenuItem value="user">User</MenuItem>
                <MenuItem value="admin">Admin</MenuItem>
                <MenuItem value="super-user">Super User</MenuItem>
              </Select>
            </FormControl>
          </Grid>
          
          {error && (
            <Grid item xs={12}>
              <TextField
                fullWidth
                error
                value={error}
                InputProps={{ readOnly: true }}
                variant="outlined"
                multiline
              />
            </Grid>
          )}
        </Grid>
      </DialogContent>
      
      <DialogActions>
        <Button onClick={handleClose} disabled={loading}>
          Cancel
        </Button>
        <Button onClick={handleSubmit} variant="contained" disabled={loading}>
          {loading ? 'Creating...' : 'Create User'}
        </Button>
      </DialogActions>
    </Dialog>
  );
}
```

**Usage:**
```typescript
function UserManagement() {
  const [dialogOpen, setDialogOpen] = useState(false);
  
  const handleCreate = async (userData) => {
    await api.createUser(userData);
    // ... refresh list
  };
  
  return (
    <>
      <Button onClick={() => setDialogOpen(true)}>Create User</Button>
      
      <CreateUserDialog
        open={dialogOpen}
        onClose={() => setDialogOpen(false)}
        onCreate={handleCreate}
      />
    </>
  );
}
```

**Key concepts:**
- **Dialog props**: `open` (controlled state), `onClose` (handler), `maxWidth`, `fullWidth`
- **DialogTitle, DialogContent, DialogActions**: Standard dialog sections
- **Reset form on close**: Clear state when dialog closes
- **Loading state**: Disable buttons while submitting
- **Error display**: Show validation/API errors

---

### 2. TextField (Form Input)

**Text input with validation and error states**

```typescript
import { TextField } from '@mui/material';

// Basic text input
<TextField
  label="Email"
  type="email"
  value={email}
  onChange={(e) => setEmail(e.target.value)}
  fullWidth
/>

// Required field with error state
<TextField
  required
  label="Password"
  type="password"
  value={password}
  onChange={(e) => setPassword(e.target.value)}
  error={!!error}
  helperText={error || 'At least 8 characters'}
  fullWidth
/>

// Multiline (textarea)
<TextField
  label="Description"
  value={description}
  onChange={(e) => setDescription(e.target.value)}
  multiline
  rows={4}
  fullWidth
/>

// Read-only display
<TextField
  label="User ID"
  value={userId}
  InputProps={{ readOnly: true }}
  variant="filled"
  fullWidth
/>

// With placeholder
<TextField
  label="Phone Number"
  placeholder="+1234567890"
  value={phone}
  onChange={(e) => setPhone(e.target.value)}
  helperText="E.164 format with country code"
  fullWidth
/>
```

**Key concepts:**
- **label**: Floating label (moves up when focused)
- **value + onChange**: Controlled component
- **error + helperText**: Validation feedback
- **required**: Visual indicator (asterisk)
- **multiline + rows**: Textarea mode
- **InputProps**: Customize inner input element
- **variant**: `outlined` (default), `filled`, `standard`
- **fullWidth**: Expand to container width

---

### 3. Select/Dropdown

**Dropdown for single-choice selection**

```typescript
import { FormControl, InputLabel, Select, MenuItem } from '@mui/material';

function RoleSelect() {
  const [role, setRole] = useState('user');
  
  return (
    <FormControl fullWidth required>
      <InputLabel>Role</InputLabel>
      <Select
        value={role}
        label="Role"  // Must match InputLabel for proper floating
        onChange={(e) => setRole(e.target.value)}
      >
        <MenuItem value="user">User</MenuItem>
        <MenuItem value="admin">Admin</MenuItem>
        <MenuItem value="super-user">Super User</MenuItem>
      </Select>
    </FormControl>
  );
}

// With "None" option
<FormControl fullWidth>
  <InputLabel>OTP Preference</InputLabel>
  <Select
    value={preference}
    label="OTP Preference"
    onChange={(e) => setPreference(e.target.value)}
  >
    <MenuItem value="">None (user chooses)</MenuItem>
    <MenuItem value="sms">SMS</MenuItem>
    <MenuItem value="email">Email</MenuItem>
  </Select>
</FormControl>
```

**Key concepts:**
- **FormControl**: Wrapper for form elements (provides layout, spacing)
- **InputLabel**: Floating label (must match Select `label` prop)
- **Select + MenuItem**: Dropdown with options
- **Empty string value**: Represents "no selection"
- **required**: Visual indicator on FormControl

---

### 4. Button

**Buttons with variants, loading states, and icons**

```typescript
import { Button, CircularProgress } from '@mui/material';
import AddIcon from '@mui/icons-material/Add';
import DeleteIcon from '@mui/icons-material/Delete';

// Contained button (primary action)
<Button variant="contained" onClick={handleSubmit}>
  Submit
</Button>

// Outlined button (secondary action)
<Button variant="outlined" onClick={handleCancel}>
  Cancel
</Button>

// Text button (tertiary action)
<Button variant="text" onClick={handleReset}>
  Reset
</Button>

// Button with icon
<Button variant="contained" startIcon={<AddIcon />} onClick={handleCreate}>
  Create User
</Button>

// Icon-only button
<Button variant="outlined" onClick={handleDelete}>
  <DeleteIcon />
</Button>

// Loading state
<Button variant="contained" disabled={loading} onClick={handleSubmit}>
  {loading ? <CircularProgress size={20} color="inherit" /> : 'Submit'}
</Button>

// Color variants
<Button variant="contained" color="primary">Primary</Button>
<Button variant="contained" color="secondary">Secondary</Button>
<Button variant="contained" color="error">Delete</Button>
<Button variant="contained" color="success">Confirm</Button>
```

**Key concepts:**
- **variant**: `contained` (filled), `outlined` (border), `text` (no background)
- **color**: `primary`, `secondary`, `error`, `warning`, `success`, `info`
- **startIcon/endIcon**: Icon before/after button text
- **disabled**: Grayed out, cannot click
- **size**: `small`, `medium` (default), `large`

---

### 5. Table

**Data table with actions**

```typescript
import {
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  IconButton,
  Tooltip,
  Chip,
} from '@mui/material';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';

interface User {
  id: string;
  email: string;
  role: string;
  isActive: boolean;
}

function UserTable({ users }: { users: User[] }) {
  return (
    <TableContainer component={Paper}>
      <Table>
        <TableHead>
          <TableRow>
            <TableCell>Email</TableCell>
            <TableCell>Role</TableCell>
            <TableCell>Status</TableCell>
            <TableCell align="right">Actions</TableCell>
          </TableRow>
        </TableHead>
        
        <TableBody>
          {users.map((user) => (
            <TableRow key={user.id} hover>
              <TableCell>{user.email}</TableCell>
              
              <TableCell>
                <Chip
                  label={user.role}
                  size="small"
                  color={user.role === 'admin' ? 'warning' : 'default'}
                />
              </TableCell>
              
              <TableCell>
                <Chip
                  label={user.isActive ? 'Active' : 'Inactive'}
                  size="small"
                  color={user.isActive ? 'success' : 'default'}
                />
              </TableCell>
              
              <TableCell align="right">
                <Tooltip title="Edit">
                  <IconButton size="small" onClick={() => handleEdit(user)}>
                    <EditIcon />
                  </IconButton>
                </Tooltip>
                
                <Tooltip title="Delete">
                  <IconButton size="small" onClick={() => handleDelete(user)}>
                    <DeleteIcon />
                  </IconButton>
                </Tooltip>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </TableContainer>
  );
}
```

**Key concepts:**
- **TableContainer + Paper**: Wrap table in Paper for elevation
- **TableHead + TableBody**: Separate header and body rows
- **TableRow + TableCell**: Row and cell structure
- **hover**: Highlight row on mouse hover
- **align**: `left` (default), `center`, `right`
- **Chip**: Tag-like component for status indicators
- **IconButton**: Small button for actions
- **Tooltip**: Show hint on hover

---

### 6. Card

**Card for content sections**

```typescript
import { Card, CardContent, CardActions, Typography, Button } from '@mui/material';

function FeatureCard({ title, description }: { title: string; description: string }) {
  return (
    <Card>
      <CardContent>
        <Typography variant="h5" component="h2" gutterBottom>
          {title}
        </Typography>
        
        <Typography variant="body2" color="text.secondary">
          {description}
        </Typography>
      </CardContent>
      
      <CardActions>
        <Button size="small">Learn More</Button>
      </CardActions>
    </Card>
  );
}

// Card with header and elevation
import { CardHeader, Avatar } from '@mui/material';

<Card elevation={3}>
  <CardHeader
    avatar={<Avatar>A</Avatar>}
    title="User Profile"
    subheader="Last updated: 2 hours ago"
  />
  <CardContent>
    {/* ... */}
  </CardContent>
</Card>
```

**Key concepts:**
- **Card**: Container with elevation/shadow
- **CardContent**: Main content area
- **CardActions**: Action buttons at bottom
- **CardHeader**: Title, subtitle, avatar
- **elevation**: 0-24 (shadow depth)
- **variant**: `elevation` (default), `outlined`

---

### 7. Alert/Notification

**Show success, error, warning, info messages**

```typescript
import { Alert, AlertTitle } from '@mui/material';

// Basic alert
<Alert severity="error">
  Failed to load users. Please try again.
</Alert>

// Alert with title
<Alert severity="success">
  <AlertTitle>Success</AlertTitle>
  User created successfully!
</Alert>

// Dismissible alert
<Alert severity="warning" onClose={() => setError(null)}>
  This action cannot be undone.
</Alert>

// Info alert with action
<Alert severity="info" action={
  <Button color="inherit" size="small" onClick={handleRetry}>
    Retry
  </Button>
}>
  Connection lost. Check your network.
</Alert>
```

**Key concepts:**
- **severity**: `error`, `warning`, `info`, `success`
- **onClose**: Show close button, handler called on click
- **AlertTitle**: Bold title above message
- **action**: Custom action button/link

---

## Layout Patterns

### 1. Grid Layout (Responsive)

**12-column responsive grid system**

```typescript
import { Grid } from '@mui/material';

function DashboardLayout() {
  return (
    <Grid container spacing={3}>
      {/* Full-width header (12 columns) */}
      <Grid item xs={12}>
        <Typography variant="h4">Dashboard</Typography>
      </Grid>
      
      {/* 2 cards side-by-side on desktop, stacked on mobile */}
      <Grid item xs={12} md={6}>
        <StatsCard title="Total Users" value={1234} />
      </Grid>
      
      <Grid item xs={12} md={6}>
        <StatsCard title="Active Users" value={567} />
      </Grid>
      
      {/* 3 cards on desktop, 1 on mobile */}
      <Grid item xs={12} sm={6} md={4}>
        <MetricCard metric="Revenue" />
      </Grid>
      
      <Grid item xs={12} sm={6} md={4}>
        <MetricCard metric="Conversions" />
      </Grid>
      
      <Grid item xs={12} sm={12} md={4}>
        <MetricCard metric="Engagement" />
      </Grid>
    </Grid>
  );
}
```

**Breakpoint system:**
- **xs**: 0px+ (extra small, mobile)
- **sm**: 600px+ (small, tablet portrait)
- **md**: 900px+ (medium, tablet landscape)
- **lg**: 1200px+ (large, desktop)
- **xl**: 1536px+ (extra large, wide desktop)

**Grid props:**
- **container**: Marks element as grid container
- **item**: Marks element as grid item
- **spacing**: Gap between items (0-10, 1 = 8px)
- **xs/sm/md/lg/xl**: Number of columns (1-12) at each breakpoint

---

### 2. Stack Layout (Flex)

**Vertical or horizontal flex layout with spacing**

```typescript
import { Stack } from '@mui/material';

// Vertical stack (default)
<Stack spacing={2}>
  <Button>Button 1</Button>
  <Button>Button 2</Button>
  <Button>Button 3</Button>
</Stack>

// Horizontal stack
<Stack direction="row" spacing={2}>
  <Button>Cancel</Button>
  <Button variant="contained">Submit</Button>
</Stack>

// Responsive direction (row on desktop, column on mobile)
<Stack direction={{ xs: 'column', sm: 'row' }} spacing={2}>
  <TextField label="First Name" fullWidth />
  <TextField label="Last Name" fullWidth />
</Stack>

// Align items
<Stack direction="row" spacing={2} alignItems="center" justifyContent="space-between">
  <Typography>Title</Typography>
  <Button>Action</Button>
</Stack>
```

**Key concepts:**
- **direction**: `row`, `column`, `row-reverse`, `column-reverse`
- **spacing**: Gap between items (0-10, or custom like `1.5`)
- **alignItems**: Cross-axis alignment (`flex-start`, `center`, `flex-end`, `stretch`)
- **justifyContent**: Main-axis alignment (`flex-start`, `center`, `flex-end`, `space-between`, `space-around`)

---

### 3. Box (Generic Container)

**Flexible container with sx prop for styling**

```typescript
import { Box } from '@mui/material';

// Centered content
<Box sx={{
  display: 'flex',
  justifyContent: 'center',
  alignItems: 'center',
  minHeight: '100vh',
}}>
  <CircularProgress />
</Box>

// Padding and margin
<Box sx={{ p: 3, mb: 2 }}>
  {/* p: padding, m: margin, t/b/l/r: top/bottom/left/right */}
  {/* p: 3 = 3 * 8px = 24px */}
  <Typography>Content</Typography>
</Box>

// Responsive styles
<Box sx={{
  width: { xs: '100%', sm: '50%', md: '33%' },
  backgroundColor: 'background.paper',
  borderRadius: 1,
  boxShadow: 1,
}}>
  {/* ... */}
</Box>

// Absolute positioning
<Box sx={{
  position: 'absolute',
  top: 16,
  right: 16,
  zIndex: 1000,
}}>
  <Button>Action</Button>
</Box>
```

**sx prop shortcuts:**
- **p**: padding (pt, pb, pl, pr, px, py)
- **m**: margin (mt, mb, ml, mr, mx, my)
- **width, height**: Size
- **backgroundColor, color**: Colors
- **borderRadius**: Corners (1 = theme.shape.borderRadius)
- **boxShadow**: Elevation (1-24)

---

## Form Patterns

### Form with Validation

**Controlled form with useState and validation**

```typescript
import { useState } from 'react';
import { TextField, Button, Stack, Alert } from '@mui/material';

function SignInForm() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [errors, setErrors] = useState<{ email?: string; password?: string }>({});
  const [loading, setLoading] = useState(false);
  const [serverError, setServerError] = useState<string | null>(null);

  const validate = () => {
    const newErrors: { email?: string; password?: string } = {};
    
    // Email validation
    if (!email) {
      newErrors.email = 'Email is required';
    } else if (!/\S+@\S+\.\S+/.test(email)) {
      newErrors.email = 'Email is invalid';
    }
    
    // Password validation
    if (!password) {
      newErrors.password = 'Password is required';
    } else if (password.length < 8) {
      newErrors.password = 'Password must be at least 8 characters';
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!validate()) return;
    
    try {
      setLoading(true);
      setServerError(null);
      await api.login({ email, password });
      // ... redirect on success
    } catch (err) {
      setServerError(err instanceof Error ? err.message : 'Login failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <Stack spacing={2}>
        {serverError && (
          <Alert severity="error" onClose={() => setServerError(null)}>
            {serverError}
          </Alert>
        )}
        
        <TextField
          label="Email"
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          error={!!errors.email}
          helperText={errors.email}
          fullWidth
          required
        />
        
        <TextField
          label="Password"
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          error={!!errors.password}
          helperText={errors.password}
          fullWidth
          required
        />
        
        <Button
          type="submit"
          variant="contained"
          fullWidth
          disabled={loading}
        >
          {loading ? 'Signing in...' : 'Sign In'}
        </Button>
      </Stack>
    </form>
  );
}
```

**Key concepts:**
- **Controlled inputs**: value + onChange
- **Client validation**: Check errors before submit
- **Error state**: error prop + helperText
- **Loading state**: Disable button, show loading text
- **Server errors**: Display API errors above form

---

## Responsive Design

### Using useMediaQuery Hook

**Conditional rendering based on screen size**

```typescript
import { useMediaQuery, useTheme } from '@mui/material';

function ResponsiveComponent() {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('sm')); // < 600px
  const isTablet = useMediaQuery(theme.breakpoints.between('sm', 'md')); // 600px - 900px
  const isDesktop = useMediaQuery(theme.breakpoints.up('md')); // >= 900px
  
  return (
    <Box>
      {isMobile && <MobileMenu />}
      {isDesktop && <DesktopMenu />}
      
      <Typography variant={isMobile ? 'h6' : 'h4'}>
        Welcome
      </Typography>
    </Box>
  );
}
```

**Breakpoint utilities:**
- **down('sm')**: <= 600px
- **up('md')**: >= 900px
- **between('sm', 'md')**: 600px - 900px
- **only('md')**: 900px - 1200px (md breakpoint only)

---

### Responsive sx Props

**Built-in responsive styling**

```typescript
// Different widths at different breakpoints
<Box sx={{
  width: { xs: '100%', sm: '80%', md: '60%', lg: '50%' },
  padding: { xs: 2, sm: 3, md: 4 },
  fontSize: { xs: '0.875rem', sm: '1rem', md: '1.125rem' },
}}>
  Content
</Box>

// Hide on mobile
<Box sx={{ display: { xs: 'none', sm: 'block' } }}>
  Desktop only
</Box>

// Show only on mobile
<Box sx={{ display: { xs: 'block', sm: 'none' } }}>
  Mobile only
</Box>
```

---

## Icons

### Using MUI Icons

```bash
npm install @mui/icons-material
```

```typescript
import AddIcon from '@mui/icons-material/Add';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import SettingsIcon from '@mui/icons-material/Settings';

// In button
<Button startIcon={<AddIcon />}>Create</Button>

// Standalone icon
<CheckCircleIcon color="success" />

// Icon button
<IconButton onClick={handleEdit}>
  <EditIcon />
</IconButton>

// Icon with size
<SettingsIcon fontSize="small" />    {/* 20px */}
<SettingsIcon fontSize="medium" />   {/* 24px (default) */}
<SettingsIcon fontSize="large" />    {/* 32px */}

// Icon with custom color
<DeleteIcon sx={{ color: 'error.main' }} />
```

**Popular icons:**
- Navigation: `Menu`, `Close`, `ArrowBack`, `ArrowForward`
- Actions: `Add`, `Edit`, `Delete`, `Save`, `Cancel`, `Search`
- Status: `CheckCircle`, `Error`, `Warning`, `Info`
- Toggle: `Visibility`, `VisibilityOff`, `KeyboardArrowDown`, `KeyboardArrowUp`

---

## Loading States

### CircularProgress

```typescript
import { CircularProgress, Box } from '@mui/material';

// Centered spinner
<Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '400px' }}>
  <CircularProgress />
</Box>

// Small inline spinner
<CircularProgress size={20} />

// In button
<Button disabled={loading}>
  {loading ? <CircularProgress size={20} color="inherit" /> : 'Submit'}
</Button>

// With text
<Stack direction="row" spacing={2} alignItems="center">
  <CircularProgress size={24} />
  <Typography>Loading users...</Typography>
</Stack>
```

### Skeleton (Placeholder)

```typescript
import { Skeleton, Card, CardContent } from '@mui/material';

// Loading placeholder for text
<Skeleton variant="text" width={200} />
<Skeleton variant="text" width="80%" />

// Loading card
<Card>
  <CardContent>
    <Skeleton variant="rectangular" height={118} />
    <Skeleton variant="text" />
    <Skeleton variant="text" width="60%" />
  </CardContent>
</Card>

// Loading avatar
<Skeleton variant="circular" width={40} height={40} />
```

---

## Best Practices

### ✅ Do

1. **Use theme tokens** - Access colors via `theme.palette.primary.main`, not hardcoded hex
2. **Use sx prop** - For one-off styles, cleaner than styled()
3. **Use Stack/Grid** - For layout, avoid custom flex CSS
4. **Use responsive props** - `{ xs: value, md: value }` for responsive design
5. **Use MUI icons** - Consistent with Material Design
6. **Centralize theme** - Custom theme in one file
7. **Use CssBaseline** - Reset browser styles consistently
8. **Controlled components** - Always use value + onChange
9. **Loading states** - Disable buttons, show spinners during async operations
10. **Validation errors** - Show helperText for user guidance

### ❌ Don't

1. **Don't hardcode colors** - Use theme palette
2. **Don't mix CSS with sx** - Choose one approach
3. **Don't skip labels** - Forms need InputLabel for accessibility
4. **Don't forget fullWidth** - TextFields look better with fullWidth
5. **Don't override too much** - Use theme overrides for global styles
6. **Don't import entire icon library** - Import specific icons only
7. **Don't use inline styles** - Use sx prop instead
8. **Don't skip error boundaries** - Handle component errors gracefully
9. **Don't forget responsive design** - Test on mobile breakpoints
10. **Don't bundle entire MUI** - Use tree-shaking (automatic with modern bundlers)

---

## Troubleshooting

### Issue: Label not floating properly in Select

**Symptom:** InputLabel doesn't shrink when Select has value

**Solution:**
```typescript
// Ensure Select `label` prop matches InputLabel text EXACTLY
<FormControl fullWidth>
  <InputLabel>Role</InputLabel>
  <Select
    value={role}
    label="Role"  // ← Must match InputLabel
  >
    {/* ... */}
  </Select>
</FormControl>
```

### Issue: Theme not applied to components

**Symptom:** Components use default MUI theme, not custom theme

**Solution:**
```typescript
// Wrap App with ThemeProvider
import { ThemeProvider, createTheme } from '@mui/material';
import { buildTheme } from './theme/theme';

const theme = createTheme(buildTheme());

<ThemeProvider theme={theme}>
  <CssBaseline />
  <App />
</ThemeProvider>
```

### Issue: Grid spacing cuts off content

**Symptom:** Grid container causes horizontal scrollbar or cut-off content

**Solution:**
```typescript
// Wrap Grid container in Box with negative margin offset
<Box sx={{ overflow: 'hidden' }}>
  <Grid container spacing={3}>
    {/* ... */}
  </Grid>
</Box>

// Or use Stack instead of Grid for simpler cases
<Stack spacing={2}>
  {/* ... */}
</Stack>
```

---

## References

### Source Code
- **Enterprise application UI**: `d:\_dev\Enterprise application\webui\ui\src\`
  - `theme/theme.ts`: Custom theme configuration
  - `shell/App.tsx`: ThemeProvider setup
  - `pages/admin/UserManagement.tsx`: Table, Chip, IconButton patterns
  - `pages/SignIn.tsx`: Form patterns with validation
  - `components/admin/CreateUserDialog.tsx`: Dialog, TextField, Select patterns

### Related Patterns
- 📎 [Feature Folder Structure](./feature-folder-structure.md) - Component organization
- 📎 [React Patterns](./react-patterns.md) - Component design patterns
- 📎 [TanStack Query Patterns](./tanstack-query-patterns.md) - Data fetching

### External Resources
- [Material UI Documentation](https://mui.com/)
- [Material Design Guidelines](https://material.io/design)
- [MUI Icons Gallery](https://mui.com/material-ui/material-icons/)
- [MUI System (sx prop)](https://mui.com/system/getting-started/the-sx-prop/)

---

**Pattern Version:** 1.0.0  
**Last Updated:** 2026-01-28  
**Extracted From:** Enterprise application v0.2.11 (WebUI service)
