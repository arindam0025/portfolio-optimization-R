import yfinance as yf
import pandas as pd
import matplotlib.pyplot as plt

# ✅ Download data
data = yf.download("TCS.NS", start="2021-01-01")

# ✅ Golden Cross / Death Cross (SMA Crossover)
data['SMA50'] = data['Close'].rolling(50).mean()
data['SMA200'] = data['Close'].rolling(200).mean()
data['Signal_SMA'] = 0
data.loc[data['SMA50'] > data['SMA200'], 'Signal_SMA'] = 1
data['Position_SMA'] = data['Signal_SMA'].diff()

plt.figure(figsize=(14, 7))
plt.plot(data['Close'], label='Close', alpha=0.6)
plt.plot(data['SMA50'], label='SMA 50', linestyle='--')
plt.plot(data['SMA200'], label='SMA 200', linestyle='--')
plt.scatter(data[data['Position_SMA'] == 1].index, data['SMA50'][data['Position_SMA'] == 1], color='green', marker='^', s=100, label='Golden Cross')
plt.scatter(data[data['Position_SMA'] == -1].index, data['SMA50'][data['Position_SMA'] == -1], color='red', marker='v', s=100, label='Death Cross')
plt.title("Golden Cross / Death Cross Strategy")
plt.legend()
plt.grid()
plt.show()
plt.clf()

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import yfinance as yf

# Download stock data
stock = yf.download('AAPL', start='2022-01-01', end='2024-01-01')

# Calculate Bollinger Bands
stock['SMA_20'] = stock['Close'].rolling(window=20).mean() # 20-day Simple Moving Average
stock['20_Day_STD'] = stock['Close'].rolling(window=20).std() # Standard Deviation
stock['Upper_Band'] = stock['SMA_20'] + (stock['20_Day_STD'] * 2) # Upper Bollinger Band
stock['Lower_Band'] = stock['SMA_20'] - (stock['20_Day_STD'] * 2) # Lower Bollinger Band

# Flatten MultiIndex columns to access them correctly
stock.columns = stock.columns.droplevel(1) # Drop the 'Ticker' level from MultiIndex

# Check the columns to ensure they exist
print(stock.columns)

# Drop rows where 'Close', 'Lower_Band', or 'Upper_Band' are NaN
stock = stock.dropna(subset=['Close', 'Lower_Band', 'Upper_Band'])

# Generate Buy/Sell signals
stock['Buy_Signal'] = np.nan
stock['Sell_Signal'] = np.nan

# Buy signal: when Close price touches lower Bollinger Band
stock.loc[stock['Close'] <= stock['Lower_Band'], 'Buy_Signal'] = stock['Close']

# Sell signal: when Close price touches upper Bollinger Band
stock.loc[stock['Close'] >= stock['Upper_Band'], 'Sell_Signal'] = stock['Close']

# Plot the results
plt.figure(figsize=(12,8))
plt.plot(stock['Close'], label='Close Price', color='blue', alpha=0.5)
plt.plot(stock['SMA_20'], label='20-Day SMA', color='orange')
plt.plot(stock['Upper_Band'], label='Upper Bollinger Band', color='red')
plt.plot(stock['Lower_Band'], label='Lower Bollinger Band', color='green')

# Mark Buy and Sell signals
plt.scatter(stock.index, stock['Buy_Signal'], label='Buy Signal', marker='^', color='green', alpha=1)
plt.scatter(stock.index, stock['Sell_Signal'], label='Sell Signal', marker='v', color='red', alpha=1)

plt.title('Bollinger Bands Mean Reversion Strategy')
plt.legend(loc='best')
plt.show()

import matplotlib.dates as mdates

np.random.seed(42)
dates = pd.date_range(start='2024-01-01', periods=700, freq='B')
initial_price = 100
drift = 0.0002
volatility = 0.015
returns = np.random.normal(loc=drift, scale=volatility, size=len(dates))
prices = initial_price * (1 + returns).cumprod()

data = pd.DataFrame({'Date': dates, 'Close': prices})
data = data.set_index('Date')

#Calculate Bollinger Bands
window = 20 # Standard window for Bollinger Bands
num_std_dev = 2 # Standard number of std deviations

# Calculate Middle Band (SMA)
data['Middle Band'] = data['Close'].rolling(window=window).mean()

