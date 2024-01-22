-- Author: Ruslana Kruk
-- Language: SQL
-- Functionality: This SQL query finds the minimum low value for each ticker from Candle_Prices and identifies if it has been the lowest in the recent period.

WITH Min_Low_Values AS (
    SELECT CP.Ticker,
           MIN(CP.Low) AS Min_Low
    FROM Candle_Prices CP
    GROUP BY CP.Ticker
), Last_Min_Low AS (
    SELECT CP.Ticker,
           CP.Low,
           MAX(CP.Interval_Date_Time) AS Last_Low_Date
    FROM Candle_Prices CP
    INNER JOIN Min_Low_Values MLV
        ON MLV.Ticker = CP.Ticker
        AND MLV.Min_Low = CP.Low
    GROUP BY CP.Ticker, CP.Low
)
SELECT LML.Ticker,
       LML.Low,
       LML.Last_Low_Date
FROM Last_Min_Low LML
INNER JOIN Candle_Prices CP
    ON CP.Ticker = LML.Ticker
    AND CP.Is_Last = 1
    AND CP.Ti_Atr_5 >= 1
    AND CP.Volume > 300000
    AND ABS(CP.Close - LML.Low) < CP.Ti_Atr_5
LEFT JOIN Candle_Prices CP1
    ON CP1.Ticker = LML.Ticker
    AND CP1.Interval_Date_Time BETWEEN TRUNC(LML.Last_Low_Date + 1) AND TRUNC(SYSDATE)
    AND CP1.Low < LML.Low
LEFT JOIN Candle_Prices CP2
    ON CP2.Ticker = LML.Ticker
    AND CP2.Interval_Date_Time BETWEEN TRUNC(LML.Last_Low_Date + 1) AND TRUNC(SYSDATE)
    AND CP2.Close < LML.Low
WHERE LML.Last_Low_Date <= TRUNC(SYSDATE - 3)
GROUP BY LML.Ticker, LML.Low, LML.Last_Low_Date
ORDER BY 1;
