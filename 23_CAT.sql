USE InsuranceData;
GO

/* ============================================================
   PART 1 — P&C · CAT
   Structure only (schemas, tables, PK/DEFAULT/CHECK). No FKs.
   ============================================================ */

/* ---------------------------
   Reference catalogs
--------------------------- */

IF OBJECT_ID('pc.pc_cat_ref_peril','U') IS NULL
CREATE TABLE pc.pc_cat_ref_peril (
  peril_code     NVARCHAR(40)  NOT NULL,
  peril_name     NVARCHAR(200) NOT NULL,
  description    NVARCHAR(500) NULL,
  CONSTRAINT PK_pc_cat_ref_peril PRIMARY KEY (peril_code)
);
GO

IF OBJECT_ID('pc.pc_cat_ref_model','U') IS NULL
CREATE TABLE pc.pc_cat_ref_model (
  model_id        UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_pc_cat_model_id DEFAULT NEWID(),
  vendor_code     NVARCHAR(60)     NOT NULL,
  model_code      NVARCHAR(60)     NOT NULL,
  version_tag     NVARCHAR(60)     NOT NULL,   -- vendor version
  hazard_set_id   NVARCHAR(100)    NULL,
  description     NVARCHAR(500)    NULL,
  CONSTRAINT PK_pc_cat_ref_model PRIMARY KEY (model_id)
);
GO

IF OBJECT_ID('pc.pc_cat_ref_geography','U') IS NULL
CREATE TABLE pc.pc_cat_ref_geography (
  geography_code  NVARCHAR(60)     NOT NULL,   -- CRESTA/GRID/Country/Region code
  system_code     NVARCHAR(40)     NOT NULL,   -- CRESTA, GRID1KM, ISO-3166-2, etc.
  geography_name  NVARCHAR(200)    NULL,
  CONSTRAINT PK_pc_cat_ref_geography PRIMARY KEY (geography_code, system_code)
);
GO

IF OBJECT_ID('pc.pc_cat_ref_agg_level','U') IS NULL
CREATE TABLE pc.pc_cat_ref_agg_level (
  agg_level_code  NVARCHAR(40)  NOT NULL,   -- EVENT, REGION, COUNTRY, PORTFOLIO…
  agg_level_name  NVARCHAR(200) NOT NULL,
  CONSTRAINT PK_pc_cat_ref_agg_level PRIMARY KEY (agg_level_code)
);
GO

IF OBJECT_ID('pc.pc_cat_ref_severity_band','U') IS NULL
CREATE TABLE pc.pc_cat_ref_severity_band (
  severity_band_code NVARCHAR(40)  NOT NULL,  -- e.g., L/M/H/Extreme
  severity_band_name NVARCHAR(200) NOT NULL,
  description        NVARCHAR(500) NULL,
  CONSTRAINT PK_pc_cat_ref_severity_band PRIMARY KEY (severity_band_code)
);
GO

IF OBJECT_ID('pc.pc_cat_ref_metric','U') IS NULL
CREATE TABLE pc.pc_cat_ref_metric (
  metric_code   NVARCHAR(40)  NOT NULL,     -- AEP, OEP, MeanLoss, TVaR, PML…
  metric_name   NVARCHAR(200) NOT NULL,
  description   NVARCHAR(500) NULL,
  CONSTRAINT PK_pc_cat_ref_metric PRIMARY KEY (metric_code)
);
GO

IF OBJECT_ID('pc.pc_cat_ref_return_period','U') IS NULL
CREATE TABLE pc.pc_cat_ref_return_period (
  return_period_years INT NOT NULL,         -- 10, 20, 50, 100, 250, 500, 1000
  display_label       NVARCHAR(40) NULL,
  CONSTRAINT PK_pc_cat_ref_return_period PRIMARY KEY (return_period_years),
  CONSTRAINT CK_pc_cat_rp_pos CHECK (return_period_years > 0)
);
GO

