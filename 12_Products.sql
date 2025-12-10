/* ============================================================
   PRODUCT — PART 1 (BASE)
   Tables ONLY: PKs, UNIQUEs, CHECKs, DEFAULTs (no FKs here)
   ============================================================ */

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='core')  EXEC('CREATE SCHEMA core');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='pc')    EXEC('CREATE SCHEMA pc');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='lp')    EXEC('CREATE SCHEMA lp');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='hlth')  EXEC('CREATE SCHEMA hlth');
GO

/* ============================================================
   1) Reference catalogs (under 'core', no separate ref schema)
============================================================ */
IF OBJECT_ID('core.ref_lob_attribute','U') IS NULL
CREATE TABLE core.ref_lob_attribute (
  lob_attribute_code NVARCHAR(60)   NOT NULL,
  lob_attribute_name NVARCHAR(200)  NULL,
  dtype              VARCHAR(30)    NULL,     -- NUMERIC, TEXT, ENUM, DATE, BOOL
  unit_code          NVARCHAR(30)   NULL,     -- e.g., EUR, YEARS, KM2
  description        NVARCHAR(500)  NULL,
  CONSTRAINT PK_ref_lob_attribute PRIMARY KEY (lob_attribute_code),
  CONSTRAINT CK_ref_lob_attr_dtype CHECK (dtype IN ('NUMERIC','TEXT','ENUM','DATE','BOOL'))
);
GO

IF OBJECT_ID('core.ref_coverage_kind','U') IS NULL
CREATE TABLE core.ref_coverage_kind (
  coverage_kind_code NVARCHAR(60)   NOT NULL,
  coverage_kind_name NVARCHAR(200)  NULL,
  description        NVARCHAR(500)  NULL,
  CONSTRAINT PK_ref_coverage_kind PRIMARY KEY (coverage_kind_code)
);
GO

/* ============================================================
   2) Product header
============================================================ */
IF OBJECT_ID('core.core_product','U') IS NULL
CREATE TABLE core.core_product (
  product_id    UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_core_product_id DEFAULT NEWID(),
  product_code  NVARCHAR(60)     NOT NULL,
  product_name  NVARCHAR(200)    NOT NULL,
  lob_code      NVARCHAR(20)     NULL,
  status_code   NVARCHAR(40)     NULL,    -- DRAFT, ACTIVE, RETIRED...
  created_at    DATETIME2(6)     NOT NULL CONSTRAINT DF_core_product_created DEFAULT SYSUTCDATETIME(),
  retired_at    DATETIME2(6)     NULL,
  description   NVARCHAR(500)    NULL,
  CONSTRAINT PK_core_product PRIMARY KEY (product_id),
  CONSTRAINT UQ_core_product_code UNIQUE (product_code),
  CONSTRAINT CK_core_product_lob CHECK (lob_code IS NULL OR lob_code IN (N'PC',N'LP',N'HLTH')),
  CONSTRAINT CK_core_product_dates CHECK (retired_at IS NULL OR retired_at >= created_at)
);
GO

/* ============================================================
   3) Product version (no pricing)
============================================================ */
IF OBJECT_ID('core.core_product_version','U') IS NULL
CREATE TABLE core.core_product_version (
  product_version_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_core_prodver_id DEFAULT NEWID(),
  product_id         UNIQUEIDENTIFIER NOT NULL,
  version_tag        NVARCHAR(60)     NOT NULL,   -- v1, 2025-12, etc.
  effective_from     DATE             NOT NULL,
  effective_to       DATE             NULL,
  regulatory_json    NVARCHAR(MAX)    NULL,       -- approvals/refs (no PHI, no pricing)
  created_at         DATETIME2(6)     NOT NULL CONSTRAINT DF_core_prodver_created DEFAULT SYSUTCDATETIME(),
  description        NVARCHAR(500)    NULL,
  CONSTRAINT PK_core_product_version PRIMARY KEY (product_version_id),
  CONSTRAINT UQ_core_prodver_nk UNIQUE (product_id, version_tag),
  CONSTRAINT CK_core_prodver_dates CHECK (effective_to IS NULL OR effective_to >= effective_from),
  CONSTRAINT CK_core_prodver_regjson CHECK (regulatory_json IS NULL OR ISJSON(regulatory_json)=1)
);
GO

