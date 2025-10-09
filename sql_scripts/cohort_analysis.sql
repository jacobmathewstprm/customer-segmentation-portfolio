CREATE OR REPLACE VIEW `mycapstoneprojects.online_retail.cohort_analysis_data` AS
WITH cohort_data AS (
  SELECT
    CustomerID,
    DATE_TRUNC(MIN(InvoiceDate), MONTH) AS CohortMonth
  FROM
    `mycap-capstone-projects.online_retail.online_retail_cleaned`
  GROUP BY
    CustomerID
)
SELECT
  main.CustomerID,
  c.CohortMonth,
  main.InvoiceDate,
  DATE_DIFF(DATE_TRUNC(main.InvoiceDate, MONTH), c.CohortMonth, MONTH) AS MonthNumber,
  main.Description,
  main.Quantity,
  main.UnitPrice
FROM
  `mycap-capstone-projects.online_retail.online_retail_cleaned` AS main
JOIN
  cohort_data AS c ON main.CustomerID = c.CustomerID;
