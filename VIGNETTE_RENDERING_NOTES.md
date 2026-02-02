# Vignette Rendering Status

## Successfully Rendered (with code execution)

### 1. applications.qmd ✓

- **Status**: SUCCESS
- **Output**: docs/articles/applications.html (118.9 KB)
- **Code chunks**: 21/21 executed successfully
- **Features**:
  - Financial applications (VaR, Expected Shortfall)
  - Option pricing
  - Mean residual life
  - System reliability
  - Truncated regression
  - Survival analysis
  - Process capability
  - Outlier detection
  - Reinsurance calculations
- **Verification**: Contains actual computed outputs (e.g., “99% VaR:”
  calculations)

### 2. theory.qmd ✓

- **Status**: SUCCESS
- **Output**: docs/articles/theory.html (65.8 KB)
- **Code chunks**: 9/9 executed successfully
- **Features**:
  - Normal distribution asymptotic properties
  - Bounds visualization
  - Numerical computation tips
- **Verification**: Contains at least 1 generated plot

## Not Rendered

### 3. benchmarks.qmd ✗

- **Status**: SKIPPED
- **Reason**: Missing microbenchmark package dependency
- **Background**: microbenchmark was removed from DESCRIPTION due to C
  compiler issues in Nix environment (see R/dev/issues/fix_issue_5.R)
- **Problem**: Multiple code chunks call `microbenchmark()` directly
  without conditional checks:
  - Line 66: vector-bench chunk
  - Line 245: Implementation comparison
  - Line 279: Vectorization benefits
  - Line 318: Cache benchmarks
- **Solution options**:
  1.  Add microbenchmark back to Suggests (requires resolving Nix C
      compiler issues)
  2.  Wrap all microbenchmark() calls with conditional checks for
      package availability
  3.  Replace microbenchmark with bench::mark() from the bench package

## Rendering Method

Vignettes were rendered using a custom script that: 1. Creates temporary
directory structure mirroring package layout 2. Copies references.bib to
enable bibliography resolution 3. Temporarily replaces
[`library(millsratio)`](https://johngavin.github.io/millsratio/) with
`devtools::load_all(".", quiet = TRUE)` 4. Renders using quarto CLI with
–execute-dir set to package root 5. Copies HTML outputs to
docs/articles/

## Files

- Rendering script:
  `/Users/johngavin/docs_gh/proj/stats/simulations/mills_ratio/millsratio/render_vignettes_v4.R`
- Output directory:
  `/Users/johngavin/docs_gh/proj/stats/simulations/mills_ratio/millsratio/docs/articles/`
- Bibliography:
  `/Users/johngavin/docs_gh/proj/stats/simulations/mills_ratio/millsratio/references.bib`
