/* ============================================================
   FCT — CAPITAL
   PART 1: Creation-only (tables + PKs + safe CHECKs/defaults)
   No FKs/UQs/IX here.
   ============================================================ */

USE InsuranceData;
GO

/* 0) Metric reference (added per review) */
IF OBJECT_ID('fct.fct_cap_ref_metric','U') IS NULL
CREATE TABLE fct.fct_cap_ref_metric (
  metric_code NVARCHAR(60)  NOT NULL,
  metric_name NVARCHAR(200) NOT NULL,
  description NVARCHAR(500) NULL,
  CONSTRAINT PK_fct_cap_ref_metric PRIMARY KEY (metric_code)
);
GO

/* 1) Risk module reference (hierarchy; self-FK later) */
IF OBJECT_ID('fct.fct_cap_ref_risk_module','U') IS NULL
CREATE TABLE fct.fct_cap_ref_risk_module (
  risk_module_code    NVARCHAR(60)   NOT NULL,
  parent_module_code  NVARCHAR(60)   NULL,
  module_name         NVARCHAR(200)  NOT NULL,
  description         NVARCHAR(1000) NULL,
  CONSTRAINT PK_fct_cap_ref_risk_module PRIMARY KEY (risk_module_code)
);
GO

/* 2) Stress scenario catalog (UQ on code in Part 2) */
IF OBJECT_ID('fct.fct_cap_stress_scenario_ref','U') IS NULL
CREATE TABLE fct.fct_cap_stress_scenario_ref (
  scenario_id     UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_fct_cap_scn_id DEFAULT NEWID(),
  scenario_code   NVARCHAR(60)     NOT NULL,
  scenario_name   NVARCHAR(200)    NOT NULL,
  kind_code       NVARCHAR(30)     NOT NULL,    -- whitelist later
  params_json     NVARCHAR(MAX)    NULL,        -- JSON check later
  created_at      DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_cap_scn_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_fct_cap_stress_scenario_ref PRIMARY KEY (scenario_id)
);
GO

/* 3) Capital run (hub) */
IF OBJECT_ID('fct.fct_capital_run','U') IS NULL
CREATE TABLE fct.fct_capital_run (
  run_id        UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_fct_cap_run_id DEFAULT NEWID(),
  run_key       NVARCHAR(120)    NOT NULL,     -- UQ with as_of_date later
  as_of_date    DATE             NOT NULL,
  method_code   NVARCHAR(30)     NOT NULL,     -- whitelist later
  currency_code CHAR(3)          NULL,         -- ISO check later
  params_json   NVARCHAR(MAX)    NULL,         -- JSON check later
  notes         NVARCHAR(1000)   NULL,
  created_at    DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_cap_run_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_fct_capital_run PRIMARY KEY (run_id)
);
GO

/* 4) Capital components (SCR/MCR/aggregations) */
IF OBJECT_ID('fct.fct_capital_component','U') IS NULL
CREATE TABLE fct.fct_capital_component (
  component_id        UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_fct_cap_comp_id DEFAULT NEWID(),
  run_id              UNIQUEIDENTIFIER NOT NULL,    -- FK later
  risk_module_code    NVARCHAR(60)     NOT NULL,    -- FK later
  parent_module_code  NVARCHAR(60)     NULL,
  is_sub_module       BIT              NOT NULL CONSTRAINT DF_fct_cap_comp_is_sub DEFAULT(0),
  aggregation_method  NVARCHAR(30)     NULL,        -- whitelist later
  currency_code       CHAR(3)          NULL,        -- ISO check later
  amount_num          DECIMAL(19,4)    NULL,        -- non-neg check later
  correlation_note    NVARCHAR(200)    NULL,
  created_at          DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_cap_comp_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_fct_capital_component PRIMARY KEY (component_id)
);
GO

/* 5) Capital position (entity KPIs for the run) */
IF OBJECT_ID('fct.fct_capital_position','U') IS NULL
CREATE TABLE fct.fct_capital_position (
  position_id            UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_fct_cappos_id DEFAULT NEWID(),
  run_id                 UNIQUEIDENTIFIER NOT NULL,   -- FK later
  reporting_entity_id    UNIQUEIDENTIFIER NULL,       -- optional FK to core.entity later
  reporting_entity_code  NVARCHAR(120)    NULL,
  scope_code             NVARCHAR(20)     NOT NULL,   -- whitelist later
  currency_code          CHAR(3)          NULL,       -- ISO check later
  own_funds_total_amount DECIMAL(19,4)    NULL CHECK (own_funds_total_amount IS NULL OR own_funds_total_amount >= 0),
  scr_total_amount       DECIMAL(19,4)    NULL CHECK (scr_total_amount       IS NULL OR scr_total_amount       >= 0),
  mcr_total_amount       DECIMAL(19,4)    NULL CHECK (mcr_total_amount       IS NULL OR mcr_total_amount       >= 0),
  solvency_ratio_pct     DECIMAL(9,6)     NULL,
  notes                  NVARCHAR(1000)   NULL,
  created_at             DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_cappos_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_fct_capital_position PRIMARY KEY (position_id)
);
GO

