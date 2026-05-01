# Norex Maximum Suggested Panel Length — Extracted Context Data

Source workbook: `ccaf4237-1424-4f88-9bc9-e0d9653e1d51.xlsm`.

## Recommended Markdown format for LLM context

For this kind of Excel-derived technical reference, the preferred Markdown format is **normalized CSV inside fenced code blocks**, preceded by a short schema and interpretation notes.

Why this is preferred over a visual Markdown table:

- CSV is compact and less noisy for large tables.
- Column names are explicit and stable.
- It avoids fragile Excel layout concepts such as merged cells, blank continuation rows, and visual grouping.
- It is easier for an LLM or script to parse consistently.

## Interpretation notes

- Units for maximum panel length columns are **feet**.
- `Not Available` means the combination is explicitly unavailable in the source table.
- Decimal values were rounded to two decimals for context readability.
- Blank Excel continuation rows were normalized by repeating the applicable colour/finish metadata.
- The two visible source sheets are:
  - `Norex L - Max. Panel Length` → St-Hyacinthe maximum panel length table
  - `Norex M - Max. Panel Length SRY` → Strathroy maximum panel length table

## Schema: maximum panel length table

```csv
sheet,plant,panel_family,color,finish,tsurface_c,sri,gage,grooved_embossed_ft,grooved_smooth_ft,silkline_embossed_ft,silkline_smooth_ft,microribbed_embossed_ft,microribbed_smooth_ft,without_profile_embossed_ft,without_profile_smooth_ft
```

### Norex L — St-Hyacinthe maximum panel length table

