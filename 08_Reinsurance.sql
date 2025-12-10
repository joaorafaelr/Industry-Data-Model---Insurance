/* ============================================================
   RAR → Reinsurance — PART 1 (Tables only)
   Requirements:
   - SQL Server 2016+ (ISJSON used later in Part 2)
   - No UNIQUEs, FKs, or non-PK indexes here
   ============================================================ */

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='rar')
  EXEC('CREATE SCHEMA rar');
GO

/* Catalog: Reinstatement basis */
IF OBJECT_ID('rar.rar_ref_reinstatement_basis','U') IS NULL
CREATE TABLE rar.rar_ref_reinstatement_basis (
  reinstatement_basis_code  NVARCHAR(40)    NOT NULL,
  reinstatement_basis_name  NVARCHAR(200)   NULL,
  description               NVARCHAR(500)   NULL,
  CONSTRAINT PK_rar_ref_reinstatement_basis PRIMARY KEY (reinstatement_basis_code)
);
GO

/* Accounting period */
IF OBJECT_ID('rar.rar_ri_accounting_period','U') IS NULL
CREATE TABLE rar.rar_ri_accounting_period (
  accounting_period_id  UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_ri_ap_id DEFAULT NEWID(),
  period_key            NVARCHAR(40)     NOT NULL,     -- e.g. '2025Q1' or '2025-01'
  start_date            DATE             NOT NULL,
  end_date              DATE             NOT NULL,
  description           NVARCHAR(500)    NULL,
  created_at            DATETIME2(6)     NOT NULL CONSTRAINT DF_ri_ap_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_ri_accounting_period PRIMARY KEY (accounting_period_id)
);
GO

/* Program year */
IF OBJECT_ID('rar.rar_ri_program_year','U') IS NULL
CREATE TABLE rar.rar_ri_program_year (
  program_year_id  UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_ri_prog_id DEFAULT NEWID(),
  program_key      NVARCHAR(120)    NOT NULL,    -- logical name of program
  year_no          INT              NOT NULL,    -- e.g., 2026
  description      NVARCHAR(500)    NULL,
  start_date       DATE             NOT NULL,
  end_date         DATE             NULL,
  created_at       DATETIME2(6)     NOT NULL CONSTRAINT DF_ri_prog_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_ri_program_year PRIMARY KEY (program_year_id)
);
GO

/* Treaty (header) */
IF OBJECT_ID('rar.rar_ri_treaty','U') IS NULL
CREATE TABLE rar.rar_ri_treaty (
  treaty_id            UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_ri_treaty_id DEFAULT NEWID(),
  program_year_id      UNIQUEIDENTIFIER NOT NULL,
  treaty_code          NVARCHAR(60)     NOT NULL,      -- natural key within program/year
  treaty_name          NVARCHAR(200)    NULL,
  treaty_type_code     NVARCHAR(40)     NULL,          -- QS, Surplus, XoL, CAT XoL, Stop Loss...
  inception_date       DATE             NOT NULL,
  expiry_date          DATE             NULL,
  limit_currency_code  CHAR(3)          NULL,          -- currency for treaty limits (if defined)
  description          NVARCHAR(500)    NULL,
  created_at           DATETIME2(6)     NOT NULL CONSTRAINT DF_ri_treaty_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_ri_treaty PRIMARY KEY (treaty_id)
);
GO

/* Treaty version */
IF OBJECT_ID('rar.rar_ri_treaty_version','U') IS NULL
CREATE TABLE rar.rar_ri_treaty_version (
  treaty_version_id  UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_ri_tver_id DEFAULT NEWID(),
  treaty_id          UNIQUEIDENTIFIER NOT NULL,
  version_tag        NVARCHAR(60)     NOT NULL,   -- v1, 2026-01, etc.
  effective_from     DATE             NOT NULL,
  effective_to       DATE             NULL,
  notes              NVARCHAR(500)    NULL,
  created_at         DATETIME2(6)     NOT NULL CONSTRAINT DF_ri_tver_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_ri_treaty_version PRIMARY KEY (treaty_version_id)
);
GO

