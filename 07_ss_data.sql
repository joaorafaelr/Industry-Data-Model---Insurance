/* ============================================================
   Support Services → Data
   Enterprise Reference Data (Technical)
   File: sp_Data.sql
   Purpose: Central technical dictionaries shared by all domains
   ============================================================ */

USE InsuranceData;
GO


/* ============================================================
   1. ref_currency
      Enterprise-wide currency catalog (ISO 4217)
============================================================ */
IF OBJECT_ID('ss.data_ref_currency','U') IS NULL
CREATE TABLE ss.data_ref_currency (
    currency_code      CHAR(3)        NOT NULL,   -- ISO 4217 code (EUR, USD…)
    currency_name      NVARCHAR(100)  NOT NULL,   -- Euro, US Dollar, etc.
    numeric_code       CHAR(3)        NULL,       -- ISO 4217 numeric code
    minor_unit         TINYINT        NULL,       -- Decimal places (EUR=2)
    symbol             NVARCHAR(10)   NULL,       -- €, $, £ …
    is_active          BIT            NOT NULL
                      CONSTRAINT DF_data_ref_currency_active DEFAULT(1),
    created_at         DATETIME2(6)   NOT NULL
                      CONSTRAINT DF_data_ref_currency_created DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_data_ref_currency PRIMARY KEY CLUSTERED (currency_code)
);
GO
