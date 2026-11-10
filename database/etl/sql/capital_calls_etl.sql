USE PrivateCapitalDB;
GO

/*
Capital Calls ETL

Flow:
1. Raw import table
2. Staging table
3. Validation
4. Mark Valid / Invalid
5. Load valid rows into dbo.CapitalCalls
6. Verify results

This script uses a "first validation failure wins" approach.
Once a row becomes Invalid, later validation rules ignore it.
*/

------------------------------------------------------------
-- STEP 1: Confirm raw import table exists
------------------------------------------------------------

IF OBJECT_ID('dbo.capital_calls_import', 'U') IS NULL
BEGIN
    RAISERROR('Raw import table dbo.capital_calls_import does not exist.', 16, 1);
    RETURN;
END;
GO

------------------------------------------------------------
-- STEP 2: Move raw imported data into staging
------------------------------------------------------------

INSERT INTO dbo.CapitalCalls_Staging
(
    fund_id,
    investor_id,
    call_date,
    due_date,
    amount_called,
    call_status
)
SELECT
    CAST(R.fund_id AS VARCHAR(50)),
    CAST(R.investor_id AS VARCHAR(50)),
    CAST(R.call_date AS VARCHAR(50)),
    CAST(R.due_date AS VARCHAR(50)),
    CAST(R.amount_called AS VARCHAR(50)),
    CAST(R.call_status AS VARCHAR(50))
FROM dbo.capital_calls_import R
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.CapitalCalls_Staging S
    WHERE S.fund_id = CAST(R.fund_id AS VARCHAR(50))
      AND S.investor_id = CAST(R.investor_id AS VARCHAR(50))
      AND S.call_date = CAST(R.call_date AS VARCHAR(50))
      AND S.due_date = CAST(R.due_date AS VARCHAR(50))
      AND S.amount_called = CAST(R.amount_called AS VARCHAR(50))
      AND S.call_status = CAST(R.call_status AS VARCHAR(50))
);

------------------------------------------------------------
-- STEP 3: Validate fund_id
------------------------------------------------------------

UPDATE S
SET
    validation_status = 'Invalid',
    error_message = 'Fund does not exist'
FROM dbo.CapitalCalls_Staging S
LEFT JOIN dbo.Funds F
    ON TRY_CONVERT(INT, S.fund_id) = F.fund_id
WHERE S.validation_status = 'Pending'
  AND F.fund_id IS NULL;

------------------------------------------------------------
-- STEP 4: Validate investor_id
------------------------------------------------------------

UPDATE S
SET
    validation_status = 'Invalid',
    error_message = 'Investor does not exist'
FROM dbo.CapitalCalls_Staging S
LEFT JOIN dbo.Investors I
    ON TRY_CONVERT(INT, S.investor_id) = I.investor_id
WHERE S.validation_status = 'Pending'
  AND I.investor_id IS NULL;

------------------------------------------------------------
-- STEP 5: Validate fund-investor relationship
------------------------------------------------------------

UPDATE S
SET
    validation_status = 'Invalid',
    error_message = 'Investor is not committed to this fund'
FROM dbo.CapitalCalls_Staging S
LEFT JOIN dbo.FundInvestors FI
    ON TRY_CONVERT(INT, S.fund_id) = FI.fund_id
   AND TRY_CONVERT(INT, S.investor_id) = FI.investor_id
WHERE S.validation_status = 'Pending'
  AND FI.investor_id IS NULL;

------------------------------------------------------------
-- STEP 6: Validate amount_called
------------------------------------------------------------

UPDATE dbo.CapitalCalls_Staging
SET
    validation_status = 'Invalid',
    error_message = 'Amount called must be a valid positive number'
WHERE validation_status = 'Pending'
  AND
  (
      TRY_CONVERT(DECIMAL(18,2), amount_called) IS NULL
      OR TRY_CONVERT(DECIMAL(18,2), amount_called) <= 0
  );

------------------------------------------------------------
-- STEP 7: Validate dates
------------------------------------------------------------

UPDATE dbo.CapitalCalls_Staging
SET
    validation_status = 'Invalid',
    error_message = 'Invalid call date or due date'
WHERE validation_status = 'Pending'
  AND
  (
      TRY_CONVERT(DATE, call_date) IS NULL
      OR TRY_CONVERT(DATE, due_date) IS NULL
      OR TRY_CONVERT(DATE, due_date) < TRY_CONVERT(DATE, call_date)
  );

------------------------------------------------------------
-- STEP 8: Validate call_status
------------------------------------------------------------

UPDATE dbo.CapitalCalls_Staging
SET
    validation_status = 'Invalid',
    error_message = 'Invalid call status'
WHERE validation_status = 'Pending'
  AND
  (
      call_status IS NULL
      OR LTRIM(RTRIM(call_status)) NOT IN ('Outstanding', 'Paid')
  );

------------------------------------------------------------
-- STEP 9: Mark remaining rows Valid
------------------------------------------------------------

UPDATE dbo.CapitalCalls_Staging
SET validation_status = 'Valid'
WHERE validation_status = 'Pending';

------------------------------------------------------------
-- STEP 10: Load valid rows into CapitalCalls
------------------------------------------------------------

INSERT INTO dbo.CapitalCalls
(
    fund_id,
    investor_id,
    call_date,
    due_date,
    amount_called,
    call_status
)
SELECT
    TRY_CONVERT(INT, S.fund_id),
    TRY_CONVERT(INT, S.investor_id),
    TRY_CONVERT(DATE, S.call_date),
    TRY_CONVERT(DATE, S.due_date),
    TRY_CONVERT(DECIMAL(18,2), S.amount_called),
    LTRIM(RTRIM(S.call_status))
FROM dbo.CapitalCalls_Staging S
WHERE S.validation_status = 'Valid'
  AND NOT EXISTS
  (
      SELECT 1
      FROM dbo.CapitalCalls C
      WHERE C.fund_id = TRY_CONVERT(INT, S.fund_id)
        AND C.investor_id = TRY_CONVERT(INT, S.investor_id)
        AND C.call_date = TRY_CONVERT(DATE, S.call_date)
        AND C.due_date = TRY_CONVERT(DATE, S.due_date)
        AND C.amount_called = TRY_CONVERT(DECIMAL(18,2), S.amount_called)
        AND C.call_status = LTRIM(RTRIM(S.call_status))
  );

------------------------------------------------------------
-- STEP 11: Review ETL results
------------------------------------------------------------

SELECT
    staging_id,
    fund_id,
    investor_id,
    call_date,
    due_date,
    amount_called,
    call_status,
    validation_status,
    error_message,
    imported_at
FROM dbo.CapitalCalls_Staging
ORDER BY staging_id;

------------------------------------------------------------
-- STEP 12: Summary
------------------------------------------------------------

SELECT
    validation_status,
    COUNT(*) AS record_count
FROM dbo.CapitalCalls_Staging
GROUP BY validation_status;
GO