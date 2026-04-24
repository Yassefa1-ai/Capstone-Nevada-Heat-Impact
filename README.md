# Capstone: Nevada Heat Impact Prediction System

This project implements a weather-driven public health prediction system for Southern Nevada. It analyzes the relationship between extreme heat events, drug overdoses, and physical assaults to provide actionable public safety alerts.

## Project Structure
- `overdose_time_series.ipynb`: Time series modeling and risk classification for overdose incidents.
- `assault_time_series.ipynb`: Time series modeling and risk classification for assault incidents.
- `Heat Related 2021-2024.xlsx`: Historical heat-related mortality data.
- `Heat Related 2024 EOY Coroner-dataset.xlsx`: Updated 2024 mortality records.
- `Heat Deaths EOY 2025.xlsx`: Newly imported 2025 mortality records.
- `server_ready.sh`: Automation script for server-side execution.

## Setup & Execution

### Prerequisites
- Python 3.9+
- Pip (Python package manager)

### Quick Start (Server Execution)
To run the entire pipeline and generate the latest predictions on a server, execute the automation script:

```bash
chmod +x server_ready.sh
./server_ready.sh
```

### Execution Order
If running manually, execute the notebooks in the following order:
1. **`overdose_time_series.ipynb`**: Establishes correlation baselines and tests multiple classifiers.
2. **`assault_time_series.ipynb`**: Refines predictions using threshold-tuned Logistic Regression for public safety flagging.

## Data Pipeline Logic
The system follows a automated pipeline:
1. **Ingestion**: Combines historical and new Coroner (mortality) datasets, removes duplicates via `Case #`.
2. **Preprocessing**: Aggregates data into daily counts and merges with weather variables (`apparent_temperature_f`, `uv_index_clear_sky_`).
3. **Feature Engineering**: Creates lag variables, rolling means, and heatwave interaction terms.
4. **Modeling**: Uses SARIMAX (Seasonal AutoRegressive Integrated Moving Average with eXogenous regressors) for time series forecasting.
5. **Classification**: Categorizes days as "High Risk" (≥20 incidents) using machine learning classifiers.

## Interpreting Results
After execution, open the notebooks to view:
- **Primary Visualization**: A line chart comparing Incidents, Heat Deaths, and Temperature.
- **Correlation Matrix**: Statistical breakdown of heat's impact on incident rates.
- **Model Summary**: SARIMAX coefficients and AIC scores.
- **Classification Report**: Precision, Recall, and F1-score for High-Risk day detection.

---
**Note**: Ensure that the `combined_all.csv` (weather/incident data) is present in the `../Data/Combined Datasets/` directory relative to the notebooks for full historical analysis.