/* ---------------------------
   Event & footprint
--------------------------- */

IF OBJECT_ID('pc.pc_cat_event','U') IS NULL
CREATE TABLE pc.pc_cat_event (
  event_id        UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_pc_cat_event_id DEFAULT NEWID(),
  event_code      NVARCHAR(100)    NOT NULL,  -- natural code (internal or vendor+id)
  event_name      NVARCHAR(200)    NOT NULL,
  peril_code      NVARCHAR(40)     NOT NULL,
  start_timestamp DATETIME2(6)     NULL,
  end_timestamp   DATETIME2(6)     NULL,
  country_code    CHAR(2)          NULL,
  params_json     NVARCHAR(MAX)    NULL,
  created_at      DATETIME2(6)     NOT NULL CONSTRAINT DF_pc_cat_event_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_pc_cat_event PRIMARY KEY (event_id),
  CONSTRAINT CK_pc_cat_event_cc2 CHECK (country_code IS NULL OR (country_code = UPPER(country_code) AND country_code LIKE '[A-Z][A-Z]')),
  CONSTRAINT CK_pc_cat_event_js  CHECK (params_json IS NULL OR ISJSON(params_json)=1)
);
GO

IF OBJECT_ID('pc.pc_cat_event_footprint','U') IS NULL
CREATE TABLE pc.pc_cat_event_footprint (
  footprint_id     UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_pc_cat_fp_id DEFAULT NEWID(),
  event_id         UNIQUEIDENTIFIER NOT NULL,
  footprint_version NVARCHAR(60)    NOT NULL,
  source_uri       NVARCHAR(1000)   NULL,
  source_sha256    VARBINARY(32)    NULL,
  meta_json        NVARCHAR(MAX)    NULL,
  created_at       DATETIME2(6)     NOT NULL CONSTRAINT DF_pc_cat_fp_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_pc_cat_event_footprint PRIMARY KEY (footprint_id),
  CONSTRAINT CK_pc_cat_fp_js CHECK (meta_json IS NULL OR ISJSON(meta_json)=1)
);
GO

/* ---------------------------
   Run & exposure snapshot
--------------------------- */

IF OBJECT_ID('pc.pc_cat_run','U') IS NULL
CREATE TABLE pc.pc_cat_run (
  run_id               UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_pc_cat_run_id DEFAULT NEWID(),
  run_key              NVARCHAR(120)    NOT NULL, -- human/natural tag
  model_id             UNIQUEIDENTIFIER NOT NULL,
  hazard_set_id        NVARCHAR(100)    NULL,
  footprint_id         UNIQUEIDENTIFIER NULL,
  exposure_snapshot_id UNIQUEIDENTIFIER NULL,
  as_of_date           DATE             NULL,
  currency_code        CHAR(3)          NULL,
  params_json          NVARCHAR(MAX)    NULL,
  params_sha256        VARBINARY(32)    NULL,
  code_sha256          VARBINARY(32)    NULL,
  data_sha256          VARBINARY(32)    NULL,
  environment_fingerprint NVARCHAR(200) NULL,
  random_seed          INT              NULL,
  created_at           DATETIME2(6)     NOT NULL CONSTRAINT DF_pc_cat_run_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_pc_cat_run PRIMARY KEY (run_id),
  CONSTRAINT CK_pc_cat_run_ccy CHECK (currency_code IS NULL OR (currency_code = UPPER(currency_code) AND currency_code LIKE '[A-Z][A-Z][A-Z]')),
  CONSTRAINT CK_pc_cat_run_js  CHECK (params_json IS NULL OR ISJSON(params_json)=1)
);
GO

