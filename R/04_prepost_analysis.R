library(dplyr)
library(tidyr)
library(ggplot2)
library(purrr)
library(readr)

datos <- readRDS("data/private/analysis_data.rds")
workshops <- levels(datos$taller)

datos <- datos %>%
  mutate(
    workshop = as.character(taller),
    change = conocimiento_total_post - conocimiento_total_pre,
    perceived_change = conocimiento_percibido_post - conocimiento_percibido_pre,
    improvement = case_when(
      change > 0 ~ "Improved",
      change < 0 ~ "Decreased",
      TRUE ~ "Unchanged"
    ),
    age_group = if_else(edad <= 18, "14-18", "19+")
  )

stopifnot(all.equal(datos$change, datos$cambio_conocimiento))
set.seed(20261008)

# Resampling individual change retains the PRE/POST pair; these estimates do not account for centre clustering.
bootstrap_change <- function(change, n_boot = 5000, include_dz = FALSE) {
  draws <- replicate(n_boot, {
    sample_change <- sample(change, length(change), replace = TRUE)
    if (include_dz) {
      c(mean = mean(sample_change), dz = mean(sample_change) / sd(sample_change))
    } else {
      mean(sample_change)
    }
  })
  result <- tibble(
    bootstrap_mean_low = quantile(
      if (include_dz) draws["mean", ] else draws, 0.025
    ),
    bootstrap_mean_high = quantile(
      if (include_dz) draws["mean", ] else draws, 0.975
    )
  )
  if (include_dz) {
    result <- result %>% mutate(
      dz_bootstrap_low = quantile(draws["dz", ], 0.025),
      dz_bootstrap_high = quantile(draws["dz", ], 0.975)
    )
  }
  result
}

# Summarise paired change within a workshop, and then within each observed year.
summarise_change <- function(data, paired_tests = FALSE, include_dz = FALSE) {
  change <- data$change
  n <- length(change)
  ci <- mean(change) + c(-1, 1) * qt(0.975, df = n - 1) * sd(change) / sqrt(n)
  pattern <- prop.table(table(factor(
    data$improvement, levels = c("Improved", "Unchanged", "Decreased")
  ))) * 100

  result <- tibble(
    n = n,
    pre_mean = mean(data$conocimiento_total_pre),
    pre_sd = sd(data$conocimiento_total_pre),
    post_mean = mean(data$conocimiento_total_post),
    post_sd = sd(data$conocimiento_total_post),
    mean_change = mean(change),
    sd_change = sd(change),
    mean_change_ci_low = ci[1],
    mean_change_ci_high = ci[2],
    median_change = median(change),
    iqr_change = IQR(change),
    change_min = min(change),
    change_max = max(change),
    change_p10 = quantile(change, 0.10),
    change_p25 = quantile(change, 0.25),
    change_p75 = quantile(change, 0.75),
    change_p90 = quantile(change, 0.90),
    cohen_dz = mean(change) / sd(change),
    improved_percent = unname(pattern["Improved"]),
    unchanged_percent = unname(pattern["Unchanged"]),
    decreased_percent = unname(pattern["Decreased"]),
    median_improvement = if (any(change > 0)) median(change[change > 0]) else NA_real_,
    median_decrease = if (any(change < 0)) median(change[change < 0]) else NA_real_
  ) %>%
    bind_cols(bootstrap_change(change, include_dz = include_dz))

  if (paired_tests) {
    t_test <- t.test(change, mu = 0)
    wilcox <- suppressWarnings(wilcox.test(change, mu = 0, exact = FALSE))
    result <- result %>%
      mutate(
        paired_t = unname(t_test$statistic),
        paired_t_df = unname(t_test$parameter),
        paired_t_p = t_test$p.value,
        wilcoxon_V = unname(wilcox$statistic),
        wilcoxon_p = wilcox$p.value
      )
  }
  result
}

objective_summary <- map_dfr(workshops, function(w) {
  filter(datos, workshop == w) %>%
    summarise_change(paired_tests = TRUE, include_dz = TRUE) %>%
    mutate(workshop = w, .before = 1)
})

year_summary <- datos %>%
  group_by(workshop, year = anio) %>%
  group_modify(~ summarise_change(.x)) %>%
  ungroup()

# Describe perceived knowledge separately from the objective score.
perceived_summary <- map_dfr(workshops, function(w) {
  subset <- filter(datos, workshop == w)
  change <- subset$perceived_change
  pattern <- prop.table(table(factor(
    if_else(change > 0, "Improved", if_else(change < 0, "Decreased", "Unchanged")),
    levels = c("Improved", "Unchanged", "Decreased")
  ))) * 100

  tibble(
    workshop = w, n = nrow(subset),
    pre_mean = mean(subset$conocimiento_percibido_pre),
    pre_median = median(subset$conocimiento_percibido_pre),
    post_mean = mean(subset$conocimiento_percibido_post),
    post_median = median(subset$conocimiento_percibido_post),
    mean_change = mean(change), median_change = median(change),
    sd_change = sd(change), iqr_change = IQR(change),
    improved_percent = unname(pattern["Improved"]),
    unchanged_percent = unname(pattern["Unchanged"]),
    decreased_percent = unname(pattern["Decreased"])
  ) %>%
    bind_cols(bootstrap_change(change))
})

# Use the same deterministic centre codes in all diagnostic tables.
centre_key <- tibble(
  centro = sort(unique(datos$centro), method = "radix"),
  centre = sprintf("Centro_%02d", seq_along(sort(unique(datos$centro), method = "radix")))
)
datos <- datos %>% left_join(centre_key, by = "centro")

