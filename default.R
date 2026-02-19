# Generate default.nix from DESCRIPTION file
# This ensures all package dependencies are available in the Nix environment

library(rix)

# Read DESCRIPTION to get package dependencies
desc <- read.dcf("DESCRIPTION")

# Extract Imports
imports_raw <- desc[, "Imports"]
imports <- if (!is.na(imports_raw) && nchar(imports_raw) > 0) {
  # Parse the Imports field
  imports_split <- strsplit(imports_raw, ",\\s*")[[1]]
  # Remove version specifications
  gsub("\\s*\\([^)]*\\)", "", imports_split)
} else {
  character(0)
}

# Extract Suggests
suggests_raw <- desc[, "Suggests"]
suggests <- if (!is.na(suggests_raw) && nchar(suggests_raw) > 0) {
  suggests_split <- strsplit(suggests_raw, ",\\s*")[[1]]
  gsub("\\s*\\([^)]*\\)", "", suggests_split)
} else {
  character(0)
}

# Combine all packages
all_packages <- unique(c(imports, suggests))

# Remove packages that are part of base R
base_packages <- c("stats", "utils", "graphics", "grDevices", "methods", "base")
r_packages <- setdiff(all_packages, base_packages)

# Add essential developer tools (not in DESCRIPTION but needed for development)
dev_tools <- c("devtools", "pkgload")
r_packages <- unique(c(r_packages, dev_tools))

# Add rwasm as GitHub package
gh_pkgs <- list(
  list(
    package_name = "rwasm",
    repo_url = "https://github.com/r-wasm/rwasm",
    commit = "ebd68f7a1eb3378dfc968dd7ddcd3f412c34e8bb"  # Latest as of 2026-01-31
  )
)

cat("Generating default.nix with the following packages:\n")
cat("From DESCRIPTION:\n")
cat(paste(" -", setdiff(r_packages, dev_tools)), sep = "\n")
cat("Developer tools:\n")
cat(paste(" -", dev_tools), sep = "\n")
cat("GitHub packages:\n")
cat(" - rwasm (r-wasm/rwasm)\n")

# Generate default.nix
rix(
  date = "2026-01-05",
  r_pkgs = r_packages,
  git_pkgs = gh_pkgs,
  system_pkgs = NULL,  # No extra system packages needed
  ide = "none",  # NEVER use "rstudio" in project-specific shells - dev shell provides IDE
  project_path = ".",
  overwrite = TRUE
)

cat("\ndefault.nix created successfully!\n")
cat("Run ./default.sh to enter the Nix environment.\n")