IF OBJECT_ID('pc.pc_cat_exposure_snapshot_hdr','U') IS NULL
CREATE TABLE pc.pc_cat_exposure_snapshot_hdr (
  snapshot_id       UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_pc_cat_snap_id DEFAULT NEWID(),
  snapshot_key      NVARCHAR(120)    NOT NULL,
  source_uri        NVARCHAR(1000)   NULL,
  selection_json    NVARCHAR(MAX)    NULL,     -- portfolio filter JSON
  selection_sha256  VARBINARY(32)    NULL,
  geography_system  NVARCHAR(40)     NULL,     -- matches ref_geography.system_code
  created_at        DATETIME2(6)     NOT NULL CONSTRAINT DF_pc_cat_snap_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_pc_cat_exposure_snapshot_hdr PRIMARY KEY (snapshot_id),
  CONSTRAINT CK_pc_cat_snap_js CHECK (selection_json IS NULL OR ISJSON(selection_json)=1)
);
GO

IF OBJECT_ID('pc.pc_cat_exposure_snapshot_item','U') IS NULL
CREATE TABLE pc.pc_cat_exposure_snapshot_item (
  snapshot_id      UNIQUEIDENTIFIER NOT NULL,
  item_seq         INT              NOT NULL,    -- stable row order within snapshot
  subject_type     NVARCHAR(40)     NOT NULL,    -- POLICY / OBJECT / LOCATION / COMPONENT
  subject_key      NVARCHAR(200)    NOT NULL,    -- business key for the subject type
  geography_code   NVARCHAR(60)     NULL,
  geography_system NVARCHAR(40)     NULL,
  geocell_code     NVARCHAR(100)    NULL,
  insured_value    DECIMAL(19,4)    NULL,        -- informational; non-negative
  meta_json        NVARCHAR(MAX)    NULL,
  CONSTRAINT PK_pc_cat_snap_item PRIMARY KEY (snapshot_id, item_seq),
  CONSTRAINT CK_pc_cat_snap_item_amt CHECK (insured_value IS NULL OR insured_value >= 0),
  CONSTRAINT CK_pc_cat_snap_item_js  CHECK (meta_json IS NULL OR ISJSON(meta_json)=1)
);
GO

/* ---------------------------
   Results, aggregation, links, documents, extensions
--------------------------- */

IF OBJECT_ID('pc.pc_cat_loss_estimate','U') IS NULL
CREATE TABLE pc.pc_cat_loss_estimate (
  run_id               UNIQUEIDENTIFIER NOT NULL,
  agg_level_code       NVARCHAR(40)     NOT NULL,
  geography_code       NVARCHAR(60)     NULL,
  geography_system     NVARCHAR(40)     NULL,
  peril_code           NVARCHAR(40)     NOT NULL,
  metric_code          NVARCHAR(40)     NOT NULL,      -- AEP/OEP/etc.
  return_period_years  INT              NOT NULL,
  value_amount         DECIMAL(19,4)    NOT NULL,
  currency_code        CHAR(3)          NOT NULL,
  created_at           DATETIME2(6)     NOT NULL CONSTRAINT DF_pc_cat_le_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_pc_cat_loss_estimate PRIMARY KEY
    (run_id, agg_level_code, geography_code, geography_system, peril_code, metric_code, return_period_years, currency_code),
  CONSTRAINT CK_pc_cat_le_amt CHECK (value_amount >= 0),
  CONSTRAINT CK_pc_cat_le_ccy CHECK (currency_code = UPPER(currency_code) AND currency_code LIKE '[A-Z][A-Z][A-Z]')
);
GO