centre_summary <- datos %>%
  group_by(workshop, centre) %>%
  summarise(
    n = n(), mean_change = mean(change), median_change = median(change),
    sd_change = sd(change), improved_percent = 100 * mean(change > 0),
    years_represented = paste(sort(unique(anio)), collapse = "; "),
    .groups = "drop"
  ) %>%
  filter(n >= 20)

# Summarise context groups with enough observations for a stable diagnostic.
context_summary <- function(data, variable, label) {
  data %>%
      group_by(workshop, category = .data[[variable]]) %>%
    summarise(
      n = n(), mean_change = mean(change), sd_change = sd(change),
      median_change = median(change), iqr_change = IQR(change),
      improved_percent = 100 * mean(change > 0),
      unchanged_percent = 100 * mean(change == 0),
      decreased_percent = 100 * mean(change < 0),
      .groups = "drop"
    ) %>%
    filter(n >= 20) %>%
    mutate(context = label, .before = 2)
}

context_summary_table <- bind_rows(
  context_summary(datos, "sexo", "Sex"),
  context_summary(datos, "age_group", "Age group"),
  context_summary(datos, "curso", "Course / grade"),
  context_summary(datos, "anio", "Year"),
  context_summary(datos, "centre", "Centre")
)

# Correlations describe associations, not calibration or reliability.
correlation_specs <- tribble(
  ~relationship, ~x, ~y,
  "Baseline objective vs objective change", "conocimiento_total_pre", "change",
  "PRE objective vs POST objective", "conocimiento_total_pre", "conocimiento_total_post",
  "Objective change vs perceived change", "change", "perceived_change"
)

correlation_summary <- map_dfr(workshops, function(w) {
  subset <- filter(datos, workshop == w)
  map_dfr(seq_len(nrow(correlation_specs)), function(i) {
    x <- subset[[correlation_specs$x[i]]]
    y <- subset[[correlation_specs$y[i]]]
    tibble(
      workshop = w, relationship = correlation_specs$relationship[i], n = length(x),
      pearson_r = cor(x, y, method = "pearson"),
      spearman_rho = cor(x, y, method = "spearman")
    )
  })
})

# Keep extreme-change review aggregate; no participant rows are exported.
extreme_summary <- map_dfr(workshops, function(w) {
  subset <- filter(datos, workshop == w)
  map_dfr(c("Largest positive", "Largest negative"), function(direction) {
    value <- if (direction == "Largest positive") max(subset$change) else min(subset$change)
    extreme <- filter(subset, change == value)
    tibble(
      workshop = w, direction, change = value, tied_observations = nrow(extreme),
      pre_min = min(extreme$conocimiento_total_pre),
      pre_max = max(extreme$conocimiento_total_pre),
      post_min = min(extreme$conocimiento_total_post),
      post_max = max(extreme$conocimiento_total_post),
      years_represented = paste(sort(unique(extreme$anio)), collapse = "; ")
    )
  })
})

# Save workshop-level and diagnostic summaries.
dir.create("tables", showWarnings = FALSE)
dir.create("figures", showWarnings = FALSE)
write_csv(objective_summary, "tables/prepost_change_by_workshop.csv")
write_csv(year_summary, "tables/prepost_change_by_year.csv")
write_csv(centre_summary, "tables/change_by_centre.csv")
write_csv(context_summary_table, "tables/change_by_context.csv")
write_csv(perceived_summary, "tables/perceived_change_by_workshop.csv")
write_csv(correlation_summary, "tables/change_correlations.csv")
write_csv(extreme_summary, "tables/extreme_change_aggregate_diagnostic.csv")

# Examine paired scores and individual change by workshop.
objective_long <- datos %>%
  mutate(participant = row_number()) %>%
  select(participant, workshop, PRE = conocimiento_total_pre,
         POST = conocimiento_total_post) %>%
  pivot_longer(c(PRE, POST), names_to = "moment", values_to = "score")

ggsave(
  "figures/prepost_change_by_workshop.png",
  ggplot(objective_long, aes(moment, score, group = participant)) +
    geom_line(alpha = 0.035, colour = "grey35") +
    geom_boxplot(aes(group = moment), width = 0.32, outlier.shape = NA) +
    facet_wrap(~workshop, scales = "free_y") +
    labs(x = "Assessment", y = "Objective score (workshop-specific)") +
    theme_minimal(),
  width = 9, height = 5, dpi = 160, bg = "white"
)

ggsave(
  "figures/change_distribution_by_workshop.png",
  ggplot(datos, aes(change)) +
    geom_histogram(binwidth = 0.5, boundary = 0, colour = "white", fill = "steelblue") +
    facet_wrap(~workshop, scales = "free_y") +
    labs(x = "Observed objective pre/post change", y = "Participants") +
    theme_minimal(),
  width = 9, height = 5, dpi = 160, bg = "white"
)

ggsave(
  "figures/change_by_year.png",
  ggplot(year_summary, aes(year, mean_change)) +
    geom_errorbar(aes(ymin = bootstrap_mean_low, ymax = bootstrap_mean_high), width = 0.12) +
    geom_point(size = 2) +
    facet_wrap(~workshop, scales = "free_x") +
    labs(x = "School year", y = "Mean observed change") +
    theme_minimal(),
  width = 8, height = 5, dpi = 160, bg = "white"
)

ggsave(
  "figures/baseline_vs_change.png",
  ggplot(datos, aes(conocimiento_total_pre, change)) +
    geom_point(alpha = 0.35, position = position_jitter(width = 0.05, height = 0.05)) +
    facet_wrap(~workshop, scales = "free") +
    labs(x = "Objective PRE score", y = "Objective pre/post change") +
    theme_minimal(),
  width = 9, height = 5, dpi = 160, bg = "white"
)

