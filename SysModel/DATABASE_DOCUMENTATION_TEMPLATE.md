# Configurateur Database - Documentation Template

**Instructions for Developers**: Please complete the sections marked with `[ ]` for the database objects you are familiar with. Focus on purpose, key fields, and critical relationships. Keep descriptions concise and practical.

## Documentation Guidelines

**Purpose**: Explain what this object does and why it exists. What problem (business, technical, or architectural) does it solve?

**Key Fields**: Describe the important columns/fields and what they store.
- Focus on business-relevant fields (not technical IDs unless important)
- Explain what values are stored, valid ranges, or special meanings
- Example: `prix_vendant: Selling price in CAD, markup: Percentage markup over cost`

**Relationships**: Describe how this object connects to other tables/objects.
- Foreign key relationships: "Links to sys_localisation for translations"
- Parent-child relationships: "Parent table for trx_chambre_renfort"
- Dependent views: "Used by vw_flat_items to build item catalog"
- Example: `FK to sys_localisation (sys_localisation_uid), Referenced by trx_porte`

**Business Rules/Notes**: Any constraints, calculations, special behaviors, or important facts.
- Validation rules, required workflows, calculation logic
- Integration points (Epicor, Inventor)
- Common issues or gotchas

---

## REFERENCE TABLES (ref_*)

