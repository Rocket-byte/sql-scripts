-- Author: Ruslana Kruk
-- Language: SQL
-- Functionality: This SQL query identifies candles in the Candle_Prices table demonstrating continuous growth over six consecutive intervals.

SELECT P1.*
FROM Candle_Prices P1
JOIN Candle_Prices P2 ON P2.Ticker = P1.Ticker
    AND P2.Interval = P1.Interval
    AND P2.Row_Num_Asc = P1.Row_Num_Asc + 1
    AND P2.Low > P1.Low
    AND P2.High > P1.High
JOIN Candle_Prices P3 ON P3.Ticker = P2.Ticker
    AND P3.Interval = P2.Interval
    AND P3.Row_Num_Asc = P2.Row_Num_Asc + 1
    AND P3.Low > P2.Low
    AND P3.High > P2.High
JOIN Candle_Prices P4 ON P4.Ticker = P3.Ticker
    AND P4.Interval = P3.Interval
    AND P4.Row_Num_Asc = P3.Row_Num_Asc + 1
    AND P4.Low > P3.Low
    AND P4.High > P3.High
JOIN Candle_Prices P5 ON P5.Ticker = P4.Ticker
    AND P5.Interval = P4.Interval
    AND P5.Row_Num_Asc = P4.Row_Num_Asc + 1
    AND P5.Low > P4.Low
    AND P5.High > P4.High
JOIN Candle_Prices P6 ON P6.Ticker = P5.Ticker
    AND P6.Interval = P5.Interval
    AND P6.Row_Num_Asc = P5.Row_Num_Asc + 1
    AND P6.Low > P5.Low
    AND P6.High > P5.High
WHERE P6.Is_Last = 1
    AND P6.Ti_Atr_5 > 1
    AND P6.Volume > 300000
ORDER BY 1;
