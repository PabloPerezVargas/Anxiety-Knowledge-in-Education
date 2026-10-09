library(dplyr)
library(tidyr)
library(ggplot2)
library(purrr)
library(readr)

# Read the prepared data and attach the documented conceptual domains.
datos <- readRDS("data/private/analysis_data.rds")
centre_key <- tibble(
  centro = sort(unique(datos$centro), method = "radix"),
  centre = sprintf("Centro_%02d", seq_along(sort(unique(datos$centro), method = "radix")))
)

domain_map <- tribble(
  ~taller, ~item, ~item_label,
  "Ansiedad", 1L, "Anxiety conceptualisation",
  "Ansiedad", 2L, "Components and process of the anxiety response",
  "Ansiedad", 3L, "Learning and consolidation processes",
  "Ansiedad", 4L, "Metacognition",
  "Ansiedad", 5L, "Verbalisation and support processes",
  "Ansiedad", 6L, "Relaxation and regulation methods",
  "Ansiedad", 7L, "Long-term prevention and regulation",
  "Ansiedad", 8L, "Integration of knowledge into practical advice",
  "Decisiones", 1L, "Decision-making and problem solving",
  "Decisiones", 2L, "Cold (rational) cognitive processes",
  "Decisiones", 3L, "Hot (emotional) processes",
  "Decisiones", 4L, "Planning and the context of decisions",
  "Decisiones", 5L, "Impulsivity",
  "Decisiones", 6L, "Skills associated with effective decision-making",
  "Decisiones", 7L, "Information organisation",
  "Decisiones", 8L, "Integration of knowledge into practical advice",
  "Riesgo", 1L, "Anxiety-state concepts",
  "Riesgo", 2L, "Factors associated with self-harm and suicidal behaviour",
  "Riesgo", 3L, "Homeostasis and habituation",
  "Riesgo", 4L, "Metacognition",
  "Riesgo", 5L, "Impulsivity, anxiety and risk",
  "Riesgo", 6L, "Crisis regulation methods",
  "Riesgo", 7L, "Long-term prevention and protective processes",
  "Riesgo", 8L, "Integration of knowledge into practical advice"
)

datos <- datos %>%
  mutate(participant = row_number()) %>%
  left_join(centre_key, by = "centro")

item_pairs <- datos %>%
  select(participant, taller, anio, centre, starts_with("pregunta")) %>%
  pivot_longer(
    starts_with("pregunta"), names_to = c("item", "moment"),
    names_pattern = "pregunta(\\d+)(pre|post)", values_to = "score"
  ) %>%
  mutate(item = as.integer(item)) %>%
  pivot_wider(names_from = moment, values_from = score) %>%
  mutate(
    change = post - pre,
    response_pattern = case_when(
      change > 0 ~ "Improved",
      change < 0 ~ "Decreased",
      TRUE ~ "Unchanged"
    )
  ) %>%
  left_join(domain_map, by = c("taller", "item"))

stopifnot(
  nrow(datos) == 1090L,
  all(table(datos$taller) == c(531L, 411L, 148L)),
  nrow(item_pairs) == 1090L * 8L,
  nrow(domain_map) == 24L,
  !anyNA(item_pairs[c("pre", "post", "change", "item_label")]),
  all(item_pairs$change == item_pairs$post - item_pairs$pre)
)

set.seed(20261008)

# Bootstrap participants, keeping each item's PRE and POST scores together.
bootstrap_mean_ci <- function(data, n_boot = 5000L) {
  boot_means <- replicate(n_boot, {
    sampled <- sample.int(nrow(data), nrow(data), replace = TRUE)
    mean(data$post[sampled] - data$pre[sampled])
  })
  unname(quantile(boot_means, c(0.025, 0.975)))
}

# Summarise change within each workshop-specific item.
content_learning_map <- item_pairs %>%
  group_by(taller, item, item_label) %>%
  group_modify(~ {
    d <- .x
    change <- d$change
    pattern <- prop.table(table(factor(
      d$response_pattern, levels = c("Improved", "Unchanged", "Decreased")
    ))) * 100
    ci <- bootstrap_mean_ci(d)
    change_sd <- sd(change)

    tibble(
      n = nrow(d),
      pre_mean = mean(d$pre), pre_sd = sd(d$pre),
      pre_median = median(d$pre), pre_IQR = IQR(d$pre),
      pre_observed_min = min(d$pre), pre_observed_max = max(d$pre),
      post_mean = mean(d$post), post_sd = sd(d$post),
      post_median = median(d$post), post_IQR = IQR(d$post),
      post_observed_min = min(d$post), post_observed_max = max(d$post),
      mean_change = mean(change), sd_change = change_sd,
      median_change = median(change), IQR_change = IQR(change),
      change_min = min(change), change_max = max(change),
      bootstrap_mean_ci_low = ci[1], bootstrap_mean_ci_high = ci[2],
      cohen_dz = if (change_sd > 0) mean(change) / change_sd else NA_real_,
      dz_note = if (change_sd == 0) "Undefined: zero change SD" else
        if (change_sd < 0.1) "Unstable: near-zero change SD" else "",
      improved_n = sum(change > 0), improved_percent = unname(pattern["Improved"]),
      unchanged_n = sum(change == 0), unchanged_percent = unname(pattern["Unchanged"]),
      decreased_n = sum(change < 0), decreased_percent = unname(pattern["Decreased"]),
      pre_observed_min_concentration = mean(d$pre == min(d$pre)),
      pre_observed_max_concentration = mean(d$pre == max(d$pre)),
      post_observed_min_concentration = mean(d$post == min(d$post)),
      post_observed_max_concentration = mean(d$post == max(d$post)),
      range_basis = "Observed endpoints only; theoretical item limits not established"
    )
  }) %>%
  ungroup() %>%
  rename(workshop = taller) %>%
  mutate(item_display = paste("Item", item, "—", item_label))

