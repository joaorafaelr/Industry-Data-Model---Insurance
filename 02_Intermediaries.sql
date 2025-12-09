USE InsuranceData;
GO

/* ============================================================
   9) CID - Intermediaries (catalogs, masters, ops)
   ============================================================ */
IF OBJECT_ID('cid.cid_int_ref_jurisdiction','U') IS NULL
CREATE TABLE cid.cid_int_ref_jurisdiction (
  jurisdiction_id   INT IDENTITY(1,1) NOT NULL,
  jurisdiction_code VARCHAR(16) NOT NULL,  -- PT, ES, EU-EEA, GB-FCA
  jurisdiction_name NVARCHAR(120) NOT NULL,
  CONSTRAINT PK_cid_jurisdiction PRIMARY KEY (jurisdiction_id),
  CONSTRAINT UX_cid_jurisdiction_code UNIQUE (jurisdiction_code)
);
GO

IF OBJECT_ID('cid.cid_int_ref_lob_scope','U') IS NULL
CREATE TABLE cid.cid_int_ref_lob_scope (
  lob_scope_code VARCHAR(16) NOT NULL,   -- PC, LP, HLTH, MULTI
  lob_scope_name NVARCHAR(100) NULL,
  CONSTRAINT PK_cid_lob_scope PRIMARY KEY (lob_scope_code)
);
GO

IF OBJECT_ID('cid.cid_int_ref_appointment_type','U') IS NULL
CREATE TABLE cid.cid_int_ref_appointment_type (
  appointment_type_id INT IDENTITY(1,1) NOT NULL,
  type_code           VARCHAR(40) NOT NULL,  -- BROKER, AGENT_TIED, MGA, ...
  type_name           NVARCHAR(120) NULL,
  CONSTRAINT PK_cid_appt_type PRIMARY KEY (appointment_type_id),
  CONSTRAINT UX_cid_appt_type_code UNIQUE (type_code)
);
GO

IF OBJECT_ID('cid.cid_int_intermediary','U') IS NULL
CREATE TABLE cid.cid_int_intermediary (
  intermediary_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_int_intermediary DEFAULT NEWID(),
  entity_id       UNIQUEIDENTIFIER NOT NULL,   -- must be ORGANIZATION
  active_flag     BIT NOT NULL CONSTRAINT DF_cid_int_active DEFAULT(1),
  home_country_code CHAR(2)       NULL,
  regulator_ref   VARCHAR(60)     NULL,
  CONSTRAINT PK_cid_int_intermediary PRIMARY KEY (intermediary_id)
);
GO

IF OBJECT_ID('cid.cid_int_intermediary_source_key','U') IS NULL
CREATE TABLE cid.cid_int_intermediary_source_key (
  intermediary_source_key_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_isk DEFAULT NEWID(),
  intermediary_id    UNIQUEIDENTIFIER NOT NULL,
  source_system_code VARCHAR(60)      NOT NULL,
  external_key       NVARCHAR(200)    NOT NULL,
  status_code        VARCHAR(30)      NULL,
  link_confidence_pct DECIMAL(5,2)    NULL,
  CONSTRAINT PK_cid_int_intermediary_source_key PRIMARY KEY (intermediary_source_key_id)
);
GO

IF OBJECT_ID('cid.cid_int_intermediary_rep','U') IS NULL
CREATE TABLE cid.cid_int_intermediary_rep (
  intermediary_rep_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_rep DEFAULT NEWID(),
  intermediary_id     UNIQUEIDENTIFIER NOT NULL,
  person_entity_id    UNIQUEIDENTIFIER NOT NULL,
  rep_role_code       VARCHAR(60)      NOT NULL,   -- validated against core.role_ref (ENTERPRISE) externally
  valid_from          DATETIME2(6)     NOT NULL,
  valid_to            DATETIME2(6)     NULL,
  CONSTRAINT PK_cid_int_intermediary_rep PRIMARY KEY (intermediary_rep_id),
  CONSTRAINT CK_cid_rep_range CHECK (valid_from < ISNULL(valid_to, core.fn_highdate()))
);
GO

IF OBJECT_ID('cid.cid_int_intermediary_license','U') IS NULL
CREATE TABLE cid.cid_int_intermediary_license (
  license_id         UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_license DEFAULT NEWID(),
  intermediary_id    UNIQUEIDENTIFIER NOT NULL,
  jurisdiction_id    INT              NOT NULL,
  license_class_code VARCHAR(50)      NOT NULL,
  lob_scope_code     VARCHAR(16)      NULL,
  license_number     NVARCHAR(120)    NULL,
  valid_from         DATETIME2(6)     NOT NULL,
  valid_to           DATETIME2(6)     NULL,
  /* Computed column to normalize NULL for unique filter (no guardrails here) */
  license_number_nn  AS ISNULL(license_number,'') PERSISTED,
  CONSTRAINT PK_cid_int_intermediary_license PRIMARY KEY (license_id),
  CONSTRAINT CK_cid_license_range CHECK (valid_from < ISNULL(valid_to, core.fn_highdate()))
);
GO

