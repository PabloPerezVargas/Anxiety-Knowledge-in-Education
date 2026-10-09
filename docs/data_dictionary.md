# Data dictionary

Documentation for the analytical dataset built by [`R/01_prepare_data.R`](../R/01_prepare_data.R).

> **Status — PRIVATE.** The object `data/private/analysis_data.rds` contains
> participant-level records and is excluded from version control. It is not a
> public release. No anonymised or public dataset has been produced yet.

## Provenance and origin of the instrument

The questionnaire and psychoeducational workshop framework used in this project
originated in earlier research and development work by **Brais Moldes Peña**,
which established the workshop objectives, the eight-item structure, and the
key-concept scoring approach.

Those original materials are private reference documents. **No item wording and
no scoring-key wording is reproduced anywhere in this repository.** This
dictionary describes only the *conceptual domain* each item addresses, which is
sufficient to interpret results without redistributing the instrument.

Later versions of the workshop content were revised and restructured, and the
current research framework states clearer academic objectives than the earliest
implementations. Item numbering below refers to the **current** eight-item
structure.

## Two distinct measures

The dataset contains **two conceptually different measures**, on **two different
metrics**. They must not be combined or rescaled onto a shared range.

| | Objective knowledge | Perceived knowledge |
|---|---|---|
| Variables | `conocimiento_total_pre/post` | `conocimiento_percibido_pre/post` |
| Derived from | sum of the 8 scored items | historical total columns in the source file |
| Observed range | pre 0–13.5, post 0–36 | pre 0–8, post 0–8 |
| Construct | what the participant can correctly recall | the **number of the eight questions the participant believed they could answer** |

The source file names the perceived measure `conoc_tot_pre` / `conoc_tot_post`.
Those names are misleading — `conoc_` suggests objective knowledge and `tot_`
suggests a total. The variable is neither. It is a **perceived-knowledge count**:
the participant's own estimate of how many of the questionnaire's eight items
they could answer. It is a self-report of confidence, not a measure of actual
knowledge, and it must not be labelled "Seguridad" or presented as an
achievement score.

The pipeline renames it on read to prevent misreading. **The underlying values
are preserved exactly** and are never rescaled.

## Perceived knowledge across school years

`conocimiento_percibido_pre/post` use the same **eight-question** scale in
every school year (21/22, 24/25 and 25/26), with a range of 0–8 in all of
them. Raw perceived-knowledge scores are therefore directly comparable
across cohorts, with no rescaling or special treatment of any cohort.

### Workshop × school-year nesting

An unrelated structural feature of the data remains: the 21/22 cohort
(n = 132) contains only the anxiety workshop, and all three workshops were
delivered only in the 25/26 cohort (n = 731). Workshop and school year are
confounded, so between-workshop comparisons should draw on the 25/26 cohort.

## Variables

### Participant and context variables

| Variable | Type | Origin | Meaning |
|---|---|---|---|
| `sexo` | factor (2) | Direct | Self-reported sex, as recorded in the questionnaire. Stored as a factor; no numeric recode is provided. |
| `edad` | numeric | Direct | Age in years at the time of the workshop. **Retained deliberately** for subgroup analysis (e.g. participants aged 17 or over). |
| `taller` | factor (3) | Direct | Workshop attended: `Ansiedad`, `Decisiones`, `Riesgo`. |
| `curso` | character | Direct | Class group within the centre (e.g. year group and section). |
| `centro` | character | Direct | Educational centre. **Directly identifying — to be pseudonymised before any public release.** |
| `anio` | character | Direct | School year of data collection (renamed from `Año`). |

### Perceived knowledge

| Variable | Type | Origin | Meaning |
|---|---|---|---|
| `conocimiento_percibido_pre` | numeric | Direct | Number of the questionnaire's eight items the participant believed they could answer, before the workshop. Renamed from `conoc_tot_pre`. Range 0–8. |
| `conocimiento_percibido_post` | numeric | Direct | Same eight-question measure after the workshop. Renamed from `conoc_tot_post`. Range 0–8. |
| `cambio_conocimiento_percibido` | numeric | Derived | `conocimiento_percibido_post − conocimiento_percibido_pre`. |

