# Private Capital Support Platform

An in-progress application support project designed to simulate how a private capital firm might track funds, investors, portfolio activity, loans, capital calls, and distributions.

The project is being built with a focus on SQL troubleshooting, root-cause analysis, data validation, and application support workflows, with planned expansion into ETL, REST APIs, Linux, logging, reporting, and AI-assisted support.

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
- 16 loans
- 40 capital calls
- 30 distributions

## SQL Support Cases

The project includes six database support scenarios involving investigation, root-cause analysis, remediation, and validation.

Several cases use intentionally introduced data-quality issues to simulate production support incidents in a controlled environment.

### Case 001 — Overdue Outstanding Capital Calls

Investigated capital calls that remained `Outstanding` after their due dates.

Key steps included:

- Identifying overdue capital calls
- Joining fund and investor data
- Comparing `amount_called` against investor `commitment_amount`
- Aggregating cumulative capital calls using `SUM()`
- Verifying that no investor had been called beyond their commitment

**Result:**

Seven overdue outstanding capital calls were identified. No over-calling was found. Independent payment verification was not possible with the current schema, so the case was documented for external verification or escalation.

### Case 002 — Loan Assigned to Wrong Fund Strategy

Investigated loans associated with funds whose strategy was not `Private Credit`.

A loan was found assigned to `Nova Growth Fund I`, which uses a `Private Equity` strategy.

The loan was reassigned to the appropriate Private Credit fund.

**Result:**

Resolved and validated with zero remaining strategy mismatches.

### Case 003 — Matured Loan Still Marked Active

Investigated a loan whose maturity date had passed while its status remained `Active`.

Key steps included:

- Identifying active loans with past maturity dates
- Joining loan, fund, and company data
- Verifying the loan belonged to a valid Private Credit fund
- Identifying the stale `loan_status`
- Updating the affected loan from `Active` to `Matured`

**Result:**

Resolved and validated. The final query returned zero active loans with past maturity dates.

### Case 004 — Capital Call / Commitment Data Mismatch

Investigated a capital call associated with an investor who did not have a recorded commitment to the specified fund.

Key steps included:

- Using a `LEFT JOIN` to detect capital calls without matching `FundInvestors` relationships
- Matching both `fund_id` and `investor_id`
- Reviewing the investor's valid fund commitments
- Determining that the database did not contain enough information to safely infer the intended fund
- Removing the known invalid simulated capital call instead of guessing a replacement value

**Result:**

Resolved and validated with zero capital calls lacking valid fund-investor relationships.

### Case 005 — Duplicate Distribution Record

Investigated a duplicate investor distribution.

Key steps included:

- Grouping distributions by fund, investor, type, date, and amount
- Using `COUNT(*)` and `HAVING COUNT(*) > 1` to identify duplicates
- Inspecting the individual distribution records
- Preserving the original record and deleting only the simulated duplicate

**Result:**

Resolved and validated with zero remaining duplicate distribution groups.

### Case 006 — Fund Commitment Reconciliation Mismatch

Investigated differences between fund-level committed capital and the sum of individual investor commitments.

Key steps included:

- Aggregating `FundInvestors.commitment_amount` by fund
- Comparing aggregated investor commitments against `Funds.committed_capital`
- Calculating reconciliation differences
- Identifying mismatches across all five funds
- Updating fund-level totals using the detailed investor commitment records as the source of truth

**Result:**

Resolved and validated with zero remaining commitment reconciliation mismatches.

## Current Project Status

- Core SQL Server schema complete
- Sample data population complete
- Six SQL support cases completed
- SQL troubleshooting and data-quality phase complete
- Project documentation maintained in GitHub
- Preparing to expand into additional application-support technologies

## Planned Development

The next stages of the project include:

- ETL / SSIS concepts and troubleshooting
- Python + FastAPI REST API
- Postman API testing
- Ubuntu / WSL2 Linux environment
- Application logging
- API, Linux, and integration support incidents
- Incident troubleshooting and root-cause analysis
- SSRS / Power BI reporting
- AI-assisted support chatbot
- Azure / Azure DevOps integration

## Project Goal

The goal is to build a realistic application support environment for private capital systems and practice troubleshooting across multiple layers, including SQL, ETL, APIs, Linux, logs, reporting, integrations, and AI-assisted support workflows.
