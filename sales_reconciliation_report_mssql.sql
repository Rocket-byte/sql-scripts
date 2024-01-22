-- SQL Server Script for Sales Reconciliation Between Lab and Sales_1c Data
-- Author: Ruslana Kruk

-- Declare parameters for date range
DECLARE @StartDate DATE = '2018-01-01';
DECLARE @EndDate DATE = '2018-01-23';

-- Subquery for sales data from Sales_1c
WITH Cc AS (
    SELECT 
        t.Order_Uid AS Order_Uid_1c,
        t.Order_Sap_Code AS Sap_Code_1c,
        t.Receipt_Currency AS Curr_1c,
        SUM(t.Sum_Original + t.Sum_Discount - t.Sum_Points_Real) AS Sm_1c,
        SUM(t.Sum_Franchise_Patient) AS Fran_Pat_1c,
        SUM(t.Sum_Franchise_Client) AS Fran_Client_1c,
        SUM(t.Sum_Points_Real) AS Pts_Real_1c
    FROM 
        Lab.Sales_1c t
    WHERE 
        CONVERT(DATE, t.Receipt_Date) BETWEEN @StartDate AND @EndDate
    GROUP BY 
        t.Order_Uid, t.Order_Sap_Code, t.Receipt_Currency
    HAVING 
        SUM(t.Sum_Original + t.Sum_Discount - t.Sum_Points_Real) <> 0 
        OR SUM(t.Sum_Franchise_Patient) <> 0 
        OR SUM(t.Sum_Franchise_Client) <> 0 
        OR SUM(t.Sum_Points_Real) <> 0
),

Lab AS (
    SELECT 
        o.Order_Uid,
        o.Sap_Code,
        CASE 
            WHEN Rp.Currency_Id IN (9, 10) THEN Rpm.Currency_Id 
            ELSE Rp.Currency_Id 
        END AS Curr_Id,
        SUM(CASE WHEN Rp.Currency_Id <> 10 THEN Rp.Total_Pay ELSE 0 END) AS Fact,
        SUM(CASE WHEN Rp.Currency_Id IN (7, 8) THEN Rp.Total_Pay ELSE 0 END) AS Fr_Patient,
        SUM(CASE WHEN Rp.Currency_Id = 9 THEN Rp.Total_Pay ELSE 0 END) AS Fr_Client,
        SUM(CASE WHEN Rp.Currency_Id = 10 THEN Rp.Total_Pay ELSE 0 END) AS Pts_Real
    FROM 
        Lab.Receipts r
    JOIN 
        Lab.Orders o ON r.Order_Uid = o.Order_Uid
    JOIN 
        Lab.Receipt_Payments Rp ON r.Receipt_Uid = Rp.Receipt_Uid
    LEFT JOIN 
        Lab.Receipt_Payments Rpm ON r.Receipt_Uid = Rpm.Receipt_Uid AND Rpm.Currency_Id NOT IN (9, 10)
    JOIN 
        Erp.Lab_Poses Lp ON r.Pos_Id = Lp.Pos_Id
    WHERE 
        o.Lab_Id > 0
        AND r.Status > 0
        AND o.Status > 0
        AND Lp.Pos_Type < 888
        AND Rp.Is_Active = 1
        AND CONVERT(DATE, r.Shift_Date) BETWEEN @StartDate AND @EndDate
    GROUP BY 
        o.Order_Uid, o.Sap_Code, 
        CASE WHEN Rp.Currency_Id IN (9, 10) THEN Rpm.Currency_Id ELSE Rp.Currency_Id END
    HAVING 
        SUM(CASE WHEN Rp.Currency_Id <> 10 THEN Rp.Total_Pay ELSE 0 END) <> 0 
        OR SUM(CASE WHEN Rp.Currency_Id IN (7, 8) THEN Rp.Total_Pay ELSE 0 END) <> 0 
        OR SUM(CASE WHEN Rp.Currency_Id = 9 THEN Rp.Total_Pay ELSE 0 END) <> 0 
        OR SUM(CASE WHEN Rp.Currency_Id = 10 THEN Rp.Total_Pay ELSE 0 END) <> 0
)

-- Main query to reconcile and compare sales data between Cc and Lab
SELECT 
    ISNULL(Cc.Order_Uid_1c, Lab.Order_Uid) AS Order_Uid,
    ISNULL(Cc.Sap_Code_1c, Lab.Sap_Code) AS Sap_Code,
    Cc.Curr_1c,
    Cc.Sm_1c AS Summa_1c,
    Cc.Fran_Pat_1c,
    Cc.Fran_Client_1c,
    Cc.Pts_Real_1c,
    Lab.Curr_Id,
    Lab.Fact AS Summa_Rcp,
    Lab.Fr_Patient,
    Lab.Fr_Client,
    Lab.Pts_Real
FROM 
    Cc
FULL JOIN 
    Lab ON Cc.Order_Uid_1c = Lab.Order_Uid AND Cc.Curr_1c = Lab.Curr_Id
WHERE 
    ISNULL(Cc.Sm_1c, 0) <> ISNULL(Lab.Fact, 0)
    OR ISNULL(Cc.Fran_Pat_1c, 0) <> ISNULL(Lab.Fr_Patient, 0)
    OR ISNULL(Cc.Fran_Client_1c, 0) <> ISNULL(Lab.Fr_Client, 0)
    OR ISNULL(Cc.Pts_Real_1c, 0) <> ISNULL(Lab.Pts_Real, 0)
ORDER BY 
    ISNULL(Cc.Order_Uid_1c, Lab.Order_Uid);
