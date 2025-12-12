/* ============================================================
   FCT — INSIGHTS  |  PART 1: Base tables + intra-row CHECKs
   Rerunnable: all CREATE TABLEs guarded with IF OBJECT_ID IS NULL
   ============================================================ */

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='fct')
  EXEC('CREATE SCHEMA fct');
GO

/* -----------------------
   Reference catalogs
   ----------------------- */

IF OBJECT_ID('fct.fct_ins_dq_rule_ref','U') IS NULL
CREATE TABLE fct.fct_ins_dq_rule_ref (
  dq_rule_id     UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_fct_ins_dq_rule_id DEFAULT NEWID(),
  dq_rule_code   NVARCHAR(60)  NOT NULL,
  dq_rule_name   NVARCHAR(200) NOT NULL,
  description    NVARCHAR(500) NULL,
  severity_code  NVARCHAR(30)  NULL,  -- INFO/WARN/CRITICAL
  CONSTRAINT PK_fct_ins_dq_rule_ref PRIMARY KEY (dq_rule_id)
);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_fct_ins_dq_rule_sev'
               AND parent_object_id=OBJECT_ID('fct.fct_ins_dq_rule_ref'))
ALTER TABLE fct.fct_ins_dq_rule_ref
  ADD CONSTRAINT CK_fct_ins_dq_rule_sev
  CHECK (severity_code IS NULL OR severity_code IN (N'INFO',N'WARN',N'CRITICAL'));
GO

IF OBJECT_ID('fct.fct_ins_kpi_ref','U') IS NULL
CREATE TABLE fct.fct_ins_kpi_ref (
  kpi_id        UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_fct_ins_kpi_id DEFAULT NEWID(),
  kpi_code      NVARCHAR(60)  NOT NULL,
  kpi_name      NVARCHAR(200) NOT NULL,
  unit_code     NVARCHAR(30)  NULL,
  description   NVARCHAR(500) NULL,
  CONSTRAINT PK_fct_ins_kpi_ref PRIMARY KEY (kpi_id)
);
GO

IF OBJECT_ID('fct.fct_ins_recon_rule_ref','U') IS NULL
CREATE TABLE fct.fct_ins_recon_rule_ref (
  recon_rule_id   UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_fct_ins_recon_rule_id DEFAULT NEWID(),
  recon_rule_code NVARCHAR(60)  NOT NULL,
  recon_rule_name NVARCHAR(200) NOT NULL,
  description     NVARCHAR(500) NULL,
  CONSTRAINT PK_fct_ins_recon_rule_ref PRIMARY KEY (recon_rule_id)
);
GO

/* -----------------------
   Data Quality results
   ----------------------- */

IF OBJECT_ID('fct.fct_ins_dq_result','U') IS NULL
CREATE TABLE fct.fct_ins_dq_result (
  dq_result_id     UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_fct_ins_dqres_id DEFAULT NEWID(),
  dq_rule_id       UNIQUEIDENTIFIER NOT NULL,
  period_id        UNIQUEIDENTIFIER NOT NULL,
  status_code      NVARCHAR(30) NOT NULL,     -- PASS/FAIL/WARN
  result_value_num DECIMAL(19,6) NULL,
  details_json     NVARCHAR(MAX) NULL,
  created_at       DATETIME2(6)  NOT NULL CONSTRAINT DF_fct_ins_dqres_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_fct_ins_dq_result PRIMARY KEY (dq_result_id)
);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_fct_ins_dqres_status'
               AND parent_object_id=OBJECT_ID('fct.fct_ins_dq_result'))
ALTER TABLE fct.fct_ins_dq_result
  ADD CONSTRAINT CK_fct_ins_dqres_status
  CHECK (status_code IN (N'PASS',N'FAIL',N'WARN'));
GO

/* -----------------------
   KPI instances (dim-anchored)
   ----------------------- */

IF OBJECT_ID('fct.fct_ins_kpi_instance','U') IS NULL
CREATE TABLE fct.fct_ins_kpi_instance (
  kpi_instance_id   UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_fct_ins_kpiinst_id DEFAULT NEWID(),
  kpi_id            UNIQUEIDENTIFIER NOT NULL,
  period_id         UNIQUEIDENTIFIER NOT NULL,
  instance_code     NVARCHAR(60) NULL,   -- label only, not in natural key
  currency_code     CHAR(3)      NOT NULL,
  value_num         DECIMAL(19,6) NOT NULL,

  dim1_dimension_id UNIQUEIDENTIFIER NULL,
  dim1_value_id     UNIQUEIDENTIFIER NULL,
  dim2_dimension_id UNIQUEIDENTIFIER NULL,
  dim2_value_id     UNIQUEIDENTIFIER NULL,
  dim3_dimension_id UNIQUEIDENTIFIER NULL,
  dim3_value_id     UNIQUEIDENTIFIER NULL,
  dim4_dimension_id UNIQUEIDENTIFIER NULL,
  dim4_value_id     UNIQUEIDENTIFIER NULL,
  dim5_dimension_id UNIQUEIDENTIFIER NULL,
  dim5_value_id     UNIQUEIDENTIFIER NULL,

  created_at        DATETIME2(6) NOT NULL CONSTRAINT DF_fct_ins_kpiinst_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_fct_ins_kpi_instance PRIMARY KEY (kpi_instance_id)
);
GO
-- Pairwise NULL discipline (all five slots)
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_fct_kpiinst_dim1_pair'
               AND parent_object_id=OBJECT_ID('fct.fct_ins_kpi_instance'))
