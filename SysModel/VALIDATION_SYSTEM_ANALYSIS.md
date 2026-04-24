# Validation System Architecture Analysis

**Date**: April 20, 2026  
**Source Views Analyzed**: 
- `vw_eli5_sys_field_change_impact`
- `vw_flat_cond_list`
- `vw_flat_cond_results`

---

## Executive Summary

The Configurateur database implements a sophisticated **dynamic validation and business rules engine** that controls field behavior, data integrity, and cross-field dependencies. The system is built around a core pattern:

**FIELD → LIMITATOR → CONDITIONS → RESULTS**

This architecture allows business rules to be defined declaratively in the database rather than hardcoded in application logic, enabling runtime configuration of validation behavior.

---

## System Architecture Overview

### The Rule Engine Flow

```
┌─────────────────┐
│  sys_field_ref  │ ← Defines which fields have validation rules
└────────┬────────┘
         │
         ▼
┌──────────────────────┐
│ sys_field_limitator  │ ← Links fields to their limitators (rules)
└──────────┬───────────┘
           │
           ▼
┌─────────────────┐
│ sys_limitator   │ ← Named rule groups with result types
└────────┬────────┘
         │
         ├──────────────┐
         ▼              ▼
┌──────────────┐  ┌────────────────┐
│sys_condition │  │ sys_cond_result│ ← What happens when conditions are met
└──────┬───────┘  └────────────────┘
       │
       ▼
┌──────────────────────┐
│sys_cond_value_list   │ ← Values to check against (for list-based conditions)
└──────────────────────┘
```

---

## Core Tables Deep Dive

### 1. **sys_field_ref** - Field Configuration Registry

**Purpose**: Central registry defining field-level metadata and lookup relationships

**Key Attributes**:
- `ForTable` / `ForField`: The field being configured (e.g., "trx_porte.couleur")
- `LookupTable` / `LookupField`: Where valid values come from (typically `ref_reference`)
- `DefFromTable` / `DefFromField`: Default value source (can inherit from parent records)
- `Description`: sys_localisation_uid for multilingual field labels
- `DefCondition?`: Default value calculation logic
- `Help`: sys_localisation_uid for help text

**Deduced Behavior**: 
- This table essentially makes the database schema "self-aware" - it knows what each field represents and how it should behave
- Acts as metadata layer enabling dynamic form generation
- Supports localization through sys_localisation references

---

### 2. **sys_limitator** - Business Rule Containers

**Purpose**: Named groups of conditions with typed results

**Key Attributes**:
- `Nom`: Human-readable rule name (e.g., "Minimum door width for reinforcement")
- `ConditionText`: Stored description/formula (possibly obsolete, replaced by sys_condition records)
- `ConditionResult`: Text result or formula
- `sys_limitator_result_type_uid`: Determines how results are interpreted

**Result Type Behavior** (from `sys_limitator_result_type`):
- `use_result_list = 1`: Results come from `sys_cond_result` table (multiple possible values)
- `use_result_list = 0`: Result stored directly in `ConditionResult` field
- **Special Case** uid=5: Uses `ConditionResult` text directly (seen in vw_flat_cond_results CASE statement)

**Deduced Pattern**: Limitators are reusable rule templates that can be applied to multiple fields

---

### 3. **sys_condition** - Individual Condition Logic

**Purpose**: Defines the "IF" part of business rules - when does a limitator apply?

**Key Attributes**:
- `sys_limitator_UID`: Parent rule this condition belongs to
- `ConditionTable` / `ConditionField`: What field to evaluate (e.g., "trx_porte.hauteur")
- `ConditionType`: Type of comparison (FK to sys_condition_type)
- `ConditionValue`: Value to compare against OR null if using value list
- `AndOr`: Logical operator ('AND' / 'OR') for chaining multiple conditions

**Architecture Insight**: 
- Multiple conditions can belong to one limitator
- Conditions are chained using AndOr logic
- This creates compound boolean expressions: `(field1 = value1) AND (field2 > value2) OR (field3 IN list)`

---

### 4. **sys_condition_type** - Comparison Operators

**Purpose**: Defines types of comparisons available

**Key Attributes**:
- `descr_fr` / `desc_en`: Human-readable description (e.g., "égal à", "equals")
- `prog`: Programmatic operator code (e.g., "=", ">", "IN", "CONTAINS")
- `use_cond_value_list`: Boolean - if TRUE, uses sys_cond_value_list for multi-value checks

