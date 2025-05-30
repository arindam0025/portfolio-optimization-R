
packages <- c("PerformanceAnalytics", "quantmod", "ggplot2", "xts", "zoo", "tidyverse")
new_packages <- packages[!(packages %in% installed.packages()[, "Package"])]
if(length(new_packages)) install.packages(new_packages, dependencies = TRUE)

library(PerformanceAnalytics)
library(quantmod)
library(ggplot2)
library(xts)
library(zoo)
library(tidyverse)


fetch_stock_data <- function() {
  stocks <- c("RELIANCE.NS", "HDFCBANK.NS", "TCS.NS")
  start_date <- "2023-01-01"
  end_date <- Sys.Date()
  
  stock_data <- lapply(stocks, function(stock) {
    tryCatch(getSymbols(stock, from = start_date, to = end_date, src = "yahoo", auto.assign = FALSE),
             error = function(e) NULL)
  })
  names(stock_data) <- stocks
  stock_data <- stock_data[!sapply(stock_data, is.null)]
  
  stock_returns <- do.call(merge, lapply(stock_data, function(x) dailyReturn(Cl(x), type = "log")))
  colnames(stock_returns) <- names(stock_data)
  
  return(na.omit(stock_returns))
}

returns <- fetch_stock_data()

getSymbols("^NSEI", from = "2023-01-01", to = Sys.Date(), src = "yahoo", auto.assign = FALSE) -> market_index
market_returns <- dailyReturn(Cl(market_index), type = "log")


merged_data <- merge(returns$RELIANCE.NS, market_returns, all = FALSE)
colnames(merged_data) <- c("Reliance", "Market")


capm_model <- lm(Reliance ~ Market, data = as.data.frame(merged_data))


risk_metrics <- function(returns) {
  list(
    var_95 = VaR(returns, p = 0.95, method = "historical"),
    es_95 = ES(returns, p = 0.95, method = "historical"),
    sharpe_ratio = SharpeRatio.annualized(returns),
    sortino_ratio = SortinoRatio(returns)
  )
}


risk_results <- risk_metrics(returns)


returns_df <- fortify.zoo(returns)
ggplot(returns_df, aes(x = Index)) +
  geom_line(aes(y = RELIANCE.NS, color = "Reliance")) +
  geom_line(aes(y = HDFCBANK.NS, color = "HDFC Bank")) +
  geom_line(aes(y = TCS.NS, color = "TCS")) +
  labs(title = "Stock Returns Over Time", x = "Date", y = "Returns") +
  theme_minimal()


ggplot(as.data.frame(merged_data), aes(x = Market, y = Reliance)) +
  geom_point(color = "blue") +
  geom_smooth(method = "lm", col = "red") +
  labs(title = "CAPM Regression: Reliance vs. Market Returns", x = "Market Returns", y = "Reliance Returns") +
  theme_minimal()


risk_df <- data.frame(
  Metric = c("VaR (95%)", "Expected Shortfall (95%)", "Sharpe Ratio", "Sortino Ratio"),
  Value = c(risk_results$var_95[1], risk_results$es_95[1], risk_results$sharpe_ratio[1], risk_results$sortino_ratio[1])
)

ggplot(risk_df, aes(x = Metric, y = Value, fill = Metric)) +
  geom_bar(stat = "identity") +
  labs(title = "Risk Metrics Comparison", x = "Metric", y = "Value") +
  theme_minimal()


print(summary(capm_model))
print(risk_results)






stocks <- c("RELIANCE.NS")
start_date <- "2023-01-01"

fetch_stock_data <- function(stock) {
  stock_data <- tryCatch(getSymbols(stock, from = start_date, auto.assign = FALSE, src = "yahoo"),
                         error = function(e) return(NULL))
  if (!is.null(stock_data)) {
    stock_returns <- dailyReturn(Cl(stock_data), type = "log")
    colnames(stock_returns) <- stock
    return(stock_returns)
  }
  return(NULL)
}

returns_list <- lapply(stocks, fetch_stock_data)
returns <- do.call(merge, returns_list)
returns <- na.omit(returns)


set.seed(123)
ff_factors <- data.frame(
  Date = index(returns),
  `Mkt-RF` = rnorm(nrow(returns), mean = 0.0005, sd = 0.01),
  SMB = rnorm(nrow(returns), mean = 0.0003, sd = 0.008),
  HML = rnorm(nrow(returns), mean = 0.0002, sd = 0.007),
  RF = rep(0.01 / 252, nrow(returns)),  
  check.names = FALSE  
)


returns_df <- data.frame(Date = index(returns), coredata(returns))


merged_data <- inner_join(returns_df, ff_factors, by = "Date", keep = TRUE)


merged_data$Excess_Return <- merged_data[[stocks[1]]] - merged_data$RF


colnames(merged_data)


ff_model <- lm(Excess_Return ~ `Mkt-RF` + SMB + HML, data = merged_data)
summary(ff_model)


ggplot(merged_data, aes(x = `Mkt-RF`, y = Excess_Return)) +
  geom_point(alpha = 0.5, color = "blue") +
  geom_smooth(method = "lm", color = "red") +
  labs(
    title = "Fama-French Three-Factor Model",
    x = "Market Excess Return (Mkt-RF)",
    y = "Stock Excess Return"
  ) +
  theme_minimal()

black_scholes <- function(S, K, r, T, sigma, type = "call") {
  d1 <- (log(S / K) + (r + 0.5 * sigma^2) * T) / (sigma * sqrt(T))
  d2 <- d1 - sigma * sqrt(T)
  
  if (type == "call") {
    price <- S * pnorm(d1) - K * exp(-r * T) * pnorm(d2)
  } else if (type == "put") {
    price <- K * exp(-r * T) * pnorm(-d2) - S * pnorm(-d1)
  } else {
    stop("Invalid option type. Use 'call' or 'put'.")
  }
  
  return(price)
}

S <- 3000       # Current stock price
K <- 3100       # Strike price
r <- 0.06       # Risk-free interest rate (annual)
T <- 0.5        # Time to maturity in years (e.g., 6 months)
sigma <- 0.2    # Volatility (standard deviation)


call_price <- black_scholes(S, K, r, T, sigma, type = "call")
put_price  <- black_scholes(S, K, r, T, sigma, type = "put")


cat("Black-Scholes Call Option Price:", round(call_price, 2), "\n")
cat("Black-Scholes Put Option Price:", round(put_price, 2), "\n")
