/* ============================================================
   0) CREATE DATABASE + context
   ============================================================ */
IF DB_ID('InsuranceData') IS NULL
BEGIN
  DECLARE @sql NVARCHAR(MAX) = N'CREATE DATABASE InsuranceData';
  EXEC (@sql);
END
GO
USE InsuranceData;
GO

/* ============================================================
   1) SCHEMAS
   ============================================================ */
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='core') EXEC('CREATE SCHEMA core');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='cid')  EXEC('CREATE SCHEMA cid');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='pc')   EXEC('CREATE SCHEMA pc');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='lp')   EXEC('CREATE SCHEMA lp');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='hlth') EXEC('CREATE SCHEMA hlth');
GO

/* ============================================================
   2) Helper for open-ended ranges
   ============================================================ */
IF OBJECT_ID('core.fn_highdate','FN') IS NULL
  EXEC('CREATE FUNCTION core.fn_highdate() RETURNS DATETIME2(6) AS BEGIN RETURN ''9999-12-31 23:59:59.999999''; END');
GO

/* ============================================================
   3) CORE — Entities (master & catalogs)
   ============================================================ */
IF OBJECT_ID('core.ref_entity_class','U') IS NULL
CREATE TABLE core.ref_entity_class (
  entity_class_code  VARCHAR(40)   NOT NULL,      -- PERSON, ORGANIZATION, ...
  entity_class_name  NVARCHAR(200) NULL,
  CONSTRAINT PK_ref_entity_class PRIMARY KEY (entity_class_code)
);
GO
IF NOT EXISTS (SELECT 1 FROM core.ref_entity_class WHERE entity_class_code='PERSON')
  INSERT core.ref_entity_class(entity_class_code, entity_class_name) VALUES ('PERSON','Person');
IF NOT EXISTS (SELECT 1 FROM core.ref_entity_class WHERE entity_class_code='ORGANIZATION')
  INSERT core.ref_entity_class(entity_class_code, entity_class_name) VALUES ('ORGANIZATION','Organization');
GO

IF OBJECT_ID('core.ref_address_usage','U') IS NULL
CREATE TABLE core.ref_address_usage (
  address_usage_code VARCHAR(30)   NOT NULL,  -- LEGAL, SERVICE, BILLING, RESIDENTIAL, …
  usage_name         NVARCHAR(150) NULL,
  CONSTRAINT PK_ref_address_usage PRIMARY KEY (address_usage_code)
);
GO

IF OBJECT_ID('core.ref_country','U') IS NULL
CREATE TABLE core.ref_country (
  country_code CHAR(2)         NOT NULL,   -- ISO 3166-1 alpha-2
  iso3_code    CHAR(3)         NULL,
  country_name NVARCHAR(120)   NOT NULL,
  eu_member    BIT             NOT NULL CONSTRAINT DF_country_eu DEFAULT(0),
  CONSTRAINT PK_ref_country PRIMARY KEY (country_code)
);
GO

IF OBJECT_ID('core.ref_contact_type','U') IS NULL
CREATE TABLE core.ref_contact_type (
  contact_type_code VARCHAR(30)   NOT NULL,  -- EMAIL, MOBILE, LANDLINE
  contact_type_name NVARCHAR(120) NULL,
  CONSTRAINT PK_ref_contact_type PRIMARY KEY (contact_type_code)
);
GO

IF OBJECT_ID('core.ref_contact_purpose','U') IS NULL
CREATE TABLE core.ref_contact_purpose (
  purpose_code VARCHAR(40)   NOT NULL,
  purpose_name NVARCHAR(200) NULL,
  CONSTRAINT PK_ref_contact_purpose PRIMARY KEY (purpose_code)
);
GO

IF OBJECT_ID('core.ref_identity_type','U') IS NULL
CREATE TABLE core.ref_identity_type (
  identity_type_code VARCHAR(30)   NOT NULL,   -- NATIONAL_ID, TAX_ID, VAT, PASSPORT, …
  identity_type_name NVARCHAR(120) NULL,
  CONSTRAINT PK_ref_identity_type PRIMARY KEY (identity_type_code)
);
GO

IF OBJECT_ID('core.ref_consent_purpose','U') IS NULL
CREATE TABLE core.ref_consent_purpose (
  consent_purpose_code VARCHAR(40)   NOT NULL, -- MARKETING, CONTRACT, LEGAL_OBLIGATION…
  purpose_name         NVARCHAR(200) NULL,
  default_legal_basis  VARCHAR(40)   NULL,     -- CONTRACT, LEGAL_OBLIGATION, CONSENT
  CONSTRAINT PK_ref_consent_purpose PRIMARY KEY (consent_purpose_code)
);
GO

