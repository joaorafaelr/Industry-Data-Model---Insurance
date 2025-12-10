/* ============================================================
   HEALTH → PROVIDERS (Part 1 — Base)
   Schemas + Tables (PKs & DEFAULTs only; no FKs/UNIQUE/CHECK/IX)
   ============================================================ */

-- Ensure schemas
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='core') EXEC('CREATE SCHEMA core');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='hlth') EXEC('CREATE SCHEMA hlth');
GO

/* 1) Provider organisation (anchor to entity ORG — FK in Part 2) */
IF OBJECT_ID('hlth.hlth_provider_org','U') IS NULL
CREATE TABLE hlth.hlth_provider_org (
  provider_org_id    UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_hlth_porg_id DEFAULT NEWID(),
  entity_id          UNIQUEIDENTIFIER NOT NULL,   -- core.entity (ORG) — FK in Part 2
  org_code           NVARCHAR(80)     NULL,       -- external/provider code
  org_name           NVARCHAR(200)    NULL,
  status_code        NVARCHAR(30)     NULL,       -- ACTIVE/SUSPENDED/...
  created_at         DATETIME2(6)     NOT NULL CONSTRAINT DF_hlth_porg_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_hlth_provider_org PRIMARY KEY (provider_org_id)
);
GO

/* 2) Provider site (physical location) */
IF OBJECT_ID('hlth.hlth_provider_site','U') IS NULL
CREATE TABLE hlth.hlth_provider_site (
  provider_site_id   UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_hlth_psite_id DEFAULT NEWID(),
  provider_org_id    UNIQUEIDENTIFIER NOT NULL,   -- parent org — FK in Part 2
  site_code          NVARCHAR(80)     NULL,
  site_name          NVARCHAR(200)    NULL,
  address_id         UNIQUEIDENTIFIER NULL,       -- core.entity_address or address master (by reference)
  effective_from     DATE             NULL,
  effective_to       DATE             NULL,
  status_code        NVARCHAR(30)     NULL,
  created_at         DATETIME2(6)     NOT NULL CONSTRAINT DF_hlth_psite_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_hlth_provider_site PRIMARY KEY (provider_site_id)
);
GO

/* 3) Practitioner (individual) */
IF OBJECT_ID('hlth.hlth_provider_practitioner','U') IS NULL
CREATE TABLE hlth.hlth_provider_practitioner (
  practitioner_id    UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_hlth_pprac_id DEFAULT NEWID(),
  entity_id          UNIQUEIDENTIFIER NOT NULL,   -- core.entity (PERSON) — FK in Part 2
  license_number     NVARCHAR(80)     NULL,       -- unique when present (filtered UNIQUE in Part 2)
  specialty_code     NVARCHAR(60)     NULL,       -- taxonomy ref (free in base)
  status_code        NVARCHAR(30)     NULL,
  created_at         DATETIME2(6)     NOT NULL CONSTRAINT DF_hlth_pprac_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_hlth_provider_practitioner PRIMARY KEY (practitioner_id)
);
GO

/* 4) Affiliation (practitioner ↔ org/site) */
IF OBJECT_ID('hlth.hlth_org_practitioner_affiliation','U') IS NULL
CREATE TABLE hlth.hlth_org_practitioner_affiliation (
  affiliation_id     UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_hlth_paff_id DEFAULT NEWID(),
  practitioner_id    UNIQUEIDENTIFIER NOT NULL,
  provider_org_id    UNIQUEIDENTIFIER NOT NULL,
  provider_site_id   UNIQUEIDENTIFIER NULL,    -- optional site-level affiliation
  role_code          NVARCHAR(40)     NULL,    -- ATTENDING, SURGEON, etc. (free in base)
  effective_from     DATE             NULL,
  effective_to       DATE             NULL,
  notes_json         NVARCHAR(MAX)    NULL,    -- ISJSON in Part 2
  created_at         DATETIME2(6)     NOT NULL CONSTRAINT DF_hlth_paff_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_hlth_org_practitioner_affiliation PRIMARY KEY (affiliation_id)
);
GO

/* 5) Provider network (insurer-defined) */
IF OBJECT_ID('hlth.hlth_provider_network','U') IS NULL
CREATE TABLE hlth.hlth_provider_network (
  network_id         UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_hlth_pnet_id DEFAULT NEWID(),
  network_code       NVARCHAR(80)     NOT NULL,
  network_name       NVARCHAR(200)    NULL,
  effective_from     DATE             NULL,
  effective_to       DATE             NULL,
  status_code        NVARCHAR(30)     NULL,
  created_at         DATETIME2(6)     NOT NULL CONSTRAINT DF_hlth_pnet_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_hlth_provider_network PRIMARY KEY (network_id)
);
GO

/* 6) Network membership (org/site/practitioner) */
IF OBJECT_ID('hlth.hlth_network_membership','U') IS NULL
CREATE TABLE hlth.hlth_network_membership (
  membership_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_hlth_pnmem_id DEFAULT NEWID(),
  network_id         UNIQUEIDENTIFIER NOT NULL,
  provider_org_id    UNIQUEIDENTIFIER NULL,
  provider_site_id   UNIQUEIDENTIFIER NULL,
  practitioner_id    UNIQUEIDENTIFIER NULL,
  tier_code          NVARCHAR(30)     NULL,    -- GOLD/SILVER/...
  effective_from     DATE             NULL,
  effective_to       DATE             NULL,
  notes_json         NVARCHAR(MAX)    NULL,    -- ISJSON in Part 2
  created_at         DATETIME2(6)     NOT NULL CONSTRAINT DF_hlth_pnmem_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_hlth_network_membership PRIMARY KEY (membership_id)
);
GO

