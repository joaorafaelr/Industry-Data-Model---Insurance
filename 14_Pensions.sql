/* ============================================================
   LIFE & PENSIONS → PENSIONS — PART 1 (TABLES, NO RELATIONSHIPS)
   - All FKs deferred to Part 2
   - PK/UNIQUE/CHECK/DEFAULT inline
   - Fixes applied:
     • Removed redundant UQ on lp_pension_allocation (PK already covers)
     • Removed membership UQ that involved NULL policy_id (to avoid “one NULL” problem);
       membership uniqueness will be enforced via a filtered UNIQUE in Part 2
   ============================================================ */

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='lp') EXEC('CREATE SCHEMA lp');
GO

/* ------------------------------
   Reference catalogs
   ------------------------------ */

IF OBJECT_ID('lp.ref_pension_scheme_type','U') IS NULL
CREATE TABLE lp.ref_pension_scheme_type (
  scheme_type_code  NVARCHAR(30) NOT NULL,
  scheme_type_name  NVARCHAR(120) NULL,
  description       NVARCHAR(500) NULL,
  CONSTRAINT PK_lp_ref_pension_scheme_type PRIMARY KEY (scheme_type_code)
);

IF OBJECT_ID('lp.ref_contribution_type','U') IS NULL
CREATE TABLE lp.ref_contribution_type (
  contribution_type_code NVARCHAR(30) NOT NULL,  -- EMPLOYEE/EMPLOYER/VOLUNTARY…
  contribution_type_name NVARCHAR(120) NULL,
  description            NVARCHAR(500) NULL,
  CONSTRAINT PK_lp_ref_contribution_type PRIMARY KEY (contribution_type_code)
);

IF OBJECT_ID('lp.ref_contribution_frequency','U') IS NULL
CREATE TABLE lp.ref_contribution_frequency (
  frequency_code    NVARCHAR(30) NOT NULL,       -- MONTHLY/QUARTERLY/ANNUAL/ADHOC
  frequency_name    NVARCHAR(120) NULL,
  months_interval   TINYINT NULL,                -- 1..12; NULL for ADHOC
  description       NVARCHAR(500) NULL,
  CONSTRAINT PK_lp_ref_contribution_frequency PRIMARY KEY (frequency_code),
  CONSTRAINT CK_lp_freq_months CHECK (months_interval IS NULL OR months_interval BETWEEN 1 AND 12)
);

IF OBJECT_ID('lp.ref_allocation_method','U') IS NULL
CREATE TABLE lp.ref_allocation_method (
  allocation_method_code NVARCHAR(30) NOT NULL,  -- TARGET_PERCENT/LIFESTYLE/AGE-BAND
  allocation_method_name NVARCHAR(120) NULL,
  description            NVARCHAR(500) NULL,
  CONSTRAINT PK_lp_ref_allocation_method PRIMARY KEY (allocation_method_code)
);

IF OBJECT_ID('lp.ref_vesting_type','U') IS NULL
CREATE TABLE lp.ref_vesting_type (
  vesting_type_code NVARCHAR(30) NOT NULL,       -- CLIFF/GRADED/IMMEDIATE
  vesting_type_name NVARCHAR(120) NULL,
  description       NVARCHAR(500) NULL,
  CONSTRAINT PK_lp_ref_vesting_type PRIMARY KEY (vesting_type_code)
);

IF OBJECT_ID('lp.ref_pension_event_type','U') IS NULL
CREATE TABLE lp.ref_pension_event_type (
  event_type_code NVARCHAR(30) NOT NULL,         -- RETIREMENT/DEATH/DISABILITY/WITHDRAWAL/TRANSFER_*
  event_type_name NVARCHAR(120) NULL,
  description     NVARCHAR(500) NULL,
  CONSTRAINT PK_lp_ref_pension_event_type PRIMARY KEY (event_type_code)
);

IF OBJECT_ID('lp.ref_annuity_option','U') IS NULL
CREATE TABLE lp.ref_annuity_option (
  annuity_option_code NVARCHAR(30) NOT NULL,     -- LIFE_ONLY/JOINT/PERIOD_CERTAIN/ESCALATING…
  annuity_option_name NVARCHAR(120) NULL,
  description         NVARCHAR(500) NULL,
  CONSTRAINT PK_lp_ref_annuity_option PRIMARY KEY (annuity_option_code)
);

