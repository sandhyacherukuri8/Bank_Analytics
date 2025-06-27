
CREATE DATABASE bank_analytics ;
use bank_analytics;

-- All Data 
select * from LoanAccounts;

update LoanAccounts
set Disbursement_Date =STR_TO_DATE(Disbursement_Date , '%d-%m-%Y');

alter table LoanAccounts
 modify  Disbursement_Date date;

ALTER TABLE LoanAccounts
DROP COLUMN Disbursement_Date_Years;
-----------------------------------------------------------------------------------------------------------------------------------------------
-- 1. Total Loan Amount Funded

SELECT CONCAT(ROUND(SUM(Loan_Amount)/1000000, 2), ' M') AS Total_Loan_Amount
FROM LoanAccounts;

-----------------------------------------------------------------------------------------------------------------------------------------------
-- 2. Total Loans

SELECT COUNT(*) AS Total_Loans FROM LoanAccounts;

-----------------------------------------------------------------------------------------------------------------------------------------------
-- 3. Total Collection

SELECT CONCAT(ROUND(SUM(Total_Rec_Prncp + Total_Rrec_Int)/1000000, 2), ' M') AS Total_Collection
FROM LoanAccounts;

-----------------------------------------------------------------------------------------------------------------------------------------------
-- 4. Total Interest

SELECT CONCAT(ROUND(SUM(Total_Rrec_Int)/1000000, 2), ' M') AS Total_Interest
FROM LoanAccounts;

-----------------------------------------------------------------------------------------------------------------------------------------------
-- 5. Branch-Wise Performance

SELECT 
    Branch_Name,
    ROUND(SUM(Total_Rrec_Int), 2) AS Interest_Revenue,
    ROUND(SUM(Total_Fees), 2) AS Fee_Revenue,
    ROUND(SUM(Total_Rrec_Int + Total_Fees), 2) AS Total_Revenue
FROM LoanAccounts
GROUP BY Branch_Name
ORDER BY Branch_Name;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  6. State-Wise Loan
 
SELECT 
    State_Name,
    CONCAT(ROUND(SUM(Loan_Amount) / 1000000, 2), ' M') AS Total_Loan
FROM LoanAccounts
WHERE State_Name IS NOT NULL 
  AND State_Name != '' 
  AND State_Name NOT IN ('No Data', 'NA', 'Unknown', 'State Name')  -- Remove header too
GROUP BY State_Name
HAVING SUM(Loan_Amount) > 100000;

---------------------------------------------------------------------------------------------------------------------------------------------
-- 7. Religion-Wise Loan
 
 SELECT 
    Religion,
    CONCAT(ROUND(SUM(Loan_Amount) / 1000000, 2), ' M') AS Total_Loan
FROM LoanAccounts
WHERE Religion IS NOT NULL 
  AND Religion != '' 
  AND Religion NOT IN ('No Data', 'NA', 'N/A', 'Unknown')
GROUP BY Religion
HAVING SUM(Loan_Amount) > 100000;

---------------------------------------------------------------------------------------------------------------------------------------------
-- 8. Product Group-Wise Loan

SELECT 
    Purpose_Category AS Product_Group,
    CONCAT(ROUND(SUM(Loan_Amount) / 1000000, 2), ' M') AS Total_Loan
FROM LoanAccounts
WHERE Purpose_Category IS NOT NULL 
  AND Purpose_Category != '' 
  AND Purpose_Category NOT IN ('No Data', 'NA', 'N/A', 'Unknown')
GROUP BY Purpose_Category
HAVING SUM(Loan_Amount) > 100000;

---------------------------------------------------------------------------------------------------------------------------------------------
-- 9. Disbursement Trend (Per Month)

 SELECT 
    DATE_FORMAT(Disbursement_Date, '%b %Y') AS Month,  -- e.g., Jan 2017
    CONCAT(ROUND(SUM(Loan_Amount) / 1000000, 2), ' M') AS Total_Disbursed
FROM LoanAccounts
WHERE Disbursement_Date IS NOT NULL 
  AND YEAR(Disbursement_Date) > 1900  -- skips '0000-00-00' without direct comparison
GROUP BY DATE_FORMAT(Disbursement_Date, '%b %Y')
HAVING SUM(Loan_Amount) > 100000
ORDER BY MIN(Disbursement_Date);  -- ensure correct month order

