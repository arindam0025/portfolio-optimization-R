# Install required packages
if (!require("quantmod")) install.packages("quantmod")
if (!require("PerformanceAnalytics")) install.packages("PerformanceAnalytics")
if (!require("quadprog")) install.packages("quadprog")
if (!require("ggplot2")) install.packages("ggplot2")
if (!require("ROI")) install.packages("ROI")
if (!require("ROI.plugin.quadprog")) install.packages("ROI.plugin.quadprog")

# Load packages
library(quantmod)
library(PerformanceAnalytics)
library(quadprog)
library(ggplot2)
library(ROI)
library(ROI.plugin.quadprog)

# ------------------------- 1. Load Stock Data --------------------------
tickers <- c(
  "AXISBANK.NS", "INDUSINDBK.NS", "BANDHANBNK.NS", "HDFCBANK.NS", "ICICIBANK.NS", "KOTAKBANK.NS",
  "INFY.NS", "TCS.NS", "TECHM.NS",
  "TATAMOTORS.NS", "M&M.NS", "BAJAJ-AUTO.NS",
  "HINDUNILVR.NS", "ITC.NS", "NESTLEIND.NS",
  "RELIANCE.NS", "ONGC.NS", "IOC.NS",
  "SUNPHARMA.NS", "CIPLA.NS",
  "TATASTEEL.NS", "JSWSTEEL.NS", "HINDALCO.NS",
  "LT.NS", "NTPC.NS", "POWERGRID.NS",
  "WHIRLPOOL.NS", "VOLTAS.NS"
)

startDate <- "2020-01-01"
endDate <- Sys.Date()

getSymbols(tickers, from = startDate, to = endDate)

# Extract Adjusted Close Prices
priceList <- lapply(tickers, function(sym) Ad(get(sym)))
prices <- do.call(merge, priceList)
colnames(prices) <- tickers

# Calculate Daily Log Returns
returns <- na.omit(Return.calculate(prices, method = "log"))

# ------------------------- 2. Equal Weighted Portfolio --------------------------
weights <- rep(1/length(tickers), length(tickers))
portReturns <- Return.portfolio(R = returns, weights = weights)

# Risk Metrics
confidenceLevel <- 0.95
portfolioVaR <- VaR(portReturns, p = confidenceLevel, method = "historical")
portfolioES  <- ES(portReturns, p = confidenceLevel, method = "historical")
portfolioSharpe <- SharpeRatio.annualized(portReturns, Rf = 6.58)
portfolioSortino <- SortinoRatio(portReturns, MAR = 0)

riskMetrics <- data.frame(
  VaR = as.numeric(portfolioVaR),
  ExpectedShortfall = as.numeric(portfolioES),
  Sharpe = as.numeric(portfolioSharpe),
  Sortino = as.numeric(portfolioSortino)
)
print("Portfolio Risk Metrics:")
print(riskMetrics)

# ------------------------- 3. CAPM Regression --------------------------
niftyData <- getSymbols("^NSEI", from = startDate, to = endDate, auto.assign = FALSE)
niftyPrices <- Ad(niftyData)
niftyReturns <- na.omit(Return.calculate(niftyPrices, method = "log"))

dataCAPM <- merge(portReturns, niftyReturns, join = "inner")
colnames(dataCAPM) <- c("Portfolio", "Nifty")

capmModel <- lm(Portfolio ~ Nifty, data = dataCAPM)
print("CAPM Regression Summary:")
print(summary(capmModel))
cat("CAPM Alpha:", coef(capmModel)[1], "\n")
cat("CAPM Beta: ", coef(capmModel)[2], "\n")

# ------------------------- 4. Black-Scholes Option Pricing --------------------------
black_scholes_price <- function(S, K, T, r, sigma, option_type = "call") {
  d1 <- (log(S/K) + (r + 0.5*sigma^2)*T) / (sigma*sqrt(T))
  d2 <- d1 - sigma*sqrt(T)
  if(option_type == "call") {
    return(S * pnorm(d1) - K * exp(-r*T) * pnorm(d2))
  } else {
    return(K * exp(-r*T) * pnorm(-d2) - S * pnorm(-d1))
  }
}

