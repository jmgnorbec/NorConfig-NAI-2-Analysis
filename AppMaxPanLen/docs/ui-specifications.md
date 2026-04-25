# UI Specifications

## Design Philosophy

**Style:** "Toy but pro" - playful yet professional, inspired by ToitCalc Pro

**Reference:** See [References/UI style example.png](../References/UI%20style%20example.png)

---

## Visual Design

### Color Palette
- **Header:** Dark navy (#1a2332 or similar)
- **Primary accent:** Blue (#3b82f6 or similar)
- **Background:** Light gray (#f3f4f6)
- **Cards:** White with subtle shadow
- **Text:** Dark gray for body, white for header

### Typography
- **Header:** Bold, large for app title
- **Section titles:** Medium weight, 14-16px
- **Body:** Regular weight, 14px
- **Result:** Large, bold (32-48px)

### Layout Structure

```
┌─────────────────────────────────────────────────────────────┐
│  Header (Dark Navy)                                         │
│  MaxPanelLength                            [Plant: STH]     │
└─────────────────────────────────────────────────────────────┘
┌────────────────────────┬────────────────────────────────────┐
│  Left Panel            │  Right Panel                       │
│  (Parameters)          │  (Result Display)                  │
│                        │                                    │
│  [Clear]               │  ┌──────────────────────────────┐  │
│                        │  │  Maximum Length              │  │
│  Plant Selection       │  │  52.25 ft                    │  │
│  Color List            │  │                              │  │
│  Paint Buttons         │  │  Selected:                   │  │
│  Gage Buttons          │  │  • Color: Blanc Régal        │  │
│  Profile Buttons       │  │  • Paint: PVDF CLASSIC       │  │
│  Finish Buttons        │  │  • Gage: 22                  │  │
│                        │  │  • Profile: Grooved          │  │
│                        │  │  • Finish: Embossed          │  │
│                        │  └──────────────────────────────┘  │
└────────────────────────┴────────────────────────────────────┘
```

---

## Component Specifications

### 1. Plant Selection
**Control Type:** Toggle switch or button group

**Appearance:**
- Two options: STH | SRY
- Active state: Blue background, white text
- Inactive state: Light gray background, dark text
- Smooth transition animation

**States:**
- **Selected:** One plant active
- **Third state (unselected):** Neither selected (initial state, after Clear)

**Behavior:**
- Single selection (radio button behavior)
- Clicking same selection does nothing
- Cannot deselect to third state by clicking (only via Clear button)

---

### 2. Color Selection
**Control Type:** Scrollable list with radio button behavior

**Appearance:**
- Vertical list in card/panel
- Each color as clickable row
- Selected: Blue border/background highlight
- Available: Full opacity, cursor pointer
- Unavailable: Grayed out, cursor not-allowed
- Max height with scroll (e.g., 300px)

**Display:**
- Show bilingual names as-is from CSV: "Blanc Régal/Regal White"
- 14px font size
- Padding for comfortable clicking
- Hover state for available colors

**States:**
- **Selected:** One color highlighted
- **Third state (unselected):** No selection, placeholder text "Select a color"
- **No options available:** Show message "No colors available for selected plant"

---

### 3. Paint Type Selection
**Control Type:** Button group (horizontal)

**Appearance:**
- Buttons: PVDF CLASSIC | PVDF SIGNATURE | SMP CLASSIC | SMP PREMIUM | METALLIC
- Selected: Blue background, white text
- Available: White background, blue border, dark text
- Unavailable: Light gray background, gray text, cursor not-allowed
- Equal width buttons or auto-width with padding

**States:**
- **Selected:** One paint type active
- **Third state (unselected):** All buttons outlined, none filled
- **No options available:** All buttons disabled with message

---

### 4. Gage Selection
**Control Type:** Button group (horizontal)

**Appearance:**
- Three buttons: 22 | 24 | 26
- Same styling as Paint Type
- Smaller, compact layout

**States:**
- **Selected:** One gage highlighted
- **Third state (unselected):** None selected
- **No options available:** All disabled

---

### 5. Profile Selection
**Control Type:** Button group (horizontal or 2x2 grid)

**Appearance:**
- Four options: Grooved | Silkline | Microribbed | None
- Same styling as Paint Type
- Consider 2x2 grid if horizontal doesn't fit well

**States:**
- **Selected:** One profile active
- **Third state (unselected):** None selected
- **No options available:** All disabled

---

### 6. Finish Selection
**Control Type:** Toggle/Button group

**Appearance:**
- Two buttons: Embossed | Smooth
- Larger buttons (only two options)
- Same styling as other button groups

**States:**
- **Selected:** One finish active
- **Third state (unselected):** None selected
- **No options available:** Both disabled

---

### 7. Result Display
**Control Type:** Information card

**Appearance:**
- Large card on right panel
- Prominent number display (32-48px bold)
- Unit displayed (ft or feet)
- Background: white card with shadow
- Padding: generous spacing

**Content:**
- **When complete:** 
  - Large number: "52.25 ft" or "NA"
  - Label: "Maximum Panel Length"
  - Selected parameters summary below
  
- **When incomplete:**
  - Placeholder text: "Select all parameters to view result"
  - Light gray text
  
- **When NA:**
  - Display "NA" or "Not Available" prominently
  - Style differently (orange/warning color?)
  - Still show selected parameters

**Selected Parameters Summary:**
```
Selected Parameters:
• Plant: St-Hyacinthe (STH)
• Color: Blanc Régal/Regal White
• Paint: PVDF CLASSIC
• Gage: 22
• Profile: Grooved
• Finish: Embossed
```

---

### 8. Clear Button
**Control Type:** Button

**Appearance:**
- Positioned at top of left panel
- Secondary button style (outline or light gray)
- Text: "Clear" or "Reset"
- Icon optional (⟲ or ✕)

**Behavior:**
- Resets ALL parameters to third state (unselected)
- Includes Plant selection
- Clears result display
- Returns UI to initial empty state

---

## Data Loading & Management

### API Integration

**Endpoints:** See [api-specification.md](api-specification.md) for complete API details
- Plants list endpoint for startup
- Plant data endpoint for fetching complete dataset

### Initial Load Flow

**On application startup:**
- Load and display available plants from API
- Wait for user to select plant before loading data

**When user selects a plant:**
- Fetch complete dataset for selected plant (~50-100 rows)
- Cache dataset in application state for session duration
- Extract unique filter options from dataset (colors, paints, gages)
- Populate color list with available colors

### Data Caching Strategy

**Session-level caching:**
- Cache dataset until page refresh or plant change
- When plant changes: replace cache with new plant's dataset
- No expiry or server polling needed (data is static)
- Dataset size (<50KB) allows efficient client-side storage

### Dynamic Filtering Pattern

**Filter options based on current selections:**
- Extract unique values from dataset matching current selections
- Enable/disable characteristic buttons based on availability in filtered dataset
- When color selected: filter available paints/gages/profiles/finishes for that color
- When color + paint selected: further filter based on both criteria
- Continue progressive filtering as user makes selections

### Loading States

**During data fetch:**
- Display loading indicator
- Disable interactive controls
- Show "Loading..." message

**After successful load:**
- Enable controls
- Populate available options
- Remove loading indicators

**On error:**
- Display error message in result panel
- Preserve previous state if available
- Provide retry action

---

## Interaction Logic

### Parameter Hierarchy
```
Plant (Level 0)
  ↓
Color (Level 1)
  ↓
Paint, Gage, Profile, Finish (Level 2)
```

### Selection Flow

**Initial State:**
- All parameters in third state (unselected)
- Result display shows placeholder

**Step 1: Select Plant**
- Color list populates with available colors for plant
- Other characteristics remain disabled/empty

**Step 2: Select Color**
- Paint/Gage/Profile/Finish buttons populate with available options
- Only show/enable options that exist for selected Plant + Color combination
- Buttons with no valid options shown as disabled or hidden

**Step 3: Select Characteristics**
- User selects Paint, Gage, Profile, Finish in any order
- Result displays once all parameters selected
- Frontend calculates from local dataset

---

## State Management Rules

### Rule 1: Plant Change
**When user changes plant selection:**

1. Load available colors for new plant
2. **IF** currently selected color exists in new plant:
   - **Keep color selected**
   - Reload characteristics for new plant + same color
   - Apply Rule 2 logic to characteristics
3. **ELSE** (color not available in new plant):
   - **Reset color to third state**
   - Reset all characteristics to third state
   - Show "Select a color" state

### Rule 2: Color Change
**When user changes color selection:**

1. Load available options for Paint/Gage/Profile/Finish for new color
2. **For each characteristic (Paint, Gage, Profile, Finish):**
   - **IF** currently selected value exists for new color:
     - **Keep selection**
   - **ELSE** (value not available):
     - **Reset to third state**
     - Show as unselected

### Rule 3: Characteristic Change
**When user selects Paint/Gage/Profile/Finish:**

- Update selection state
- Check if all characteristics now selected
- If complete → calculate and display result
- If incomplete → show "select remaining parameters"

### Rule 4: Clear Button
**When user clicks Clear:**

- Reset Plant to third state
- Reset Color to third state
- Reset all characteristics to third state
- Clear result display
- Return to initial state

---

## Dynamic Option Display

### Enabling/Disabling Logic

**Color List:**
- Show all colors available for selected plant
- If no plant selected: show all colors from both plants (or require plant first)
- Gray out unavailable, enable available

**Characteristic Buttons (Paint/Gage/Profile/Finish):**
- **Enabled:** Option exists in dataset for current Plant + Color
- **Disabled:** Option does NOT exist in dataset
- **Visual:** Disabled buttons grayed out with cursor not-allowed

### "No Options Available" State

**When characteristic has zero valid options:**

Display message in that section:
- "No paint options available for this color"
- "No gages available for this color"
- etc.

Consider: Should this prevent selection entirely, or allow user to proceed and see why at result?

**Recommendation:** Show disabled state but allow partial selection for user awareness.

---

## Result Calculation

### Profile + Finish to CSV Column Mapping

**Mapping table for constructing column keys:**

| Profile | Finish | CSV Column Key |
|---------|--------|----------------|
| Grooved | Embossed | GroovedEmbossed |
| Grooved | Smooth | GroovedSmooth |
| Silkline | Embossed | SilklineEmbossed |
| Silkline | Smooth | SilklineSmooth |
| Microribbed | Embossed | MicroribbedEmbossed |
| Microribbed | Smooth | MicroribbedSmooth |
| None | Embossed | Embossed |
| None | Smooth | Smooth |

### Calculation Logic

**When all parameters selected:**

1. **Construct column key** by concatenating Profile + Finish values (see mapping table above)

2. **Find matching row** in cached dataset using selected color, paint, and gage

3. **Extract max length value** from row's maxLengths object using constructed column key

4. **Display result** (see Result Display section below)

### Result Display

**Valid numeric result:**
- Display value: "52.25 ft"
- Green or blue highlight
- Show selected parameters

**NA result:**
- Display: "Not Available" or "NA"
- Orange/warning color
- Show message: "This combination is not available"
- Still show selected parameters for reference

**Error (should not happen with proper filtering):**
- Display error message
- Ask user to refresh or contact support

---

## Responsive Design

### Breakpoints

**Desktop (>1024px):**
- Two-column layout (parameters left, result right)
- Full button groups horizontal

**Tablet (768-1024px):**
- Two-column layout maintained
- Slightly smaller spacing
- Button groups may wrap

**Mobile (<768px):**
- Single column layout
- Parameters stacked above result
- Button groups vertical or wrap
- Color list shorter with scroll

---

## Accessibility

### Keyboard Navigation
- Tab through all controls
- Enter/Space to select
- Arrow keys in button groups
- Clear focus indicators

### Screen Readers
- Proper ARIA labels
- Announce state changes
- Describe disabled states
- Read result clearly

### Color Contrast
- WCAG AA compliance minimum
- Text readable on all backgrounds
- Clear visual hierarchy

---

## Animation & Transitions

**State Changes:**
- Smooth transitions (150-200ms)
- Button hover effects
- Selection highlights
- Loading states if needed

**Result Display:**
- Fade in when result calculated
- Number animation optional (count-up effect)
- Smooth transition between results when parameters change

---

## Error States

### API Errors
- Show error message in result panel
- Suggest actions (refresh, check connection)
- Don't break UI state

### Validation Errors
- Show inline with invalid control
- Clear, actionable messages
- Prevent invalid submissions

---

## Future Enhancements (Post-MVP)

- Save/bookmark favorite combinations
- Export results to PDF
- Comparison mode (multiple configurations side-by-side)
- Recent searches history
- Print-friendly view
