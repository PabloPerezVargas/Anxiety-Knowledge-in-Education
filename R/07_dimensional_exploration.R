library(dplyr)
library(tidyr)
library(ggplot2)
library(purrr)
library(readr)
library(psych)

datos <- readRDS("data/private/analysis_data.rds")
workshops <- levels(datos$taller)
items <- paste0("pregunta", 1:8, "post")

# Keep the Anxiety cohort sensitivity explicit; all Anxiety years remain primary.
samples <- list(
  "Ansiedad — all years" = filter(datos, taller == "Ansiedad"),
  "Ansiedad — 2024/25 + 2025/26" = filter(datos, taller == "Ansiedad",
                                              anio %in% c("24/25", "25/26")),
  "Decisiones — all years" = filter(datos, taller == "Decisiones"),
  "Riesgo — all years" = filter(datos, taller == "Riesgo")
)

set.seed(20261009)

# Use ranks to make Pearson correlations of the transformed scores equal Spearman correlations.
explore_structure <- function(data, workshop, sample_label) {
  score_matrix <- as.matrix(select(data, all_of(items)))
  colnames(score_matrix) <- paste0("Item", 1:8)
  ranked <- apply(score_matrix, 2, rank, ties.method = "average")
  colnames(ranked) <- paste0("Item", 1:8)
  n <- nrow(ranked)
  correlation <- cor(ranked)
  eigenvalues <- eigen(correlation, symmetric = TRUE, only.values = TRUE)$values
  kmo <- psych::KMO(correlation)
  bartlett <- psych::cortest.bartlett(correlation, n = n)

  parallel <- psych::fa.parallel(
    ranked, fa = "fa", fm = "minres", n.iter = 100,
    quant = 0.95, plot = FALSE
  )

  off_diagonal <- correlation[upper.tri(correlation)]
  pa_factors <- parallel$nfact
  fit_factors <- unique(c(1L, if (pa_factors >= 2L) 2L))
  factor_models <- list()

  for (factor_n in fit_factors) {
    factor_model <- psych::fa(
      correlation, nfactors = factor_n, n.obs = n,
      fm = "minres", rotate = if (factor_n == 1L) "none" else "oblimin",
      residuals = FALSE, warnings = FALSE
    )
    loadings <- unclass(factor_model$loadings)
    factor_names <- paste0("Factor ", seq_len(ncol(loadings)))
    colnames(loadings) <- factor_names

    reproduced <- loadings %*% if (factor_n > 1L) factor_model$Phi else diag(1)
    reproduced <- reproduced %*% t(loadings)
    diag(reproduced) <- 1
    residual <- correlation - reproduced
    residual_max <- max(abs(residual[upper.tri(residual)]))
    communalities <- factor_model$communality

    loading_table <- as.data.frame(loadings) %>%
      tibble::rownames_to_column("item") %>%
      pivot_longer(-item, names_to = "factor", values_to = "loading") %>%
      mutate(
        workshop = workshop, sample = sample_label, solution = paste0(factor_n, " factor"),
        item = match(item, paste0("Item", 1:8)),
        communality = unname(communalities[match(item, seq_along(items))]),
        stringsAsFactors = FALSE
      ) %>%
      select(workshop, sample, solution, item, factor, loading, communality)

    fit_row <- tibble(
      one_factor_rmsr = if (factor_n == 1L) factor_model$rms else NA_real_,
      one_factor_rmsea = if (factor_n == 1L) factor_model$RMSEA[1] else NA_real_,
      one_factor_tli = if (factor_n == 1L) factor_model$TLI else NA_real_,
      one_factor_max_residual = if (factor_n == 1L) residual_max else NA_real_,
      two_factor_rmsr = if (factor_n == 2L) factor_model$rms else NA_real_,
      two_factor_rmsea = if (factor_n == 2L) factor_model$RMSEA[1] else NA_real_,
      two_factor_tli = if (factor_n == 2L) factor_model$TLI else NA_real_,
      two_factor_max_residual = if (factor_n == 2L) residual_max else NA_real_
    )

    factor_models[[as.character(factor_n)]] <- list(loadings = loading_table, fit = fit_row)
  }

  one_factor <- factor_models[["1"]]
  two_factor <- factor_models[["2"]]
  one_rmsr <- one_factor$fit$one_factor_rmsr
  one_rmsea <- one_factor$fit$one_factor_rmsea
  one_factor_judgement <- if (pa_factors == 1L && one_rmsr <= 0.05 && one_rmsea <= 0.08) {
    "Reasonably plausible"
  } else if (pa_factors >= 2L || one_rmsr > 0.08 || one_rmsea > 0.10) {
    "Questionable"
  } else {
    "Questionable; criteria are mixed"
  }

  diagnostic <- tibble(
    workshop = workshop, sample = sample_label, n = n,
    kmo_overall = kmo$MSA,
    minimum_item_msa = min(kmo$MSAi),
    minimum_msa_item = which.min(kmo$MSAi),
    item_msa = paste(sprintf("Item%d=%.3f", 1:8, kmo$MSAi), collapse = "; "),
    bartlett_chisq = unname(bartlett$chisq), bartlett_df = unname(bartlett$df),
    bartlett_p = bartlett$p.value,
    eigenvalues = paste(sprintf("%.3f", eigenvalues), collapse = "; "),
    eigenvalues_over_1 = sum(eigenvalues > 1),
    parallel_factors = pa_factors,
    parallel_fa_observed = paste(sprintf("%.3f", parallel$fa.values), collapse = "; "),
    parallel_fa_95_percentile = paste(sprintf("%.3f", parallel$fa.sim), collapse = "; "),
    mean_interitem_spearman = mean(off_diagonal),
    minimum_interitem_spearman = min(off_diagonal),
    maximum_interitem_spearman = max(off_diagonal),
    near_zero_pairs_abs_lt_0_10 = sum(abs(off_diagonal) < 0.10),
    one_factor_judgement = one_factor_judgement,
    one_factor_rmsr = one_factor$fit$one_factor_rmsr,
    one_factor_rmsea = one_factor$fit$one_factor_rmsea,
    one_factor_tli = one_factor$fit$one_factor_tli,
    one_factor_max_residual = one_factor$fit$one_factor_max_residual,
    two_factor_rmsr = if (is.null(two_factor)) NA_real_ else two_factor$fit$two_factor_rmsr,
    two_factor_rmsea = if (is.null(two_factor)) NA_real_ else two_factor$fit$two_factor_rmsea,
    two_factor_tli = if (is.null(two_factor)) NA_real_ else two_factor$fit$two_factor_tli,
    two_factor_max_residual = if (is.null(two_factor)) NA_real_ else two_factor$fit$two_factor_max_residual
  )

  scree <- tibble(
    workshop = workshop, sample = sample_label, component = seq_along(eigenvalues),
    observed_eigenvalue = eigenvalues,
    parallel_fa_observed = parallel$fa.values,
    parallel_fa_95_percentile = parallel$fa.sim
  )

  list(
    diagnostic = diagnostic,
    scree = scree,
    correlation = as.data.frame(as.table(correlation)) %>%
      transmute(workshop = workshop, sample = sample_label,
                item1 = match(Var1, paste0("Item", 1:8)),
                item2 = match(Var2, paste0("Item", 1:8)), correlation = Freq),
    loadings = bind_rows(map(factor_models, "loadings"))
  )
}

