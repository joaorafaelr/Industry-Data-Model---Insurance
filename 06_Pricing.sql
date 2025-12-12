/* ============================================================
   RISK, ACTUARIAL & REINSURANCE - PRICING (SQL Server)
   Creation-only. Creates schema [rar] if missing; no ALTERs.
   ============================================================ */

USE InsuranceData;
GO

/* ============================================================
   PART A) MODELING ASSETS & RUN METADATA
   ============================================================ */

-- A1) Model registry (versions & artifacts)
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
  trained_on_calib_set_id UNIQUEIDENTIFIER NULL,       -- optional link (no FK here)
  training_run_id         UNIQUEIDENTIFIER NULL,       -- optional (no FK here)
  created_at              DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_mr_created DEFAULT SYSUTCDATETIME(),
  description             NVARCHAR(500)    NULL,
  CONSTRAINT PK_rar_prc_model_registry PRIMARY KEY (model_registry_id),
  CONSTRAINT UX_rar_prc_model_registry UNIQUE (model_key, version_tag)
);
GO

-- A2) Feature dictionary
IF OBJECT_ID('rar.rar_prc_feature_ref','U') IS NULL
CREATE TABLE rar.rar_prc_feature_ref (
  feature_id    UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_feat_id DEFAULT NEWID(),
  feature_code  NVARCHAR(200)    NOT NULL,   -- canonical name
  feature_name  NVARCHAR(200)    NULL,
  dtype         VARCHAR(30)      NULL,       -- NUMERIC, CATEGORICAL, TEXT, etc.
  description   NVARCHAR(500)    NULL,
  CONSTRAINT PK_rar_prc_feature_ref PRIMARY KEY (feature_id),
  CONSTRAINT UX_rar_prc_feature_code UNIQUE (feature_code)
);
GO

-- A3) Curve header (single-level; versioned by version_tag + market anchors)
IF OBJECT_ID('rar.rar_prc_curve_ref','U') IS NULL
CREATE TABLE rar.rar_prc_curve_ref (
  curve_id         UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_curve_id DEFAULT NEWID(),
  curve_key        NVARCHAR(200)    NOT NULL,   -- logical name
  version_tag      NVARCHAR(60)     NOT NULL,   -- curve version indicator
  market_date      DATE             NULL,       -- as-of date
  valuation_ts     DATETIME2(6)     NULL,       -- intraday valuation timestamp
  curve_type       NVARCHAR(60)     NULL,       -- YIELD, LOSS, INFLATION, etc.
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

-- A4) Curve points (hybrid X with computed key + not-both-null check)
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

-- A5) Calibration / training dataset registry
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

-- A6) Input snapshot (header-only; labeled + hashed)
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

-- A7) Run header (exact name kept: rar_prc__run)
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

-- A8) Output (run-scoped; blob + minimal subject anchors)
IF OBJECT_ID('rar.rar_prc_output','U') IS NULL
CREATE TABLE rar.rar_prc_output (
  output_id     UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_out_id DEFAULT NEWID(),
  run_id        UNIQUEIDENTIFIER NOT NULL,
  output_kind   NVARCHAR(60)     NULL,       -- PREMIUMS, FACTORS, LOADINGS, etc.
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

-- A9) Explainability (run+subject anchored; method versioned)
IF OBJECT_ID('rar.rar_prc_explainability','U') IS NULL
CREATE TABLE rar.rar_prc_explainability (
  explain_id          UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_exp_id DEFAULT NEWID(),
  run_id              UNIQUEIDENTIFIER NOT NULL,
  subject_type        NVARCHAR(40)     NULL,      -- RISK_OBJECT, COVERAGE_COMPONENT, etc.
  subject_key         NVARCHAR(200)    NULL,
  method_code         NVARCHAR(40)     NULL,      -- SHAP, IG, permutation, etc.
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

/* ============================================================
   PART B) PRICING BASE STRUCTURE (PKs + defaults only)
   ============================================================ */

-- B1) Rate book master (LoB/product-agnostic)
IF OBJECT_ID('rar.rar_prc_rate_book','U') IS NULL
CREATE TABLE rar.rar_prc_rate_book (
    rate_book_id     UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_rar_prc_rate_book PRIMARY KEY,
    rate_book_code   NVARCHAR(60)     NOT NULL,  -- natural key (UNIQUE in Part 2)
    rate_book_name   NVARCHAR(200)    NOT NULL,
    description      NVARCHAR(1000)   NULL,
    created_at       DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_prc_rb_created DEFAULT SYSUTCDATETIME()
);
GO

