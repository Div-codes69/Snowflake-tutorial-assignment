-- Load data/cleaned_energy_consumption.csv into raw_energy_consumption before running this script.
INSERT INTO dim_region (region_name, country_name)
SELECT DISTINCT region, country FROM raw_energy_consumption ON CONFLICT DO NOTHING;
INSERT INTO dim_location (location_name, city_name, region_key)
SELECT DISTINCT r.location_name, r.city, dr.region_key FROM raw_energy_consumption r
JOIN dim_region dr ON dr.region_name=r.region AND dr.country_name=r.country ON CONFLICT DO NOTHING;
INSERT INTO dim_consumer (consumer_name, consumer_type, location_key)
SELECT DISTINCT r.consumer_name, r.consumer_type, dl.location_key FROM raw_energy_consumption r
JOIN dim_location dl ON dl.location_name=r.location_name AND dl.city_name=r.city ON CONFLICT DO NOTHING;
INSERT INTO dim_meter_type (meter_type_name) SELECT DISTINCT meter_type FROM raw_energy_consumption ON CONFLICT DO NOTHING;
INSERT INTO dim_meter (meter_id, meter_type_key, consumer_key)
SELECT DISTINCT r.meter_id, mt.meter_type_key, c.consumer_key FROM raw_energy_consumption r
JOIN dim_meter_type mt ON mt.meter_type_name=r.meter_type
JOIN dim_consumer c ON c.consumer_name=r.consumer_name ON CONFLICT DO NOTHING;
INSERT INTO dim_energy_source (energy_source_name) SELECT DISTINCT energy_source FROM raw_energy_consumption ON CONFLICT DO NOTHING;
INSERT INTO dim_tariff (tariff_name, energy_source_key)
SELECT DISTINCT r.tariff_name, es.energy_source_key FROM raw_energy_consumption r JOIN dim_energy_source es ON es.energy_source_name=r.energy_source ON CONFLICT DO NOTHING;
INSERT INTO dim_year (year_key, calendar_year) SELECT DISTINCT EXTRACT(YEAR FROM reading_timestamp)::INT, EXTRACT(YEAR FROM reading_timestamp)::INT FROM raw_energy_consumption ON CONFLICT DO NOTHING;
INSERT INTO dim_month (month_number, month_name, year_key)
SELECT DISTINCT EXTRACT(MONTH FROM reading_timestamp)::SMALLINT, TO_CHAR(reading_timestamp,'Month'), EXTRACT(YEAR FROM reading_timestamp)::INT FROM raw_energy_consumption ON CONFLICT DO NOTHING;
INSERT INTO dim_date (date_key, full_date, day_of_month, day_name, is_weekend, month_key)
SELECT DISTINCT TO_CHAR(reading_timestamp,'YYYYMMDD')::INT, reading_timestamp::DATE, EXTRACT(DAY FROM reading_timestamp)::SMALLINT, TO_CHAR(reading_timestamp,'Day'), EXTRACT(ISODOW FROM reading_timestamp) IN (6,7), dm.month_key
FROM raw_energy_consumption r JOIN dim_month dm ON dm.month_number=EXTRACT(MONTH FROM r.reading_timestamp) AND dm.year_key=EXTRACT(YEAR FROM r.reading_timestamp) ON CONFLICT DO NOTHING;
INSERT INTO dim_time_band (time_band_name) VALUES ('Night'), ('Morning'), ('Afternoon'), ('Evening') ON CONFLICT DO NOTHING;
INSERT INTO dim_time (time_key, full_time, hour_of_day, time_band_key)
SELECT DISTINCT TO_CHAR(reading_timestamp,'HH24MI')::INT, reading_timestamp::TIME, EXTRACT(HOUR FROM reading_timestamp)::SMALLINT, tb.time_band_key FROM raw_energy_consumption r
JOIN dim_time_band tb ON tb.time_band_name=CASE WHEN EXTRACT(HOUR FROM reading_timestamp)<6 THEN 'Night' WHEN EXTRACT(HOUR FROM reading_timestamp)<12 THEN 'Morning' WHEN EXTRACT(HOUR FROM reading_timestamp)<18 THEN 'Afternoon' ELSE 'Evening' END ON CONFLICT DO NOTHING;
INSERT INTO fact_energy_usage (reading_id,meter_key,tariff_key,date_key,time_key,consumption_kwh,peak_demand_kw,voltage,temperature_c,cost_amount)
SELECT r.reading_id,m.meter_key,t.tariff_key,TO_CHAR(r.reading_timestamp,'YYYYMMDD')::INT,TO_CHAR(r.reading_timestamp,'HH24MI')::INT,r.consumption_kwh,r.peak_demand_kw,r.voltage,r.temperature_c,r.cost_amount
FROM raw_energy_consumption r JOIN dim_meter m ON m.meter_id=r.meter_id JOIN dim_tariff t ON t.tariff_name=r.tariff_name ON CONFLICT (reading_id) DO NOTHING;

