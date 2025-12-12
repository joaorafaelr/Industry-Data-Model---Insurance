USE InsuranceData;
GO

/* ============================
   BANK & CASH ACCOUNTS
   ============================ */

-- Bank account reference
IF OBJECT_ID('fct.fct_tsy_bank_account_ref','U') IS NULL
CREATE TABLE fct.fct_tsy_bank_account_ref (
  bank_account_id   UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_fct_tsy_bank_account_ref PRIMARY KEY
      CONSTRAINT DF_fct_tsy_bank_account_ref_id DEFAULT NEWID(),
  iban              NVARCHAR(34)     NULL,      -- may arrive later / missing for some banks
  bank_code         NVARCHAR(20)     NULL,
  branch_code       NVARCHAR(20)     NULL,
  account_number    NVARCHAR(40)     NULL,
  account_name      NVARCHAR(200)    NULL,
  currency_code     CHAR(3)          NULL,      -- ISO 4217 (check in Part 2)
  opened_on         DATE             NULL,
  closed_on         DATE             NULL,
  is_active         BIT              NOT NULL CONSTRAINT DF_fct_tsy_bank_account_active DEFAULT(1),
  created_at        DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_tsy_bank_account_created DEFAULT SYSUTCDATETIME(),
  description       NVARCHAR(500)    NULL
);
GO

-- Internal cash account reference (maps optionally to a bank account)
IF OBJECT_ID('fct.fct_tsy_cash_account_ref','U') IS NULL
CREATE TABLE fct.fct_tsy_cash_account_ref (
  cash_account_id   UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_fct_tsy_cash_account_ref PRIMARY KEY
      CONSTRAINT DF_fct_tsy_cash_account_ref_id DEFAULT NEWID(),
  cash_account_code NVARCHAR(60)     NOT NULL,
  cash_account_name NVARCHAR(200)    NOT NULL,
  bank_account_id   UNIQUEIDENTIFIER NULL,      -- FK in Part 2
  currency_code     CHAR(3)          NULL,      -- ISO check in Part 2
  opened_on         DATE             NULL,
  closed_on         DATE             NULL,
  is_active         BIT              NOT NULL CONSTRAINT DF_fct_tsy_cash_account_active DEFAULT(1),
  created_at        DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_tsy_cash_account_created DEFAULT SYSUTCDATETIME(),
  description       NVARCHAR(500)    NULL
);
GO

/* ============================
   CASH POOLS
   ============================ */

IF OBJECT_ID('fct.fct_tsy_cash_pool_ref','U') IS NULL
CREATE TABLE fct.fct_tsy_cash_pool_ref (
  cash_pool_id   UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_fct_tsy_cash_pool_ref PRIMARY KEY
      CONSTRAINT DF_fct_tsy_cash_pool_ref_id DEFAULT NEWID(),
  pool_code      NVARCHAR(60)     NOT NULL,   -- UQ in Part 2
  pool_name      NVARCHAR(200)    NOT NULL,
  currency_code  CHAR(3)          NULL,
  created_at     DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_tsy_cash_pool_created DEFAULT SYSUTCDATETIME(),
  description    NVARCHAR(500)    NULL
);
GO

IF OBJECT_ID('fct.fct_tsy_cash_pool_membership','U') IS NULL
CREATE TABLE fct.fct_tsy_cash_pool_membership (
  pool_membership_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_fct_tsy_cash_pool_membership PRIMARY KEY
      CONSTRAINT DF_fct_tsy_cash_pool_membership_id DEFAULT NEWID(),
  cash_pool_id       UNIQUEIDENTIFIER NOT NULL,  -- FK in Part 2
  cash_account_id    UNIQUEIDENTIFIER NOT NULL,  -- FK in Part 2
  effective_from     DATE             NOT NULL,
  effective_to       DATE             NULL,
  created_at         DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_tsy_pool_memb_created DEFAULT SYSUTCDATETIME()
);
GO

/* ============================
   BANK STATEMENTS & MOVEMENTS
   ============================ */

-- Imported statements (raw landing)
IF OBJECT_ID('fct.fct_tsy_statement_import','U') IS NULL
CREATE TABLE fct.fct_tsy_statement_import (
  statement_id     UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_fct_tsy_statement_import PRIMARY KEY
      CONSTRAINT DF_fct_tsy_statement_import_id DEFAULT NEWID(),
  bank_account_id  UNIQUEIDENTIFIER NOT NULL,  -- FK in Part 2
  statement_date   DATE             NOT NULL,
  source_uri       NVARCHAR(1000)   NULL,      -- file path / object storage URI
  source_sha256    VARBINARY(32)    NULL,      -- file hash (de-dup in Part 2)
  imported_at      DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_tsy_stmt_imported DEFAULT SYSUTCDATETIME(),
  raw_payload_json NVARCHAR(MAX)    NULL       -- ISJSON in Part 2
);
GO

