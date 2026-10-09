# Anxiety Knowledge in Education

## Why this programme exists

This project studies a real-world psychoeducational programme delivered
across educational settings in Spain, primarily in Galicia. The workshops offer
participants an initial structured encounter with psychological knowledge for
everyday life. For Anxiety, the programme frames a broad pathway from a
situation or cue through emotional and physiological activation, thoughts and
impulses, to behavioural responses. Recognising parts of this process may give
participants concepts with which to reflect on triggers, automatic responses,
regulation, coping, verbalisation, support, and metacognitive strategies.

This is the programme’s rationale, not an outcome established by this dataset.
The workshops do not treat anxiety disorders. The historical assessments
measure immediate declarative and conceptual knowledge; they do not demonstrate
behaviour change, improved coping, clinical prevention, or long-term retention.
The idea that declarative knowledge may later facilitate procedural skills is
a theoretical proposition, not a tested result here. See the [conceptual
framework](docs/conceptual_framework.md) for how these possible outcomes relate.

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

## What does “learning” mean here?

```text
Metacognitive judgement       “Do I think I know this?”
          ↕ calibration
Knowledge performance         “Can I recall or recognise it?”
          ↓
Applied reasoning             “Can I use it in context?”
          ↓
Real-world behaviour          “Does it affect what I do?”

Across time: Does any of this persist?
```

The project therefore separates what participants think they know, what they
can retrieve or recognise, what they can apply in context, and what they
ultimately do. Recall and recognition are different ways of observing knowledge,
not sequential stages. Application and real-world behaviour are further
outcomes; retention is a separate question over time. The historical archive
mainly captures aggregate perceived knowledge and immediate open-response
knowledge performance. See the [conceptual framework](docs/conceptual_framework.md).

## Key findings

- 1,090 real-world PRE/POST records across three psychoeducational workshops.
- Assessed knowledge increased substantially immediately after all three
  workshops.
- Learning varied across contents and cohorts.
- POST item relationships were generally more coherent than PRE relationships;
  cohort variation matters particularly for Anxiety.
- Dimensional evidence differs by workshop. Risk showed the clearest support for
  a broad POST dimension; Anxiety and Decision-making showed greater structural
  uncertainty.
- Historical results inform measurement redesign, not automatic retention or
  deletion of historical items.

## Track A — What the historical data show

Track A asks what happened in the workshops and what the historical instruments
can measure well. Its sequence moved from overall learning to content-specific
learning, cohort consistency, item behaviour, and dimensional structure.

### Did assessed knowledge change?

Average objective scores increased immediately after each workshop: by **7.45
points in Anxiety, 6.74 in Decision-making, and 5.39 in Risk**. These are
workshop-specific score units, not between-workshop comparisons. The [PRE/POST
figure](figures/prepost_change_by_workshop.png) shows the distributions and
individual paired observations; estimates are in the
[workshop table](tables/prepost_change_by_workshop.csv).

The same questions were used PRE and POST, so familiarity or pretest
sensitisation may contribute to observed change. There was no untreated/control
comparison, and immediate POST does not establish retention or behaviour change.
The [limitations](docs/limitations_and_future_work.md) summarise these boundaries.

### Where did learning appear?

Large overall changes raised a further question: was learning distributed
evenly across the assessed content? The [content learning
map](figures/content_learning_map.png) shows that change varied across items
within each workshop. A total score alone cannot show which concepts changed.

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

## What the historical data taught us about measurement

The accumulated evidence raised measurement questions beyond the size of the
total-score change:

- Total gains conceal substantial differences across the content areas
  assessed.
- Strong PRE concentration at observed minimums can restrict score variation;
  weak PRE item relationships do not by themselves show poor item quality.
- More coherent POST relationships are interesting, but do not validate one
  underlying scale. Broad content coverage may be educationally important even
  when it does not maximise internal consistency.
- Historical items with low item-rest relationships need diagnosis, not
  automatic deletion. Content, scoring, response format, range restriction, and
  cohort context may all matter.
- Anxiety’s cohort-sensitive structure shows why item versions, scoring, and
  administration should be documented over time.
- Repeating PRE/POST items may contribute familiarity or pretest sensitisation
  to observed gains.

The [conceptual framework](docs/conceptual_framework.md) explains why perceived
knowledge, recall, recognition, application, and behaviour are related but
distinct outcomes. The [evidence-to-design table](docs/evidence_to_instrument_design.md)
connects Track A observations to future measurement questions.

## Track B — Improving future measurement

Track A is not separate from instrument development: its findings generate
hypotheses for ongoing work, beginning with Anxiety. Each design choice
responds to a measurement question raised by the historical evidence:

- Open-response recall depends partly on verbal production and scoring;
  standardised recognition items may complement it where appropriate, without
  replacing explicit content coverage.
- The historical archive has only aggregate perceived knowledge; future
  item-level perceived judgements, collected before response options, could
  support metacognitive calibration.
- Historical open responses may contain misconceptions that could inform
  plausible distractors, but coding a sample has not yet been done.
- Same-item PRE/POST raises a repetition concern; matched, counterbalanced A/B
  forms are a possible future design, but no forms exist or have demonstrated
  equivalence.
- Historical assessments primarily capture conceptual knowledge; vignettes
  could examine application separately, not as a proxy for real-life behaviour.

The planned sequence is workshop objectives → content blueprint → standardised
candidate items → content review → pilot testing → classical item analysis →
dimensional evaluation. Versioning and scoring documentation will help
interpret future cohorts. IRT, DIF, equating, anchors, and item banking are
conditional later options, only if the construct, data, and research question
justify them. No new candidate items or A/B forms currently exist; historical
results cannot establish how new items, distractors, or forms will perform. See
the [instrument development guide](instrument/README.md) and [workshop content
framework](docs/workshop_content_framework.md) for current status and broad
content descriptions.

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

## Further reading

- [Conceptual framework](docs/conceptual_framework.md): the continuum from
  perceived knowledge to behaviour.
- [Evidence to instrument design](docs/evidence_to_instrument_design.md): how
  Track A results motivate Track B questions.
- [Workshop content framework](docs/workshop_content_framework.md): public
  descriptions of the three content areas.
- [Roadmap](ROADMAP.md): completed historical evaluation and next work.
- [Methodology](docs/methodology.md): design and measurement decisions.
- [Data dictionary](docs/data_dictionary.md): variables and data structure.
- [Limitations and future work](docs/limitations_and_future_work.md): interpretation boundaries.

The workshop and questionnaire framework were originally developed by Brais
Moldes Peña. The original instruments, scoring keys, and participant responses
are not published in this repository, which focuses on secondary analysis,
measurement evaluation, and future psychometric development.