/* Treaty layer */
IF OBJECT_ID('rar.rar_ri_treaty_layer','U') IS NULL
CREATE TABLE rar.rar_ri_treaty_layer (
  layer_id                 UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_ri_layer_id DEFAULT NEWID(),
  treaty_version_id        UNIQUEIDENTIFIER NOT NULL,
  layer_no                 INT              NOT NULL,        -- ordinal within version
  attachment_amount        DECIMAL(19,4)    NULL,
  limit_amount             DECIMAL(19,4)    NULL,
  aggregate_limit_amount   DECIMAL(19,4)    NULL,
  deductible_amount        DECIMAL(19,4)    NULL,
  reinstatement_basis_code NVARCHAR(40)     NULL,
  reinstatement_count      INT              NULL,
  currency_code            CHAR(3)          NULL,
  description              NVARCHAR(500)    NULL,
  created_at               DATETIME2(6)     NOT NULL CONSTRAINT DF_ri_layer_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_ri_treaty_layer PRIMARY KEY (layer_id)
);
GO

/* Treaty layer terms (key/value/JSON) */
IF OBJECT_ID('rar.rar_ri_treaty_layer_term','U') IS NULL
CREATE TABLE rar.rar_ri_treaty_layer_term (
  layer_term_id    UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_ri_lterm_id DEFAULT NEWID(),
  layer_id         UNIQUEIDENTIFIER NOT NULL,
  term_code        NVARCHAR(60)     NOT NULL,     -- e.g. OCCURRENCE, AGGREGATE, HOURS_CLAUSE
  term_value_txt   NVARCHAR(200)    NULL,
  term_value_num   DECIMAL(19,6)    NULL,
  term_value_json  NVARCHAR(MAX)    NULL,
  created_at       DATETIME2(6)     NOT NULL CONSTRAINT DF_ri_lterm_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_ri_treaty_layer_term PRIMARY KEY (layer_term_id)
);
GO

/* Market participant (reinsurer/broker/retro) */
IF OBJECT_ID('rar.rar_ri_market_participant','U') IS NULL
CREATE TABLE rar.rar_ri_market_participant (
  participant_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_ri_part_id DEFAULT NEWID(),
  participant_code    NVARCHAR(60)     NOT NULL,      -- natural code
  display_name        NVARCHAR(200)    NOT NULL,
  participant_type_code NVARCHAR(40)   NULL,          -- REINSURER, BROKER, RETRO...
  domicile_country_code CHAR(2)        NULL,
  tax_id              NVARCHAR(60)     NULL,
  created_at          DATETIME2(6)     NOT NULL CONSTRAINT DF_ri_part_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_ri_market_participant PRIMARY KEY (participant_id)
);
GO

/* Placement shares (either version-level or per-layer) */
IF OBJECT_ID('rar.rar_ri_placement_share','U') IS NULL
CREATE TABLE rar.rar_ri_placement_share (
  placement_id       UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_ri_place_id DEFAULT NEWID(),
  treaty_version_id  UNIQUEIDENTIFIER NOT NULL,
  layer_id           UNIQUEIDENTIFIER NULL,          -- NULL = overall version share
  participant_id     UNIQUEIDENTIFIER NOT NULL,      -- reinsurer (or broker if modeled as signatory)
  share_pct          DECIMAL(9,6)     NOT NULL,      -- 0..1
  brokerage_pct      DECIMAL(9,6)     NULL,          -- 0..1 (if applicable)
  line_notes         NVARCHAR(500)    NULL,
  created_at         DATETIME2(6)     NOT NULL CONSTRAINT DF_ri_place_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_ri_placement_share PRIMARY KEY (placement_id)
);
GO

