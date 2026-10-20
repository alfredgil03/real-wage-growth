/************
Project: Real Wage Growth: What Actually Predicts It?

Author: Alfred Gil

Description:		
        Build a monthly master data set by integrating all cleaned 
        macroeconomic indicators into one table using Date as the 
        common key. 
        
Source Tables: 
		consumer_sentiment_cleaned
        cpi_cleaned
        effr_cleaned
        gas_prices_cleaned
        hourly_wages_cleaned
        mortgage_rates_cleaned
        real_dpi_cleaned
        real_pce_cleaned
        savings_rate_cleaned
        unemployment_cleaned
        
Output Table: 
		master_monthly 
************/

CREATE DATABASE IF NOT EXISTS macro_project;
USE macro_project;

DROP TABLE IF EXISTS master_monthly;

CREATE TABLE master_monthly AS
SELECT
	c.`Date`,
    c.CPI,
    g.GasPrices,
    u.UnemploymentRate,
    i.DisposableIncome,
    s.ConsumerSpending,
    m.MortgageRates,
    f.FedFundsRate,
    cs.ConsumerSentiment,
    w.HourlyWages,
    sr.SavingsRate
FROM cpi_cleaned c
LEFT JOIN gas_prices_cleaned g
	ON c.`Date` = g.`Date`
LEFT JOIN unemployment_cleaned u
	ON c.`Date` = u.`Date`
LEFT JOIN real_dpi_cleaned i
	ON c.`Date` = i.`Date`
LEFT JOIN real_pce_cleaned s
	ON c.`Date` = s.`Date`
LEFT JOIN mortgage_rates_cleaned m
	ON c.`Date` = m.`Date`
LEFT JOIN effr_cleaned f
	ON c.`Date` = f.`Date`
LEFT JOIN consumer_sentiment_cleaned cs 
	ON c.`Date` = cs.`Date`
LEFT JOIN hourly_wages_cleaned w 
	ON c.`Date` = w.`Date`
LEFT JOIN savings_rate_cleaned sr
	ON c.`Date` = sr.`Date`
ORDER BY c.`Date`;

ALTER TABLE master_monthly
MODIFY COLUMN `Date` DATE;

ALTER TABLE master_monthly
ADD PRIMARY KEY (`Date`);

SELECT * 
FROM master_monthly
ORDER BY `Date`
LIMIT 5;