IF OBJECT_ID('core.ref_kyc_regime','U') IS NULL
CREATE TABLE core.ref_kyc_regime (
  kyc_regime_code VARCHAR(40)   NOT NULL,   -- FATCA, CRS, EDD, SDD…
  regime_name     NVARCHAR(200) NULL,
  CONSTRAINT PK_ref_kyc_regime PRIMARY KEY (kyc_regime_code)
);
GO

IF OBJECT_ID('core.ref_postcode_pattern','U') IS NULL
CREATE TABLE core.ref_postcode_pattern (
  country_code CHAR(2)       NOT NULL,
  regex_text   NVARCHAR(200) NOT NULL,
  example      NVARCHAR(60)  NULL,
  CONSTRAINT PK_ref_postcode_pattern PRIMARY KEY (country_code),
  CONSTRAINT FK_rpp_country FOREIGN KEY (country_code) REFERENCES core.ref_country(country_code)
);
GO

IF OBJECT_ID('core.ref_product_family','U') IS NULL
CREATE TABLE core.ref_product_family (
  product_family_code VARCHAR(60)   NOT NULL,
  product_family_name NVARCHAR(200) NOT NULL,
  description         NVARCHAR(500) NULL,
  CONSTRAINT PK_ref_product_family PRIMARY KEY CLUSTERED (product_family_code)
);
GO

/* ============================================================
   4) CORE — Party structures
   ============================================================ */
IF OBJECT_ID('core.entity','U') IS NULL
CREATE TABLE core.entity (
  entity_id         UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_entity_id DEFAULT NEWID(),
  entity_class_code VARCHAR(40)      NOT NULL,        -- FK to ref_entity_class
  entity_type       VARCHAR(60)      NULL,            -- optional subtype
  created_at        DATETIME2(6)     NOT NULL CONSTRAINT DF_entity_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_entity PRIMARY KEY CLUSTERED (entity_id),
  CONSTRAINT FK_entity_class FOREIGN KEY (entity_class_code) REFERENCES core.ref_entity_class(entity_class_code)
);
GO

IF OBJECT_ID('core.entity_name','U') IS NULL
CREATE TABLE core.entity_name (
  entity_name_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_entity_name_id DEFAULT NEWID(),
  entity_id      UNIQUEIDENTIFIER NOT NULL,
  name_type      VARCHAR(30)      NOT NULL,       -- LEGAL, TRADING, ALIAS…
  given_names    NVARCHAR(200)    NULL,           -- for PERSON
  family_names   NVARCHAR(200)    NULL,
  org_name       NVARCHAR(300)    NULL,           -- for ORGANIZATION
  valid_from     DATETIME2(6)     NOT NULL,
  valid_to       DATETIME2(6)     NULL,
  CONSTRAINT PK_entity_name PRIMARY KEY (entity_name_id),
  CONSTRAINT FK_entity_name_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id),
  CONSTRAINT CK_entity_name_range CHECK (valid_from < ISNULL(valid_to, core.fn_highdate()))
);
GO

IF OBJECT_ID('core.entity_address','U') IS NULL
CREATE TABLE core.entity_address (
  entity_address_id  UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_entity_addr_id DEFAULT NEWID(),
  entity_id          UNIQUEIDENTIFIER NOT NULL,
  address_usage_code VARCHAR(30)      NOT NULL,
  line1              NVARCHAR(200)    NOT NULL,
  line2              NVARCHAR(200)    NULL,
  city               NVARCHAR(120)    NOT NULL,
  postcode           NVARCHAR(32)     NULL,
  country_code       CHAR(2)          NOT NULL,
  valid_from         DATETIME2(6)     NOT NULL,
  valid_to           DATETIME2(6)     NULL,
  CONSTRAINT PK_entity_address PRIMARY KEY (entity_address_id),
  CONSTRAINT FK_entity_addr_entity  FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id),
  CONSTRAINT FK_entity_addr_usage   FOREIGN KEY (address_usage_code) REFERENCES core.ref_address_usage(address_usage_code),
  CONSTRAINT FK_entity_addr_country FOREIGN KEY (country_code) REFERENCES core.ref_country(country_code),
  CONSTRAINT CK_entity_addr_range CHECK (valid_from < ISNULL(valid_to, core.fn_highdate()))
);
GO

