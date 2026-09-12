from pathlib import Path
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
source = ROOT / "data" / "sample_energy_consumption.csv"
target = ROOT / "data" / "cleaned_energy_consumption.csv"
df = pd.read_csv(source)
df = df.drop_duplicates(subset="reading_id")
df["reading_timestamp"] = pd.to_datetime(df["reading_timestamp"], errors="coerce")
numeric_columns = ["consumption_kwh", "peak_demand_kw", "voltage", "temperature_c", "cost_amount"]
for column in numeric_columns:
    df[column] = pd.to_numeric(df[column], errors="coerce")
    df[column] = df[column].fillna(df[column].median())
df = df.dropna(subset=["reading_timestamp", "meter_id"])
df = df[(df["consumption_kwh"] >= 0) & (df["peak_demand_kw"] >= 0)]
df["reading_year"] = df["reading_timestamp"].dt.year
df["reading_month"] = df["reading_timestamp"].dt.month
df["hour_of_day"] = df["reading_timestamp"].dt.hour
df["time_band"] = pd.cut(df["hour_of_day"], [-1, 5, 11, 17, 23], labels=["Night", "Morning", "Afternoon", "Evening"])
df.to_csv(target, index=False)
print(f"Preprocessing complete: {len(df)} readings saved to {target}")