**Deduced Types** (based on `use_cond_value_list` flag):
- **Simple comparisons**: `=`, `>`, `<`, `>=`, `<=`, `!=` (use ConditionValue)
- **List-based checks**: `IN`, `NOT IN` (use sys_cond_value_list)

---

### 5. **sys_cond_value_list** - Multi-Value Condition Lists

**Purpose**: Stores multiple values for list-based conditions (IN operator scenarios)

**Key Attributes**:
- `sys_condition_UID`: Parent condition
- `CondValue`: Reference to ref_reference.UID (integer)

**Critical Chain** (revealed by vw_flat_cond_list):
```
sys_cond_value_list.CondValue 
  → ref_reference.UID 
  → ref_item.UID 
  → sys_localisation.uid 
  → sys_localisation.fr (display text)
```

**Deduced Behavior**:
- Conditions can check against lists of pre-defined reference values
- Example: "Color IN (Red, Blue, Green)" where Red/Blue/Green are ref_reference entries
- The view flattens this into comma-separated lists for display

---

### 6. **sys_cond_result** - Rule Outcome Values

**Purpose**: Defines possible result values when limitator conditions are satisfied

**Key Attributes**:
- `sys_limitator_UID`: Parent rule
- `ResultValue`: Can be text, number, or ref_reference.UID

**Critical Chain** (revealed by vw_flat_cond_results):
```
sys_cond_result.ResultValue 
  → ref_reference.UID 
  → ref_item.UID 
  → sys_localisation.uid 
  → sys_localisation.fr (display text)
```

**Deduced Pattern**:
- Results can be:
  - **Direct values**: Stored in limitator.ConditionResult (when result_type.use_result_list = 0)
  - **Reference lists**: Multiple ref_reference UIDs in sys_cond_result (when use_result_list = 1)
  - **Literal text**: Direct text in limitator.ConditionResult (when result_type uid = 5)

---

### 7. **sys_field_limitator** - Field-to-Rule Mapping

**Purpose**: Associates fields with their applicable limitators (many-to-many)

**Key Attributes**:
- `sys_field_ref_UID`: The field being constrained
- `sys_limitator_UID`: The rule applied to this field

**Deduced Behavior**:
- One field can have multiple limitators
- One limitator can apply to multiple fields (reusability)
- This is the **binding layer** that activates rules for specific fields

---

## Reference Tables Integration

### ref_reference - The Value Lookup Hub

**Purpose**: Central lookup table for all selectable/configurable values in the system

**Structure**:
- `UID`: Primary key
- `ref_categories_UID`: Categorizes the reference (what type of value is this?)
- `ref_item_UID`: Links to actual item/part with pricing and localization
- `modulr_map`: Application-specific mapping
- `inv_key` / `inv_value`: Inventor CAD integration fields
- Pricing fields: `prix_vendant`, `prix_coutant`, `prix_supp`, `markup`

**Usage Pattern** (revealed by views):
1. Conditions check against ref_reference UIDs
2. Results return ref_reference UIDs
3. Display text comes from: `ref_reference → ref_item → sys_localisation`

**Deduced Role**: 
- Universal value domain for all constrained fields
- Supports pricing at the reference level (can override ref_item prices)
- Categories organize references by context (door types, colors, materials, etc.)

---

### ref_categories - Value Organization

**Purpose**: Organizes ref_reference entries into logical groups

**Structure**:
- `UID`: Primary key
- `code`: Unique category code (e.g., "DOOR_COLORS", "WALL_TYPES")
- `ref_type_UID`: Higher-level type classification

**Deduced Role**:
- Creates namespaces for reference values
- Example: "Blue" as a paint color vs "Blue" as a room designation
- Enables context-specific value lists

---

### ref_item - The Item Master

**Purpose**: Core item/part catalog with pricing and localization

**Structure**:
- `UID`: Primary key
- `partnum`: Part number (likely ERP/Epicor integration)
- `sys_localisation_uid`: Multilingual descriptions
- Pricing: `prix_vendant`, `prix_coutant`, `prix_supp`, `markup`
- `functional_value`: Programmatic identifier
- `represent_empty`: Boolean - can represent "no selection"
- `image_on_plan`: Visual representation