/* Declaration (periodized) */
IF OBJECT_ID('rar.rar_ri_declaration','U') IS NULL
CREATE TABLE rar.rar_ri_declaration (
  declaration_id          UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_ri_decl_id DEFAULT NEWID(),
  treaty_version_id       UNIQUEIDENTIFIER NOT NULL,
  accounting_period_id    UNIQUEIDENTIFIER NOT NULL,
  exposure_ref_key        NVARCHAR(200)    NOT NULL,   -- neutral anchor to subject
  peril_code              NVARCHAR(40)     NULL,
  declared_premium_amount DECIMAL(19,4)    NULL,
  declared_sum_insured_amount DECIMAL(19,4) NULL,
  currency_code           CHAR(3)          NULL,
  metadata_json           NVARCHAR(MAX)    NULL,
  created_at              DATETIME2(6)     NOT NULL CONSTRAINT DF_ri_decl_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_ri_declaration PRIMARY KEY (declaration_id)
);
GO

/* Cession (by declaration + layer) */
IF OBJECT_ID('rar.rar_ri_cession','U') IS NULL
CREATE TABLE rar.rar_ri_cession (
  cession_id              UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_ri_cess_id DEFAULT NEWID(),
  declaration_id          UNIQUEIDENTIFIER NOT NULL,
  layer_id                UNIQUEIDENTIFIER NOT NULL,
  exposure_ref_key        NVARCHAR(200)    NOT NULL,
  peril_code              NVARCHAR(40)     NULL,
  ceded_rate_pct          DECIMAL(9,6)     NOT NULL,   -- 0..1
  ceded_premium_amount    DECIMAL(19,4)    NULL,
  ceded_sum_insured_amount DECIMAL(19,4)   NULL,
  expected_loss_amount    DECIMAL(19,4)    NULL,
  currency_code           CHAR(3)          NULL,
  created_at              DATETIME2(6)     NOT NULL CONSTRAINT DF_ri_cess_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_ri_cession PRIMARY KEY (cession_id)
);
GO

/* Bordereau — Premium */
IF OBJECT_ID('rar.rar_ri_bordereau_premium','U') IS NULL
CREATE TABLE rar.rar_ri_bordereau_premium (
  bdp_id                 UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_ri_bdp_id DEFAULT NEWID(),
  declaration_id         UNIQUEIDENTIFIER NOT NULL,
  accounting_period_id   UNIQUEIDENTIFIER NOT NULL,
  written_premium_amount DECIMAL(19,4)    NULL,
  earned_premium_amount  DECIMAL(19,4)    NULL,
  adjustments_json       NVARCHAR(MAX)    NULL,
  currency_code          CHAR(3)          NULL,
  created_at             DATETIME2(6)     NOT NULL CONSTRAINT DF_ri_bdp_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_ri_bordereau_premium PRIMARY KEY (bdp_id)
);
GO

/* Bordereau — Claims */
IF OBJECT_ID('rar.rar_ri_bordereau_claims','U') IS NULL
CREATE TABLE rar.rar_ri_bordereau_claims (
  bdc_id               UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_ri_bdc_id DEFAULT NEWID(),
  declaration_id       UNIQUEIDENTIFIER NOT NULL,
  accounting_period_id UNIQUEIDENTIFIER NOT NULL,
  peril_code           NVARCHAR(40)     NULL,
  reported_claims_count INT             NULL,
  paid_amount          DECIMAL(19,4)    NULL,
  outstanding_amount   DECIMAL(19,4)    NULL,
  ibnr_amount          DECIMAL(19,4)    NULL,
  currency_code        CHAR(3)          NULL,
  created_at           DATETIME2(6)     NOT NULL CONSTRAINT DF_ri_bdc_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_ri_bordereau_claims PRIMARY KEY (bdc_id)
);
GO