```csv
sheet,plant,panel_family,color,finish,tsurface_c,sri,gage,grooved_embossed_ft,grooved_smooth_ft,silkline_embossed_ft,silkline_smooth_ft,microribbed_embossed_ft,microribbed_smooth_ft,without_profile_embossed_ft,without_profile_smooth_ft
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Blanc Régal/Regal White,PVDF CLASSIC,53.34,76.59,22,52.25,52.25,52.25,52.25,52.25,52.25,24,24
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Blanc Régal/Regal White,PVDF CLASSIC,53.34,76.59,24,52.25,52.25,52.25,52.25,52.25,52.25,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Blanc Régal/Regal White,PVDF CLASSIC,53.34,76.59,26,52.25,52.25,52.25,52.25,52.17,52.25,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Blanc Brillant/Bright White,SMP CLASSIC,53.44,76.33,22,52.25,52.25,52.25,52.25,52.25,52.25,24,24
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Blanc Brillant/Bright White,SMP CLASSIC,53.44,76.33,24,52.25,52.25,52.25,52.25,52.25,52.25,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Blanc Brillant/Bright White,SMP CLASSIC,53.44,76.33,26,52.25,52.25,52.25,52.25,52.11,52.25,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Blanc Impérial/Imperial White,METALLIC,56.55,65.71,22,52.25,52.25,52.25,52.25,52.25,52.25,24,24
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Blanc Impérial/Imperial White,METALLIC,56.55,65.71,24,52.25,52.25,52.25,52.25,52.25,52.25,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Blanc Impérial/Imperial White,METALLIC,56.55,65.71,26,52.25,52.25,52.25,52.25,49.81,50.1,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Electric Yellow,PVDF SIGNATURE,56.72,67.56,22,52.25,52.25,52.25,52.25,52.25,52.25,24,24
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Electric Yellow,PVDF SIGNATURE,56.72,67.56,24,52.25,52.25,52.25,52.25,52.25,52.25,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Electric Yellow,PVDF SIGNATURE,56.72,67.56,26,52.25,52.25,52.25,52.25,49.66,49.95,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Blanc Pur/White white,SMP CLASSIC,57.58,65.3,22,52.25,52.25,52.25,52.25,52.25,52.25,24,24
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Blanc Pur/White white,SMP CLASSIC,57.58,65.3,24,52.25,52.25,52.25,52.25,51.8,52.25,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Blanc Pur/White white,SMP CLASSIC,57.58,65.3,26,52.25,52.25,52.25,52.25,48.89,49.19,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Sable/Sandstone,PVDF CLASSIC,58.61,62.56,22,52.25,52.25,52.25,52.25,52.25,52.25,24,24
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Sable/Sandstone,PVDF CLASSIC,58.61,62.56,24,52.25,52.25,52.25,52.25,50.32,52.25,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Sable/Sandstone,PVDF CLASSIC,58.61,62.56,26,52.08,51.27,52.08,51.27,47.9,48.19,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Blanc os/Bone White,SMP CLASSIC,60.53,57.45,22,52.25,52.25,52.25,52.25,52.17,51.73,24,24
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Blanc os/Bone White,SMP CLASSIC,60.53,57.45,24,50.71,50.12,50.71,50.12,47.57,50.12,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Blanc os/Bone White,SMP CLASSIC,60.53,57.45,26,49.44,48.37,49.44,48.37,45.84,46.09,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Gris Pierre/Stone Grey,SMP CLASSIC,63.07,50.71,22,51.34,50.25,51.34,50.25,48.35,47.8,24,24
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Gris Pierre/Stone Grey,SMP CLASSIC,63.07,50.71,24,47.08,46.56,47.08,46.56,43.92,46.56,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Gris Pierre/Stone Grey,SMP CLASSIC,63.07,50.71,26,45.77,44.49,45.77,44.49,42.69,42.85,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Argent Brillant/Bright Silver perspectra,METALLIC,63.42,49.81,22,50.89,49.77,50.89,49.77,47.84,47.28,24,24
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Argent Brillant/Bright Silver perspectra,METALLIC,63.42,49.81,24,46.57,46.07,46.57,46.07,43.41,46.07,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Argent Brillant/Bright Silver perspectra,METALLIC,63.42,49.81,26,45.24,43.94,45.24,43.94,42.22,42.36,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Gris Élément/Element Grey,PVDF CLASSIC,63.57,49.37,22,46,45,46,45,43,42,24,24
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Gris Élément/Element Grey,PVDF CLASSIC,63.57,49.37,24,46.35,45.85,46.35,45.85,43.2,45.85,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Gris Élément/Element Grey,PVDF CLASSIC,63.57,49.37,26,45.01,43.71,45.01,43.71,42.01,42.14,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Riesling/Riesling,METALLIC,66.54,41.57,22,46.94,45.71,46.94,45.71,43.6,42.93,21,20
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Riesling/Riesling,METALLIC,66.54,41.57,24,42.11,41.7,42.11,41.7,38.94,41.7,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Riesling/Riesling,METALLIC,66.54,41.57,26,40.41,39.13,40.41,39.13,37.63,37.57,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Vibrant Red,SMP PREMIUM,66.6,41.36,22,46.87,45.63,46.87,45.63,43.52,42.85,21,20
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Vibrant Red,SMP PREMIUM,66.6,41.36,24,42.02,41.62,42.02,41.62,38.85,41.62,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Vibrant Red,SMP PREMIUM,66.6,41.36,26,40.32,39.04,40.32,39.04,37.54,37.46,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Beige Surrey,PVDF CLASSIC,68.1,37.38,22,45.01,43.76,45.01,43.76,41.63,40.91,21,20
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Beige Surrey,PVDF CLASSIC,68.1,37.38,24,39.87,39.51,39.87,39.51,36.69,39.51,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Beige Surrey,PVDF CLASSIC,68.1,37.38,26,37.87,36.69,37.87,36.69,35.06,34.86,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Fauve/Tan,SMP CLASSIC,68.6,36.06,22,44.4,43.15,44.4,43.15,41.03,40.29,21,20
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Fauve/Tan,SMP CLASSIC,68.6,36.06,24,39.16,38.81,39.16,38.81,35.97,38.81,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Fauve/Tan,SMP CLASSIC,68.6,36.06,26,37.04,35.91,37.04,35.91,34.2,33.95,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Pacific Turquoise,SMP PREMIUM,71.06,29.55,22,41.44,40.24,41.44,40.24,38.21,37.41,21,20
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Pacific Turquoise,SMP PREMIUM,71.06,29.55,24,35.64,35.37,35.64,35.37,32.44,35.37,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Pacific Turquoise,SMP PREMIUM,71.06,29.55,26,32.84,32.03,32.84,32.03,29.71,29.18,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Bleu Ardoise/Slate Blue,SMP PREMIUM,71.1,29.48,22,41.4,40.2,41.4,40.2,38.17,37.37,21,20
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Bleu Ardoise/Slate Blue,SMP PREMIUM,71.1,29.48,24,35.59,35.32,35.59,35.32,32.39,35.32,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Bleu Ardoise/Slate Blue,SMP PREMIUM,71.1,29.48,26,32.78,31.98,32.78,31.98,29.65,29.11,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Étain/Pewter perspectra,METALLIC,71.1,29.48,22,41.4,40.2,41.4,40.2,38.17,37.37,21,20
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Étain/Pewter perspectra,METALLIC,71.1,29.48,24,35.59,35.32,35.59,35.32,32.39,35.32,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Étain/Pewter perspectra,METALLIC,71.1,29.48,26,32.78,31.98,32.78,31.98,29.65,29.11,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Acier Satiné/Satin Steel,PVDF SIGNATURE,71.28,29.02,22,41.19,40,41.19,40,37.98,37.17,21,20
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Acier Satiné/Satin Steel,PVDF SIGNATURE,71.28,29.02,24,35.33,35.07,35.33,35.07,32.13,35.07,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Acier Satiné/Satin Steel,PVDF SIGNATURE,71.28,29.02,26,32.46,31.7,32.46,31.7,29.3,28.74,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Cuivre/Copper,METALLIC,71.4,28.84,22,41.05,39.86,41.05,39.86,37.85,37.04,21,20
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Cuivre/Copper,METALLIC,71.4,28.84,24,35.16,34.9,35.16,34.9,31.96,34.9,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Cuivre/Copper,METALLIC,71.4,28.84,26,32.26,31.51,32.26,31.51,29.07,28.5,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Fusain/Charcoal,PVDF CLASSIQUE,71.6,28,22,42,40,42,40,37.64,38,21,20
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Fusain/Charcoal,PVDF CLASSIQUE,71.6,28,24,34.88,34.62,34.88,34.62,31.68,34.62,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Fusain/Charcoal,PVDF CLASSIQUE,71.6,28,26,31.9,31.19,31.9,31.19,28.68,28.08,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Gris Tempête/Storm Grey,PVDF SIGNATURE,72.14,27,22,41,40,41,40,39,38,21,20
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Gris Tempête/Storm Grey,PVDF SIGNATURE,72.14,27,24,34.09,33.85,34.09,33.85,30.89,33.85,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Gris Tempête/Storm Grey,PVDF SIGNATURE,72.14,28,26,30.93,30.32,30.93,30.32,27.6,26.93,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Gris Régent/Regent Gray,PVDF CLASSIC,72.41,26,22,41,40,41,40,39,38,21,20
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Gris Régent/Regent Gray,PVDF CLASSIC,72.41,26,24,33.72,33.49,33.72,33.49,30.51,33.49,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Gris Régent/Regent Gray,PVDF CLASSIC,72.41,26,26,30.47,29.91,30.47,29.91,27.08,26.37,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Bleu royal/Royal Blue,PVDF SIGNATURE,73.27,23.78,22,38.85,37.76,38.85,37.76,35.91,35.06,21,20
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Bleu royal/Royal Blue,PVDF SIGNATURE,73.27,23.78,24,32.48,32.27,32.48,32.27,29.27,32.27,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Bleu royal/Royal Blue,PVDF SIGNATURE,73.27,28,26,28.9,28.53,28.9,28.53,25.3,24.48,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Gris Rigel /Grey Rigel,METALLIC,73.96,21.98,22,41,40,41,40,38,37,21,20
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Gris Rigel /Grey Rigel,METALLIC,73.96,21.98,24,31.49,31.31,31.49,31.31,28.28,31.31,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Gris Rigel /Grey Rigel,METALLIC,73.96,21.98,26,27.64,27.43,27.64,27.43,23.86,22.93,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Bleu Héron/Heron Blue,SMP PREMIUM,74.08,21.66,22,37.92,36.89,37.92,36.89,35.13,34.27,21,18
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Bleu Héron/Heron Blue,SMP PREMIUM,74.08,21.66,24,31.33,31.15,31.33,31.15,28.12,31.15,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Bleu Héron/Heron Blue,SMP PREMIUM,74.08,26,26,27.43,27.24,27.43,27.24,23.61,22.67,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Rouge Colonial/Colonial Red,PVDF SIGNATURE,75.75,17.26,22,36.01,35.12,36.01,35.12,33.59,32.7,21,18
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Rouge Colonial/Colonial Red,PVDF SIGNATURE,75.75,17.26,24,28.93,28.8,28.93,28.8,25.71,28.8,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Rouge Colonial/Colonial Red,PVDF SIGNATURE,75.75,26,26,24.29,24.55,24.29,24.55,19.92,18.71,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Brun Foncé /Dark Brown,SMP PREMIUM,77.52,11.34,22,31,30,31,30,28,27,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Brun Foncé /Dark Brown,SMP PREMIUM,77.52,11.34,24,26.4,26.33,26.4,26.33,23.17,26.33,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Brun Foncé /Dark Brown,SMP PREMIUM,77.52,26,26,20.89,21.7,20.89,21.7,15.82,14.29,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Noir/Black,METALLIC,82.6,-1,22,28,28,28,28,28.6,27.65,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Noir/Black,METALLIC,82.6,-1,24,Not Available,Not Available,Not Available,Not Available,Not Available,Not Available,Not Available,Not Available
Norex L - Max. Panel Length,St-Hyacinthe,Norex L,Noir/Black,METALLIC,82.6,-1,26,Not Available,Not Available,Not Available,Not Available,Not Available,Not Available,Not Available,Not Available
```