**Deduced Role**:
- Base entity for all items (parts, materials, options)
- Localization target (descriptions come from sys_localisation)
- Default pricing source (can be overridden at ref_reference level)

---

### sys_localisation - Multilingual Support

**Purpose**: Stores text in multiple languages (implied: fr, en, possibly others)

**Structure** (inferred from usage):
- `UID`: Primary key
- `fr`: French text
- `en`: English text (inferred from sys_condition_type which has desc_en)

**Deduced Role**:
- Centralized translation table
- Used for: field labels, help text, item descriptions, condition descriptions
- Enables language switching without code changes

---

## View Analysis

### vw_flat_cond_list - Condition Value Flattening

**Purpose**: Converts multi-row condition value lists into comma-separated strings

**Output Columns**:
- `sys_condition_UID`: Parent condition
- `flat_list`: Comma-separated display names (e.g., "Red,Blue,Green")
- `flat_val`: Comma-separated UIDs wrapped in quotes (e.g., "'12','15','18'")

**Technique**: Uses FOR XML PATH('') to concatenate rows

**Usage**: Displays what values a condition checks against in human-readable form

**Example Output**:
```
sys_condition_UID | flat_list           | flat_val
--------------------------------------------------
42                | Rouge,Bleu,Vert     | '101','102','103'
```

---

### vw_flat_cond_results - Result Value Flattening

**Purpose**: Converts multi-row result lists into comma-separated strings

**Output Columns**:
- `sys_limitator_uid`: Parent limitator
- `flat_list`: Comma-separated display names
- `flat_val`: Comma-separated UIDs OR direct text from ConditionResult

**Special Logic**:
```sql
WHEN lim.sys_limitator_result_type_uid='5' 
THEN lim.ConditionResult  -- Use text directly
ELSE LEFT(flat_val, LEN(flat_val) - 2)  -- Use concatenated ref values
```

**Deduced Behavior**: 
- Result type 5 = literal text results
- Other types = lookup values from ref_reference

---

### vw_eli5_sys_field_change_impact - **THE MASTER VALIDATION CATALOG VIEW**

**Purpose**: This is the **central denormalized view** providing complete access to the entire validation rule system. Despite the "ELI5" name suggesting it's just for explanations, it's actually a comprehensive rule catalog that joins all validation system components.

**Critical Role**: This view serves as the **primary query interface** for the validation system - it's not just documentation, it's the operational view applications would use to:
1. Query all rules affecting a specific field
2. Find what fields are checked by a rule's conditions  
3. Get complete rule definitions in a single query
4. Perform impact analysis
5. Execute runtime rule evaluation

**Output Columns** (40+ columns total):

**Human-Readable Layer:**
- `explication`: French sentence explaining the entire rule chain (field → condition → result)

**Condition Details** (from sys_condition):
- `UID`, `sys_limitator_UID`, `AndOr`, `ConditionTable`, `ConditionField`, `ConditionType`, `ConditionValue`

**Condition Type Metadata** (from sys_condition_type):
- `cond_type_uid`, `descr_fr`, `desc_en`, `prog`, `use_cond_value_list`

**Condition Values** (from vw_flat_cond_list):
- `sys_condition_UID`, `flat_list` (display names), `flat_val` (UIDs)

**Limitator Definition** (from sys_limitator):
- `lim_uid`, `Nom`, `ConditionText`, `ConditionResult`, `sys_limitator_result_type_uid`

**Field-Rule Binding** (from sys_field_limitator):
- `sfl_uid`, `sys_field_ref_UID`, `sys_limitator_UID`

**Field Metadata** (from sys_field_ref):
- `fie_uid`, `ForTable`, `ForField`, `LookupTable`, `LookupField`, `DefFromTable`, `DefFromField`, `Description`, `DefCondition?`, `NoDesignDoc`

**Result Type Info** (from sys_limitator_result_type):
- `rty_uid`, `text`, `code`, `use_result_list`

**Result Values** (from vw_flat_cond_results):
- `result_flat_list` (display names), `result_flat_val` (UIDs or literal text)

**Joins Involved** (8 tables/views - ALL LEFT OUTER JOINs):
1. `sys_limitator` - The rule (BASE TABLE)
2. `sys_condition` - The conditions
3. `sys_condition_type` - Condition operators
4. `vw_flat_cond_list` - Condition values (flattened)
5. `sys_field_limitator` - Field-to-rule binding
6. `sys_field_ref` - Field metadata
7. `sys_limitator_result_type` - Result type info
8. `vw_flat_cond_results` - Result values (flattened)

