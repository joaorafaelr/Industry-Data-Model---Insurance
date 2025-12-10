/* ============================================================
   POLICIES — PART 1 (BASE)
   Schemas + Tables only (PKs/defaults ok). No FKs/UNIQUE/IX here.
   Requires: SQL Server 2016+ for DATETIME2(6) defaults.
   ============================================================ */

/* core.core_policy */
IF OBJECT_ID('core.core_policy','U') IS NULL
CREATE TABLE core.core_policy (
  policy_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_core_pol_id DEFAULT NEWID(),
  lob_code       NVARCHAR(10)     NOT NULL,
  policy_number  NVARCHAR(60)     NOT NULL,
  status_code    NVARCHAR(40)     NULL,
  inception_date DATE             NULL,
  expiry_date    DATE             NULL,
  currency_code  CHAR(3)          NULL,
  created_at     DATETIME2(6)     NOT NULL CONSTRAINT DF_core_pol_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_core_policy PRIMARY KEY (policy_id)
);
GO

/* core.core_policy_term (versioning per policy) */
IF OBJECT_ID('core.core_policy_term','U') IS NULL
CREATE TABLE core.core_policy_term (
  policy_id      UNIQUEIDENTIFIER NOT NULL,
  version_tag    NVARCHAR(40)     NOT NULL,
  effective_from DATETIME2(6)     NOT NULL,
  effective_to   DATETIME2(6)     NULL,
  status_code    NVARCHAR(40)     NULL,
  created_at     DATETIME2(6)     NOT NULL CONSTRAINT DF_core_polterm_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_core_policy_term PRIMARY KEY (policy_id, version_tag)
);
GO

/* core.core_policy_coverage */
IF OBJECT_ID('core.core_policy_coverage','U') IS NULL
CREATE TABLE core.core_policy_coverage (
  coverage_id        UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_core_polcov_id DEFAULT NEWID(),
  policy_id          UNIQUEIDENTIFIER NOT NULL,
  version_tag        NVARCHAR(40)     NOT NULL,
  coverage_code      NVARCHAR(60)     NULL,
  benefit_code       NVARCHAR(60)     NULL,
  sum_insured_amount DECIMAL(19,4)    NULL,
  deductible_amount  DECIMAL(19,4)    NULL,
  limit_amount       DECIMAL(19,4)    NULL,
  currency_code      CHAR(3)          NULL,
  created_at         DATETIME2(6)     NOT NULL CONSTRAINT DF_core_polcov_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_core_policy_coverage PRIMARY KEY (coverage_id)
);
GO

/* core.core_policy_document_ref */
IF OBJECT_ID('core.core_policy_document_ref','U') IS NULL
CREATE TABLE core.core_policy_document_ref (
  doc_id        UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_core_poldoc_id DEFAULT NEWID(),
  policy_id     UNIQUEIDENTIFIER NOT NULL,
  doc_type_code NVARCHAR(40)     NULL,
  doc_uri       NVARCHAR(500)    NULL, -- bumped to 1000 in Part 2 if needed
  created_at    DATETIME2(6)     NOT NULL CONSTRAINT DF_core_poldoc_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_core_policy_document_ref PRIMARY KEY (doc_id)
);
GO

/* LoB extensions — 1–1 with core_policy (FK in Part 2) */
IF OBJECT_ID('pc.pc_policy_ext','U') IS NULL
CREATE TABLE pc.pc_policy_ext (
  policy_id  UNIQUEIDENTIFIER NOT NULL,
  extra_json NVARCHAR(MAX)    NULL,
  CONSTRAINT PK_pc_policy_ext PRIMARY KEY (policy_id)
);
GO

IF OBJECT_ID('lp.lp_policy_ext','U') IS NULL
CREATE TABLE lp.lp_policy_ext (
  policy_id  UNIQUEIDENTIFIER NOT NULL,
  extra_json NVARCHAR(MAX)    NULL,
  CONSTRAINT PK_lp_policy_ext PRIMARY KEY (policy_id)
);
GO

IF OBJECT_ID('hlth.hlth_policy_ext','U') IS NULL
CREATE TABLE hlth.hlth_policy_ext (
  policy_id  UNIQUEIDENTIFIER NOT NULL,
  extra_json NVARCHAR(MAX)    NULL,
  CONSTRAINT PK_hlth_policy_ext PRIMARY KEY (policy_id)
);
GO
