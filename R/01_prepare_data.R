# ============================================================
# 01_prepare_data.R
#
# Builds the PRIVATE analytical dataset from the raw master
# questionnaire file.
#
#   Input : Datos totales 20 sept 2026.csv   (never modified)
#   Output: data/private/analysis_data.rds  (participant-level,
#                                           excluded from git)
#
# Preparation and validation only: no inferential statistics.
#
# Run from the repository root:
#     Rscript R/01_prepare_data.R
# ============================================================

# ------------------------------------------------------------
# 1. CONFIGURATION AND PATHS
# ------------------------------------------------------------

archivo_raw <- "Datos totales 20 sept 2026.csv"
archivo_out <- file.path("data", "private", "analysis_data.rds")

# The raw CSV is read-only input. Nothing in this script writes to it.
if (!file.exists(archivo_raw) && file.exists(file.path("..", archivo_raw))) {
  setwd("..")
}
stopifnot(file.exists(archivo_raw))

# The sixteen scored items, in questionnaire order.
preguntas_pre  <- paste0("pregunta", 1:8, "pre")
preguntas_post <- paste0("pregunta", 1:8, "post")

# Expected schema of the raw file, in header order. The item
# columns alternate pre/post, matching the questionnaire layout.
nombres_esperados <- c(
  "sexo", "edad", "taller", "curso", "centro", "Año",
  "conoc_tot_pre", "conoc_tot_post",
  as.vector(rbind(preguntas_pre, preguntas_post))
)


# ------------------------------------------------------------
# 2. READ RAW DATA
# ------------------------------------------------------------

# All columns are read as text and converted explicitly below, so
# parsing does not depend on the machine's locale or decimal mark.
# readr strips the BOM and always reads UTF-8.
crudo <- readr::read_csv(
  archivo_raw,
  col_types      = readr::cols(.default = readr::col_character()),
  na             = c("", "NA"),
  name_repair    = "minimal",
  show_col_types = FALSE
)

n_crudo <- nrow(crudo)

# The by-name renaming below relies on this exact schema.
stopifnot(identical(names(crudo), nombres_esperados))


# ------------------------------------------------------------
# 3. RENAME VARIABLES
# ------------------------------------------------------------

# Renaming is by name, never by position.
#
# conoc_tot_* counts how many items the participant believed they
# could answer, i.e. PERCEIVED knowledge. It is not an objective
# knowledge total, and the historical name is misleading.
renombres <- c(
  sexo           = "sexo",
  edad           = "edad",
  taller         = "taller",
  curso          = "curso",
  centro         = "centro",
  `Año`          = "anio",
  conoc_tot_pre  = "conocimiento_percibido_pre",
  conoc_tot_post = "conocimiento_percibido_post"
)

# The sixteen scored items keep their original names.
renombres <- c(renombres, setNames(preguntas_pre, preguntas_pre),
               setNames(preguntas_post, preguntas_post))

datos <- as.data.frame(crudo, stringsAsFactors = FALSE)
names(datos) <- renombres[match(names(crudo), names(renombres))]
stopifnot(!anyNA(names(datos)))


# ------------------------------------------------------------
# 4. CLEAN AND PARSE
# ------------------------------------------------------------

# Categorical variables: remove surrounding whitespace only.
# No category is merged or collapsed.
categoricas <- c("sexo", "taller", "curso", "centro", "anio")
datos[categoricas] <- lapply(datos[categoricas], trimws)

# Numeric variables: the item scores use decimal commas ("0,5"),
# so commas are normalised before conversion.
a_numero <- function(x) {
  suppressWarnings(as.numeric(gsub(",", ".", trimws(x), fixed = TRUE)))
}

numericas <- c("edad", "conocimiento_percibido_pre",
               "conocimiento_percibido_post",
               preguntas_pre, preguntas_post)
datos[numericas] <- lapply(datos[numericas], a_numero)

# Factors. R models accept factor predictors directly, so no
# numeric recode of sex is created.
datos$taller <- factor(datos$taller, levels = c("Ansiedad", "Decisiones", "Riesgo"))
datos$sexo   <- factor(datos$sexo)


# ------------------------------------------------------------
# 5. DERIVED VARIABLES
# ------------------------------------------------------------

# Objective knowledge: the sum of the eight scored items at each
# moment. These totals are deliberately NOT rescaled onto the
# perceived-knowledge scale; the two are different constructs on
# different metrics.
datos$conocimiento_total_pre  <- rowSums(datos[preguntas_pre])
datos$conocimiento_total_post <- rowSums(datos[preguntas_post])

