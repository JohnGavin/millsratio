# Fix Issue #3: Remove non-ASCII characters from R/hazard_functions.R
# Non-ASCII characters (→ and ∞) cause R CMD check WARNING in CI
# Replace with ASCII equivalents: -> and Inf

library(readr)

file_path <- "R/hazard_functions.R"

# Read the file
lines <- readLines(file_path, warn = FALSE)

# Replace non-ASCII characters with ASCII equivalents
# → (U+2192) becomes ->
# ∞ (U+221E) becomes Inf
lines[174] <- '      normal = "h(x) ~ x as x -> Inf",'
lines[175] <- '      t = paste0("h(x) ~ ", df + 1, "/", df, "/x as x -> Inf"),'

# Write back
writeLines(lines, file_path)

cat("Fixed non-ASCII characters in", file_path, "\n")

# Verify the fix
cat("\nVerifying with tools::showNonASCIIfile():\n")
result <- tools::showNonASCIIfile(file_path)
if (length(result) == 0) {
  cat("No non-ASCII characters found - fix successful!\n")
} else {
  cat("Still has non-ASCII characters:\n")
  print(result)
}
