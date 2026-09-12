-- 1. Monthly consumption and cost
SELECT y.calendar_year, mo.month_name, ROUND(SUM(f.consumption_kwh),2) AS total_kwh, ROUND(SUM(f.cost_amount),2) AS total_cost
FROM fact_energy_usage f JOIN dim_date d ON d.date_key=f.date_key JOIN dim_month mo ON mo.month_key=d.month_key JOIN dim_year y ON y.year_key=mo.year_key
GROUP BY y.calendar_year, mo.month_number, mo.month_name ORDER BY y.calendar_year, mo.month_number;
-- 2. Consumer types with highest usage
SELECT c.consumer_type, ROUND(SUM(f.consumption_kwh),2) AS total_kwh, ROUND(AVG(f.peak_demand_kw),2) AS avg_peak_kw
FROM fact_energy_usage f JOIN dim_meter m ON m.meter_key=f.meter_key JOIN dim_consumer c ON c.consumer_key=m.consumer_key GROUP BY c.consumer_type ORDER BY total_kwh DESC;
-- 3. Anomalous readings for investigation
SELECT f.reading_id, c.consumer_name, d.full_date, f.consumption_kwh, f.peak_demand_kw, f.anomaly_score
FROM fact_energy_usage f JOIN dim_meter m ON m.meter_key=f.meter_key JOIN dim_consumer c ON c.consumer_key=m.consumer_key JOIN dim_date d ON d.date_key=f.date_key
WHERE f.is_anomaly=true ORDER BY f.anomaly_score;

