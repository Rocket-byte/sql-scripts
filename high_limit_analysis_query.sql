-- Author: Ruslana Kruk
-- Language: SQL
-- Functionality: This SQL query identifies candle prices within a specified limit range and evaluates the strength of this limit.

SELECT Lim1.Ticker,
       Lim1.High,
       ROUND(Lim1.High - Lim1.Ti_Atr_5 * 0.04, 2) AS Limit_Begin,
       ROUND(Lim1.High + Lim1.Ti_Atr_5 * 0.04, 2) AS Limit_End,
       Lim1.Ti_Atr_5,
       GREATEST(NVL2(Lim4.Ticker, 4, 0), NVL2(Lim3.Ticker, 3, 0), 2) AS Limit_Count,
       CASE
           WHEN Lim1.High = Lim2.High THEN 1
           ELSE NULL
       END AS Limit_Strong
FROM Candle_Prices Lim1
INNER JOIN Candle_Prices Lim2
    ON Lim2.Ticker = Lim1.Ticker
    AND Lim2.Row_Num_Asc = Lim1.Row_Num_Asc - 1
    AND Lim2.High BETWEEN Lim1.High - Lim1.Ti_Atr_5 * 0.04 AND Lim1.High + Lim1.Ti_Atr_5 * 0.04
LEFT JOIN Candle_Prices Lim3
    ON Lim3.Ticker = Lim1.Ticker
    AND Lim3.Row_Num_Asc = Lim1.Row_Num_Asc - 2
    AND Lim3.High BETWEEN Lim1.High - Lim1.Ti_Atr_5 * 0.04 AND Lim1.High + Lim1.Ti_Atr_5 * 0.04
LEFT JOIN Candle_Prices Lim4
    ON Lim4.Ticker = Lim1.Ticker
    AND Lim4.Row_Num_Asc = Lim1.Row_Num_Asc - 3
    AND Lim4.High BETWEEN Lim1.High - Lim1.Ti_Atr_5 * 0.04 AND Lim1.High + Lim1.Ti_Atr_5 * 0.04
WHERE Lim1.Is_Last = 1
      AND Lim1.Volume >= 100000
      AND Lim2.High = Lim1.High
      AND Lim1.Ti_Atr_5 BETWEEN 1 AND 5
ORDER BY Lim1.Ticker;
