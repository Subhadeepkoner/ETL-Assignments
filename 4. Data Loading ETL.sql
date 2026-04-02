CREATE DATABASE OrderDB;
USE OrderDB;

CREATE TABLE Orders (
    Order_ID VARCHAR(10),
    Customer_ID VARCHAR(10),
    Sales_Amount VARCHAR(50),
    Order_Date VARCHAR(20)
);
INSERT INTO Orders VALUES
('O101','C001','4500','12-01-2024'),
('O102','C002',NULL,'15-01-2024'),
('O103','C003','3200','2024/01/18'),
('O101','C001','4500','12-01-2024'),
('O104','C004','Three Thousand','20-01-2024'),
('O105','C005','5100','25-01-2024');
select * from Orders;


#### Q1. Data Understanding
## Identify all data quality issues present in the dataset that can cause problems during data loading

##>>Data Quality Issues Identified
   #>i) Duplicate Order_ID → O101 appears twice
   #>ii) Missing value → Sales_Amount is NULL (O102)
   #>iii) Invalid data type → "Three Thousand" (O104)
   #>iv) Inconsistent date formats → DD-MM-YYYY and YYYY/MM/DD
   

#### Q2. Primary Key Validation
## Assume Order_ID is the Primary Key. 

# a) Is the dataset violating the Primary Key rule?
   #> Yes, Order_ID is duplicated.
   
# b) Which record(s) cause this violation?
   #> O101 appears twice.
   
SELECT Order_ID, COUNT(*) AS Count
FROM Orders
GROUP BY Order_ID
HAVING COUNT(*) > 1;


#### Q3. Missing Value Analysis
## Which column(s) contain missing values?

# a) List the affected records
   #> Sales_Amount
   
# b) Explain why loading these records without handling missing values is risky
   #> O102

SELECT *
FROM Orders
WHERE Sales_Amount IS NULL;

# c) Risky
   #> i) Incorrect total sales  ii) Inaccurate reports


#### Q4. Data Type Validation
## Identify records where Sales_Amount violates expected data type rules.

# a) Which record(s) will fail numeric validation?
# b) What would happen if this dataset is loaded into a SQL table with Sales_Amount as DECIMAL?
   
   #> Sales_Amount should be numeric but contains text.
   
   SELECT *
FROM Orders
WHERE Sales_Amount REGEXP '[^0-9]';

   #>Impact
    #> i) Insert failure if numeric type enforced
    #> ii) Incorrect calculations


#### Q5. Date Format Consistency
## The column has multiple formats

# a) List all date formats present in the dataset.
   #> Formats found
    #>> 12-01-2024
	#>> 2024/01/18

SELECT Order_Date,
CASE 
    WHEN Order_Date LIKE '__-__-____' THEN 'DD-MM-YYYY'
    WHEN Order_Date LIKE '____/__/__' THEN 'YYYY/MM/DD'
    ELSE 'Unknown Format'
END AS Date_Format
FROM Orders;
  
# b) Why is this a problem during data loading?
   #> i) Incorrect sorting     ii) Filtering issues


#### Q6. Load Readiness Decision
## Based on the dataset condition:

# a) Should this dataset be loaded directly into the database? (Yes/No)
   #> NO
   
 # b) Justify your answer with at least three reasons.
    #> Reasons Are:
	 #>> Duplicate records
     #>> Missing values
     #>> Invalid data types
     #>> Inconsistent date formats

#### Q7. Pre-Load Validation Checklist
## List the exact pre-load validation checks you would perform on this dataset before loading.

#>> i) Duplicate Check
SELECT Order_ID, COUNT(*)
FROM Orders
GROUP BY Order_ID
HAVING COUNT(*) > 1;

#>> ii) NULL Check
SELECT *
FROM Orders
WHERE Sales_Amount IS NULL;

#>> iii) Data Type Check
SELECT *
FROM Orders
WHERE Sales_Amount REGEXP '[^0-9]';

#>> iv) Date Format Check 
SELECT Order_Date,
CASE 
    WHEN Order_Date LIKE '__-__-____' THEN 'DD-MM-YYYY'
    WHEN Order_Date LIKE '____/__/__' THEN 'YYYY/MM/DD'
    ELSE 'Unknown Format'
END AS Date_Format
FROM Orders;


#### Q8. Cleaning Strategy
## Describe the step-by-step cleaning actions required to make this dataset load-ready.

INSERT INTO Orders VALUES ('O101','C001','4500','12-01-2024');
select * from Orders;

#>>Step 0: Safe Mode OFF (important)
SET SQL_SAFE_UPDATES = 0;

#>> Step 1: Step 1: Fix Invalid Data (Text → Numeric)
UPDATE Orders
SET Sales_Amount = '3000'
WHERE Order_ID = 'O104';
COMMIT;
SELECT * FROM Orders
WHERE Order_ID = 'O104';

#>>Step 2: Handle NULL Values
UPDATE Orders
SET Sales_Amount = 0
WHERE Sales_Amount IS NULL;
SELECT * FROM Orders WHERE Sales_Amount IS NULL;
commit;
select * from Orders;

#>> Step 3: Convert Column to Numeric Type
ALTER TABLE Orders
MODIFY Sales_Amount INT;
DESC Orders;
select * from Orders;

#>> Step 4: Remove Duplicate Records
DELETE FROM Orders
WHERE Order_ID = 'O101'
LIMIT 1;

#>> Step 5: Fix YYYY/MM/DD
UPDATE Orders
SET Order_Date = STR_TO_DATE(Order_Date, '%Y/%m/%d')
WHERE Order_Date LIKE '%/%';

#>> step 6: Fix DD-MM-YYYY
UPDATE Orders
SET Order_Date = STR_TO_DATE(Order_Date, '%d-%m-%Y')
WHERE Order_Date LIKE '__-__-____';

#>> step 7: Convert to DATE
ALTER TABLE Orders
MODIFY Order_Date DATE;

#>> step 8: Final Output
select * from Orders;


#### Q9. Loading Strategy Selection
## Assume this dataset represents daily sales data.

# a) Should a Full Load or Incremental Load be used?
   #>> Incremental Load
   
# b) Justify your choice. 
   #> >Daily sales data
   #>> New records added regularly
   #>> More efficient than full load


#### Q10. BI Impact Scenario
## Assume this dataset was loaded without cleaning and connected to a BI dashboard.   

# a) What incorrect results might appear in Total Sales KPI?
   #>> Wrong total sales 
   #>> Duplicate counting
   
# b) Which records specifically would cause misleading insights?   
   #>> O101 (duplicate)
   #>> O102 (NULL)
   #>> O104 (invalid text)
   
# c) Why would BI tools not detect these issues automatically?
   #>> Assume clean data
   #>> No automatic validation
   #>> Garbage in, garbage out
   
##>>>The dataset contains multiple data quality issues and should not be loaded directly.Proper data cleaning and validation must be performed to ensure accurate reporting and analysis.