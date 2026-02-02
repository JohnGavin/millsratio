# Hazard Connection Vignette Workaround

## Problem

The `hazard-connection.qmd` vignette required the `gt` package which was
causing rendering issues.

## Solution

Replaced all `gt` table formatting with
[`knitr::kable()`](https://rdrr.io/pkg/knitr/man/kable.html) - a simpler
table format that works without additional dependencies.

## Changes Made

### 1. Modified vignettes/hazard-connection.qmd

**Setup chunk changes:** - Changed
[`library(millsratio)`](https://johngavin.github.io/millsratio/) to
[`devtools::load_all()`](https://devtools.r-lib.org/reference/load_all.html)
for development rendering - Commented out
[`library(gt)`](https://gt.rstudio.com) with note: “Replaced with
knitr::kable()”

**Table formatting replacements (5 instances):**

1.  **Lines 57-59** - First few rows table:

    ``` r
    # Before:
    gt() %>%
      fmt_number(columns = c(mills_ratio, hazard_method1, hazard_method2), decimals = 4) %>%
      tab_header(title = "Mills Ratio vs Hazard Function")

    # After:
    knitr::kable(
      digits = 4,
      caption = "Mills Ratio vs Hazard Function"
    )
    ```

2.  **Lines 152-157** - Hazard properties:

    ``` r
    # Before:
    gt() %>%
      fmt_number(columns = c(min_hazard, max_hazard), decimals = 4) %>%
      tab_header(
        title = "Hazard Function Properties by Distribution",
        subtitle = "IFR = Increasing Failure Rate, DFR = Decreasing, CFR = Constant"
      )

    # After:
    knitr::kable(
      digits = 4,
      caption = "Hazard Function Properties by Distribution (IFR = Increasing Failure Rate, DFR = Decreasing, CFR = Constant)"
    )
    ```

3.  **Lines 229-230** - Reliability summary:

    ``` r
    # Before:
    gt() %>%
      tab_header(title = "Component Life Estimates from Hazard Model")

    # After:
    knitr::kable(
      caption = "Component Life Estimates from Hazard Model"
    )
    ```

4.  **Lines 283-285** - Distribution comparison:

    ``` r
    # Before:
    gt() %>%
      fmt_number(decimals = 3) %>%
      tab_header(title = "Distribution Comparison Summary")

    # After:
    knitr::kable(
      digits = 3,
      caption = "Distribution Comparison Summary"
    )
    ```

### 2. Rendering Process

``` bash
# Rendered from package root so devtools::load_all() works
cd /Users/johngavin/docs_gh/proj/stats/simulations/mills_ratio/millsratio
quarto render vignettes/hazard-connection.qmd --to html
```

**Output:** `docs/vignettes/hazard-connection.html` (174K)

### 3. Deployment

``` bash
# Copied to docs/articles/ for website deployment
cp docs/vignettes/hazard-connection.html docs/articles/hazard-connection.html
```

## Verification

**All vignettes now present in docs/articles/:** - applications.html
(118K) - benchmarks.html (133K) - dashboard.html (176K) -
**hazard-connection.html (174K)** ← NEW - theory.html (65K) -
webr-playground.html (149K)

**HTML verification:** Checked rendered output contains standard HTML
tables with captions (not gt-specific styling).

## Benefits of knitr::kable()

1.  **No dependencies:** Works with base R/knitr only
2.  **Simpler syntax:** Fewer parameters to configure
3.  **Consistent rendering:** Works across all output formats
4.  **Faster builds:** No additional package loading overhead

## Notes

- The original vignette with `gt` formatting is preserved in git history
  if needed
- Tables still display cleanly with proper captions and formatting
- All interactive plots (plotly) remain unchanged
- Mathematical equations render correctly