-- B2) Rate book version (effective-dated windows; no overlaps enforced here)
IF OBJECT_ID('rar.rar_prc_rate_book_version','U') IS NULL
CREATE TABLE rar.rar_prc_rate_book_version (
    rate_book_version_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_rar_prc_rate_book_version PRIMARY KEY,
    rate_book_id         UNIQUEIDENTIFIER NOT NULL, -- FK in Part 2
    version_tag          NVARCHAR(60)     NOT NULL,
    effective_from       DATE             NOT NULL,
    effective_to         DATE             NULL,
    status_code          NVARCHAR(30)     NOT NULL, -- DRAFT/ACTIVE/RETIRED (whitelist in Part 2)
    meta_json            NVARCHAR(MAX)    NULL,     -- JSON check in Part 2
    created_at           DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_prc_rbv_created DEFAULT SYSUTCDATETIME()
);
GO

-- B3) Rating factor catalog (age_band, territory, vehicle_group, etc.)
IF OBJECT_ID('rar.rar_prc_rating_factor_ref','U') IS NULL
CREATE TABLE rar.rar_prc_rating_factor_ref (
    factor_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_rar_prc_rating_factor_ref PRIMARY KEY,
    factor_code    NVARCHAR(60)     NOT NULL,   -- natural key per factor
    factor_name    NVARCHAR(200)    NOT NULL,
    dtype          NVARCHAR(40)     NOT NULL,   -- NUMERIC / CATEGORICAL / BOOLEAN / BAND
    description    NVARCHAR(1000)   NULL,
    created_at     DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_prc_factor_created DEFAULT SYSUTCDATETIME()
);
GO

-- B4) Rating factor bands (for BAND/CATEGORICAL types)
IF OBJECT_ID('rar.rar_prc_rating_factor_band','U') IS NULL
CREATE TABLE rar.rar_prc_rating_factor_band (
    band_id        UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_rar_prc_rating_factor_band PRIMARY KEY,
    factor_id      UNIQUEIDENTIFIER NOT NULL,   -- FK in Part 2
    band_code      NVARCHAR(60)     NOT NULL,   -- natural within factor
    lower_bound    DECIMAL(19,6)    NULL,       -- for numeric bands
    upper_bound    DECIMAL(19,6)    NULL,       -- for numeric bands
    label          NVARCHAR(200)    NULL,
    created_at     DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_prc_band_created DEFAULT SYSUTCDATETIME()
);
GO

-- B5) Tariff table header (ties a dimensional matrix to a version)
IF OBJECT_ID('rar.rar_prc_tariff_table','U') IS NULL
CREATE TABLE rar.rar_prc_tariff_table (
    tariff_table_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_rar_prc_tariff_table PRIMARY KEY,
    rate_book_version_id UNIQUEIDENTIFIER NOT NULL, -- FK in Part 2
    table_code           NVARCHAR(60)     NOT NULL,  -- natural key per RB version
    table_name           NVARCHAR(200)    NOT NULL,
    calc_method_code     NVARCHAR(40)     NOT NULL,  -- e.g., BASE_RATE, MULTIPLIER, ADDITIVE
    currency_code        CHAR(3)          NULL,      -- ISO; check in Part 2
    meta_json            NVARCHAR(MAX)    NULL,      -- JSON check in Part 2
    created_at           DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_prc_tarifft_created DEFAULT SYSUTCDATETIME()
);
GO

-- B6) Tariff table cells (up to 5 dimensions for generality)
IF OBJECT_ID('rar.rar_prc_tariff_cell','U') IS NULL
CREATE TABLE rar.rar_prc_tariff_cell (
    tariff_cell_id   UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_rar_prc_tariff_cell PRIMARY KEY,
    tariff_table_id  UNIQUEIDENTIFIER NOT NULL,  -- FK in Part 2
    dim1_code        NVARCHAR(60)     NULL,
    dim2_code        NVARCHAR(60)     NULL,
    dim3_code        NVARCHAR(60)     NULL,
    dim4_code        NVARCHAR(60)     NULL,
    dim5_code        NVARCHAR(60)     NULL,
    value_num        DECIMAL(19,6)    NULL,      -- numeric rate
    value_txt        NVARCHAR(200)    NULL,      -- textual (rare)
    value_json       NVARCHAR(MAX)    NULL,      -- structured cell payload
    created_at       DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_prc_tariffc_created DEFAULT SYSUTCDATETIME()
);
GO