IF OBJECT_ID('lp.ref_transfer_type','U') IS NULL
CREATE TABLE lp.ref_transfer_type (
  transfer_type_code NVARCHAR(30) NOT NULL,      -- INTRA-SCHEME/INTER-SCHEME/EXTERNAL
  transfer_type_name NVARCHAR(120) NULL,
  description        NVARCHAR(500) NULL,
  CONSTRAINT PK_lp_ref_transfer_type PRIMARY KEY (transfer_type_code)
);

/* ------------------------------
   Core objects (no FKs here)
   ------------------------------ */

IF OBJECT_ID('lp.lp_pension_scheme','U') IS NULL
CREATE TABLE lp.lp_pension_scheme (
  scheme_id           UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_lp_scheme_id DEFAULT NEWID(),
  scheme_code         NVARCHAR(60)     NOT NULL,
  scheme_name         NVARCHAR(200)    NOT NULL,
  scheme_type_code    NVARCHAR(30)     NULL,   -- FK in Part 2
  sponsor_entity_id   UNIQUEIDENTIFIER NULL,   -- FK in Part 2 (core.entity)
  status_code         NVARCHAR(20)     NOT NULL, -- ACTIVE/INACTIVE
  created_at          DATETIME2(6)     NOT NULL CONSTRAINT DF_lp_scheme_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_lp_pension_scheme PRIMARY KEY (scheme_id),
  CONSTRAINT UQ_lp_scheme_code UNIQUE (scheme_code),
  CONSTRAINT CK_lp_scheme_status CHECK (status_code IN (N'ACTIVE', N'INACTIVE'))
);

IF OBJECT_ID('lp.lp_pension_scheme_version','U') IS NULL
CREATE TABLE lp.lp_pension_scheme_version (
  scheme_version_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_lp_schemver_id DEFAULT NEWID(),
  scheme_id         UNIQUEIDENTIFIER NOT NULL,      -- FK in Part 2
  version_tag       NVARCHAR(60)     NOT NULL,
  effective_from    DATE             NOT NULL,
  effective_to      DATE             NULL,
  status_code       NVARCHAR(20)     NOT NULL,      -- DRAFT/ACTIVE/RETIRED
  ifrs17_rule_id    NVARCHAR(120)    NULL,
  actuarial_rule_id NVARCHAR(120)    NULL,
  notes_json        NVARCHAR(MAX)    NULL,
  created_at        DATETIME2(6)     NOT NULL CONSTRAINT DF_lp_schemver_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_lp_pension_scheme_version PRIMARY KEY (scheme_version_id),
  CONSTRAINT UQ_lp_schemver_nat UNIQUE (scheme_id, version_tag),
  CONSTRAINT CK_lp_schemver_dates CHECK (effective_to IS NULL OR effective_to >= effective_from),
  CONSTRAINT CK_lp_schemver_status CHECK (status_code IN (N'DRAFT', N'ACTIVE', N'RETIRED')),
  CONSTRAINT CK_lp_schemver_json CHECK (notes_json IS NULL OR ISJSON(notes_json)=1)
);

IF OBJECT_ID('lp.lp_pension_fund_catalog','U') IS NULL
CREATE TABLE lp.lp_pension_fund_catalog (
  fund_id          UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_lp_fund_id DEFAULT NEWID(),
  scheme_id        UNIQUEIDENTIFIER NOT NULL,      -- FK in Part 2
  fund_code        NVARCHAR(60)     NOT NULL,
  fund_name        NVARCHAR(200)    NOT NULL,
  asset_class_code NVARCHAR(40)     NULL,
  risk_level_code  NVARCHAR(40)     NULL,
  currency_code    CHAR(3)          NULL,          -- ISO text
  effective_from   DATE             NOT NULL,
  effective_to     DATE             NULL,
  is_default       BIT              NOT NULL CONSTRAINT DF_lp_fund_default DEFAULT (0),
  created_at       DATETIME2(6)     NOT NULL CONSTRAINT DF_lp_fund_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_lp_pension_fund_catalog PRIMARY KEY (fund_id),
  CONSTRAINT UQ_lp_fund_nat UNIQUE (scheme_id, fund_code, effective_from),
  CONSTRAINT CK_lp_fund_dates CHECK (effective_to IS NULL OR effective_to >= effective_from),
  CONSTRAINT CK_lp_fund_currency CHECK (currency_code IS NULL OR currency_code LIKE '[A-Z][A-Z][A-Z]')
);

