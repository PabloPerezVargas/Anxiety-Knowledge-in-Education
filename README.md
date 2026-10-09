# Anxiety Knowledge in Education

## Why this programme exists

This project examines a real-world psychoeducational programme delivered
across educational settings in Spain, primarily in Galicia. The workshops
provide participants with an initial structured contact with psychological
knowledge relevant to everyday situations. In the Anxiety workshop, the
conceptual pathway runs from a situation or cue through emotional and
physiological activation, thoughts and impulses, and behavioural responses.
The programme aims to help participants recognise activation, consider what
may trigger it, reflect before responding automatically, and become aware of
regulation, coping, verbalisation, support, and metacognitive strategies.

This is the programme’s rationale, not an outcome demonstrated here. The
workshops provide an initial conceptual framework; they do not treat anxiety
disorders. The historical assessments measure immediate declarative and
conceptual knowledge. They do not demonstrate behaviour change, improved
coping, clinical prevention, reduced anxiety disorders, or long-term retention.
The programme proposed that declarative knowledge might later facilitate
procedural skills, but this dataset does not test that possibility.

## The historical archive

The accumulated archive contains **1,090 real-world PRE/POST records**: 531
Anxiety, 411 Decision-making, and 148 Risk records from the 2021/22, 2024/25,
and 2025/26 academic years across 11 educational centres. The archive grew as
workshops were delivered; the original 2021/22 Anxiety study was smaller. This
is not a simulated or laboratory dataset, and it is not intended to represent
participants across Spain or Galicia.

Each workshop used its own eight-question open-response instrument. Their
items and scores are workshop-specific, not a common scale. Perceived
knowledge is recorded separately as a 0–8 count. Anxiety item scoring and
comparability across cohorts remain uncertain.

**Central question:** What knowledge appears to be acquired immediately after
these workshops, how consistently is that learning observed across contents
and cohorts, and what can the historical measurement system teach us about
designing better future assessments?

## Key findings

- 1,090 real-world PRE/POST records across three psychoeducational workshops.
- Assessed knowledge increased substantially immediately after all three
  workshops.
- Learning varied across contents and cohorts.
- POST item relationships were generally more coherent than PRE relationships.
- Risk showed the clearest evidence of a broad general POST dimension, while
  Anxiety and Decision-making showed greater structural uncertainty.
- Historical results provide useful evidence for measurement redesign, not
  automatic retention or deletion of historical items.

## Track A — What the historical data show

The analysis follows a sequence of questions: **overall learning →
content-specific learning → cohort consistency → historical item behaviour →
dimensional structure**. Track A aims both to understand what happened in the
historical workshops and to diagnose what their instruments can and cannot
measure well.

### Did assessed knowledge change?

Average objective scores increased immediately after each workshop: by **7.45
points in Anxiety, 6.74 in Decision-making, and 5.39 in Risk**. These are
workshop-specific score units, not between-workshop comparisons. The [PRE/POST
figure](figures/prepost_change_by_workshop.png) shows the distributions and
individual paired observations; estimates are in the
[workshop table](tables/prepost_change_by_workshop.csv).

The same questions were used PRE and POST. Familiarity or pretest sensitisation
may therefore contribute to change, and no untreated or control comparison
isolates a causal workshop effect.

### Where did learning appear?

Large overall changes leave a further question: were they spread evenly across
the assessed content? The [content learning map](figures/content_learning_map.png)
shows that change varied across items within each workshop. This item-level
heterogeneity motivates closer attention to what the historical assessments
captured, rather than treating a total as a complete account of learning.

### How did the historical items behave?

POST item relationships with the rest of their workshop’s scores were
**generally more coherent than PRE**, where responses often clustered at the
observed minimum. The [item-rest figure](figures/item_rest_correlations.png)
shows this contrast. Anxiety item relationships and score distributions varied
across cohorts; available records do not establish that wording, scoring, and
administration were fully comparable in every year. These cohort patterns are
descriptive and do not establish why results differed.

### Is there one underlying dimension?

Exploratory POST analyses gave different pictures by workshop. **Risk showed
the clearest support for a broad general dimension.** Recent-cohort Anxiety was
more compatible with one general dimension than pooled Anxiety, while
Decision-making showed evidence of additional or heterogeneous structure.
These analyses do not validate a single latent scale. Historical totals remain
useful descriptive summaries, but the evidence does not establish all three
instruments as validated unidimensional psychometric scales. See the [scree
and parallel-analysis figure](figures/scree_parallel_analysis.png) for the
exploratory results.

## Track B — Improving future measurement

Track A diagnoses what the historical workshop data and instruments can—and
cannot—show. Its findings generate hypotheses for the ongoing development of
new, workshop-specific knowledge instruments, beginning with Anxiety. The
planned sequence is workshop objectives → content blueprint → standardised
candidate items → content review → pilot testing → classical item analysis →
dimensional evaluation. Advanced psychometric work would be considered only if
later evidence and research questions justify it.

Future instruments are intended to reduce dependence on open-response keyword
scoring while retaining clear coverage of workshop content. No new candidate
items or A/B forms currently exist. Historical results can inform their design,
but cannot establish how new items, distractors, or forms will perform. See the
[instrument development guide](instrument/README.md) for current status.

## Data access and reproduction

The participant-level source data are restricted for privacy. Analysis scripts
and aggregate outputs are public, but a fresh public clone cannot fully rerun
the analyses without authorised access to the source data.

With R and the required packages installed, run the scripts in order from the
repository root:

```r
source("R/01_prepare_data.R")
source("R/03_descriptives.R")
source("R/04_prepost_analysis.R")
source("R/05_content_learning_map.R")
source("R/06_historical_item_diagnostic.R")
source("R/07_dimensional_exploration.R")
```

The preparation step creates the analysis dataset and performs basic checks.
The remaining scripts generate aggregate tables and figures. Full rerunning
requires authorised access to the restricted source data.

## Project documents

- [Roadmap](ROADMAP.md): completed historical evaluation and next work.
- [Methodology](docs/methodology.md): design and measurement decisions.
- [Data dictionary](docs/data_dictionary.md): variables and data structure.
- [Limitations and future work](docs/limitations_and_future_work.md): interpretation boundaries.

The workshop and questionnaire framework were originally developed by Brais
Moldes Peña. The original instruments, scoring keys, and participant responses
are not published in this repository, which focuses on secondary analysis,
measurement evaluation, and future psychometric development.
