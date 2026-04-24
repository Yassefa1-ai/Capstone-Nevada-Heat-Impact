#!/bin/bash

# --- Capstone: Nevada Heat Impact - Server Execution Script ---
set -e

echo "-------------------------------------------------------"
echo "🚀 Initializing Nevada Heat Impact Prediction Pipeline"
echo "-------------------------------------------------------"

# 1. Always recreate the virtual environment fresh to avoid pip corruption
echo "🛠️  Recreating virtual environment (ensures clean pip)..."
rm -rf .venv
python3 -m venv .venv

echo "🔌 Activating virtual environment..."
source .venv/bin/activate

# 2. Bootstrap pip using the system ensurepip (bypasses the broken venv pip entirely)
echo "📦 Step 1: Bootstrapping pip..."
python3 -m ensurepip --upgrade
python3 -m pip install --upgrade pip --quiet

# 3. Install dependencies
echo "📦 Step 2: Installing dependencies..."
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
    holidays

# 4. Pre-flight data file checks
echo ""
echo "🗂️  Checking data files..."
MISSING=0

if [ ! -f "../Data/Overdose Data/overdose_weather_merge.csv" ]; then
    echo "  ⚠️  overdose_weather_merge.csv not found at ../Data/Overdose Data/"
    echo "      Overdose models will be skipped."
    MISSING=1
fi

if [ ! -f "../Data/Combined Datasets/combined_all.csv" ]; then
    echo "  ⚠️  combined_all.csv not found at ../Data/Combined Datasets/"
    echo "      Assault models will be skipped."
    MISSING=1
fi

HEAT_FOUND=0
for heat_path in \
    "Heat_Related_2021-2024.csv" \
    "../Data/Heat_Related_2021-2024.csv" \
    "Heat_Related_2024_EOY_Coroner-dataset.xlsx" \
    "Heat Related 2024 EOY Coroner-dataset.xlsx" \
    "Heat_Deaths_EOY_2025__1_.xlsx" \
    "Heat_Deaths_EOY_2025.xlsx" \
    "Heat Deaths EOY 2025.xlsx"; do
    if [ -f "$heat_path" ]; then
        HEAT_FOUND=1
        echo "  ✅  Heat deaths source found: $heat_path"
        break
    fi
done

if [ "$HEAT_FOUND" -eq 0 ]; then
    echo "  ⚠️  No heat-related deaths file found."
    echo "      Place Heat_Related_2021-2024.csv or the EOY Excel files in this directory."
    MISSING=1
fi

if [ "$MISSING" -eq 1 ]; then
    echo ""
    echo "  ℹ️  Continuing — notebooks are guarded against missing data."
    echo "      Place missing files and re-run for full model output."
fi
echo ""

# 5. Execute Overdose Notebook
echo "💉 Step 3: Executing Overdose Time Series Model..."
jupyter nbconvert \
    --to notebook \
    --execute \
    --inplace \
    --ExecutePreprocessor.timeout=600 \
    --allow-errors \
    overdose_time_series.ipynb

# 6. Execute Assault Notebook
echo "👊 Step 4: Executing Assault Time Series Model..."
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
echo "   Open the .ipynb files to review outputs."
echo "-------------------------------------------------------"