IF OBJECT_ID('lp.lp_pension_membership','U') IS NULL
CREATE TABLE lp.lp_pension_membership (
  membership_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_lp_mem_id DEFAULT NEWID(),
  scheme_id          UNIQUEIDENTIFIER NOT NULL,    -- FK in Part 2
  policy_id          UNIQUEIDENTIFIER NULL,        -- optional link to core_policy
  person_entity_id   UNIQUEIDENTIFIER NOT NULL,    -- FK in Part 2 (core.entity)
  employer_entity_id UNIQUEIDENTIFIER NULL,        -- FK in Part 2 (core.entity)
  status_code        NVARCHAR(20)     NOT NULL,    -- ACTIVE/SUSPENDED/TERMINATED
  enrolled_at        DATE             NOT NULL,
  created_at         DATETIME2(6)     NOT NULL CONSTRAINT DF_lp_mem_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_lp_pension_membership PRIMARY KEY (membership_id),
  CONSTRAINT CK_lp_mem_status CHECK (status_code IN (N'ACTIVE', N'SUSPENDED', N'TERMINATED'))
  -- NOTE: uniqueness by contract will be enforced in Part 2 via a filtered unique index (policy_id IS NOT NULL)
);

IF OBJECT_ID('lp.lp_pension_membership_term','U') IS NULL
CREATE TABLE lp.lp_pension_membership_term (
  membership_id  UNIQUEIDENTIFIER NOT NULL,   -- FK in Part 2
  effective_from DATE             NOT NULL,
  effective_to   DATE             NULL,
  status_code    NVARCHAR(20)     NOT NULL,
  employment_type_code NVARCHAR(40) NULL,
  salary_basis_amount  DECIMAL(19,4) NULL,
  salary_currency      CHAR(3)      NULL,
  notes_json     NVARCHAR(MAX)  NULL,
  CONSTRAINT PK_lp_pension_membership_term PRIMARY KEY (membership_id, effective_from),
  CONSTRAINT CK_lp_term_dates CHECK (effective_to IS NULL OR effective_to >= effective_from),
  CONSTRAINT CK_lp_salary_nonneg CHECK (salary_basis_amount IS NULL OR salary_basis_amount >= 0),
  CONSTRAINT CK_lp_term_salary_currency CHECK (salary_currency IS NULL OR salary_currency LIKE '[A-Z][A-Z][A-Z]'),
  CONSTRAINT CK_lp_term_json CHECK (notes_json IS NULL OR ISJSON(notes_json)=1)
);

