-- Smart Electricity Consumption Data Warehouse: PostgreSQL Snowflake Schema
CREATE TABLE dim_region (
    region_key SERIAL PRIMARY KEY, region_name VARCHAR(100) NOT NULL,
    country_name VARCHAR(100) NOT NULL, UNIQUE (region_name, country_name)
);
CREATE TABLE dim_location (
    location_key SERIAL PRIMARY KEY, location_name VARCHAR(150) NOT NULL,
    city_name VARCHAR(100) NOT NULL, region_key INT NOT NULL REFERENCES dim_region(region_key),
    UNIQUE (location_name, city_name, region_key)
);
CREATE TABLE dim_consumer (
    consumer_key SERIAL PRIMARY KEY, consumer_name VARCHAR(150) NOT NULL,
    consumer_type VARCHAR(30) NOT NULL, location_key INT NOT NULL REFERENCES dim_location(location_key),
    UNIQUE (consumer_name, location_key)
);
CREATE TABLE dim_meter_type (
    meter_type_key SERIAL PRIMARY KEY, meter_type_name VARCHAR(60) UNIQUE NOT NULL
);
CREATE TABLE dim_meter (
    meter_key SERIAL PRIMARY KEY, meter_id VARCHAR(50) UNIQUE NOT NULL,
    meter_type_key INT NOT NULL REFERENCES dim_meter_type(meter_type_key), consumer_key INT NOT NULL REFERENCES dim_consumer(consumer_key)
);
CREATE TABLE dim_energy_source (
    energy_source_key SERIAL PRIMARY KEY, energy_source_name VARCHAR(80) UNIQUE NOT NULL
);
CREATE TABLE dim_tariff (
    tariff_key SERIAL PRIMARY KEY, tariff_name VARCHAR(100) UNIQUE NOT NULL,
    energy_source_key INT NOT NULL REFERENCES dim_energy_source(energy_source_key)
);
CREATE TABLE dim_year (year_key INT PRIMARY KEY, calendar_year INT UNIQUE NOT NULL);
CREATE TABLE dim_month (
    month_key SERIAL PRIMARY KEY, month_number SMALLINT NOT NULL, month_name VARCHAR(15) NOT NULL,
    year_key INT NOT NULL REFERENCES dim_year(year_key), UNIQUE (month_number, year_key)
);
CREATE TABLE dim_date (
    date_key INT PRIMARY KEY, full_date DATE UNIQUE NOT NULL, day_of_month SMALLINT NOT NULL,
    day_name VARCHAR(12) NOT NULL, is_weekend BOOLEAN NOT NULL, month_key INT NOT NULL REFERENCES dim_month(month_key)
);
CREATE TABLE dim_time_band (
    time_band_key SERIAL PRIMARY KEY, time_band_name VARCHAR(30) UNIQUE NOT NULL
);
CREATE TABLE dim_time (
    time_key INT PRIMARY KEY, full_time TIME UNIQUE NOT NULL, hour_of_day SMALLINT NOT NULL,
    time_band_key INT NOT NULL REFERENCES dim_time_band(time_band_key)
);
CREATE TABLE raw_energy_consumption (
    reading_id VARCHAR(50), meter_id VARCHAR(50), consumer_name VARCHAR(150), consumer_type VARCHAR(30),
    location_name VARCHAR(150), city VARCHAR(100), region VARCHAR(100), country VARCHAR(100), meter_type VARCHAR(60),
    energy_source VARCHAR(80), tariff_name VARCHAR(100), reading_timestamp TIMESTAMP,
    consumption_kwh NUMERIC(12,3), peak_demand_kw NUMERIC(12,3), voltage NUMERIC(8,2), temperature_c NUMERIC(6,2), cost_amount NUMERIC(12,2)
);
CREATE TABLE fact_energy_usage (
    usage_key BIGSERIAL PRIMARY KEY, reading_id VARCHAR(50) UNIQUE NOT NULL,
    meter_key INT NOT NULL REFERENCES dim_meter(meter_key), tariff_key INT NOT NULL REFERENCES dim_tariff(tariff_key),
    date_key INT NOT NULL REFERENCES dim_date(date_key), time_key INT NOT NULL REFERENCES dim_time(time_key),
    consumption_kwh NUMERIC(12,3) NOT NULL, peak_demand_kw NUMERIC(12,3), voltage NUMERIC(8,2),
    temperature_c NUMERIC(6,2), cost_amount NUMERIC(12,2) NOT NULL, is_anomaly BOOLEAN DEFAULT FALSE, anomaly_score NUMERIC(10,6)
);
CREATE INDEX idx_energy_usage_date ON fact_energy_usage(date_key);
CREATE INDEX idx_energy_usage_meter ON fact_energy_usage(meter_key);

