-- SQL Query for Price Break Analysis in Financial Data
-- Author: Ruslana Kruk

WITH Pb AS (
    -- Subquery to select specific tickers based on various conditions
    SELECT 
        p.Ticker,
        p.Interval_Date_Time AS Date_Start,
        Lp.Interval_Date_Time AS Date_End,
        p.High,
        p.Low
    FROM 
        Candle_Prices p
    JOIN 
        Candle_Prices Pre ON Pre.Ticker = p.Ticker
                            AND Pre.Row_Num_Asc = p.Row_Num_Asc - 1
    JOIN 
        Candle_Prices Lp ON Lp.Ticker = p.Ticker
                            AND Lp.Is_Last = 1
                            AND Lp.Ti_Atr_5 >= 1
                            AND Lp.Volume > 300000
                            AND ABS(Lp.Close - p.High) < Lp.Ti_Atr_5
    WHERE 
        1 = 1 -- Placeholder for additional conditions
        AND (
            ABS(p.Change_Open_Percent) > 10 
            OR ABS(p.Change_Percent) > 10 
            OR (p.High - p.Low) >= Pre.Ti_Atr_5 * 2.5
        )
        AND p.Row_Num_Desc BETWEEN 5 AND 120
)
-- Main query to select tickers and count occurrences based on certain conditions
SELECT 
    Pb.Ticker,
    ',' AS Separator,
    Pb.Date_Start,
    Pb.High,
    Pb.Low,
    COUNT(DISTINCT c.Row_Num_Asc) AS q_Hi,
    COUNT(DISTINCT Cl.Row_Num_Asc) AS q_Close
FROM 
    Pb
LEFT JOIN 
    Candle_Prices c ON c.Ticker = Pb.Ticker
                      AND c.Interval_Date_Time BETWEEN Pb.Date_Start AND TRUNC(SYSDATE)
                      AND c.High > Pb.High
LEFT JOIN 
    Candle_Prices Cl ON Cl.Ticker = Pb.Ticker
                       AND Cl.Interval_Date_Time BETWEEN Pb.Date_Start AND TRUNC(SYSDATE)
                       AND Cl.Close > Pb.High
GROUP BY 
    Pb.Ticker,
    Pb.Date_Start,
    Pb.Date_End,
    Pb.High,
    Pb.Low
HAVING 
    COUNT(DISTINCT Cl.Row_Num_Asc) < 1 AND COUNT(DISTINCT c.Row_Num_Asc) < 1
ORDER BY 
    1;
