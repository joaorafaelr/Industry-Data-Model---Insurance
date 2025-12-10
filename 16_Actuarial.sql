/* ============================================================
   RAR — ACTUARIAL
   PART 1 — TABLES (PKs, DEFAULTs, hygiene CHECKs) — NO FKs
   ============================================================ */

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='rar') EXEC('CREATE SCHEMA rar');
GO

/* Refs */
IF OBJECT_ID('rar.rar_act_ref_cashflow_type','U') IS NULL
CREATE TABLE rar.rar_act_ref_cashflow_type (
  cashflow_type_code   NVARCHAR(40)  NOT NULL,
  cashflow_type_name   NVARCHAR(200) NOT NULL,
  description          NVARCHAR(500) NULL,
  CONSTRAINT PK_rar_act_ref_cashflow_type PRIMARY KEY (cashflow_type_code)
);

IF OBJECT_ID('rar.rar_act_ref_fx_rate_set','U') IS NULL
CREATE TABLE rar.rar_act_ref_fx_rate_set (
  fx_rate_set_id   UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_act_fxset_id DEFAULT NEWID(),
  set_key          NVARCHAR(100)    NOT NULL,
  as_of_date       DATE             NOT NULL,
  source_system    NVARCHAR(100)    NULL,
  description      NVARCHAR(500)    NULL,
  created_at       DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_act_fxset_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_act_ref_fx_rate_set PRIMARY KEY (fx_rate_set_id)
);

/* Contract Groups */
IF OBJECT_ID('rar.rar_act_actuarial_contract_group','U') IS NULL
CREATE TABLE rar.rar_act_actuarial_contract_group (
  contract_group_id  UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_act_cg_id DEFAULT NEWID(),
  portfolio_code     NVARCHAR(60)     NOT NULL,
  cohort_year        SMALLINT         NOT NULL,
  measurement_model  NVARCHAR(30)     NOT NULL,   -- GMM/PAA/VFA
  onerous_bucket     NVARCHAR(30)     NOT NULL,   -- ONEROUS/NON_ONEROUS/OTHER
  currency_code      CHAR(3)          NOT NULL,
  lob_code           NVARCHAR(20)     NULL,
  status_code        NVARCHAR(30)     NOT NULL,
  notes_json         NVARCHAR(MAX)    NULL,
  created_at         DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_act_cg_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_act_actuarial_contract_group PRIMARY KEY (contract_group_id),
  CONSTRAINT CK_rar_act_cg_cur    CHECK (currency_code LIKE '[A-Z][A-Z][A-Z]'),
  CONSTRAINT CK_rar_act_cg_json   CHECK (notes_json IS NULL OR ISJSON(notes_json)=1),
  CONSTRAINT CK_rar_act_cg_cohort CHECK (cohort_year BETWEEN 1900 AND 2100)
);

IF OBJECT_ID('rar.rar_act_actuarial_contract_group_ri','U') IS NULL
CREATE TABLE rar.rar_act_actuarial_contract_group_ri (
  contract_group_ri_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_act_cgri_id DEFAULT NEWID(),
  portfolio_code       NVARCHAR(60)     NOT NULL,
  cohort_year          SMALLINT         NOT NULL,
  measurement_model    NVARCHAR(30)     NOT NULL,
  currency_code        CHAR(3)          NOT NULL,
  status_code          NVARCHAR(30)     NOT NULL,
  notes_json           NVARCHAR(MAX)    NULL,
  created_at           DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_act_cgri_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_act_actuarial_contract_group_ri PRIMARY KEY (contract_group_ri_id),
  CONSTRAINT CK_rar_act_cgri_cur    CHECK (currency_code LIKE '[A-Z][A-Z][A-Z]'),
  CONSTRAINT CK_rar_act_cgri_json   CHECK (notes_json IS NULL OR ISJSON(notes_json)=1),
  CONSTRAINT CK_rar_act_cgri_cohort CHECK (cohort_year BETWEEN 1900 AND 2100)
);

/* Policy ↔ CG map */
IF OBJECT_ID('rar.rar_act_policy_contract_group_map','U') IS NULL
CREATE TABLE rar.rar_act_policy_contract_group_map (
  map_id             UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_act_cgmap_id DEFAULT NEWID(),
  policy_id          UNIQUEIDENTIFIER NOT NULL,
  contract_group_id  UNIQUEIDENTIFIER NOT NULL,
  effective_from     DATE             NOT NULL,
  effective_to       DATE             NULL,
  reason_code        NVARCHAR(40)     NULL,
  notes_json         NVARCHAR(MAX)    NULL,
  created_at         DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_act_cgmap_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_act_policy_contract_group_map PRIMARY KEY (map_id),
  CONSTRAINT CK_rar_act_cgmap_dates CHECK (effective_to IS NULL OR effective_to >= effective_from),
  CONSTRAINT CK_rar_act_cgmap_json  CHECK (notes_json IS NULL OR ISJSON(notes_json)=1)
);