IF OBJECT_ID('core.entity_contact_point','U') IS NULL
CREATE TABLE core.entity_contact_point (
  contact_point_id  UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_ecp_id DEFAULT NEWID(),
  entity_id         UNIQUEIDENTIFIER NOT NULL,
  contact_type_code VARCHAR(30)      NOT NULL,
  contact_value     NVARCHAR(256)    NOT NULL,    -- email/phone/etc
  is_verified       BIT              NOT NULL CONSTRAINT DF_ecp_verified DEFAULT(0),
  verified_ts       DATETIME2(6)     NULL,
  is_primary        BIT              NOT NULL CONSTRAINT DF_ecp_primary DEFAULT(0),
  purpose_code      VARCHAR(40)      NULL,
  locale            NVARCHAR(20)     NULL,
  timezone          NVARCHAR(64)     NULL,
  deliverability_status VARCHAR(30)  NULL,
  last_bounce_ts    DATETIME2(6)     NULL,
  valid_from        DATETIME2(6)     NOT NULL,
  valid_to          DATETIME2(6)     NULL,
  CONSTRAINT PK_entity_contact_point PRIMARY KEY (contact_point_id),
  CONSTRAINT FK_ecp_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id),
  CONSTRAINT FK_ecp_type   FOREIGN KEY (contact_type_code) REFERENCES core.ref_contact_type(contact_type_code),
  CONSTRAINT FK_ecp_purpose FOREIGN KEY (purpose_code) REFERENCES core.ref_contact_purpose(purpose_code),
  CONSTRAINT CK_ecp_range CHECK (valid_from < ISNULL(valid_to, core.fn_highdate()))
);
GO

IF OBJECT_ID('core.entity_identity','U') IS NULL
CREATE TABLE core.entity_identity (
  entity_identity_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_eid_id DEFAULT NEWID(),
  entity_id          UNIQUEIDENTIFIER NOT NULL,
  identity_type_code VARCHAR(30)      NOT NULL,
  identity_number    NVARCHAR(128)    NOT NULL,
  country_code       CHAR(2)          NULL,
  country_code_nn    AS ISNULL(country_code,'ZZ') PERSISTED,
  identity_number_norm AS LOWER(TRIM(REPLACE(REPLACE(REPLACE(identity_number, ' ', ''), '-', ''), '.', ''))) PERSISTED,
  issued_on          DATE             NULL,
  expires_on         DATE             NULL,
  valid_from         DATETIME2(6)     NOT NULL,
  valid_to           DATETIME2(6)     NULL,
  CONSTRAINT PK_entity_identity PRIMARY KEY (entity_identity_id),
  CONSTRAINT FK_eid_entity  FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id),
  CONSTRAINT FK_eid_type    FOREIGN KEY (identity_type_code) REFERENCES core.ref_identity_type(identity_type_code),
  CONSTRAINT FK_eid_country FOREIGN KEY (country_code) REFERENCES core.ref_country(country_code),
  CONSTRAINT CK_eid_range CHECK (valid_from < ISNULL(valid_to, core.fn_highdate()))
);
GO

IF OBJECT_ID('core.entity_source_key','U') IS NULL
CREATE TABLE core.entity_source_key (
  entity_source_key_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_esk_id DEFAULT NEWID(),
  entity_id            UNIQUEIDENTIFIER NOT NULL,
  source_system_code   VARCHAR(60)      NOT NULL,
  external_key         NVARCHAR(200)    NOT NULL,
  status_code          VARCHAR(30)      NULL,   -- ACTIVE/MERGED/RETIRED
  link_confidence_pct  DECIMAL(5,2)     NULL,   -- 0..100
  CONSTRAINT PK_entity_source_key PRIMARY KEY (entity_source_key_id),
  CONSTRAINT FK_esk_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id)
);
GO

/* Additional entity satellites */
IF OBJECT_ID('core.entity_nationality','U') IS NULL
CREATE TABLE core.entity_nationality (
  entity_nationality_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_entity_nat_id DEFAULT NEWID(),
  entity_id             UNIQUEIDENTIFIER NOT NULL,
  country_code          CHAR(2)          NOT NULL,
  valid_from            DATETIME2(6)     NOT NULL,
  valid_to              DATETIME2(6)     NULL,
  CONSTRAINT PK_entity_nationality PRIMARY KEY (entity_nationality_id),
  CONSTRAINT FK_entity_nat_entity  FOREIGN KEY (entity_id)    REFERENCES core.entity(entity_id),
  CONSTRAINT FK_entity_nat_country FOREIGN KEY (country_code) REFERENCES core.ref_country(country_code),
  CONSTRAINT CK_entity_nat_range CHECK (valid_from < ISNULL(valid_to, core.fn_highdate()))
);
GO