**Query Patterns Enabled**:

```sql
-- Get all rules affecting a specific field
SELECT * FROM vw_eli5_sys_field_change_impact 
WHERE fie.ForTable = 'trx_porte' AND fie.ForField = 'couleur'

-- Find what fields a rule checks in its conditions
SELECT DISTINCT con.ConditionTable, con.ConditionField 
FROM vw_eli5_sys_field_change_impact 
WHERE lim_uid = 42

-- Get complete rule catalog for documentation
SELECT lim.Nom, explication, rty.text, fie.ForTable, fie.ForField
FROM vw_eli5_sys_field_change_impact
ORDER BY fie.ForTable, fie.ForField, lim.Nom

-- Impact analysis: what rules fire when a field changes
SELECT * FROM vw_eli5_sys_field_change_impact
WHERE con.ConditionTable = 'trx_porte' AND con.ConditionField = 'hauteur'
```

**Example Row** (reconstructed):
```
explication: "Le champ [couleur] de la table [trx_porte] est impacté par 
              un changement au champ: [type_porte] de [trx_porte]. 
              Impact possible: Restreindre les valeurs (Rouge,Bleu) 
              Par la condition: est égal à (Porte Standard) du 
              limitateur: Couleurs disponibles pour portes standard"
lim_uid: 42
lim.Nom: "Couleurs disponibles pour portes standard"
fie.ForTable: "trx_porte"
fie.ForField: "couleur"
con.ConditionTable: "trx_porte"
con.ConditionField: "type_porte"
cty.prog: "="
flat_val: "'101'"  (Standard door type UID)
result_flat_val: "'201','202','203'"  (Red, Blue, White UIDs)
rty.code: "RESTRICT_VALUES"
... (30+ more columns)
```

**Usage**: 
- **Runtime Rule Execution**: Application queries this view to get rules for a field
- **Impact Analysis**: "If I change field X, what rules check it and what fields do those rules affect?"
- **Documentation**: Auto-generate complete business rule documentation
- **Debugging**: Understand why a field behaves a certain way
- **Rule Management UI**: Build admin interfaces to view/edit rules
- **Onboarding**: Help new developers understand the rule system
- **Testing**: Validate rule definitions and find conflicts
- **Auditing**: Track what rules govern critical fields

---

## System Behavior Patterns

### Pattern 1: Value Restriction

**Scenario**: Limit available options based on other field values

**Implementation**:
1. sys_field_ref defines field with lookup to ref_reference
2. sys_limitator defines rule with result_type "restrict values"
3. sys_condition checks parent field value
4. sys_cond_result specifies allowed ref_reference UIDs
5. Application reads limitator to filter dropdown options

**Example**: 
- Field: Door Color
- Condition: IF door_type = 'Standard'
- Result: Color IN (White, Grey, Black)

---

### Pattern 2: Conditional Defaults

**Scenario**: Set field default based on context

**Implementation**:
1. sys_field_ref.DefFromTable/DefFromField defines potential default source
2. sys_field_ref.DefCondition? contains formula
3. sys_limitator defines default calculation rule
4. sys_condition determines when default applies
5. sys_cond_result provides the default value

**Example**:
- Field: Wall Thickness
- Condition: IF room_type = 'Freezer'
- Result: thickness = 150mm (vs standard 100mm)

---

### Pattern 3: Cross-Field Validation

**Scenario**: Validate that field combinations are valid

**Implementation**:
1. sys_limitator defines validation rule with result_type "error" or "warning"
2. Multiple sys_condition records check different fields
3. AndOr logic chains conditions
4. ConditionResult contains error message

**Example**:
- Condition 1: IF height > 3000 AND
- Condition 2: reinforcement = 'None'
- Result: ERROR "Doors over 3m require reinforcement"

---

### Pattern 4: Dynamic Calculations

**Scenario**: Calculate field values from other fields

**Implementation**:
1. sys_limitator with result_type for "calculated value"
2. sys_condition defines when calculation applies
3. ConditionResult contains formula or computed value

**Example**:
- Condition: IF door_width > 1200
- Result: hinge_count = 3 (vs standard 2)