-- Normalized bank movements
IF OBJECT_ID('fct.fct_tsy_bank_movement','U') IS NULL
CREATE TABLE fct.fct_tsy_bank_movement (
  movement_id        UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_fct_tsy_bank_movement PRIMARY KEY
      CONSTRAINT DF_fct_tsy_bank_movement_id DEFAULT NEWID(),
  bank_account_id    UNIQUEIDENTIFIER NOT NULL,  -- FK in Part 2
  statement_id       UNIQUEIDENTIFIER NULL,      -- FK in Part 2
  movement_code      NVARCHAR(120)    NULL,      -- UQ when present (Part 2)
  booking_date       DATE             NULL,
  value_date         DATE             NULL,
  amount             DECIMAL(19,4)    NOT NULL,
  currency_code      CHAR(3)          NULL,
  direction_code     NVARCHAR(10)     NULL,      -- CREDIT / DEBIT (no sign semantics enforced)
  balance_after      DECIMAL(19,4)    NULL,
  counterparty_name  NVARCHAR(200)    NULL,
  counterparty_acct  NVARCHAR(60)     NULL,
  description        NVARCHAR(500)    NULL,
  external_ref       NVARCHAR(200)    NULL,
  created_at         DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_tsy_bmov_created DEFAULT SYSUTCDATETIME()
);
GO

-- Reconciliation links (movement → business object)
IF OBJECT_ID('fct.fct_tsy_recon_match','U') IS NULL
CREATE TABLE fct.fct_tsy_recon_match (
  match_id            UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_fct_tsy_recon_match PRIMARY KEY
      CONSTRAINT DF_fct_tsy_recon_match_id DEFAULT NEWID(),
  movement_id         UNIQUEIDENTIFIER NOT NULL,     -- FK in Part 2
  business_object_type NVARCHAR(40)    NOT NULL,     -- POLICY / CLAIM / AR_INVOICE / AP_PAYMENT ...
  business_object_id  NVARCHAR(120)    NOT NULL,
  match_status_code   NVARCHAR(30)     NOT NULL,     -- MATCHED / PARTIAL / CANDIDATE / REJECTED
  matched_amount      DECIMAL(19,4)    NULL,
  created_at          DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_tsy_recon_created DEFAULT SYSUTCDATETIME(),
  notes               NVARCHAR(500)    NULL
);
GO

/* ============================
   INVESTMENTS
   ============================ */

IF OBJECT_ID('fct.fct_tsy_investment_instrument_ref','U') IS NULL
CREATE TABLE fct.fct_tsy_investment_instrument_ref (
  instrument_id     UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_fct_tsy_investment_instrument_ref PRIMARY KEY
      CONSTRAINT DF_fct_tsy_investment_instrument_ref_id DEFAULT NEWID(),
  isin              NVARCHAR(12)     NULL,     -- UQ & shape in Part 2
  instrument_code   NVARCHAR(60)     NULL,     -- optional house key
  instrument_name   NVARCHAR(200)    NULL,
  instrument_type_code NVARCHAR(40)  NULL,     -- BOND / EQUITY / FUND / MM / OTHER
  currency_code     CHAR(3)          NULL,
  issuer_entity_id  UNIQUEIDENTIFIER NULL,     -- FK to core.entity (optional) in Part 2
  issue_date        DATE             NULL,
  maturity_date     DATE             NULL,
  coupon_rate_pct   DECIMAL(9,6)     NULL,
  created_at        DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_tsy_instr_created DEFAULT SYSUTCDATETIME()
);
GO

IF OBJECT_ID('fct.fct_tsy_investment_position','U') IS NULL
CREATE TABLE fct.fct_tsy_investment_position (
  position_id          UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_fct_tsy_investment_position PRIMARY KEY
      CONSTRAINT DF_fct_tsy_investment_position_id DEFAULT NEWID(),
  as_of_date           DATE             NOT NULL,
  instrument_id        UNIQUEIDENTIFIER NOT NULL,  -- FK in Part 2
  quantity             DECIMAL(19,6)    NOT NULL,
  price_amount         DECIMAL(19,6)    NULL,      -- price in currency_code
  market_value_amount  DECIMAL(19,4)    NULL,      -- quantity * price (or provided)
  currency_code        CHAR(3)          NULL,
  custody_account_code NVARCHAR(60)     NULL,      -- optional sub-grain (see Part 2 note)
  created_at           DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_tsy_invpos_created DEFAULT SYSUTCDATETIME()
);
GO

