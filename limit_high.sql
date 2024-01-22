-- SQL Query to Identify Tickers with Specific High Limit Conditions
-- Author: Ruslana Kruk

-- Selecting tickers with specific high limit conditions based on ATR values and previous high limits
SELECT 
    Lim1.Ticker,
    Lim1.High,
    -- Calculating the beginning and end limits
    ROUND(Lim1.High - Lim1.Ti_Atr_5 * 0.2 * 0.2, 2) AS Limit_Begin,
    ROUND(Lim1.High + Lim1.Ti_Atr_5 * 0.2 * 0.2, 2) AS Limit_End,
    Lim1.Ti_Atr_5,
    -- Determining the limit count
    GREATEST(NVL2(Lim4.Ticker, 4, 0), NVL2(Lim3.Ticker, 3, 0), 2) AS Limit_Count,
    -- Determining if the limit is strong
    CASE
        WHEN Lim1.High = Lim2.High THEN 1
        ELSE NULL
    END AS Limit_Strong
FROM 
    Candle_Prices Lim1
JOIN 
    Candle_Prices Lim2 ON Lim2.Ticker = Lim1.Ticker
                         AND Lim2.Row_Num_Asc = Lim1.Row_Num_Asc - 1
                         AND Lim2.High BETWEEN Lim1.High - Lim1.Ti_Atr_5 * 0.2 * 0.2 
                                            AND Lim1.High + Lim1.Ti_Atr_5 * 0.2 * 0.2
LEFT JOIN 
    Candle_Prices Lim3 ON Lim3.Ticker = Lim1.Ticker
                         AND Lim3.Row_Num_Asc = Lim1.Row_Num_Asc - 2
                         AND Lim3.High BETWEEN Lim1.High - Lim1.Ti_Atr_5 * 0.2 * 0.2 
                                            AND Lim1.High + Lim1.Ti_Atr_5 * 0.2 * 0.2
LEFT JOIN 
    Candle_Prices Lim4 ON Lim4.Ticker = Lim1.Ticker
                         AND Lim4.Row_Num_Asc = Lim1.Row_Num_Asc - 3
                         AND Lim4.High BETWEEN Lim1.High - Lim1.Ti_Atr_5 * 0.2 * 0.2 
                                            AND Lim1.High + Lim1.Ti_Atr_5 * 0.2 * 0.2
WHERE 
    1 = 1 -- Placeholder for additional conditions
    AND Lim1.Is_Last = 1
    AND Lim1.Volume >= 100000
    AND Lim2.High = Lim1.High
    -- Uncomment to filter by specific date
    -- AND Lim1.Interval_Date_Time = '30.09.2021'
    AND Lim1.Ti_Atr_5 BETWEEN 1 AND 5
ORDER BY 
    Lim1.Ticker;
