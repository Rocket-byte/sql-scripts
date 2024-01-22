-- SQL Query to Generate Prime Fibonacci Numbers Up to 2^5
-- Author: Ruslana Kruk

WITH Numbers AS (
    -- Generate numbers from 1 to 32 (2^5)
    SELECT LEVEL AS Numbb
    FROM DUAL
    CONNECT BY LEVEL <= POWER(2, 5)
),
Maxim AS (
    -- Find the maximum prime number in the generated sequence
    SELECT MAX(N1.Numbb) AS Maxx
    FROM Numbers N1
    WHERE NOT EXISTS (
        -- Exclude numbers that are not prime
        SELECT NULL
        FROM Numbers N2
        WHERE N1.Numbb > N2.Numbb
        AND N2.Numbb <> 1
        AND MOD(N1.Numbb, N2.Numbb) = 0
    )
    ORDER BY N1.Numbb
)
-- Calculate Fibonacci numbers and filter out non-prime ones
SELECT ROUND((POWER((1 + SQRT(5)) / 2, Num1.Numbb) - POWER((1 - SQRT(5)) / 2, Num1.Numbb)) / SQRT(5)) AS Fib
FROM Numbers Num1
WHERE EXISTS (
    SELECT * FROM Maxim m WHERE m.Maxx > Num1.Numbb
)
AND NOT EXISTS (
    -- Filter out Fibonacci numbers that are not prime
    SELECT NULL
    FROM Numbers N2
    WHERE ROUND((POWER((1 + SQRT(5)) / 2, Num1.Numbb) - POWER((1 - SQRT(5)) / 2, Num1.Numbb)) / SQRT(5)) > N2.Numbb
    AND N2.Numbb <> 1
    AND MOD(ROUND((POWER((1 + SQRT(5)) / 2, Num1.Numbb) - POWER((1 - SQRT(5)) / 2, Num1.Numbb)) / SQRT(5)), N2.Numbb) = 0
)
AND ROUND((POWER((1 + SQRT(5)) / 2, Num1.Numbb) - POWER((1 - SQRT(5)) / 2, Num1.Numbb)) / SQRT(5)) <> 1;