results <- imap(samples, function(data, sample_label) {
  workshop <- if (grepl("Ansiedad", sample_label)) "Ansiedad" else if (
    grepl("Decisiones", sample_label)
  ) "Decisiones" else "Riesgo"
  explore_structure(data, workshop, sample_label)
})

dimensionality_diagnostics <- map_dfr(results, "diagnostic")
scree_data <- map_dfr(results, "scree")
correlation_data <- map_dfr(results, "correlation")
efa_loadings <- map_dfr(results, "loadings")

# Save workshop-level diagnostics and factor loadings only.
dir.create("tables", showWarnings = FALSE)
dir.create("figures", showWarnings = FALSE)
write_csv(dimensionality_diagnostics, "tables/dimensionality_diagnostics.csv")
write_csv(efa_loadings, "tables/efa_loadings.csv")
write_csv(correlation_data, "tables/post_spearman_correlations.csv")

scree_plot_data <- bind_rows(
  scree_data %>% transmute(workshop, sample, component,
                           criterion = "Correlation-matrix eigenvalues",
                           series = "Observed", value = observed_eigenvalue),
  scree_data %>% transmute(workshop, sample, component,
                           criterion = "Parallel factor analysis",
                           series = "Observed factor roots", value = parallel_fa_observed),
  scree_data %>% transmute(workshop, sample, component,
                           criterion = "Parallel factor analysis",
                           series = "95th-percentile null", value = parallel_fa_95_percentile)
)

ggplot(scree_plot_data, aes(component, value, colour = series, linetype = series)) +
  geom_hline(yintercept = 1, colour = "grey75", linetype = "dotted") +
  geom_line() +
  geom_point(size = 1.4) +
  facet_grid(sample ~ criterion, scales = "free_y") +
  scale_x_continuous(breaks = 1:8) +
  labs(x = "Component", y = "Eigenvalue / factor root", colour = NULL, linetype = NULL) +
  theme_minimal()
ggsave("figures/scree_parallel_analysis.png", width = 11, height = 9, dpi = 160, bg = "white")

ggplot(efa_loadings, aes(loading, factor(item), colour = factor)) +
  geom_vline(xintercept = 0, colour = "grey75") +
  geom_point(size = 2) +
  facet_grid(sample + solution ~ workshop) +
  scale_y_discrete(labels = paste("Item", 1:8)) +
  labs(x = "Loading", y = NULL, colour = NULL) +
  theme_minimal()
ggsave("figures/efa_loadings.png", width = 11, height = 8, dpi = 160, bg = "white")

cat("POST Spearman structural diagnostics:\n")
print(dimensionality_diagnostics %>%
        select(workshop, sample, n, kmo_overall, minimum_item_msa,
               bartlett_chisq, bartlett_p, eigenvalues_over_1,
               parallel_factors, one_factor_judgement,
               one_factor_rmsr, one_factor_rmsea, one_factor_tli,
               two_factor_rmsr, two_factor_rmsea, two_factor_tli), n = Inf)
cat("\nItem loadings and communalities:\n")
print(efa_loadings, n = Inf)

stopifnot(
  nrow(datos) == 1090L,
  all(as.numeric(table(datos$taller)) == c(531L, 411L, 148L)),
  all(vapply(samples, function(x) all(items %in% names(x)), logical(1))),
  nrow(dimensionality_diagnostics) == length(samples),
  all(efa_loadings$item %in% 1:8),
  all(efa_loadings$workshop %in% workshops)
)
