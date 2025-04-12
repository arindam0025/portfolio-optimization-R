
if (!require("quantmod")) install.packages("quantmod", dependencies = TRUE)


library(quantmod)


end_date <- Sys.Date()
start_date <- end_date - 365 * 5


wipro_data <- getSymbols("WIPRO.NS", src = "yahoo", from = start_date, to = end_date, auto.assign = FALSE)


hcl_data <- getSymbols("HCLTECH.NS", src = "yahoo", from = start_date, to = end_date, auto.assign = FALSE)


cat("Wipro Data:\n")
print(head(wipro_data))


cat("\nHCL Data:\n")
print(head(hcl_data))

install.packages(c("quantmod", "PerformanceAnalytics"))
library(quantmod)
library(PerformanceAnalytics)


Wipro_data <- getSymbols("WIPRO.NS", src = "yahoo", from = Sys.Date() - 365*5, to = Sys.Date(), auto.assign = FALSE)


HCL_data <- getSymbols("HCLTECH.NS", src = "yahoo", from = Sys.Date() - 365*5, to = Sys.Date(), auto.assign = FALSE)

plot(Ad(Wipro_data),
     main = "Wipro Stock Price",
     xlab = "Date",
     ylab = "Adjusted Close Price",
     col = "blue",
     type = "l")


plot(Ad(HCL_data),
     main = "HCL Technologies Stock Price",
     xlab = "Date",
     ylab = "Adjusted Close Price",
     col = "red",
     type = "l")


cat("Summary statistics for Wipro's adjusted close prices:\n")
print(summary(Ad(Wipro_data)))


cat("\nSummary statistics for HCL's adjusted close prices:\n")
print(summary(Ad(HCL_data)))


cat("\nVolatility (Standard Deviation) for Wipro:\n")
print(sd(Ad(Wipro_data)))


cat("\nVolatility (Standard Deviation) for HCL:\n")
print(sd(Ad(HCL_data)))


cat("\nVariance for Wipro:\n")
print(var(Ad(Wipro_data)))


cat("\nVariance for HCL:\n")
print(var(Ad(HCL_data)))

library(quantmod)
library(PerformanceAnalytics)


Wipro_returns <- dailyReturn(Ad(Wipro_data))
HCL_returns <- dailyReturn(Ad(HCL_data))


portfolio_returns <- (Wipro_returns + HCL_returns) / 2


monthly_Wipro_returns <- monthlyReturn(Ad(Wipro_data))
monthly_HCL_returns <- monthlyReturn(Ad(HCL_data))
monthly_portfolio_returns <- (monthly_Wipro_returns + monthly_HCL_returns) / 2


cum_Wipro_returns <- cumprod(1 + Wipro_returns) - 1
cum_HCL_returns <- cumprod(1 + HCL_returns) - 1
cum_portfolio_returns <- cumprod(1 + portfolio_returns) - 1


Nifty50_data <- getSymbols("^NSEI", src = "yahoo", from = Sys.Date() - 365*5, to = Sys.Date(), auto.assign = FALSE)
Nifty50_returns <- dailyReturn(Ad(Nifty50_data))
cum_Nifty50_returns <- cumprod(1 + Nifty50_returns) - 1


plot(cum_Wipro_returns, main = "Cumulative Returns", ylab = "Cumulative Returns", col = "blue", type = "l")
lines(cum_HCL_returns, col = "red")
lines(cum_portfolio_returns, col = "green")
lines(cum_Nifty50_returns, col = "black")
legend("topleft", legend = c("Wipro", "HCL", "Portfolio", "Nifty 50"), col = c("blue", "red", "green", "black"), lty = 1)