IF OBJECT_ID('core.ref_entity_classification','U') IS NULL
CREATE TABLE core.ref_entity_classification (
  classification_code VARCHAR(60)   NOT NULL,
  classification_name NVARCHAR(200) NOT NULL,
  description         NVARCHAR(500) NULL,
  CONSTRAINT PK_ref_entity_classification PRIMARY KEY (classification_code)
);
GO

IF OBJECT_ID('core.entity_classification','U') IS NULL
CREATE TABLE core.entity_classification (
  entity_classification_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_entity_class_id DEFAULT NEWID(),
  entity_id        UNIQUEIDENTIFIER NOT NULL,
  classification_code VARCHAR(60)   NOT NULL,
  valid_from       DATETIME2(6)     NOT NULL,
  valid_to         DATETIME2(6)     NULL,
  CONSTRAINT PK_entity_classification PRIMARY KEY (entity_classification_id),
  CONSTRAINT FK_entity_class_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id),
  CONSTRAINT FK_entity_class_code FOREIGN KEY (classification_code) REFERENCES core.ref_entity_classification(classification_code),
  CONSTRAINT CK_entity_class_range CHECK (valid_from < ISNULL(valid_to, core.fn_highdate()))
);
GO

IF OBJECT_ID('core.ref_company','U') IS NULL
CREATE TABLE core.ref_company (
  company_code VARCHAR(60)   NOT NULL,
  company_name NVARCHAR(200) NOT NULL,
  description  NVARCHAR(500) NULL,
  CONSTRAINT PK_ref_company PRIMARY KEY (company_code)
);
GO

IF OBJECT_ID('core.entity_company_membership','U') IS NULL
CREATE TABLE core.entity_company_membership (
  entity_company_membership_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_entity_co_mem_id DEFAULT NEWID(),
  entity_id    UNIQUEIDENTIFIER NOT NULL,
  company_code VARCHAR(60)      NOT NULL,
  valid_from   DATETIME2(6)     NOT NULL,
  valid_to     DATETIME2(6)     NULL,
  CONSTRAINT PK_entity_company_membership PRIMARY KEY (entity_company_membership_id),
  CONSTRAINT FK_entity_company_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id),
  CONSTRAINT FK_entity_company_code FOREIGN KEY (company_code) REFERENCES core.ref_company(company_code),
  CONSTRAINT CK_entity_company_range CHECK (valid_from < ISNULL(valid_to, core.fn_highdate()))
);
GO

IF OBJECT_ID('core.ref_network','U') IS NULL
CREATE TABLE core.ref_network (
  network_code VARCHAR(60)   NOT NULL,
  network_name NVARCHAR(200) NOT NULL,
  description  NVARCHAR(500) NULL,
  CONSTRAINT PK_ref_network PRIMARY KEY (network_code)
);
GO

IF OBJECT_ID('core.entity_network_membership','U') IS NULL
CREATE TABLE core.entity_network_membership (
  entity_network_membership_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_entity_net_mem_id DEFAULT NEWID(),
  entity_id   UNIQUEIDENTIFIER NOT NULL,
  network_code VARCHAR(60)     NOT NULL,
  valid_from  DATETIME2(6)     NOT NULL,
  valid_to    DATETIME2(6)     NULL,
  CONSTRAINT PK_entity_network_membership PRIMARY KEY (entity_network_membership_id),
  CONSTRAINT FK_entity_network_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id),
  CONSTRAINT FK_entity_network_code FOREIGN KEY (network_code) REFERENCES core.ref_network(network_code),
  CONSTRAINT CK_entity_network_range CHECK (valid_from < ISNULL(valid_to, core.fn_highdate()))
);
GO

IF OBJECT_ID('core.ref_tax_regime','U') IS NULL
CREATE TABLE core.ref_tax_regime (
  tax_regime_code VARCHAR(40)   NOT NULL,
  tax_regime_name NVARCHAR(200) NOT NULL,
  description     NVARCHAR(500) NULL,
  CONSTRAINT PK_ref_tax_regime PRIMARY KEY (tax_regime_code)
);
GO

