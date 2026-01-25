# Plan: Enhance millsratio Dashboard and Documentation

## Objective

Implement comprehensive enhancements to the millsratio package:
1. Add hazard function page to dashboard with Mills ratio connections
2. Deploy dashboard via shinylive for web access
3. Create Quarto website for richer documentation
4. Add targets pipeline examples for reproducible workflows

## Implementation Plan

### 1. Dashboard Enhancement: Hazard Function Page

**New page showing Mills ratio ↔ Hazard function connection**

#### Mathematical Content
- Definition: h(x) = f(x)/[1-F(x)] = 1/m(x)
- Interpretation: Instantaneous failure rate
- Connection: Mills ratio is reciprocal of hazard function
- Applications: Survival analysis, reliability engineering

#### Visual Elements
- Interactive plot showing both m(x) and h(x)
- Side-by-side comparison for different distributions
- Mathematical formulas using MathJax

#### Code Examples (Tidyverse style)
```r
# Calculate hazard from Mills ratio
data %>%
  mutate(
    mills_ratio = mills_ratio_normal(x),
    hazard = 1 / mills_ratio
  ) %>%
  pivot_longer(c(mills_ratio, hazard))
```

### 2. Shinylive Deployment

**Make dashboard accessible via web browser without R installation**

#### Components
- Convert Shiny app to shinylive format
- Create vignettes/shinylive/app.R
- Build WebAssembly version
- Deploy to GitHub Pages

#### Benefits
- No R installation required
- Runs entirely in browser
- Interactive exploration for users
- Embedded in documentation

### 3. Quarto Website

**Rich documentation site beyond pkgdown**

#### Structure
```
_quarto.yml
index.qmd          # Landing page
articles/
  theory.qmd       # Mathematical theory
  applications.qmd # Real-world uses
  benchmarks.qmd   # Performance comparisons
examples/
  survival.qmd     # Survival analysis
  finance.qmd      # Risk assessment
```

#### Features
- Interactive code chunks
- Mathematical equations (native Quarto)
- Embedded shinylive dashboard
- Cross-references and citations

### 4. Targets Pipeline Examples

**Reproducible analysis workflows**

#### Pipeline Components
```r
R/tar_plans/
  plan_mills_simulation.R    # Simulate Mills ratios
  plan_distribution_compare.R # Compare distributions
  plan_hazard_analysis.R      # Hazard function analysis
  plan_dashboard_data.R       # Prepare dashboard data
```

#### Example Pipeline
- Load data
- Calculate Mills ratios for multiple distributions
- Compare tail thickness
- Generate plots
- Create report

## File Structure

```
millsratio/
├── inst/
│   └── shiny/
│       ├── ui_simple.R (update with hazard page)
│       └── server_simple.R (add hazard calculations)
├── vignettes/
│   ├── shinylive/
│   │   └── app.R (shinylive version)
│   └── articles/
│       └── hazard-connection.qmd
├── _quarto.yml (new)
├── index.qmd (new)
├── R/
│   ├── hazard_functions.R (new)
│   └── tar_plans/
│       ├── plan_mills_simulation.R (new)
│       └── plan_hazard_analysis.R (new)
└── _targets.R (update)
```

## Success Criteria

- [ ] Dashboard has functional hazard function page with math and code
- [ ] Shinylive app runs in browser without R
- [ ] Quarto website builds and deploys
- [ ] Targets pipeline runs end-to-end
- [ ] All documentation includes tidyverse examples

## Priority Order

1. **HIGH**: Add hazard function page to dashboard (immediate value)
2. **HIGH**: Create basic Quarto website structure
3. **MEDIUM**: Set up targets pipeline examples
4. **MEDIUM**: Deploy shinylive version

## Technical Considerations

### Hazard Function Implementation
```r
#' Calculate hazard function from Mills ratio
#' @export
hazard_from_mills <- function(mills_ratio) {
  1 / mills_ratio
}

#' Calculate hazard function directly
#' @export
hazard_function <- function(x, distribution = "normal", ...) {
  f <- switch(distribution,
    normal = dnorm(x, ...),
    t = dt(x, ...),
    exp = dexp(x, ...)
  )

  survival <- switch(distribution,
    normal = pnorm(x, ..., lower.tail = FALSE),
    t = pt(x, ..., lower.tail = FALSE),
    exp = pexp(x, ..., lower.tail = FALSE)
  )

  f / survival
}
```

### Dashboard Page Structure
- Tab 1: Theory - Mathematical relationship
- Tab 2: Interactive - Explore different distributions
- Tab 3: Code - Tidyverse examples
- Tab 4: Applications - Real-world uses

## Dependencies to Add

For Quarto website:
- quarto (system dependency)

For shinylive:
- shinylive (R package)
- webR (build dependency)

Already have:
- shiny, bslib (dashboard)
- targets (pipelines)
- tidyverse packages

## Estimated Effort

- Hazard function page: 1-2 hours
- Quarto website setup: 1 hour
- Targets pipelines: 1 hour
- Shinylive deployment: 1-2 hours

Total: ~5 hours of development