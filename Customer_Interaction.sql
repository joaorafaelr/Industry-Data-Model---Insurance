/* CID Customer Interaction & Engagement DDL (structure only, no guardrails) */
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='cid') EXEC('CREATE SCHEMA cid');
GO

/* ===========================
   CORE — Digital Profile
   =========================== */

IF OBJECT_ID('core.ref_digital_segment','U') IS NULL
CREATE TABLE core.ref_digital_segment (
  digital_segment_code VARCHAR(40)   NOT NULL,     -- e.g., HIGH, MEDIUM, LOW, OFFLINE
  digital_segment_name NVARCHAR(200) NOT NULL,
  description          NVARCHAR(500) NULL,
  CONSTRAINT PK_ref_digital_segment PRIMARY KEY (digital_segment_code)
);
GO

IF OBJECT_ID('core.entity_digital_profile','U') IS NULL
CREATE TABLE core.entity_digital_profile (
  entity_digital_profile_id UNIQUEIDENTIFIER NOT NULL
    CONSTRAINT DF_entity_digprof_id DEFAULT NEWID(),

  /* Anchor */
  entity_id         UNIQUEIDENTIFIER NOT NULL,

  /* Core derived attributes (keep minimal & transversal) */
  is_app_user        BIT             NOT NULL CONSTRAINT DF_edp_app DEFAULT(0),
  is_web_portal_user BIT             NOT NULL CONSTRAINT DF_edp_web DEFAULT(0),
  has_paperless      BIT             NOT NULL CONSTRAINT DF_edp_paperless DEFAULT(0),
  has_direct_debit   BIT             NOT NULL CONSTRAINT DF_edp_dd DEFAULT(0),
  push_opt_in        BIT             NOT NULL CONSTRAINT DF_edp_push DEFAULT(0),
  email_opt_in       BIT             NOT NULL CONSTRAINT DF_edp_email DEFAULT(0),
  sms_opt_in         BIT             NOT NULL CONSTRAINT DF_edp_sms DEFAULT(0),

  /* Activity signals (summaries) */
  last_login_ts      DATETIME2(6)    NULL,
  app_install_ts     DATETIME2(6)    NULL,
  app_last_active_ts DATETIME2(6)    NULL,
  login_count_12m    INT             NULL,

  /* Scoring / segmentation */
  digital_score      DECIMAL(6,2)    NULL,         -- 0..100 or model-specific
  digital_segment_code VARCHAR(40)   NULL,         -- FK to ref_digital_segment

  /* Lineage */
  source_system_code VARCHAR(60)     NULL,
  updated_ts         DATETIME2(6)    NOT NULL
    CONSTRAINT DF_edp_updated DEFAULT SYSUTCDATETIME(),

  /* Effective dating */
  valid_from         DATETIME2(6)    NOT NULL,
  valid_to           DATETIME2(6)    NULL,

  CONSTRAINT PK_entity_digital_profile
    PRIMARY KEY CLUSTERED (entity_digital_profile_id),

  /* Base relationships (hard FKs belong in Base) */
  CONSTRAINT FK_edp_entity
    FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id),

  CONSTRAINT FK_edp_segment
    FOREIGN KEY (digital_segment_code) REFERENCES core.ref_digital_segment(digital_segment_code),

  /* Range sanity in Base; no-overlap uniqueness will live in Guardrails */
  CONSTRAINT CK_edp_range
    CHECK (valid_from < ISNULL(valid_to, core.fn_highdate()))
);
GO

/* Reference catalogs */
IF OBJECT_ID('cid.cid_ci_ref_interaction_type','U') IS NULL
CREATE TABLE cid.cid_ci_ref_interaction_type (
  interaction_type_code VARCHAR(60)   NOT NULL,
  interaction_type_name NVARCHAR(200) NOT NULL,
  description           NVARCHAR(500) NULL,
  CONSTRAINT PK_cid_ci_ref_interaction_type PRIMARY KEY CLUSTERED (interaction_type_code)
);
GO

