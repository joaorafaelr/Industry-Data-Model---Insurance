/* ============================================================
   RISK, ACTUARIAL & REINSURANCE â†’ PRICING (SQL Server)
   Creation-only. Assumes schema [rar] already exists.
   No external enterprise refs. No ALTERs.
   ============================================================ */

USE InsuranceData;
GO

/* 1) Model registry â€” versions & artifacts */
IF OBJECT_ID('rar.rar_prc_model_registry','U') IS NULL
CREATE TABLE rar.rar_prc_model_registry (
  model_registry_id       UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_mr_id DEFAULT NEWID(),
  model_key               NVARCHAR(200)    NOT NULL,   -- logical name (stable)
  version_tag             NVARCHAR(60)     NOT NULL,   -- v1, 2025-12-05, etc.
  artifact_uri            NVARCHAR(500)    NULL,       -- where the model binary lives
  artifact_sha256         VARBINARY(32)    NULL,       -- artifact fingerprint
  feature_schema_sha256   VARBINARY(32)    NULL,       -- features layout hash
  training_code_sha256    VARBINARY(32)    NULL,       -- code that produced it
  approvals_json          NVARCHAR(MAX)    NULL,       -- who/when approved
  -- minimal lineage anchors Paul asked for:
  trained_on_calib_set_id UNIQUEIDENTIFIER NULL,       -- optional link (no FK here)
  training_run_id         UNIQUEIDENTIFIER NULL,       -- optional (no FK here)
  created_at              DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_mr_created DEFAULT SYSUTCDATETIME(),
  description             NVARCHAR(500)    NULL,
  CONSTRAINT PK_rar_prc_model_registry PRIMARY KEY (model_registry_id),
  CONSTRAINT UX_rar_prc_model_registry UNIQUE (model_key, version_tag)
);
GO
-- Structural index (unique already creates one; no extra index needed)

/* 2) Feature dictionary */
IF OBJECT_ID('rar.rar_prc_feature_ref','U') IS NULL
CREATE TABLE rar.rar_prc_feature_ref (
  feature_id    UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_feat_id DEFAULT NEWID(),
  feature_code  NVARCHAR(200)    NOT NULL,   -- canonical name
  feature_name  NVARCHAR(200)    NULL,
  dtype         VARCHAR(30)      NULL,       -- NUMERIC, CATEGORICAL, TEXT, â€¦
  description   NVARCHAR(500)    NULL,
  CONSTRAINT PK_rar_prc_feature_ref PRIMARY KEY (feature_id),
  CONSTRAINT UX_rar_prc_feature_code UNIQUE (feature_code)
);
GO

/* 3) Curve header (single-level; versioned by version_tag + market anchors) */
IF OBJECT_ID('rar.rar_prc_curve_ref','U') IS NULL
CREATE TABLE rar.rar_prc_curve_ref (
  curve_id         UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_curve_id DEFAULT NEWID(),
  curve_key        NVARCHAR(200)    NOT NULL,   -- logical name
  version_tag      NVARCHAR(60)     NOT NULL,   -- curve version indicator
  -- market/valuation anchors (new):
  market_date      DATE             NULL,       -- as-of date
  valuation_ts     DATETIME2(6)     NULL,       -- intraday valuation timestamp
  -- semantics (kept as free text in base)
  curve_type       NVARCHAR(60)     NULL,       -- YIELD, LOSS, INFLATION, â€¦
  currency_code    CHAR(3)          NULL,       -- ISO currency (ref)
  lob_code         NVARCHAR(40)     NULL,       -- optional scope
  product_family   NVARCHAR(60)     NULL,
  jurisdiction     NVARCHAR(60)     NULL,
  country_code     NVARCHAR(10)     NULL,
  interp_method    NVARCHAR(60)     NULL,
  extrap_policy    NVARCHAR(60)     NULL,
  daycount         NVARCHAR(40)     NULL,
  compounding      NVARCHAR(40)     NULL,
  calendar_code    NVARCHAR(60)     NULL,
  source_uri       NVARCHAR(500)    NULL,
  curve_sha256     VARBINARY(32)    NULL,
  created_at       DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_curve_created DEFAULT SYSUTCDATETIME(),
  description      NVARCHAR(500)    NULL,
  CONSTRAINT PK_rar_prc_curve_ref PRIMARY KEY (curve_id),
  CONSTRAINT UX_rar_prc_curve_key_ver UNIQUE (curve_key, version_tag)
);
GO
CREATE INDEX IX_rar_curve_type ON rar.rar_prc_curve_ref(curve_type, market_date);
GO

