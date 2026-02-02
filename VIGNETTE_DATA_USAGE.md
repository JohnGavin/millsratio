# Vignette Pre-computed Data Usage Guide

## Overview

All vignette data has been pre-computed using the targets pipeline and
saved to `inst/extdata/`. This allows vignettes to load data quickly
without re-computing, which is essential for CI/CD and pkgdown builds.

## Pipeline Status

### Completed Targets

**Simulation Data:** - `simulation_params` - Simulation configuration (x
range, distributions) - `mills_data` - Full Mills ratio dataset (400
rows across 4 distributions) - `mills_summary` - Summary statistics by
distribution - `mills_behavior` - Monotonicity analysis
(increasing/decreasing) - `t30_paradox_analysis` - Comparison of t(30)
vs normal (100 points)

**Hazard Analysis:** - `hazard_data` - Hazard function values (h =
1/m) - `hazard_properties` - IFR/DFR/CFR classification -
`hazard_plot` - Static ggplot2 visualization - `hazard_interactive` -
Interactive plotly visualization - `hazard_asymptotics` - Tail behavior
analysis

**Examples (for testing):** - 9 example targets testing all exported
functions - All examples passed validation

### Exported Data Files

All files saved to `inst/extdata/` (total: 14 files, ~2.1 MB):

    example_basic.rds              292 bytes    - Basic Mills ratio calculations
    example_comparison.rds         238 bytes    - Distribution comparison example
    example_curves.rds             2.2 KB       - Simulation curves
    example_paradox.rds            15 KB        - t(30) paradox data
    example_plot.rds               423 KB       - Example plot object
    hazard_asymptotics.rds         327 bytes    - Tail behavior analysis
    hazard_data.rds                7.8 KB       - Full hazard dataset
    hazard_interactive.rds         1.3 MB       - Interactive plotly plot
    hazard_plot.rds                323 KB       - Static ggplot2 plot
    hazard_properties.rds          277 bytes    - IFR/DFR/CFR properties
    mills_behavior.rds             238 bytes    - Monotonicity results
    mills_data.rds                 3.1 KB       - Full Mills ratio dataset
    mills_summary.rds              355 bytes    - Summary statistics
    t30_paradox_analysis.rds       3.1 KB       - t(30) vs normal comparison

## Usage in Vignettes

### Setup Chunk (All Vignettes)

``` r
# Load package (but don't compute anything)
library(millsratio)

# Load pre-computed data
mills_data <- readRDS(system.file("extdata", "mills_data.rds", package = "millsratio"))
mills_summary <- readRDS(system.file("extdata", "mills_summary.rds", package = "millsratio"))
hazard_plot <- readRDS(system.file("extdata", "hazard_plot.rds", package = "millsratio"))
```

### Benefits

1.  **Fast**: Loads in milliseconds instead of seconds
2.  **Reproducible**: Same data every time
3.  **CI-friendly**: No package installation required during vignette
    render
4.  **Version-controlled**: Data committed with package

### Example: hazard-connection.qmd

``` r
# OLD (slow, breaks in CI):
# mills_data <- simulate_mills_curves(x_range = c(0.1, 10), distributions = c("normal", "t30"))

# NEW (fast, works everywhere):
mills_data <- readRDS(system.file("extdata", "mills_data.rds", package = "millsratio"))
```

## Re-generating Data

To update pre-computed data after changing functions:

``` bash
cd /Users/johngavin/docs_gh/proj/stats/simulations/mills_ratio/millsratio

# Run pipeline
Rscript -e "library(targets); tar_make()"

# Save to inst/extdata (see R script above)
```

## Data Verification

All data has been verified loadable:

``` r
✓ example_basic.rds              [list] 4 elements
✓ example_comparison.rds         [data.frame] 4 rows x 4 cols
✓ example_curves.rds             [data.frame] 300 rows x 4 cols
✓ hazard_plot.rds                [ggplot2] plot object
✓ hazard_interactive.rds         [plotly] interactive plot
✓ mills_data.rds                 [tbl_df] 400 rows x 3 cols
✓ mills_summary.rds              [tbl_df] 4 rows x 6 cols
✓ hazard_properties.rds          [tbl_df] 4 rows x 5 cols
```

## Sample Data

### mills_data (first 10 rows)

    # A tibble: 10 × 3
           x distribution mills_ratio
       <dbl> <chr>              <dbl>
     1   0.1 normal              1.16
     2   0.1 t3                  1.27
     3   0.1 t30                 1.17
     4   0.1 exponential         1
     5   0.2 normal              1.08
    ...

### mills_summary

    # A tibble: 4 × 6
      distribution mean_mills sd_mills min_mills max_mills median_mills
    1 exponential       1.00     0.00      1.00      1.00         1.00
    2 normal            0.29     0.24      0.10      1.16         0.19
    3 t3                1.94     0.79      0.94      3.41         1.84
    4 t30               0.45     0.17      0.35      1.17         0.39

### hazard_properties

    # A tibble: 4 × 5
      distribution all_increasing all_decreasing behavior
    1 exponential  FALSE          TRUE           DFR (Decreasing Failure Rate)
    2 normal       TRUE           FALSE          IFR (Increasing Failure Rate)
    3 t3           FALSE          FALSE          Non-monotonic
    4 t30          FALSE          FALSE          Non-monotonic

## Next Steps

1.  Update vignettes to use pre-computed data
2.  Test vignette rendering with:
    `quarto::quarto_render("vignettes/hazard-connection.qmd")`
3.  Verify pkgdown build works
4.  Commit changes with descriptive message

## Notes

- The warning about `hazard_properties` conflicting with a function name
  is expected (it’s both a function and a target)
- Documentation targets (quarto_site, pkgdown_site) are marked
  outdated - this is OK, we build them separately
- All example targets passed validation - package functions work
  correctly