-- B7) Coverage-level price components (surcharges, loadings, discounts)
IF OBJECT_ID('rar.rar_prc_coverage_price_component','U') IS NULL
CREATE TABLE rar.rar_prc_coverage_price_component (
    price_component_id   UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_rar_prc_cov_price_component PRIMARY KEY,
    rate_book_version_id UNIQUEIDENTIFIER NOT NULL,   -- FK in Part 2
    coverage_kind_code   NVARCHAR(60)     NOT NULL,   -- FK to core.ref_coverage_kind in Part 2
    component_code       NVARCHAR(60)     NOT NULL,   -- natural within version+coverage
    component_name       NVARCHAR(200)    NOT NULL,
    component_type_code  NVARCHAR(40)     NOT NULL,   -- BASE / LOADING / DISCOUNT / TAX
    formula_json         NVARCHAR(MAX)    NULL,       -- JSON check in Part 2
    created_at           DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_prc_covpc_created DEFAULT SYSUTCDATETIME()
);
GO

-- B8) Pricing decision rules (business rules, no code here)
IF OBJECT_ID('rar.rar_prc_pricing_rule','U') IS NULL
CREATE TABLE rar.rar_prc_pricing_rule (
    pricing_rule_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_rar_prc_pricing_rule PRIMARY KEY,
    rate_book_version_id UNIQUEIDENTIFIER NOT NULL,  -- FK in Part 2
    rule_code            NVARCHAR(60)     NOT NULL,
    rule_name            NVARCHAR(200)    NOT NULL,
    priority_no          INT              NOT NULL,
    status_code          NVARCHAR(30)     NOT NULL,  -- ACTIVE/INACTIVE
    created_at           DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_prc_rule_created DEFAULT SYSUTCDATETIME()
);
GO

-- B9) Rule conditions (normalized, expression-free)
IF OBJECT_ID('rar.rar_prc_pricing_rule_condition','U') IS NULL
CREATE TABLE rar.rar_prc_pricing_rule_condition (
    rule_condition_id    UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_rar_prc_pricing_rule_condition PRIMARY KEY,
    pricing_rule_id      UNIQUEIDENTIFIER NOT NULL,  -- FK in Part 2
    factor_code          NVARCHAR(60)     NOT NULL,  -- matches rar_prc_rating_factor_ref.factor_code
    operator_code        NVARCHAR(20)     NOT NULL,  -- =, IN, BETWEEN, >=, etc.
    value_code           NVARCHAR(200)    NULL,      -- literal or band_code
    value_num_from       DECIMAL(19,6)    NULL,      -- for BETWEEN / >=
    value_num_to         DECIMAL(19,6)    NULL,      -- for BETWEEN
    created_at           DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_prc_rulecond_created DEFAULT SYSUTCDATETIME()
);
GO

-- B10) Rule actions (what to do if rule matches)
IF OBJECT_ID('rar.rar_prc_pricing_rule_action','U') IS NULL
CREATE TABLE rar.rar_prc_pricing_rule_action (
    rule_action_id       UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_rar_prc_pricing_rule_action PRIMARY KEY,
    pricing_rule_id      UNIQUEIDENTIFIER NOT NULL,  -- FK in Part 2
    action_type_code     NVARCHAR(40)     NOT NULL,  -- SET_COMPONENT, APPLY_FACTOR, SET_MIN_PREMIUM, REFER, DECLINE
    payload_json         NVARCHAR(MAX)    NULL,      -- details (component_code, factor value, caps, etc.)
    created_at           DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_prc_ruleact_created DEFAULT SYSUTCDATETIME()
);
GO

-- B11) Bind product versions to a rate book version (LoB-neutral binding)
IF OBJECT_ID('rar.rar_prc_product_pricing_binding','U') IS NULL
CREATE TABLE rar.rar_prc_product_pricing_binding (
    binding_id           UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_rar_prc_product_pricing_binding PRIMARY KEY,
    product_version_id   UNIQUEIDENTIFIER NOT NULL,  -- FK to core.core_product_version (Part 2 if exists)
    rate_book_version_id UNIQUEIDENTIFIER NOT NULL,  -- FK in Part 2
    effective_from       DATE             NOT NULL,
    effective_to         DATE             NULL,
    created_at           DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_prc_bind_created DEFAULT SYSUTCDATETIME()
);
GO

/* ============================================================
   PART C) PUBLICATION & VERSIONING
   ============================================================ */

