library(dplyr)
library(tidyr)
library(ggplot2)
library(purrr)
library(readr)

datos <- readRDS("data/private/analysis_data.rds")
workshops <- levels(datos$taller)

centre_key <- tibble(
  centro = sort(unique(datos$centro), method = "radix"),
  centre = sprintf("Centro_%02d", seq_along(sort(unique(datos$centro), method = "radix")))
)
datos <- datos %>%
  left_join(centre_key, by = "centro") %>%
  mutate(age_group = if_else(edad <= 18, "14-18", "19+"))

# Describe sample composition; named centres and small categories remain diagnostic.
count_table <- function(data, dimension, variable, group = character(), minimum_n = 10) {
  counts <- data %>%
    count(across(all_of(c(group, variable))), name = "n")

  counts$grouping <- if (length(group)) {
    apply(as.data.frame(lapply(counts[group], as.character)), 1, paste, collapse = "; ")
  } else {
    "All participants"
  }
  counts$category <- as.character(counts[[variable]])

  counts %>%
    group_by(grouping) %>%
    mutate(percent = 100 * n / sum(n)) %>%
    ungroup() %>%
    filter(n >= minimum_n) %>%
    transmute(dimension = dimension, grouping, category, n, percent)
}

sample_counts <- bind_rows(
  count_table(datos, "Workshop", "taller"),
  count_table(datos, "Year", "anio"),
  count_table(datos, "Year within workshop", "anio", "taller"),
  count_table(datos, "Centre within workshop", "centre", "taller"),
  count_table(datos, "Sex", "sexo"),
  count_table(datos, "Sex within workshop", "sexo", "taller"),
  count_table(datos, "Age group within workshop", "age_group", "taller"),
  count_table(datos, "Course within workshop", "curso", "taller")
)

age_summary <- bind_rows(
  datos %>%
    summarise(n = n(), age_mean = mean(edad), age_sd = sd(edad),
              age_median = median(edad), age_IQR = IQR(edad),
              age_min = min(edad), age_max = max(edad)) %>%
    mutate(dimension = "Age summary", grouping = "All participants", category = "Age"),
  datos %>%
    group_by(taller) %>%
    summarise(n = n(), age_mean = mean(edad), age_sd = sd(edad),
              age_median = median(edad), age_IQR = IQR(edad),
              age_min = min(edad), age_max = max(edad), .groups = "drop") %>%
    mutate(dimension = "Age summary", grouping = paste0("Workshop=", taller), category = "Age")
) %>%
  mutate(percent = 100) %>%
  select(dimension, grouping, category, n, percent,
         age_mean, age_sd, age_median, age_IQR, age_min, age_max)

sample_descriptives <- sample_counts %>%
  mutate(age_mean = NA_real_, age_sd = NA_real_, age_median = NA_real_,
         age_IQR = NA_real_, age_min = NA_real_, age_max = NA_real_) %>%
  bind_rows(age_summary) %>%
  arrange(dimension, grouping, category)

# Describe scores separately within each workshop and instrument.
score_variables <- c(
  "conocimiento_total_pre", "conocimiento_total_post", "cambio_conocimiento",
  "conocimiento_percibido_pre", "conocimiento_percibido_post",
  "cambio_conocimiento_percibido"
)
score_descriptives <- datos %>%
  select(taller, all_of(score_variables)) %>%
  pivot_longer(-taller, names_to = "measure", values_to = "score") %>%
  group_by(workshop = taller, measure) %>%
  summarise(
    n = sum(!is.na(score)), mean = mean(score), sd = sd(score),
    median = median(score), IQR = IQR(score), min = min(score), max = max(score),
    .groups = "drop"
  )

# Describe each item at each occasion within its own workshop.
item_long <- datos %>%
  mutate(participant = row_number()) %>%
  select(participant, taller, starts_with("pregunta")) %>%
  pivot_longer(
    starts_with("pregunta"), names_to = c("item", "moment"),
    names_pattern = "pregunta(\\d+)(pre|post)", values_to = "score"
  ) %>%
  mutate(item = as.integer(item))

