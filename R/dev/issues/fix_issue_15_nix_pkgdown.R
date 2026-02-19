# Fix for Issue #15: Nix segfault and pkgdown CI failure
# https://github.com/JohnGavin/millsratio/issues/15
#
# Problem 1: Nix segfault
#   targets and tarchetypes were not in DESCRIPTION Suggests,
#   so they were missing from default.nix. Running tar_make()
#   in the project nix-shell caused dyn.load segfaults due to
#   R version mismatch with packages from a different environment.
#
# Fix 1: Added targets, tarchetypes to DESCRIPTION Suggests.
#   Regenerated default.nix via Rscript default.R.
#
# Problem 2: pkgdown CI failure
#   .github/workflows/pkgdown.yaml used `needs: website` which
#   pulled all Suggests including shinylive (not on CRAN), causing
#   pkgdepends to deadlock. Also, pkgdown.yml (without underscore)
#   was stale and referenced non-existent functions.
#
# Fix 2: Deleted pkgdown.yaml workflow (per CLAUDE.md guidance:
#   build locally with pkgdown::build_site(), push to gh-pages).
#   Deleted stale pkgdown.yml. Added Config/Needs/website: pkgdown
#   to DESCRIPTION. Kept _pkgdown.yml (actual config, 3 lines).
#
# Version bump: 0.2.0 -> 0.2.1

# Verification steps:
# 1. nix-shell default.nix --run "Rscript -e 'library(targets); cat(\"OK\\n\")'"
# 2. nix-shell default.nix --run "Rscript -e 'targets::tar_make()'"
# 3. devtools::test() - all tests pass
# 4. devtools::check() - 0 errors, 0 warnings
# 5. No pkgdown workflow in .github/workflows/