---

## Architecture Insights

### 1. Declarative Programming Model
The system implements a **rule-based declarative approach** rather than procedural code:
- Rules stored as data, not code
- Changes to business logic = database updates, not deployments
- Non-developers can modify rules (with proper tooling)

### 2. Separation of Concerns
Clear layering:
- **Data Layer**: ref_* tables (what items exist)
- **Metadata Layer**: sys_field_ref (what fields mean)
- **Rules Layer**: sys_limitator + sys_condition (how fields behave)
- **Presentation Layer**: sys_localisation (how to display)

### 3. Reusability
- Limitators can apply to multiple fields
- Conditions can reference any table/field
- Results can reference any ref_reference value
- One rule definition → many uses

### 4. Extensibility
Adding new validation types requires:
- New sys_condition_type record (operator)
- New sys_limitator_result_type record (result type)
- Application code to interpret new types
- NO schema changes needed

### 5. Auditability
The system is inherently auditable:
- All rules visible in database
- Changes tracked (with proper audit triggers)
- Human-readable via vw_eli5_sys_field_change_impact
- Can generate rule documentation automatically

---

## Application Integration Guide

### How to Use vw_eli5_sys_field_change_impact at Runtime

This view is the **single point of access** for the validation system. Here's how applications should use it:

#### 1. Form Load - Get All Rules for a Field
```sql
-- Get all limitators that affect the "couleur" field on "trx_porte" table
SELECT lim_uid, lim.Nom, rty.code, rty.text,
       con.ConditionTable, con.ConditionField, con.ConditionValue,
       cty.prog, flat_list, flat_val,
       result_flat_list, result_flat_val
FROM vw_eli5_sys_field_change_impact
WHERE fie.ForTable = 'trx_porte' 
  AND fie.ForField = 'couleur'
```

Application logic:
- Cache these rules for the field
- When user changes a condition field, re-evaluate the limitator
- Apply the result (restrict dropdown, show error, set default, etc.)

#### 2. Field Change - Find What to Re-evaluate
```sql
-- User changed "type_porte" field - what rules need to be checked?
SELECT DISTINCT fie.ForTable, fie.ForField, lim_uid, lim.Nom
FROM vw_eli5_sys_field_change_impact
WHERE con.ConditionTable = 'trx_porte'
  AND con.ConditionField = 'type_porte'
```

Application logic:
- Identify all fields that might be affected
- Re-evaluate limitators for those fields
- Update UI (enable/disable, filter values, show warnings)

#### 3. Impact Analysis - Dependency Chain
```sql
-- Show user what will be affected if they change a field
SELECT fie.ForTable + '.' + fie.ForField as affected_field,
       con.ConditionTable + '.' + con.ConditionField as trigger_field,
       lim.Nom as rule_name,
       rty.text as impact_type,
       explication as explanation
FROM vw_eli5_sys_field_change_impact
WHERE con.ConditionTable = 'trx_porte'
  AND con.ConditionField = 'hauteur'
ORDER BY fie.ForTable, fie.ForField
```

#### 4. Rule Catalog Export
```sql
-- Generate complete rule documentation
SELECT 
    fie.ForTable + '.' + fie.ForField as target_field,
    lim.Nom as rule_name,
    con.ConditionTable + '.' + con.ConditionField as checks_field,
    cty.descr_fr as condition_type,
    cli.flat_list as condition_values,
    rty.text as result_type,
    fcr.result_flat_list as result_values,
    explication as full_description
FROM vw_eli5_sys_field_change_impact
ORDER BY fie.ForTable, fie.ForField, lim.Nom
```

#### 5. Rule Debugging
```sql
-- Why isn't my field showing expected values?
SELECT *
FROM vw_eli5_sys_field_change_impact
WHERE fie.ForTable = 'trx_porte'
  AND fie.ForField = 'couleur'
  AND lim.Nom LIKE '%couleur%'
```

### Performance Considerations

**The vw_eli5 view uses LEFT OUTER JOINs**, which means:
- Always use WHERE clauses on indexed columns (fie.ForTable, fie.ForField, con.ConditionTable, con.ConditionField)
- Results can have NULL values for tables that don't have data
- One limitator can produce multiple rows (one per condition, one per field it affects)