-- C1) Publication job (pipeline execution)
IF OBJECT_ID('rar.rar_prc_rate_publication_job','U') IS NULL
CREATE TABLE rar.rar_prc_rate_publication_job (
    job_id                  UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_rar_prc_pubjob PRIMARY KEY,
    trigger_source_code     NVARCHAR(40)     NOT NULL,      -- MANUAL / CI_PIPELINE / SCHEDULE / API
    initiated_by_principal  NVARCHAR(200)    NULL,
    started_at              DATETIME2(6)     NOT NULL
        CONSTRAINT DF_rar_prc_pubjob_started DEFAULT SYSUTCDATETIME(),
    finished_at             DATETIME2(6)     NULL,
    status_code             NVARCHAR(30)     NOT NULL,      -- PENDING/RUNNING/SUCCEEDED/FAILED
    request_json            NVARCHAR(MAX)    NULL,          -- request parameters (no schema enforced here)
    log_uri                 NVARCHAR(1000)   NULL
);
GO

-- C2) Published rate book (immutable artifact)
IF OBJECT_ID('rar.rar_prc_published_rate_book','U') IS NULL
CREATE TABLE rar.rar_prc_published_rate_book (
    rate_book_id            UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_rar_prc_ratebook PRIMARY KEY,
    rate_book_key           NVARCHAR(120)    NOT NULL,      -- natural identifier for the book (product+jurisdiction+channel)
    version_tag             NVARCHAR(60)     NOT NULL,      -- e.g., 2026.01 / R1
    effective_from          DATE             NOT NULL,
    effective_to            DATE             NULL,
    product_version_id      UNIQUEIDENTIFIER NULL,          -- optional cross-domain link
    channel_code            NVARCHAR(40)     NULL,
    jurisdiction_code       NVARCHAR(40)     NULL,
    country_code            NVARCHAR(2)      NULL,
    currency_code           CHAR(3)          NULL,
    source_uri              NVARCHAR(1000)   NULL,          -- where the compiled book lives
    artifact_sha256         VARBINARY(32)    NULL,
    published_by_principal  NVARCHAR(200)    NULL,
    publication_job_id      UNIQUEIDENTIFIER NULL,          -- link to job
    created_at              DATETIME2(6)     NOT NULL
        CONSTRAINT DF_rar_prc_ratebook_created DEFAULT SYSUTCDATETIME()
);
GO

-- C3) Publication audit trail
IF OBJECT_ID('rar.rar_prc_publication_audit','U') IS NULL
CREATE TABLE rar.rar_prc_publication_audit (
    audit_id                UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_rar_prc_pubaudit PRIMARY KEY,
    rate_book_id            UNIQUEIDENTIFIER NOT NULL,
    event_code              NVARCHAR(40)     NOT NULL,      -- CREATED / PUBLISHED / RETIRED / ROLLBACK
    details_json            NVARCHAR(MAX)    NULL,
    actor_principal         NVARCHAR(200)    NULL,
    occurred_at             DATETIME2(6)     NOT NULL
        CONSTRAINT DF_rar_prc_pubaudit_occ DEFAULT SYSUTCDATETIME()
);
GO

/* ============================================================
   PART D) GOVERNANCE & APPROVALS
   ============================================================ */

-- D1) Change request (business change intent)
IF OBJECT_ID('rar.rar_prc_change_request','U') IS NULL
CREATE TABLE rar.rar_prc_change_request (
    cr_id                   UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_rar_prc_cr PRIMARY KEY,
    product_version_id      UNIQUEIDENTIFIER NULL,
    description             NVARCHAR(4000)   NULL,
    requested_by_principal  NVARCHAR(200)    NOT NULL,
    requested_at            DATETIME2(6)     NOT NULL
        CONSTRAINT DF_rar_prc_cr_reqat DEFAULT SYSUTCDATETIME(),
    status_code             NVARCHAR(30)     NOT NULL,      -- DRAFT/IN_REVIEW/APPROVED/REJECTED/CLOSED
    payload_json            NVARCHAR(MAX)    NULL,          -- proposed deltas (diffs), references only
    target_effective_from   DATE             NULL,
    target_jurisdiction     NVARCHAR(40)     NULL,
    ticket_ref              NVARCHAR(120)    NULL
);
GO

