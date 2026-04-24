# copilot-context.md

## 🧭 Context Overview

This project focuses on **Norconfig NAI 2.0 – Roofing Panels & Options Product Configurator**.

Goal:
Design and implement a **rule-driven product configurator system** capable of:
- Generating valid product configurations
- Producing consistent specifications
- Integrating with enterprise systems (Epicor, MES, etc.)

---

## 📄 Source of Truth

Primary document:
- NSR-321 (JIRA export)

Key facts:
- Strategic project (2026 growth)
- Target: August 2026
- Product: NorSeam (highly configurable roofing panels)

---

## 🚨 Core Problem

Current system:
- Allows invalid configurations
- Lacks validation rules
- Is monolithic and obsolete
- Requires manual work

Impact:
- Production errors
- Non-conformities
- Rework costs

---

## 🎯 Target System (High-Level)

The system must:

1. Guide users through valid configuration paths
2. Validate all configurations (rules + constraints)
3. Generate product specifications
4. Integrate with:
   - Epicor
   - Planning / MES
   - CAD / take-off tools
5. Support extensibility (low-code / no-code where possible)

---

## 🧠 Architectural Direction (Working Hypothesis)

System is NOT just UI.

It is composed of:

- Configuration Engine (rules + constraints)
- Product Model (parametric structure)
- Validation Layer
- Integration Layer (APIs / adapters)
- UI (guided workflow)

---

## 🧩 Key Design Questions (OPEN)

- Rule engine vs constraint solver vs hybrid?
- Product model: parametric vs graph-based?
- Should we use a Knowledge Graph for configuration logic?
- Integration pattern: synchronous API vs async/event-driven?
- How to enable business-side configurability?

---

## 🔗 Relation to Ongoing Work

This project aligns with:

- Context Engineering (Architecture for Attention)
- Knowledge Graph exploration (multi-hop reasoning, relationships)
- AI-assisted workflow design
- Copilot-driven development

---

## 🏗️ Suggested Folder Structure

/dev
  /docs
    - project-brief.md
    - copilot-context.md   ← this file
    - architecture.md
    - domain-model.md
  /src
  /tests

---

## 🧭 Working Principles

- Low entropy documentation
- Explicit separation:
  - facts vs assumptions vs design
- Layered documentation:
  - Brief → Spec → Architecture → Implementation
- Copilot-first:
  - files should be readable, structured, minimal

---

## ⚠️ Constraints

- Must integrate with legacy enterprise systems
- Must support complex domain rules (roof panels)
- Must minimize invalid configurations (near 100%)

---

## 📌 Immediate Next Steps

1. Extract domain entities and relationships
2. Define product model structure
3. Define configuration rules system
4. Draft minimal architecture
5. Evaluate Knowledge Graph applicability

---

## 🧠 Notes for Copilot

- Prefer structured outputs (Markdown, lists, schemas)
- Avoid verbosity
- Focus on:
  - clarity
  - correctness
  - maintainability
- When uncertain:
  - state assumptions explicitly

