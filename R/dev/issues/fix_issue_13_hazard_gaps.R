# Fix for Issue #13: Add hazard function tests, visualization, and verification
# https://github.com/JohnGavin/millsratio/issues/13
#
# Problem:
# - 4 exported hazard functions had zero test coverage
# - No side-by-side m(x) vs h(x) visualization
# - No numerical verification table proving h(x) = 1/m(x)
# - No hazard crossover plot for t(30) paradox
# - Vignette computed data inline instead of using precomputed targets
#
# Changes:
# 1. Created tests/testthat/test-hazard_functions.R (~20 test blocks, 51 expectations)
#    - hazard_from_mills: reciprocal, vectorized, edge cases, roundtrips
#    - hazard_function: normal/t/exponential, errors, equivalence to 1/m(x)
#    - compare_mills_hazard: structure, reciprocal verification, all distributions
#    - hazard_properties: IFR/CFR classification, t-distribution, field completeness
#
# 2. Added plot_mills_vs_hazard() to R/visualization.R
#    - Faceted ggplot2/plotly dual-panel showing m(x) and h(x) side-by-side
#    - Supports multiple distributions, log_y, interactive mode
#
# 3. Added 5 new targets to R/tar_plans/plan_hazard_analysis.R
#    - hazard_verification_table: proves h(x)*m(x)=1 across all distributions
#    - hazard_crossover_data: t(30) vs normal hazard crossover
#    - hazard_mills_side_by_side: precomputed data for side-by-side viz
#    - hazard_plot_mills_vs_hazard: static ggplot2 plot
#    - save_hazard_extdata: saves all targets to inst/extdata/
#
# 4. Updated vignettes/hazard-connection.qmd
#    - Replaced devtools::load_all() with library(millsratio)
#    - Replaced inline computation with precomputed data via readRDS()
#    - Added "Numerical Verification" section with verification table
#    - Added "Hazard Crossover: t(30) Paradox" section
#    - Added "Side-by-Side Comparison" section
#
# 5. Bumped version 0.1.0 -> 0.2.0 (new feature)
#
# Verification:
# - devtools::test(filter = "hazard"): 51 tests pass
# - devtools::test(): 131 tests pass (0 failures)
# - devtools::check(): 0 errors, 0 warnings, 7 NOTEs (all pre-existing)