-- D2) Approval workflow (container for decisions)
IF OBJECT_ID('rar.rar_prc_approval_workflow','U') IS NULL
CREATE TABLE rar.rar_prc_approval_workflow (
    workflow_id             UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_rar_prc_awf PRIMARY KEY,
    cr_id                   UNIQUEIDENTIFIER NOT NULL,
    workflow_name           NVARCHAR(120)    NOT NULL,      -- e.g., "Pricing Committee Standard"
    status_code             NVARCHAR(30)     NOT NULL,      -- OPEN/CLOSED/CANCELLED
    created_at              DATETIME2(6)     NOT NULL
        CONSTRAINT DF_rar_prc_awf_created DEFAULT SYSUTCDATETIME()
);
GO

-- D3) Approval decision (steps)
IF OBJECT_ID('rar.rar_prc_approval_decision','U') IS NULL
CREATE TABLE rar.rar_prc_approval_decision (
    decision_id             UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_rar_prc_awfdec PRIMARY KEY,
    workflow_id             UNIQUEIDENTIFIER NOT NULL,
    approver_principal      NVARCHAR(200)    NOT NULL,
    decision_code           NVARCHAR(30)     NOT NULL,      -- APPROVE/REJECT/REQUEST_CHANGES
    decided_at              DATETIME2(6)     NOT NULL
        CONSTRAINT DF_rar_prc_awfdec_decided DEFAULT SYSUTCDATETIME(),
    comments                NVARCHAR(2000)   NULL,
    conditions_json         NVARCHAR(MAX)    NULL
);
GO

-- D4) Rate filing package (regulator submission)
IF OBJECT_ID('rar.rar_prc_rate_filing_package','U') IS NULL
CREATE TABLE rar.rar_prc_rate_filing_package (
    filing_id               UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_rar_prc_filing PRIMARY KEY,
    cr_id                   UNIQUEIDENTIFIER NOT NULL,
    regulator_code          NVARCHAR(60)     NULL,
    jurisdiction_code       NVARCHAR(40)     NULL,
    submission_ref          NVARCHAR(120)    NULL,
    submitted_at            DATETIME2(6)     NULL,
    status_code             NVARCHAR(30)     NOT NULL,      -- DRAFT/SUBMITTED/ACCEPTED/REJECTED/WITHDRAWN
    package_uri             NVARCHAR(1000)   NULL,
    package_sha256          VARBINARY(32)    NULL
);
GO

/* ============================================================
   PART E) RUNTIME PRICING & OVERRIDES
   ============================================================ */

-- E1) Pricing request (quote-in)
IF OBJECT_ID('rar.rar_prc_pricing_request','U') IS NULL
CREATE TABLE rar.rar_prc_pricing_request (
    request_id              UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_rar_prc_preq PRIMARY KEY,
    correlation_id          NVARCHAR(120)    NULL,          -- external correlation (idempotency)
    product_version_id      UNIQUEIDENTIFIER NULL,
    channel_code            NVARCHAR(40)     NULL,
    jurisdiction_code       NVARCHAR(40)     NULL,
    country_code            NVARCHAR(2)      NULL,
    currency_code           CHAR(3)          NULL,
    subject_type            NVARCHAR(40)     NULL,          -- VEHICLE/PROPERTY/PERSON/...
    subject_key             NVARCHAR(120)    NULL,          -- caller-provided key
    quote_context_json      NVARCHAR(MAX)    NULL,          -- full request inputs
    received_at             DATETIME2(6)     NOT NULL
        CONSTRAINT DF_rar_prc_preq_recv DEFAULT SYSUTCDATETIME()
);
GO

-- E2) Pricing response (quote-out)
IF OBJECT_ID('rar.rar_prc_pricing_response','U') IS NULL
CREATE TABLE rar.rar_prc_pricing_response (
    response_id             UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_rar_prc_prsp PRIMARY KEY,
    request_id              UNIQUEIDENTIFIER NOT NULL,
    computed_at             DATETIME2(6)     NOT NULL
        CONSTRAINT DF_rar_prc_prsp_comp DEFAULT SYSUTCDATETIME(),
    total_premium_amount    DECIMAL(19,4)    NULL,
    currency_code           CHAR(3)          NULL,
    status_code             NVARCHAR(30)     NOT NULL,      -- OK/ERROR/TIMEOUT/PARTIAL
    response_json           NVARCHAR(MAX)    NULL           -- full engine payload (no PHI)
);
GO