IF OBJECT_ID('lp.lp_pension_contribution_schedule','U') IS NULL
CREATE TABLE lp.lp_pension_contribution_schedule (
  schedule_id            UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_lp_sched_id DEFAULT NEWID(),
  membership_id          UNIQUEIDENTIFIER NOT NULL,  -- FK in Part 2
  contribution_type_code NVARCHAR(30)     NOT NULL,  -- FK in Part 2
  frequency_code         NVARCHAR(30)     NOT NULL,  -- FK in Part 2
  effective_from         DATE             NOT NULL,
  effective_to           DATE             NULL,
  employee_rate_pct      DECIMAL(9,6)     NULL,      -- 0..1
  employer_rate_pct      DECIMAL(9,6)     NULL,      -- 0..1
  fixed_amount           DECIMAL(19,4)    NULL,
  currency_code          CHAR(3)          NULL,      -- required when fixed_amount set
  created_at             DATETIME2(6)     NOT NULL CONSTRAINT DF_lp_sched_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_lp_pension_contribution_schedule PRIMARY KEY (schedule_id),
  CONSTRAINT UQ_lp_sched_nat UNIQUE (membership_id, contribution_type_code, effective_from),
  CONSTRAINT CK_lp_sched_dates CHECK (effective_to IS NULL OR effective_to >= effective_from),
  CONSTRAINT CK_lp_sched_pct CHECK (
    (employee_rate_pct IS NULL OR (employee_rate_pct BETWEEN 0 AND 1)) AND
    (employer_rate_pct IS NULL OR (employer_rate_pct BETWEEN 0 AND 1))
  ),
  CONSTRAINT CK_lp_sched_shape_any CHECK (
    (employee_rate_pct IS NOT NULL) OR (employer_rate_pct IS NOT NULL) OR (fixed_amount IS NOT NULL)
  ),
  CONSTRAINT CK_lp_sched_xor CHECK (
    (fixed_amount IS NULL AND (employee_rate_pct IS NOT NULL OR employer_rate_pct IS NOT NULL))
    OR
    (fixed_amount IS NOT NULL AND employee_rate_pct IS NULL AND employer_rate_pct IS NULL)
  ),
  CONSTRAINT CK_lp_sched_currency CHECK (currency_code IS NULL OR currency_code LIKE '[A-Z][A-Z][A-Z]'),
  CONSTRAINT CK_lp_sched_money_shape CHECK (fixed_amount IS NULL OR currency_code IS NOT NULL),
  CONSTRAINT CK_lp_fixed_nonneg CHECK (fixed_amount IS NULL OR fixed_amount >= 0)
);

IF OBJECT_ID('lp.lp_pension_allocation','U') IS NULL
CREATE TABLE lp.lp_pension_allocation (
  membership_id       UNIQUEIDENTIFIER NOT NULL,   -- FK in Part 2
  fund_id             UNIQUEIDENTIFIER NOT NULL,   -- FK in Part 2
  effective_from      DATE             NOT NULL,
  effective_to        DATE             NULL,
  allocation_rate_pct DECIMAL(9,6)     NOT NULL,  -- 0..1
  allocation_method_code NVARCHAR(30)  NULL,      -- FK in Part 2 (optional)
  notes_json          NVARCHAR(MAX)    NULL,
  CONSTRAINT PK_lp_pension_allocation PRIMARY KEY (membership_id, fund_id, effective_from),
  -- (Removed redundant UNIQUE on same columns)
  CONSTRAINT CK_lp_alloc_dates CHECK (effective_to IS NULL OR effective_to >= effective_from),
  CONSTRAINT CK_lp_alloc_pct CHECK (allocation_rate_pct BETWEEN 0 AND 1),
  CONSTRAINT CK_lp_alloc_json CHECK (notes_json IS NULL OR ISJSON(notes_json)=1)
);

IF OBJECT_ID('lp.lp_pension_vesting_rule','U') IS NULL
CREATE TABLE lp.lp_pension_vesting_rule (
  vesting_rule_id    UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_lp_vrule_id DEFAULT NEWID(),
  scheme_version_id  UNIQUEIDENTIFIER NOT NULL,   -- FK in Part 2
  vesting_type_code  NVARCHAR(30)     NOT NULL,   -- FK in Part 2
  rule_code          NVARCHAR(60)     NOT NULL,   -- natural key within scheme_version
  rule_payload_json  NVARCHAR(MAX)    NULL,       -- params only; no amounts
  created_at         DATETIME2(6)     NOT NULL CONSTRAINT DF_lp_vrule_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_lp_pension_vesting_rule PRIMARY KEY (vesting_rule_id),
  CONSTRAINT UQ_lp_vrule_nat UNIQUE (scheme_version_id, rule_code),
  CONSTRAINT CK_lp_vrule_json CHECK (rule_payload_json IS NULL OR ISJSON(rule_payload_json)=1)
);

IF OBJECT_ID('lp.lp_pension_vesting_schedule','U') IS NULL
CREATE TABLE lp.lp_pension_vesting_schedule (
  membership_id    UNIQUEIDENTIFIER NOT NULL,    -- FK in Part 2
  vesting_date     DATE             NOT NULL,
  vested_rate_pct  DECIMAL(9,6)     NOT NULL,    -- 0..1
  source_rule_id   UNIQUEIDENTIFIER NULL,        -- FK in Part 2
  notes_json       NVARCHAR(MAX)    NULL,
  CONSTRAINT PK_lp_pension_vesting_schedule PRIMARY KEY (membership_id, vesting_date),
  CONSTRAINT CK_lp_vsched_pct CHECK (vested_rate_pct BETWEEN 0 AND 1),
  CONSTRAINT CK_lp_vsched_json CHECK (notes_json IS NULL OR ISJSON(notes_json)=1)
);

