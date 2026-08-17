# Acer Portfolio - Python Analysis
# Automated analysis of sales, inventory, marketplace, and series performance

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# Load Acer portfolio data

from pathlib import Path

file_path = Path(__file__).resolve().parent.parent / "Portfolio.xlsx"

df = pd.read_excel(
    file_path,
    sheet_name="Suitcase Series"
)

# Clean column names
df.columns = (
    df.columns
    .str.replace("\n", " ", regex=False)
    .str.strip()
)

# 1. Sales performance by series

series_sales = (
    df.groupby("Series")["Total Sales Out"]
    .sum()
    .sort_values(ascending=False)
)

print("\nSales by Series:")
print(series_sales)

# 2. Inventory performance by series

series_inventory = (
    df.groupby("Series")["Total Inventory"]
    .sum()
    .sort_values(ascending=False)
)

print("\nInventory by Series:")
print(series_inventory)

# 3. Sales-to-inventory ratio

df["Sales Inventory Ratio"] = (
    df["Total Sales Out"] /
    df["Total Inventory"].replace(0, np.nan)
)

print("\nSales-to-Inventory Ratio:")
print(
    df[["Series", "Total Sales Out", "Total Inventory", "Sales Inventory Ratio"]]
    .sort_values("Sales Inventory Ratio", ascending=False)
)

# 4. Marketplace sales analysis

marketplace_sales = pd.Series({
    "Flipkart": df["Flipkart Sales"].sum(),
    "Amazon": df["Amazon Sales"].sum(),
    "Myntra": df["Myntra Sales"].sum()
})

marketplace_sales = marketplace_sales.sort_values(ascending=False)

print("\nMarketplace Sales:")
print(marketplace_sales)

# 5. Marketplace sales contribution

marketplace_sales_pct = (
    marketplace_sales /
    marketplace_sales.sum() * 100
)

print("\nMarketplace Sales Contribution (%):")
print(marketplace_sales_pct.round(2))

# 6. Marketplace stock analysis

marketplace_stock = pd.Series({
    "Flipkart": df["Flipkart Stock"].sum(),
    "Amazon": df["Amazon Stock"].sum(),
    "Myntra": df["Myntra Stock"].sum()
})

marketplace_stock = marketplace_stock.sort_values(ascending=False)

print("\nMarketplace Stock:")
print(marketplace_stock)

# 7. Marketplace stock contribution

marketplace_stock_pct = (
    marketplace_stock /
    marketplace_stock.sum() * 100
)

print("\nMarketplace Stock Contribution (%):")
print(marketplace_stock_pct.round(2))

# 8. Stock-risk classification

def classify_stock(inventory):
    if inventory < 50:
        return "Low Stock"
    elif inventory <= 150:
        return "Moderate Stock"
    else:
        return "High Stock"


df["Stock Status"] = df["Total Inventory"].apply(classify_stock)

print("\nStock Risk Classification:")
print(
    df[["Series", "Total Inventory", "Stock Status"]]
    .sort_values("Total Inventory")
)

# 9. Inventory value by series

inventory_value = (
    df.groupby("Series")["Inventory Value @ MRP"]
    .sum()
    .sort_values(ascending=False)
)

print("\nInventory Value by Series:")
print(inventory_value)

# 10. Overall business KPIs

total_sales = df["Total Sales Out"].sum()
total_inventory = df["Total Inventory"].sum()
total_inventory_value = df["Inventory Value @ MRP"].sum()

print("\nOverall Business KPIs:")
print(f"Total Sales: {total_sales}")
print(f"Total Inventory: {total_inventory}")
print(f"Total Inventory Value: ₹{total_inventory_value:,.0f}")

# 11. Top-selling series

top_series = series_sales.idxmax()
top_series_sales = series_sales.max()

print("\nTop-Selling Series:")
print(f"{top_series}: {top_series_sales} units")

# 12. Lowest-inventory series

lowest_stock_series = series_inventory.idxmin()
lowest_stock = series_inventory.min()

print("\nLowest-Inventory Series:")
print(f"{lowest_stock_series}: {lowest_stock} units")

# 13. Highest-inventory series

highest_stock_series = series_inventory.idxmax()
highest_stock = series_inventory.max()

print("\nHighest-Inventory Series:")
print(f"{highest_stock_series}: {highest_stock} units")

# 14. Top two series sales contribution

top_two_sales = series_sales.head(2).sum()
top_two_sales_pct = top_two_sales / total_sales * 100

print("\nTop Two Series Sales Contribution:")
print(f"Sales: {top_two_sales} units")
print(f"Contribution: {top_two_sales_pct:.2f}%")

# 15. Potential replenishment candidates

replenishment = df[
    (df["Total Inventory"] < 100) &
    (df["Total Sales Out"] > 0)
].copy()

replenishment["Sales Inventory Ratio"] = (
    replenishment["Total Sales Out"] /
    replenishment["Total Inventory"].replace(0, np.nan)
)

replenishment = replenishment.sort_values(
    "Sales Inventory Ratio",
    ascending=False
)

print("\nPotential Replenishment Candidates:")
print(
    replenishment[
        ["Series", "Total Sales Out", "Total Inventory", "Sales Inventory Ratio"]
    ]
)

