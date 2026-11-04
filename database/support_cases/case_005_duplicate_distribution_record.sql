USE PrivateCapitalDB;
GO

/*
Support Case 005
Title: Duplicate Distribution Record

Goal:
Identify duplicate distribution records, investigate the affected
payments, remove the duplicate simulated record, and validate
that no duplicates remain.
*/

-- Step 1: Detect duplicate distributions
SELECT
    F.fund_name,
    I.investor_name,
    D.distribution_type,
    D.distribution_date,
    D.distribution_amount,
    COUNT(*) AS duplicate_count
FROM dbo.Distributions D
JOIN dbo.Funds F
    ON F.fund_id = D.fund_id
JOIN dbo.Investors I
    ON I.investor_id = D.investor_id
GROUP BY
    F.fund_name,
    I.investor_name,
    D.distribution_type,
    D.distribution_date,
    D.distribution_amount
HAVING COUNT(*) > 1;

-- Step 2: Inspect the duplicate records
SELECT
    D.distribution_id,
    F.fund_name,
    I.investor_name,
    D.distribution_type,
    D.distribution_date,
    D.distribution_amount
FROM dbo.Distributions D
JOIN dbo.Funds F
    ON F.fund_id = D.fund_id
JOIN dbo.Investors I
    ON I.investor_id = D.investor_id
WHERE D.fund_id = 1
  AND D.investor_id = 1
  AND D.distribution_date = '2026-02-15'
  AND D.distribution_amount = 750000.00
  AND D.distribution_type = 'Investment Proceeds';

-- Step 3: Remove the duplicate simulated record
DELETE FROM dbo.Distributions
WHERE distribution_id = 1002;

-- Step 4: Validate that no duplicate distributions remain
SELECT
    F.fund_name,
    I.investor_name,
    D.distribution_type,
    D.distribution_date,
    D.distribution_amount,
    COUNT(*) AS duplicate_count
FROM dbo.Distributions D
JOIN dbo.Funds F
    ON F.fund_id = D.fund_id
JOIN dbo.Investors I
    ON I.investor_id = D.investor_id
GROUP BY
    F.fund_name,
    I.investor_name,
    D.distribution_type,
    D.distribution_date,
    D.distribution_amount
HAVING COUNT(*) > 1;