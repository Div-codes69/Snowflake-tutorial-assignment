import os
from pathlib import Path
import pandas as pd
from sklearn.ensemble import IsolationForest
from sklearn.preprocessing import StandardScaler

ROOT = Path(__file__).resolve().parents[1]
data_file = ROOT / "data" / "cleaned_energy_consumption.csv"
df = pd.read_csv(data_file)
df["reading_timestamp"] = pd.to_datetime(df["reading_timestamp"])
df["hour_of_day"] = df["reading_timestamp"].dt.hour
features = ["consumption_kwh", "peak_demand_kw", "voltage", "temperature_c", "hour_of_day"]
X = StandardScaler().fit_transform(df[features])
model = IsolationForest(contamination=0.10, random_state=42)
df["anomaly_label"] = model.fit_predict(X)
df["anomaly_score"] = model.decision_function(X)
df["is_anomaly"] = df["anomaly_label"].eq(-1)
output = ROOT / "data" / "energy_anomalies.csv"
df.drop(columns="anomaly_label").to_csv(output, index=False)
print(f"Detected {df['is_anomaly'].sum()} anomalous readings. Results saved to {output}")

# Optional: persist results after loading the fact table.
# Set DATABASE_URL, e.g. postgresql://postgres:password@localhost:5432/electricity_dw
database_url = os.getenv("DATABASE_URL")
if database_url:
    import psycopg2
    with psycopg2.connect(database_url) as conn, conn.cursor() as cur:
        for row in df.itertuples():
            cur.execute("UPDATE fact_energy_usage SET is_anomaly=%s, anomaly_score=%s WHERE reading_id=%s", (bool(row.is_anomaly), float(row.anomaly_score), row.reading_id))
    print("Anomaly flags loaded into fact_energy_usage.")