ALTER TABLE fct.fct_ins_kpi_instance
  ADD CONSTRAINT CK_fct_kpiinst_dim1_pair CHECK (
    (dim1_dimension_id IS NULL AND dim1_value_id IS NULL) OR
    (dim1_dimension_id IS NOT NULL AND dim1_value_id IS NOT NULL)
  );
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_fct_kpiinst_dim2_pair'
               AND parent_object_id=OBJECT_ID('fct.fct_ins_kpi_instance'))
ALTER TABLE fct.fct_ins_kpi_instance
  ADD CONSTRAINT CK_fct_kpiinst_dim2_pair CHECK (
    (dim2_dimension_id IS NULL AND dim2_value_id IS NULL) OR
    (dim2_dimension_id IS NOT NULL AND dim2_value_id IS NOT NULL)
  );
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_fct_kpiinst_dim3_pair'
               AND parent_object_id=OBJECT_ID('fct.fct_ins_kpi_instance'))
ALTER TABLE fct.fct_ins_kpi_instance
  ADD CONSTRAINT CK_fct_kpiinst_dim3_pair CHECK (
    (dim3_dimension_id IS NULL AND dim3_value_id IS NULL) OR
    (dim3_dimension_id IS NOT NULL AND dim3_value_id IS NOT NULL)
  );
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_fct_kpiinst_dim4_pair'
               AND parent_object_id=OBJECT_ID('fct.fct_ins_kpi_instance'))
ALTER TABLE fct.fct_ins_kpi_instance
  ADD CONSTRAINT CK_fct_kpiinst_dim4_pair CHECK (
    (dim4_dimension_id IS NULL AND dim4_value_id IS NULL) OR
    (dim4_dimension_id IS NOT NULL AND dim4_value_id IS NOT NULL)
  );
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_fct_kpiinst_dim5_pair'
               AND parent_object_id=OBJECT_ID('fct.fct_ins_kpi_instance'))
ALTER TABLE fct.fct_ins_kpi_instance
  ADD CONSTRAINT CK_fct_kpiinst_dim5_pair CHECK (
    (dim5_dimension_id IS NULL AND dim5_value_id IS NULL) OR
    (dim5_dimension_id IS NOT NULL AND dim5_value_id IS NOT NULL)
  );
GO

/* -----------------------
   Reconciliation results
   ----------------------- */

IF OBJECT_ID('fct.fct_ins_recon_result','U') IS NULL
CREATE TABLE fct.fct_ins_recon_result (
  recon_result_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_fct_ins_reconres_id DEFAULT NEWID(),
  recon_rule_id   UNIQUEIDENTIFIER NOT NULL,
  period_id       UNIQUEIDENTIFIER NOT NULL,
  currency_code   CHAR(3)      NOT NULL,
  left_amount     DECIMAL(19,6) NULL,
  right_amount    DECIMAL(19,6) NULL,
  diff_amount     DECIMAL(19,6) NULL,
  status_code     NVARCHAR(30) NOT NULL,   -- OK/WARN/FAIL
  details_json    NVARCHAR(MAX) NULL,
  created_at      DATETIME2(6)  NOT NULL CONSTRAINT DF_fct_ins_reconres_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_fct_ins_recon_result PRIMARY KEY (recon_result_id)
);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_fct_ins_reconres_status'
               AND parent_object_id=OBJECT_ID('fct.fct_ins_recon_result'))
ALTER TABLE fct.fct_ins_recon_result
  ADD CONSTRAINT CK_fct_ins_reconres_status
  CHECK (status_code IN (N'OK',N'WARN',N'FAIL'));
GO

/* -----------------------
   Alerts / breaches
   ----------------------- */

IF OBJECT_ID('fct.fct_ins_alert','U') IS NULL
CREATE TABLE fct.fct_ins_alert (
  alert_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_fct_ins_alert_id DEFAULT NEWID(),
  source_type   NVARCHAR(40)  NOT NULL,   -- DQ/KPI/RECON
  source_id     UNIQUEIDENTIFIER NOT NULL,
  period_id     UNIQUEIDENTIFIER NOT NULL,
  severity_code NVARCHAR(30)  NOT NULL,   -- INFO/WARN/CRITICAL
  status_code   NVARCHAR(30)  NOT NULL,   -- OPEN/ACK/CLOSED
  message       NVARCHAR(500) NULL,
  created_at    DATETIME2(6)  NOT NULL CONSTRAINT DF_fct_ins_alert_created DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_fct_ins_alert PRIMARY KEY (alert_id)
);
GO
-- Intra-row enumerations for alerts
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_fct_ins_alert_source'
               AND parent_object_id=OBJECT_ID('fct.fct_ins_alert'))
ALTER TABLE fct.fct_ins_alert
  ADD CONSTRAINT CK_fct_ins_alert_source
  CHECK (source_type IN (N'DQ',N'KPI',N'RECON'));
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_fct_ins_alert_sev'
               AND parent_object_id=OBJECT_ID('fct.fct_ins_alert'))
ALTER TABLE fct.fct_ins_alert
  ADD CONSTRAINT CK_fct_ins_alert_sev
  CHECK (severity_code IN (N'INFO',N'WARN',N'CRITICAL'));
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_fct_ins_alert_status'
               AND parent_object_id=OBJECT_ID('fct.fct_ins_alert'))
ALTER TABLE fct.fct_ins_alert
  ADD CONSTRAINT CK_fct_ins_alert_status
  CHECK (status_code IN (N'OPEN',N'ACK',N'CLOSED'));
GO