The perceived-knowledge scale is uniform (eight questions, 0–8) in every
school year; see the section above.

### Scored knowledge items

Sixteen variables, one per item per measurement moment:
`pregunta1pre` … `pregunta8pre` and `pregunta1post` … `pregunta8post`.

Numeric. Half-point values are present, so the variables are **numeric, not
integer**. Items are scored in half-points in the post-test data; the observed
pre-test ceiling is lower than the post-test ceiling, so the two moments are not
on an identical realised range.

**The same item numbers refer to different content in each workshop.** Because
the three workshops were designed independently, `pregunta3pre` in the anxiety
workshop does not assess the same domain as `pregunta3pre` in the risk
workshop. Any cross-workshop item-level comparison must account for this.

Conceptual domains only, per workshop, as set out in the project documentation:

| Item | Ansiedad | Decisiones | Riesgo |
|---|---|---|---|
| 1 | Anxiety conceptualisation | Decision-making and problem solving | Anxiety-state concepts |
| 2 | Components and process of the anxiety response | Cold (rational) cognitive processes | Factors associated with self-harm and suicidal behaviour |
| 3 | Learning and consolidation processes | Hot (emotional) processes | Homeostasis and habituation |
| 4 | Metacognition | Planning and the context of decisions | Metacognition |
| 5 | Verbalisation and support processes | Impulsivity | Impulsivity, anxiety and risk |
| 6 | Relaxation and regulation methods | Skills associated with effective decision-making | Crisis regulation methods |
| 7 | Long-term prevention and regulation | Information organisation | Long-term prevention and protective processes |
| 8 | Integration of knowledge into practical advice | Integration of knowledge into practical advice | Integration of knowledge into practical advice |

Item 8 addresses knowledge integration in all three workshops.

This table records **domains, not items**. It does not restate the questions,
the answer options, or the scoring key.

### Derived knowledge totals

| Variable | Type | Origin | Meaning |
|---|---|---|---|
| `conocimiento_total_pre` | numeric | Derived | `pregunta1pre` + … + `pregunta8pre`. Objective knowledge before the workshop. |
| `conocimiento_total_post` | numeric | Derived | `pregunta1post` + … + `pregunta8post`. Objective knowledge after the workshop. |
| `cambio_conocimiento` | numeric | Derived | `conocimiento_total_post − conocimiento_total_pre`. |

These totals are **not rescaled** and **not comparable** with
`conocimiento_percibido_pre/post`.

## Validation guarantees

`R/01_prepare_data.R` aborts on the first failure if any of the following does
not hold, so a saved dataset always satisfies them:

- the source file has exactly 24 columns with the expected schema
- exactly 1090 observations are read, and **none is removed**
- workshop counts are Ansiedad 531, Decisiones 411, Riesgo 148
- there are exactly 11 educational centres
- no missing values in the 24 original variables
- each knowledge total equals the exact row sum of its eight items
- `conocimiento_percibido_pre/post` preserve the original `conoc_tot_pre/post`
  values exactly
- every perceived-knowledge score lies within 0–8, and no perceived score
  equals 9

**Deduplication is deliberately disabled.** The dataset contains one pair of
fully identical records. These correspond to two different participants and are
retained, giving a working N of 1090.

## Known data characteristics

- **Complete data.** All 1090 records are complete across all 24 variables.
- **Age range 14–73.** The sample includes a substantial adolescent core
  (median 16) alongside a smaller adult group, including parent groups and
  adult education. Age should be generalised or banded in any public release.
- **Category counts.** 11 centres, 27 course groups, 3 school years
  (21/22, 24/25, 25/26). Some centre × course combinations are very small,
  which matters for disclosure control.
- **Workshop and school year are confounded.** The 21/22 cohort is
  anxiety-only; the decision-making and risk workshops were never
  administered in that cohort and appear only in later years. Between-workshop
  comparisons should draw on the 25/26 cohort, the only one containing all
  three workshops.
- **Categories are preserved as recorded.** Only surrounding whitespace is
  removed. No category has been merged, recoded or collapsed.