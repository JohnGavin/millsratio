# Plan: Fix millsratio CI Failures

## Problem Statement

The millsratio package has critical CI failures preventing installation and use:
1. R CMD check fails on all platforms
2. Nix check workflow fails
3. test-coverage fails (missing CODECOV_TOKEN)

## Current Status

- Website: ✅ Deployed at https://johngavin.github.io/millsratio/
- R CMD check: ❌ Fails on all 5 platforms
- Nix check: ❌ Build fails in CI
- Test coverage: ❌ Missing CODECOV_TOKEN
- Local tests: ✅ 80/80 pass

## Root Causes Identified

1. **R CMD check failures**: Unknown - need to investigate logs
2. **Nix check failure**: Nix environment not building in CI
3. **Coverage failure**: Missing CODECOV_TOKEN secret

## Solution Plan

### Step 1: Investigate R CMD Check Failures
- Check job logs at https://github.com/JohnGavin/millsratio/actions
- Identify specific errors
- Fix identified issues

### Step 2: Fix Nix CI Build
- Review default-ci.nix configuration
- Ensure all dependencies are properly specified
- Test locally with nix-build

### Step 3: Add CODECOV_TOKEN
- Get token from https://codecov.io
- Add to repository secrets
- Name: CODECOV_TOKEN

### Step 4: Remove Multi-Platform CI
- We don't need Windows/Mac/Linux matrix
- Keep only Nix-based single platform check

## Implementation Steps (9-Step Workflow)

0. **Design & Plan** ✓ This document
1. **Create Issue**: Document CI failures
2. **Create Branch**: `fix-ci-failures`
3. **Make Changes**: Fix identified issues
4. **Run Checks**: Local devtools::check()
5. **Push Cachix**: If using Cachix
6. **Push GitHub**: Push branch
7. **Wait for CI**: Monitor Nix workflows only
8. **Merge PR**: After CI passes
9. **Log Everything**: Document in R/dev/issues/

## Success Criteria

- [ ] Nix check passes
- [ ] Test coverage uploads successfully
- [ ] No r-lib/actions multi-platform tests
- [ ] Package can be installed from GitHub

## Priority

1. HIGH: Fix Nix check (reproducible builds)
2. MEDIUM: Add CODECOV_TOKEN
3. LOW: Clean up unused workflows