/************
Project: Real Wage Growth: What Actually Predicts It?

Author: Alfred Gil

Description:		
        Create a feature-engineered monthly dataset from the cleaned
		monthly master data set. 
        
Source Table: 
		master_monthly

Output Table: 
		master_monthly_features 
************/

USE macro_project;

-- Remove existing feature table (if it exists)
DROP TABLE IF EXISTS master_monthly_features;

-- Create feature-engineered dataset
CREATE TABLE master_monthly_features AS
SELECT
	`Date`,
    CPI,
    GasPrices,
    UnemploymentRate,
    DisposableIncome,
    ConsumerSpending,
    MortgageRates,
    FedFundsRate,
    ConsumerSentiment,
    HourlyWages,
    SavingsRate,
    
    -- New Variables
    Inflation,
    WageGrowth_YoY,
    FedFundsRate_Lag3,
    ConsumerSentiment_Lag1,	
    ROUND(
		WageGrowth_YoY - Inflation,
		2
	) AS RealWageGrowth,
    
    -- YoY growth rates for remaining trend variables
    ConsumerSpending_YoY,
    DisposableIncome_YoY,
    GasPrices_YoY,

	-- Month-over-month changes 
    UnemploymentRate_MoM,
    ConsumerSentiment_MoM,

	-- Real (inflation-adjusted) rate variables
    ROUND(
		FedFundsRate - Inflation,
        2
	) AS RealFedFundsRate,
    ROUND(
		MortgageRates - Inflation,
        2
	) AS RealMortgageRate,
    
    -- Real hourly wage index (wages deflated by CPI)
    ROUND(
		HourlyWages / CPI * 100,
        2
	) AS RealHourlyWages
    
FROM (
	SELECT
		`Date`,
        CPI,
        GasPrices,
        UnemploymentRate,
        DisposableIncome,
        ConsumerSpending,
        MortgageRates,
        FedFundsRate,
        ConsumerSentiment,
        HourlyWages,
        SavingsRate,
    
		-- Create Inflation variable (YoY % change in CPI)
		ROUND(
			((CPI - LAG(CPI, 12) OVER (ORDER BY `Date`))
				/ LAG(CPI, 12) OVER (ORDER BY `Date`)) * 100, 2) 
                AS Inflation,
        
		-- Create Wage growth year-over-year variable
		ROUND(
			((HourlyWages - LAG(HourlyWages, 12) OVER (ORDER BY `Date`))
				/ LAG(HourlyWages, 12) OVER (ORDER BY `Date`)) * 100, 2) 
                AS WageGrowth_YoY,
        
		-- Create Federal funds rate lagged by 3 months variable 
		LAG(FedFundsRate, 3) OVER (ORDER BY `Date`) AS FedFundsRate_Lag3,
    
		-- Create Consumer sentiment lagged by 1 month variable
		LAG(ConsumerSentiment, 1) OVER (ORDER BY `Date`) AS ConsumerSentiment_Lag1,
        
        -- Create Consumer Spending year-over-year growth variable
        ROUND(
			((ConsumerSpending - LAG(ConsumerSpending, 12) OVER (ORDER BY `Date`))
				/ LAG(ConsumerSpending, 12) OVER (ORDER BY `Date`)) * 100, 2)
				AS ConsumerSpending_YoY,
                
		-- Create Disposable Income year-over-year growth variable
        ROUND(
			((DisposableIncome - LAG(DisposableIncome, 12) OVER (ORDER BY `Date`))
				/ LAG(DisposableIncome, 12) OVER (ORDER BY `Date`)) * 100, 2)
                AS DisposableIncome_YoY,
                
		-- Create Gas Prices year-over-year growth variable
        ROUND(
			((GasPrices - LAG(GasPrices, 12) OVER (ORDER BY `Date`))
				/ LAG(GasPrices, 12) OVER (ORDER BY `Date`)) * 100, 2)
                AS GasPrices_YoY,
                
		-- Create Unemployment Rate month-over-month change
        ROUND(
			UnemploymentRate - LAG(UnemploymentRate, 1) OVER (ORDER BY `Date`), 2)
				UnemploymentRate_MoM,
                
		-- Create Consumer Sentiment month-over-month change
        ROUND(
			((ConsumerSentiment - LAG(ConsumerSentiment, 1) OVER (ORDER BY `Date`))
				/ LAG(ConsumerSentiment, 1) OVER (ORDER BY `Date`)) * 100, 2)
                AS ConsumerSentiment_MoM
        
	FROM master_monthly
)t
ORDER BY `Date`;

-- Validation

SELECT COUNT(*) FROM master_monthly_features;
SELECT * FROM master_monthly_features ORDER BY `Date`;
