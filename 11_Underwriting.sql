/* ============================================================
   UNDERWRITING — PART 1 (BASE)
   Tables ONLY (PKs, UNIQUEs, CHECKs, DEFAULTs) — NO FKs here
   ============================================================ */

/* ============================================================
   1) UNDERWRITING RULE VERSION CATALOG (no ref schema)
============================================================ */
IF OBJECT_ID('core.core_uw_rule_version','U') IS NULL
CREATE TABLE core.core_uw_rule_version (
  rule_version_id   UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_core_uw_rulev_id DEFAULT NEWID(),
  rule_code         NVARCHAR(60)     NOT NULL,
  version_number    INT              NOT NULL,
  description       NVARCHAR(500)    NULL,
  created_at        DATETIME2(6)     NOT NULL CONSTRAINT DF_core_uw_rulev_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_core_uw_rule_version PRIMARY KEY (rule_version_id),
  CONSTRAINT UQ_core_uw_rulev_code_ver UNIQUE (rule_code, version_number)
);
GO

/* ============================================================
   2) UW CASE (pivot)
============================================================ */
IF OBJECT_ID('core.core_uw_case','U') IS NULL
CREATE TABLE core.core_uw_case (
  uw_case_id           UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_core_uw_case_id DEFAULT NEWID(),
  proposer_entity_id   UNIQUEIDENTIFIER NULL,
  product_version_id   UNIQUEIDENTIFIER NULL,
  channel_code         NVARCHAR(40)     NULL,
  state_code           NVARCHAR(40)     NULL,
  lob_code             NVARCHAR(20)     NULL,
  created_at           DATETIME2(6)     NOT NULL CONSTRAINT DF_core_uw_case_created DEFAULT SYSUTCDATETIME(),
  updated_at           DATETIME2(6)     NULL,
  CONSTRAINT PK_core_uw_case PRIMARY KEY (uw_case_id),
  CONSTRAINT CK_core_uwcase_lob_whitelist CHECK (lob_code IS NULL OR lob_code IN (N'PC',N'LP',N'HLTH')),
  CONSTRAINT CK_core_uwcase_ts CHECK (updated_at IS NULL OR updated_at >= created_at)
);
GO

/* ============================================================
   3) UW CASE EVENTS (audit log)
============================================================ */
IF OBJECT_ID('core.core_uw_case_event','U') IS NULL
CREATE TABLE core.core_uw_case_event (
  event_id           UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_core_uwevt_id DEFAULT NEWID(),
  uw_case_id         UNIQUEIDENTIFIER NOT NULL,
  event_type         NVARCHAR(60)     NULL,
  event_payload_json NVARCHAR(MAX)    NULL,
  occurred_at        DATETIME2(6)     NOT NULL CONSTRAINT DF_core_uwevt_occurred DEFAULT SYSUTCDATETIME(),
  created_at         DATETIME2(6)     NOT NULL CONSTRAINT DF_core_uwevt_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_core_uw_case_event PRIMARY KEY (event_id),
  CONSTRAINT CK_core_uwevt_json CHECK (event_payload_json IS NULL OR ISJSON(event_payload_json)=1)
);
GO

/* ============================================================
   4) RULE OUTCOMES (per evaluated rule)
============================================================ */
IF OBJECT_ID('core.core_uw_rule_outcome','U') IS NULL
CREATE TABLE core.core_uw_rule_outcome (
  rule_outcome_id  UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_core_uwro_id DEFAULT NEWID(),
  uw_case_id       UNIQUEIDENTIFIER NOT NULL,
  rule_version_id  UNIQUEIDENTIFIER NOT NULL,
  outcome_code     NVARCHAR(40)     NOT NULL,
  details_json     NVARCHAR(MAX)    NULL,
  created_at       DATETIME2(6)     NOT NULL CONSTRAINT DF_core_uwro_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_core_uw_rule_outcome PRIMARY KEY (rule_outcome_id),
  CONSTRAINT UQ_core_uwro_case_rulev UNIQUE (uw_case_id, rule_version_id),
  CONSTRAINT CK_core_uwro_outcome_whitelist CHECK (outcome_code IN (N'PASS',N'FAIL',N'REFER')),
  CONSTRAINT CK_core_uwro_details_json CHECK (details_json IS NULL OR ISJSON(details_json)=1)
);
GO

