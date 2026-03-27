create database ETL;
use ETL;
CREATE TABLE CustomerData (
       Customer_ID INT PRIMARY KEY,
       Name VARCHAR(50),
       City VARCHAR(50),
       Monthly_Sales INT,
       Income INT,
       Region VARCHAR(50)
   );
   
   INSERT INTO CustomerData (Customer_ID, Name, City, Monthly_Sales, Income, Region)
   VALUES
   (101, 'Rahul Mehta', 'Mumbai', 12000, 65000, 'West'),
   (102, 'Anjali Rao', 'Bengaluru', NULL, NULL, 'South'),
   (103, 'Suresh Iyer', 'Chennai', 15000, 72000, 'South'),
   (104, 'Neha Singh', 'Delhi', NULL, NULL, 'North'),
   (105, 'Amit Verma', 'Pune', 18000, 58000, NULL),
   (106, 'Karan Shah', 'Ahmedabad', NULL, 61000, 'West'),
   (107, 'Pooja Das', 'Kolkata', 14000, NULL, 'East'),
   (108, 'Riya Kapoor', 'Jaipur', 16000, 89000, 'North');
   
   select * from CustomerData;
   
  ##Q8. Listwise Deletion 
  ##Remove all rows where Region is missing. 
  ## 1.Identify affected rows

   select * 
   from CustomerData
   where Region is NULL;
   
   ## 2. Show the dataset after deletion
   
   delete from  CustomerData
  where Region is NULL;
  
  ## 3. Mention how many records were lost
  
   select COUNT(*) as LostRecords
   from CustomerData
   where Region is NULL;
   
    select * from CustomerData;
   
## Q9. Imputation 
## Handle missing values in Monthly_Sales using
## 1. Apply forward fill

    CREATE TABLE TempSales AS
   SELECT Customer_ID, 
          Monthly_Sales,
          LAG(Monthly_Sales) OVER (ORDER BY Customer_ID) AS PrevSales
   FROM CustomerData;
   
  ##Imputation query
   
   UPDATE CustomerData
   SET Monthly_Sales = (
       SELECT COALESCE(PrevSales, Monthly_Sales)
       FROM TempSales
       WHERE TempSales.Customer_ID = CustomerData.Customer_ID
   )
   WHERE Monthly_Sales IS NULL;
   
   ## 2. Before & After comparison:
    --- Before: Customer 102, 104, 106 have NULL in Monthly_Sales.
    --- After:
   
   ## 3.Why Forward Fill is suitable:
   --- It uses the nearest preceding non‑null value, which is appropriate when data is ordered and missing values are sequential.
   
   
   ##Q10. Flagging Missing Data
   ## Create a flag column for missing Income.
   ## 1.Create Income_Missing_Flag (0 = present, 1 = missing)
   
   ALTER TABLE CustomerData
   ADD Income_Missing_Flag INT;
   
   SELECT * FROM CustomerData;

SELECT Customer_ID,Name,City, Monthly_Sales,Region, Income, 
          CASE 
              WHEN Income IS NULL THEN 1 
              ELSE 0 
          END AS Flag
   FROM CustomerData;
   
   SELECT * FROM CustomerData;
   
ALTER TABLE CustomerData
DROP COLUMN Income_Missing_Flag;

ALTER TABLE CustomerData
ADD Income_Missing_Flag INT DEFAULT 0;
   
   ## 2.Show updated dataset

UPDATE CustomerData
SET Income_Missing_Flag = CASE 
    WHEN Income IS NULL THEN 1 
    ELSE 0 
END ;
SELECT * FROM CustomerData;
   
   ## 3.Count how many customers have missing income
   
   SELECT COUNT(*) AS MissingIncomeCount
   FROM CustomerData
   WHERE Income_Missing_Flag = 1;
   
    SELECT * FROM CustomerData;
   
   
   