IF OBJECT_ID('lp.lp_pension_event','U') IS NULL
CREATE TABLE lp.lp_pension_event (
  event_id        UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_lp_event_id DEFAULT NEWID(),
  membership_id   UNIQUEIDENTIFIER NOT NULL,     -- FK in Part 2
  event_type_code NVARCHAR(30)     NOT NULL,     -- FK in Part 2
  event_date      DATE             NOT NULL,
  status_code     NVARCHAR(20)     NOT NULL,     -- REQUESTED/APPROVED/PROCESSED…
  external_ref_id NVARCHAR(120)    NULL,
  details_json    NVARCHAR(MAX)    NULL,         -- metadata; no payouts/rates
  created_at      DATETIME2(6)     NOT NULL CONSTRAINT DF_lp_event_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_lp_pension_event PRIMARY KEY (event_id),
  CONSTRAINT CK_lp_event_json CHECK (details_json IS NULL OR ISJSON(details_json)=1)
);

IF OBJECT_ID('lp.lp_pension_annuity_option','U') IS NULL
CREATE TABLE lp.lp_pension_annuity_option (
  membership_id       UNIQUEIDENTIFIER NOT NULL,  -- FK in Part 2
  effective_from      DATE             NOT NULL,
  annuity_option_code NVARCHAR(30)     NOT NULL,  -- FK in Part 2
  pricing_run_id      NVARCHAR(120)    NULL,
  actuarial_run_id    NVARCHAR(120)    NULL,
  params_json         NVARCHAR(MAX)    NULL,
  created_at          DATETIME2(6)     NOT NULL CONSTRAINT DF_lp_aopt_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_lp_pension_annuity_option PRIMARY KEY (membership_id, effective_from),
  CONSTRAINT CK_lp_aopt_json CHECK (params_json IS NULL OR ISJSON(params_json)=1)
);

IF OBJECT_ID('lp.lp_pension_transfer_instruction','U') IS NULL
CREATE TABLE lp.lp_pension_transfer_instruction (
  transfer_id       UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_lp_transf_id DEFAULT NEWID(),
  membership_id     UNIQUEIDENTIFIER NOT NULL,   -- FK in Part 2
  transfer_type_code NVARCHAR(30)    NOT NULL,   -- FK in Part 2
  transfer_date     DATE             NOT NULL,
  from_fund_id      UNIQUEIDENTIFIER NULL,       -- FK in Part 2
  to_fund_id        UNIQUEIDENTIFIER NULL,       -- FK in Part 2
  amount            DECIMAL(19,4)    NULL,
  currency_code     CHAR(3)          NOT NULL,   -- ISO text
  status_code       NVARCHAR(20)     NOT NULL,   -- REQUESTED/EXECUTED/CANCELLED
  notes_json        NVARCHAR(MAX)    NULL,
  created_at        DATETIME2(6)     NOT NULL CONSTRAINT DF_lp_transf_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_lp_pension_transfer_instruction PRIMARY KEY (transfer_id),
  CONSTRAINT CK_lp_transf_endpoints CHECK (
    (CASE WHEN from_fund_id IS NOT NULL THEN 1 ELSE 0 END +
     CASE WHEN to_fund_id   IS NOT NULL THEN 1 ELSE 0 END) >= 1
  ),
  CONSTRAINT CK_lp_transf_amount CHECK (amount IS NULL OR amount >= 0),
  CONSTRAINT CK_lp_transf_currency CHECK (currency_code LIKE '[A-Z][A-Z][A-Z]'),
  CONSTRAINT CK_lp_transf_status CHECK (status_code IN (N'REQUESTED', N'EXECUTED', N'CANCELLED')),
  CONSTRAINT CK_lp_transf_json CHECK (notes_json IS NULL OR ISJSON(notes_json)=1)
);

