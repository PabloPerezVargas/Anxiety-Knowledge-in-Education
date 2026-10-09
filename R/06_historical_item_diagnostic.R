library(dplyr)
library(tidyr)
library(ggplot2)
library(purrr)
library(readr)
library(psych)

datos <- readRDS("data/private/analysis_data.rds")
workshops <- levels(datos$taller)
items <- paste0("pregunta", 1:8)

# Put PRE and POST item responses into separate workshop-specific matrices.
item_data <- map_dfr(c("pre", "post"), function(moment) {
  datos %>%
    select(taller, anio, all_of(paste0(items, moment))) %>%
    rename_with(~ items, all_of(paste0(items, moment))) %>%
    mutate(moment = toupper(moment))
})

item_diagnostics <- list()
reliability <- list()
interitem <- list()

for (workshop in workshops) {
  for (moment in c("PRE", "POST")) {
    subset <- item_data %>% filter(taller == workshop, moment == !!moment)
    item_matrix <- subset %>% select(all_of(items))
    total <- rowSums(item_matrix)

    # Corrected item-rest correlations remove the target item from the total.
    item_diagnostics[[length(item_diagnostics) + 1L]] <- map_dfr(seq_along(items), function(i) {
      score <- item_matrix[[i]]
      rest <- total - score
      tibble(
        workshop = workshop, moment = moment, item = i,
        n = length(score),
        pearson_item_total = cor(score, total, method = "pearson"),
        spearman_item_total = cor(score, total, method = "spearman"),
        pearson_item_rest = cor(score, rest, method = "pearson"),
        spearman_item_rest = cor(score, rest, method = "spearman")
      )
    })

    alpha_fit <- psych::alpha(item_matrix, check.keys = FALSE, warnings = FALSE)
    reliability[[length(reliability) + 1L]] <- tibble(
      workshop = workshop, moment = moment, n = nrow(item_matrix),
      alpha = unname(alpha_fit$total$raw_alpha)
    )
    dropped <- alpha_fit$alpha.drop$raw_alpha
    item_diagnostics[[length(item_diagnostics)]] <- item_diagnostics[[length(item_diagnostics)]] %>%
      mutate(alpha_if_item_deleted = unname(dropped[match(item, seq_along(items))]))

    correlation_matrix <- cor(item_matrix, method = "spearman")
    interitem[[length(interitem) + 1L]] <- as.data.frame(as.table(correlation_matrix)) %>%
      transmute(workshop = workshop, moment = moment,
                item1 = as.integer(match(Var1, items)),
                item2 = as.integer(match(Var2, items)), correlation = Freq)
  }
}

item_rest_diagnostics <- bind_rows(item_diagnostics)
reliability_by_workshop <- bind_rows(reliability)
interitem_correlations <- bind_rows(interitem)

# Compare Anxiety item-rest correlations and alpha with and without 2021/22.
anxiety_data <- item_data %>% filter(taller == "Ansiedad")
pre_all <- anxiety_data %>% filter(moment == "PRE")
pre_recent <- pre_all %>% filter(anio %in% c("24/25", "25/26"))
post_all <- anxiety_data %>% filter(moment == "POST")
post_recent <- post_all %>% filter(anio %in% c("24/25", "25/26"))

