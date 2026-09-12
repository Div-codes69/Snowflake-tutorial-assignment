# Smart Electricity Consumption Data Warehouse

## Project overview

This project implements a data warehouse and data-mining workflow for analysing smart-meter electricity consumption. It follows the structure of the supplied Food Delivery DWDM project, but uses an energy-focused **Snowflake Schema** and an Isolation Forest model for anomaly detection.

The workflow covers data preparation, ETL, warehouse loading, SQL analytics and detection of unusual electricity usage.

## Technology stack

- Python, Pandas, scikit-learn
- PostgreSQL and SQL
- Matplotlib and Seaborn

## Folder layout

```text
smart-electricity-dw/
├── data/sample_energy_consumption.csv
├── python/data_preprocessing.py
├── python/anomaly_detection.py
├── sql/01_snowflake_schema.sql
├── sql/02_etl_load.sql
├── sql/03_analytics_queries.sql
└── requirements.txt
```

## Snowflake schema

```text
dim_region ──< dim_location ──< dim_consumer ──< fact_energy_usage >── dim_date ──< dim_month ──< dim_year
                                                   │
                                                   ├── dim_time ──< dim_time_band
                                                   ├── dim_tariff ──< dim_energy_source
                                                   └── dim_meter ──< dim_meter_type
```

`fact_energy_usage` stores each meter reading. The normalized hierarchy tables make this a snowflake schema rather than a star schema.

## Run it

1. Create a PostgreSQL database called `electricity_dw`.
2. Run `sql/01_snowflake_schema.sql` and then `sql/02_etl_load.sql`.
3. Install dependencies: `pip install -r requirements.txt`.
4. From `python/`, run `python data_preprocessing.py`, then import `data/cleaned_energy_consumption.csv` into `raw_energy_consumption`.
5. Run `python anomaly_detection.py`. Set `DATABASE_URL` if PostgreSQL is not local/default.

## Key measures

- `consumption_kwh`: energy used in the interval
- `cost_amount`: estimated charge for the interval
- `peak_demand_kw`: maximum demand recorded
- `is_anomaly`: result of the anomaly detection model

The sample data is deliberately small and illustrative. Replace it with smart-meter data using the same column names for a real deployment.