IF OBJECT_ID('core.entity_tax_regime','U') IS NULL
CREATE TABLE core.entity_tax_regime (
  entity_tax_regime_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_entity_tax_regime_id DEFAULT NEWID(),
  entity_id       UNIQUEIDENTIFIER NOT NULL,
  tax_regime_code VARCHAR(40)      NOT NULL,
  country_code    CHAR(2)          NULL,
  valid_from      DATETIME2(6)     NOT NULL,
  valid_to        DATETIME2(6)     NULL,
  CONSTRAINT PK_entity_tax_regime PRIMARY KEY (entity_tax_regime_id),
  CONSTRAINT FK_entity_tax_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id),
  CONSTRAINT FK_entity_tax_code FOREIGN KEY (tax_regime_code) REFERENCES core.ref_tax_regime(tax_regime_code),
  CONSTRAINT FK_entity_tax_country FOREIGN KEY (country_code) REFERENCES core.ref_country(country_code),
  CONSTRAINT CK_entity_tax_range CHECK (valid_from < ISNULL(valid_to, core.fn_highdate()))
);
GO

/* ============================================================
   5) CORE — Consent/KYC/Event
   ============================================================ */
IF OBJECT_ID('core.consent','U') IS NULL
CREATE TABLE core.consent (
  consent_id           UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_consent_id DEFAULT NEWID(),
  entity_id            UNIQUEIDENTIFIER NOT NULL,
  consent_purpose_code VARCHAR(40)      NOT NULL,
  status_code          VARCHAR(20)      NOT NULL, -- GIVEN/WITHDRAWN/RESTRICTED
  legal_basis          VARCHAR(40)      NULL,
  evidence_uri         NVARCHAR(500)    NULL,
  valid_from           DATETIME2(6)     NOT NULL,
  valid_to             DATETIME2(6)     NULL,
  CONSTRAINT PK_consent PRIMARY KEY CLUSTERED (consent_id),
  CONSTRAINT FK_consent_entity  FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id),
  CONSTRAINT FK_consent_purpose FOREIGN KEY (consent_purpose_code) REFERENCES core.ref_consent_purpose(consent_purpose_code),
  CONSTRAINT CK_consent_range CHECK (valid_from < ISNULL(valid_to, core.fn_highdate()))
);
GO

IF OBJECT_ID('core.entity_event_log','U') IS NULL
CREATE TABLE core.entity_event_log (
  event_id     UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_eel_id DEFAULT NEWID(),
  entity_id    UNIQUEIDENTIFIER NOT NULL,
  event_type   VARCHAR(40)      NOT NULL,  -- CONSENT_GIVEN/WITHDRAWN/RESTRICTED/etc
  event_ts     DATETIME2(6)     NOT NULL CONSTRAINT DF_eel_ts DEFAULT SYSUTCDATETIME(),
  legal_basis  VARCHAR(40)      NULL,
  evidence_uri NVARCHAR(500)    NULL,
  payload_json NVARCHAR(MAX)    NULL,
  prev_hash    VARBINARY(64)    NULL,      -- plain attribute (no enforcement)
  this_hash    VARBINARY(64)    NULL,
  CONSTRAINT PK_entity_event_log PRIMARY KEY (event_id),
  CONSTRAINT FK_eel_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id)
);
GO

IF OBJECT_ID('core.kyc_status','U') IS NULL
CREATE TABLE core.kyc_status (
  kyc_status_id   UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_kyc_id DEFAULT NEWID(),
  entity_id       UNIQUEIDENTIFIER NOT NULL,
  kyc_regime_code VARCHAR(40)      NOT NULL,
  status_code     VARCHAR(30)      NOT NULL,  -- PASSED/FAILED/PENDING
  obtained_from   NVARCHAR(200)    NULL,
  valid_from      DATETIME2(6)     NOT NULL,
  valid_to        DATETIME2(6)     NULL,
  CONSTRAINT PK_kyc_status PRIMARY KEY CLUSTERED (kyc_status_id),
  CONSTRAINT FK_kyc_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id),
  CONSTRAINT FK_kyc_regime FOREIGN KEY (kyc_regime_code) REFERENCES core.ref_kyc_regime(kyc_regime_code),
  CONSTRAINT CK_kyc_range CHECK (valid_from < ISNULL(valid_to, core.fn_highdate()))
);
GO

/* ============================================================
   6) CORE — Roles, Relationships, Policy/PPR
   ============================================================ */
IF OBJECT_ID('core.role_ref','U') IS NULL
CREATE TABLE core.role_ref (
  role_code    VARCHAR(60)   NOT NULL,
  context_code VARCHAR(30)   NOT NULL,  -- ENTERPRISE, POLICY
  role_name    NVARCHAR(200) NULL,
  allow_flag   BIT           NOT NULL CONSTRAINT DF_role_allow DEFAULT(1),
  ban_flag     BIT           NOT NULL CONSTRAINT DF_role_ban   DEFAULT(0),
  CONSTRAINT PK_role_ref PRIMARY KEY (role_code, context_code)
);
GO

