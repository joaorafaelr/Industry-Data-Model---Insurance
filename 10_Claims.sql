/* ============================================================
   CLAIMS — PART 1 (BASE)
   Schemas + Tables only (PKs/defaults ok). No FKs/UNIQUE/IX here.
   ============================================================ */

/* core.core_claim_header */
IF OBJECT_ID('core.core_claim_header','U') IS NULL
CREATE TABLE core.core_claim_header (
  claim_id     UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_core_clm_id DEFAULT NEWID(),
  policy_id    UNIQUEIDENTIFIER NULL,
  lob_code     NVARCHAR(10)     NOT NULL,
  claim_number NVARCHAR(60)     NOT NULL,
  status_code  NVARCHAR(40)     NULL,
  reported_at  DATETIME2(6)     NULL, -- default added in Part 2; optional NOT NULL later
  loss_date    DATE             NULL,
  cause_code   NVARCHAR(40)     NULL,
  currency_code CHAR(3)         NULL,
  created_at   DATETIME2(6)     NOT NULL CONSTRAINT DF_core_clm_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_core_claim_header PRIMARY KEY (claim_id)
);
GO

/* core.core_claim_coverage */
IF OBJECT_ID('core.core_claim_coverage','U') IS NULL
CREATE TABLE core.core_claim_coverage (
  claim_coverage_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_core_clmcov_id DEFAULT NEWID(),
  claim_id          UNIQUEIDENTIFIER NOT NULL,
  coverage_code     NVARCHAR(60)     NULL,
  benefit_code      NVARCHAR(60)     NULL,
  incurred_amount   DECIMAL(19,4)    NULL,
  reserve_amount    DECIMAL(19,4)    NULL,
  paid_amount       DECIMAL(19,4)    NULL,
  currency_code     CHAR(3)          NULL,
  created_at        DATETIME2(6)     NOT NULL CONSTRAINT DF_core_clmcov_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_core_claim_coverage PRIMARY KEY (claim_coverage_id)
);
GO

/* core.core_claim_party_role */
IF OBJECT_ID('core.core_claim_party_role','U') IS NULL
CREATE TABLE core.core_claim_party_role (
  party_role_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_core_clmpr_id DEFAULT NEWID(),
  claim_id      UNIQUEIDENTIFIER NOT NULL,
  role_code     NVARCHAR(40)     NOT NULL,  -- INSURED, CLAIMANT, BROKER, etc.
  effective_from DATETIME2(6)    NULL,
  effective_to   DATETIME2(6)    NULL,
  created_at     DATETIME2(6)    NOT NULL CONSTRAINT DF_core_clmpr_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_core_claim_party_role PRIMARY KEY (party_role_id)
);
GO

/* core.core_claim_decision */
IF OBJECT_ID('core.core_claim_decision','U') IS NULL
CREATE TABLE core.core_claim_decision (
  decision_id  UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_core_clmdec_id DEFAULT NEWID(),
  claim_id     UNIQUEIDENTIFIER NOT NULL,
  decision_code NVARCHAR(40)    NOT NULL,   -- ACCEPTED, DENIED, PARTIAL, etc.
  decided_at   DATETIME2(6)     NOT NULL,
  notes        NVARCHAR(500)    NULL,
  created_at   DATETIME2(6)     NOT NULL CONSTRAINT DF_core_clmdec_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_core_claim_decision PRIMARY KEY (decision_id)
);
GO

/* core.core_claim_financial_head (anchored by (claim_id, head_code)) */
IF OBJECT_ID('core.core_claim_financial_head','U') IS NULL
CREATE TABLE core.core_claim_financial_head (
  claim_id   UNIQUEIDENTIFIER NOT NULL,
  head_code  NVARCHAR(40)     NOT NULL,   -- e.g., INDEMNITY, EXPENSE, RECOVERY
  head_name  NVARCHAR(200)    NULL,
  description NVARCHAR(500)   NULL,
  created_at DATETIME2(6)     NOT NULL CONSTRAINT DF_core_clmfh_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_core_claim_financial_head PRIMARY KEY (claim_id, head_code)
);
GO

/* core.core_claim_financial_movement */
IF OBJECT_ID('core.core_claim_financial_movement','U') IS NULL
CREATE TABLE core.core_claim_financial_movement (
  movement_id   UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_core_clmmov_id DEFAULT NEWID(),
  claim_id      UNIQUEIDENTIFIER NOT NULL,
  head_code     NVARCHAR(40)     NOT NULL,  -- aligns to head composite PK
  movement_type NVARCHAR(30)     NOT NULL,  -- RESERVE_SET, RELEASE, PAYMENT, RECOVERY
  amount        DECIMAL(19,4)    NOT NULL,
  movement_ts   DATETIME2(6)     NOT NULL CONSTRAINT DF_core_clmmov_ts DEFAULT SYSUTCDATETIME(),
  notes         NVARCHAR(500)    NULL,
  created_at    DATETIME2(6)     NOT NULL CONSTRAINT DF_core_clmmov_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_core_claim_financial_movement PRIMARY KEY (movement_id)
);
GO

/* core.core_claim_document_ref */
IF OBJECT_ID('core.core_claim_document_ref','U') IS NULL
CREATE TABLE core.core_claim_document_ref (
  doc_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_core_clmdoc_id DEFAULT NEWID(),
  claim_id    UNIQUEIDENTIFIER NOT NULL,
  doc_type_code NVARCHAR(40)   NULL,
  doc_uri     NVARCHAR(500)    NULL, -- bumped to 1000 in Part 2 if needed
  created_at  DATETIME2(6)     NOT NULL CONSTRAINT DF_core_clmdoc_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_core_claim_document_ref PRIMARY KEY (doc_id)
);
GO

/* core.core_claim_coverage_snapshot */
IF OBJECT_ID('core.core_claim_coverage_snapshot','U') IS NULL
CREATE TABLE core.core_claim_coverage_snapshot (
  snapshot_id  UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_core_clmcovsnap_id DEFAULT NEWID(),
  claim_id     UNIQUEIDENTIFIER NOT NULL,
  snapshot_tag NVARCHAR(60)     NOT NULL,   -- e.g., FNOL, POST_ADJ, SETTLEMENT
  coverage_json NVARCHAR(MAX)   NULL,       -- JSON; CK added in Part 2
  created_at   DATETIME2(6)     NOT NULL CONSTRAINT DF_core_clmcovsnap_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_core_claim_coverage_snapshot PRIMARY KEY (snapshot_id)
);
GO

/* LoB extensions — 1–1 with core_claim_header (FK in Part 2) */
IF OBJECT_ID('pc.pc_claim_ext','U') IS NULL
CREATE TABLE pc.pc_claim_ext (
  claim_id   UNIQUEIDENTIFIER NOT NULL,
  extra_json NVARCHAR(MAX)    NULL,
  CONSTRAINT PK_pc_claim_ext PRIMARY KEY (claim_id)
);
GO

IF OBJECT_ID('lp.lp_claim_ext','U') IS NULL
CREATE TABLE lp.lp_claim_ext (
  claim_id   UNIQUEIDENTIFIER NOT NULL,
  extra_json NVARCHAR(MAX)    NULL,
  CONSTRAINT PK_lp_claim_ext PRIMARY KEY (claim_id)
);
GO

IF OBJECT_ID('hlth.hlth_claim_ext','U') IS NULL
CREATE TABLE hlth.hlth_claim_ext (
  claim_id   UNIQUEIDENTIFIER NOT NULL,
  extra_json NVARCHAR(MAX)    NULL,
  CONSTRAINT PK_hlth_claim_ext PRIMARY KEY (claim_id)
);
GO