IF OBJECT_ID('cid.cid_ci_ref_campaign_type','U') IS NULL
CREATE TABLE cid.cid_ci_ref_campaign_type (
  campaign_type_code VARCHAR(60)   NOT NULL,
  campaign_type_name NVARCHAR(200) NOT NULL,
  description        NVARCHAR(500) NULL,
  CONSTRAINT PK_cid_ci_ref_campaign_type PRIMARY KEY CLUSTERED (campaign_type_code)
);
GO

IF OBJECT_ID('cid.cid_ci_ref_event_type','U') IS NULL
CREATE TABLE cid.cid_ci_ref_event_type (
  event_type_code VARCHAR(60)   NOT NULL,
  event_type_name NVARCHAR(200) NOT NULL,
  description     NVARCHAR(500) NULL,
  CONSTRAINT PK_cid_ci_ref_event_type PRIMARY KEY CLUSTERED (event_type_code)
);
GO

IF OBJECT_ID('cid.cid_ci_ref_survey_type','U') IS NULL
CREATE TABLE cid.cid_ci_ref_survey_type (
  survey_type_code VARCHAR(60)   NOT NULL,
  survey_type_name NVARCHAR(200) NOT NULL,
  description      NVARCHAR(500) NULL,
  CONSTRAINT PK_cid_ci_ref_survey_type PRIMARY KEY CLUSTERED (survey_type_code)
);
GO

IF OBJECT_ID('cid.cid_ci_ref_direction','U') IS NULL
CREATE TABLE cid.cid_ci_ref_direction (
  direction_code VARCHAR(40)   NOT NULL,
  direction_name NVARCHAR(200) NOT NULL,
  CONSTRAINT PK_cid_ci_ref_direction PRIMARY KEY CLUSTERED (direction_code)
);
GO

IF OBJECT_ID('cid.cid_ci_ref_medium','U') IS NULL
CREATE TABLE cid.cid_ci_ref_medium (
  medium_code VARCHAR(40)   NOT NULL,
  medium_name NVARCHAR(200) NOT NULL,
  CONSTRAINT PK_cid_ci_ref_medium PRIMARY KEY CLUSTERED (medium_code)
);
GO

IF OBJECT_ID('cid.cid_ci_ref_outcome','U') IS NULL
CREATE TABLE cid.cid_ci_ref_outcome (
  outcome_code VARCHAR(60)   NOT NULL,
  outcome_name NVARCHAR(200) NOT NULL,
  CONSTRAINT PK_cid_ci_ref_outcome PRIMARY KEY CLUSTERED (outcome_code)
);
GO

IF OBJECT_ID('cid.cid_ci_ref_source','U') IS NULL
CREATE TABLE cid.cid_ci_ref_source (
  source_code VARCHAR(60)   NOT NULL,
  source_name NVARCHAR(200) NOT NULL,
  CONSTRAINT PK_cid_ci_ref_source PRIMARY KEY CLUSTERED (source_code)
);
GO

IF OBJECT_ID('cid.cid_ci_ref_lost_reason','U') IS NULL
CREATE TABLE cid.cid_ci_ref_lost_reason (
  lost_reason_code VARCHAR(60)   NOT NULL,
  lost_reason_name NVARCHAR(200) NOT NULL,
  CONSTRAINT PK_cid_ci_ref_lost_reason PRIMARY KEY CLUSTERED (lost_reason_code)
);
GO

IF OBJECT_ID('cid.cid_ci_ref_objective','U') IS NULL
CREATE TABLE cid.cid_ci_ref_objective (
  objective_code VARCHAR(60)   NOT NULL,
  objective_name NVARCHAR(200) NOT NULL,
  CONSTRAINT PK_cid_ci_ref_objective PRIMARY KEY CLUSTERED (objective_code)
);
GO