IF OBJECT_ID('core.role_capability','U') IS NULL
CREATE TABLE core.role_capability (
  capability_code VARCHAR(80)   NOT NULL,  -- CAN_EARN_REMUNERATION, ...
  capability_name NVARCHAR(200) NULL,
  CONSTRAINT PK_role_capability PRIMARY KEY (capability_code)
);
GO

IF OBJECT_ID('core.role_ref_capability','U') IS NULL
CREATE TABLE core.role_ref_capability (
  role_code       VARCHAR(60) NOT NULL,
  context_code    VARCHAR(30) NOT NULL,
  capability_code VARCHAR(80) NOT NULL,
  CONSTRAINT PK_role_ref_capability PRIMARY KEY (role_code, context_code, capability_code),
  CONSTRAINT FK_rrc_role FOREIGN KEY (role_code, context_code) REFERENCES core.role_ref(role_code, context_code),
  CONSTRAINT FK_rrc_cap  FOREIGN KEY (capability_code)        REFERENCES core.role_capability(capability_code)
);
GO

IF OBJECT_ID('core.relationship_ref','U') IS NULL
CREATE TABLE core.relationship_ref (
  relationship_code VARCHAR(60)   NOT NULL,   -- UBO, DIRECTOR, ...
  context_code      VARCHAR(30)   NOT NULL,   -- ENTERPRISE, POLICY
  relationship_name NVARCHAR(200) NULL,
  CONSTRAINT PK_relationship_ref PRIMARY KEY (relationship_code, context_code)
);
GO

IF OBJECT_ID('core.entity_relationship','U') IS NULL
CREATE TABLE core.entity_relationship (
  entity_relationship_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_er_id DEFAULT NEWID(),
  from_entity_id  UNIQUEIDENTIFIER NOT NULL,
  to_entity_id    UNIQUEIDENTIFIER NOT NULL,
  relationship_code VARCHAR(60)   NOT NULL,
  context_code    VARCHAR(30)     NOT NULL CONSTRAINT DF_er_ctx DEFAULT('ENTERPRISE'),
  valid_from      DATETIME2(6)    NOT NULL,
  valid_to        DATETIME2(6)    NULL,
  CONSTRAINT PK_entity_relationship PRIMARY KEY CLUSTERED (entity_relationship_id),
  CONSTRAINT FK_er_from_entity FOREIGN KEY (from_entity_id) REFERENCES core.entity(entity_id),
  CONSTRAINT FK_er_to_entity   FOREIGN KEY (to_entity_id)   REFERENCES core.entity(entity_id),
  CONSTRAINT FK_er_rel         FOREIGN KEY (relationship_code, context_code) REFERENCES core.relationship_ref(relationship_code, context_code),
  CONSTRAINT CK_er_range CHECK (valid_from < ISNULL(valid_to, core.fn_highdate()))
);
GO

/* Policy and PPR (Option A) */
IF OBJECT_ID('core.ref_lob','U') IS NULL
CREATE TABLE core.ref_lob (
  lob_code VARCHAR(20)    NOT NULL,
  lob_name NVARCHAR(120)  NULL,
  CONSTRAINT PK_ref_lob PRIMARY KEY CLUSTERED (lob_code)
);
GO

IF OBJECT_ID('core.policy','U') IS NULL
CREATE TABLE core.policy (
  policy_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_policy_id DEFAULT NEWID(),
  policy_number  NVARCHAR(64)     NULL,
  lob_code       VARCHAR(20)      NULL,
  effective_from DATETIME2(6)     NULL,
  effective_to   DATETIME2(6)     NULL,
  CONSTRAINT PK_policy PRIMARY KEY CLUSTERED (policy_id),
  CONSTRAINT FK_policy_lob FOREIGN KEY (lob_code) REFERENCES core.ref_lob(lob_code)
);
GO

IF OBJECT_ID('core.entity_policy_role','U') IS NULL
CREATE TABLE core.entity_policy_role (
  entity_policy_role_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_ppr_id DEFAULT NEWID(),
  policy_id             UNIQUEIDENTIFIER NOT NULL,
  entity_id             UNIQUEIDENTIFIER NOT NULL,
  role_code             VARCHAR(60)      NOT NULL,
  context_code          VARCHAR(30)      NOT NULL CONSTRAINT DF_ppr_ctx DEFAULT('POLICY'),
  valid_from            DATETIME2(6)     NOT NULL,
  valid_to              DATETIME2(6)     NULL,
  CONSTRAINT PK_entity_policy_role PRIMARY KEY CLUSTERED (entity_policy_role_id),
  CONSTRAINT FK_ppr_policy  FOREIGN KEY (policy_id) REFERENCES core.policy(policy_id),
  CONSTRAINT FK_ppr_entity  FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id),
  CONSTRAINT FK_ppr_role    FOREIGN KEY (role_code, context_code) REFERENCES core.role_ref(role_code, context_code),
  CONSTRAINT CK_ppr_range CHECK (valid_from < ISNULL(valid_to, core.fn_highdate()))
);
GO

