/* ============================================================
   RISK, ACTUARIAL & REINSURANCE → ACTUARIAL (GroupCAT)
   PART 1: TABLES ONLY (PKs, DEFAULTs, light CHECKs) — no FKs
   Requires SQL Server 2016+ for ISJSON checks.
   ============================================================ */

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='rar') EXEC('CREATE SCHEMA rar');
GO

/* 1) Peril × Region taxonomy (CRESTA/ISO/internal) */
IF OBJECT_ID('rar.rar_groupcat_peril_region_ref','U') IS NULL
CREATE TABLE rar.rar_groupcat_peril_region_ref (
  peril_code     NVARCHAR(40)  NOT NULL,          -- e.g., FLOOD, EQ, WIND
  region_code    NVARCHAR(60)  NOT NULL,          -- e.g., CRESTA zone, ISO region
  region_kind    NVARCHAR(40)  NULL,              -- CRESTA / ISO2 / ISO3 / CUSTOM
  country_code   CHAR(2)       NULL,              -- ISO 3166-1 alpha-2
  valid_from     DATE          NULL,
  valid_to       DATE          NULL,
  description    NVARCHAR(400) NULL,
  created_at     DATETIME2(6)  NOT NULL CONSTRAINT DF_rar_groupcatpr_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_groupcat_peril_region_ref PRIMARY KEY (peril_code, region_code),
  CONSTRAINT CK_rar_groupcatpr_dates CHECK (valid_to IS NULL OR valid_to >= valid_from)
);
GO

/* 2) CAT model registry (vendor, version, build, hazard set) */
IF OBJECT_ID('rar.rar_groupcat_model_ref','U') IS NULL
CREATE TABLE rar.rar_groupcat_model_ref (
  model_id         UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_groupcatmod_id DEFAULT NEWID(),
  vendor_code      NVARCHAR(60)     NOT NULL,     -- e.g., RMS, AIR, INTERNAL
  model_code       NVARCHAR(60)     NOT NULL,     -- e.g., RMSEUWind
  version_tag      NVARCHAR(60)     NOT NULL,     -- e.g., 24.1, 2025-12
  build_id         NVARCHAR(60)     NULL,         -- optional build string
  hazard_set_id    NVARCHAR(120)    NULL,         -- hazard dataset id
  release_date     DATE             NULL,
  license_tag      NVARCHAR(120)    NULL,
  source_uri       NVARCHAR(500)    NULL,
  model_sha256     VARBINARY(32)    NULL,
  description      NVARCHAR(500)    NULL,
  created_at       DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_groupcatmod_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_groupcat_model_ref PRIMARY KEY (model_id)
);
GO

/* 3) Exposure-to-grid mapping (policy/risk → cell) with geocode quality */
IF OBJECT_ID('rar.rar_groupcat_exposure_map','U') IS NULL
CREATE TABLE rar.rar_groupcat_exposure_map (
  map_id           UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_groupcatmap_id DEFAULT NEWID(),
  subject_type     NVARCHAR(40)     NOT NULL,     -- e.g., POLICY, RISK_OBJECT
  subject_key      NVARCHAR(200)    NOT NULL,     -- caller-provided id
  geohash          NVARCHAR(20)     NULL,
  cell_key         NVARCHAR(120)    NULL,         -- grid/cell identifier
  latitude         DECIMAL(10,6)    NULL,
  longitude        DECIMAL(10,6)    NULL,
  quality_code     NVARCHAR(20)     NULL,         -- PRECISE/ADDRESS/CENTROID/ZIP/COUNTRY
  method_code      NVARCHAR(40)     NULL,         -- GEOCODER_A/IMPORT/etc.
  source_uri       NVARCHAR(500)    NULL,
  meta_json        NVARCHAR(MAX)    NULL,
  created_at       DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_groupcatmap_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_groupcat_exposure_map PRIMARY KEY (map_id),
  CONSTRAINT CK_rar_groupcatmap_json CHECK (meta_json IS NULL OR ISJSON(meta_json)=1)
);
GO

