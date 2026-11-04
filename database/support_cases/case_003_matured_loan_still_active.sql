USE PrivateCapitalDB;
GO

/*
Support Case 003
Title: Matured Loan Still Marked Active

Goal:
Identify loans that are still marked Active even though their
maturity date has already passed, correct the stale status,
and validate that no mismatches remain.
*/

-- Step 1: Identify active loans with a past maturity date
SELECT
    L.loan_id,
    C.company_name,
    F.fund_name,
    F.strategy,
    L.principal_amount,
    L.interest_rate,
    L.start_date,
    L.maturity_date,
    L.loan_status
FROM dbo.Loans L
JOIN dbo.Funds F
    ON L.fund_id = F.fund_id
JOIN dbo.Companies C
    ON L.company_id = C.company_id
WHERE L.loan_status = 'Active'
  AND L.maturity_date < CAST(GETDATE() AS DATE);

-- Step 2: Correct the affected loan
UPDATE dbo.Loans
SET loan_status = 'Matured'
WHERE loan_id = 1002;

-- Step 3: Validate the updated record
SELECT
    loan_id,
    loan_status,
    maturity_date
FROM dbo.Loans
WHERE loan_id = 1002;

-- Step 4: Confirm no matured loans remain marked Active
SELECT
    L.loan_id,
    C.company_name,
    F.fund_name,
    F.strategy,
    L.loan_status,
    L.maturity_date
FROM dbo.Loans L
JOIN dbo.Funds F
    ON L.fund_id = F.fund_id
JOIN dbo.Companies C
    ON L.company_id = C.company_id
WHERE L.loan_status = 'Active'
  AND L.maturity_date < CAST(GETDATE() AS DATE);