/* ============================================================
   4) Product component (coverage/benefit/feature building block)
============================================================ */
IF OBJECT_ID('core.core_product_component','U') IS NULL
CREATE TABLE core.core_product_component (
  component_id          UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_core_prodcomp_id DEFAULT NEWID(),
  product_version_id    UNIQUEIDENTIFIER NOT NULL,
  component_code        NVARCHAR(60)     NOT NULL,
  component_name        NVARCHAR(200)    NOT NULL,
  coverage_kind_code    NVARCHAR(60)     NULL,  -- ref_coverage_kind
  mandatory_flag        CHAR(1)          NULL,  -- Y/N
  sum_insured_min       DECIMAL(19,4)    NULL,
  sum_insured_max       DECIMAL(19,4)    NULL,
  deductible_min        DECIMAL(19,4)    NULL,
  deductible_max        DECIMAL(19,4)    NULL,
  currency_code         CHAR(3)          NULL,  -- ISO 4217 text (no FK here)
  limits_json           NVARCHAR(MAX)    NULL,  -- limits structure
  conditions_json       NVARCHAR(MAX)    NULL,  -- textual/structured conditions
  created_at            DATETIME2(6)     NOT NULL CONSTRAINT DF_core_prodcomp_created DEFAULT SYSUTCDATETIME(),
  description           NVARCHAR(500)    NULL,
  CONSTRAINT PK_core_product_component PRIMARY KEY (component_id),
  CONSTRAINT UQ_core_prodcomp_nk UNIQUE (product_version_id, component_code),
  CONSTRAINT CK_core_prodcomp_flag CHECK (mandatory_flag IS NULL OR mandatory_flag IN ('Y','N')),
  CONSTRAINT CK_core_prodcomp_json1 CHECK (limits_json IS NULL OR ISJSON(limits_json)=1),
  CONSTRAINT CK_core_prodcomp_json2 CHECK (conditions_json IS NULL OR ISJSON(conditions_json)=1),
  CONSTRAINT CK_core_prodcomp_amounts CHECK (
    (sum_insured_min IS NULL OR sum_insured_min >= 0) AND
    (sum_insured_max IS NULL OR sum_insured_max >= 0) AND
    (deductible_min  IS NULL OR deductible_min  >= 0) AND
    (deductible_max  IS NULL OR deductible_max  >= 0) AND
    (sum_insured_min IS NULL OR sum_insured_max IS NULL OR sum_insured_max >= sum_insured_min) AND
    (deductible_min  IS NULL OR deductible_max  IS NULL OR deductible_max  >= deductible_min)
  )
);
GO

/* ============================================================
   5) Product option (parameterization within a component)
============================================================ */
IF OBJECT_ID('core.core_product_option','U') IS NULL
CREATE TABLE core.core_product_option (
  option_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_core_prodopt_id DEFAULT NEWID(),
  component_id   UNIQUEIDENTIFIER NOT NULL,
  option_code    NVARCHAR(60)     NOT NULL,
  option_name    NVARCHAR(200)    NULL,
  is_default     CHAR(1)          NULL,     -- Y/N
  value_num      DECIMAL(19,6)    NULL,
  value_txt      NVARCHAR(200)    NULL,
  value_json     NVARCHAR(MAX)    NULL,
  created_at     DATETIME2(6)     NOT NULL CONSTRAINT DF_core_prodopt_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_core_product_option PRIMARY KEY (option_id),
  CONSTRAINT UQ_core_prodopt_nk UNIQUE (component_id, option_code),
  CONSTRAINT CK_core_prodopt_default CHECK (is_default IS NULL OR is_default IN ('Y','N')),
  CONSTRAINT CK_core_prodopt_json CHECK (value_json IS NULL OR ISJSON(value_json)=1)
);
GO

/* ============================================================
   6) Product eligibility (catalog-based, no pricing)
============================================================ */
IF OBJECT_ID('core.core_product_eligibility_value','U') IS NULL
CREATE TABLE core.core_product_eligibility_value (
  eligibility_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_core_prodelig_id DEFAULT NEWID(),
  product_version_id  UNIQUEIDENTIFIER NOT NULL,
  lob_attribute_code  NVARCHAR(60)     NOT NULL,  -- ref_lob_attribute
  operator_code       NVARCHAR(20)     NOT NULL,  -- IN, NOT_IN, BETWEEN, >=, <=, =, !=
  value_txt           NVARCHAR(400)    NULL,      -- for ENUM/TEXT sets (CSV or list semantics in app)
  value_num_from      DECIMAL(19,6)    NULL,      -- for ranges
  value_num_to        DECIMAL(19,6)    NULL,
  value_json          NVARCHAR(MAX)    NULL,      -- complex eligibility payload if needed
  description         NVARCHAR(500)    NULL,
  created_at          DATETIME2(6)     NOT NULL CONSTRAINT DF_core_prodelig_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_core_product_eligibility_value PRIMARY KEY (eligibility_id),
  CONSTRAINT CK_core_prodelig_op CHECK (operator_code IN (N'IN',N'NOT_IN',N'BETWEEN',N'>=',N'<=',N'=',N'!=')),
  CONSTRAINT CK_core_prodelig_range CHECK (
    (operator_code <> N'BETWEEN') OR
    (value_num_from IS NOT NULL AND value_num_to IS NOT NULL AND value_num_to >= value_num_from)
  ),
  CONSTRAINT CK_core_prodelig_json CHECK (value_json IS NULL OR ISJSON(value_json)=1)
);
GO