IF OBJECT_ID('core.policy_entity_relationship','U') IS NULL
CREATE TABLE core.policy_entity_relationship (
  policy_entity_relationship_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_per_id DEFAULT NEWID(),
  policy_id     UNIQUEIDENTIFIER NOT NULL,
  parent_ppr_id UNIQUEIDENTIFIER NOT NULL,
  child_ppr_id  UNIQUEIDENTIFIER NOT NULL,
  relationship_code VARCHAR(60)  NOT NULL,  -- from relationship_ref (context POLICY)
  context_code      VARCHAR(30)  NOT NULL CONSTRAINT DF_per_ctx DEFAULT('POLICY'),
  valid_from    DATETIME2(6)     NOT NULL,
  valid_to      DATETIME2(6)     NULL,
  CONSTRAINT PK_policy_entity_relationship PRIMARY KEY CLUSTERED (policy_entity_relationship_id),
  CONSTRAINT FK_per_policy  FOREIGN KEY (policy_id)     REFERENCES core.policy(policy_id),
  CONSTRAINT FK_per_parent  FOREIGN KEY (parent_ppr_id) REFERENCES core.entity_policy_role(entity_policy_role_id),
  CONSTRAINT FK_per_child   FOREIGN KEY (child_ppr_id)  REFERENCES core.entity_policy_role(entity_policy_role_id),
  CONSTRAINT FK_per_rel     FOREIGN KEY (relationship_code, context_code) REFERENCES core.relationship_ref(relationship_code, context_code),
  CONSTRAINT CK_per_range CHECK (valid_from < ISNULL(valid_to, core.fn_highdate()))
);
GO

/* ============================================================
   7) CORE — DSR
   ============================================================ */
IF OBJECT_ID('core.entity_dsr_event','U') IS NULL
CREATE TABLE core.entity_dsr_event (
  dsr_event_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_dsr_id DEFAULT NEWID(),
  entity_id    UNIQUEIDENTIFIER NOT NULL,
  dsr_type     VARCHAR(20)      NOT NULL,  -- ACCESS/RECTIFY/ERASE/RESTRICT/OBJECT/PORT
  requested_ts DATETIME2(6)     NOT NULL CONSTRAINT DF_dsr_req DEFAULT SYSUTCDATETIME(),
  status_code  VARCHAR(20)      NOT NULL,  -- OPEN/CLOSED/REJECTED
  evidence_uri NVARCHAR(500)    NULL,
  prev_hash    VARBINARY(64)    NULL,
  this_hash    VARBINARY(64)    NULL,
  CONSTRAINT PK_entity_dsr_event PRIMARY KEY (dsr_event_id),
  CONSTRAINT FK_dsr_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id)
);
GO

/* ============================================================
   8) LoB scopes (pc/lp/hlth) — PPR extensions
   ============================================================ */
IF OBJECT_ID('pc.entity_scope','U') IS NULL
CREATE TABLE pc.entity_scope (
  entity_scope_id       UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_pc_scope_id DEFAULT NEWID(),
  entity_policy_role_id UNIQUEIDENTIFIER NOT NULL,
  attr_json             NVARCHAR(MAX)    NULL,
  CONSTRAINT PK_pc_entity_scope PRIMARY KEY (entity_scope_id),
  CONSTRAINT FK_pc_scope_ppr FOREIGN KEY (entity_policy_role_id) REFERENCES core.entity_policy_role(entity_policy_role_id)
);
GO

IF OBJECT_ID('lp.entity_scope','U') IS NULL
CREATE TABLE lp.entity_scope (
  entity_scope_id       UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_lp_scope_id DEFAULT NEWID(),
  entity_policy_role_id UNIQUEIDENTIFIER NOT NULL,
  attr_json             NVARCHAR(MAX)    NULL,
  CONSTRAINT PK_lp_entity_scope PRIMARY KEY (entity_scope_id),
  CONSTRAINT FK_lp_scope_ppr FOREIGN KEY (entity_policy_role_id) REFERENCES core.entity_policy_role(entity_policy_role_id)
);
GO