### Norex M — Strathroy maximum panel length table

```csv
sheet,plant,panel_family,color,finish,tsurface_c,sri,gage,grooved_embossed_ft,grooved_smooth_ft,silkline_embossed_ft,silkline_smooth_ft,microribbed_embossed_ft,microribbed_smooth_ft,without_profile_embossed_ft,without_profile_smooth_ft
Norex M - Max. Panel Length SRY,Strathroy,Norex M,Blanc Régal/Regal White,PVDF CLASSIC,53.34,76.59,22,60,60,60,60,60,60,24,24
Norex M - Max. Panel Length SRY,Strathroy,Norex M,Blanc Régal/Regal White,PVDF CLASSIC,53.34,76.59,26,58.7,59.12,58.7,59.12,52.17,52.38,Not Available,Not Available
Norex M - Max. Panel Length SRY,Strathroy,Norex M,Blanc Brillant/Bright White,SMP CLASSIC,53.44,76.33,22,60,60,60,60,60,60,24,24
Norex M - Max. Panel Length SRY,Strathroy,Norex M,Blanc Brillant/Bright White,SMP CLASSIC,53.44,76.33,24,60,60,60,60,56.22,60,Not Available,Not Available
Norex M - Max. Panel Length SRY,Strathroy,Norex M,Blanc Brillant/Bright White,SMP CLASSIC,53.44,76.33,26,58.59,58.97,58.59,58.97,52.11,52.32,Not Available,Not Available
Norex M - Max. Panel Length SRY,Strathroy,Norex M,Blanc Impérial/Imperial White,METALLIC,56.55,65.71,26,54.78,54.36,54.78,54.36,49.81,50.1,Not Available,Not Available
Norex M - Max. Panel Length SRY,Strathroy,Norex M,Electric Yellow,PVDF SIGNATURE,56.72,67.56,22,59.79,59.03,59.79,59.03,58.43,58.16,24,24
Norex M - Max. Panel Length SRY,Strathroy,Norex M,Blanc Pur/White white,SMP CLASSIC,57.58,65.3,26,52.25,52.25,52.25,52.25,48.89,49.19,Not Available,Not Available
Norex M - Max. Panel Length SRY,Strathroy,Norex M,Sable/Sandstone,PVDF CLASSIC,58.61,62.56,22,57.22,56.17,57.22,56.17,55.25,54.89,24,24
Norex M - Max. Panel Length SRY,Strathroy,Norex M,Blanc os/Bone White,SMP CLASSIC,60.53,57.45,26,49.44,48.37,49.44,48.37,45.84,46.09,Not Available,Not Available
Norex M - Max. Panel Length SRY,Strathroy,Norex M,Gris Pierre/Stone Grey,SMP CLASSIC,63.07,50.71,26,45.77,44.49,45.77,44.49,42.69,42.85,Not Available,Not Available
Norex M - Max. Panel Length SRY,Strathroy,Norex M,Argent Brillant/Bright Silver perspectra,METALLIC,63.42,49.81,22,50.89,49.31,50.89,49.31,47.84,47.28,24,24
Norex M - Max. Panel Length SRY,Strathroy,Norex M,Gris Élément/Element Grey,PVDF CLASSIC,63.57,49.37,22,46,45,46,45,43,42,24,24
Norex M - Max. Panel Length SRY,Strathroy,Norex M,Riesling/Riesling,METALLIC,66.54,41.57,22,46.94,45.2,46.94,45.2,43.6,42.93,21,20
Norex M - Max. Panel Length SRY,Strathroy,Norex M,Vibrant Red,SMP PREMIUM,66.6,41.36,22,46.87,45.13,46.87,45.13,43.52,42.85,21,20
Norex M - Max. Panel Length SRY,Strathroy,Norex M,Beige Surrey,PVDF CLASSIC,68.1,37.38,22,45.01,43.24,45.01,43.24,41.63,40.91,21,20
Norex M - Max. Panel Length SRY,Strathroy,Norex M,Fauve/Tan,SMP CLASSIC,68.6,36.06,24,36.29,35.37,36.29,35.37,33.97,35.37,Not Available,Not Available
Norex M - Max. Panel Length SRY,Strathroy,Norex M,Pacific Turquoise,SMP PREMIUM,71.06,29.55,22,41.44,39.7,41.44,39.7,38.21,37.41,21,20
Norex M - Max. Panel Length SRY,Strathroy,Norex M,Bleu Ardoise/Slate Blue,SMP PREMIUM,71.1,29.48,24,34,33,34,33,32,33,Not Available,Not Available
Norex M - Max. Panel Length SRY,Strathroy,Norex M,Étain/Pewter perspectra,METALLIC,71.1,29.48,22,41.4,39.66,41.4,39.66,38.17,37.37,21,20
Norex M - Max. Panel Length SRY,Strathroy,Norex M,Acier Satiné/Satin Steel,PVDF SIGNATURE,71.28,29.02,22,41.19,39.45,41.19,39.45,37.98,37.17,21,20
Norex M - Max. Panel Length SRY,Strathroy,Norex M,Cuivre/Copper,METALLIC,71.4,28.84,22,41.05,39.32,41.05,39.32,37.85,37.04,21,20
Norex M - Max. Panel Length SRY,Strathroy,Norex M,Fusain/Charcoal,PVDF CLASSIQUE,71.6,28,22,42,39.09,42,39.09,37.64,38,21,20
Norex M - Max. Panel Length SRY,Strathroy,Norex M,Fusain/Charcoal,PVDF CLASSIQUE,71.6,28,26,31.9,31.19,31.9,31.19,28.68,28.08,Not Available,Not Available
Norex M - Max. Panel Length SRY,Strathroy,Norex M,Gris Tempête/Storm Grey,PVDF SIGNATURE,72.14,27,22,41,40,41,40,39,38,21,20
Norex M - Max. Panel Length SRY,Strathroy,Norex M,Gris Régent/Regent Gray,PVDF CLASSIC,72.41,26,22,41,40,41,40,39,38,21,20
Norex M - Max. Panel Length SRY,Strathroy,Norex M,Gris Régent/Regent Gray,PVDF CLASSIC,72.41,26,26,30.47,29.91,30.47,29.91,27.08,26.37,Not Available,Not Available
Norex M - Max. Panel Length SRY,Strathroy,Norex M,Bleu royal/Royal Blue,PVDF SIGNATURE,73.27,23.78,22,38.85,37.21,38.85,37.21,35.91,35.06,21,20
Norex M - Max. Panel Length SRY,Strathroy,Norex M,Gris Rigel /Grey Rigel,METALLIC,73.96,21.98,22,41,40,41,40,38,37,21,20
Norex M - Max. Panel Length SRY,Strathroy,Norex M,Bleu Héron/Heron Blue,SMP PREMIUM,74.08,21.66,22,37.92,36.34,37.92,36.34,35.13,34.27,21,18
Norex M - Max. Panel Length SRY,Strathroy,Norex M,Rouge Colonial/Colonial Red,PVDF SIGNATURE,75.75,17.26,22,36.01,34.58,36.01,34.58,33.59,32.7,21,18
Norex M - Max. Panel Length SRY,Strathroy,Norex M,Brun Foncé /Dark Brown,SMP PREMIUM,77.52,11.34,22,31,30,31,30,28,27,Not Available,Not Available
Norex M - Max. Panel Length SRY,Strathroy,Norex M,Noir/Black,METALLIC,82.6,-1,22,28,28,28,28,28.6,27.65,Not Available,Not Available
```