item_summary <- item_long %>%
  group_by(workshop = taller, item, moment) %>%
  summarise(
    n = n(), mean = mean(score), sd = sd(score), median = median(score),
    IQR = IQR(score), min = min(score), max = max(score),
    prop_at_observed_min = mean(score == min(score)),
    prop_at_observed_max = mean(score == max(score)),
    .groups = "drop"
  ) %>%
  pivot_wider(
    names_from = moment,
    values_from = c(n, mean, sd, median, IQR, min, max,
                    prop_at_observed_min, prop_at_observed_max),
    names_glue = "{moment}_{.value}"
  )

item_change <- item_long %>%
  select(participant, taller, item, moment, score) %>%
  pivot_wider(names_from = moment, values_from = score) %>%
  group_by(workshop = taller, item) %>%
  summarise(mean_pre_post_change = mean(post - pre), .groups = "drop")

item_descriptives <- left_join(item_summary, item_change, by = c("workshop", "item"))

# Explore associations between objective and perceived knowledge within each workshop.
correlation_specs <- tribble(
  ~comparison, ~x, ~y,
  "Objective pre vs perceived pre", "conocimiento_total_pre", "conocimiento_percibido_pre",
  "Objective post vs perceived post", "conocimiento_total_post", "conocimiento_percibido_post",
  "Objective change vs perceived change", "cambio_conocimiento", "cambio_conocimiento_percibido"
)

correlations <- map_dfr(workshops, function(workshop) {
  subset <- filter(datos, taller == workshop)
  map_dfr(seq_len(nrow(correlation_specs)), function(i) {
    x <- subset[[correlation_specs$x[i]]]
    y <- subset[[correlation_specs$y[i]]]
    tibble(
      workshop = workshop, comparison = correlation_specs$comparison[i], n = length(x),
      pearson_r = cor(x, y, method = "pearson"),
      spearman_rho = cor(x, y, method = "spearman")
    )
  })
})

scatter_data <- map_dfr(seq_len(nrow(correlation_specs)), function(i) {
  datos %>%
    transmute(
      workshop = taller,
      comparison = correlation_specs$comparison[i],
      objective_or_change = .data[[correlation_specs$x[i]]],
      perceived_or_change = .data[[correlation_specs$y[i]]]
    )
})

# Keep sample composition as a private diagnostic, not a public release table.
dir.create("tables", showWarnings = FALSE)
dir.create("figures", showWarnings = FALSE)
write_csv(sample_descriptives, "tables/sample_descriptives.csv")
write_csv(score_descriptives, "tables/score_descriptives_by_workshop.csv")
write_csv(item_descriptives, "tables/item_descriptives_by_workshop.csv")
write_csv(correlations, "tables/perceived_objective_correlations.csv")

ggsave(
  "figures/perceived_prepost_distributions.png",
  datos %>%
    select(taller, conocimiento_percibido_pre, conocimiento_percibido_post) %>%
    pivot_longer(-taller, names_to = "moment", values_to = "value") %>%
    ggplot(aes(value, fill = moment)) +
    geom_histogram(binwidth = 1, boundary = -0.5, position = "identity",
                   alpha = 0.45, colour = "white") +
    facet_wrap(~taller, scales = "free_y") +
    scale_x_continuous(breaks = 0:8) +
    labs(x = "Perceived-knowledge count (0–8)", y = "Participants",
         fill = "Assessment") +
    theme_minimal(),
  width = 9, height = 5, dpi = 160, bg = "white"
)

ggsave(
  "figures/perceived_objective_relationships.png",
  ggplot(scatter_data, aes(objective_or_change, perceived_or_change)) +
    geom_count(alpha = 0.65) +
    facet_grid(comparison ~ workshop, scales = "free") +
    labs(x = "Objective score or change", y = "Perceived score or change") +
    theme_minimal(),
  width = 10, height = 8, dpi = 160, bg = "white"
)