/* Journey stage */
IF OBJECT_ID('cid.cid_ci_journey_stage','U') IS NULL
CREATE TABLE cid.cid_ci_journey_stage (
  stage_code VARCHAR(60)   NOT NULL,
  stage_name NVARCHAR(200) NOT NULL,
  description NVARCHAR(500) NULL,
  CONSTRAINT PK_cid_ci_journey_stage PRIMARY KEY CLUSTERED (stage_code)
);
GO

/* Campaigns */
IF OBJECT_ID('cid.cid_ci_campaign','U') IS NULL
CREATE TABLE cid.cid_ci_campaign (
  campaign_id       UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_ci_campaign DEFAULT NEWID(),
  campaign_type_code VARCHAR(60)     NOT NULL,
  campaign_name     NVARCHAR(200)    NOT NULL,
  start_date        DATETIME2(6)     NULL,
  end_date          DATETIME2(6)     NULL,
  owner_entity_id   UNIQUEIDENTIFIER NULL,
  primary_channel_id UNIQUEIDENTIFIER NULL,
  budget_amount     DECIMAL(18,2)    NULL,
  budget_currency   CHAR(3)          NULL,
  objective_code    VARCHAR(60)      NULL,
  CONSTRAINT PK_cid_ci_campaign PRIMARY KEY CLUSTERED (campaign_id),
  CONSTRAINT FK_cid_ci_campaign_type FOREIGN KEY (campaign_type_code) REFERENCES cid.cid_ci_ref_campaign_type(campaign_type_code),
  CONSTRAINT FK_cid_ci_campaign_owner FOREIGN KEY (owner_entity_id) REFERENCES core.entity(entity_id),
  CONSTRAINT FK_cid_ci_campaign_channel FOREIGN KEY (primary_channel_id) REFERENCES cid.cid_ch_channel(channel_id),
  CONSTRAINT FK_cid_ci_campaign_objective FOREIGN KEY (objective_code) REFERENCES cid.cid_ci_ref_objective(objective_code)
);
GO

IF OBJECT_ID('cid.cid_ci_campaign_membership','U') IS NULL
CREATE TABLE cid.cid_ci_campaign_membership (
  membership_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_ci_camp_mem DEFAULT NEWID(),
  campaign_id   UNIQUEIDENTIFIER NOT NULL,
  entity_id     UNIQUEIDENTIFIER NOT NULL,
  joined_ts     DATETIME2(6)     NOT NULL CONSTRAINT DF_cid_ci_camp_joined DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_cid_ci_campaign_membership PRIMARY KEY CLUSTERED (membership_id),
  CONSTRAINT FK_cid_ci_campmem_campaign FOREIGN KEY (campaign_id) REFERENCES cid.cid_ci_campaign(campaign_id),
  CONSTRAINT FK_cid_ci_campmem_entity   FOREIGN KEY (entity_id)   REFERENCES core.entity(entity_id)
);
GO

IF OBJECT_ID('cid.cid_ci_campaign_outcome','U') IS NULL
CREATE TABLE cid.cid_ci_campaign_outcome (
  outcome_id   UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_ci_camp_out DEFAULT NEWID(),
  campaign_id  UNIQUEIDENTIFIER NOT NULL,
  entity_id    UNIQUEIDENTIFIER NOT NULL,
  outcome_code VARCHAR(60)      NULL,
  outcome_ts   DATETIME2(6)     NOT NULL CONSTRAINT DF_cid_ci_camp_out_ts DEFAULT SYSUTCDATETIME(),
  notes        NVARCHAR(500)    NULL,
  CONSTRAINT PK_cid_ci_campaign_outcome PRIMARY KEY CLUSTERED (outcome_id),
  CONSTRAINT FK_cid_ci_camp_out_campaign FOREIGN KEY (campaign_id) REFERENCES cid.cid_ci_campaign(campaign_id),
  CONSTRAINT FK_cid_ci_camp_out_entity   FOREIGN KEY (entity_id)   REFERENCES core.entity(entity_id),
  CONSTRAINT FK_cid_ci_camp_out_outcome FOREIGN KEY (outcome_code) REFERENCES cid.cid_ci_ref_outcome(outcome_code)
);
GO