# 16. Potential excess-stock candidates

excess_stock = df[
    (df["Total Inventory"] > 150) &
    (df["Total Sales Out"] < 5)
].copy()

print("\nPotential Excess-Stock Candidates:")
print(
    excess_stock[
        ["Series", "Total Sales Out", "Total Inventory", "Inventory Value @ MRP"]
    ]
)

# 17. Create output folders

from pathlib import Path

output_dir = Path(__file__).resolve().parent / "outputs"
charts_dir = output_dir / "charts"

output_dir.mkdir(exist_ok=True)
charts_dir.mkdir(exist_ok=True)

print("\nOutput folders created.")

# 18. Export sales analysis

series_sales_df = series_sales.reset_index()

series_sales_df.columns = [
    "Series",
    "Total Sales"
]

series_sales_df.to_csv(
    output_dir / "sales_by_series.csv",
    index=False
)

print("Saved: sales_by_series.csv")

# 19. Export inventory analysis

series_inventory_df = series_inventory.reset_index()

series_inventory_df.columns = [
    "Series",
    "Total Inventory"
]

series_inventory_df.to_csv(
    output_dir / "inventory_by_series.csv",
    index=False
)

print("Saved: inventory_by_series.csv")

# 20. Export marketplace sales

marketplace_sales_df = pd.DataFrame({
    "Marketplace": marketplace_sales.index,
    "Total Sales": marketplace_sales.values,
    "Sales Percentage": marketplace_sales_pct.round(2).values
})

marketplace_sales_df.to_csv(
    output_dir / "sales_by_marketplace.csv",
    index=False
)

print("Saved: sales_by_marketplace.csv")

# 21. Export marketplace stock

marketplace_stock_df = pd.DataFrame({
    "Marketplace": marketplace_stock.index,
    "Stock": marketplace_stock.values,
    "Stock Percentage": marketplace_stock_pct.round(2).values
})

marketplace_stock_df.to_csv(
    output_dir / "stock_by_marketplace.csv",
    index=False
)

print("Saved: stock_by_marketplace.csv")

# 22. Export stock-risk analysis

stock_risk_df = df[
    [
        "Series",
        "Total Sales Out",
        "Total Inventory",
        "Sales Inventory Ratio",
        "Stock Status",
        "Inventory Value @ MRP"
    ]
].copy()

stock_risk_df.to_csv(
    output_dir / "stock_risk_analysis.csv",
    index=False
)

print("Saved: stock_risk_analysis.csv")

# 23. Sales by series chart

plt.figure(figsize=(10, 6))

series_sales.plot(kind="bar")

plt.title("Sales by Suitcase Series")
plt.xlabel("Series")
plt.ylabel("Units Sold")
plt.xticks(rotation=45)
plt.tight_layout()

plt.savefig(
    charts_dir / "sales_by_series.png",
    dpi=300
)

plt.close()

print("Saved: sales_by_series.png")

# 24. Inventory by series chart

plt.figure(figsize=(10, 6))

series_inventory.plot(kind="bar")

plt.title("Inventory by Suitcase Series")
plt.xlabel("Series")
plt.ylabel("Inventory Units")
plt.xticks(rotation=45)
plt.tight_layout()

plt.savefig(
    charts_dir / "inventory_by_series.png",
    dpi=300
)

plt.close()

print("Saved: inventory_by_series.png")

# 25. Marketplace sales chart

plt.figure(figsize=(8, 6))

marketplace_sales.plot(kind="bar")

plt.title("Sales by Marketplace")
plt.xlabel("Marketplace")
plt.ylabel("Units Sold")
plt.xticks(rotation=0)
plt.tight_layout()

plt.savefig(
    charts_dir / "sales_by_marketplace.png",
    dpi=300
)

plt.close()

print("Saved: sales_by_marketplace.png")

# 26. Marketplace stock chart

plt.figure(figsize=(8, 6))

marketplace_stock.plot(kind="bar")

plt.title("Stock by Marketplace")
plt.xlabel("Marketplace")
plt.ylabel("Stock Units")
plt.xticks(rotation=0)
plt.tight_layout()

plt.savefig(
    charts_dir / "stock_by_marketplace.png",
    dpi=300
)

plt.close()

print("Saved: stock_by_marketplace.png")

# 27. Final analysis summary

print("\n" + "=" * 50)
print("ACER PORTFOLIO ANALYSIS COMPLETE")
print("=" * 50)

print(f"Total Sales: {total_sales}")
print(f"Total Inventory: {total_inventory}")
print(f"Inventory Value: ₹{total_inventory_value:,.0f}")
print(f"Top Series: {top_series}")
print(f"Top Series Sales: {top_series_sales}")
print(f"Lowest Stock Series: {lowest_stock_series}")
print(f"Lowest Stock: {lowest_stock}")
print(f"Highest Stock Series: {highest_stock_series}")
print(f"Highest Stock: {highest_stock}")
print(f"Top Two Sales Contribution: {top_two_sales_pct:.2f}%")
print(f"Top Marketplace: {marketplace_sales.idxmax()}")
print(f"Top Marketplace Sales: {marketplace_sales.max()}")

print("\nOutputs saved to:")
print(output_dir)