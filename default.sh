#!/usr/bin/env bash
# =============================================================================
# Mills Ratio Package - Nix Environment with Persistent GC Root
# =============================================================================
#
# PURPOSE: Creates a reproducible Nix environment with:
# - All R packages from DESCRIPTION file
# - Persistent garbage collection (GC) root to prevent package deletion
# - Fast subsequent runs (seconds after first build)
#
# USAGE:
#   chmod +x default.sh
#   ./default.sh
#
# To force rebuild: rm nix-shell-root && ./default.sh
#
# =============================================================================

set -euo pipefail

# Define paths
PROJECT_PATH="$(pwd)"
GC_ROOT_PATH="$PROJECT_PATH/nix-shell-root"
NIX_FILE="$PROJECT_PATH/default.nix"
DESCRIPTION_FILE="$PROJECT_PATH/DESCRIPTION"

echo "==================================="
echo "Mills Ratio Package - Nix Setup"
echo "==================================="
echo ""

# Check if we're in the right directory
if [ ! -f "$DESCRIPTION_FILE" ]; then
    echo "Error: DESCRIPTION file not found."
    echo "Please run this script from the package root directory."
    exit 1
fi

# Step 1: Generate default.nix if needed
echo "=== STEP 1: Generate default.nix from DESCRIPTION ==="

NEED_REGEN=false

# Check if default.nix needs regeneration
if [ ! -f "$NIX_FILE" ]; then
    echo "default.nix does not exist."
    NEED_REGEN=true
elif [ ! -s "$NIX_FILE" ]; then
    echo "default.nix exists but is empty."
    NEED_REGEN=true
elif [ "$DESCRIPTION_FILE" -nt "$NIX_FILE" ]; then
    echo "DESCRIPTION has been modified since default.nix was generated."
    NEED_REGEN=true
else
    echo "default.nix is up to date."
fi

if [ "$NEED_REGEN" = true ]; then
    echo "Generating default.nix from DESCRIPTION..."

    # Check if R and rix are available
    if command -v R >/dev/null 2>&1; then
        if [ -f "default.R" ]; then
            R --vanilla --quiet -e 'source("default.R")' 2>/dev/null || {
                echo "Warning: Could not generate default.nix with R"
                echo "Using pre-defined default.nix instead..."
                NEED_REGEN=false
            }
        else
            echo "default.R not found, creating minimal default.nix..."
            NEED_REGEN=false
        fi
    else
        echo "R not found, creating minimal default.nix..."
        NEED_REGEN=false
    fi
fi

# If still no default.nix, create a minimal one
if [ ! -f "$NIX_FILE" ]; then
    echo "Creating minimal default.nix..."
    cat > "$NIX_FILE" << 'EOF'
let
  pkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {};

  rpkgs = with pkgs.rPackages; [
    # Core dependencies from DESCRIPTION
    ggplot2
    dplyr
    tidyr
    purrr
    shiny
    bslib
    plotly
    DT

    # Development dependencies
    testthat
    knitr
    rmarkdown
    covr
    scales
    htmlwidgets

    # Package development
    devtools
    usethis
    pkgload
    roxygen2

    # Additional useful packages
    targets
    quarto
  ];

  system_packages = with pkgs; [
    R
    rstudio
    quarto
  ];

in
pkgs.mkShell {
  buildInputs = system_packages ++ rpkgs;

  shellHook = ''
    echo ""
    echo "==============================================="
    echo "Mills Ratio Package - Nix Environment"
    echo "==============================================="
    echo ""
    echo "R version: $(R --version | head -n 1)"
    echo ""
    echo "To work with the package:"
    echo "  R"
    echo "  > devtools::load_all()"
    echo "  > launch_dashboard_no_browser()"
    echo ""
    echo "To run the targets pipeline:"
    echo "  > targets::tar_make()"
    echo ""
    export IN_NIX_SHELL=impure
  '';
}
EOF
fi

# Step 2: Build shell with persistent GC root
echo ""
echo "=== STEP 2: Build shell and create persistent GC root ==="

# Check if GC root already exists and is valid
if [ -L "$GC_ROOT_PATH" ] && [ -e "$GC_ROOT_PATH" ]; then
    STORE_PATH=$(readlink -f "$GC_ROOT_PATH")
    echo "✓ Using existing GC root"
    echo "  Symlink: $GC_ROOT_PATH"
    echo "  Points to: $STORE_PATH"
    echo ""
    echo "  This is fast because packages are already built!"
    echo "  To force rebuild: rm $GC_ROOT_PATH && ./default.sh"
else
    # Build the shell derivation and create GC root symlink atomically
    # The -o flag creates the symlink AND protects from garbage collection
    echo "Building Nix environment (first run may take a while)..."

    if command -v cachix >/dev/null 2>&1; then
        echo "Using cachix for faster downloads..."
        cachix use rstats-on-nix 2>/dev/null || true
    fi

    if ! nix-build "$NIX_FILE" \
        -o "$GC_ROOT_PATH" \
        --cores 4; then
        echo "ERROR: nix-build failed"
        exit 1
    fi

    if [ ! -L "$GC_ROOT_PATH" ]; then
        echo "ERROR: Failed to create GC root at $GC_ROOT_PATH"
        exit 1
    fi

    STORE_PATH=$(readlink -f "$GC_ROOT_PATH")
    echo ""
    echo "✓ SUCCESS: Persistent GC Root created"
    echo "  Symlink: $GC_ROOT_PATH"
    echo "  Points to: $STORE_PATH"
fi

# Step 3: Verify GC root is registered
echo "=== STEP 3: Verify GC root is registered ==="
if nix-store --gc --print-roots | grep -q "$GC_ROOT_PATH"; then
    echo "✓ GC root is properly registered with Nix"
    echo "  Your packages are protected from garbage collection"
else
    echo "⚠ WARNING: GC root may not be properly registered"
fi

# Step 4: Enter the Nix shell
echo ""
echo "=== STEP 4: Entering Nix shell ==="
echo ""

# Save user's shell before Nix changes it
USER_SHELL="$SHELL"

# Use nix-shell with the GC root
if [ -n "${IN_NIX_SHELL:-}" ]; then
    echo "Already in a Nix shell. Run 'R' to start working."
else
    echo "Type 'exit' to leave the Nix shell"
    echo ""

    # Enter shell using the original nix file (GC root protects dependencies)
    exec nix-shell "$NIX_FILE" --command "$USER_SHELL -i"
fi