/* Assumptions */
IF OBJECT_ID('rar.rar_act_assumption_set','U') IS NULL
CREATE TABLE rar.rar_act_assumption_set (
  assumption_set_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_act_as_id DEFAULT NEWID(),
  set_key           NVARCHAR(100)    NOT NULL,
  purpose_code      NVARCHAR(40)     NOT NULL,
  scope_code        NVARCHAR(40)     NULL,
  description       NVARCHAR(500)    NULL,
  created_at        DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_act_as_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_act_assumption_set PRIMARY KEY (assumption_set_id)
);

IF OBJECT_ID('rar.rar_act_assumption_set_version','U') IS NULL
CREATE TABLE rar.rar_act_assumption_set_version (
  assumption_version_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_act_asv_id DEFAULT NEWID(),
  assumption_set_id     UNIQUEIDENTIFIER NOT NULL,
  version_tag           NVARCHAR(60)     NOT NULL,
  effective_from        DATE             NOT NULL,
  effective_to          DATE             NULL,
  payload_json          NVARCHAR(MAX)    NULL,
  locked_flag           BIT              NOT NULL CONSTRAINT DF_rar_act_asv_locked DEFAULT(0),
  created_at            DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_act_asv_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_act_assumption_set_version PRIMARY KEY (assumption_version_id),
  CONSTRAINT CK_rar_act_asv_dates CHECK (effective_to IS NULL OR effective_to >= effective_from),
  CONSTRAINT CK_rar_act_asv_json  CHECK (payload_json IS NULL OR ISJSON(payload_json)=1)
);

/* Curves */
IF OBJECT_ID('rar.rar_act_discount_curve_ref','U') IS NULL
CREATE TABLE rar.rar_act_discount_curve_ref (
  discount_curve_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_act_dcr_id DEFAULT NEWID(),
  curve_key         NVARCHAR(100)    NOT NULL,
  currency_code     CHAR(3)          NOT NULL,
  source_code       NVARCHAR(60)     NULL,
  construction_json NVARCHAR(MAX)    NULL,
  as_of_date        DATE             NOT NULL,
  created_at        DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_act_dcr_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_act_discount_curve_ref PRIMARY KEY (discount_curve_id),
  CONSTRAINT CK_rar_act_dcr_cur  CHECK (currency_code LIKE '[A-Z][A-Z][A-Z]'),
  CONSTRAINT CK_rar_act_dcr_json CHECK (construction_json IS NULL OR ISJSON(construction_json)=1)
);

IF OBJECT_ID('rar.rar_act_discount_curve_point','U') IS NULL
CREATE TABLE rar.rar_act_discount_curve_point (
  discount_curve_id UNIQUEIDENTIFIER NOT NULL,
  tenor_months      INT              NOT NULL,
  rate_annual_pct   DECIMAL(18,9)    NOT NULL,
  created_at        DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_act_dcp_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_act_discount_curve_point PRIMARY KEY (discount_curve_id, tenor_months),
  CONSTRAINT CK_rar_act_dcp_tenor_nonneg CHECK (tenor_months >= 0)
);

IF OBJECT_ID('rar.rar_act_yield_curve_ref','U') IS NULL
CREATE TABLE rar.rar_act_yield_curve_ref (
  yield_curve_id    UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_act_ycr_id DEFAULT NEWID(),
  curve_key         NVARCHAR(100)    NOT NULL,
  currency_code     CHAR(3)          NOT NULL,
  source_code       NVARCHAR(60)     NULL,
  construction_json NVARCHAR(MAX)    NULL,
  as_of_date        DATE             NOT NULL,
  created_at        DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_act_ycr_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_act_yield_curve_ref PRIMARY KEY (yield_curve_id),
  CONSTRAINT CK_rar_act_ycr_cur  CHECK (currency_code LIKE '[A-Z][A-Z][A-Z]'),
  CONSTRAINT CK_rar_act_ycr_json CHECK (construction_json IS NULL OR ISJSON(construction_json)=1)
);

IF OBJECT_ID('rar.rar_act_yield_curve_point','U') IS NULL
CREATE TABLE rar.rar_act_yield_curve_point (
  yield_curve_id    UNIQUEIDENTIFIER NOT NULL,
  tenor_months      INT              NOT NULL,
  yield_annual_pct  DECIMAL(18,9)    NOT NULL,
  created_at        DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_act_ycp_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_act_yield_curve_point PRIMARY KEY (yield_curve_id, tenor_months),
  CONSTRAINT CK_rar_act_ycp_tenor_nonneg CHECK (tenor_months >= 0)
);

