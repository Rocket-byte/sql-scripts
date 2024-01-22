-- SQL Server Script for Student Sales Analysis
-- Author: Ruslana Kruk

-- Declare parameters for date range
DECLARE @DateBegin DATE = '2020-10-01'; -- Modify as needed
DECLARE @DateEnd DATE = GETDATE(); -- Current date or modify as needed

WITH Src AS (
    SELECT 
        c.Sales_Direction_Id,
        c.Student_Id,
        c.Period_Begin,
        Pc.Period_Sales,
        c.Period_Payments,
        SUM(ISNULL(Pc.Period_Sales, 0)) OVER (PARTITION BY c.Student_Id ORDER BY c.Period_Begin) AS Sales,
        SUM(ISNULL(c.Period_Payments, 0)) OVER (PARTITION BY c.Student_Id ORDER BY c.Period_Begin) AS Payments
    FROM 
        Period_Calculations c
    LEFT JOIN 
        Period_Calculations Pc ON Pc.Student_Id = c.Student_Id
                                 AND Pc.Sales_Direction_Id = c.Sales_Direction_Id
                                 AND Pc.Period_Begin = DATEADD(MONTH, -1, EOMONTH(c.Period_Begin, -1))
    WHERE 
        c.Sales_Direction_Id IN (1, 2)
        AND c.Period_Begin BETWEEN @DateBegin AND @DateEnd
    GROUP BY 
        c.Sales_Direction_Id, c.Student_Id, c.Period_Begin, Pc.Period_Sales, c.Period_Payments
),
Data AS (
    SELECT 
        Sr.Student_Id,
        s.Student_Fio,
        s.Student_Pact_Type_Name,
        s.Pact_Num,
        s.School_Name,
        s.Class_Num,
        s.Pact_Discont,
        s.Pact_Total,
        Sr.Period_Begin,
        SUM(CASE WHEN Sr.Sales_Direction_Id = 1 THEN Sr.Payments - Sr.Sales ELSE 0 END) AS Sale_Dir_1,
        SUM(CASE WHEN Sr.Sales_Direction_Id = 2 THEN Sr.Payments - Sr.Sales ELSE 0 END) AS Sale_Dir_2
    FROM 
        Src Sr
    JOIN 
        Vw_Xed_Student_Pacts s ON s.Student_Id = Sr.Student_Id
    WHERE 
        s.Student_Pact_Type = 0
        AND Sr.Period_Begin >= @DateBegin
    GROUP BY 
        Sr.Student_Id, s.Student_Fio, s.Student_Pact_Type_Name, s.Pact_Num, s.School_Name, s.Class_Num, s.Pact_Discont, s.Pact_Total, Sr.Period_Begin
    ORDER BY 
        s.Student_Fio, Sr.Period_Begin
)
SELECT 
    d.Student_Id,
    d.Student_Fio,
    Sale_Dir_1,
    Sale_Dir_2,
    p.Bind_Type_Id,
    p.Client_Fio,
    p.Default_Mail,
    p.Default_Phone
FROM 
    Data d
JOIN 
    Ai_Students_Payer p ON p.Student_Id = d.Student_Id AND p.Bind_Type_Id = 1