IF OBJECT_ID('lp.lp_pension_document_ref','U') IS NULL
CREATE TABLE lp.lp_pension_document_ref (
  document_id   UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_lp_doc_id DEFAULT NEWID(),
  scheme_id     UNIQUEIDENTIFIER NULL,    -- FK in Part 2
  membership_id UNIQUEIDENTIFIER NULL,    -- FK in Part 2
  event_id      UNIQUEIDENTIFIER NULL,    -- FK in Part 2
  doc_type_code NVARCHAR(40)     NULL,
  doc_uri       NVARCHAR(1000)   NOT NULL,
  doc_sha256    VARBINARY(32)    NULL,
  created_at    DATETIME2(6)     NOT NULL CONSTRAINT DF_lp_doc_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_lp_pension_document_ref PRIMARY KEY (document_id),
  CONSTRAINT CK_lp_doc_one_target CHECK (
    (CASE WHEN scheme_id     IS NOT NULL THEN 1 ELSE 0 END +
     CASE WHEN membership_id IS NOT NULL THEN 1 ELSE 0 END +
     CASE WHEN event_id      IS NOT NULL THEN 1 ELSE 0 END) = 1
  )
);

/* ------------------------------
   LP Extensions (governed attrs only)
   ------------------------------ */

IF OBJECT_ID('lp.lp_pension_membership_ext','U') IS NULL
CREATE TABLE lp.lp_pension_membership_ext (
  membership_id        UNIQUEIDENTIFIER NOT NULL,  -- FK in Part 2
  attribute_code       NVARCHAR(60)     NOT NULL,
  effective_from       DATE             NOT NULL,
  effective_to         DATE             NULL,
  attribute_value_txt  NVARCHAR(4000)   NULL,
  attribute_value_num  DECIMAL(19,6)    NULL,
  attribute_value_json NVARCHAR(MAX)    NULL,
  CONSTRAINT PK_lp_pension_membership_ext PRIMARY KEY (membership_id, attribute_code, effective_from),
  CONSTRAINT CK_lp_memext_dates CHECK (effective_to IS NULL OR effective_to >= effective_from),
  CONSTRAINT CK_lp_memext_json  CHECK (attribute_value_json IS NULL OR ISJSON(attribute_value_json)=1)
);

IF OBJECT_ID('lp.lp_pension_event_ext','U') IS NULL
CREATE TABLE lp.lp_pension_event_ext (
  event_id            UNIQUEIDENTIFIER NOT NULL,   -- FK in Part 2
  attribute_code      NVARCHAR(60)     NOT NULL,
  attribute_value_txt NVARCHAR(4000)   NULL,
  attribute_value_num DECIMAL(19,6)    NULL,
  attribute_value_json NVARCHAR(MAX)   NULL,
  created_at          DATETIME2(6)     NOT NULL CONSTRAINT DF_lp_eventext_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_lp_pension_event_ext PRIMARY KEY (event_id, attribute_code),
  CONSTRAINT CK_lp_eventext_json CHECK (attribute_value_json IS NULL OR ISJSON(attribute_value_json)=1)
);

IF OBJECT_ID('lp.lp_pension_scheme_ext','U') IS NULL
CREATE TABLE lp.lp_pension_scheme_ext (
  scheme_id           UNIQUEIDENTIFIER NOT NULL,   -- FK in Part 2
  scheme_version_id   UNIQUEIDENTIFIER NULL,       -- FK in Part 2
  attribute_code      NVARCHAR(60)     NOT NULL,
  effective_from      DATE             NOT NULL,
  effective_to        DATE             NULL,
  attribute_value_txt NVARCHAR(4000)   NULL,
  attribute_value_num DECIMAL(19,6)    NULL,
  attribute_value_json NVARCHAR(MAX)   NULL,
  CONSTRAINT PK_lp_pension_scheme_ext PRIMARY KEY (scheme_id, attribute_code, effective_from),
  CONSTRAINT CK_lp_schemeext_dates CHECK (effective_to IS NULL OR effective_to >= effective_from),
  CONSTRAINT CK_lp_schemeext_json  CHECK (attribute_value_json IS NULL OR ISJSON(attribute_value_json)=1)
);
GO