/* Leads and opportunities */
IF OBJECT_ID('cid.cid_ci_lead','U') IS NULL
CREATE TABLE cid.cid_ci_lead (
  lead_id             UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_ci_lead DEFAULT NEWID(),
  prospect_entity_id  UNIQUEIDENTIFIER NOT NULL,
  campaign_id         UNIQUEIDENTIFIER NULL,
  created_ts          DATETIME2(6)     NOT NULL CONSTRAINT DF_cid_ci_lead_created DEFAULT SYSUTCDATETIME(),
  status_code         VARCHAR(40)      NULL,
  details             NVARCHAR(MAX)    NULL,
  owner_entity_id     UNIQUEIDENTIFIER NULL,
  source_code         VARCHAR(60)      NULL,
  CONSTRAINT PK_cid_ci_lead PRIMARY KEY CLUSTERED (lead_id),
  CONSTRAINT FK_cid_ci_lead_entity   FOREIGN KEY (prospect_entity_id) REFERENCES core.entity(entity_id),
  CONSTRAINT FK_cid_ci_lead_campaign FOREIGN KEY (campaign_id) REFERENCES cid.cid_ci_campaign(campaign_id),
  CONSTRAINT FK_cid_ci_lead_owner    FOREIGN KEY (owner_entity_id) REFERENCES core.entity(entity_id),
  CONSTRAINT FK_cid_ci_lead_source   FOREIGN KEY (source_code) REFERENCES cid.cid_ci_ref_source(source_code)
);
GO

IF OBJECT_ID('cid.cid_ci_opportunity','U') IS NULL
CREATE TABLE cid.cid_ci_opportunity (
  opportunity_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_ci_opp DEFAULT NEWID(),
  lead_id             UNIQUEIDENTIFIER NULL,
  prospect_entity_id  UNIQUEIDENTIFIER NOT NULL,
  stage_code          VARCHAR(60)      NULL,   -- journey stage
  expected_value      DECIMAL(18,2)    NULL,
  probability_pct     DECIMAL(5,2)     NULL,   -- 0..100
  status_code         VARCHAR(40)      NULL,
  owner_entity_id     UNIQUEIDENTIFIER NULL,
  source_code         VARCHAR(60)      NULL,
  currency_code       CHAR(3)          NULL,
  expected_close_ts   DATETIME2(6)     NULL,
  closed_ts           DATETIME2(6)     NULL,
  lost_reason_code    VARCHAR(60)      NULL,
  CONSTRAINT PK_cid_ci_opportunity PRIMARY KEY CLUSTERED (opportunity_id),
  CONSTRAINT FK_cid_ci_opp_lead    FOREIGN KEY (lead_id)            REFERENCES cid.cid_ci_lead(lead_id),
  CONSTRAINT FK_cid_ci_opp_entity  FOREIGN KEY (prospect_entity_id) REFERENCES core.entity(entity_id),
  CONSTRAINT FK_cid_ci_opp_stage   FOREIGN KEY (stage_code)         REFERENCES cid.cid_ci_journey_stage(stage_code),
  CONSTRAINT FK_cid_ci_opp_owner   FOREIGN KEY (owner_entity_id)    REFERENCES core.entity(entity_id),
  CONSTRAINT FK_cid_ci_opp_source  FOREIGN KEY (source_code)        REFERENCES cid.cid_ci_ref_source(source_code),
  CONSTRAINT FK_cid_ci_opp_lost_reason FOREIGN KEY (lost_reason_code) REFERENCES cid.cid_ci_ref_lost_reason(lost_reason_code)
);
GO

