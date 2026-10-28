# Master Pipeline Execution Script
message(">>> STARTING CRIMSON-SECURE FULL PIPELINE EXECUTION <<<\n")

# Stage 1: Generate SHA-256 Manifest
message("--> [1/6] Generating Cryptographic Manifests...")
source("R/01_manifest_gen.R")

# Stage 2: Verification Gate Circuit Breaker
message("--> [2/6] Running Data Verification Gate...")
source("R/02_verification_gate.R")

# Stage 3: Train SARIMAX & Baselines
message("--> [3/6] Fitting SARIMAX Models...")
source("R/03_sarimax_models.R")

# Stage 4: Train Prophet Models & Export Forecasts
message("--> [4/6] Fitting Prophet Models & Exporting Plots...")
source("R/04_prophet_models.R")

# Stage 5: Master Cryptographic Audit
message("--> [5/6] Running End-to-End Audit Verification...")
source("R/05_verify_pipeline.R")

# Stage 6: Evaluate Model Performance & Price Spikes
message("--> [6/6] Evaluating Accuracy Metrics & Sensitivity...")
source("R/06_evaluate_models.R")

message("\n")
message("PIPELINE EXECUTED SUCCESSFULLY")
message("")