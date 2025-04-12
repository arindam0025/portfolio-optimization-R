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

### 2. **`ultiFactor_Modeling_RiskPricing.R`**
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