IF OBJECT_ID('hlth.entity_scope','U') IS NULL
CREATE TABLE hlth.entity_scope (
  entity_scope_id       UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_hlth_scope_id DEFAULT NEWID(),
  entity_policy_role_id UNIQUEIDENTIFIER NOT NULL,
  attr_json             NVARCHAR(MAX)    NULL,
  CONSTRAINT PK_hlth_entity_scope PRIMARY KEY (entity_scope_id),
  CONSTRAINT FK_hlth_scope_ppr FOREIGN KEY (entity_policy_role_id) REFERENCES core.entity_policy_role(entity_policy_role_id)
);
GO

/* ============================================================
   9) CID — Intermediaries (catalogs, masters, ops)
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
  type_code           VARCHAR(40) NOT NULL,  -- BROKER, AGENT_TIED, MGA, …
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
  CONSTRAINT PK_cid_int_intermediary PRIMARY KEY (intermediary_id),
  CONSTRAINT FK_cid_int_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id),
  CONSTRAINT FK_cid_int_home_country FOREIGN KEY (home_country_code) REFERENCES core.ref_country(country_code)
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
  CONSTRAINT PK_cid_int_intermediary_source_key PRIMARY KEY (intermediary_source_key_id),
  CONSTRAINT FK_cid_isk_intermediary FOREIGN KEY (intermediary_id) REFERENCES cid.cid_int_intermediary(intermediary_id)
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
  CONSTRAINT FK_cid_rep_intermediary FOREIGN KEY (intermediary_id)  REFERENCES cid.cid_int_intermediary(intermediary_id),
  CONSTRAINT FK_cid_rep_person       FOREIGN KEY (person_entity_id) REFERENCES core.entity(entity_id),
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
  CONSTRAINT FK_cid_license_intermediary FOREIGN KEY (intermediary_id) REFERENCES cid.cid_int_intermediary(intermediary_id),
  CONSTRAINT FK_cid_license_juris       FOREIGN KEY (jurisdiction_id) REFERENCES cid.cid_int_ref_jurisdiction(jurisdiction_id),
  CONSTRAINT FK_cid_license_lob         FOREIGN KEY (lob_scope_code)  REFERENCES cid.cid_int_ref_lob_scope(lob_scope_code),
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
  CONSTRAINT FK_cid_appt_intermediary  FOREIGN KEY (intermediary_id)     REFERENCES cid.cid_int_intermediary(intermediary_id),
  CONSTRAINT FK_cid_appt_insurer       FOREIGN KEY (insurer_entity_id)   REFERENCES core.entity(entity_id),
  CONSTRAINT FK_cid_appt_type          FOREIGN KEY (appointment_type_id) REFERENCES cid.cid_int_ref_appointment_type(appointment_type_id),
  CONSTRAINT FK_cid_appt_license       FOREIGN KEY (license_id)          REFERENCES cid.cid_int_intermediary_license(license_id),
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
  CONSTRAINT FK_cid_fp_subject FOREIGN KEY (subject_entity_id) REFERENCES core.entity(entity_id),
  CONSTRAINT CK_cid_fp_range CHECK (valid_from < ISNULL(valid_to, core.fn_highdate()))
);
GO

IF OBJECT_ID('cid.cid_int_ref_remuneration_component','U') IS NULL
CREATE TABLE cid.cid_int_ref_remuneration_component (
  component_code VARCHAR(40)   NOT NULL,  -- COMMISSION_NEW, FEE_PCT, BONUS_TIERED, …
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
  CONSTRAINT FK_cid_remas_ppr  FOREIGN KEY (entity_policy_role_id) REFERENCES core.entity_policy_role(entity_policy_role_id),
  CONSTRAINT FK_cid_remas_tpl  FOREIGN KEY (template_id)          REFERENCES cid.cid_int_remuneration_template(template_id),
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
  CONSTRAINT PK_cid_bor PRIMARY KEY (bor_change_id),
  CONSTRAINT FK_cid_bor_from FOREIGN KEY (from_ppr_id) REFERENCES core.entity_policy_role(entity_policy_role_id),
  CONSTRAINT FK_cid_bor_to   FOREIGN KEY (to_ppr_id)   REFERENCES core.entity_policy_role(entity_policy_role_id)
);
GO

/* ============================================================
   10) CID — Channel membership (links to Channels DDL)
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
  CONSTRAINT FK_cid_ch_mem_entity  FOREIGN KEY (entity_id)  REFERENCES core.entity(entity_id),
  CONSTRAINT CK_cid_ch_mem_range CHECK (valid_from < ISNULL(valid_to, core.fn_highdate()))
);
GO