anxiety_sensitivity <- map_dfr(seq_along(items), function(i) {
  pre_all_matrix <- select(pre_all, all_of(items))
  pre_recent_matrix <- select(pre_recent, all_of(items))
  post_all_matrix <- select(post_all, all_of(items))
  post_recent_matrix <- select(post_recent, all_of(items))

  tibble(
    item = i, n_all_years = nrow(pre_all_matrix), n_recent_years = nrow(pre_recent_matrix),
    spearman_pre_all_years = cor(pre_all_matrix[[i]], rowSums(pre_all_matrix) - pre_all_matrix[[i]], method = "spearman"),
    spearman_pre_recent_years = cor(pre_recent_matrix[[i]], rowSums(pre_recent_matrix) - pre_recent_matrix[[i]], method = "spearman"),
    spearman_post_all_years = cor(post_all_matrix[[i]], rowSums(post_all_matrix) - post_all_matrix[[i]], method = "spearman"),
    spearman_post_recent_years = cor(post_recent_matrix[[i]], rowSums(post_recent_matrix) - post_recent_matrix[[i]], method = "spearman")
  )
}) %>%
  mutate(
    alpha_pre_all_years = psych::alpha(select(pre_all, all_of(items)), check.keys = FALSE, warnings = FALSE)$total$raw_alpha,
    alpha_pre_recent_years = psych::alpha(select(pre_recent, all_of(items)), check.keys = FALSE, warnings = FALSE)$total$raw_alpha,
    alpha_post_all_years = psych::alpha(select(post_all, all_of(items)), check.keys = FALSE, warnings = FALSE)$total$raw_alpha,
    alpha_post_recent_years = psych::alpha(select(post_recent, all_of(items)), check.keys = FALSE, warnings = FALSE)$total$raw_alpha
  )

# Save aggregate diagnostics only; item labels remain numbers to avoid implying shared constructs.
dir.create("tables", showWarnings = FALSE)
dir.create("figures", showWarnings = FALSE)
write_csv(item_rest_diagnostics, "tables/item_rest_diagnostics.csv")
write_csv(reliability_by_workshop, "tables/reliability_by_workshop.csv")
write_csv(anxiety_sensitivity, "tables/anxiety_item_sensitivity.csv")
write_csv(interitem_correlations, "tables/interitem_correlations.csv")

# Spearman item-rest correlations are shown separately by workshop and moment.
ggplot(item_rest_diagnostics, aes(spearman_item_rest, factor(item), colour = moment)) +
  geom_vline(xintercept = 0, colour = "grey70") +
  geom_point(position = position_dodge(width = 0.45), size = 2) +
  facet_wrap(~workshop, nrow = 1) +
  labs(x = "Spearman corrected item-rest correlation", y = "Item",
       colour = "Moment") +
  theme_minimal()
ggsave("figures/item_rest_correlations.png", width = 11, height = 5, dpi = 160, bg = "white")

# POST inter-item correlations are displayed within each instrument only.
post_correlations <- filter(interitem_correlations, moment == "POST")
ggplot(post_correlations, aes(item1, item2, fill = correlation)) +
  geom_tile() +
  geom_text(aes(label = sprintf("%.2f", correlation)), size = 3) +
  facet_wrap(~workshop, nrow = 1) +
  scale_x_continuous(breaks = 1:8) +
  scale_y_continuous(breaks = 1:8) +
  scale_fill_gradient2(limits = c(-1, 1), midpoint = 0) +
  coord_equal() +
  labs(x = "Item", y = "Item", fill = "Spearman\nr") +
  theme_minimal()
ggsave("figures/interitem_correlations_post.png", width = 12, height = 4.5,
       dpi = 160, bg = "white")

cat("Item-rest correlations by workshop and moment (Spearman):\n")
print(item_rest_diagnostics %>%
        select(workshop, moment, item, spearman_item_rest, alpha_if_item_deleted) %>%
        arrange(workshop, moment, spearman_item_rest), n = Inf)
cat("\nReliability summaries (diagnostic only):\n")
print(reliability_by_workshop, n = Inf)
cat("\nAnxiety sensitivity: all years versus 2024/25 + 2025/26:\n")
print(anxiety_sensitivity, n = Inf)
cat("\nPOST inter-item pairs with |Spearman r| >= .70 (review guide only):\n")
print(post_correlations %>%
        filter(item1 < item2, abs(correlation) >= 0.70) %>%
        arrange(workshop, desc(abs(correlation))), n = Inf)

stopifnot(
  nrow(datos) == 1090L,
  all(table(datos$taller) == c(531L, 411L, 148L)),
  nrow(item_rest_diagnostics) == 3L * 2L * 8L,
  nrow(reliability_by_workshop) == 3L * 2L,
  nrow(anxiety_sensitivity) == 8L,
  all(item_rest_diagnostics$item %in% 1:8),
  all(item_rest_diagnostics$spearman_item_rest <= 1 &
        item_rest_diagnostics$spearman_item_rest >= -1)
)
