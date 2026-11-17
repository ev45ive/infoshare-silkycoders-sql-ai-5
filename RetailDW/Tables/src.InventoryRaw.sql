/*
    Landing zone for the nightly stock feed sent by the warehouse system (WMS).

    The daily export can include multiple stores. One row represents a
    store / SKU / day observation of the closing stock level.
*/
CREATE TABLE [src].[InventoryRaw]
(
    [RawId]         BIGINT         IDENTITY (1, 1) NOT NULL,
    [SnapshotDate]  NVARCHAR (20)  NULL,
    [SKU]           NVARCHAR (40)  NULL,
    [StoreCode]     NVARCHAR (20)  NULL,
    [StockQuantity] NVARCHAR (20)  NULL,
    [SourceFile]    NVARCHAR (100) NULL,
    [ExtractedAt]   DATETIME2 (3)  NOT NULL CONSTRAINT [DF_src_InventoryRaw_ExtractedAt] DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT [PK_src_InventoryRaw] PRIMARY KEY CLUSTERED ([RawId] ASC)
);