/* 7) Provider contract (header) */
IF OBJECT_ID('hlth.hlth_provider_contract','U') IS NULL
CREATE TABLE hlth.hlth_provider_contract (
  contract_id        UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_hlth_pcon_id DEFAULT NEWID(),
  provider_org_id    UNIQUEIDENTIFIER NOT NULL,
  provider_site_id   UNIQUEIDENTIFIER NULL,    -- optional site-specific contract
  contract_code      NVARCHAR(80)     NULL,
  status_code        NVARCHAR(30)     NULL,    -- ACTIVE/SUSPENDED/TERMINATED
  signed_date        DATE             NULL,
  created_at         DATETIME2(6)     NOT NULL CONSTRAINT DF_hlth_pcon_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_hlth_provider_contract PRIMARY KEY (contract_id)
);
GO

/* 8) Provider contract term (effective-dated; optional tariff_schedule_id pointer) */
IF OBJECT_ID('hlth.hlth_provider_contract_term','U') IS NULL
CREATE TABLE hlth.hlth_provider_contract_term (
  contract_term_id     UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_hlth_pcont_id DEFAULT NEWID(),
  contract_id          UNIQUEIDENTIFIER NOT NULL,
  effective_from       DATE             NOT NULL,
  effective_to         DATE             NULL,
  tariff_schedule_id   UNIQUEIDENTIFIER NULL,    -- ID pointer (no FK in base)
  conditions_json      NVARCHAR(MAX)    NULL,    -- ISJSON in Part 2
  created_at           DATETIME2(6)     NOT NULL CONSTRAINT DF_hlth_pcont_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_hlth_provider_contract_term PRIMARY KEY (contract_term_id)
);
GO

/* 9) Provider service catalog (availability only) */
IF OBJECT_ID('hlth.hlth_provider_service_catalog','U') IS NULL
CREATE TABLE hlth.hlth_provider_service_catalog (
  service_catalog_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_hlth_psc_id DEFAULT NEWID(),
  provider_org_id    UNIQUEIDENTIFIER NULL,
  provider_site_id   UNIQUEIDENTIFIER NULL,
  practitioner_id    UNIQUEIDENTIFIER NULL,
  service_code       NVARCHAR(60)     NOT NULL,  -- clinical service/procedure code (taxonomy outside)
  status_code        NVARCHAR(30)     NULL,      -- AVAILABLE/SUSPENDED
  effective_from     DATE             NOT NULL,
  effective_to       DATE             NULL,
  notes_json         NVARCHAR(MAX)    NULL,      -- ISJSON in Part 2
  created_at         DATETIME2(6)     NOT NULL CONSTRAINT DF_hlth_psc_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_hlth_provider_service_catalog PRIMARY KEY (service_catalog_id)
);
GO

/* 10) Accreditation/certification record */
IF OBJECT_ID('hlth.hlth_provider_accreditation','U') IS NULL
CREATE TABLE hlth.hlth_provider_accreditation (
  accreditation_id   UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_hlth_paccr_id DEFAULT NEWID(),
  provider_org_id    UNIQUEIDENTIFIER NULL,
  provider_site_id   UNIQUEIDENTIFIER NULL,
  practitioner_id    UNIQUEIDENTIFIER NULL,
  accreditation_code NVARCHAR(80)     NOT NULL,  -- accreditation/certification code
  issuer_code        NVARCHAR(80)     NULL,
  effective_from     DATE             NOT NULL,
  effective_to       DATE             NULL,
  details_json       NVARCHAR(MAX)    NULL,      -- ISJSON in Part 2
  created_at         DATETIME2(6)     NOT NULL CONSTRAINT DF_hlth_paccr_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_hlth_provider_accreditation PRIMARY KEY (accreditation_id)
);
GO

/* 11) Pre-authorization template (routes to UW rule/version) */
IF OBJECT_ID('hlth.hlth_pre_auth_template','U') IS NULL
CREATE TABLE hlth.hlth_pre_auth_template (
  pre_auth_template_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_hlth_pauth_id DEFAULT NEWID(),
  service_code         NVARCHAR(60)     NOT NULL,
  network_id           UNIQUEIDENTIFIER NULL,  -- optional: template scoped to a network
  tier_code            NVARCHAR(30)     NULL,  -- optional: template scoped to a tier
  rule_version_id      UNIQUEIDENTIFIER NOT NULL, -- FK to core.ref_uw_rule_version in Part 2
  effective_from       DATE             NOT NULL,
  effective_to         DATE             NULL,
  template_params_json NVARCHAR(MAX)    NULL,  -- ISJSON in Part 2
  created_at           DATETIME2(6)     NOT NULL CONSTRAINT DF_hlth_pauth_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_hlth_pre_auth_template PRIMARY KEY (pre_auth_template_id)
);
GO

/* 12) Exclusion/blacklist (fraud/compliance) */
IF OBJECT_ID('hlth.hlth_provider_exclusion','U') IS NULL
CREATE TABLE hlth.hlth_provider_exclusion (
  exclusion_id       UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_hlth_pexcl_id DEFAULT NEWID(),
  provider_org_id    UNIQUEIDENTIFIER NULL,
  provider_site_id   UNIQUEIDENTIFIER NULL,
  practitioner_id    UNIQUEIDENTIFIER NULL,
  reason_code        NVARCHAR(60)     NOT NULL,
  effective_from     DATE             NOT NULL,
  effective_to       DATE             NULL,
  notes_json         NVARCHAR(MAX)    NULL,    -- ISJSON in Part 2
  created_at         DATETIME2(6)     NOT NULL CONSTRAINT DF_hlth_pexcl_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_hlth_provider_exclusion PRIMARY KEY (exclusion_id)
);
GO
