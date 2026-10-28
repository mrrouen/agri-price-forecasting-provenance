# R/05_verify_pipeline.R - Master Pipeline Audit Verification
library(openssl)
library(digest)
library(jsonlite)

message(">>> AUDIT GATE: VERIFYING ALL PIPELINE MANIFESTS <<<")

verify_manifest <- function(manifest_json_path, pub_path = "keys/public_key.pem") {
  if (!file.exists(manifest_json_path)) stop("Manifest file missing: ", manifest_json_path)
  
  parsed <- jsonlite::fromJSON(manifest_json_path, simplifyVector = FALSE)
  manifest_data <- parsed$manifest
  sig_hex <- as.character(parsed$signature_hex[[1]])
  
  # Check file hash match
  actual_hash <- digest::digest(manifest_data$artifact_path, algo = "sha256", file = TRUE)
  if (actual_hash != manifest_data$sha256_hash) {
    stop("SECURITY ALERT: Artifact byte mismatch in ", manifest_data$artifact_path)
  }
  
  # Check ECDSA signature
  manifest_json <- jsonlite::toJSON(manifest_data, auto_unbox = TRUE, pretty = TRUE)
  manifest_bytes <- charToRaw(manifest_json)
  sig_raw <- parse_hex(sig_hex)
  
  pub_key <- read_pubkey(pub_path)
  is_valid <- openssl::signature_verify(manifest_bytes, sig_raw, hash = sha256, pubkey = pub_key)
  
  if (!is_valid) {
    stop("SECURITY ALERT: Invalid ECDSA signature in ", manifest_json_path)
  }
  return(TRUE)
}

# Verify all created JSON manifests
manifest_files <- list.files("manifests", pattern = "\\.json$", full.names = TRUE)
for (m in manifest_files) {
  verify_manifest(m)
  message("✔ VERIFIED: ", m)
}

message("\n✔ PIPELINE AUDIT COMPLETE: ALL ARTIFACTS VERIFIED & UNTAMPERED\n")