/* Signals and interactions */
IF OBJECT_ID('cid.cid_ci_signal','U') IS NULL
CREATE TABLE cid.cid_ci_signal (
  signal_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_ci_signal DEFAULT NEWID(),
  entity_id      UNIQUEIDENTIFIER NOT NULL,
  event_type_code VARCHAR(60)     NULL,
  signal_ts      DATETIME2(6)     NOT NULL CONSTRAINT DF_cid_ci_signal_ts DEFAULT SYSUTCDATETIME(),
  payload_json   NVARCHAR(MAX)    NULL,
  CONSTRAINT PK_cid_ci_signal PRIMARY KEY CLUSTERED (signal_id),
  CONSTRAINT FK_cid_ci_signal_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id),
  CONSTRAINT FK_cid_ci_signal_event  FOREIGN KEY (event_type_code) REFERENCES cid.cid_ci_ref_event_type(event_type_code)
);
GO

IF OBJECT_ID('cid.cid_ci_interaction','U') IS NULL
CREATE TABLE cid.cid_ci_interaction (
  interaction_id        UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_ci_interaction DEFAULT NEWID(),
  entity_id             UNIQUEIDENTIFIER NOT NULL,
  interaction_type_code VARCHAR(60)      NOT NULL,
  interaction_ts        DATETIME2(6)     NOT NULL CONSTRAINT DF_cid_ci_interaction_ts DEFAULT SYSUTCDATETIME(),
  subject               NVARCHAR(200)    NULL,
  notes                 NVARCHAR(MAX)    NULL,
  actor_entity_id       UNIQUEIDENTIFIER NULL,
  direction_code        VARCHAR(40)      NULL,
  medium_code           VARCHAR(40)      NULL,
  duration_sec          INT              NULL,
  outcome_code          VARCHAR(60)      NULL,
  policy_id             UNIQUEIDENTIFIER NULL,
  channel_id            UNIQUEIDENTIFIER NULL,
  campaign_id           UNIQUEIDENTIFIER NULL,
  CONSTRAINT PK_cid_ci_interaction PRIMARY KEY CLUSTERED (interaction_id),
  CONSTRAINT FK_cid_ci_interaction_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id),
  CONSTRAINT FK_cid_ci_interaction_type   FOREIGN KEY (interaction_type_code) REFERENCES cid.cid_ci_ref_interaction_type(interaction_type_code),
  CONSTRAINT FK_cid_ci_interaction_actor  FOREIGN KEY (actor_entity_id) REFERENCES core.entity(entity_id),
  CONSTRAINT FK_cid_ci_interaction_direction FOREIGN KEY (direction_code) REFERENCES cid.cid_ci_ref_direction(direction_code),
  CONSTRAINT FK_cid_ci_interaction_medium FOREIGN KEY (medium_code) REFERENCES cid.cid_ci_ref_medium(medium_code),
  CONSTRAINT FK_cid_ci_interaction_outcome FOREIGN KEY (outcome_code) REFERENCES cid.cid_ci_ref_outcome(outcome_code),
  CONSTRAINT FK_cid_ci_interaction_policy FOREIGN KEY (policy_id) REFERENCES core.policy(policy_id),
  CONSTRAINT FK_cid_ci_interaction_channel FOREIGN KEY (channel_id) REFERENCES cid.cid_ch_channel(channel_id),
  CONSTRAINT FK_cid_ci_interaction_campaign FOREIGN KEY (campaign_id) REFERENCES cid.cid_ci_campaign(campaign_id)
);
GO

