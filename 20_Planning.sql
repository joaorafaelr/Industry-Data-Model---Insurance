/* ============================================================
   FCT — PLANNING (Part 1)
   Tables + PKs + DEFAULTs + intra-table CHECKs only
   ============================================================ */

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='fct') EXEC('CREATE SCHEMA fct');
GO

/* Reference catalogs */
IF OBJECT_ID('fct.fct_plan_scenario_ref','U') IS NULL
CREATE TABLE fct.fct_plan_scenario_ref (
  scenario_code NVARCHAR(50)  NOT NULL,
  scenario_name NVARCHAR(200) NOT NULL,
  CONSTRAINT PK_fct_plan_scenario_ref PRIMARY KEY (scenario_code)
);
GO

IF OBJECT_ID('fct.fct_plan_assumption_ref','U') IS NULL
CREATE TABLE fct.fct_plan_assumption_ref (
  assumption_code NVARCHAR(50)  NOT NULL,
  assumption_name NVARCHAR(200) NOT NULL,
  CONSTRAINT PK_fct_plan_assumption_ref PRIMARY KEY (assumption_code)
);
GO

IF OBJECT_ID('fct.fct_plan_driver_ref','U') IS NULL
CREATE TABLE fct.fct_plan_driver_ref (
  driver_code NVARCHAR(50)  NOT NULL,
  driver_name NVARCHAR(200) NOT NULL,
  CONSTRAINT PK_fct_plan_driver_ref PRIMARY KEY (driver_code)
);
GO

/* Plan cycle */
IF OBJECT_ID('fct.fct_plan_cycle','U') IS NULL
CREATE TABLE fct.fct_plan_cycle (
  plan_cycle_id   UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_fct_plancyc_id DEFAULT NEWID(),
  cycle_code      NVARCHAR(60)     NOT NULL,
  cycle_name      NVARCHAR(200)    NOT NULL,
  fiscal_year     INT              NULL,
  start_period_id UNIQUEIDENTIFIER NULL,
  end_period_id   UNIQUEIDENTIFIER NULL,
  created_at      DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_plancyc_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_fct_plan_cycle PRIMARY KEY (plan_cycle_id),
  /* minimal window sanity (full chronology guardrail done via trigger later) */
  CONSTRAINT CK_fct_plancyc_window CHECK (
    start_period_id IS NULL OR end_period_id IS NULL OR start_period_id <> end_period_id
  )
);
GO

/* Plan version */
IF OBJECT_ID('fct.fct_plan_version','U') IS NULL
CREATE TABLE fct.fct_plan_version (
  plan_version_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_fct_planver_id DEFAULT NEWID(),
  plan_cycle_id   UNIQUEIDENTIFIER NOT NULL,
  scenario_code   NVARCHAR(50)     NOT NULL,
  version_code    NVARCHAR(60)     NOT NULL,
  status_code     NVARCHAR(30)     NOT NULL,  -- DRAFT/IN_REVIEW/APPROVED/LOCKED/RETIRED
  created_at      DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_planver_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_fct_plan_version PRIMARY KEY (plan_version_id),
  CONSTRAINT CK_fct_planver_status CHECK (
    status_code IN (N'DRAFT',N'IN_REVIEW',N'APPROVED',N'LOCKED',N'RETIRED')
  )
);
GO

