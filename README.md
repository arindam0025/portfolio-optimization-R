# 📊 Quantitative Finance Analytics in R

This repository contains a suite of R scripts focused on equity market analysis, risk modeling, and financial performance evaluation. These tools leverage historical stock data to derive insights on return behavior, volatility, market risk, and pricing models.

---

## 📁 Contents

### 1. **`EquityPortfolio_RiskMetrics_India.R`**
A comprehensive script that:
- Constructs an equal-weighted portfolio from 29 Indian blue-chip stocks.
- Calculates and plots cumulative returns vs Nifty 50 over 5 years.
- Computes key risk metrics:
  - Value at Risk (VaR)
  - Expected Shortfall (ES)
  - Sharpe Ratio
  - Sortino Ratio
  - Calmar Ratio
- Exports a performance report and plots.

🛠️ **Skills & Tools**: Portfolio analytics, `quantmod`, `PerformanceAnalytics`, `ggplot2`, risk management.

---

### 2. **`MultiFactor_Modeling_RiskPricing.R`**
A multi-purpose script that combines:
- **CAPM Regression** for Reliance vs Nifty 50.
- **Fama-French 3-Factor Modeling** (using synthetic factors).
- **Risk Metric Visualizations** (bar charts for VaR, Sharpe, etc.).
- **Black-Scholes Option Pricing Model** for call and put options.

🧠 **Skills & Tools**: Linear modeling, regression, factor modeling, option pricing, data visualization.

---

### 3. **`Portfolio_Performance_Comparison_Wipro_HCL_vs_Nifty.R`**
A focused analysis on two major Indian IT companies:
- Fetches and visualizes adjusted close prices.
- Compares Wipro & HCLTech volatility, variance, and monthly returns.
- Builds a simple portfolio and compares its performance to Nifty 50.

📈 **Skills & Tools**: Time series comparison, cumulative return analysis, portfolio blending.

---

## ▶️ Getting Started

### Prerequisites
Install the required R packages if not already present:
```r
install.packages(c("quantmod", "PerformanceAnalytics", "tidyverse", "zoo", "lubridate", "ggplot2", "xts"))


🔶 1. Golden Cross / Death Cross Strategy (TCS) Indicators Used:

SMA50 (50-day Simple Moving Average)

SMA200 (200-day Simple Moving Average)

Logic:

A Golden Cross occurs when SMA50 crosses above SMA200 → Signal to buy

A Death Cross occurs when SMA50 crosses below SMA200 → Signal to sell

Visualization:

Line plot with SMA50, SMA200, and close price

Green upward arrows for Golden Cross

Red downward arrows for Death Cross

🔶 2. Bollinger Bands Strategy (AAPL) Indicators Used:

SMA20 (20-day Simple Moving Average)

Upper/Lower Bands: SMA ± 2× standard deviation

Logic:

Buy when the price hits the lower band

Sell when the price hits the upper band

Visualization:

Price chart with Bollinger Bands

Green arrow for buy signal at the lower band

Red arrow for sell signal at the upper band

🔶 3. Simulated Data Bollinger Band Strategy Purpose: Backtest mean reversion on a simulated price series

Method:

Generated synthetic stock data using normal returns

Applied Bollinger Bands (20-day SMA ± 2 std dev)

Generated buy/sell signals similarly as above

Visualization:

Candlestick-style price chart with bands and shaded area

Buy/Sell signals marked with arrows

🔶 4. RSI Strategy (TCS) Indicator Used:

RSI (Relative Strength Index) with a period of 14

Logic:

Buy when RSI < 30 (oversold)

Sell when RSI > 70 (overbought)

Visualization:

RSI line with horizontal lines at 30 and 70

Green arrow for buy

Red arrow for sell

🔶 5. Breakout Strategy with Volume Confirmation (TCS) Indicators Used:

20-day High

20-day Average Volume

Logic:

A breakout buy is triggered when:

Current close > 20-day high

Current volume > 1.5× 20-day average volume

Visualization:

Close price line

Volume as bars

Green arrow for breakout signals
