CREATE OR REPLACE VIEW `mycapstoneprojects.online_retail.rfm_customer_segments` AS
WITH rfm_data_view AS (
    SELECT
        CustomerID,
        MAX(InvoiceDate) AS LastPurchaseDate,
        COUNT(DISTINCT InvoiceNo) AS Frequency,
        SUM(Quantity * UnitPrice) AS Monetary
    FROM `mycapstoneprojects.online_retail.online_retail_cleaned`
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
),
rfm_scores AS (
    SELECT
        CustomerID,
        NTILE(4) OVER (ORDER BY LastPurchaseDate DESC) AS R_Score,
        NTILE(4) OVER (ORDER BY Frequency) AS F_Score,
        NTILE(4) OVER (ORDER BY Monetary) AS M_Score
    FROM rfm_data_view
)
SELECT
    s.CustomerID,
    d.Monetary,
    s.R_Score,
    s.F_Score,
    s.M_Score,
    CAST(s.R_Score AS STRING) || CAST(s.F_Score AS STRING) || CAST(s.M_Score AS STRING) AS RFM_Score,
    CASE
        WHEN s.R_Score >= 3 AND s.F_Score >= 3 AND s.M_Score >= 3 THEN 'Loyal Customers'
        WHEN s.R_Score >= 3 THEN 'Promising'
        WHEN s.R_Score <= 2 AND s.F_Score >= 3 THEN 'At-Risk'
        WHEN s.R_Score <= 2 AND s.M_Score >= 4 THEN 'Lapsed VIPs'
        ELSE 'Lost'
    END AS CustomerSegment
FROM
    rfm_scores AS s
JOIN
    rfm_data_view AS d ON s.CustomerID = d.CustomerID;