/* ============================================================
   5) UW EVIDENCE (reference-only, no PHI)
============================================================ */
IF OBJECT_ID('core.core_uw_evidence','U') IS NULL
CREATE TABLE core.core_uw_evidence (
  evidence_id       UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_core_uwevd_id DEFAULT NEWID(),
  uw_case_id        UNIQUEIDENTIFIER NOT NULL,
  evidence_type     NVARCHAR(60)     NULL,
  evidence_uri      NVARCHAR(1000)   NULL,
  created_at        DATETIME2(6)     NOT NULL CONSTRAINT DF_core_uwevd_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_core_uw_evidence PRIMARY KEY (evidence_id)
);
GO

/* ============================================================
   6) FINAL UW DECISION (1–1 with case)
============================================================ */
IF OBJECT_ID('core.core_uw_decision','U') IS NULL
CREATE TABLE core.core_uw_decision (
  uw_case_id       UNIQUEIDENTIFIER NOT NULL,
  decision_code    NVARCHAR(40)     NOT NULL,
  conditions_json  NVARCHAR(MAX)    NULL,
  created_at       DATETIME2(6)     NOT NULL CONSTRAINT DF_core_uwdec_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_core_uw_decision PRIMARY KEY (uw_case_id),
  CONSTRAINT CK_core_uwdec_code_whitelist CHECK (decision_code IN (N'ACCEPT',N'DECLINE',N'POSTPONE')),
  CONSTRAINT CK_core_uwdec_conditions_json CHECK (conditions_json IS NULL OR ISJSON(conditions_json)=1)
);
GO

/* ============================================================
   7) PC EXTENSION
============================================================ */
IF OBJECT_ID('pc.pc_uw_case_ext','U') IS NULL
CREATE TABLE pc.pc_uw_case_ext (
  uw_case_id           UNIQUEIDENTIFIER NOT NULL,
  vehicle_data_json    NVARCHAR(MAX)    NULL,
  property_data_json   NVARCHAR(MAX)    NULL,
  liability_data_json  NVARCHAR(MAX)    NULL,
  CONSTRAINT PK_pc_uw_case_ext PRIMARY KEY (uw_case_id),
  CONSTRAINT CK_pc_uwext_vehicle_json   CHECK (vehicle_data_json   IS NULL OR ISJSON(vehicle_data_json)=1),
  CONSTRAINT CK_pc_uwext_property_json  CHECK (property_data_json  IS NULL OR ISJSON(property_data_json)=1),
  CONSTRAINT CK_pc_uwext_liability_json CHECK (liability_data_json IS NULL OR ISJSON(liability_data_json)=1)
);
GO

/* ============================================================
   8) LIFE EXTENSION
============================================================ */
IF OBJECT_ID('lp.lp_uw_case_ext','U') IS NULL
CREATE TABLE lp.lp_uw_case_ext (
  uw_case_id            UNIQUEIDENTIFIER NOT NULL,
  smoker_flag           CHAR(1)          NULL,
  occupation_class_code NVARCHAR(40)     NULL,
  medical_factors_json  NVARCHAR(MAX)    NULL,
  CONSTRAINT PK_lp_uw_case_ext PRIMARY KEY (uw_case_id),
  CONSTRAINT CK_lp_uwext_smoker_flag CHECK (smoker_flag IS NULL OR smoker_flag IN ('Y','N')),
  CONSTRAINT CK_lp_uwext_med_json    CHECK (medical_factors_json IS NULL OR ISJSON(medical_factors_json)=1)
);
GO

/* ============================================================
   9) HEALTH EXTENSION
============================================================ */
IF OBJECT_ID('hlth.hlth_uw_case_ext','U') IS NULL
CREATE TABLE hlth.hlth_uw_case_ext (
  uw_case_id                UNIQUEIDENTIFIER NOT NULL,
  network_eligibility_code  NVARCHAR(40)     NULL,
  medical_questionnaire_ref NVARCHAR(200)    NULL,
  health_metadata_json      NVARCHAR(MAX)    NULL,
  CONSTRAINT PK_hlth_uw_case_ext PRIMARY KEY (uw_case_id),
  CONSTRAINT CK_hlth_uwext_json CHECK (health_metadata_json IS NULL OR ISJSON(health_metadata_json)=1)
);
GO