## Supporting colour / surface-temperature data

These rows come from the `MAXIMUM SURFACE TEMPERATURE` section of each visible sheet. They are included as supporting context only; the main lookup data is in the maximum panel length tables above.

### Schema: colour / surface-temperature table

```csv
sheet,color,finish,norbec_color_number,appearance,solar_reflectance_sr,solar_absorptance_alpha,emissivity,tsurface_max_c,sri,gage
```

### Norex L colour / surface-temperature data

```csv
sheet,color,finish,norbec_color_number,appearance,solar_reflectance_sr,solar_absorptance_alpha,emissivity,tsurface_max_c,sri,gage
Norex L - Max. Panel Length,Blanc Horizon/Horizon White (Coastal),,10856,x,0.73,0.27,0.89,48.51,88.76,
Norex L - Max. Panel Length,Blanc Régal/Regal White,PVDF CLASSIC,17-1651,,0.64,0.36,0.87,53.34,74.93,"22
26"
Norex L - Max. Panel Length,Blanc Brillant/Bright White,SMP CLASSIC,28783,,0.64,0.36,0.86,53.44,74.34,"22
24
26"
Norex L - Max. Panel Length,Blanc Impérial/Imperial White,METALLIC,,,0.58,0.42,0.86,56.55,65.71,26
Norex L - Max. Panel Length,Electric Yellow,PVDF SIGNATURE,17-1661,,0.57,0.43,0.89,56.72,66.35,22
Norex L - Max. Panel Length,Blanc Pur/White white,SMP CLASSIC,28317,,0.56,0.44,0.86,57.58,62.85,26
Norex L - Max. Panel Length,Sable/Sandstone,PVDF CLASSIC,17-1629,,0.54,0.46,0.86,58.61,60.01,22
Norex L - Max. Panel Length,Blanc os/Bone White,SMP CLASSIC,28273,,0.5,0.5,0.87,60.53,55.15,26
Norex L - Max. Panel Length,Gris Pierre/Stone Grey,SMP CLASSIC,28305,,0.45,0.55,0.87,63.07,48.19,26
Norex L - Max. Panel Length,Argent Brillant/Bright Silver perspectra,METALLIC,17-1627,,0.46,0.54,0.81,63.42,44.04,22
Norex L - Max. Panel Length,Gris Élément/Element Grey,PVDF CLASSIC,10557,,0.44,0.56,0.87,63.57,46.8,22
Norex L - Max. Panel Length,Riesling/Riesling,METALLIC,10437,,0.4,0.6,0.81,66.54,35.19,22
Norex L - Max. Panel Length,Vibrant Red,SMP PREMIUM,17-1660,,0.38,0.62,0.87,66.6,38.53,22
Norex L - Max. Panel Length,Beige Surrey,PVDF CLASSIC,17-9805,,0.35,0.65,0.87,68.1,34.43,22
Norex L - Max. Panel Length,Fauve/Tan,SMP CLASSIC,28315,,0.34,0.66,0.87,68.6,33.06,24
Norex L - Max. Panel Length,Pacific Turquoise,SMP PREMIUM,28258,,0.28,0.72,0.9,71.06,28.17,22
Norex L - Max. Panel Length,Bleu Ardoise/Slate Blue,SMP PREMIUM,28260,,0.29,0.71,0.87,71.1,26.28,24
Norex L - Max. Panel Length,Étain/Pewter perspectra,METALLIC,17-1626,,0.29,0.71,0.87,71.1,26.28,22
Norex L - Max. Panel Length,Acier Satiné/Satin Steel,PVDF SIGNATURE,9742,,0.29,0.71,0.86,71.28,25.16,22
Norex L - Max. Panel Length,Cuivre/Copper,METALLIC,10321,,0.35,0.65,0.69,71.4,10.96,22
Norex L - Max. Panel Length,Fusain/Charcoal,PVDF CLASSIC,17-1625,,0.28,0.72,0.87,71.6,24.93,"22
26"
Norex L - Max. Panel Length,Gris Tempête/Storm Grey,PVDF SIGNATURE,10032,,0.28,0.72,0.84,72.14,21.46,22
Norex L - Max. Panel Length,Gris Régent/Regent Gray,PVDF CLASSIC,7602,,0.26,0.74,0.88,72.41,23.36,"22
26"
Norex L - Max. Panel Length,Bleu royal/Royal Blue,PVDF SIGNATURE,9935,,0.25,0.75,0.86,73.27,19.71,22
Norex L - Max. Panel Length,Gris Rigel /Grey Rigel,METALLIC,9789,,0.24,0.76,0.85,73.96,17.15,22
Norex L - Max. Panel Length,Bleu Héron/Heron Blue,SMP PREMIUM,28330,,0.23,0.77,0.87,74.08,18.2,22
Norex L - Max. Panel Length,Rouge Colonial/Colonial Red,PVDF SIGNATURE,5636,,0.2,0.8,0.86,75.75,12.96,22
Norex L - Max. Panel Length,Brun Foncé /Dark Brown,SMP PREMIUM,28229,,0.16,0.84,0.87,77.52,8.88,22
Norex L - Max. Panel Length,Noir/Black,METALLIC,28262,,0.07,0.93,0.84,82.6,-1,22
Norex L - Max. Panel Length,Couleur inconnue (STD.),,Mystère,???,0.05,0.95,0.81,84.29,-1,
```