/* Canonical event */
IF OBJECT_ID('cid.cid_ci_event','U') IS NULL
CREATE TABLE cid.cid_ci_event (
  event_id       UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_ci_event DEFAULT NEWID(),
  entity_id      UNIQUEIDENTIFIER NOT NULL,
  event_type_code VARCHAR(60)     NOT NULL,
  event_ts       DATETIME2(6)     NOT NULL CONSTRAINT DF_cid_ci_event_ts DEFAULT SYSUTCDATETIME(),
  source_system_code VARCHAR(60)  NULL,
  payload_json   NVARCHAR(MAX)    NULL,
  campaign_id    UNIQUEIDENTIFIER NULL,
  interaction_id UNIQUEIDENTIFIER NULL,
  lead_id        UNIQUEIDENTIFIER NULL,
  opportunity_id UNIQUEIDENTIFIER NULL,
  policy_id      UNIQUEIDENTIFIER NULL,
  channel_id     UNIQUEIDENTIFIER NULL,
  CONSTRAINT PK_cid_ci_event PRIMARY KEY CLUSTERED (event_id),
  CONSTRAINT FK_ci_evt_entity    FOREIGN KEY (entity_id)      REFERENCES core.entity(entity_id),
  CONSTRAINT FK_ci_evt_type      FOREIGN KEY (event_type_code) REFERENCES cid.cid_ci_ref_event_type(event_type_code),
  CONSTRAINT FK_ci_evt_campaign  FOREIGN KEY (campaign_id)    REFERENCES cid.cid_ci_campaign(campaign_id),
  CONSTRAINT FK_ci_evt_interact  FOREIGN KEY (interaction_id) REFERENCES cid.cid_ci_interaction(interaction_id),
  CONSTRAINT FK_ci_evt_lead      FOREIGN KEY (lead_id)        REFERENCES cid.cid_ci_lead(lead_id),
  CONSTRAINT FK_ci_evt_opp       FOREIGN KEY (opportunity_id) REFERENCES cid.cid_ci_opportunity(opportunity_id),
  CONSTRAINT FK_ci_evt_policy    FOREIGN KEY (policy_id)      REFERENCES core.policy(policy_id),
  CONSTRAINT FK_ci_evt_channel   FOREIGN KEY (channel_id)     REFERENCES cid.cid_ch_channel(channel_id)
);
GO

/* Audience */
IF OBJECT_ID('cid.cid_ci_audience_definition','U') IS NULL
CREATE TABLE cid.cid_ci_audience_definition (
  audience_id   UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_ci_aud_def DEFAULT NEWID(),
  audience_name NVARCHAR(200)    NOT NULL,
  description   NVARCHAR(500)    NULL,
  definition_json NVARCHAR(MAX)  NULL,
  CONSTRAINT PK_cid_ci_audience_definition PRIMARY KEY CLUSTERED (audience_id)
);
GO

IF OBJECT_ID('cid.cid_ci_audience_member','U') IS NULL
CREATE TABLE cid.cid_ci_audience_member (
  audience_member_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_ci_aud_mem DEFAULT NEWID(),
  audience_id        UNIQUEIDENTIFIER NOT NULL,
  entity_id          UNIQUEIDENTIFIER NOT NULL,
  valid_from         DATETIME2(6)     NOT NULL,
  valid_to           DATETIME2(6)     NULL,
  CONSTRAINT PK_cid_ci_audience_member PRIMARY KEY CLUSTERED (audience_member_id),
  CONSTRAINT FK_cid_ci_aud_mem_aud   FOREIGN KEY (audience_id) REFERENCES cid.cid_ci_audience_definition(audience_id),
  CONSTRAINT FK_cid_ci_aud_mem_entity FOREIGN KEY (entity_id)  REFERENCES core.entity(entity_id),
  CONSTRAINT CK_cid_ci_aud_mem_range CHECK (valid_from < ISNULL(valid_to, CONVERT(DATETIME2(6), '9999-12-31 23:59:59.999999')))
);
GO

/* Surveys */
IF OBJECT_ID('cid.cid_ci_survey','U') IS NULL
CREATE TABLE cid.cid_ci_survey (
  survey_id        UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_ci_survey DEFAULT NEWID(),
  survey_type_code VARCHAR(60)      NOT NULL,
  survey_name      NVARCHAR(200)    NOT NULL,
  definition_json  NVARCHAR(MAX)    NULL,
  CONSTRAINT PK_cid_ci_survey PRIMARY KEY CLUSTERED (survey_id),
  CONSTRAINT FK_cid_ci_survey_type FOREIGN KEY (survey_type_code) REFERENCES cid.cid_ci_ref_survey_type(survey_type_code)
);
GO

