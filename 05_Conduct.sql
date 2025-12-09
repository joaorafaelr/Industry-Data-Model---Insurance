USE InsuranceData;
GO

/* CID Conduct DDL (structure only, no guardrails) */
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='cid') EXEC('CREATE SCHEMA cid');
GO

/* Complaints */
IF OBJECT_ID('cid.cid_cond_complaint','U') IS NULL
CREATE TABLE cid.cid_cond_complaint (
  complaint_id    UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_cond_complaint DEFAULT NEWID(),
  entity_id       UNIQUEIDENTIFIER NOT NULL,  -- customer or complainant entity
  policy_id       UNIQUEIDENTIFIER NULL,
  channel_id      UNIQUEIDENTIFIER NULL,
  received_ts     DATETIME2(6)     NOT NULL CONSTRAINT DF_cid_cond_complaint_recv DEFAULT SYSUTCDATETIME(),
  description     NVARCHAR(MAX)    NULL,
  finding_code    VARCHAR(40)      NULL,
  remediation_text NVARCHAR(MAX)   NULL,
  remediation_ts  DATETIME2(6)     NULL,
  CONSTRAINT PK_cid_cond_complaint PRIMARY KEY CLUSTERED (complaint_id)
);
GO

/* Suitability assessments */
IF OBJECT_ID('cid.cid_cond_suitability','U') IS NULL
CREATE TABLE cid.cid_cond_suitability (
  suitability_id  UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_cond_suitability DEFAULT NEWID(),
  entity_id       UNIQUEIDENTIFIER NOT NULL,  -- customer
  intermediary_id UNIQUEIDENTIFIER NULL,      -- adviser/intermediary
  policy_id       UNIQUEIDENTIFIER NULL,
  assessed_ts     DATETIME2(6)     NOT NULL CONSTRAINT DF_cid_cond_suitability_ts DEFAULT SYSUTCDATETIME(),
  suitability_result VARCHAR(40)   NULL,      -- PASS/FAIL/CONDITIONAL (free code)
  rationale       NVARCHAR(MAX)    NULL,
  CONSTRAINT PK_cid_cond_suitability PRIMARY KEY CLUSTERED (suitability_id)
);
GO

/* Product governance (POG evidence) */
IF OBJECT_ID('cid.cid_cond_product_governance','U') IS NULL
CREATE TABLE cid.cid_cond_product_governance (
  pog_id            UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_cond_pog DEFAULT NEWID(),
  product_family_code VARCHAR(60)    NULL,    -- FK to core.ref_product_family
  policy_id         UNIQUEIDENTIFIER NULL,
  target_market_desc NVARCHAR(MAX)   NULL,
  review_date       DATE             NULL,
  test_results_json NVARCHAR(MAX)    NULL,
  CONSTRAINT PK_cid_cond_product_governance PRIMARY KEY CLUSTERED (pog_id)
);
GO

/* Evidence store */
IF OBJECT_ID('cid.cid_cond_evidence_store','U') IS NULL
CREATE TABLE cid.cid_cond_evidence_store (
  evidence_id   UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_cond_evidence DEFAULT NEWID(),
  related_table VARCHAR(128)     NULL,
  related_id    UNIQUEIDENTIFIER NULL,
  uploaded_ts   DATETIME2(6)     NOT NULL CONSTRAINT DF_cid_cond_evidence_ts DEFAULT SYSUTCDATETIME(),
  file_uri      NVARCHAR(1000)   NULL,
  hash_value    VARBINARY(64)    NULL,
  metadata_json NVARCHAR(MAX)    NULL,
  CONSTRAINT PK_cid_cond_evidence_store PRIMARY KEY CLUSTERED (evidence_id)
);
GO