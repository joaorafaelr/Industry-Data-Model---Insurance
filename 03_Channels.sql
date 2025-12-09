USE InsuranceData;
GO

/* Channels DDL (structure only, no guardrails)
   Note: depends on Products for FK to core.ref_product_family.
*/

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='cid') EXEC('CREATE SCHEMA cid');
GO

/* Reference: distribution channels */
IF OBJECT_ID('cid.cid_ch_ref_channel','U') IS NULL
CREATE TABLE cid.cid_ch_ref_channel (
  channel_code VARCHAR(40)   NOT NULL,
  channel_name NVARCHAR(200) NOT NULL,
  description  NVARCHAR(500) NULL,
  CONSTRAINT PK_cid_ch_ref_channel PRIMARY KEY CLUSTERED (channel_code)
);
GO

/* Reference: availability reasons */
IF OBJECT_ID('cid.cid_ch_ref_availability_reason','U') IS NULL
CREATE TABLE cid.cid_ch_ref_availability_reason (
  reason_code VARCHAR(40)   NOT NULL,
  reason_name NVARCHAR(200) NOT NULL,
  description NVARCHAR(500) NULL,
  CONSTRAINT PK_cid_ch_ref_avail_reason PRIMARY KEY CLUSTERED (reason_code)
);
GO

/* Reference: lifecycle stages */
IF OBJECT_ID('cid.cid_ch_ref_lifecycle_stage','U') IS NULL
CREATE TABLE cid.cid_ch_ref_lifecycle_stage (
  lifecycle_stage_code VARCHAR(40)   NOT NULL,
  lifecycle_stage_name NVARCHAR(200) NOT NULL,
  description          NVARCHAR(500) NULL,
  CONSTRAINT PK_cid_ch_ref_lifecycle_stage PRIMARY KEY CLUSTERED (lifecycle_stage_code)
);
GO

/* Channel master */
IF OBJECT_ID('cid.cid_ch_channel','U') IS NULL
CREATE TABLE cid.cid_ch_channel (
  channel_id   UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_ch_channel DEFAULT NEWID(),
  channel_code VARCHAR(40)      NOT NULL,
  channel_name NVARCHAR(200)    NULL,
  is_active    BIT              NOT NULL CONSTRAINT DF_cid_ch_channel_active DEFAULT(1),
  created_at   DATETIME2(6)     NOT NULL CONSTRAINT DF_cid_ch_channel_created DEFAULT SYSUTCDATETIME(),
  valid_from   DATETIME2(6)     NOT NULL CONSTRAINT DF_cid_ch_channel_valid_from DEFAULT SYSUTCDATETIME(),
  valid_to     DATETIME2(6)     NULL,
  owner_entity_id UNIQUEIDENTIFIER NULL,
  intermediary_id UNIQUEIDENTIFIER NULL,
  CONSTRAINT PK_cid_ch_channel PRIMARY KEY CLUSTERED (channel_id),
  CONSTRAINT CK_cid_ch_channel_range CHECK (valid_from < ISNULL(valid_to, CONVERT(DATETIME2(6), '9999-12-31 23:59:59.999999')))
);
GO

/* Channel availability matrix */
IF OBJECT_ID('cid.cid_ch_channel_availability','U') IS NULL
CREATE TABLE cid.cid_ch_channel_availability (
  availability_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_ch_avail DEFAULT NEWID(),
  channel_id           UNIQUEIDENTIFIER NOT NULL,
  product_family_code  VARCHAR(60)      NULL,
  country_code         CHAR(2)          NULL,
  jurisdiction_id      INT              NULL,
  lifecycle_stage_code VARCHAR(40)      NULL,
  reason_code          VARCHAR(40)      NULL,
  valid_from           DATETIME2(6)     NOT NULL,
  valid_to             DATETIME2(6)     NULL,
  CONSTRAINT PK_cid_ch_channel_availability PRIMARY KEY CLUSTERED (availability_id),
  CONSTRAINT CK_cid_ch_avail_range CHECK (valid_from < ISNULL(valid_to, CONVERT(DATETIME2(6), '9999-12-31 23:59:59.999999')))
);
GO

/* Channel governance */
IF OBJECT_ID('cid.cid_ch_channel_governance','U') IS NULL
CREATE TABLE cid.cid_ch_channel_governance (
  governance_id        UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_ch_gov DEFAULT NEWID(),
  channel_id           UNIQUEIDENTIFIER NOT NULL,
  lifecycle_stage_code VARCHAR(40)      NULL,
  approval_status      VARCHAR(30)      NULL,   -- free code
  risk_flag            BIT              NOT NULL CONSTRAINT DF_cid_ch_gov_risk DEFAULT(0),
  notes                NVARCHAR(1000)   NULL,
  valid_from           DATETIME2(6)     NOT NULL CONSTRAINT DF_cid_ch_gov_valid_from DEFAULT SYSUTCDATETIME(),
  valid_to             DATETIME2(6)     NULL,
  decision_ts          DATETIME2(6)     NULL,
  decided_by_entity_id UNIQUEIDENTIFIER NULL,
  decision_reason      NVARCHAR(500)    NULL,
  risk_code            VARCHAR(40)      NULL,
  CONSTRAINT PK_cid_ch_channel_governance PRIMARY KEY CLUSTERED (governance_id),
  CONSTRAINT CK_cid_ch_gov_range CHECK (valid_from < ISNULL(valid_to, CONVERT(DATETIME2(6), '9999-12-31 23:59:59.999999')))
);
GO