/* Risk Adjustment */
IF OBJECT_ID('rar.rar_act_risk_adjustment_method','U') IS NULL
CREATE TABLE rar.rar_act_risk_adjustment_method (
  ra_method_id     UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_act_ra_id DEFAULT NEWID(),
  method_code      NVARCHAR(40)     NOT NULL,   -- COC/PERCENTILE/etc.
  params_json      NVARCHAR(MAX)    NULL,
  description      NVARCHAR(500)    NULL,
  created_at       DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_act_ra_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_act_risk_adjustment_method PRIMARY KEY (ra_method_id),
  CONSTRAINT CK_rar_act_ra_json CHECK (params_json IS NULL OR ISJSON(params_json)=1)
);

/* Projection & Measurement */
IF OBJECT_ID('rar.rar_act_projection_run','U') IS NULL
CREATE TABLE rar.rar_act_projection_run (
  projection_run_id     UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_act_pr_id DEFAULT NEWID(),
  contract_group_id     UNIQUEIDENTIFIER NOT NULL,
  assumption_version_id UNIQUEIDENTIFIER NOT NULL,
  discount_curve_id     UNIQUEIDENTIFIER NOT NULL,
  yield_curve_id        UNIQUEIDENTIFIER NULL,
  ra_method_id          UNIQUEIDENTIFIER NULL,
  fx_rate_set_id        UNIQUEIDENTIFIER NULL,
  run_key               NVARCHAR(100)    NOT NULL,
  as_of_date            DATE             NOT NULL,
  params_json           NVARCHAR(MAX)    NULL,
  created_at            DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_act_pr_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_act_projection_run PRIMARY KEY (projection_run_id),
  CONSTRAINT CK_rar_act_pr_json CHECK (params_json IS NULL OR ISJSON(params_json)=1),
  CONSTRAINT CK_rar_act_pr_runkey_notblank CHECK (LEN(LTRIM(RTRIM(run_key))) > 0)
);

IF OBJECT_ID('rar.rar_act_projection_cashflow_line','U') IS NULL
CREATE TABLE rar.rar_act_projection_cashflow_line (
  projection_run_id    UNIQUEIDENTIFIER NOT NULL,
  period_start         DATE             NOT NULL,
  period_end           DATE             NOT NULL,
  cashflow_type_code   NVARCHAR(40)     NOT NULL,
  amount               DECIMAL(19,4)    NOT NULL,
  currency_code        CHAR(3)          NOT NULL,
  created_at           DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_act_pcf_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_act_projection_cashflow_line PRIMARY KEY (projection_run_id, period_start, cashflow_type_code),
  CONSTRAINT CK_rar_act_pcf_dates CHECK (period_end >= period_start),
  CONSTRAINT CK_rar_act_pcf_amt   CHECK (amount >= 0),
  CONSTRAINT CK_rar_act_pcf_cur   CHECK (currency_code LIKE '[A-Z][A-Z][A-Z]')
);

IF OBJECT_ID('rar.rar_act_actual_cashflow_line','U') IS NULL
CREATE TABLE rar.rar_act_actual_cashflow_line (
  actual_cf_id        UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_act_acf_id DEFAULT NEWID(),
  contract_group_id   UNIQUEIDENTIFIER NOT NULL,
  period_date         DATE             NOT NULL,
  cashflow_type_code  NVARCHAR(40)     NOT NULL,
  amount              DECIMAL(19,4)    NOT NULL,
  currency_code       CHAR(3)          NOT NULL,
  source_ref_key      NVARCHAR(200)    NULL,
  created_at          DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_act_acf_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_act_actual_cashflow_line PRIMARY KEY (actual_cf_id),
  CONSTRAINT CK_rar_act_acf_amt CHECK (amount >= 0),
  CONSTRAINT CK_rar_act_acf_cur CHECK (currency_code LIKE '[A-Z][A-Z][A-Z]')
);

IF OBJECT_ID('rar.rar_act_coverage_units_period','U') IS NULL
CREATE TABLE rar.rar_act_coverage_units_period (
  contract_group_id UNIQUEIDENTIFIER NOT NULL,
  period_start      DATE             NOT NULL,
  period_end        DATE             NOT NULL,
  coverage_units    DECIMAL(19,6)    NOT NULL,
  created_at        DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_act_cu_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_act_coverage_units_period PRIMARY KEY (contract_group_id, period_start),
  CONSTRAINT CK_rar_act_cu_dates CHECK (period_end >= period_start),
  CONSTRAINT CK_rar_act_cu_pos   CHECK (coverage_units >= 0)
);