# Calculate Rolling Standard Deviation
data['Std Dev'] = data['Close'].rolling(window=window).std()

# Calculate Upper and Lower Bands
data['Upper Band'] = data['Middle Band'] + (data['Std Dev'] * num_std_dev)
data['Lower Band'] = data['Middle Band'] - (data['Std Dev'] * num_std_dev)


# Buy Signal:
data['Buy_Signal_Price'] = np.where(data['Close'] <= data['Lower Band'], data['Close'], np.nan)

# Sell Signal:
data['Sell_Signal_Price'] = np.where(data['Close'] >= data['Upper Band'], data['Close'], np.nan)




# Plotting
print("Generating Bollinger Bands plot...")
plt.style.use('seaborn-v0_8-darkgrid')
fig, ax = plt.subplots(figsize=(14, 7))

# Plot Closing Price
ax.plot(data.index, data['Close'], label='Close Price', color='skyblue', linewidth=1.5, alpha=0.8)

# Plot Bollinger Bands
ax.plot(data.index, data['Upper Band'], label='Upper Band', color='lightcoral', linestyle='--', linewidth=1, alpha=0.8)
ax.plot(data.index, data['Middle Band'], label='Middle Band (SMA 20)', color='khaki', linestyle='-', linewidth=1, alpha=0.8)
ax.plot(data.index, data['Lower Band'], label='Lower Band', color='lightgreen', linestyle='--', linewidth=1, alpha=0.8)

# Shade the area between the bands
ax.fill_between(data.index, data['Upper Band'], data['Lower Band'], color='white', alpha=0.4)

# Plot Buy Signals
ax.plot(data.index, data['Buy_Signal_Price'], label='Buy Signal (Price <= Lower)', marker='^', markersize=10, color='green', linestyle='None', alpha=1)

# Plot Sell Signals
ax.plot(data.index, data['Sell_Signal_Price'], label='Sell Signal (Price >= Upper)', marker='v', markersize=10, color='red', linestyle='None', alpha=1)

# Formatting the plot
ax.set_title('Bollinger Bands Mean Reversion Strategy', fontsize=16)
ax.set_xlabel('Date', fontsize=12)
ax.set_ylabel('Price', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, linestyle='--', alpha=0.6)

# Improve date formatting on x-axis
ax.xaxis.set_major_locator(mdates.YearLocator())
ax.xaxis.set_major_formatter(mdates.DateFormatter('%Y-%m'))
plt.xticks(rotation=45)

plt.tight_layout()
plt.show()

# Display the first few rows with signals (optional)
print("\nSample Data with Bollinger Bands and Signals (first 10 signal rows):")
signal_rows = data[data['Buy_Signal_Price'].notna() | data['Sell_Signal_Price'].notna()].dropna(subset=['Middle Band'])
print(signal_rows.head(10))


import yfinance as yf
import pandas as pd
import matplotlib.pyplot as plt

# ✅ Download data
data = yf.download("TCS.NS", start="2024-01-01")

# ✅ RSI Strategy
def compute_rsi(series, period=14):
    delta = series.diff()
    gain = delta.where(delta > 0, 0)
    loss = -delta.where(delta < 0, 0)

    avg_gain = gain.rolling(window=period).mean()
    avg_loss = loss.rolling(window=period).mean()

    rs = avg_gain / avg_loss
    rsi = 100 - (100 / (1 + rs))
    return rsi

delta = series.diff()
gain = delta.clip(lower=0)
loss = -delta.clip(upper=0)
avg_gain = gain.rolling(period).mean()
avg_loss = loss.rolling(period).mean()
rs = avg_gain / avg_loss
def compute_rsi(series, period=14):
    delta = series.diff()
    gain = delta.where(delta > 0, 0)
    loss = -delta.where(delta < 0, 0)

    avg_gain = gain.rolling(window=period).mean()
    avg_loss = loss.rolling(window=period).mean()

    rs = avg_gain / avg_loss
    return 100 - (100 / (1 + rs))  # ✅ Properly indented


data['RSI'] = RSI(data['Close'])
buy_rsi = data[data['RSI'] < 30]
sell_rsi = data[data['RSI'] > 70]