/* ============================================================
   7) Distribution availability (where/when product can be sold)
============================================================ */
IF OBJECT_ID('core.core_product_distribution_availability','U') IS NULL
CREATE TABLE core.core_product_distribution_availability (
  availability_id   UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_core_proddist_id DEFAULT NEWID(),
  product_version_id UNIQUEIDENTIFIER NOT NULL,
  channel_code      NVARCHAR(40)     NOT NULL,
  jurisdiction      NVARCHAR(60)     NULL,
  country_code      NVARCHAR(10)     NULL,
  jurisdiction_norm AS ISNULL(jurisdiction, N'') PERSISTED,
  country_code_norm AS ISNULL(country_code, N'') PERSISTED,
  start_date        DATE             NOT NULL,
  end_date          DATE             NULL,
  status_code       NVARCHAR(30)     NULL,        -- AVAILABLE / UNAVAILABLE
  reason_code       NVARCHAR(60)     NULL,
  created_at        DATETIME2(6)     NOT NULL CONSTRAINT DF_core_proddist_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_core_product_distribution_availability PRIMARY KEY (availability_id),
  CONSTRAINT UQ_core_proddist_nat UNIQUE (product_version_id, channel_code, jurisdiction_norm, country_code_norm, start_date),
  CONSTRAINT CK_core_proddist_dates CHECK (end_date IS NULL OR end_date >= start_date)
);
GO

/* ============================================================
   8) Regulatory tags (labels for filings, KIDs, etc.)
============================================================ */
IF OBJECT_ID('core.core_product_regulatory_tag','U') IS NULL
CREATE TABLE core.core_product_regulatory_tag (
  tag_id            UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_core_prodrtag_id DEFAULT NEWID(),
  product_version_id UNIQUEIDENTIFIER NOT NULL,
  tag_code          NVARCHAR(60)     NOT NULL,
  tag_value         NVARCHAR(400)    NULL,
  effective_from    DATE             NOT NULL,
  effective_to      DATE             NULL,
  created_at        DATETIME2(6)     NOT NULL CONSTRAINT DF_core_prodrtag_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_core_product_regulatory_tag PRIMARY KEY (tag_id),
  CONSTRAINT UQ_core_prodrtag_nat UNIQUE (product_version_id, tag_code, effective_from),
  CONSTRAINT CK_core_prodrtag_dates CHECK (effective_to IS NULL OR effective_to >= effective_from)
);
GO

/* ============================================================
   9) LoB extensions (1–1 per component)
============================================================ */
IF OBJECT_ID('pc.pc_product_component_ext','U') IS NULL
CREATE TABLE pc.pc_product_component_ext (
  component_id              UNIQUEIDENTIFIER NOT NULL,
  vehicle_rules_json        NVARCHAR(MAX)    NULL,
  property_rules_json       NVARCHAR(MAX)    NULL,
  liability_rules_json      NVARCHAR(MAX)    NULL,
  CONSTRAINT PK_pc_prodcomp_ext PRIMARY KEY (component_id),
  CONSTRAINT CK_pc_prodcomp_json1 CHECK (vehicle_rules_json   IS NULL OR ISJSON(vehicle_rules_json)=1),
  CONSTRAINT CK_pc_prodcomp_json2 CHECK (property_rules_json  IS NULL OR ISJSON(property_rules_json)=1),
  CONSTRAINT CK_pc_prodcomp_json3 CHECK (liability_rules_json IS NULL OR ISJSON(liability_rules_json)=1)
);
GO

IF OBJECT_ID('lp.lp_product_component_ext','U') IS NULL
CREATE TABLE lp.lp_product_component_ext (
  component_id              UNIQUEIDENTIFIER NOT NULL,
  life_underwriting_json    NVARCHAR(MAX)    NULL,
  beneficiary_rules_json    NVARCHAR(MAX)    NULL,
  CONSTRAINT PK_lp_prodcomp_ext PRIMARY KEY (component_id),
  CONSTRAINT CK_lp_prodcomp_json1 CHECK (life_underwriting_json IS NULL OR ISJSON(life_underwriting_json)=1),
  CONSTRAINT CK_lp_prodcomp_json2 CHECK (beneficiary_rules_json IS NULL OR ISJSON(beneficiary_rules_json)=1)
);
GO

IF OBJECT_ID('hlth.hlth_product_component_ext','U') IS NULL
CREATE TABLE hlth.hlth_product_component_ext (
  component_id              UNIQUEIDENTIFIER NOT NULL,
  network_rules_json        NVARCHAR(MAX)    NULL,
  co_pay_rules_json         NVARCHAR(MAX)    NULL,
  CONSTRAINT PK_hlth_prodcomp_ext PRIMARY KEY (component_id),
  CONSTRAINT CK_hlth_prodcomp_json1 CHECK (network_rules_json IS NULL OR ISJSON(network_rules_json)=1),
  CONSTRAINT CK_hlth_prodcomp_json2 CHECK (co_pay_rules_json  IS NULL OR ISJSON(co_pay_rules_json)=1)
);
GO