/* 6) Capital allocation (LoB/product slices) */
IF OBJECT_ID('fct.fct_capital_allocation','U') IS NULL
CREATE TABLE fct.fct_capital_allocation (
  allocation_id   UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_fct_capalloc_id DEFAULT NEWID(),
  run_id          UNIQUEIDENTIFIER NOT NULL,   -- FK later
  lob_code        NVARCHAR(40)     NULL,
  product_code    NVARCHAR(60)     NULL,
  currency_code   CHAR(3)          NULL,       -- ISO check later
  allocated_amount DECIMAL(19,4)   NULL CHECK (allocated_amount IS NULL OR allocated_amount >= 0),
  notes           NVARCHAR(500)    NULL,
  created_at      DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_capalloc_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_fct_capital_allocation PRIMARY KEY (allocation_id)
);
GO

/* 7) Own funds breakdown */
IF OBJECT_ID('fct.fct_own_funds_item','U') IS NULL
CREATE TABLE fct.fct_own_funds_item (
  of_item_id    UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_fct_ofi_id DEFAULT NEWID(),
  run_id        UNIQUEIDENTIFIER NOT NULL,   -- FK later
  item_code     NVARCHAR(60)     NOT NULL,   -- UQ per run later
  tier_code     NVARCHAR(20)     NULL,
  currency_code CHAR(3)          NULL,       -- ISO check later
  amount_num    DECIMAL(19,4)    NULL CHECK (amount_num IS NULL OR amount_num >= 0),
  notes         NVARCHAR(500)    NULL,
  created_at    DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_ofi_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_fct_own_funds_item PRIMARY KEY (of_item_id)
);
GO

/* 8) Stress results */
IF OBJECT_ID('fct.fct_cap_stress_result','U') IS NULL
CREATE TABLE fct.fct_cap_stress_result (
  stress_result_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_fct_capstr_id DEFAULT NEWID(),
  run_id           UNIQUEIDENTIFIER NOT NULL,  -- FK later
  scenario_id      UNIQUEIDENTIFIER NOT NULL,  -- FK later
  metric_code      NVARCHAR(60)     NOT NULL,  -- FK to ref (later)
  currency_code    CHAR(3)          NULL,      -- ISO check later
  value_num        DECIMAL(19,6)    NULL,
  as_of_date       DATE             NULL,
  notes            NVARCHAR(500)    NULL,
  created_at       DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_capstr_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_fct_cap_stress_result PRIMARY KEY (stress_result_id)
);
GO

/* 9) Capital plan (UQ on period later; optional run FK later) */
IF OBJECT_ID('fct.fct_capital_plan','U') IS NULL
CREATE TABLE fct.fct_capital_plan (
  plan_id         UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_fct_capplan_id DEFAULT NEWID(),
  plan_period_key NVARCHAR(60)     NOT NULL,     -- UQ later
  run_id          UNIQUEIDENTIFIER NULL,         -- optional FK later
  currency_code   CHAR(3)          NULL,         -- ISO check later
  description     NVARCHAR(500)    NULL,
  created_at      DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_capplan_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_fct_capital_plan PRIMARY KEY (plan_id)
);
GO

/* 10) Capital plan actions (whitelist + JSON later) */
IF OBJECT_ID('fct.fct_capital_plan_action','U') IS NULL
CREATE TABLE fct.fct_capital_plan_action (
  action_id     UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_fct_capact_id DEFAULT NEWID(),
  plan_id       UNIQUEIDENTIFIER NOT NULL,     -- FK later
  action_code   NVARCHAR(60)     NOT NULL,
  status_code   NVARCHAR(30)     NULL,         -- whitelist later
  currency_code CHAR(3)          NULL,         -- ISO check later
  impact_amount DECIMAL(19,4)    NULL,
  details_json  NVARCHAR(MAX)    NULL,         -- JSON check later
  due_date      DATE             NULL,
  created_at    DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_capact_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_fct_capital_plan_action PRIMARY KEY (action_id)
);
GO

/* 11) Capital breaches (metric breaches for run) */
IF OBJECT_ID('fct.fct_capital_breach','U') IS NULL
CREATE TABLE fct.fct_capital_breach (
  breach_id       UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_fct_capbreach_id DEFAULT NEWID(),
  run_id          UNIQUEIDENTIFIER NOT NULL,     -- FK later
  metric_code     NVARCHAR(60)     NOT NULL,     -- FK to ref (later)
  threshold_value DECIMAL(19,6)    NULL,
  observed_value  DECIMAL(19,6)    NULL,
  currency_code   CHAR(3)          NULL,         -- ISO check later
  severity_code   NVARCHAR(20)     NULL,         -- whitelist later
  occurred_at     DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_capbreach_occ DEFAULT SYSUTCDATETIME(),
  resolved_at     DATETIME2(6)     NULL,
  status_code     NVARCHAR(20)     NULL,         -- whitelist later
  notes           NVARCHAR(1000)   NULL,
  CONSTRAINT PK_fct_capital_breach PRIMARY KEY (breach_id)
);
GO