IF OBJECT_ID('cid.cid_ci_survey_response','U') IS NULL
CREATE TABLE cid.cid_ci_survey_response (
  survey_response_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_ci_survey_resp DEFAULT NEWID(),
  survey_id          UNIQUEIDENTIFIER NOT NULL,
  entity_id          UNIQUEIDENTIFIER NOT NULL,
  submitted_ts       DATETIME2(6)     NOT NULL CONSTRAINT DF_cid_ci_survey_resp_ts DEFAULT SYSUTCDATETIME(),
  response_json      NVARCHAR(MAX)    NULL,
  CONSTRAINT PK_cid_ci_survey_response PRIMARY KEY CLUSTERED (survey_response_id),
  CONSTRAINT FK_cid_ci_sresp_survey FOREIGN KEY (survey_id) REFERENCES cid.cid_ci_survey(survey_id),
  CONSTRAINT FK_cid_ci_sresp_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id)
);
GO

/* Telemetry / events */
IF OBJECT_ID('cid.cid_ci_event_simulation','U') IS NULL
CREATE TABLE cid.cid_ci_event_simulation (
  event_id       UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_ci_evt_sim DEFAULT NEWID(),
  entity_id      UNIQUEIDENTIFIER NOT NULL,
  event_type_code VARCHAR(60)     NOT NULL,
  event_ts       DATETIME2(6)     NOT NULL CONSTRAINT DF_cid_ci_evt_sim_ts DEFAULT SYSUTCDATETIME(),
  payload_json   NVARCHAR(MAX)    NULL,
  CONSTRAINT PK_cid_ci_event_simulation PRIMARY KEY CLUSTERED (event_id),
  CONSTRAINT FK_cid_ci_evt_sim_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id),
  CONSTRAINT FK_cid_ci_evt_sim_type   FOREIGN KEY (event_type_code) REFERENCES cid.cid_ci_ref_event_type(event_type_code)
);
GO

IF OBJECT_ID('cid.cid_ci_event_conversion','U') IS NULL
CREATE TABLE cid.cid_ci_event_conversion (
  event_id       UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_ci_evt_conv DEFAULT NEWID(),
  entity_id      UNIQUEIDENTIFIER NOT NULL,
  event_type_code VARCHAR(60)     NOT NULL,
  event_ts       DATETIME2(6)     NOT NULL CONSTRAINT DF_cid_ci_evt_conv_ts DEFAULT SYSUTCDATETIME(),
  payload_json   NVARCHAR(MAX)    NULL,
  CONSTRAINT PK_cid_ci_event_conversion PRIMARY KEY CLUSTERED (event_id),
  CONSTRAINT FK_cid_ci_evt_conv_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id),
  CONSTRAINT FK_cid_ci_evt_conv_type   FOREIGN KEY (event_type_code) REFERENCES cid.cid_ci_ref_event_type(event_type_code)
);
GO

IF OBJECT_ID('cid.cid_ci_event_interaction','U') IS NULL
CREATE TABLE cid.cid_ci_event_interaction (
  event_id       UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_ci_evt_int DEFAULT NEWID(),
  entity_id      UNIQUEIDENTIFIER NOT NULL,
  event_type_code VARCHAR(60)     NOT NULL,
  interaction_id UNIQUEIDENTIFIER NULL,
  event_ts       DATETIME2(6)     NOT NULL CONSTRAINT DF_cid_ci_evt_int_ts DEFAULT SYSUTCDATETIME(),
  payload_json   NVARCHAR(MAX)    NULL,
  CONSTRAINT PK_cid_ci_event_interaction PRIMARY KEY CLUSTERED (event_id),
  CONSTRAINT FK_cid_ci_evt_int_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id),
  CONSTRAINT FK_cid_ci_evt_int_type   FOREIGN KEY (event_type_code) REFERENCES cid.cid_ci_ref_event_type(event_type_code),
  CONSTRAINT FK_cid_ci_evt_int_interaction FOREIGN KEY (interaction_id) REFERENCES cid.cid_ci_interaction(interaction_id)
);
GO