/* 4) Curve points (hybrid X with computed key + not-both-null check) */
IF OBJECT_ID('rar.rar_prc_curve_point','U') IS NULL
CREATE TABLE rar.rar_prc_curve_point (
  curve_id     UNIQUEIDENTIFIER NOT NULL,
  x_value_num  DECIMAL(19,9)    NULL,       -- numeric tenor
  x_value_txt  NVARCHAR(60)     NULL,       -- textual tenor
  y_value      DECIMAL(19,9)    NOT NULL,
  x_key AS (CASE WHEN x_value_txt IS NOT NULL
                 THEN x_value_txt
                 ELSE CONVERT(NVARCHAR(60), x_value_num)
            END) PERSISTED,
  CONSTRAINT PK_rar_prc_curve_point PRIMARY KEY (curve_id, x_key),
  CONSTRAINT CK_rar_cp_not_both_null CHECK (x_value_txt IS NOT NULL OR x_value_num IS NOT NULL)
);
GO
CREATE INDEX IX_rar_cp_curve_num ON rar.rar_prc_curve_point(curve_id, x_value_num) INCLUDE (y_value);
GO

/* 5) Calibration / training dataset registry */
IF OBJECT_ID('rar.rar_prc_calibration_set_ref','U') IS NULL
CREATE TABLE rar.rar_prc_calibration_set_ref (
  calib_set_id            UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_calib_id DEFAULT NEWID(),
  dataset_uri             NVARCHAR(500)    NULL,
  window_start            DATETIME2(6)     NULL,
  window_end              DATETIME2(6)     NULL,
  selection_criteria_json NVARCHAR(MAX)    NULL,
  selection_sha256        VARBINARY(32)    NULL,
  schema_sha256           VARBINARY(32)    NULL,
  row_count               BIGINT           NULL,
  target_variable         NVARCHAR(120)    NULL,
  dataset_kind            NVARCHAR(30)     NULL,   -- TABLE_SNAPSHOT, QUERY_EXPORT, FILE_BUNDLE
  source_snapshot_tag     NVARCHAR(120)    NULL,   -- optional lake/table snapshot tag
  created_at              DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_calib_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_prc_calibration_set_ref PRIMARY KEY (calib_set_id)
);
GO
CREATE INDEX IX_rar_calib_window ON rar.rar_prc_calibration_set_ref(window_start, window_end);
CREATE INDEX IX_rar_calib_target ON rar.rar_prc_calibration_set_ref(target_variable);
GO

/* 6) Input snapshot (header-only; labeled + hashed) */
IF OBJECT_ID('rar.rar_prc_input_snapshot','U') IS NULL
CREATE TABLE rar.rar_prc_input_snapshot (
  input_snapshot_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_is_id DEFAULT NEWID(),
  snapshot_key           NVARCHAR(200)    NULL,       -- human-meaningful label
  feature_schema_sha256  VARBINARY(32)    NULL,
  snapshot_sha256        VARBINARY(32)    NULL,
  created_at             DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_is_created DEFAULT SYSUTCDATETIME(),
  description            NVARCHAR(500)    NULL,
  CONSTRAINT PK_rar_prc_input_snapshot PRIMARY KEY (input_snapshot_id)
);
GO
CREATE INDEX IX_rar_is_schema ON rar.rar_prc_input_snapshot(feature_schema_sha256);
GO

