USE InsuranceData;
GO

/* ============================================================
   Finance, Capital & Treasury → Accounting
   PART 1 — TABLES (PKs, DEFAULTs, basic hygiene) — NO FKs
   ============================================================ */

/* 1) Ledger catalog */
IF OBJECT_ID('fct.fct_ref_ledger','U') IS NULL
CREATE TABLE fct.fct_ref_ledger (
  ledger_id          UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_fct_ref_ledger PRIMARY KEY,
  ledger_code        NVARCHAR(60)     NOT NULL,
  ledger_name        NVARCHAR(200)    NOT NULL,
  base_currency_code CHAR(3)          NULL,    -- ISO 4217
  status_code        NVARCHAR(30)     NOT NULL, -- ACTIVE/INACTIVE
  created_at         DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_ledger_created DEFAULT SYSUTCDATETIME(),
  description        NVARCHAR(500)    NULL
);
GO

/* 2) Accounting periods (per ledger) */
IF OBJECT_ID('fct.fct_accounting_period','U') IS NULL
CREATE TABLE fct.fct_accounting_period (
  period_id     UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_fct_accounting_period PRIMARY KEY,
  ledger_id     UNIQUEIDENTIFIER NOT NULL,  -- FK in Part 2
  period_key    NVARCHAR(20)     NOT NULL,  -- e.g., 2025M12
  start_date    DATE             NOT NULL,
  end_date      DATE             NOT NULL,
  status_code   NVARCHAR(30)     NOT NULL,  -- OPEN/CLOSED/LOCKED
  fiscal_year   INT              NULL,
  fiscal_quarter TINYINT         NULL,
  created_at    DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_period_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT CK_fct_period_dates CHECK (end_date >= start_date)
);
GO

/* 3) Chart of Accounts */
IF OBJECT_ID('fct.fct_ref_account','U') IS NULL
CREATE TABLE fct.fct_ref_account (
  account_id        UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_fct_ref_account PRIMARY KEY,
  account_code      NVARCHAR(60)     NOT NULL,
  account_name      NVARCHAR(200)    NOT NULL,
  is_postable       BIT              NOT NULL,
  parent_account_id UNIQUEIDENTIFIER NULL,   -- self-FK in Part 2
  normal_balance    CHAR(1)          NOT NULL, -- 'D' or 'C'
  created_at        DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_account_created DEFAULT SYSUTCDATETIME()
);
GO

/* 4) Dimensions (generic analytic axes) */
IF OBJECT_ID('fct.fct_ref_dimension','U') IS NULL
CREATE TABLE fct.fct_ref_dimension (
  dimension_id   UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_fct_ref_dimension PRIMARY KEY,
  dimension_code NVARCHAR(60)     NOT NULL,
  dimension_name NVARCHAR(200)    NOT NULL,
  description    NVARCHAR(500)    NULL,
  created_at     DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_dim_created DEFAULT SYSUTCDATETIME()
);
GO

/* 5) Dimension values */
IF OBJECT_ID('fct.fct_ref_dimension_value','U') IS NULL
CREATE TABLE fct.fct_ref_dimension_value (
  dim_value_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_fct_ref_dimension_value PRIMARY KEY,
  dimension_id UNIQUEIDENTIFIER NOT NULL,  -- FK in Part 2
  value_code   NVARCHAR(120)    NOT NULL,
  value_name   NVARCHAR(200)    NOT NULL,
  is_active    BIT              NOT NULL,
  created_at   DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_dimv_created DEFAULT SYSUTCDATETIME()
);
GO

/* 6) Journal header */
IF OBJECT_ID('fct.fct_journal','U') IS NULL
CREATE TABLE fct.fct_journal (
  journal_id     UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_fct_journal PRIMARY KEY,
  ledger_id      UNIQUEIDENTIFIER NOT NULL,  -- FK in Part 2
  period_id      UNIQUEIDENTIFIER NOT NULL,  -- FK + composite ledger check in Part 2
  journal_number NVARCHAR(60)     NOT NULL,  -- unique per (ledger, period)
  journal_date   DATE             NOT NULL,
  description    NVARCHAR(500)    NULL,
  source_system  NVARCHAR(60)     NULL,
  status_code    NVARCHAR(30)     NOT NULL,  -- DRAFT/POSTED/VOID
  created_at     DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_jrn_created DEFAULT SYSUTCDATETIME()
);
GO

