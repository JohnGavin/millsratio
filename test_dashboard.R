#!/usr/bin/env Rscript

# Test script for Mills Ratio Dashboard
# This script tests that the dashboard can be launched properly

library(millsratio)

cat("Mills Ratio Dashboard Test\n")
cat("===========================\n\n")

# Test 1: Check functions exist
cat("1. Checking dashboard functions exist...\n")
funcs <- c("launch_dashboard", "launch_dashboard_simple", "launch_dashboard_no_browser")
for (func in funcs) {
  if (exists(func, mode = "function")) {
    cat("   ✓", func, "exists\n")
  } else {
    cat("   ✗", func, "missing\n")
  }
}

# Test 2: Check shiny files exist
cat("\n2. Checking Shiny app files...\n")
app_dir <- system.file("shiny", package = "millsratio")
if (dir.exists(app_dir)) {
  files <- list.files(app_dir)
  required <- c("app.R", "ui.R", "server.R", "ui_simple.R", "server_simple.R")
  for (file in required) {
    if (file %in% files) {
      cat("   ✓", file, "exists\n")
    } else {
      cat("   ✗", file, "missing\n")
    }
  }
} else {
  cat("   ✗ Shiny directory not found\n")
}

# Test 3: Test core functions
cat("\n3. Testing core Mills ratio functions...\n")
x <- 2
cat("   Testing at x =", x, "\n")
cat("   - Normal:", round(mills_ratio_normal(x), 4), "\n")
cat("   - t(30):", round(mills_ratio_t(x, df = 30), 4), "\n")
cat("   - Exponential:", round(mills_ratio_exp(x), 4), "\n")

# Test 4: Verify t(30) paradox
cat("\n4. Verifying t(30) paradox...\n")
x_vals <- c(1, 2, 3, 4)
for (x in x_vals) {
  normal_m <- mills_ratio_normal(x)
  t30_m <- mills_ratio_t(x, df = 30)
  ratio <- t30_m / normal_m
  cat(sprintf("   x=%d: t(30)/Normal = %.3f\n", x, ratio))
}

cat("\n✓ All tests complete!\n\n")
cat("To launch the dashboard, run one of:\n")
cat("  - launch_dashboard_simple()        # Simplified, clean version\n")
cat("  - launch_dashboard()               # Original version\n")
cat("  - launch_dashboard_no_browser()    # Without browser auto-launch\n")
cat("\nThen navigate to http://127.0.0.1:4628\n")