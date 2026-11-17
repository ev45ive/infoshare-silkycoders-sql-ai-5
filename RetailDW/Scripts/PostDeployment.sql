PRINT N'Starting RetailDW dimension seed.';
GO
:r .\Seed\00-DimDate.sql
GO
:r .\Seed\01-DimProduct.sql
GO
:r .\Seed\02-DimStore.sql
GO
PRINT N'RetailDW dimensions are ready. Import P0 and run ETL separately with scripts/dw.ps1.';
GO