### ref_categories
**Type**: Table  
**Discovered Purpose**: Organizes ref_reference entries into logical namespaces/groups. Creates context for values (e.g., \"Blue\" as paint color vs \"Blue\" as room designation). Enables category-specific value lists for fields.

**Key Fields**: code (unique category identifier like \"DOOR_COLORS\"), ref_type_UID (higher-level classification)
**Relationships**: FK to ref_type, Referenced by ref_reference.ref_categories_UID

- [ ] **Purpose**: (Confirm/refine above)
- [ ] **Key Fields**: (Add category examples)
- [ ] **Relationships**: (Add details)
- [ ] **Business Rules/Notes**:

---

### ref_global_price_change
**Type**: Table  
**Inferred Purpose**: System-wide price adjustment rules

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### ref_item
**Type**: Table  
**Discovered Purpose**: Core item/part master catalog. Stores base items with default pricing, multilingual descriptions (via sys_localisation), and functional identifiers. Referenced by ref_reference for creating selectable options.

**Current Fields**: UID, partnum, sys_localisation_uid, prix_vendant, prix_supp, prix_coutant, markup, comment, udm, price_per, represent_empty, functional_value, image_on_plan, ref_partnum, comment_finance, cou_mod, cou_fgf

**Key Fields**: partnum (Epicor part number), sys_localisation_uid (multilingual name/description), functional_value (programmatic identifier), represent_empty (can represent "no selection")
**Relationships**: FK to sys_localisation, Referenced by ref_reference.ref_item_UID, Used by vw_flat_cond_list and vw_flat_cond_results to get display text

- [ ] **Purpose**: (Confirm/refine above)
- [ ] **Key Fields**:
  - UID: Unique identifier for ref_item
  - partnum: Part number into Epicor's Part table (implied Epicor company is SNI)
  - prix_vendant: (Default selling price)
  - prix_coutant: (Default cost price)
  - markup: (Default markup percentage)
  - functional_value: (Programmatic identifier for code)
  - sys_localisation_uid: (Multilingual descriptions)
- [ ] **Relationships**:
  - sys_localisation_uid is foreign key on table sys_localisation (name/description)
  - (Add other relationships)
- [ ] **Business Rules/Notes**:
  - ref_partnum is not used (always null)
  - Pricing can be overridden at ref_reference level

---

### ref_pan_continu
**Type**: Table  
**Inferred Purpose**: Continuous panel reference data

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### ref_param
**Type**: Table  
**Inferred Purpose**: System parameters or configuration settings

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### ref_reference
**Type**: Table  
**Discovered Purpose**: **CENTRAL VALUE LOOKUP HUB** - Universal domain for all selectable/configurable values in the system. Both validation conditions (sys_cond_value_list) and results (sys_cond_result) reference this table. Organized by categories with optional pricing overrides.

**Key Fields**: ref_categories_UID (categorizes the value), ref_item_UID (links to item with description/pricing), modulr_map (application mapping), inv_key/inv_value (Inventor CAD integration), pricing fields (can override ref_item)
**Relationships**: FK to ref_categories, FK to ref_item, Referenced by sys_cond_value_list.CondValue, Referenced by sys_cond_result.ResultValue, Used throughout trx_ tables for property values, Central to vw_flat_cond_list and vw_flat_cond_results

- [ ] **Purpose**: (Confirm/refine above)
- [ ] **Key Fields**: (Add field details)
- [ ] **Relationships**: (Add details)
- [ ] **Business Rules/Notes**:
  - In trx_ tables any value for a property that is managed by dynamic definition, the value in the trx_ table field is UID of a definition in ref_reference.
  - (Add more notes)

---

### ref_transport_skid_size
**Type**: Table  
**Inferred Purpose**: Transport skid size specifications

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### ref_type
**Type**: Table  
**Inferred Purpose**: Type classifications for reference items

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

## SYSTEM TABLES (sys_*)

### sys_cond_result
**Type**: Table  
**Discovered Purpose**: Stores the "THEN" part of validation rules - what happens when limitator conditions are met. Can store multiple possible result values (when use_result_list=1).

**Key Fields**: ResultValue (ref_reference UID or literal value), sys_limitator_UID (parent rule)
**Relationships**: FK to sys_limitator, ResultValue references ref_reference UIDs, Used by vw_flat_cond_results

- [ ] **Purpose**: (Confirm/refine above)
- [ ] **Key Fields**: (Add details)
- [ ] **Relationships**: (Add details)
- [ ] **Business Rules/Notes**:

---

### sys_cond_value_list
**Type**: Table  
**Discovered Purpose**: Stores multi-value lists for IN/NOT IN conditions. Enables checking if a field value is in a list of valid ref_reference values.

**Key Fields**: sys_condition_UID (parent condition), CondValue (ref_reference UID)
**Relationships**: FK to sys_condition, CondValue references ref_reference.UID, Used by vw_flat_cond_list

- [ ] **Purpose**: (Confirm/refine above)
- [ ] **Key Fields**: (Add details)
- [ ] **Relationships**: (Add details)
- [ ] **Business Rules/Notes**:

---

### sys_condition
**Type**: Table  
**Inferred Purpose**: Individual condition definitions for validation rules

**Discovered Purpose**: Defines the "IF" logic of validation rules - what field values to check. Multiple conditions can chain with AND/OR to form complex boolean expressions.

**Key Fields**: ConditionTable/ConditionField (what to check), ConditionType (operator like =, >, IN), ConditionValue (value to compare OR null if using value list), AndOr (chain multiple conditions)
**Relationships**: FK to sys_limitator (parent rule), FK to sys_condition_type (operator), Used by sys_cond_value_list, Central to vw_eli5_sys_field_change_impact

- [ ] **Purpose**: (Confirm/refine above)
- [ ] **Key Fields**:
  - ConditionTable: (Table name to check)
  - ConditionField: (Field name to check)
  - ConditionType: (FK to operator definition)
  - ConditionValue: (Value or null if list-based)
  - AndOr: (Logical chaining operator)
- [ ] **Relationships**: (Add details)
- [ ] **Business Rules/Notes**:

---

### sys_condition_type
**Type**: Table  
**Discovered Purpose**: Defines comparison operators available in the validation system (=, >, <, IN, etc.). Determines if condition uses single value or value list.

**Key Fields**: descr_fr/desc_en (display text), prog (programmatic code like "="), use_cond_value_list (TRUE for IN operators)
**Relationships**: Referenced by sys_condition.ConditionType, Used by vw_eli5_sys_field_change_impact

- [ ] **Purpose**: (Confirm/refine above)
- [ ] **Key Fields**: (Add operator examples)
- [ ] **Relationships**: (Add details)
- [ ] **Business Rules/Notes**:

---

### sys_da_assoc_page_bloc
**Type**: Table  
**Inferred Purpose**: Association between document pages and blocks

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### sys_da_bloc
**Type**: Table  
**Inferred Purpose**: Document blocks/sections

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### sys_da_document
**Type**: Table  
**Inferred Purpose**: Document definitions

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### sys_da_page
**Type**: Table  
**Inferred Purpose**: Document page definitions

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### sys_desc_gen
**Type**: Table  
**Inferred Purpose**: Generic description generator

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### sys_field_limitator
**Type**: Table  
**Discovered Purpose**: Many-to-many binding table linking fields to their validation rules. Activates limitators for specific fields. One field can have multiple rules; one rule can apply to multiple fields.

**Key Fields**: sys_field_ref_UID (the field), sys_limitator_UID (the rule)
**Relationships**: FK to sys_field_ref, FK to sys_limitator, Critical to vw_eli5_sys_field_change_impact

- [ ] **Purpose**: (Confirm/refine above)
- [ ] **Key Fields**: (Add details)
- [ ] **Relationships**: (Add details)
- [ ] **Business Rules/Notes**:

---

### sys_field_ref
**Type**: Table  
**Inferred Purpose**: Field relationship definitions and lookup configurations

**Discovered Purpose**: Field metadata registry - makes the database "self-aware". Defines what each field represents, where it gets values, default sources, and display text. Enables dynamic form generation and runtime field configuration.

**Key Fields**: ForTable/ForField (field being defined), LookupTable/LookupField (value source, typically ref_reference), DefFromTable/DefFromField (default value inheritance), Description/Help (sys_localisation UIDs for multilingual text)
**Relationships**: FK to sys_localisation (Description, Help), Referenced by sys_field_limitator, Central to vw_eli5_sys_field_change_impact

- [ ] **Purpose**: (Confirm/refine above)
- [ ] **Key Fields**:
  - ForTable/ForField: (Field being configured)
  - LookupTable/LookupField: (Value domain source)
  - DefFromTable/DefFromField: (Default value source)
  - Description/Help: (Localization references)
- [ ] **Relationships**: (Add details)
- [ ] **Business Rules/Notes**:

---

### sys_limitator
**Type**: Table  
**Inferred Purpose**: Rule groups that define validation/business logic

**Discovered Purpose**: Named validation rule containers. Each limitator is a reusable rule with conditions (IF logic) and results (THEN logic). The result type determines how results are interpreted (error, warning, restrict values, set default, etc.).

**Key Fields**: Nom (rule name), sys_limitator_result_type_uid (determines result behavior), ConditionText (legacy description), ConditionResult (direct result value when not using result list)
**Relationships**: FK to sys_limitator_result_type, Parent to sys_condition, Parent to sys_cond_result, Referenced by sys_field_limitator, Base table for vw_eli5_sys_field_change_impact

- [ ] **Purpose**: (Confirm/refine above)
- [ ] **Key Fields**:
  - Nom: (Human-readable rule name)
  - ConditionText: (Description/formula)
  - ConditionResult: (Direct result or formula)
  - sys_limitator_result_type_uid: (Result behavior type)
- [ ] **Relationships**: (Add details)
- [ ] **Business Rules/Notes**:

---

### sys_limitator_result_type
**Type**: Table  
**Discovered Purpose**: Defines how limitator results should be interpreted and applied. Types include: restrict values, show error, set default, calculate value, etc. The use_result_list flag determines if results come from sys_cond_result table or ConditionResult field.

**Key Fields**: text (display description), code (programmatic identifier), use_result_list (TRUE = use sys_cond_result, FALSE = use ConditionResult)
**Relationships**: Referenced by sys_limitator.sys_limitator_result_type_uid, Used by vw_eli5_sys_field_change_impact and vw_flat_cond_results

- [ ] **Purpose**: (Confirm/refine above)
- [ ] **Key Fields**: (Add result type examples)
- [ ] **Relationships**: (Add details)
- [ ] **Business Rules/Notes**: (Document special uid=5 behavior)

---

### sys_localisation
**Type**: Table  
**Discovered Purpose**: Centralized multilingual text storage. Stores translations for field labels, help text, item descriptions, and system messages. Enables runtime language switching without code changes.

**Key Fields**: UID (primary key), fr (French text), en (English text - inferred), possibly other language columns
**Relationships**: Referenced by sys_field_ref (Description, Help), ref_item (sys_localisation_uid), Used extensively by vw_flat_cond_list and vw_flat_cond_results for display text

- [ ] **Purpose**: (Confirm/refine above)
- [ ] **Key Fields**: (List all language columns)
- [ ] **Relationships**: (Add details)
- [ ] **Business Rules/Notes**:

---

### sys_notify_context
**Type**: Table  
**Inferred Purpose**: Notification context definitions

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### sys_notify_presets
**Type**: Table  
**Inferred Purpose**: Preset notification templates

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### sys_notify_recipient
**Type**: Table  
**Inferred Purpose**: Notification recipient configuration

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### sys_portes_pricing
**Type**: Table  
**Inferred Purpose**: Door pricing configuration

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### sys_pricing
**Type**: Table  
**Inferred Purpose**: General pricing system configuration

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### sys_user
**Type**: Table  
**Inferred Purpose**: System users

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### sys_user_perm
**Type**: Table  
**Inferred Purpose**: User permissions/access control

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

## TRANSACTION TABLES (trx_*)

### trx_chambre
**Type**: Table  
**Inferred Purpose**: Room transaction data

- [ ] **Purpose**: Defines properties of a cold room
- [ ] **Key Fields**:
  - UID: Unique idenfier for the room
  - trx_groupe_UID: Foreign key on the owning group
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### trx_chambre_renfort
**Type**: Table  
**Inferred Purpose**: Chamber reinforcement details

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### trx_chambre_vitre
**Type**: Table  
**Inferred Purpose**: Chamber glass/window details

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### trx_cloison
**Type**: Table  
**Inferred Purpose**: Partition/wall transaction data

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### trx_def_chambres
**Type**: Table  
**Inferred Purpose**: Chamber definitions for project

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### trx_def_portes
**Type**: Table  
**Inferred Purpose**: Door definitions for project

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### trx_door
**Type**: Table  
**Inferred Purpose**: Door transaction data

**Current Fields**: UID, trx_modulr_group_uid, trx_chambre_uid, trx_porte_uid, seq_id

- [ ] **Purpose**:
- [ ] **Key Fields**:
  - trx_chambre_uid:
  - trx_porte_uid:
  - seq_id:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### trx_epicor_assoc
**Type**: Table  
**Inferred Purpose**: Epicor ERP system association/integration

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### trx_groupe
**Type**: Table  
**Inferred Purpose**: Grouping/module groups for transactions

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### trx_inv_bom
**Type**: Table  
**Inferred Purpose**: Bill of Materials for Inventor integration

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### trx_inv_bom_V2
**Type**: Table  
**Inferred Purpose**: Bill of Materials V2 for Inventor integration

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### trx_panneau
**Type**: Table  
**Inferred Purpose**: Panel transaction data

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### trx_piece
**Type**: Table  
**Inferred Purpose**: Part/piece transaction data

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### trx_porte
**Type**: Table  
**Inferred Purpose**: Door details transaction data

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### trx_pricing
**Type**: Table  
**Inferred Purpose**: Transaction-level pricing calculations

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### trx_project
**Type**: Table  
**Inferred Purpose**: Project/quote header information

**Current Fields**: UID, Projet, BasedOn, IsAModel, Nom, Desc, IterationNum, epi_QuoteNum, epi_OrderNum, comment

- [ ] **Purpose**:
- [ ] **Key Fields**:
  - Projet:
  - BasedOn:
  - IsAModel:
  - epi_QuoteNum/epi_OrderNum:
  - IterationNum:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### trx_project_info
**Type**: Table  
**Inferred Purpose**: Additional project information/metadata

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### trx_room
**Type**: Table  
**Inferred Purpose**: Room transaction data

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### trx_transport_item
**Type**: Table  
**Inferred Purpose**: Transport item details for shipping

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### trx_transport_skid
**Type**: Table  
**Inferred Purpose**: Transport skid/pallet configuration

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

## UNIVERSAL TABLES (uni_*)

### uni_acier_epicor
**Type**: Table  
**Inferred Purpose**: Steel/metal materials for Epicor integration

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### uni_categorie
**Type**: Table  
**Inferred Purpose**: Universal category definitions

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### uni_couleurs
**Type**: Table  
**Inferred Purpose**: Color definitions

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### uni_couleurs_series
**Type**: Table  
**Inferred Purpose**: Color series/groups

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### uni_extran_inventor
**Type**: Table  
**Inferred Purpose**: External transaction data for Inventor

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### uni_intran_inventor
**Type**: Table  
**Inferred Purpose**: Internal transaction data for Inventor

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### uni_materiel
**Type**: Table  
**Inferred Purpose**: Material/equipment master data

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### uni_matiere
**Type**: Table  
**Inferred Purpose**: Material type/substance definitions

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### uni_profile
**Type**: Table  
**Inferred Purpose**: Profile/extrusion definitions

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### uni_texture
**Type**: Table  
**Inferred Purpose**: Texture/finish definitions

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### uni_type_matiere
**Type**: Table  
**Inferred Purpose**: Material type classifications

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

### uni_type_peinture
**Type**: Table  
**Inferred Purpose**: Paint/coating type definitions

- [ ] **Purpose**:
- [ ] **Key Fields**:
- [ ] **Relationships**:
- [ ] **Business Rules/Notes**:

---

## VIEWS

### view_spec_par_projet
**Type**: View  
**Inferred Purpose**: Specifications by project

- [ ] **Purpose**:
- [ ] **Source Tables**:
- [ ] **Usage/Consumers**:
- [ ] **Notes**:

---

### view_trx_porte_for_inventor
**Type**: View  
**Inferred Purpose**: Door data formatted for Inventor CAD system

- [ ] **Purpose**:
- [ ] **Source Tables**:
- [ ] **Usage/Consumers**:
- [ ] **Notes**:

---

### view_uni_acier_epicor
**Type**: View  
**Inferred Purpose**: Steel materials for Epicor integration

- [ ] **Purpose**:
- [ ] **Source Tables**:
- [ ] **Usage/Consumers**:
- [ ] **Notes**:

---

### vw_cond_value_full_list
**Type**: View  
**Inferred Purpose**: Complete list of condition values

- [ ] **Purpose**:
- [ ] **Source Tables**:
- [ ] **Usage/Consumers**:
- [ ] **Notes**:

---

### vw_eli5_sys_field_change_impact
**Type**: View  
**Inferred Purpose**: "Explain Like I'm 5" - Shows impact of field changes

- [ ] **Purpose**:
- [ ] **Source Tables**:
- [ ] **Usage/Consumers**:
- [ ] **Notes**:

---

### vw_flat_cond_list
**Type**: View  
**Inferred Purpose**: Flattened condition list with values

**Source Tables**: sys_cond_value_list, ref_reference, ref_item, sys_localisation

- [ ] **Purpose**:
- [ ] **Usage/Consumers**:
- [ ] **Notes**:

---

### vw_flat_cond_results
**Type**: View  
**Inferred Purpose**: Flattened condition results

- [ ] **Purpose**:
- [ ] **Source Tables**:
- [ ] **Usage/Consumers**:
- [ ] **Notes**:

---

### vw_flat_condition_sentence
**Type**: View  
**Inferred Purpose**: Human-readable condition sentences

- [ ] **Purpose**:
- [ ] **Source Tables**:
- [ ] **Usage/Consumers**:
- [ ] **Notes**:

---

### vw_flat_items
**Type**: View  
**Inferred Purpose**: Flattened item listing

- [ ] **Purpose**:
- [ ] **Source Tables**:
- [ ] **Usage/Consumers**:
- [ ] **Notes**:

---

### vw_flat_limitator_result_sentence
**Type**: View  
**Inferred Purpose**: Human-readable limitator result sentences

- [ ] **Purpose**:
- [ ] **Source Tables**:
- [ ] **Usage/Consumers**:
- [ ] **Notes**:

---

### vw_flat_ref_reference
**Type**: View  
**Inferred Purpose**: Flattened reference data

- [ ] **Purpose**:
- [ ] **Source Tables**:
- [ ] **Usage/Consumers**:
- [ ] **Notes**:

---

### vw_flat_result_list
**Type**: View  
**Inferred Purpose**: Flattened result list

- [ ] **Purpose**:
- [ ] **Source Tables**:
- [ ] **Usage/Consumers**:
- [ ] **Notes**:

---

### vw_ref_item_coutant
**Type**: View  
**Inferred Purpose**: Item cost/pricing view

- [ ] **Purpose**:
- [ ] **Source Tables**:
- [ ] **Usage/Consumers**:
- [ ] **Notes**:

---

### vw_sys_field_ref_extended
**Type**: View  
**Inferred Purpose**: Extended field reference information

- [ ] **Purpose**:
- [ ] **Source Tables**:
- [ ] **Usage/Consumers**:
- [ ] **Notes**:

---

### vw_sys_field_ref_valid_default
**Type**: View  
**Inferred Purpose**: Valid default values for field references

- [ ] **Purpose**:
- [ ] **Source Tables**:
- [ ] **Usage/Consumers**:
- [ ] **Notes**:

---

### vw_sys_map_inventor_material
**Type**: View  
**Inferred Purpose**: Material mapping for Inventor CAD integration

- [ ] **Purpose**:
- [ ] **Source Tables**:
- [ ] **Usage/Consumers**:
- [ ] **Notes**:

---

### vw_text_trx_porte
**Type**: View  
**Inferred Purpose**: Text/description view for door transactions

- [ ] **Purpose**:
- [ ] **Source Tables**:
- [ ] **Usage/Consumers**:
- [ ] **Notes**:

---

### vw_uni_acier_mat_uid_sans_silkline
**Type**: View  
**Inferred Purpose**: Steel materials excluding Silkline

- [ ] **Purpose**:
- [ ] **Source Tables**:
- [ ] **Usage/Consumers**:
- [ ] **Notes**:

---

### vw_uni_materiel
**Type**: View  
**Inferred Purpose**: Material/equipment view

- [ ] **Purpose**:
- [ ] **Source Tables**:
- [ ] **Usage/Consumers**:
- [ ] **Notes**:

---

## COMPLETION CHECKLIST

Use this checklist to track documentation progress:

### Reference Tables
- [ ] ref_categories
- [ ] ref_global_price_change
- [ ] ref_item
- [ ] ref_pan_continu
- [ ] ref_param
- [ ] ref_reference
- [ ] ref_transport_skid_size
- [ ] ref_type

### System Tables
- [ ] sys_cond_result
- [ ] sys_cond_value_list
- [ ] sys_condition
- [ ] sys_condition_type
- [ ] sys_da_assoc_page_bloc
- [ ] sys_da_bloc
- [ ] sys_da_document
- [ ] sys_da_page
- [ ] sys_desc_gen
- [ ] sys_field_limitator
- [ ] sys_field_ref
- [ ] sys_limitator
- [ ] sys_limitator_result_type
- [ ] sys_localisation
- [ ] sys_notify_context
- [ ] sys_notify_presets
- [ ] sys_notify_recipient
- [ ] sys_portes_pricing
- [ ] sys_pricing
- [ ] sys_user
- [ ] sys_user_perm

### Transaction Tables
- [ ] trx_chambre
- [ ] trx_chambre_renfort
- [ ] trx_chambre_vitre
- [ ] trx_cloison
- [ ] trx_def_chambres
- [ ] trx_def_portes
- [ ] trx_door
- [ ] trx_epicor_assoc
- [ ] trx_groupe
- [ ] trx_inv_bom
- [ ] trx_inv_bom_V2
- [ ] trx_panneau
- [ ] trx_piece
- [ ] trx_porte
- [ ] trx_pricing
- [ ] trx_project
- [ ] trx_project_info
- [ ] trx_room
- [ ] trx_transport_item
- [ ] trx_transport_skid

### Universal Tables
- [ ] uni_acier_epicor
- [ ] uni_categorie
- [ ] uni_couleurs
- [ ] uni_couleurs_series
- [ ] uni_extran_inventor
- [ ] uni_intran_inventor
- [ ] uni_materiel
- [ ] uni_matiere
- [ ] uni_profile
- [ ] uni_texture
- [ ] uni_type_matiere
- [ ] uni_type_peinture

### Views
- [ ] view_spec_par_projet
- [ ] view_trx_porte_for_inventor
- [ ] view_uni_acier_epicor
- [ ] vw_cond_value_full_list
- [ ] vw_eli5_sys_field_change_impact
- [ ] vw_flat_cond_list
- [ ] vw_flat_cond_results
- [ ] vw_flat_condition_sentence
- [ ] vw_flat_items
- [ ] vw_flat_limitator_result_sentence
- [ ] vw_flat_ref_reference
- [ ] vw_flat_result_list
- [ ] vw_ref_item_coutant
- [ ] vw_sys_field_ref_extended
- [ ] vw_sys_field_ref_valid_default
- [ ] vw_sys_map_inventor_material
- [ ] vw_text_trx_porte
- [ ] vw_uni_acier_mat_uid_sans_silkline
- [ ] vw_uni_materiel

---
*Template Generated: April 20, 2026*
