USE PrivateCapitalDB;
GO

/*
Support Case 004
Title: Capital Call / Commitment Data Mismatch

Goal:
Identify capital calls that do not have a valid matching
fund-investor commitment, investigate the affected relationship,
remove the invalid simulated record, and validate that no
mismatches remain.
*/

-- Step 1: Find capital calls without a matching FundInvestors relationship
SELECT
    C.capital_call_id,
    F.fund_name,
    I.investor_name,
    C.amount_called,
    FI.commitment_amount
FROM dbo.CapitalCalls C
JOIN dbo.Funds F
    ON C.fund_id = F.fund_id
JOIN dbo.Investors I
    ON C.investor_id = I.investor_id
LEFT JOIN dbo.FundInvestors FI
    ON C.fund_id = FI.fund_id
   AND C.investor_id = FI.investor_id
WHERE FI.investor_id IS NULL;

-- Step 2: Review the affected investor's valid fund commitments
SELECT
    F.fund_name,
    F.strategy,
    I.investor_name,
    FI.commitment_amount
FROM dbo.FundInvestors FI
JOIN dbo.Funds F
    ON FI.fund_id = F.fund_id
JOIN dbo.Investors I
    ON FI.investor_id = I.investor_id
WHERE I.investor_name = 'Metro Teachers Pension Fund';

-- Step 3: Review valid capital calls for the affected investor
SELECT
    C.capital_call_id,
    C.amount_called,
    C.call_date,
    C.due_date,
    C.call_status,
    F.fund_name,
    F.strategy,
    I.investor_name,
    FI.commitment_amount
FROM dbo.FundInvestors FI
JOIN dbo.Funds F
    ON FI.fund_id = F.fund_id
JOIN dbo.Investors I
    ON FI.investor_id = I.investor_id
JOIN dbo.CapitalCalls C
    ON C.investor_id = FI.investor_id
   AND C.fund_id = FI.fund_id
WHERE I.investor_name = 'Metro Teachers Pension Fund';

-- Step 4: Remove the invalid simulated capital call
DELETE FROM dbo.CapitalCalls
WHERE capital_call_id = 1002;

-- Step 5: Validate that no invalid capital calls remain
SELECT
    C.capital_call_id,
    F.fund_name,
    I.investor_name,
    C.amount_called,
    FI.commitment_amount
FROM dbo.CapitalCalls C
JOIN dbo.Funds F
    ON C.fund_id = F.fund_id
JOIN dbo.Investors I
    ON C.investor_id = I.investor_id
LEFT JOIN dbo.FundInvestors FI
    ON C.fund_id = FI.fund_id
   AND C.investor_id = FI.investor_id
WHERE FI.investor_id IS NULL;