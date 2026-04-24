
---

## High-level overview

This is a **weather-driven public health prediction system** for Southern Nevada. The project asks two questions: *How many incidents will happen tomorrow?* (time series forecasting) and *Is today a high-risk day?* (classification). It covers three incident types — overdoses, assaults, and heat-related deaths — and links all of them to ambient weather conditions.

The core hypothesis is that heat stress drives incident spikes, so weather variables like temperature, UV index, dew point, and engineered features like heatwave flags are used to build better predictions than a pure count-based model would allow.

---

## Technical deep dive

**The pipeline (same for both notebooks):**

1. **Data prep** — Load incident CSV with a datetime column, group by day to get daily counts, compute daily weather averages, merge into one time series DataFrame indexed by date.

2. **Stationarity check** — Run an Augmented Dickey-Fuller test. Both notebooks reject the null (p < 0.05), meaning the series is stationary enough to proceed with ARIMA-family models without differencing the series manually.

3. **Model progression** — The notebooks iterate from simple to complex: pure ARIMA → ARIMAX with temperature → SARIMAX grid search → adding more weather features → feature engineering → full enhanced model. Each step is evaluated by AIC (lower = better model fit penalized for complexity) and MAE/RMSE on fitted values.

4. **Feature engineering** — This is the most transferable part. The notebooks create: lag features (yesterday's count, last week's count), rolling means (3-day, 7-day), heatwave binary flags (rolling window of days above threshold), temperature category bins, cyclical day-of-week encoding (sin/cos), US holiday flags, and interaction terms (temperature × UV index). The **Lasso-SARIMAX** combination was the clear winner — LassoCV automatically zeros out weak features, then the trimmed feature set feeds a cleaner SARIMAX model.

5. **Classification** — Both notebooks define a binary target: days with ≥20 incidents = "high risk." The overdose notebook tries all three classifiers (Logistic, Naive Bayes, Random Forest) with and without oversampling. The assault notebook commits to Logistic Regression for interpretability and performs threshold tuning — intentionally lowering the decision threshold to maximize recall at the cost of precision, which is the right call for a public safety flagging system.

---

## What to change for a new dataset

The interactive widget above shows the four code locations you'd touch. The bigger conceptual question is whether your new data has a **datetime column** and **weather already merged in**. If the weather merge hasn't happened yet, that's the first preprocessing step — the notebooks assume it was done upstream. You'd join your incident data to a weather API (Open-Meteo was apparently used here, based on the column naming convention) on date and location.

The **heatwave thresholds** (90°F for moderate, 105°F for extreme in overdose; 100°F in assault) are Nevada-specific and should be revisited if the new dataset covers a different geography or climate.



## ARIMAX vs SARIMAX — the plain-language version

**ARIMA** on its own just looks at the past history of the thing you're predicting (overdose counts) and uses that pattern to forecast the future. The three numbers — AR(p), I(d), MA(q) — control how far back it looks, whether it adjusts for trends, and how much weight it gives to past prediction errors.

**ARIMAX** adds the "X" — external variables. In your notebook, that's temperature. You're telling the model: "when predicting tomorrow's overdose count, also factor in today's temperature." This is the first meaningful step from pure time series into something weather-aware.

**SARIMAX** adds a fourth layer on top of ARIMAX: seasonal patterns. In your case `seasonal_order=(1, 0, 1, 7)` tells it there's a weekly cycle — incidents on Mondays tend to look like previous Mondays, Fridays look like previous Fridays. The `7` is the period. Without this, the model treats every day the same and misses that weekend behavior is structurally different from weekday behavior.

---

## Lasso-SARIMAX — why it won

By the time you get to Model 7 in the overdose notebook, you're feeding SARIMAX roughly 13–15 features: lags, rolling means, heatwave flags, UV flags, day-of-week encodings, holiday flags, temperature buckets, and two interaction terms. The problem is that several of these are correlated with each other — `apparent_temperature_f` and `temperature_2m_f` move almost in lockstep, for example. SARIMAX doesn't handle correlated features well; it gets confused about which one is actually driving the signal, and the AIC suffers.

Lasso's penalty forces correlated or weak features to zero. What survives is a smaller, cleaner feature set where each variable is genuinely earning its spot. The SARIMAX model then fits on this trimmed set — fewer parameters, less overfitting, and the notebook confirmed: lowest AIC, lowest RMSE, lowest MAE of all models tested.

Hit the "Show Lasso result" button in the widget above to see which feature categories tend to get dropped (interaction terms and isolated flags) vs kept (lags, rolling means, and core temperature/UV). The exact features Lasso selects will shift when you run it on a new dataset — that's expected and desired behavior.