### Norex M colour / surface-temperature data

```csv
sheet,color,finish,norbec_color_number,appearance,solar_reflectance_sr,solar_absorptance_alpha,emissivity,tsurface_max_c,sri,gage
Norex M - Max. Panel Length SRY,Blanc Horizon/Horizon White (Coastal),,10856,x,0.73,0.27,0.89,48.51,88.76,
Norex M - Max. Panel Length SRY,Blanc Régal/Regal White,PVDF CLASSIC,17-1651,,0.64,0.36,0.87,53.34,74.93,"22
26"
Norex M - Max. Panel Length SRY,Blanc Brillant/Bright White,SMP CLASSIC,28783,,0.64,0.36,0.86,53.44,74.34,"22
24
26"
Norex M - Max. Panel Length SRY,Blanc Impérial/Imperial White,METALLIC,,,0.58,0.42,0.86,56.55,65.71,26
Norex M - Max. Panel Length SRY,Electric Yellow,PVDF SIGNATURE,17-1661,,0.57,0.43,0.89,56.72,66.35,22
Norex M - Max. Panel Length SRY,Blanc Pur/White white,SMP CLASSIC,28317,,0.56,0.44,0.86,57.58,62.85,26
Norex M - Max. Panel Length SRY,Sable/Sandstone,PVDF CLASSIC,17-1629,,0.54,0.46,0.86,58.61,60.01,22
Norex M - Max. Panel Length SRY,Blanc os/Bone White,SMP CLASSIC,28273,,0.5,0.5,0.87,60.53,55.15,26
Norex M - Max. Panel Length SRY,Gris Pierre/Stone Grey,SMP CLASSIC,28305,,0.45,0.55,0.87,63.07,48.19,26
Norex M - Max. Panel Length SRY,Argent Brillant/Bright Silver perspectra,METALLIC,17-1627,,0.46,0.54,0.81,63.42,44.04,22
Norex M - Max. Panel Length SRY,Gris Élément/Element Grey,PVDF CLASSIC,10557,,0.44,0.56,0.87,63.57,46.8,22
Norex M - Max. Panel Length SRY,Riesling/Riesling,METALLIC,10437,,0.4,0.6,0.81,66.54,35.19,22
Norex M - Max. Panel Length SRY,Vibrant Red,SMP PREMIUM,17-1660,,0.38,0.62,0.87,66.6,38.53,22
Norex M - Max. Panel Length SRY,Beige Surrey,PVDF CLASSIC,17-9805,,0.35,0.65,0.87,68.1,34.43,22
Norex M - Max. Panel Length SRY,Fauve/Tan,SMP CLASSIC,28315,,0.34,0.66,0.87,68.6,33.06,24
Norex M - Max. Panel Length SRY,Pacific Turquoise,SMP PREMIUM,28258,,0.28,0.72,0.9,71.06,28.17,22
Norex M - Max. Panel Length SRY,Bleu Ardoise/Slate Blue,SMP PREMIUM,28260,,0.29,0.71,0.87,71.1,26.28,24
Norex M - Max. Panel Length SRY,Étain/Pewter perspectra,METALLIC,17-1626,,0.29,0.71,0.87,71.1,26.28,22
Norex M - Max. Panel Length SRY,Acier Satiné/Satin Steel,PVDF SIGNATURE,9742,,0.29,0.71,0.86,71.28,25.16,22
Norex M - Max. Panel Length SRY,Cuivre/Copper,METALLIC,10321,,0.35,0.65,0.69,71.4,10.96,22
Norex M - Max. Panel Length SRY,Fusain/Charcoal,PVDF CLASSIC,17-1625,,0.28,0.72,0.87,71.6,24.93,"22
26"
Norex M - Max. Panel Length SRY,Gris Tempête/Storm Grey,PVDF SIGNATURE,10032,,0.28,0.72,0.84,72.14,21.46,22
Norex M - Max. Panel Length SRY,Gris Régent/Regent Gray,PVDF CLASSIC,7602,,0.26,0.74,0.88,72.41,23.36,"22
26"
Norex M - Max. Panel Length SRY,Bleu royal/Royal Blue,PVDF SIGNATURE,9935,,0.25,0.75,0.86,73.27,19.71,22
Norex M - Max. Panel Length SRY,Gris Rigel /Grey Rigel,METALLIC,9789,,0.24,0.76,0.85,73.96,17.15,22
Norex M - Max. Panel Length SRY,Bleu Héron/Heron Blue,SMP PREMIUM,28330,,0.23,0.77,0.87,74.08,18.2,22
Norex M - Max. Panel Length SRY,Rouge Colonial/Colonial Red,PVDF SIGNATURE,5636,,0.2,0.8,0.86,75.75,12.96,22
Norex M - Max. Panel Length SRY,Brun Foncé /Dark Brown,SMP PREMIUM,28229,,0.16,0.84,0.87,77.52,8.88,22
Norex M - Max. Panel Length SRY,Noir/Black,METALLIC,28262,,0.07,0.93,0.84,82.6,-1,22
Norex M - Max. Panel Length SRY,Couleur inconnue (STD.),,Mystère,???,0.05,0.95,0.81,84.29,-1,
```
