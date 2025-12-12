/* ============================================================
   P&C — Specialty Domain
   PART 1 — Tables, PKs, Defaults, Intra-row CHECKs
   ============================================================ */

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='pc') EXEC('CREATE SCHEMA pc');
GO

/* =========================
   Reference catalogs
   ========================= */

IF OBJECT_ID('pc.ref_specialty_line','U') IS NULL
CREATE TABLE pc.ref_specialty_line (
  specialty_line_code NVARCHAR(40) NOT NULL,
  specialty_line_name NVARCHAR(200) NOT NULL,
  CONSTRAINT PK_ref_specialty_line PRIMARY KEY (specialty_line_code)
);

IF OBJECT_ID('pc.ref_clause_type','U') IS NULL
CREATE TABLE pc.ref_clause_type (
  clause_type_code NVARCHAR(40) NOT NULL,
  clause_type_name NVARCHAR(200) NOT NULL,
  CONSTRAINT PK_ref_clause_type PRIMARY KEY (clause_type_code)
);

IF OBJECT_ID('pc.ref_object_role','U') IS NULL
CREATE TABLE pc.ref_object_role (
  object_role_code NVARCHAR(40) NOT NULL,
  object_role_name NVARCHAR(200) NOT NULL,
  CONSTRAINT PK_ref_object_role PRIMARY KEY (object_role_code)
);

IF OBJECT_ID('pc.ref_route_area_code','U') IS NULL
CREATE TABLE pc.ref_route_area_code (
  route_area_code NVARCHAR(60) NOT NULL,
  route_area_name NVARCHAR(200) NOT NULL,
  CONSTRAINT PK_ref_route_area_code PRIMARY KEY (route_area_code)
);

IF OBJECT_ID('pc.ref_certification_type','U') IS NULL
CREATE TABLE pc.ref_certification_type (
  certification_type_code NVARCHAR(60) NOT NULL,
  certification_type_name NVARCHAR(200) NOT NULL,
  CONSTRAINT PK_ref_certification_type PRIMARY KEY (certification_type_code)
);

/* =========================
   Risk & versioning
   ========================= */

IF OBJECT_ID('pc.pc_specialty_risk','U') IS NULL
CREATE TABLE pc.pc_specialty_risk (
  risk_id UNIQUEIDENTIFIER NOT NULL
    CONSTRAINT DF_pc_sprisk_id DEFAULT NEWID(),
  risk_code NVARCHAR(100) NOT NULL,
  specialty_line_code NVARCHAR(40) NOT NULL,
  insured_entity_id UNIQUEIDENTIFIER NULL,
  description NVARCHAR(500) NULL,
  created_at DATETIME2 NOT NULL CONSTRAINT DF_pc_sprisk_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_pc_specialty_risk PRIMARY KEY (risk_id)
);

IF OBJECT_ID('pc.pc_specialty_risk_version','U') IS NULL
CREATE TABLE pc.pc_specialty_risk_version (
  risk_version_id UNIQUEIDENTIFIER NOT NULL
    CONSTRAINT DF_pc_spriskver_id DEFAULT NEWID(),
  risk_id UNIQUEIDENTIFIER NOT NULL,
  version_no INT NOT NULL,
  effective_from DATE NOT NULL,
  effective_to DATE NULL,
  status_code NVARCHAR(30) NOT NULL,
  underwriting_json NVARCHAR(MAX) NULL,
  created_at DATETIME2 NOT NULL CONSTRAINT DF_pc_spriskver_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_pc_specialty_risk_version PRIMARY KEY (risk_version_id),
  CONSTRAINT CK_pc_spriskver_dates CHECK (effective_to IS NULL OR effective_to > effective_from),
  CONSTRAINT CK_pc_spriskver_status CHECK (status_code IN (N'DRAFT',N'ACTIVE',N'SUPERSEDED',N'CANCELLED'))
);

/* =========================
   Schedules & locations
   ========================= */

IF OBJECT_ID('pc.pc_specialty_schedule_item','U') IS NULL
CREATE TABLE pc.pc_specialty_schedule_item (
  schedule_item_id UNIQUEIDENTIFIER NOT NULL
    CONSTRAINT DF_pc_spsched_id DEFAULT NEWID(),
  risk_version_id UNIQUEIDENTIFIER NOT NULL,
  object_role_code NVARCHAR(40) NOT NULL,
  item_reference NVARCHAR(200) NOT NULL,
  insured_value DECIMAL(19,4) NULL,
  currency_code CHAR(3) NULL,
  CONSTRAINT PK_pc_specialty_schedule_item PRIMARY KEY (schedule_item_id),
  CONSTRAINT CK_pc_spsched_ccy CHECK (currency_code IS NULL OR (currency_code = UPPER(currency_code) AND currency_code LIKE '[A-Z][A-Z][A-Z]'))
);