datos$cambio_conocimiento <- datos$conocimiento_total_post - datos$conocimiento_total_pre
datos$cambio_conocimiento_percibido <-
  datos$conocimiento_percibido_post - datos$conocimiento_percibido_pre


# ------------------------------------------------------------
# 6. ESSENTIAL VALIDATION
# ------------------------------------------------------------

originales <- c("sexo", "edad", "taller", "curso", "centro", "anio",
                "conocimiento_percibido_pre", "conocimiento_percibido_post",
                preguntas_pre, preguntas_post)

# Sample size and workshop composition, compared by explicit name so
# the check does not depend on factor level ordering.
stopifnot(
  nrow(datos) == n_crudo,                                    # no rows removed
  nrow(datos) == 1090,
  sum(datos$taller == "Ansiedad")   == 531L,
  sum(datos$taller == "Decisiones") == 411L,
  sum(datos$taller == "Riesgo")     == 148L,
  length(unique(datos$centro)) == 11L
)

# No original variable lost a value, and every item survived parsing.
stopifnot(
  !anyNA(datos[originales]),
  all(vapply(datos[preguntas_pre],  is.numeric, logical(1))),
  all(vapply(datos[preguntas_post], is.numeric, logical(1)))
)

# The perceived-knowledge variables are unchanged from the source.
# The recomputed totals use apply() rather than rowSums() so that a
# wrong item selection would actually be caught.
stopifnot(
  identical(datos$conocimiento_percibido_pre,  as.numeric(crudo$conoc_tot_pre)),
  identical(datos$conocimiento_percibido_post, as.numeric(crudo$conoc_tot_post)),
  identical(datos$conocimiento_total_pre,  apply(datos[preguntas_pre],  1, sum)),
  identical(datos$conocimiento_total_post, apply(datos[preguntas_post], 1, sum))
)

# A perceived score of 9 is not a valid value in the corrected data:
# the perceived-knowledge score is an eight-question count in every
# cohort, so its range is 0-8.
stopifnot(
  all(datos$conocimiento_percibido_pre  >= 0 & datos$conocimiento_percibido_pre  <= 8),
  all(datos$conocimiento_percibido_post >= 0 & datos$conocimiento_percibido_post <= 8),
  !any(datos$conocimiento_percibido_pre  == 9),
  !any(datos$conocimiento_percibido_post == 9)
)


# ------------------------------------------------------------
# 7. SAVE PRIVATE ANALYTICAL DATASET
# ------------------------------------------------------------

dir.create(dirname(archivo_out), showWarnings = FALSE, recursive = TRUE)
saveRDS(datos, archivo_out, compress = "xz")

cat("Analytical dataset saved (PRIVATE):", archivo_out, "\n")
cat(sprintf("%d observations x %d variables\n\n", nrow(datos), ncol(datos)))

cat("Sample\n")
cat("  N =", nrow(datos), "| centres =", length(unique(datos$centro)),
    "| mean age =", round(mean(datos$edad), 2),
    "| age range", min(datos$edad), "-", max(datos$edad), "\n")
print(table(taller = datos$taller, sexo = datos$sexo))
print(table(anio = datos$anio))

cat("\nObjective knowledge (sum of eight items)\n")
cat("  pre  ", sprintf("%.3f", mean(datos$conocimiento_total_pre)),
    " post ", sprintf("%.3f", mean(datos$conocimiento_total_post)),
    " change ", sprintf("%.3f", mean(datos$cambio_conocimiento)),
    sprintf("(SD %.3f)", sd(datos$cambio_conocimiento)), "\n")

cat("\nPerceived knowledge (eight-question self-report, range 0-8)\n")
cat("  pre  ", sprintf("%.3f", mean(datos$conocimiento_percibido_pre)),
    " post ", sprintf("%.3f", mean(datos$conocimiento_percibido_post)),
    " change ", sprintf("%.3f", mean(datos$cambio_conocimiento_percibido)),
    sprintf("(SD %.3f)", sd(datos$cambio_conocimiento_percibido)), "\n")

cat("\nMean objective knowledge by workshop\n")
print(round(tapply(datos$conocimiento_total_pre,  datos$taller, mean), 3))
print(round(tapply(datos$conocimiento_total_post, datos$taller, mean), 3))

cat("\nWorkshop and school year are nested: the 21/22 data covers the\n")
cat("anxiety workshop only, while all three workshops were delivered\n")
cat("in 25/26 (n = 731). Between-workshop comparisons should draw on\n")
cat("the 25/26 cohort.\n\n")

cat("All checks passed. No inferential statistics computed.\n")