IF OBJECT_ID('pc.pc_cat_aggregation','U') IS NULL
CREATE TABLE pc.pc_cat_aggregation (
  run_id           UNIQUEIDENTIFIER NOT NULL,
  agg_level_code   NVARCHAR(40)     NOT NULL,
  geography_code   NVARCHAR(60)     NULL,
  geography_system NVARCHAR(40)     NULL,
  peril_code       NVARCHAR(40)     NULL,
  metric_code      NVARCHAR(40)     NOT NULL,
  value_amount     DECIMAL(19,4)    NOT NULL,
  currency_code    CHAR(3)          NOT NULL,
  created_at       DATETIME2(6)     NOT NULL CONSTRAINT DF_pc_cat_agg_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_pc_cat_aggregation PRIMARY KEY
    (run_id, agg_level_code, geography_code, geography_system, peril_code, metric_code, currency_code),
  CONSTRAINT CK_pc_cat_agg_amt CHECK (value_amount >= 0),
  CONSTRAINT CK_pc_cat_agg_ccy CHECK (currency_code = UPPER(currency_code) AND currency_code LIKE '[A-Z][A-Z][A-Z]')
);
GO

IF OBJECT_ID('pc.pc_cat_claim_link','U') IS NULL
CREATE TABLE pc.pc_cat_claim_link (
  event_id        UNIQUEIDENTIFIER NOT NULL,
  claim_id        UNIQUEIDENTIFIER NOT NULL,   -- FK to Claims domain (if available)
  match_method    NVARCHAR(40)     NULL,       -- GEO_MATCH / POLICY_MATCH / MANUAL
  confidence_pct  DECIMAL(9,6)     NULL,       -- 0..1
  linked_at       DATETIME2(6)     NOT NULL CONSTRAINT DF_pc_cat_clink_linked DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_pc_cat_claim_link PRIMARY KEY (event_id, claim_id),
  CONSTRAINT CK_pc_cat_clink_conf CHECK (confidence_pct IS NULL OR (confidence_pct >= 0 AND confidence_pct <= 1))
);
GO

IF OBJECT_ID('pc.pc_cat_document_ref','U') IS NULL
CREATE TABLE pc.pc_cat_document_ref (
  document_id   UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_pc_cat_doc_id DEFAULT NEWID(),
  event_id      UNIQUEIDENTIFIER NULL,
  run_id        UNIQUEIDENTIFIER NULL,
  snapshot_id   UNIQUEIDENTIFIER NULL,
  doc_uri       NVARCHAR(1000)   NOT NULL,
  artifact_sha256 VARBINARY(32)  NULL,
  doc_kind_code NVARCHAR(40)     NULL,         -- REPORT / MODEL_CFG / EVIDENCE
  created_at    DATETIME2(6)     NOT NULL CONSTRAINT DF_pc_cat_doc_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_pc_cat_document_ref PRIMARY KEY (document_id)
);
GO

IF OBJECT_ID('pc.pc_cat_event_ext','U') IS NULL
CREATE TABLE pc.pc_cat_event_ext (
  event_id        UNIQUEIDENTIFIER NOT NULL,
  attribute_code  NVARCHAR(60)     NOT NULL,
  effective_from  DATETIME2(6)     NOT NULL,
  effective_to    DATETIME2(6)     NULL,
  value_text      NVARCHAR(4000)   NULL,
  value_json      NVARCHAR(MAX)    NULL,
  CONSTRAINT PK_pc_cat_event_ext PRIMARY KEY (event_id, attribute_code, effective_from),
  CONSTRAINT CK_pc_cat_evext_js CHECK (value_json IS NULL OR ISJSON(value_json)=1)
);
GO

IF OBJECT_ID('pc.pc_cat_exposure_ext','U') IS NULL
CREATE TABLE pc.pc_cat_exposure_ext (
  snapshot_id     UNIQUEIDENTIFIER NOT NULL,
  item_seq        INT              NOT NULL,
  attribute_code  NVARCHAR(60)     NOT NULL,
  value_text      NVARCHAR(4000)   NULL,
  value_json      NVARCHAR(MAX)    NULL,
  CONSTRAINT PK_pc_cat_exposure_ext PRIMARY KEY (snapshot_id, item_seq, attribute_code),
  CONSTRAINT CK_pc_cat_expext_js CHECK (value_json IS NULL OR ISJSON(value_json)=1)
);
GO
