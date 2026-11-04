USE PrivateCapitalDB;
GO

/*
Support Case 006
Title: Fund Commitment Reconciliation Mismatch

Goal:
Compare the fund-level committed capital against the sum of
individual investor commitments, correct mismatches, and
validate that all fund totals reconcile.
*/

-- Step 1: Compare fund-level committed capital to investor commitments
SELECT
    F.fund_name,
    F.committed_capital,
    SUM(FI.commitment_amount) AS total_investor_commitments,
    F.committed_capital - SUM(FI.commitment_amount) AS commitment_difference
FROM dbo.Funds F
JOIN dbo.FundInvestors FI
    ON F.fund_id = FI.fund_id
GROUP BY
    F.fund_name,
    F.committed_capital;

-- Step 2: Show only funds with reconciliation mismatches
SELECT
    F.fund_id,
    F.fund_name,
    F.committed_capital,
    SUM(FI.commitment_amount) AS total_investor_commitments,
    F.committed_capital - SUM(FI.commitment_amount) AS commitment_difference
FROM dbo.Funds F
JOIN dbo.FundInvestors FI
    ON F.fund_id = FI.fund_id
GROUP BY
    F.fund_id,
    F.fund_name,
    F.committed_capital
HAVING F.committed_capital <> SUM(FI.commitment_amount);

-- Step 3: Update fund-level committed capital
-- FundInvestors is treated as the detailed source of truth
UPDATE F
SET F.committed_capital = X.total_commitments
FROM dbo.Funds F
JOIN (
    SELECT
        fund_id,
        SUM(commitment_amount) AS total_commitments
    FROM dbo.FundInvestors
    GROUP BY fund_id
) X
    ON F.fund_id = X.fund_id;

-- Step 4: Validate that no reconciliation mismatches remain
SELECT
    F.fund_id,
    F.fund_name,
    F.committed_capital,
    SUM(FI.commitment_amount) AS total_investor_commitments,
    F.committed_capital - SUM(FI.commitment_amount) AS commitment_difference
FROM dbo.Funds F
JOIN dbo.FundInvestors FI
    ON F.fund_id = FI.fund_id
GROUP BY
    F.fund_id,
    F.fund_name,
    F.committed_capital
HAVING F.committed_capital <> SUM(FI.commitment_amount);