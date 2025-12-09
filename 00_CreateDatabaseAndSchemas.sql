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
IF SCHEMA_ID('core') IS NULL EXEC('CREATE SCHEMA core');
IF SCHEMA_ID('pc')   IS NULL EXEC('CREATE SCHEMA pc');
IF SCHEMA_ID('lp')   IS NULL EXEC('CREATE SCHEMA lp');
IF SCHEMA_ID('hlth') IS NULL EXEC('CREATE SCHEMA hlth');
IF SCHEMA_ID('cid')  IS NULL EXEC('CREATE SCHEMA cid');
IF SCHEMA_ID('fct')  IS NULL EXEC('CREATE SCHEMA fct');
IF SCHEMA_ID('rar')  IS NULL EXEC('CREATE SCHEMA rar');
IF SCHEMA_ID('ss')   IS NULL EXEC('CREATE SCHEMA ss');
GO
