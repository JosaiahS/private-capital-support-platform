USE PrivateCapitalDB;
GO

/* 
Support Case 001
Title: Overdue Outstanding Capital Calls

Goal:
Identify overdue capital calls, confirm the affected fund/investor,
and verify that total capital called does not exceed commitment amount.
*/


-- Step 1: Find overdue outstanding capital calls
SELECT 
    cc.capital_call_id,
    f.fund_name,
    i.investor_name,
    cc.amount_called,
    cc.due_date,
    cc.call_status
FROM dbo.CapitalCalls cc
JOIN dbo.Funds f
    ON cc.fund_id = f.fund_id
JOIN dbo.Investors i
    ON cc.investor_id = i.investor_id
WHERE cc.call_status = 'Outstanding'
  AND cc.due_date < CAST(GETDATE() AS DATE);


-- Step 2: Compare each overdue call to the investor's commitment
SELECT 
    cc.capital_call_id,
    f.fund_name,
    i.investor_name,
    fi.commitment_amount,
    cc.amount_called,
    cc.due_date,
    cc.call_status
FROM dbo.CapitalCalls cc
JOIN dbo.Funds f
    ON cc.fund_id = f.fund_id
JOIN dbo.Investors i
    ON cc.investor_id = i.investor_id
JOIN dbo.FundInvestors fi
    ON cc.fund_id = fi.fund_id
   AND cc.investor_id = fi.investor_id
WHERE cc.call_status = 'Outstanding'
  AND cc.due_date < CAST(GETDATE() AS DATE);


-- Step 3: Calculate cumulative capital called per investor/fund
SELECT
    f.fund_name,
    i.investor_name,
    fi.commitment_amount,
    SUM(cc.amount_called) AS total_amount_called,
    fi.commitment_amount - SUM(cc.amount_called) AS remaining_commitment
FROM dbo.CapitalCalls cc
JOIN dbo.Funds f
    ON cc.fund_id = f.fund_id
JOIN dbo.Investors i
    ON cc.investor_id = i.investor_id
JOIN dbo.FundInvestors fi
    ON cc.fund_id = fi.fund_id
   AND cc.investor_id = fi.investor_id
GROUP BY
    f.fund_name,
    i.investor_name,
    fi.commitment_amount;