/* 7) Journal lines (dimension pairs) */
IF OBJECT_ID('fct.fct_journal_line','U') IS NULL
CREATE TABLE fct.fct_journal_line (
  journal_id          UNIQUEIDENTIFIER NOT NULL,
  line_no             INT              NOT NULL,
  account_id          UNIQUEIDENTIFIER NOT NULL,   -- FK in Part 2
  debit_credit_flag   CHAR(1)          NOT NULL,   -- 'D'/'C'
  amount              DECIMAL(19,4)    NOT NULL,   -- sign via DC
  currency_code       CHAR(3)          NULL,       -- ISO
  exchange_rate       DECIMAL(19,10)   NULL,       -- >0 if amount_base set
  amount_base         DECIMAL(19,4)    NULL,
  description         NVARCHAR(500)    NULL,
  -- Five dimension pairs (discipline in Part 2)
  dim1_dimension_id   UNIQUEIDENTIFIER NULL,
  dim1_value_id       UNIQUEIDENTIFIER NULL,
  dim2_dimension_id   UNIQUEIDENTIFIER NULL,
  dim2_value_id       UNIQUEIDENTIFIER NULL,
  dim3_dimension_id   UNIQUEIDENTIFIER NULL,
  dim3_value_id       UNIQUEIDENTIFIER NULL,
  dim4_dimension_id   UNIQUEIDENTIFIER NULL,
  dim4_value_id       UNIQUEIDENTIFIER NULL,
  dim5_dimension_id   UNIQUEIDENTIFIER NULL,
  dim5_value_id       UNIQUEIDENTIFIER NULL,
  created_at          DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_jrnl_line_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_fct_journal_line PRIMARY KEY (journal_id, line_no),
  CONSTRAINT CK_fct_jrnl_dc CHECK (debit_credit_flag IN ('D','C'))
);
GO

/* 8) Event → Accounting mappings (header) */
IF OBJECT_ID('fct.fct_event_mapping_rule','U') IS NULL
CREATE TABLE fct.fct_event_mapping_rule (
  mapping_rule_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_fct_event_mapping_rule PRIMARY KEY,
  rule_code       NVARCHAR(60)     NOT NULL,
  rule_name       NVARCHAR(200)    NOT NULL,
  priority_no     INT              NOT NULL,
  status_code     NVARCHAR(30)     NOT NULL, -- ACTIVE/INACTIVE
  created_at      DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_maprule_created DEFAULT SYSUTCDATETIME()
);
GO

/* 9) Event mapping entries (dimension pairs) */
IF OBJECT_ID('fct.fct_event_mapping_entry','U') IS NULL
CREATE TABLE fct.fct_event_mapping_entry (
  entry_id           UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_fct_event_mapping_entry PRIMARY KEY,
  mapping_rule_id    UNIQUEIDENTIFIER NOT NULL,  -- FK in Part 2
  line_no            INT              NOT NULL,  -- unique per rule
  account_id         UNIQUEIDENTIFIER NOT NULL,  -- FK in Part 2
  debit_credit_flag  CHAR(1)          NOT NULL,  -- 'D'/'C'
  amount_expr        NVARCHAR(200)    NULL,      -- named amount selector
  currency_code      CHAR(3)          NULL,
  dim1_dimension_id  UNIQUEIDENTIFIER NULL,
  dim1_value_id      UNIQUEIDENTIFIER NULL,
  dim2_dimension_id  UNIQUEIDENTIFIER NULL,
  dim2_value_id      UNIQUEIDENTIFIER NULL,
  dim3_dimension_id  UNIQUEIDENTIFIER NULL,
  dim3_value_id      UNIQUEIDENTIFIER NULL,
  dim4_dimension_id  UNIQUEIDENTIFIER NULL,
  dim4_value_id      UNIQUEIDENTIFIER NULL,
  dim5_dimension_id  UNIQUEIDENTIFIER NULL,
  dim5_value_id      UNIQUEIDENTIFIER NULL,
  created_at         DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_mape_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT CK_fct_mape_dc CHECK (debit_credit_flag IN ('D','C'))
);
GO

/* 10) GL balances (per currency) + dimension pairs */
IF OBJECT_ID('fct.fct_gl_balance','U') IS NULL
CREATE TABLE fct.fct_gl_balance (
  balance_id        UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_fct_gl_balance PRIMARY KEY,
  ledger_id         UNIQUEIDENTIFIER NOT NULL,  -- FK in Part 2
  period_id         UNIQUEIDENTIFIER NOT NULL,  -- FK + composite ledger check in Part 2
  account_id        UNIQUEIDENTIFIER NOT NULL,  -- FK in Part 2
  currency_code     CHAR(3)          NOT NULL,  -- part of natural key
  opening_balance   DECIMAL(19,4)    NOT NULL DEFAULT(0),
  debit_amount      DECIMAL(19,4)    NOT NULL DEFAULT(0),
  credit_amount     DECIMAL(19,4)    NOT NULL DEFAULT(0),
  closing_balance   DECIMAL(19,4)    NOT NULL DEFAULT(0),
  dim1_dimension_id UNIQUEIDENTIFIER NULL,
  dim1_value_id     UNIQUEIDENTIFIER NULL,
  dim2_dimension_id UNIQUEIDENTIFIER NULL,
  dim2_value_id     UNIQUEIDENTIFIER NULL,
  dim3_dimension_id UNIQUEIDENTIFIER NULL,
  dim3_value_id     UNIQUEIDENTIFIER NULL,
  dim4_dimension_id UNIQUEIDENTIFIER NULL,
  dim4_value_id     UNIQUEIDENTIFIER NULL,
  dim5_dimension_id UNIQUEIDENTIFIER NULL,
  dim5_value_id     UNIQUEIDENTIFIER NULL,
  created_at        DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_balance_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT CK_fct_bal_nonneg CHECK (opening_balance >= 0 AND debit_amount >= 0 AND credit_amount >= 0 AND closing_balance >= 0)
);
GO
