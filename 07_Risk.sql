/* ============================================================
   RAR → RISK (Part 1) — Base Tables (SQL Server 2016+)
   - Schemas, tables, PKs, column-level checks only
   - No FKs/UNIQUEs/Indexes here
   ============================================================ */

/* 0) Local dictionaries */
IF OBJECT_ID('rar.rar_risk_object_type_ref','U') IS NULL
CREATE TABLE rar.rar_risk_object_type_ref (
  object_type_code NVARCHAR(60)  NOT NULL,
  object_type_name NVARCHAR(200) NULL,
  description      NVARCHAR(500) NULL,
  CONSTRAINT PK_rar_risk_object_type_ref PRIMARY KEY (object_type_code)
);
GO

IF OBJECT_ID('rar.rar_risk_peril_ref','U') IS NULL
CREATE TABLE rar.rar_risk_peril_ref (
  peril_code NVARCHAR(40)  NOT NULL,
  peril_name NVARCHAR(200) NULL,
  description NVARCHAR(500) NULL,
  CONSTRAINT PK_rar_risk_peril_ref PRIMARY KEY (peril_code)
);
GO

IF OBJECT_ID('rar.rar_risk_factor_ref','U') IS NULL
CREATE TABLE rar.rar_risk_factor_ref (
  factor_id   UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_factor_id DEFAULT NEWID(),
  factor_code NVARCHAR(120)    NOT NULL,
  factor_name NVARCHAR(200)    NULL,
  dtype       VARCHAR(30)      NULL,  -- NUMERIC, CATEGORICAL, TEXT, JSON, ...
  description NVARCHAR(500)    NULL,
  CONSTRAINT PK_rar_risk_factor_ref PRIMARY KEY (factor_id)
  -- UNIQUE moved to Part 2
);
GO

/* 1) Risk object (neutral anchor) */
IF OBJECT_ID('rar.rar_risk_object','U') IS NULL
CREATE TABLE rar.rar_risk_object (
  risk_object_id   UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_ro_id DEFAULT NEWID(),
  subject_type     NVARCHAR(60)     NOT NULL,
  subject_key      NVARCHAR(200)    NOT NULL,
  object_type_code NVARCHAR(60)     NULL,
  meta_json        NVARCHAR(MAX)    NULL,
  created_at       DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_ro_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_risk_object PRIMARY KEY (risk_object_id),
  CONSTRAINT CK_rar_ro_meta_json CHECK (meta_json IS NULL OR ISJSON(meta_json)=1)
);
GO

/* 2) Exposure snapshot + lines */
IF OBJECT_ID('rar.rar_risk_exposure_snapshot','U') IS NULL
CREATE TABLE rar.rar_risk_exposure_snapshot (
  exposure_snapshot_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_rexh_id DEFAULT NEWID(),
  as_of_ts             DATETIME2(6)     NOT NULL,
  method_code          NVARCHAR(60)     NULL,
  params_json          NVARCHAR(MAX)    NULL,
  description          NVARCHAR(500)    NULL,
  created_at           DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_rexh_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_risk_exposure_snapshot PRIMARY KEY (exposure_snapshot_id),
  CONSTRAINT CK_rar_rexh_params_json CHECK (params_json IS NULL OR ISJSON(params_json)=1)
);
GO

IF OBJECT_ID('rar.rar_risk_exposure','U') IS NULL
CREATE TABLE rar.rar_risk_exposure (
  exposure_id          UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_rex_id DEFAULT NEWID(),
  exposure_snapshot_id UNIQUEIDENTIFIER NOT NULL,
  risk_object_id       UNIQUEIDENTIFIER NOT NULL,
  peril_code           NVARCHAR(40)     NULL,
  sum_insured_amount   DECIMAL(19,4)    NULL,
  sum_insured_currency CHAR(3)          NULL,
  deductible_amount    DECIMAL(19,4)    NULL,
  limits_json          NVARCHAR(MAX)    NULL,
  terms_json           NVARCHAR(MAX)    NULL,
  geohash              NVARCHAR(20)     NULL,
  cell_key             NVARCHAR(120)    NULL,
  created_at           DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_rex_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_risk_exposure PRIMARY KEY (exposure_id),
  CONSTRAINT CK_rar_rex_limits_json CHECK (limits_json IS NULL OR ISJSON(limits_json)=1),
  CONSTRAINT CK_rar_rex_terms_json  CHECK (terms_json  IS NULL OR ISJSON(terms_json)=1)
);
GO

