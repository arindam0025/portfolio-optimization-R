# =======================
# 1. Install & Load Packages
# =======================
packages <- c("quantmod", "PerformanceAnalytics", "tidyverse", "zoo", "lubridate")
installed <- rownames(installed.packages())

for (p in packages) {
  if (!(p %in% installed)) install.packages(p)
  library(p, character.only = TRUE)
}

# =======================
# 2. Define Stock Tickers & Benchmark
# =======================
tickers <- c("INFY.BO", "TCS.BO", "HDFCBANK.BO", "ICICIBANK.BO", "RELIANCE.BO",
             "SBIN.BO", "ITC.BO", "AXISBANK.BO", "KOTAKBANK.BO", "BHARTIARTL.BO",
             "LT.BO", "SUNPHARMA.BO", "ASIANPAINT.BO", "MARUTI.BO", "TECHM.BO",
             "HINDUNILVR.BO", "BAJFINANCE.BO", "ULTRACEMCO.BO", "POWERGRID.BO",
             "NTPC.BO", "ONGC.BO", "DRREDDY.BO", "TITAN.BO", "JSWSTEEL.BO",
             "ADANIPORTS.BO", "COALINDIA.BO", "BPCL.BO", "HEROMOTOCO.BO", "GRASIM.BO")
benchmark <- "^NSEI"

# =======================
# 3. Download Historical Price Data (Last 5 Years)
# =======================
get_stock_data <- function(symbol) {
  tryCatch({
    getSymbols(symbol, src = "yahoo", from = Sys.Date() - years(5), auto.assign = FALSE)
  }, error = function(e) NULL)
}

portfolio_data <- map(tickers, get_stock_data)
names(portfolio_data) <- tickers
portfolio_data <- compact(portfolio_data)  # Remove NULLs

nifty_data <- get_stock_data(benchmark)

# =======================
# 4. Calculate Daily Returns
# =======================
returns <- map(portfolio_data, ~ dailyReturn(Cl(.x))) %>%
  reduce(merge, all = FALSE)
returns <- na.omit(returns)

nifty_returns <- dailyReturn(Cl(nifty_data))
nifty_returns <- na.omit(nifty_returns)

# =======================
# 5. Equal-Weighted Portfolio Return
# =======================
portfolio_returns <- rowMeans(returns)
portfolio_returns <- xts(portfolio_returns, order.by = index(returns))

# =======================
# 6. Cumulative Returns
# =======================
cumulative_portfolio <- cumprod(1 + portfolio_returns)
cumulative_nifty <- cumprod(1 + nifty_returns)

# =======================
# 7. Plot Cumulative Returns (Corrected)
# =======================
combined_cum_returns <- merge(cumulative_portfolio, cumulative_nifty, join = "inner")
colnames(combined_cum_returns) <- c("Portfolio", "Nifty")

df <- data.frame(
  Date = index(combined_cum_returns),
  coredata(combined_cum_returns)
)

library(tidyr)
df_long <- pivot_longer(df, cols = c("Portfolio", "Nifty"),
                        names_to = "Index", values_to = "Cumulative_Return")

library(ggplot2)
ggplot(df_long, aes(x = Date, y = Cumulative_Return, color = Index)) +
  geom_line(size = 1.2) +
  labs(title = "Cumulative Returns: Portfolio vs Nifty 50",
       x = "Date", y = "Cumulative Returns") +
  theme_minimal()

# =======================
# 8. Risk Metrics
# =======================
VaR_95 <- VaR(portfolio_returns, p = 0.95, method = "historical")
ES_95 <- ES(portfolio_returns, p = 0.95, method = "historical")
Sharpe <- SharpeRatio(portfolio_returns, Rf = 0)
Sortino <- SortinoRatio(portfolio_returns, Rf = 0)
Calmar <- CalmarRatio(portfolio_returns)

# =======================
# 9. Export Report
# =======================
report <- list(
  VaR_95 = VaR_95,
  Expected_Shortfall_95 = ES_95,
  Sharpe_Ratio = Sharpe,
  Sortino_Ratio = Sortino,
  Calmar_Ratio = Calmar
)

print(report)
capture.output(report, file = "Portfolio_Analysis_Report.txt")

# =======================
# 10. Save Plot to File (Optional)
# =======================
ggsave("Cumulative_Returns_Plot.png", width = 8, height = 6)