plt.figure(figsize=(14, 6))
plt.plot(data['RSI'], label='RSI', color='purple')
plt.axhline(30, color='green', linestyle='--')
plt.axhline(70, color='red', linestyle='--')
plt.scatter(buy_rsi.index, buy_rsi['RSI'], label='Buy', marker='^', color='green', s=100)
plt.scatter(sell_rsi.index, sell_rsi['RSI'], label='Sell', marker='v', color='red', s=100)
plt.title("RSI Strategy")
plt.legend()
plt.grid()
plt.show()
plt.clf()


import yfinance as yf
import pandas as pd
import matplotlib.pyplot as plt

# ✅ Download data
data = yf.download("TCS.NS", start="2024-01-01")

# **Debugging step: Print the column names to understand their structure**
print("Column Names in DataFrame:")
print(data.columns)

# ✅ Breakout + Volume Confirmation
data['High20'] = data[('High', 'TCS.NS')].rolling(20).max() # Accessing High using tuple
data['VolAvg'] = data[('Volume', 'TCS.NS')].rolling(20).mean() # Accessing Volume using tuple

# Drop rows with NaN values in the necessary columns
data = data.dropna(subset=[('High', 'TCS.NS'), ('Volume', 'TCS.NS')])

# Calculate Breakout condition
data['Breakout'] = (data[('Close', 'TCS.NS')] > data['High20']) & (data[('Volume', 'TCS.NS')] > 1.5 * data['VolAvg'])

plt.figure(figsize=(14, 6))
plt.plot(data[('Close', 'TCS.NS')], label='Close Price') # Accessing Close using tuple
plt.scatter(data[data['Breakout']].index, data[('Close', 'TCS.NS')][data['Breakout']], label='Breakout Buy', color='green', marker='^', s=100)
plt.bar(data.index, data[('Volume', 'TCS.NS')], label='Volume', alpha=0.3) # Accessing Volume using tuple
plt.title("Breakout Strategy with Volume Confirmation")
plt.legend()
plt.grid()
plt.show()
plt.clf()


import yfinance as yf
import pandas as pd
import numpy as np # Import NumPy
import matplotlib.pyplot as plt

# ✅ Download data
data = yf.download("TCS.NS", start="2024-01-01")

# ✅ MACD Crossover Strategy
data['EMA12'] = data['Close'].ewm(span=12, adjust=False).mean()
data['EMA26'] = data['Close'].ewm(span=26, adjust=False).mean()
data['MACD'] = data['EMA12'] - data['EMA26']
data['MACD_Signal'] = data['MACD'].ewm(span=9, adjust=False).mean()
data['MACD_Hist'] = data['MACD'] - data['MACD_Signal']
data['MACD_Pos'] = np.where(data['MACD'] > data['MACD_Signal'], 1, 0)
data['MACD_Cross'] = pd.Series(data['MACD_Pos']).diff()

plt.figure(figsize=(14, 6))
plt.plot(data['MACD'], label='MACD', color='blue')
plt.plot(data['MACD_Signal'], label='Signal', color='orange')
plt.bar(data.index, data['MACD_Hist'], label='Histogram', alpha=0.3)
plt.scatter(data[data['MACD_Cross'] == 1].index, data['MACD'][data['MACD_Cross'] == 1], label='Buy', color='green', marker='^', s=100)
plt.scatter(data[data['MACD_Cross'] == -1].index, data['MACD'][data['MACD_Cross'] == -1], label='Sell', color='red', marker='v', s=100)
plt.title("MACD Crossover Strategy")
plt.legend()
plt.grid()
plt.show()
plt.clf()


import matplotlib.pyplot as plt

# Example: Simulated trade returns (Replace with real backtested results)
trades = [100, -50, 200, -100, 300, -150, 250]
equity = [100000 + sum(trades[:i+1]) for i in range(len(trades))]

# Metrics
total_profit = sum(trades)
win_rate = len([t for t in trades if t > 0]) / len(trades) * 100
drawdown = max([max(equity[:i+1]) - equity[i] for i in range(len(equity))])

print("\n📈 Backtest Metrics:")
print(f"Total Profit/Loss: ₹{total_profit}")
print(f"Win Rate: {win_rate:.2f}%")
print(f"Max Drawdown: ₹{drawdown}")

# Plot Equity Curve
plt.figure(figsize=(10, 5))
plt.plot(equity, marker='o')
plt.title("Equity Curve")
plt.xlabel("Trade Number")
plt.ylabel("Portfolio Value")
plt.grid()
plt.show()
plt.clf()