**Recommended Indexes**:
```sql
CREATE INDEX idx_field_ref_table_field ON sys_field_ref(ForTable, ForField)
CREATE INDEX idx_condition_table_field ON sys_condition(ConditionTable, ConditionField)
CREATE INDEX idx_field_limitator_field ON sys_field_limitator(sys_field_ref_UID)
```

**Caching Strategy**:
- Cache rules by table/field at application startup
- Invalidate cache when sys_* tables are modified
- Use application-level rule evaluation for performance

---

## Integration Points

### 1. ERP Integration (Epicor)
- `ref_item.partnum`: Part numbers from Epicor
- Pricing fields synchronized with ERP
- Order/quote numbers stored in trx_project

### 2. CAD Integration (Inventor)
- `ref_reference.inv_key` / `inv_value`: Material/parameter mapping
- Multiple `uni_*_inventor` tables
- BOM generation (trx_inv_bom tables)

### 3. Application Layer
The rule engine expects the application to:
1. Query sys_field_ref for field metadata
2. Evaluate sys_limitator conditions when fields change
3. Apply results (restrict values, show errors, set defaults)
4. Use sys_localisation for UI text
5. Respect ref_reference as value domain

---

## Potential Use Cases

Based on the architecture, this system supports:

1. **Dynamic Forms**: Forms that adapt based on field values
2. **Guided Selling**: Hide/show options based on selections
3. **Product Configuration**: Complex product rules (CPQ - Configure Price Quote)
4. **Data Validation**: Multi-field cross-validation
5. **Business Rules Management**: Non-technical rule editing
6. **Localization**: Multi-language support
7. **Pricing Logic**: Context-sensitive pricing
8. **Workflow Enforcement**: Required field logic
9. **Defaults Management**: Smart default values
10. **Documentation**: Auto-generated rule catalogs

---

## Advanced Patterns Inferred

### Chained Dependencies
```
Field A change → triggers limitator 1 → changes field B
Field B change → triggers limitator 2 → changes field C
```
The vw_eli5 view helps trace these chains.

### Circular Reference Prevention
The system needs application-level logic to prevent:
- Field A depends on Field B
- Field B depends on Field A

### Performance Optimization
For complex forms with many fields:
- Views pre-flatten condition/result lists
- Application should cache sys_field_ref metadata
- Limitator evaluation should be lazy (only when needed)

---

## Conclusions

This is a **sophisticated metadata-driven business rules engine** comparable to:
- Oracle Policy Automation
- Microsoft Dynamics validation framework
- SAP Variant Configuration
- Commercial CPQ (Configure-Price-Quote) systems

**Critical Architectural Finding**: 

The `vw_eli5_sys_field_change_impact` view is **THE MASTER VIEW** of the entire validation system. Despite its humble "Explain Like I'm 5" name, this view is:
- The **complete denormalized catalog** of all validation rules
- The **primary operational interface** for rule queries
- A **40+ column comprehensive view** exposing all rule system components
- The **single query point** for runtime rule evaluation

Applications should query this view to:
1. Get all rules for a field during form loading
2. Evaluate what rules to check when a field changes
3. Perform impact analysis
4. Generate documentation
5. Build rule management UIs

The French `explication` column is just one bonus feature among many - the real power is having the complete rule system accessible in one denormalized view.

**Strengths**:
- Extremely flexible
- Rules as data (no code deployment for changes)
- Multilingual support built-in
- Reusable components
- Self-documenting (via vw_eli5)
- **Single comprehensive query interface** (vw_eli5)
- Complete rule catalog accessible via SQL

**Complexities**:
- Steep learning curve for developers
- Requires discipline in rule definition
- Performance monitoring needed for complex rule chains
- Testing all rule combinations is challenging
- The LEFT OUTER JOINs in vw_eli5 mean proper WHERE clauses are critical for performance

**Best Practices** (inferred):
1. Document limitators thoroughly in Nom field
2. Use meaningful category codes in ref_categories
3. Keep condition chains shallow (avoid deep dependencies)
4. Leverage vw_eli5 for **ALL** rule queries (it's not just for documentation!)
5. Create integration tests for critical limitator combinations
6. Index ConditionTable/ConditionField for vw_eli5 query performance
7. Cache vw_eli5 results in application layer when possible

---

**Document Version**: 1.0  
**Author**: Analysis of database schema and views  
**Last Updated**: April 20, 2026