/* 7) Run header (exact name kept: rar_prc__run) */
IF OBJECT_ID('rar.rar_prc__run','U') IS NULL
CREATE TABLE rar.rar_prc__run (
  run_id                 UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_run_id DEFAULT NEWID(),
  model_registry_id      UNIQUEIDENTIFIER NOT NULL,   -- FK local
  input_snapshot_id      UNIQUEIDENTIFIER NULL,       -- FK local
  calib_set_id           UNIQUEIDENTIFIER NULL,       -- FK local
  curve_id               UNIQUEIDENTIFIER NULL,       -- FK local (single curve)
  params_json            NVARCHAR(MAX)    NULL,
  params_sha256          VARBINARY(32)    NULL,
  code_sha256            VARBINARY(32)    NULL,
  data_sha256            VARBINARY(32)    NULL,
  feature_schema_sha256  VARBINARY(32)    NULL,
  currency_code          CHAR(3)          NULL,       -- ISO currency (ref)
  lob_code               NVARCHAR(40)     NULL,
  product_family         NVARCHAR(60)     NULL,
  jurisdiction           NVARCHAR(60)     NULL,
  country_code           NVARCHAR(10)     NULL,
  -- lifecycle + reproducibility anchors (new):
  status_code            NVARCHAR(30)     NULL,       -- STARTED/SUCCEEDED/FAILED
  started_at             DATETIME2(6)     NULL,
  finished_at            DATETIME2(6)     NULL,
  exit_code              INT              NULL,
  random_seed            INT              NULL,
  environment_fingerprint NVARCHAR(200)   NULL,       -- docker image / env tag
  created_at             DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_run_created DEFAULT SYSUTCDATETIME(),
  initiated_by_principal NVARCHAR(120)    NULL,       -- tech user / client id
  CONSTRAINT PK_rar_prc__run PRIMARY KEY (run_id)
);
GO
CREATE INDEX IX_rar_run_model   ON rar.rar_prc__run(model_registry_id);
CREATE INDEX IX_rar_run_curve   ON rar.rar_prc__run(curve_id);
CREATE INDEX IX_rar_run_calib   ON rar.rar_prc__run(calib_set_id);
CREATE INDEX IX_rar_run_input   ON rar.rar_prc__run(input_snapshot_id);
CREATE INDEX IX_rar_run_created ON rar.rar_prc__run(created_at);
GO

/* 8) Output (run-scoped; blob + minimal subject anchors) */
IF OBJECT_ID('rar.rar_prc_output','U') IS NULL
CREATE TABLE rar.rar_prc_output (
  output_id     UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_out_id DEFAULT NEWID(),
  run_id        UNIQUEIDENTIFIER NOT NULL,
  output_kind   NVARCHAR(60)     NULL,       -- PREMIUMS, FACTORS, LOADINGS, â€¦
  subject_type  NVARCHAR(40)     NULL,       -- optional alignment with explainability
  subject_key   NVARCHAR(200)    NULL,       -- optional alignment with explainability
  currency_code CHAR(3)          NULL,       -- ISO currency (ref)
  output_json   NVARCHAR(MAX)    NULL,       -- free-form results blob
  output_sha256 VARBINARY(32)    NULL,
  created_at    DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_out_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_prc_output PRIMARY KEY (output_id)
);
GO
CREATE INDEX IX_rar_out_run     ON rar.rar_prc_output(run_id);
CREATE INDEX IX_rar_out_created ON rar.rar_prc_output(created_at);
GO

/* 9) Explainability (run+subject anchored; method versioned) */
IF OBJECT_ID('rar.rar_prc_explainability','U') IS NULL
CREATE TABLE rar.rar_prc_explainability (
  explain_id          UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_exp_id DEFAULT NEWID(),
  run_id              UNIQUEIDENTIFIER NOT NULL,
  subject_type        NVARCHAR(40)     NULL,      -- RISK_OBJECT, COVERAGE_COMPONENT, â€¦
  subject_key         NVARCHAR(200)    NULL,
  method_code         NVARCHAR(40)     NULL,      -- SHAP, IG, permutation, â€¦
  method_version      NVARCHAR(40)     NULL,      -- version of method/impl
  method_params_json  NVARCHAR(MAX)    NULL,      -- parameters used
  baseline_json       NVARCHAR(MAX)    NULL,
  details_json        NVARCHAR(MAX)    NULL,      -- per-feature contributions, etc.
  created_at          DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_exp_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_prc_explainability PRIMARY KEY (explain_id)
);
GO
CREATE INDEX IX_rar_exp_run     ON rar.rar_prc_explainability(run_id);
CREATE INDEX IX_rar_exp_subject ON rar.rar_prc_explainability(subject_type, subject_key);
GO