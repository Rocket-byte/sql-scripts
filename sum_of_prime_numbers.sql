-- SQL Query to Calculate the Sum of Prime Numbers Up to 2^4
-- Author: Ruslana Kruk

WITH Numbers AS (
    -- Generate numbers from 1 to 16 (2^4)
    SELECT LEVEL AS Numbb
    FROM DUAL
    CONNECT BY LEVEL <= POWER(2, 4)
)
-- Sum numbers that are prime
SELECT SUM(N1.Numbb)
FROM Numbers N1
WHERE NOT EXISTS (
    -- Exclude numbers that are divisible by any number other than 1 and themselves
    SELECT NULL
    FROM Numbers N2
    WHERE N1.Numbb > N2.Numbb
    AND MOD(N1.Numbb, N2.Numbb) = 0
    AND N2.Numbb <> 1
)
ORDER BY N1.Numbb;