/* Plan line (facts) */
IF OBJECT_ID('fct.fct_plan_line','U') IS NULL
CREATE TABLE fct.fct_plan_line (
  plan_line_id     UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_fct_planline_id DEFAULT NEWID(),
  plan_version_id  UNIQUEIDENTIFIER NOT NULL,
  period_id        UNIQUEIDENTIFIER NOT NULL,
  account_id       UNIQUEIDENTIFIER NOT NULL,
  currency_code    CHAR(3)          NOT NULL,
  amount_num       DECIMAL(18,2)    NOT NULL,  -- Monetary precision kept per last spec
  -- dimensional slots (pairs)
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
  created_at        DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_planline_created DEFAULT SYSUTCDATETIME(),
  -- NULL discipline on each pair
  CONSTRAINT CK_fct_planline_dim1_pair CHECK (
    (dim1_dimension_id IS NULL AND dim1_value_id IS NULL) OR
    (dim1_dimension_id IS NOT NULL AND dim1_value_id IS NOT NULL)
  ),
  CONSTRAINT CK_fct_planline_dim2_pair CHECK (
    (dim2_dimension_id IS NULL AND dim2_value_id IS NULL) OR
    (dim2_dimension_id IS NOT NULL AND dim2_value_id IS NOT NULL)
  ),
  CONSTRAINT CK_fct_planline_dim3_pair CHECK (
    (dim3_dimension_id IS NULL AND dim3_value_id IS NULL) OR
    (dim3_dimension_id IS NOT NULL AND dim3_value_id IS NOT NULL)
  ),
  CONSTRAINT CK_fct_planline_dim4_pair CHECK (
    (dim4_dimension_id IS NULL AND dim4_value_id IS NULL) OR
    (dim4_dimension_id IS NOT NULL AND dim4_value_id IS NOT NULL)
  ),
  CONSTRAINT CK_fct_planline_dim5_pair CHECK (
    (dim5_dimension_id IS NULL AND dim5_value_id IS NULL) OR
    (dim5_dimension_id IS NOT NULL AND dim5_value_id IS NOT NULL)
  ),
  -- Basic hygiene
  CONSTRAINT CK_fct_planline_amt_nonneg CHECK (amount_num >= 0),
  CONSTRAINT CK_fct_planline_ccy_upper  CHECK (currency_code = UPPER(currency_code) AND currency_code LIKE '[A-Z][A-Z][A-Z]'),
  CONSTRAINT PK_fct_plan_line PRIMARY KEY (plan_line_id),
  -- NULL-safe normalization for natural unique (lean BINARY(16) form)
  dim1_dim_bin AS ISNULL(CONVERT(BINARY(16), dim1_dimension_id), 0x00000000000000000000000000000000) PERSISTED,
  dim1_val_bin AS ISNULL(CONVERT(BINARY(16), dim1_value_id    ), 0x00000000000000000000000000000000) PERSISTED,
  dim2_dim_bin AS ISNULL(CONVERT(BINARY(16), dim2_dimension_id), 0x00000000000000000000000000000000) PERSISTED,
  dim2_val_bin AS ISNULL(CONVERT(BINARY(16), dim2_value_id    ), 0x00000000000000000000000000000000) PERSISTED,
  dim3_dim_bin AS ISNULL(CONVERT(BINARY(16), dim3_dimension_id), 0x00000000000000000000000000000000) PERSISTED,
  dim3_val_bin AS ISNULL(CONVERT(BINARY(16), dim3_value_id    ), 0x00000000000000000000000000000000) PERSISTED,
  dim4_dim_bin AS ISNULL(CONVERT(BINARY(16), dim4_dimension_id), 0x00000000000000000000000000000000) PERSISTED,
  dim4_val_bin AS ISNULL(CONVERT(BINARY(16), dim4_value_id    ), 0x00000000000000000000000000000000) PERSISTED,
  dim5_dim_bin AS ISNULL(CONVERT(BINARY(16), dim5_dimension_id), 0x00000000000000000000000000000000) PERSISTED,
  dim5_val_bin AS ISNULL(CONVERT(BINARY(16), dim5_value_id    ), 0x00000000000000000000000000000000) PERSISTED
);
GO

/* Assumption value (effective-dated OR period-scoped; overlap guard later) */
IF OBJECT_ID('fct.fct_plan_assumption_value','U') IS NULL
CREATE TABLE fct.fct_plan_assumption_value (
  assumption_value_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_fct_passump_id DEFAULT NEWID(),
  plan_version_id     UNIQUEIDENTIFIER NOT NULL,
  assumption_code     NVARCHAR(50)     NOT NULL,
  effective_from      DATE             NOT NULL,
  effective_to        DATE             NULL,
  period_id           UNIQUEIDENTIFIER NULL,
  value_num           DECIMAL(18,6)    NULL,
  value_json          NVARCHAR(MAX)    NULL,
  created_at          DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_passump_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_fct_plan_assumption_value PRIMARY KEY (assumption_value_id),
  CONSTRAINT CK_fct_passump_json  CHECK (value_json IS NULL OR ISJSON(value_json)=1),
  CONSTRAINT CK_fct_passump_shape CHECK (
    (value_num IS NOT NULL AND value_json IS NULL) OR
    (value_num IS NULL AND value_json IS NOT NULL)
  )
);
GO

/* Driver value (period-based) */
IF OBJECT_ID('fct.fct_plan_driver_value','U') IS NULL
CREATE TABLE fct.fct_plan_driver_value (
  driver_value_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_fct_pdrv_id DEFAULT NEWID(),
  plan_version_id UNIQUEIDENTIFIER NOT NULL,
  driver_code     NVARCHAR(50)     NOT NULL,
  period_id       UNIQUEIDENTIFIER NOT NULL,
  value_num       DECIMAL(18,6)    NULL,
  value_json      NVARCHAR(MAX)    NULL,
  created_at      DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_pdrv_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_fct_plan_driver_value PRIMARY KEY (driver_value_id),
  CONSTRAINT CK_fct_pdrv_json  CHECK (value_json IS NULL OR ISJSON(value_json)=1),
  CONSTRAINT CK_fct_pdrv_shape CHECK (
    (value_num IS NOT NULL AND value_json IS NULL) OR
    (value_num IS NULL AND value_json IS NOT NULL)
  )
);
GO

