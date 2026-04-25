# Maximum Panel Length Application

## Purpose

Quick reference application to determine the maximum architectural panel length for Norex panels based on product specifications.

## Architecture

Microservices architecture with Python FastAPI backend and React frontend, deployed in Docker containers. See [docs/architecture.md](docs/architecture.md) for details.

## Project Structure

- **src/**: Source code (backend and frontend applications)
  - `backend/`: Python FastAPI REST API
  - `frontend/`: React UI application
- **docs/**: Architecture and technical documentation
- **Resources/**: UI references and supporting materials
- **MaxLength-*.csv**: Plant-specific data files

## Input Parameters

- **Plant Location**: St-Hyacinthe (STH) or Strathroy (SRY)
- **Panel Color**: Various options (bilingual EN/FR)
- **Paint Type**: PVDF CLASSIC, PVDF SIGNATURE, SMP CLASSIC, SMP PREMIUM, METALLIC
- **Gage**: 22, 24, or 26
- **Profile**: Grooved, Silkline, Microribbed, or No Profile
- **Finish**: Embossed or Smooth

## Output

Maximum panel length in feet based on the selected specifications.

## Data Sources

- **MaxLength-STH.csv**: St-Hyacinthe plant data
- **MaxLength-SRY.csv**: Strathroy plant data (includes surface and SRI values)

## Data Format

CSV files with columns:
- Color, Paint, Gage (STH & SRY)
- surface, SRI (SRY only)
- Profile/Finish combinations:
  - GroovedEmbossed, GroovedSmooth
  - SilklineEmbossed, SilklineSmooth
  - MicroribbedEmbossed, MicroribbedSmooth
  - Embossed, Smooth (no profile)

## Notes

- Values may show "NA" when a combination is not available
- Values in feet format (e.g., "24'", "52.25")
- Requests exceeding maximum lengths require technical team approval

## Project Files

- `maximum-panel-length-reference.md`: Original SharePoint reference documentation
- `norex-panel-length-tables-extracted.md`: Extracted table data
- `CALCUL ESPACEMENT ENTREMISES.xlsm`: Excel calculation tool
- `Application/`: Application source code
- `Resources/`: Supporting resources