IF OBJECT_ID('cid.cid_int_appointment','U') IS NULL
CREATE TABLE cid.cid_int_appointment (
  appointment_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_appt DEFAULT NEWID(),
  intermediary_id     UNIQUEIDENTIFIER NOT NULL,
  insurer_entity_id   UNIQUEIDENTIFIER NOT NULL,  -- insurer as entity
  appointment_type_id INT              NOT NULL,
  license_id          UNIQUEIDENTIFIER NOT NULL,  -- containment check vs license
  valid_from          DATETIME2(6)     NOT NULL,
  valid_to            DATETIME2(6)     NULL,
  CONSTRAINT PK_cid_int_appointment PRIMARY KEY (appointment_id),
  CONSTRAINT CK_cid_appt_range CHECK (valid_from < ISNULL(valid_to, core.fn_highdate()))
);
GO

IF OBJECT_ID('cid.cid_int_fit_proper','U') IS NULL
CREATE TABLE cid.cid_int_fit_proper (
  fitproper_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_fp DEFAULT NEWID(),
  subject_entity_id UNIQUEIDENTIFIER NOT NULL,
  regime_code       VARCHAR(50)      NOT NULL,   -- free code (no FK per requirements)
  result_code       VARCHAR(30)      NULL,    -- PASS/FAIL/PENDING
  evidence_uri      NVARCHAR(500)    NULL,
  valid_from        DATETIME2(6)     NOT NULL,
  valid_to          DATETIME2(6)     NULL,
  CONSTRAINT PK_cid_int_fit_proper PRIMARY KEY (fitproper_id),
  CONSTRAINT CK_cid_fp_range CHECK (valid_from < ISNULL(valid_to, core.fn_highdate()))
);
GO

IF OBJECT_ID('cid.cid_int_ref_remuneration_component','U') IS NULL
CREATE TABLE cid.cid_int_ref_remuneration_component (
  component_code VARCHAR(40)   NOT NULL,  -- COMMISSION_NEW, FEE_PCT, BONUS_TIERED, ...
  component_name NVARCHAR(200) NULL,
  CONSTRAINT PK_cid_ref_rem_component PRIMARY KEY (component_code)
);
GO

IF OBJECT_ID('cid.cid_int_remuneration_template','U') IS NULL
CREATE TABLE cid.cid_int_remuneration_template (
  template_id     UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_remtpl DEFAULT NEWID(),
  template_name   NVARCHAR(200)    NOT NULL,
  definition_json NVARCHAR(MAX)    NOT NULL,  -- tiering/components metadata
  version_no      INT              NOT NULL CONSTRAINT DF_cid_remtpl_ver DEFAULT(1),
  is_active       BIT              NOT NULL CONSTRAINT DF_cid_remtpl_active DEFAULT(1),
  CONSTRAINT PK_cid_int_remuneration_template PRIMARY KEY (template_id)
);
GO
ALTER TABLE cid.cid_int_remuneration_template
  ADD CONSTRAINT CK_cid_remtpl_json CHECK (ISJSON(definition_json) = 1);
GO

IF OBJECT_ID('cid.cid_int_remuneration_assignment','U') IS NULL
CREATE TABLE cid.cid_int_remuneration_assignment (
  rem_assignment_id     UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_remas DEFAULT NEWID(),
  entity_policy_role_id UNIQUEIDENTIFIER NOT NULL,  -- FK to PPR
  template_id           UNIQUEIDENTIFIER NULL,      -- optional
  currency_code         CHAR(3)          NULL,      -- free code (no FK per requirements)
  amount_type_code      VARCHAR(30)      NULL,      -- free code (no FK per requirements)
  valid_from            DATETIME2(6)     NOT NULL,
  valid_to              DATETIME2(6)     NULL,
  CONSTRAINT PK_cid_int_remas PRIMARY KEY (rem_assignment_id),
  CONSTRAINT CK_cid_remas_range CHECK (valid_from < ISNULL(valid_to, core.fn_highdate()))
);
GO

IF OBJECT_ID('cid.cid_int_broker_of_record_change','U') IS NULL
CREATE TABLE cid.cid_int_broker_of_record_change (
  bor_change_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_bor DEFAULT NEWID(),
  from_ppr_id   UNIQUEIDENTIFIER NULL,
  to_ppr_id     UNIQUEIDENTIFIER NOT NULL,
  change_ts     DATETIME2(6)     NOT NULL CONSTRAINT DF_cid_bor_ts DEFAULT SYSUTCDATETIME(),
  reason_code   VARCHAR(50)      NULL,
  evidence_uri  NVARCHAR(500)    NULL,
  CONSTRAINT PK_cid_bor PRIMARY KEY (bor_change_id)
);
GO

/* ============================================================
   10) CID - Channel membership (links to Channels DDL)
   ============================================================ */
IF OBJECT_ID('cid.cid_ch_channel_membership','U') IS NULL
CREATE TABLE cid.cid_ch_channel_membership (
  channel_membership_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_ch_mem DEFAULT NEWID(),
  channel_id            UNIQUEIDENTIFIER NOT NULL,
  entity_id             UNIQUEIDENTIFIER NOT NULL,
  valid_from            DATETIME2(6)     NOT NULL,
  valid_to              DATETIME2(6)     NULL,
  CONSTRAINT PK_cid_ch_channel_membership PRIMARY KEY CLUSTERED (channel_membership_id),
  -- channel FK added in Channels.sql after cid.cid_ch_channel is created
  CONSTRAINT CK_cid_ch_mem_range CHECK (valid_from < ISNULL(valid_to, core.fn_highdate()))
);
GO