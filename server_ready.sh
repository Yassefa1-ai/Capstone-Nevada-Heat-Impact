#!/bin/bash

# --- Capstone: Nevada Heat Impact - Server Execution Script ---
set -e 

echo "-------------------------------------------------------"
echo "🚀 Initializing Nevada Heat Impact Prediction Pipeline"
echo "-------------------------------------------------------"

# 1. Handle Virtual Environment
if [ ! -d ".venv" ]; then
    echo "🛠️ Creating virtual environment..."
    python3 -m venv .venv
fi

echo "🔌 Activating virtual environment..."
source .venv/bin/activate

# 2. Install Dependencies
echo "📦 Step 1: Installing Legacy-Compatible dependencies..."
# Force NumPy 1.26.4 to support x86-64-v1 (Common KVM/Older CPUs)
# This prevents the 'NumPy was built with baseline optimizations (X86_V2)' error.
python3 -m pip install --upgrade pip
python3 -m pip install --quiet "numpy<2.0.0" 
python3 -m pip install --quiet pandas matplotlib seaborn statsmodels \
    scikit-learn openpyxl imbalanced-learn jupyter nbconvert

# 3. Execute Overdose Notebook
echo "💉 Step 2: Executing Overdose Time Series Model..."
jupyter nbconvert --to notebook --execute --inplace overdose_time_series.ipynb

# 4. Execute Assault Notebook
echo "👊 Step 3: Executing Assault Time Series Model..."
jupyter nbconvert --to notebook --execute --inplace assault_time_series.ipynb

echo "-------------------------------------------------------"
echo "✅ Execution Complete!"
echo "-------------------------------------------------------"
