USE PrivateCapitalDB;
GO

/*
Support Case 002
Title: Loan Assigned to Wrong Fund Strategy

Goal:
Identify loans associated with funds whose strategy is not Private Credit,
correct the bad fund assignment, and validate the fix.
*/


-- Step 1: Find loans tied to non-Private-Credit funds
SELECT
    l.loan_id,
    f.fund_name,
    f.strategy,
    l.company_id,
    l.principal_amount,
    l.interest_rate,
    l.maturity_date,
    l.loan_status
FROM dbo.Loans l
JOIN dbo.Funds f
    ON l.fund_id = f.fund_id
WHERE f.strategy <> 'Private Credit';


-- Step 2: Correct the known bad record
UPDATE dbo.Loans
SET fund_id = 2
WHERE loan_id = 1;


-- Step 3: Validate that no mismatches remain
SELECT
    l.loan_id,
    f.fund_name,
    f.strategy
FROM dbo.Loans l
JOIN dbo.Funds f
    ON l.fund_id = f.fund_id
WHERE f.strategy <> 'Private Credit';