---------------------------------------------------------------------------------------------------------------------------------------------
-- 10. Grade-Wise Loan
 
 SELECT 
    Grade,
    COUNT(*) AS Loan_Count,
    CONCAT(ROUND(SUM(Loan_Amount) / 1000000, 2), ' M') AS Total_Loan_Amount
FROM LoanAccounts
WHERE Grade IS NOT NULL 
  AND Grade != '' 
  AND Grade NOT IN ('No Data', 'NA', 'Unknown')
GROUP BY Grade
HAVING SUM(Loan_Amount) > 100000;

---------------------------------------------------------------------------------------------------------------------------------------------
-- 11. Default Loan Count

SELECT COUNT(*) AS Default_Loan_Count 
FROM LoanAccounts 
WHERE Is_Default_Loan = 'Y';

---------------------------------------------------------------------------------------------------------------------------------------------
-- 12. Delinquent Client Count

SELECT COUNT(*) AS Delinquent_Clients
FROM LoanAccounts
WHERE Is_Delinquent_Loan = 'Y';

---------------------------------------------------------------------------------------------------------------------------------------------
-- 13. Delinquent Loan Rate

SELECT 
    concat(ROUND((count(CASE WHEN Is_Delinquent_Loan = 'Y' THEN 1 END)* 100.0) / COUNT(*), 2), '%') AS Delinquent_Loan_Rate
FROM LoanAccounts;

---------------------------------------------------------------------------------------------------------------------------------------------
-- 14. Default Loan Rate

SELECT 
    CONCAT(ROUND((COUNT(CASE WHEN Is_Default_Loan = 'Y' THEN 1 END) * 100.0) / COUNT(*), 2), '%') AS Default_Loan_Rate
FROM LoanAccounts;
---------------------------------------------------------------------------------------------------------------------------------------------
-- 15. Loan Status-Wise Loan
 
 SELECT 
    Loan_Status,
    COUNT(*) AS Loan_Count,
    CONCAT(ROUND(SUM(Loan_Amount) / 1000000, 2), ' M') AS Total_Loan_Amount
FROM LoanAccounts
WHERE Loan_Status IS NOT NULL 
  AND Loan_Status != '' 
  AND Loan_Status NOT IN ('No Data', 'NA', 'Unknown')
GROUP BY Loan_Status
HAVING SUM(Loan_Amount) > 100000;

---------------------------------------------------------------------------------------------------------------------------------------------
-- 16. Age Group-Wise Loan
 
 SELECT 
    CASE 
        WHEN Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Age BETWEEN 36 AND 45 THEN '36-45'
        ELSE '46+' 
    END AS Age_Group,
    COUNT(*) AS Loan_Count,
    CONCAT(ROUND(SUM(Loan_Amount) / 1000000, 2), ' M') AS Total_Amount
FROM LoanAccounts
WHERE Age IS NOT NULL AND Age >= 18
GROUP BY Age_Group
HAVING SUM(Loan_Amount) > 100000
ORDER BY Age_Group;

---------------------------------------------------------------------------------------------------------------------------------------------
-- 17.Loan Maturity
 
    SELECT 
    Term,
    COUNT(*) AS Loan_Count,
    CONCAT(ROUND(SUM(Loan_Amount)/1000000, 2), ' M') AS Total_Amount
FROM LoanAccounts
GROUP BY Term;

---------------------------------------------------------------------------------------------------------------------------------------------
-- 18. No Verified Loans

SELECT COUNT(*) AS No_Verified_Loans
FROM LoanAccounts
WHERE Verification_Status IS NULL 
   OR Verification_Status IN ('', 'No Data', 'NA', 'N/A', 'Unknown');
   
----------------------------------------------------------------------------------------------------------------------------------------------  
-- 19. Loan Amount by Gender:
SELECT 
    Gender_ID,
    COUNT(*) AS Loan_Count,
    CONCAT(ROUND(SUM(Loan_Amount) / 1000000, 2), ' M') AS Total_Amount
FROM LoanAccounts
GROUP BY Gender_ID;

----------------------------------------------------------------------------------------------------------------------------------------------
-- 20. Top 5 Branches by Total Revenue
SELECT 
    Branch_Name,
    CONCAT(ROUND(SUM(Total_Rrec_Int + Total_Fees) / 1000000, 2), ' M') AS Total_Revenue
FROM LoanAccounts
GROUP BY Branch_Name
HAVING SUM(Total_Rrec_Int + Total_Fees) > 0
ORDER BY SUM(Total_Rrec_Int + Total_Fees) DESC
LIMIT 5;
