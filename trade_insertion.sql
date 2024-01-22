-- SQL Insert Statement for Trade Data based on Specific Conditions
-- Author: Ruslana Kruk

INSERT INTO Trades
    (Level_Type,
    Level_Description,
    Level_Information,
    Ticker,
    Level_Interval,
    Level_Time,
    Level_Cost,
    Time_Start,
    Work_Interval,
    Work_Max_Day,
    Entry_Point,
    Stop_Loss,
    Take_Profit)
SELECT 
    'LOW BSU+BPU1+BPU2' AS Level_Type,
    'SL 0.01 $, TP - 0.09 $' AS Level_Description,
    TO_CHAR(MIN(Bpu_2.Row_Num_Asc) - MIN(Bsu.Row_Num_Asc) + 1) || ' - BSU Distance' AS Level_Information,
    Bsu.Ticker,
    Bsu.Interval,
    MIN(Bpu_2.Interval_Date_Time) AS Level_Time,
    Bsu.Low,
    MIN(Bpu_2.Interval_Date_Time) + 1 / 24 / 2 + 1 / 24 / 12 AS Time_Start,
    '5m' AS Work_Interval,
    TRUNC(MIN(Bpu_2.Interval_Date_Time)) + 1 - 1 / 24 AS Work_Max_Day,
    -- Calculating Entry Point, Stop Loss, and Take Profit
    Bsu.Low + 0.0 AS Entry_Point,
    Bsu.Low - 0.05 AS Stop_Loss,
    Bsu.Low + 0.1 AS Take_Profit
FROM 
    Intraday Bsu
JOIN 
    Tickers t ON t.Ticker = Bsu.Ticker
                AND NVL(t.Ticker_Type, 'NOT') <> 'CRYPTO'
JOIN 
    Intraday Bpu_1 ON Bpu_1.Ticker = Bsu.Ticker
                    AND Bpu_1.Interval = Bsu.Interval
                    AND TRUNC(Bpu_1.Interval_Date_Time) = TRUNC(Bsu.Interval_Date_Time)
                    AND Bpu_1.Row_Num_Asc = Bsu.Row_Num_Asc + 1
                    AND Bpu_1.Low = Bsu.Low
JOIN 
    Intraday Bpu_2 ON Bpu_2.Ticker = Bpu_1.Ticker
                    AND Bpu_2.Interval = Bpu_1.Interval
                    AND TRUNC(Bpu_2.Interval_Date_Time) = TRUNC(Bpu_1.Interval_Date_Time)
                    AND Bpu_2.Row_Num_Asc = Bpu_1.Row_Num_Asc + 1
                    AND Bpu_2.Low = Bpu_1.Low
JOIN 
    Intraday Bpu_3 ON Bpu_3.Ticker = Bpu_2.Ticker
                    AND Bpu_3.Interval = Bpu_2.Interval
                    AND TRUNC(Bpu_3.Interval_Date_Time) = TRUNC(Bpu_2.Interval_Date_Time)
                    AND Bpu_3.Row_Num_Asc = Bpu_2.Row_Num_Asc + 1
                    AND Bpu_3.Low = Bpu_2.Low
WHERE 
    1 = 1 -- Placeholder for additional conditions
    AND Bsu.Interval_Date_Time >= TRUNC(SYSDATE - 2)
    AND Bsu.Interval = '30m'
GROUP BY 
    Bsu.Ticker,
    Bsu.Interval,
    Bsu.Low
ORDER BY 
    MIN(Bpu_2.Interval_Date_Time) DESC,
    1;
COMMIT;
