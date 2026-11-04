# Private Capital Support Platform

An in-progress application support project designed to simulate how a private capital firm might track funds, investors, portfolio activity, loans, capital calls, and distributions.

The project is being built with a focus on SQL troubleshooting, root-cause analysis, and application support workflows, with planned expansion into REST APIs, Linux, ETL, logging, and AI-assisted support.

## Current Tech Stack

- SQL Server
- SQL Server Management Studio (SSMS)
- T-SQL
- Git / GitHub

## Database Schema

The current database includes:

- `Funds`
- `Investors`
- `FundInvestors`
- `Companies`
- `Investments`
- `Loans`
- `CapitalCalls`
- `Distributions`

The schema uses primary keys, foreign keys, junction tables, and multi-table relationships to model private capital activity.

## Sample Data

The database currently contains realistic sample data across all core tables, including:

- 5 funds
- 16 investors
- 30 fund-investor relationships
- 15 companies
- 20 investments
- 15 loans
- 40 capital calls
- 30 distributions

## Support Cases

### Case 001 — Overdue Outstanding Capital Calls

Investigated capital calls that remained `Outstanding` after their due dates.

Key steps included:

- Identifying overdue capital calls
- Joining fund and investor data
- Comparing `amount_called` against investor `commitment_amount`
- Aggregating total capital called using `SUM()`
- Verifying that no investor had been called beyond their commitment

Result:

The overdue calls were valid records and no over-calling was identified. Independent payment verification was not possible with the current schema, so the case was documented for external verification or escalation.

### Case 002 — Loan Assigned to Wrong Fund Strategy

Investigated loans associated with funds whose strategy was not `Private Credit`.

A loan was found assigned to `Nova Growth Fund I`, which uses a `Private Equity` strategy.

The loan was reassigned to the appropriate Private Credit fund and the validation query returned zero remaining mismatches.

Result:

Resolved and validated.

## Current Project Status

- Core SQL Server schema complete
- Sample data population complete
- SQL troubleshooting phase in progress
- 2 support cases completed

## Planned Development

The next stages of the project include:

- Additional SQL support cases
- ETL / SSIS concepts
- Python + FastAPI REST API
- Postman API testing
- Ubuntu / WSL2 Linux environment
- Application logging
- Incident troubleshooting and RCA
- SSRS / Power BI reporting
- AI-assisted support chatbot
- Azure DevOps integration

## Project Goal

The goal is to build a realistic application support environment for private capital systems and practice troubleshooting across multiple layers, including SQL, APIs, Linux, ETL, logs, and AI-assisted support workflows.
