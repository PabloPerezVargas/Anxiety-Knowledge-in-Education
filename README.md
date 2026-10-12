# Anxiety Knowledge in Education

This project examines psychological knowledge after psychoeducational workshops in educational settings in Spain, mainly in Galicia. The workshops introduce concepts relevant to everyday life.

The Anxiety workshop explores the links between situations, emotional and physical activation, thoughts, impulses, and behaviour. Participants learn concepts for understanding triggers and automatic responses, reflecting on their own thinking, describing difficulties, seeking support, and exploring coping and regulation strategies. The workshops aim to provide a foundation for developing practical skills.

## The historical archive

The archive contains **1,090 paired pre/post assessment records**: **531 Anxiety, 411 Decision-making, and 148 Risk**, collected across **11 educational centres** during the **2021/22, 2024/25, and 2025/26** academic years. It grew through routine workshop delivery; the original 2021/22 Anxiety study was smaller.

Participants answered the same eight open-ended questions before and immediately after each workshop. Each workshop used its own questions and scoring system. Assessed knowledge is the sum of the eight response scores. Perceived knowledge is a separate count, from 0 to 8, of how many questions participants believed they could answer.

**Central question:** How does assessed knowledge change immediately after the workshops, how do those changes vary across topics and cohorts, and what can the responses tell us about improving future assessments?

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

The project examines perceived knowledge, recall and recognition, application in context, and everyday behaviour. Recall and recognition are different ways of assessing knowledge; retention concerns whether learning lasts over time. The existing assessments capture perceived knowledge and immediate recall through open-ended responses. The [conceptual framework](docs/conceptual_framework.md) explains these research questions.

## Key findings

- Knowledge scores increased after all three workshops.
- Changes varied across topics and cohorts.
- Items generally related more closely to the rest of the assessment after the workshops.
- Anxiety score distributions and item relationships varied across school years.
- Risk showed the clearest evidence of a broad shared dimension; Anxiety and Decision-making showed a more mixed structure.
- The historical findings guide the development of future assessments.

## Track A — What the historical data show

Track A examines knowledge change and the performance of the existing assessments. The completed analysis moved from total scores to individual topics, cohort differences, item relationships, and dimensional structure. The analyses were conducted in R.

### Did assessed knowledge change?

Average knowledge scores increased immediately after each workshop: by **7.45 points in Anxiety, 6.74 in Decision-making, and 5.39 in Risk**.

The [pre/post figure](figures/prepost_change_by_workshop.png) shows score distributions and paired observations. Full estimates are in the [workshop table](tables/prepost_change_by_workshop.csv).

### Where did learning appear?

Changes varied across questions within each workshop. The [content learning map](figures/content_learning_map.png) shows which topics had larger or smaller gains and adds detail to the overall score changes.

### How did the historical items behave?

After the workshops, items generally related more closely to the remaining assessment score. Before the workshops, scores often clustered at the minimum, leaving little variation between participants. The [item-rest figure](figures/item_rest_correlations.png) shows this pattern.

Anxiety score distributions and item relationships also varied across cohorts. These patterns inform the review of historical wording, scoring, and administration.

### Is there one underlying dimension?

The exploratory post-workshop analyses differed by workshop. **Risk showed the clearest evidence of a broad shared dimension.** Anxiety from recent cohorts was more consistent with a single dimension than Anxiety pooled across years. Decision-making showed a more complex structure.

The [scree and parallel-analysis figure](figures/scree_parallel_analysis.png) presents these results.

## What the historical data taught us about measurement

The analyses identified several priorities for assessment design:

- Report knowledge by topic alongside total scores.
- Account for low baseline variation when interpreting item relationships.
- Address both workshop content coverage and internal consistency.
- Review weaker item relationships in relation to content, wording, scoring, response format, and cohort context.
- Document item versions, scoring rules, and administration to help interpret differences between cohorts.
- Explore alternative pre/post forms to reduce exact question repetition.

The [conceptual framework](docs/conceptual_framework.md) sets out the outcomes to assess. The [evidence-to-design table](docs/evidence_to_instrument_design.md) connects Track A findings to Track B decisions.

## Track B — Improving future measurement

Track B uses the historical findings to develop and pilot future assessments, starting with Anxiety. Development is at the planning stage.

Proposed developments include:

- **Multiple-choice items** to standardise scoring and assess recognition alongside open-ended recall, which also depends on verbal expression and scoring.
- **Item-level perceived-knowledge judgements**, collected before participants see response options, to examine how their judgements align with their answers.
- **Review of existing open responses** to identify misconceptions and develop incorrect answer options for multiple-choice items. This involves coding and reviewing a sample of responses.
- **Matched, counterbalanced A/B forms** to reduce exact question repetition and compare form performance in pilot data.
- **Short scenarios** to assess application in realistic situations.

The planned sequence is to define workshop objectives, map the content to be assessed, draft items, review their relevance and clarity, pilot them, and examine item performance and dimensional structure. Item sets, forms, scoring rules, and administration will be documented as development progresses.

The [instrument development guide](instrument/README.md) describes the plans for item review, piloting, form comparison, and further psychometric analysis. The [workshop content framework](docs/workshop_content_framework.md) summarises the three content areas.

## Data access and reproduction

Participant-level source data, original questionnaires, and scoring keys are private. Analysis scripts and aggregate outputs are public.

To reproduce the analyses, authorised access to the source data, R, and the required packages are needed. Run the scripts in order from the repository root:

```r
source("R/01_prepare_data.R")
source("R/03_descriptives.R")
source("R/04_prepost_analysis.R")
source("R/05_content_learning_map.R")
source("R/06_historical_item_diagnostic.R")
source("R/07_dimensional_exploration.R")
```

The preparation script builds and checks the analysis dataset. The remaining scripts generate aggregate tables and figures.

## Further reading

- [Conceptual framework](docs/conceptual_framework.md): research outcomes and assessment formats.
- [Evidence to instrument design](docs/evidence_to_instrument_design.md): how Track A findings guide Track B.
- [Workshop content framework](docs/workshop_content_framework.md): the three content areas.
- [Roadmap](ROADMAP.md): completed analyses and next steps.
- [Methodology](docs/methodology.md): study design and measurement.
- [Data dictionary](docs/data_dictionary.md): variables and data structure.
- [Limitations and future work](docs/limitations_and_future_work.md): study scope and future research.

The original workshop and questionnaire framework was developed by **Brais Moldes Peña**. This repository covers secondary analysis, assessment evaluation, and future instrument development.