/* 3) Assessment header + factor contributions */
IF OBJECT_ID('rar.rar_risk_assessment','U') IS NULL
CREATE TABLE rar.rar_risk_assessment (
  assessment_id    UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_ras_id DEFAULT NEWID(),
  risk_object_id   UNIQUEIDENTIFIER NOT NULL,
  peril_code       NVARCHAR(40)     NULL,
  assessed_at      DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_ras_ts DEFAULT SYSUTCDATETIME(),
  method_code      NVARCHAR(60)     NULL,
  model_version_id UNIQUEIDENTIFIER NULL,  -- clean target to Pricing model version
  params_json      NVARCHAR(MAX)    NULL,
  score_value      DECIMAL(19,9)    NULL,
  pml_amount       DECIMAL(19,4)    NULL,
  pml_pct          DECIMAL(9,6)     NULL,
  currency_code    CHAR(3)          NULL,
  created_at       DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_ras_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_risk_assessment PRIMARY KEY (assessment_id),
  CONSTRAINT CK_rar_ras_params_json CHECK (params_json IS NULL OR ISJSON(params_json)=1)
);
GO

IF OBJECT_ID('rar.rar_risk_assessment_factor','U') IS NULL
CREATE TABLE rar.rar_risk_assessment_factor (
  assessment_id UNIQUEIDENTIFIER NOT NULL,
  factor_id     UNIQUEIDENTIFIER NOT NULL,
  value_num     DECIMAL(38,12)   NULL,
  value_txt     NVARCHAR(200)    NULL,
  value_json    NVARCHAR(MAX)    NULL,
  contribution  DECIMAL(38,12)   NULL,
  CONSTRAINT PK_rar_risk_assessment_factor PRIMARY KEY (assessment_id, factor_id),
  CONSTRAINT CK_rar_raf_val CHECK (
    value_num IS NOT NULL OR value_txt IS NOT NULL OR value_json IS NOT NULL
  ),
  CONSTRAINT CK_rar_raf_value_json CHECK (value_json IS NULL OR ISJSON(value_json)=1)
);
GO

/* 4) Accumulation snapshot + cells */
IF OBJECT_ID('rar.rar_risk_accumulation_snapshot','U') IS NULL
CREATE TABLE rar.rar_risk_accumulation_snapshot (
  accu_snapshot_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_accu_id DEFAULT NEWID(),
  as_of_ts         DATETIME2(6)     NOT NULL,
  method_code      NVARCHAR(60)     NULL,
  params_json      NVARCHAR(MAX)    NULL,
  description      NVARCHAR(500)    NULL,
  created_at       DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_accu_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_risk_accumulation_snapshot PRIMARY KEY (accu_snapshot_id),
  CONSTRAINT CK_rar_accu_params_json CHECK (params_json IS NULL OR ISJSON(params_json)=1)
);
GO

IF OBJECT_ID('rar.rar_risk_accumulation_detail','U') IS NULL
CREATE TABLE rar.rar_risk_accumulation_detail (
  accu_snapshot_id       UNIQUEIDENTIFIER NOT NULL,
  cell_key               NVARCHAR(120)    NOT NULL,
  peril_code             NVARCHAR(40)     NOT NULL,
  exposure_count         BIGINT           NULL,
  sum_insured_amount     DECIMAL(19,4)    NULL,
  expected_loss_amount   DECIMAL(19,4)    NULL,
  pml_amount             DECIMAL(19,4)    NULL,
  CONSTRAINT PK_rar_risk_accumulation_detail PRIMARY KEY (accu_snapshot_id, cell_key, peril_code)
);
GO

/* 5) Event catalog + impacts */
IF OBJECT_ID('rar.rar_risk_event_ref','U') IS NULL
CREATE TABLE rar.rar_risk_event_ref (
  event_id     UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_event_id DEFAULT NEWID(),
  event_key    NVARCHAR(120)    NOT NULL,
  event_type   NVARCHAR(60)     NULL,
  source_uri   NVARCHAR(500)    NULL,
  payload_json NVARCHAR(MAX)    NULL,
  description  NVARCHAR(500)    NULL,
  created_at   DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_event_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_risk_event_ref PRIMARY KEY (event_id),
  CONSTRAINT CK_rar_event_payload CHECK (payload_json IS NULL OR ISJSON(payload_json)=1)
  -- UNIQUE moved to Part 2
);
GO

IF OBJECT_ID('rar.rar_risk_event_impact','U') IS NULL
CREATE TABLE rar.rar_risk_event_impact (
  event_id       UNIQUEIDENTIFIER NOT NULL,
  risk_object_id UNIQUEIDENTIFIER NOT NULL,
  peril_code     NVARCHAR(40)     NOT NULL,
  impact_json    NVARCHAR(MAX)    NULL,
  loss_amount    DECIMAL(19,4)    NULL,
  created_at     DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_evimp_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_risk_event_impact PRIMARY KEY (event_id, risk_object_id, peril_code),
  CONSTRAINT CK_rar_evimp_impact CHECK (impact_json IS NULL OR ISJSON(impact_json)=1)
);
GO