IF OBJECT_ID('rar.rar_act_measurement_run','U') IS NULL
CREATE TABLE rar.rar_act_measurement_run (
  measurement_run_id    UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_act_mr_id DEFAULT NEWID(),
  contract_group_id     UNIQUEIDENTIFIER NOT NULL,
  projection_run_id     UNIQUEIDENTIFIER NULL,
  assumption_version_id UNIQUEIDENTIFIER NOT NULL,
  discount_curve_id     UNIQUEIDENTIFIER NOT NULL,
  yield_curve_id        UNIQUEIDENTIFIER NULL,
  fx_rate_set_id        UNIQUEIDENTIFIER NULL,
  ra_method_id          UNIQUEIDENTIFIER NULL,
  run_key               NVARCHAR(100)    NOT NULL,
  as_of_date            DATE             NOT NULL,
  created_at            DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_act_mr_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_act_measurement_run PRIMARY KEY (measurement_run_id),
  CONSTRAINT CK_rar_act_mr_runkey_notblank CHECK (LEN(LTRIM(RTRIM(run_key))) > 0)
);

IF OBJECT_ID('rar.rar_act_ifrs17_rollforward','U') IS NULL
CREATE TABLE rar.rar_act_ifrs17_rollforward (
  measurement_run_id   UNIQUEIDENTIFIER NOT NULL,
  contract_group_id    UNIQUEIDENTIFIER NOT NULL,
  driver_code          NVARCHAR(40)     NOT NULL,   -- NEW_CS/INTEREST_ACC/FX/RELEASE/OCI/…
  balance_type_code    NVARCHAR(30)     NOT NULL,   -- CSM/LRC/LIC
  period_start         DATE             NOT NULL,
  period_end           DATE             NOT NULL,
  amount               DECIMAL(19,4)    NOT NULL,
  currency_code        CHAR(3)          NOT NULL,
  created_at           DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_act_rf_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_act_ifrs17_rollforward PRIMARY KEY (measurement_run_id, contract_group_id, driver_code, balance_type_code, period_start),
  CONSTRAINT CK_rar_act_rf_dates CHECK (period_end >= period_start),
  CONSTRAINT CK_rar_act_rf_amt   CHECK (amount >= 0),
  CONSTRAINT CK_rar_act_rf_cur   CHECK (currency_code LIKE '[A-Z][A-Z][A-Z]')
);

IF OBJECT_ID('rar.rar_act_experience_adjustment','U') IS NULL
CREATE TABLE rar.rar_act_experience_adjustment (
  exp_adj_id          UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_act_ea_id DEFAULT NEWID(),
  measurement_run_id  UNIQUEIDENTIFIER NOT NULL,
  contract_group_id   UNIQUEIDENTIFIER NOT NULL,
  cashflow_type_code  NVARCHAR(40)     NOT NULL,
  period_date         DATE             NOT NULL,
  expected_amount     DECIMAL(19,4)    NOT NULL,
  actual_amount       DECIMAL(19,4)    NOT NULL,
  currency_code       CHAR(3)          NOT NULL,
  created_at          DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_act_ea_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_act_experience_adjustment PRIMARY KEY (exp_adj_id),
  CONSTRAINT CK_rar_act_ea_nonneg CHECK (expected_amount >= 0 AND actual_amount >= 0),
  CONSTRAINT CK_rar_act_ea_cur    CHECK (currency_code LIKE '[A-Z][A-Z][A-Z]')
);

IF OBJECT_ID('rar.rar_act_transition_setting','U') IS NULL
CREATE TABLE rar.rar_act_transition_setting (
  transition_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_act_tr_id DEFAULT NEWID(),
  contract_group_id  UNIQUEIDENTIFIER NOT NULL,
  method_code        NVARCHAR(40)     NOT NULL,  -- FULL/MPA/FV
  params_json        NVARCHAR(MAX)    NULL,
  created_at         DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_act_tr_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_act_transition_setting PRIMARY KEY (transition_id),
  CONSTRAINT CK_rar_act_tr_json CHECK (params_json IS NULL OR ISJSON(params_json)=1)
);

/* Reinsurance-held outputs */
IF OBJECT_ID('rar.rar_act_ifrs17_measurement_ri','U') IS NULL
CREATE TABLE rar.rar_act_ifrs17_measurement_ri (
  measurement_ri_id    UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_act_mri_id DEFAULT NEWID(),
  contract_group_ri_id UNIQUEIDENTIFIER NOT NULL,
  as_of_date           DATE             NOT NULL,
  metric_code          NVARCHAR(40)     NOT NULL,
  amount               DECIMAL(19,4)    NOT NULL,
  currency_code        CHAR(3)          NOT NULL,
  created_at           DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_act_mri_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_act_ifrs17_measurement_ri PRIMARY KEY (measurement_ri_id),
  CONSTRAINT CK_rar_act_mri_amt CHECK (amount >= 0),
  CONSTRAINT CK_rar_act_mri_cur CHECK (currency_code LIKE '[A-Z][A-Z][A-Z]')
);
GO
