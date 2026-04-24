# Configurateur Database - Quotation System

## Overview
This database serves as the foundation for a dynamic quotation/configuration system. The system is built on a flexible configuration framework that defines business rules, validation logic, and data relationships for generating quotes.

**Database**: `Configurateur`

## System Architecture

The database is organized into four main categories:

### 1. Reference Tables (`ref_*`)
Define the properties, pricing, and characteristics of quotable elements.
- **Purpose**: Master data for items, categories, types, parameters
- **Examples**: Items (parts/materials), price change rules, transport configurations
- **Key Tables**: `ref_item`, `ref_reference`, `ref_categories`, `ref_param`

### 2. System Tables (`sys_*`)
Define the dynamic configuration subsystem that governs validation rules, field relationships, and business logic.
- **Purpose**: Rule engine for data validation and integrity
- **Examples**: Conditions, limitators, field references, pricing rules
- **Key Tables**: `sys_condition`, `sys_limitator`, `sys_field_ref`, `sys_pricing`

### 3. Transaction Tables (`trx_*`)
Store actual quote/project data and user transactions.
- **Purpose**: Live quote data (projects, doors, rooms, panels, etc.)
- **Examples**: Projects, doors, rooms, chambers, pricing calculations
- **Key Tables**: `trx_project`, `trx_door`, `trx_room`, `trx_porte`

### 4. Universal/Common Tables (`uni_*`)
Define universal properties shared across the system.
- **Purpose**: Common data like materials, colors, profiles
- **Examples**: Materials, textures, colors, profiles
- **Key Tables**: `uni_materiel`, `uni_couleurs`, `uni_profile`, `uni_matiere`

## Key Concepts

### Dynamic Configuration System
The system uses a sophisticated rule engine:
- **Limitators** (`sys_limitator`): Define rule groups with conditions and results
- **Conditions** (`sys_condition`): Specify when rules apply (field values, logic)
- **Field References** (`sys_field_ref`): Define relationships between fields and lookup tables
- **Results**: Determine what happens when conditions are met

### Integration Points
- **Epicor**: ERP integration (`epi_QuoteNum`, `epi_OrderNum` fields)
- **Inventor**: CAD integration (multiple Inventor-related views and tables)

## Views

Views provide flattened, denormalized access to complex relationships:
- **Flat Condition Views**: `vw_flat_cond_*` - Simplify condition logic
- **Item Views**: `vw_flat_items`, `vw_ref_item_coutant` - Item listings with pricing
- **Material Mapping**: `vw_sys_map_inventor_material` - Integration with Inventor
- **Field Impact**: `vw_eli5_sys_field_change_impact` - Understand field dependencies

## Documentation Status

This repository contains SQL DDL scripts for all tables and views. Each database object requires detailed documentation including:
- Business purpose and usage
- Field descriptions
- Relationships and dependencies
- Business rules and constraints
- Integration points

See `DATABASE_DOCUMENTATION_TEMPLATE.md` for the documentation framework to be completed by developers.

## File Structure
```
Tables/         - DDL scripts for all database tables
Views/          - DDL scripts for all database views
```

## Next Steps
1. Complete developer documentation using the template
2. Document key business processes and workflows
3. Create entity-relationship diagrams
4. Document integration points and APIs

---
*Last Updated: April 20, 2026*
