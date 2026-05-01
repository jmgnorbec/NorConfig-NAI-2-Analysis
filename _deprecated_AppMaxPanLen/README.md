# Maximum Panel Length Application

## Purpose

Quick reference application to determine the maximum architectural panel length for Norex panels based on product specifications.

## Architecture

Microservices architecture with Python FastAPI backend and React frontend, deployed in Docker containers.

- **Architecture & design decisions**: [docs/architecture.md](docs/architecture.md)
- **API specification**: [docs/api-specification.md](docs/api-specification.md)
- **UI specifications**: [docs/ui-specifications.md](docs/ui-specifications.md)
- **Development plan**: [docs/development-plan.md](docs/development-plan.md)

## Project Structure

- **src/**: Source code (backend and frontend applications)
  - `backend/`: Python FastAPI REST API
  - `frontend/`: React UI application
- **docs/**: Architecture and technical documentation
- **References/**: Reference documents and UI design examples
- **MaxLength-*.csv**: Plant-specific data files

## Input Parameters

- Plant: STH (St-Hyacinthe) or SRY (Strathroy)
- Color: Various bilingual options (e.g., "Blanc Régal/Regal White")
- Paint Type: PVDF CLASSIC, PVDF SIGNATURE, SMP CLASSIC, SMP PREMIUM, METALLIC
- Gage: 22, 24, 26
- Profile: Grooved, Silkline, Microribbed, None
- Finish: Embossed, Smooth

## Data

**Sources:**
- `MaxLength-STH.csv` - St-Hyacinthe plant data
- `MaxLength-SRY.csv` - Strathroy plant data (includes surface and SRI values)

**Format:**
- Each row: Color, Paint, Gage, and max lengths for profile/finish combinations
- SRY includes additional surface and SRI columns
- Values in feet (e.g., "52.25" or "24'")
- "NA" indicates unavailable combination

**Note:** Requests exceeding max lengths require technical team approval

## References

- `References/maximum-panel-length-reference.md` - Original SharePoint documentation
- `References/norex-panel-length-tables-extracted.md` - Extracted table data
- `References/UI style example.png` - UI design reference (ToitCalc Pro)
- `CALCUL ESPACEMENT ENTREMISES.xlsm` - Excel calculation tool