IF OBJECT_ID('pc.pc_specialty_insured_location','U') IS NULL
CREATE TABLE pc.pc_specialty_insured_location (
  location_id UNIQUEIDENTIFIER NOT NULL
    CONSTRAINT DF_pc_sploc_id DEFAULT NEWID(),
  risk_version_id UNIQUEIDENTIFIER NOT NULL,
  route_area_code NVARCHAR(60) NOT NULL,
  description NVARCHAR(500) NULL,
  CONSTRAINT PK_pc_specialty_insured_location PRIMARY KEY (location_id)
);

/* =========================
   Clauses & documents
   ========================= */

IF OBJECT_ID('pc.pc_specialty_clauses','U') IS NULL
CREATE TABLE pc.pc_specialty_clauses (
  clause_id UNIQUEIDENTIFIER NOT NULL
    CONSTRAINT DF_pc_spclause_id DEFAULT NEWID(),
  risk_version_id UNIQUEIDENTIFIER NOT NULL,
  clause_type_code NVARCHAR(40) NOT NULL,
  clause_reference NVARCHAR(200) NOT NULL,
  CONSTRAINT PK_pc_specialty_clauses PRIMARY KEY (clause_id)
);

IF OBJECT_ID('pc.pc_specialty_document_ref','U') IS NULL
CREATE TABLE pc.pc_specialty_document_ref (
  document_id UNIQUEIDENTIFIER NOT NULL
    CONSTRAINT DF_pc_spdoc_id DEFAULT NEWID(),
  risk_version_id UNIQUEIDENTIFIER NOT NULL,
  document_uri NVARCHAR(1000) NOT NULL,
  document_sha256 VARBINARY(32) NULL,
  certification_type_code NVARCHAR(60) NULL,
  CONSTRAINT PK_pc_specialty_document_ref PRIMARY KEY (document_id)
);

/* =========================
   Line-specific extensions
   ========================= */

IF OBJECT_ID('pc.pc_specialty_marine_ext','U') IS NULL
CREATE TABLE pc.pc_specialty_marine_ext (
  risk_version_id UNIQUEIDENTIFIER NOT NULL,
  imo_number NVARCHAR(20) NULL,
  flag_code NVARCHAR(20) NULL,
  tonnage DECIMAL(19,4) NULL,
  CONSTRAINT PK_pc_specialty_marine_ext PRIMARY KEY (risk_version_id)
);

IF OBJECT_ID('pc.pc_specialty_aviation_ext','U') IS NULL
CREATE TABLE pc.pc_specialty_aviation_ext (
  risk_version_id UNIQUEIDENTIFIER NOT NULL,
  aircraft_type NVARCHAR(100) NULL,
  mtow_kg DECIMAL(19,4) NULL,
  seat_count INT NULL,
  CONSTRAINT PK_pc_specialty_aviation_ext PRIMARY KEY (risk_version_id)
);

IF OBJECT_ID('pc.pc_specialty_energy_ext','U') IS NULL
CREATE TABLE pc.pc_specialty_energy_ext (
  risk_version_id UNIQUEIDENTIFIER NOT NULL,
  facility_type NVARCHAR(100) NULL,
  capacity_mw DECIMAL(19,4) NULL,
  commissioning_year INT NULL,
  CONSTRAINT PK_pc_specialty_energy_ext PRIMARY KEY (risk_version_id)
);

IF OBJECT_ID('pc.pc_specialty_construction_ext','U') IS NULL
CREATE TABLE pc.pc_specialty_construction_ext (
  risk_version_id UNIQUEIDENTIFIER NOT NULL,
  project_type NVARCHAR(100) NULL,
  contract_form NVARCHAR(100) NULL,
  phase_code NVARCHAR(50) NULL,
  CONSTRAINT PK_pc_specialty_construction_ext PRIMARY KEY (risk_version_id)
);

IF OBJECT_ID('pc.pc_specialty_art_ext','U') IS NULL
CREATE TABLE pc.pc_specialty_art_ext (
  risk_version_id UNIQUEIDENTIFIER NOT NULL,
  artist_name NVARCHAR(200) NULL,
  medium NVARCHAR(100) NULL,
  provenance_ref NVARCHAR(200) NULL,
  CONSTRAINT PK_pc_specialty_art_ext PRIMARY KEY (risk_version_id)
);
