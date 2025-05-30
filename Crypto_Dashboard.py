
import streamlit as st
import requests
import pandas as pd
import matplotlib.pyplot as plt

st.set_page_config(page_title="Crypto ESG Dashboard", layout="wide")

# --- Function to get live prices ---
def get_price(symbol):
    url = f'https://api.coingecko.com/api/v3/simple/price?ids={symbol}&vs_currencies=usd'
    response = requests.get(url)
    data = response.json()
    return data[symbol]['usd']

# --- Your portfolio ---
portfolio = [
    {"name": "Bitcoin", "symbol": "bitcoin", "amount": 0.5, "esg": 40},
    {"name": "Ethereum", "symbol": "ethereum", "amount": 1.2, "esg": 60},
    {"name": "Cardano", "symbol": "cardano", "amount": 100, "esg": 75},
]

# --- Data collection ---
... st.title("📊 Real-Time Crypto ESG Investment Tracker")
... 
... data = []
... total_value = 0
... 
... for coin in portfolio:
...     price = get_price(coin["symbol"])
...     value = coin["amount"] * price
...     total_value += value
...     data.append({
...         "Name": coin["name"],
...         "Amount": coin["amount"],
...         "Price (USD)": price,
...         "Value (USD)": value,
...         "ESG Score": coin["esg"]
...     })
... 
... df = pd.DataFrame(data)
... 
... # --- Show data ---
... st.dataframe(df.style.format({"Price (USD)": "${:,.2f}", "Value (USD)": "${:,.2f}"}))
... 
... # --- Weighted ESG Score ---
... weighted_score = sum(row["Value (USD)"] * row["ESG Score"] for row in data) / total_value
... st.metric("💹 Portfolio Value (USD)", f"${total_value:,.2f}")
... st.metric("🌱 Weighted ESG Score", f"{weighted_score:.2f} / 100")
... 
... # --- Charts ---
... st.subheader("📈 Portfolio Allocation")
... fig1, ax1 = plt.subplots()
... ax1.pie(df["Value (USD)"], labels=df["Name"], autopct="%1.1f%%", startangle=90)
... st.pyplot(fig1)
... 
... st.subheader("🌿 ESG Scores")
... fig2, ax2 = plt.subplots()
... ax2.bar(df["Name"], df["ESG Score"], color='green')
... st.pyplot(fig2)