IF OBJECT_ID('cid.cid_ci_event_campaign_exposure','U') IS NULL
CREATE TABLE cid.cid_ci_event_campaign_exposure (
  event_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_ci_evt_exp DEFAULT NEWID(),
  entity_id     UNIQUEIDENTIFIER NOT NULL,
  campaign_id   UNIQUEIDENTIFIER NULL,
  event_type_code VARCHAR(60)    NOT NULL,
  event_ts      DATETIME2(6)     NOT NULL CONSTRAINT DF_cid_ci_evt_exp_ts DEFAULT SYSUTCDATETIME(),
  payload_json  NVARCHAR(MAX)    NULL,
  CONSTRAINT PK_cid_ci_event_campaign_exposure PRIMARY KEY CLUSTERED (event_id),
  CONSTRAINT FK_cid_ci_evt_exp_entity   FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id),
  CONSTRAINT FK_cid_ci_evt_exp_campaign FOREIGN KEY (campaign_id) REFERENCES cid.cid_ci_campaign(campaign_id),
  CONSTRAINT FK_cid_ci_evt_exp_type     FOREIGN KEY (event_type_code) REFERENCES cid.cid_ci_ref_event_type(event_type_code)
);
GO

IF OBJECT_ID('cid.cid_ci_event_campaign_response','U') IS NULL
CREATE TABLE cid.cid_ci_event_campaign_response (
  event_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_ci_evt_resp DEFAULT NEWID(),
  entity_id     UNIQUEIDENTIFIER NOT NULL,
  campaign_id   UNIQUEIDENTIFIER NULL,
  event_type_code VARCHAR(60)    NOT NULL,
  event_ts      DATETIME2(6)     NOT NULL CONSTRAINT DF_cid_ci_evt_resp_ts DEFAULT SYSUTCDATETIME(),
  payload_json  NVARCHAR(MAX)    NULL,
  CONSTRAINT PK_cid_ci_event_campaign_response PRIMARY KEY CLUSTERED (event_id),
  CONSTRAINT FK_cid_ci_evt_resp_entity   FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id),
  CONSTRAINT FK_cid_ci_evt_resp_campaign FOREIGN KEY (campaign_id) REFERENCES cid.cid_ci_campaign(campaign_id),
  CONSTRAINT FK_cid_ci_evt_resp_type     FOREIGN KEY (event_type_code) REFERENCES cid.cid_ci_ref_event_type(event_type_code)
);
GO

IF OBJECT_ID('cid.cid_ci_event_cross_sell_trigger','U') IS NULL
CREATE TABLE cid.cid_ci_event_cross_sell_trigger (
  event_id       UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_cid_ci_evt_xsell DEFAULT NEWID(),
  entity_id      UNIQUEIDENTIFIER NOT NULL,
  event_type_code VARCHAR(60)     NOT NULL,
  event_ts       DATETIME2(6)     NOT NULL CONSTRAINT DF_cid_ci_evt_xsell_ts DEFAULT SYSUTCDATETIME(),
  payload_json   NVARCHAR(MAX)    NULL,
  CONSTRAINT PK_cid_ci_event_cross_sell_trigger PRIMARY KEY CLUSTERED (event_id),
  CONSTRAINT FK_cid_ci_evt_xsell_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id),
  CONSTRAINT FK_cid_ci_evt_xsell_type   FOREIGN KEY (event_type_code) REFERENCES cid.cid_ci_ref_event_type(event_type_code)
);
GO