/* Recovery event (e.g., CAT recovery at layer) */
IF OBJECT_ID('rar.rar_ri_recovery_event','U') IS NULL
CREATE TABLE rar.rar_ri_recovery_event (
  recovery_event_id  UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_ri_recv_id DEFAULT NEWID(),
  layer_id           UNIQUEIDENTIFIER NOT NULL,
  event_key          NVARCHAR(120)    NULL,
  event_date         DATE             NULL,
  recovery_amount    DECIMAL(19,4)    NULL,
  details_json       NVARCHAR(MAX)    NULL,
  currency_code      CHAR(3)          NULL,
  created_at         DATETIME2(6)     NOT NULL CONSTRAINT DF_ri_recv_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_ri_recovery_event PRIMARY KEY (recovery_event_id)
);
GO

/* Settlement statement (periodized) */
IF OBJECT_ID('rar.rar_ri_settlement_statement','U') IS NULL
CREATE TABLE rar.rar_ri_settlement_statement (
  settlement_id         UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_ri_settle_id DEFAULT NEWID(),
  treaty_version_id     UNIQUEIDENTIFIER NOT NULL,
  accounting_period_id  UNIQUEIDENTIFIER NOT NULL,
  statement_json        NVARCHAR(MAX)    NULL,
  total_payable_amount  DECIMAL(19,4)    NULL,  -- sign convention documented in README
  currency_code         CHAR(3)          NULL,
  created_at            DATETIME2(6)     NOT NULL CONSTRAINT DF_ri_settle_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_ri_settlement_statement PRIMARY KEY (settlement_id)
);
GO

/* Expected recovery run (calc job) */
IF OBJECT_ID('rar.rar_ri_expected_recovery_run','U') IS NULL
CREATE TABLE rar.rar_ri_expected_recovery_run (
  exp_run_id               UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_ri_exprun_id DEFAULT NEWID(),
  treaty_version_id        UNIQUEIDENTIFIER NOT NULL,
  params_json              NVARCHAR(MAX)    NULL,
  run_at                   DATETIME2(6)     NOT NULL CONSTRAINT DF_ri_exprun_runat DEFAULT SYSUTCDATETIME(),
  initiated_by_principal   NVARCHAR(120)    NULL,
  created_at               DATETIME2(6)     NOT NULL CONSTRAINT DF_ri_exprun_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_ri_expected_recovery_run PRIMARY KEY (exp_run_id)
);
GO

/* Exposure — P&C */
IF OBJECT_ID('rar.rar_ri_exposure_pc','U') IS NULL
CREATE TABLE rar.rar_ri_exposure_pc (
  exposure_pc_id    UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_ri_exppc_id DEFAULT NEWID(),
  exposure_ref_key  NVARCHAR(200)    NOT NULL,
  peril_code        NVARCHAR(40)     NULL,
  si_amount         DECIMAL(19,4)    NULL,
  geohash           NVARCHAR(20)     NULL,
  cell_key          NVARCHAR(120)    NULL,
  metadata_json     NVARCHAR(MAX)    NULL,
  created_at        DATETIME2(6)     NOT NULL CONSTRAINT DF_ri_exppc_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_ri_exposure_pc PRIMARY KEY (exposure_pc_id)
);
GO

/* Exposure — Life */
IF OBJECT_ID('rar.rar_ri_exposure_life','U') IS NULL
CREATE TABLE rar.rar_ri_exposure_life (
  exposure_life_id     UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_ri_explife_id DEFAULT NEWID(),
  exposure_ref_key     NVARCHAR(200)    NOT NULL,
  sum_at_risk_amount   DECIMAL(19,4)    NULL,
  gender_code          CHAR(1)          NULL,
  age_years            INT              NULL,
  smoker_flag          BIT              NULL CONSTRAINT DF_ri_explife_smoker DEFAULT(0),
  metadata_json        NVARCHAR(MAX)    NULL,
  created_at           DATETIME2(6)     NOT NULL CONSTRAINT DF_ri_explife_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_rar_ri_exposure_life PRIMARY KEY (exposure_life_id)
);
GO
