#!/bin/bash

# --- Capstone: Nevada Heat Impact - Server Execution Script ---
set -e

echo "-------------------------------------------------------"
echo "🚀 Initializing Nevada Heat Impact Prediction Pipeline"
echo "-------------------------------------------------------"

# 1. Handle Virtual Environment
if [ ! -d ".venv" ]; then
    echo "🛠️  Creating virtual environment..."
    python3 -m venv .venv
fi

echo "🔌 Activating virtual environment..."
source .venv/bin/activate

# 2. Install Dependencies
echo "📦 Step 1: Installing dependencies..."
# Force NumPy <2.0 to support x86-64-v1 (common KVM/older CPUs).
# This prevents the 'NumPy was built with baseline optimizations (X86_V2)' error.
python3 -m pip install --upgrade pip --quiet
python3 -m pip install --quiet "numpy<2.0.0"
python3 -m pip install --quiet \
    pandas \
    matplotlib \
    seaborn \
    statsmodels \
    scikit-learn \
    openpyxl \
    imbalanced-learn \
    jupyter \
    nbconvert \
    holidays   # required by weekday/holiday feature engineering in both notebooks

# 3. Check that at least one required data source is present and warn clearly if not
echo ""
echo "🗂️  Checking data files..."
MISSING=0

if [ ! -f "../Data/Overdose Data/overdose_weather_merge.csv" ]; then
    echo "  ⚠️  WARNING: overdose_weather_merge.csv not found at ../Data/Overdose Data/"
    echo "      The overdose notebook will run but all models will be skipped (no incident data)."
    MISSING=1
fi

if [ ! -f "../Data/Combined Datasets/combined_all.csv" ]; then
    echo "  ⚠️  WARNING: combined_all.csv not found at ../Data/Combined Datasets/"
    echo "      The assault notebook will run but all models will be skipped (no incident data)."
    MISSING=1
fi

# Heat deaths: accept CSV or any of the Excel variants
HEAT_FOUND=0
for heat_path in \
    "Heat_Related_2021-2024.csv" \
    "../Data/Heat_Related_2021-2024.csv" \
    "Heat Related 2021-2024.xlsx" \
    "Heat Related 2024 EOY Coroner-dataset.xlsx"; do
    if [ -f "$heat_path" ]; then
        HEAT_FOUND=1
        break
    fi
done

if [ "$HEAT_FOUND" -eq 0 ]; then
    echo "  ⚠️  WARNING: No heat-related deaths file found."
    echo "      Expected Heat_Related_2021-2024.csv in the working directory or ../Data/."
fi

if [ "$MISSING" -eq 1 ]; then
    echo ""
    echo "  ℹ️  Continuing execution — notebooks are guarded against missing data."
    echo "      Place the missing files and re-run to get full model output."
fi
echo ""

# 4. Execute Overdose Notebook
# --ExecutePreprocessor.timeout=600  → 10-minute per-cell timeout (SARIMAX grid search is slow)
# --allow-errors                     → log cell errors as outputs instead of aborting the run
echo "💉 Step 2: Executing Overdose Time Series Model..."
jupyter nbconvert \
    --to notebook \
    --execute \
    --inplace \
    --ExecutePreprocessor.timeout=600 \
    --allow-errors \
    overdose_time_series.ipynb

# 5. Execute Assault Notebook
echo "👊 Step 3: Executing Assault Time Series Model..."
jupyter nbconvert \
    --to notebook \
    --execute \
    --inplace \
    --ExecutePreprocessor.timeout=600 \
    --allow-errors \
    assault_time_series.ipynb

echo ""
echo "-------------------------------------------------------"
echo "✅ Execution Complete!"
echo "   Open the .ipynb files to review outputs and any"
echo "   warnings about missing data files."
echo "-------------------------------------------------------"