# Describe item change by cohort without year-specific tests.
content_change_by_year <- item_pairs %>%
  group_by(taller, anio, item, item_label) %>%
  group_modify(~ {
    d <- .x
    ci <- bootstrap_mean_ci(d)
    tibble(
      n = nrow(d),
      pre_mean = mean(d$pre), post_mean = mean(d$post),
      mean_change = mean(d$change),
      bootstrap_mean_ci_low = ci[1], bootstrap_mean_ci_high = ci[2],
      improved_percent = 100 * mean(d$change > 0)
    )
  }) %>%
  ungroup() %>%
  rename(workshop = taller, year = anio) %>%
  mutate(
    year = factor(year, levels = c("21/22", "24/25", "25/26")),
    item_display = paste("Item", item, "—", item_label)
  )

# Check the strongest and weakest changing items across sufficiently large centres.
notable_items <- bind_rows(
  content_learning_map %>%
    group_by(workshop) %>%
    slice_max(mean_change, n = 2, with_ties = FALSE) %>%
    mutate(item_pattern = "Highest overall mean change"),
  content_learning_map %>%
    group_by(workshop) %>%
    slice_min(mean_change, n = 2, with_ties = FALSE) %>%
    mutate(item_pattern = "Lowest overall mean change")
) %>%
  distinct(workshop, item, .keep_all = TRUE) %>%
  select(workshop, item, item_label, item_pattern)

content_change_by_centre <- item_pairs %>%
  rename(workshop = taller) %>%
  semi_join(notable_items, by = c("workshop", "item", "item_label")) %>%
  group_by(workshop, centre, item, item_label) %>%
  summarise(
    n = n(), mean_change = mean(change), sd_change = sd(change),
    median_change = median(change), improved_percent = 100 * mean(change > 0),
    .groups = "drop"
  ) %>%
  filter(n >= 20) %>%
  left_join(notable_items, by = c("workshop", "item", "item_label")) %>%
  arrange(workshop, item, centre)

# Save workshop-specific summaries; the centre table is an internal diagnostic.
dir.create("tables", showWarnings = FALSE)
dir.create("figures", showWarnings = FALSE)
write_csv(content_learning_map, "tables/content_learning_map.csv")
write_csv(content_change_by_year, "tables/content_change_by_year.csv")
write_csv(content_change_by_centre, "tables/content_change_by_centre.csv")

ggplot(content_learning_map,
       aes(mean_change, reorder(item_display, item))) +
  geom_vline(xintercept = 0, colour = "grey70") +
  geom_segment(aes(x = bootstrap_mean_ci_low, xend = bootstrap_mean_ci_high,
                   yend = reorder(item_display, item)), colour = "grey35") +
  geom_point(size = 2) +
  facet_wrap(~workshop, scales = "free_y", ncol = 1) +
  labs(x = "Mean item-score change (POST - PRE)", y = NULL) +
  theme_minimal(base_size = 10) +
  theme(axis.text.y = element_text(size = 8))
ggsave("figures/content_learning_map.png", width = 11, height = 10, dpi = 160, bg = "white")

ggplot(item_pairs, aes(factor(item), change)) +
  geom_hline(yintercept = 0, colour = "grey70") +
  geom_boxplot(outlier.size = 0.6) +
  facet_grid(taller ~ ., scales = "free_y") +
  labs(x = "Historical item number", y = "Item-level change (POST - PRE)") +
  theme_minimal()
ggsave("figures/item_change_distributions.png", width = 10, height = 7, dpi = 160, bg = "white")

ggplot(content_change_by_year, aes(year, mean_change, group = 1)) +
  geom_errorbar(aes(ymin = bootstrap_mean_ci_low, ymax = bootstrap_mean_ci_high),
                width = 0.15) +
  geom_point(size = 1.5) +
  facet_wrap(vars(workshop, item), scales = "free_y", ncol = 4) +
  labs(x = "School year", y = "Mean item change") +
  theme_minimal(base_size = 9)
ggsave("figures/content_change_by_year.png", width = 14, height = 8, dpi = 160, bg = "white")