/* 4) Saved portfolio selections (filters) used in runs */
IF OBJECT_ID('rar.rar_groupcat_portfolio_selection','U') IS NULL
CREATE TABLE rar.rar_groupcat_portfolio_selection (
  selection_id     UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_groupcatps_id DEFAULT NEWID(),
  selection_name   NVARCHAR(120)    NOT NULL,
  owner_principal  NVARCHAR(120)    NULL,         -- tech user/service id
  filter_json      NVARCHAR(MAX)    NULL,
  selection_sha256 VARBINARY(32)    NULL,         -- fingerprint of filter
  description      NVARCHAR(500)    NULL,
  created_at       DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_groupcatps_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_groupcat_portfolio_selection PRIMARY KEY (selection_id),
  CONSTRAINT CK_rar_groupcatps_json CHECK (filter_json IS NULL OR ISJSON(filter_json)=1)
);
GO

/* 5) Aggregation run (immutable execution header) */
IF OBJECT_ID('rar.rar_groupcat_aggregation_run','U') IS NULL
CREATE TABLE rar.rar_groupcat_aggregation_run (
  run_id                 UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_rar_groupcatrun_id DEFAULT NEWID(),
  model_id               UNIQUEIDENTIFIER NOT NULL,   -- FK in Part 2
  selection_id           UNIQUEIDENTIFIER NULL,       -- FK in Part 2
  as_of_date             DATE             NULL,       -- valuation date
  financial_terms_tag    NVARCHAR(80)     NULL,       -- version string
  has_secondary_uncert   BIT              NOT NULL CONSTRAINT DF_rar_groupcatrun_su DEFAULT 0,
  currency_code          CHAR(3)          NULL,
  params_json            NVARCHAR(MAX)    NULL,
  params_sha256          VARBINARY(32)    NULL,
  initiated_by_principal NVARCHAR(120)    NULL,
  created_at             DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_groupcatrun_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_groupcat_aggregation_run PRIMARY KEY (run_id),
  CONSTRAINT CK_rar_groupcatrun_json CHECK (params_json IS NULL OR ISJSON(params_json)=1),
  CONSTRAINT CK_rar_groupcatrun_ccy  CHECK (currency_code IS NULL OR currency_code LIKE '[A-Z][A-Z][A-Z]')
);
GO

/* 6) EP curve points (AEP/OEP) per run */
IF OBJECT_ID('rar.rar_groupcat_agg_result','U') IS NULL
CREATE TABLE rar.rar_groupcat_agg_result (
  run_id               UNIQUEIDENTIFIER NOT NULL,     -- FK in Part 2
  ep_type_code         NVARCHAR(10)     NOT NULL,     -- 'AEP' | 'OEP'
  return_period_years  INT              NOT NULL,     -- e.g., 10, 20, 100
  loss_amount          DECIMAL(19,4)    NOT NULL,
  percentile           DECIMAL(9,6)     NULL,         -- optional helper
  currency_code        CHAR(3)          NULL,
  created_at           DATETIME2(6)     NOT NULL CONSTRAINT DF_rar_groupcatres_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_groupcat_agg_result PRIMARY KEY (run_id, ep_type_code, return_period_years),
  CONSTRAINT CK_rar_groupcatres_ep CHECK (ep_type_code IN (N'AEP', N'OEP')),
  CONSTRAINT CK_rar_groupcatres_ccy CHECK (currency_code IS NULL OR currency_code LIKE '[A-Z][A-Z][A-Z]'),
  CONSTRAINT CK_rar_groupcatres_amt CHECK (loss_amount >= 0)
);
GO

/* 7) Standard return periods */
IF OBJECT_ID('rar.rar_ref_return_period','U') IS NULL
CREATE TABLE rar.rar_ref_return_period (
  return_period_years INT           NOT NULL,        -- 10/20/50/100/250/500/1000
  label               NVARCHAR(40)  NULL,            -- 'RP10', 'RP100', etc.
  description         NVARCHAR(200) NULL,
  created_at          DATETIME2(6)  NOT NULL CONSTRAINT DF_rar_rpr_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_ref_return_period PRIMARY KEY (return_period_years)
);
GO
