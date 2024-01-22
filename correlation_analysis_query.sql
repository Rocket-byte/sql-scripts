-- Author: Ruslana Kruk
-- Language: SQL
-- Functionality: This SQL query calculates the correlation coefficient between the 'Change_Percent' values of 'QQQ' and 'SPY' stocks over recent periods.

SELECT CORR(SPY_Change, QQQ_Change) AS Correlation_Coefficient
FROM (
    SELECT p.Interval_Date_Time,
           SUM(CASE WHEN p.Symbol = 'SPY' THEN p.Change_Percent ELSE 0 END) AS SPY_Change,
           SUM(CASE WHEN p.Symbol = 'QQQ' THEN p.Change_Percent ELSE 0 END) AS QQQ_Change
    FROM Prices p
    WHERE p.Symbol IN ('SPY', 'QQQ')
          AND p.Row_Num_Desc < 61
    GROUP BY p.Interval_Date_Time
    ORDER BY p.Interval_Date_Time
);
