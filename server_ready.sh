#!/bin/bash

# --- Capstone: Nevada Heat Impact - Server Execution Script ---
# This script automates the environment setup and execution of the 
# time series modeling notebooks for Overdoses and Assaults.

set -e # Exit on error

echo "-------------------------------------------------------"
echo "🚀 Initializing Nevada Heat Impact Prediction Pipeline"
echo "-------------------------------------------------------"

# 1. Install Dependencies
echo "📦 Step 1: Installing/Updating Python dependencies..."
python3 -m pip install --quiet pandas numpy matplotlib seaborn statsmodels \
    scikit-learn openpyxl imbalanced-learn jupyter nbconvert

# 2. Execute Overdose Notebook
echo "💉 Step 2: Executing Overdose Time Series Model..."
# We use --inplace to update the notebook with latest results and predictions
jupyter nbconvert --to notebook --execute --inplace overdose_time_series.ipynb

# 3. Execute Assault Notebook
echo "👊 Step 3: Executing Assault Time Series Model..."
jupyter nbconvert --to notebook --execute --inplace assault_time_series.ipynb

echo "-------------------------------------------------------"
echo "✅ Execution Complete!"
echo "-------------------------------------------------------"
echo "Latest predictions and model summaries are now saved inside:"
echo " - overdose_time_series.ipynb"
echo " - assault_time_series.ipynb"
echo "-------------------------------------------------------"
