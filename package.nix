# package.nix - Build millsratio as an installable R package derivation
#
# Used by push_to_cachix.sh to build and push to johngavin cachix.
# Uses same nixpkgs pin as default.nix (2026-01-05).
#
# Usage:
#   nix-build package.nix --no-out-link
#   # Push ONLY this package (not deps!) - see push_to_cachix.sh

let
  pkgs = import (fetchTarball "https://github.com/rstats-on-nix/nixpkgs/archive/2026-01-05.tar.gz") {};

  millsratio = pkgs.rPackages.buildRPackage {
    name = "millsratio";
    src = ./.;

    # Imports from DESCRIPTION
    propagatedBuildInputs = with pkgs.rPackages; [
      dplyr
      ggplot2
      plotly
      scales
      shiny
      tidyr
    ];
  };

in millsratio