S <- 100; K <- 105; T <- 0.5; r <- 0.01; sigma <- 0.2
callPrice <- black_scholes_price(S, K, T, r, sigma, option_type = "call")
putPrice  <- black_scholes_price(S, K, T, r, sigma, option_type = "put")
cat("Call Price:", callPrice, "\n")
cat("Put Price: ", putPrice, "\n")

# Implied Volatility
implied_vol <- function(observed_price, S, K, T, r, option_type = "call") {
  price_error <- function(sigma) {
    bs_price <- black_scholes_price(S, K, T, r, sigma, option_type)
    return(bs_price - observed_price)
  }
  vol_solution <- uniroot(price_error, lower = 0.0001, upper = 3)
  return(vol_solution$root)
}
calc_implied_vol <- implied_vol(callPrice, S, K, T, r, option_type = "call")
cat("Implied Volatility:", calc_implied_vol, "\n")

# ------------------------- 5. Markowitz Optimization --------------------------
meanReturns <- colMeans(returns)
covMatrix <- cov(returns)

markowitz_optimization <- function(mean_returns, cov_matrix, risk_free_rate = 0.0658) {
  n_assets <- length(mean_returns)
  Dmat <- 2 * cov_matrix
  dvec <- rep(0, n_assets)
  Amat <- cbind(rep(1, n_assets), diag(n_assets))
  bvec <- c(1, rep(0, n_assets))
  result <- solve.QP(Dmat, dvec, Amat, bvec, meq = 1)
  optimal_weights <- result$solution
  names(optimal_weights) <- colnames(cov_matrix)
  port_return <- sum(optimal_weights * mean_returns) * 252
  port_risk <- sqrt(t(optimal_weights) %*% cov_matrix %*% optimal_weights) * sqrt(252)
  sharpe <- (port_return - risk_free_rate) / port_risk
  return(list(weights = optimal_weights, return = port_return, risk = port_risk, sharpe = sharpe))
}

markowitz_result <- markowitz_optimization(meanReturns, covMatrix)
cat("\nMarkowitz Optimal Weights:\n")
print(round(markowitz_result$weights, 4))
cat("\nPortfolio Return:", round(markowitz_result$return * 100, 2), "%\n")
cat("Portfolio Risk  :", round(markowitz_result$risk * 100, 2), "%\n")
cat("Sharpe Ratio    :", round(markowitz_result$sharpe, 4), "\n")

# ------------------------- 6. Efficient Frontier Plot --------------------------
efficient_frontier <- function(returns, n_portfolios = 5000, risk_free_rate = 0.0658) {
  n_assets <- ncol(returns)
  mean_returns <- colMeans(returns)
  cov_matrix <- cov(returns)
  frontier <- data.frame(Return = numeric(), Risk = numeric(), Sharpe = numeric())
  
  for (i in 1:n_portfolios) {
    weights <- runif(n_assets)
    weights <- weights / sum(weights)
    port_return <- sum(weights * mean_returns) * 252
    port_risk <- sqrt(t(weights) %*% cov_matrix %*% weights) * sqrt(252)
    sharpe <- (port_return - risk_free_rate) / port_risk
    frontier <- rbind(frontier, data.frame(Return = port_return, Risk = port_risk, Sharpe = sharpe))
  }
  return(frontier)
}

frontier <- efficient_frontier(returns)

ggplot(frontier, aes(x = Risk * 100, y = Return * 100, color = Sharpe)) +
  geom_point(alpha = 0.6) +
  scale_color_gradient(low = "blue", high = "red") +
  labs(title = "Efficient Frontier (Markowitz Optimization)",
       x = "Annualized Risk (%)",
       y = "Annualized Return (%)") +
  theme_minimal()