-- E3) Pricing breakdown (components)
IF OBJECT_ID('rar.rar_prc_pricing_breakdown','U') IS NULL
CREATE TABLE rar.rar_prc_pricing_breakdown (
    line_id                 UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_rar_prc_pbd PRIMARY KEY,
    response_id             UNIQUEIDENTIFIER NOT NULL,
    component_code          NVARCHAR(60)     NOT NULL,      -- BASE / LOAD_LIAB / DISCOUNT_AGE / TAX / FEE / ...
    amount                  DECIMAL(19,4)    NOT NULL,
    currency_code           CHAR(3)          NULL,
    details_json            NVARCHAR(MAX)    NULL
);
GO

-- E4) Overrides (manual adjustments + governance)
IF OBJECT_ID('rar.rar_prc_override_decision','U') IS NULL
CREATE TABLE rar.rar_prc_override_decision (
    override_id             UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_rar_prc_ovr PRIMARY KEY,
    response_id             UNIQUEIDENTIFIER NOT NULL,      -- the priced response being overridden
    workflow_id             UNIQUEIDENTIFIER NULL,          -- optional: approval workflow used
    decided_by_principal    NVARCHAR(200)    NOT NULL,
    decided_at              DATETIME2(6)     NOT NULL
        CONSTRAINT DF_rar_prc_ovr_decided DEFAULT SYSUTCDATETIME(),
    field_path              NVARCHAR(200)    NOT NULL,      -- JSONPath / dotted path to overridden field
    old_value_json          NVARCHAR(MAX)    NULL,
    new_value_json          NVARCHAR(MAX)    NULL,
    reason_code             NVARCHAR(60)     NULL
);
GO

/* ============================================================
   PART F) MONITORING & BACKTESTING
   ============================================================ */

-- F1) Daily KPIs (aggregated)
IF OBJECT_ID('rar.rar_prc_pricing_kpi_daily','U') IS NULL
CREATE TABLE rar.rar_prc_pricing_kpi_daily (
    kpi_date                DATE             NOT NULL,
    product_code            NVARCHAR(60)     NOT NULL,
    channel_code            NVARCHAR(40)     NOT NULL,
    jurisdiction_code       NVARCHAR(40)     NOT NULL,
    country_code            NVARCHAR(2)      NOT NULL,
    quotes_count            INT              NOT NULL,
    bind_rate_pct           DECIMAL(9,6)     NULL,          -- 0..1
    avg_premium_amount      DECIMAL(19,4)    NULL,
    currency_code           CHAR(3)          NULL,
    loss_ratio_estimate_pct DECIMAL(9,6)     NULL,          -- 0..1 (optional)
    created_at              DATETIME2(6)     NOT NULL
        CONSTRAINT DF_rar_prc_kpi_created DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_rar_prc_kpi PRIMARY KEY (kpi_date, product_code, channel_code, jurisdiction_code, country_code)
);
GO

-- F2) Backtesting results (metrics by cohort)
IF OBJECT_ID('rar.rar_prc_backtest_result','U') IS NULL
CREATE TABLE rar.rar_prc_backtest_result (
    backtest_id             UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_rar_prc_btest PRIMARY KEY,
    run_date                DATE             NOT NULL,
    product_code            NVARCHAR(60)     NOT NULL,
    cohort_tag              NVARCHAR(120)    NULL,          -- e.g., LP2025-Q1-Motor-NewBiz
    metric_code             NVARCHAR(60)     NOT NULL,      -- GINI / LIFT@10 / MAPE / LR_DIFF / HITRATE ...
    metric_value_num        DECIMAL(19,6)    NULL,
    metric_value_json       NVARCHAR(MAX)    NULL,
    notes                   NVARCHAR(1000)   NULL
);
GO

-- F3) Drift monitor (feature drift / performance drift)
IF OBJECT_ID('rar.rar_prc_drift_monitor','U') IS NULL
CREATE TABLE rar.rar_prc_drift_monitor (
    drift_id                UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_rar_prc_drift PRIMARY KEY,
    observed_at             DATETIME2(6)     NOT NULL
        CONSTRAINT DF_rar_prc_drift_obs DEFAULT SYSUTCDATETIME(),
    product_code            NVARCHAR(60)     NOT NULL,
    feature_code            NVARCHAR(60)     NOT NULL,
    drift_statistic         DECIMAL(19,6)    NULL,          -- e.g., PSI/KL
    p_value                 DECIMAL(19,6)    NULL,
    status_code             NVARCHAR(30)     NOT NULL,      -- GREEN/AMBER/RED
    details_json            NVARCHAR(MAX)    NULL
);
GO