/* ============================
   FORECAST CASHFLOWS
   ============================ */

IF OBJECT_ID('fct.fct_tsy_forecast_cashflow','U') IS NULL
CREATE TABLE fct.fct_tsy_forecast_cashflow (
  forecast_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_fct_tsy_forecast_cashflow PRIMARY KEY
      CONSTRAINT DF_fct_tsy_forecast_cashflow_id DEFAULT NEWID(),
  cash_account_id  UNIQUEIDENTIFIER NULL,     -- FK in Part 2
  instrument_id    UNIQUEIDENTIFIER NULL,     -- FK in Part 2
  due_date         DATE             NOT NULL,
  amount           DECIMAL(19,4)    NOT NULL,
  currency_code    CHAR(3)          NULL,
  cashflow_type_code NVARCHAR(40)   NULL,     -- INTEREST / REDEMPTION / DIVIDEND / FEE / OTHER
  source_code      NVARCHAR(40)     NULL,     -- SOURCE_SYSTEM / MODEL / MANUAL
  created_at       DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_tsy_fc_created DEFAULT SYSUTCDATETIME(),
  details_json     NVARCHAR(MAX)    NULL
);
GO

/* ============================
   DEBT (CORPORATE / BANK)
   ============================ */

IF OBJECT_ID('fct.fct_tsy_debt_instrument_ref','U') IS NULL
CREATE TABLE fct.fct_tsy_debt_instrument_ref (
  debt_id            UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_fct_tsy_debt_instrument_ref PRIMARY KEY
      CONSTRAINT DF_fct_tsy_debt_instrument_ref_id DEFAULT NEWID(),
  debt_code          NVARCHAR(60)     NOT NULL,  -- house identifier (UQ in Part 2)
  title              NVARCHAR(200)    NULL,
  borrower_entity_id UNIQUEIDENTIFIER NULL,      -- FK to core.entity (recommended)
  lender_entity_id   UNIQUEIDENTIFIER NULL,      -- FK to core.entity
  currency_code      CHAR(3)          NULL,
  notional_amount    DECIMAL(19,4)    NOT NULL,
  interest_basis_code NVARCHAR(40)    NULL,      -- FIXED / FLOATING / ZERO
  spread_bps         INT              NULL,      -- for floating
  issue_date         DATE             NULL,
  maturity_date      DATE             NULL,
  created_at         DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_tsy_debt_created DEFAULT SYSUTCDATETIME(),
  description        NVARCHAR(500)    NULL
);
GO

IF OBJECT_ID('fct.fct_tsy_debt_cashflow_schedule','U') IS NULL
CREATE TABLE fct.fct_tsy_debt_cashflow_schedule (
  schedule_id     UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_fct_tsy_debt_cashflow_schedule PRIMARY KEY
      CONSTRAINT DF_fct_tsy_debt_cashflow_schedule_id DEFAULT NEWID(),
  debt_id         UNIQUEIDENTIFIER NOT NULL,  -- FK in Part 2
  due_date        DATE             NOT NULL,
  cashflow_type_code NVARCHAR(40)  NOT NULL,  -- INTEREST / REDEMPTION / FEE
  amount          DECIMAL(19,4)    NOT NULL,
  currency_code   CHAR(3)          NULL,
  created_at      DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_tsy_debt_cf_created DEFAULT SYSUTCDATETIME()
);
GO

/* ============================
   LIQUIDITY BUCKETING (OPTIONAL)
   ============================ */

IF OBJECT_ID('fct.fct_tsy_liquidity_bucket_ref','U') IS NULL
CREATE TABLE fct.fct_tsy_liquidity_bucket_ref (
  bucket_code   NVARCHAR(30)  NOT NULL CONSTRAINT PK_fct_tsy_liquidity_bucket_ref PRIMARY KEY,
  bucket_name   NVARCHAR(200) NOT NULL,
  sort_order    INT           NULL,
  description   NVARCHAR(500) NULL
);
GO

IF OBJECT_ID('fct.fct_tsy_liquidity_position','U') IS NULL
CREATE TABLE fct.fct_tsy_liquidity_position (
  liquidity_pos_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_fct_tsy_liquidity_position PRIMARY KEY
      CONSTRAINT DF_fct_tsy_liquidity_position_id DEFAULT NEWID(),
  as_of_date       DATE             NOT NULL,
  currency_code    CHAR(3)          NULL,
  bucket_code      NVARCHAR(30)     NOT NULL,     -- FK in Part 2
  amount           DECIMAL(19,4)    NOT NULL,
  source_code      NVARCHAR(40)     NULL,         -- MODEL / REPORTING / MANUAL
  created_at       DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_tsy_liqpos_created DEFAULT SYSUTCDATETIME()
);
GO