/* Allocation rule (header) */
IF OBJECT_ID('fct.fct_plan_allocation_rule','U') IS NULL
CREATE TABLE fct.fct_plan_allocation_rule (
  allocation_rule_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_fct_pallocr_id DEFAULT NEWID(),
  plan_version_id    UNIQUEIDENTIFIER NOT NULL,
  method_code        NVARCHAR(30)     NOT NULL, -- PROPORTIONAL/FIXED/DRIVER_BASED
  target_account_id  UNIQUEIDENTIFIER NOT NULL,
  created_at         DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_pallocr_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_fct_plan_allocation_rule PRIMARY KEY (allocation_rule_id),
  CONSTRAINT CK_fct_pallocr_method CHECK (method_code IN (N'PROPORTIONAL',N'FIXED',N'DRIVER_BASED'))
);
GO

/* Allocation entries (lines) */
IF OBJECT_ID('fct.fct_plan_allocation_entry','U') IS NULL
CREATE TABLE fct.fct_plan_allocation_entry (
  allocation_entry_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_fct_palloce_id DEFAULT NEWID(),
  allocation_rule_id  UNIQUEIDENTIFIER NOT NULL,
  source_account_id   UNIQUEIDENTIFIER NULL,
  driver_code         NVARCHAR(50)     NULL,
  weight_pct          DECIMAL(9,6)     NULL,   -- 0..1
  fixed_amount        DECIMAL(18,2)    NULL,   -- >= 0
  created_at          DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_palloce_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_fct_plan_allocation_entry PRIMARY KEY (allocation_entry_id),
  CONSTRAINT CK_fct_palloce_weight_pct_bounds CHECK (weight_pct IS NULL OR (weight_pct >= 0 AND weight_pct <= 1)),
  CONSTRAINT CK_fct_palloce_fixed_amt_nonneg  CHECK (fixed_amount IS NULL OR fixed_amount >= 0)
);
GO

/* Variance register */
IF OBJECT_ID('fct.fct_plan_variance','U') IS NULL
CREATE TABLE fct.fct_plan_variance (
  variance_id        UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_fct_pvar_id DEFAULT NEWID(),
  plan_version_id    UNIQUEIDENTIFIER NOT NULL,
  period_id          UNIQUEIDENTIFIER NOT NULL,
  account_id         UNIQUEIDENTIFIER NOT NULL,
  variance_type_code NVARCHAR(20)     NOT NULL, -- ABSOLUTE / PCT
  variance_amount    DECIMAL(18,2)    NULL,
  variance_pct       DECIMAL(9,6)     NULL,     -- -1..1 when type=PCT
  currency_code      CHAR(3)          NULL,
  created_at         DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_pvar_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_fct_plan_variance PRIMARY KEY (variance_id),
  CONSTRAINT CK_fct_pvar_shape CHECK (
    (variance_type_code='ABSOLUTE' AND variance_amount IS NOT NULL AND variance_pct IS NULL) OR
    (variance_type_code='PCT'      AND variance_pct    IS NOT NULL AND variance_amount IS NULL)
  ),
  CONSTRAINT CK_fct_pvar_pct_bounds CHECK (variance_type_code <> N'PCT' OR (variance_pct BETWEEN -1 AND 1)),
  CONSTRAINT CK_fct_pvar_ccy_upper CHECK (currency_code IS NULL OR (currency_code = UPPER(currency_code) AND currency_code LIKE '[A-Z][A-Z][A-Z]'))
);
GO

/* Submission */
IF OBJECT_ID('fct.fct_plan_submission','U') IS NULL
CREATE TABLE fct.fct_plan_submission (
  submission_id  UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_fct_psub_id DEFAULT NEWID(),
  plan_version_id UNIQUEIDENTIFIER NOT NULL,
  submitted_by   NVARCHAR(200)    NOT NULL,
  submitted_at   DATETIME2(6)     NOT NULL CONSTRAINT DF_fct_psub_at DEFAULT SYSUTCDATETIME(),
  status_code    NVARCHAR(30)     NOT NULL, -- SUBMITTED/APPROVED/REJECTED
  comments       NVARCHAR(1000)   NULL,
  CONSTRAINT PK_fct_plan_submission PRIMARY KEY (submission_id),
  CONSTRAINT CK_fct_psub_status CHECK (status_code IN (N'SUBMITTED',N'APPROVED',N'REJECTED'))
);
GO
