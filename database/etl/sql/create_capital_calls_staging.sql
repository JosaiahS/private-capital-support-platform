USE PrivateCapitalDB;
GO

/*
Creates the staging table used for incoming capital-call ETL data.

Incoming values are stored as VARCHAR so malformed external data
can still be captured and validated instead of failing immediately.
*/

IF OBJECT_ID('dbo.CapitalCalls_Staging', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.CapitalCalls_Staging
    (
        staging_id INT IDENTITY(1,1) PRIMARY KEY,

        fund_id VARCHAR(50),
        investor_id VARCHAR(50),
        call_date VARCHAR(50),
        due_date VARCHAR(50),
        amount_called VARCHAR(50),
        call_status VARCHAR(50),

        validation_status VARCHAR(20) DEFAULT 'Pending',
        error_message VARCHAR(255),

        imported_at DATETIME2 DEFAULT GETDATE()
    );
END;
GO