## SQL Style Guide – Data Warehouse (T-SQL, SQL Server 2022)

Wzorzec stylu i konwencji dla kodu SQL w hurtowni danych sprzedaży firmy odzieżowej (retail). Dokument opisuje zasady nazewnictwa, warstwy schematów, modelowanie wymiarowe (Kimball), formatowanie zapytań oraz gotowe przykłady: DDL, SELECT, procedurę i widok.

- **Data:** 2026-11-17
- **Autor:** Mateusz Kulesza (ev45ive@gmail.com)
- **Wersja:** 1.0

### Spis treści

- [Zasady ogólne](#zasady-ogolne)
- [Nazewnictwo obiektów](#nazewnictwo-obiektow)
- [Konwencje nazw ograniczeń](#konwencje-nazw-ograniczen)
- [Warstwy i schematy](#warstwy-i-schematy)
- [Modelowanie wymiarowe (Kimball)](#modelowanie-wymiarowe-kimball)
- [Formatowanie i komentarze](#formatowanie-i-komentarze)
- [Przykłady](#przyklady)
  - [DDL – tabela faktów](#ddl--tabela-faktow)
  - [SELECT – zapytanie raportowe](#select--zapytanie-raportowe)
  - [Procedura – ładowanie wymiaru](#procedura--ladowanie-wymiaru)
  - [View – widok dla raportów](#view--widok-dla-raportow)

### Zasady ogólne

- Składnia: T-SQL, SQL Server 2022.
- Nazwy obiektów, kolumn, aliasów i parametrów: **PascalCase**, po angielsku.
- Komentarze w kodzie: po angielsku, wyłącznie tam, gdzie logika nie jest oczywista.
- Kod SQL zawsze w skryptach wersjonowanych w repozytorium; bez hardcodowanych dat i wartości środowiskowych.
- Słowa kluczowe SQL wielkimi literami (`SELECT`, `FROM`, `JOIN`).

### Nazewnictwo obiektów

- Tabele wymiarów: `Dim<Name>` (np. `DimProduct`), tabele faktów: `Fact<Name>` (np. `FactSales`).
- Klucze surogatowe: `<Name>Key` typu `int` (wymiary) lub `bigint` (fakty).
- Klucz daty: `DateKey` w formacie `yyyyMMdd` (`int`).
- Kolumny miar: nazwy opisowe, bez skrótów (`GrossAmount`, `Quantity`).
- Atrybuty niepewne / nieznane: wiersz członka `Unknown` z kluczem `-1`.
- Aliasy: krótkie, stałe, zgodne z nazwą obiektu (`fs` = FactSales, `dp` = DimProduct).

| Obiekt | Wzorzec nazwy | Przykład |
|---|---|---|
| Tabela wymiaru | `Dim<Name>` | `DimProduct` |
| Tabela faktów | `Fact<Name>` | `FactSales` |
| Widok raportowy | `vw_<Name>` lub `Rpt.<Name>` | `Rpt.MonthlySales` |
| Procedura ETL | `usp_<Layer>_<Target>` | `usp_Etl_LoadDimProduct` |

### Konwencje nazw ograniczeń

| Prefiks | Znaczenie | Wzorzec | Przykład |
|---|---|---|---|
| `PK_` | Klucz główny | `PK_<Table>` | `PK_FactSales` |
| `FK_` | Klucz obcy | `FK_<Table>_<RefTable>` | `FK_FactSales_DimProduct` |
| `UQ_` | Unikalność | `UQ_<Table>_<Columns>` | `UQ_FactSales_OrderNumber_LineNumber` |
| `IX_` | Indeks | `IX_<Table>_<Columns>` | `IX_FactSales_ProductKey` |
| `DF_` | Wartość domyślna | `DF_<Table>_<Column>` | `DF_FactSales_Quantity` |

Nazwy ograniczeń zawsze podajemy jawnie – systemowe nazwy generowane przez SQL Server są niestabilne między środowiskami.

### Warstwy i schematy

| Schemat | Rola | Kto zapisuje | Kto czyta |
|---|---|---|---|
| `stg` | Staging – surowe dane ze źródeł, bez przekształceń | Proces ładowania | `etl` |
| `etl` | Logika transformacji, procedury `usp_Etl_*`, tabele pomocnicze | Procesy ETL | `etl` |
| `dwh` | Model gwiaździsty (wymiary i fakty) | `etl` | `rpt`, analitycy |
| `rpt` | Widoki i zapytania dla raportów (read-only) | Zespół DWH | BI, raporty |

Zasada: warstwa wyższa czyta tylko z warstwy niższej, nigdy odwrotnie.

### Modelowanie wymiarowe (Kimball)

- Każda tabela faktów ma jasno zdefiniowany **grain** (poziom szczegółowości) opisany w dokumentacji obiektu.
- Wymiary są **conformed** – ten sam `DimDate` i `DimProduct` we wszystkich tabelach faktów.
- Wymiary są **denormalizowane** (płaska struktura, np. `CategoryName` w `DimProduct`).
- Wymiary wolno zmieniające się (SCD): typ 1 (nadpisanie) lub typ 2 (`ValidFrom`, `ValidTo`, `IsCurrent`).
- Dane transakcyjne bez własnej tabeli wymiaru (np. numer zamówienia) przechowujemy jako **degenerate dimension** w tabeli faktów.
- Każdy wymiar ma wiersz `Unknown` (`<Name>Key = -1`), dzięki czemu `INNER JOIN` nie gubi wierszy faktów.

| Termin | Znaczenie w projekcie |
|---|---|
| Grain | Jeden wiersz faktu = jedna pozycja zamówienia (`OrderNumber`, `LineNumber`) |
| Conformed dimension | `DimDate`, `DimProduct`, `DimChannel` – wspólne dla wielu faktów |
| Surrogate key | Klucz `<Name>Key`, niezależny od kluczy źródłowych |
| Additive measure | `Quantity`, `GrossAmount`, `DiscountAmount` – sumowalne po wszystkich wymiarach |

### Formatowanie i komentarze

- Wcięcia: 4 spacje. Każda kolumna w `SELECT` i każdy warunek w `WHERE`/`JOIN` w osobnej linii.
- Aliasy kolumn przez `AS`, zawsze po PascalCase.
- Nagłówek każdej procedury, widoku i większego zapytania: blok komentarza z nazwą, celem, grainem i źródłem.
- Komentarz inline tylko przy nieoczywistej logice (np. filtr statusu, wartość `-1`, obliczenie marży).
- Nie komentujemy oczywistego kodu.

### Przykłady

#### DDL – tabela faktów

```sql
/*
    Table:    Dwh.FactSales
    Purpose:  Sales transactions at order line grain
    Grain:    One row per OrderNumber and LineNumber
    Layer:    Dwh (star schema)
*/
CREATE TABLE Dwh.FactSales
(
    SalesKey        bigint        NOT NULL IDENTITY(1,1),
    DateKey         int           NOT NULL,
    ProductKey      int           NOT NULL,
    ChannelKey      int           NOT NULL,
    OrderStatusKey  int           NOT NULL,
    OrderNumber     varchar(20)   NOT NULL,   -- degenerate dimension, no separate table
    LineNumber      smallint      NOT NULL,
    Quantity        int           NOT NULL CONSTRAINT DF_FactSales_Quantity DEFAULT (0),
    GrossAmount     decimal(18,2) NOT NULL,
    DiscountAmount  decimal(18,2) NOT NULL CONSTRAINT DF_FactSales_DiscountAmount DEFAULT (0),
    UnitCost        decimal(18,2) NOT NULL,

    CONSTRAINT PK_FactSales PRIMARY KEY CLUSTERED (SalesKey),
    CONSTRAINT UQ_FactSales_OrderNumber_LineNumber UNIQUE (OrderNumber, LineNumber),
    CONSTRAINT FK_FactSales_DimDate        FOREIGN KEY (DateKey)        REFERENCES Dwh.DimDate (DateKey),
    CONSTRAINT FK_FactSales_DimProduct     FOREIGN KEY (ProductKey)     REFERENCES Dwh.DimProduct (ProductKey),
    CONSTRAINT FK_FactSales_DimChannel     FOREIGN KEY (ChannelKey)     REFERENCES Dwh.DimChannel (ChannelKey),
    CONSTRAINT FK_FactSales_DimOrderStatus FOREIGN KEY (OrderStatusKey) REFERENCES Dwh.DimOrderStatus (OrderStatusKey)
);

CREATE NONCLUSTERED INDEX IX_FactSales_ProductKey ON Dwh.FactSales (ProductKey);
```

| Element | Wyjaśnienie |
|---|---|
| `SalesKey` | Klucz surogatowy tabeli faktów (`PK_FactSales`) |
| `OrderNumber`, `LineNumber` | Degenerate dimension, chroni przed duplikatami (`UQ_`) |
| `DF_` | Nazwane wartości domyślne – można je później zmienić skryptem |
| `IX_FactSales_ProductKey` | Indeks pod częste filtrowanie po produkcie |

#### SELECT – zapytanie raportowe

```sql
/*
    Query:    Rpt.MonthlySalesByCategoryChannel (ad-hoc form)
    Purpose:  Monthly net sales, margin and share by category and channel
    Grain:    One row per CalendarYear, CalendarMonth, CategoryName, SeasonName, ChannelName
    Source:   Dwh.FactSales and conformed dimensions
*/

-- Reporting window: 12 full calendar months before the current month
DECLARE @StartDate date = DATEADD(MONTH, -12, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1));
DECLARE @EndDate   date = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);

WITH SalesByCategory AS
(
    SELECT
        dd.CalendarYear,
        dd.CalendarMonth,
        dp.CategoryName,
        dp.SeasonName,
        dc.ChannelName,
        SUM(fs.Quantity)                        AS UnitsSold,
        SUM(fs.GrossAmount - fs.DiscountAmount) AS NetSalesAmount,
        SUM(fs.Quantity * fs.UnitCost)          AS CostOfSalesAmount
    FROM Dwh.FactSales AS fs
    INNER JOIN Dwh.DimDate        AS dd  ON dd.DateKey        = fs.DateKey
    INNER JOIN Dwh.DimProduct     AS dp  ON dp.ProductKey     = fs.ProductKey
    INNER JOIN Dwh.DimChannel     AS dc  ON dc.ChannelKey     = fs.ChannelKey
    INNER JOIN Dwh.DimOrderStatus AS dos ON dos.OrderStatusKey = fs.OrderStatusKey
    WHERE dd.FullDate >= @StartDate
      AND dd.FullDate <  @EndDate
      AND dos.StatusName = 'Fulfilled'   -- excludes cancelled orders and returns
    GROUP BY
        dd.CalendarYear,
        dd.CalendarMonth,
        dp.CategoryName,
        dp.SeasonName,
        dc.ChannelName
)
SELECT
    s.CalendarYear,
    s.CalendarMonth,
    s.CategoryName,
    s.SeasonName,
    s.ChannelName,
    s.UnitsSold,
    s.NetSalesAmount,
    s.NetSalesAmount - s.CostOfSalesAmount AS MarginAmount,
    CAST(100.0 * (s.NetSalesAmount - s.CostOfSalesAmount)
         / NULLIF(s.NetSalesAmount, 0) AS decimal(9,4)) AS MarginPercent,
    -- Share of the row in total net sales of the same month
    CAST(100.0 * s.NetSalesAmount
         / NULLIF(SUM(s.NetSalesAmount) OVER (PARTITION BY s.CalendarYear, s.CalendarMonth), 0)
         AS decimal(9,4)) AS MonthlySalesSharePercent,
    -- Running total per category and channel
    SUM(s.NetSalesAmount) OVER (
        PARTITION BY s.CategoryName, s.ChannelName
        ORDER BY s.CalendarYear, s.CalendarMonth
        ROWS UNBOUNDED PRECEDING) AS NetSalesYearToDate
FROM SalesByCategory AS s
ORDER BY
    s.CalendarYear,
    s.CalendarMonth,
    s.NetSalesAmount DESC;
```

| Element | Wyjaśnienie |
|---|---|
| `DATEFROMPARTS(...)` | Zakres pełnych miesięcy bez zależności od formatu daty serwera |
| `CTE SalesByCategory` | Agregacja na grain raportu, dopiero potem funkcje okna |
| `NULLIF(..., 0)` | Ochrona przed dzieleniem przez zero |
| `Fulfilled` | Wyklucza anulowane zamówienia i zwroty |
| `ROWS UNBOUNDED PRECEDING` | Narastające sumy od początku okna |

#### Procedura – ładowanie wymiaru

```sql
/*
    Procedure: Etl.usp_Etl_LoadDimProduct
    Purpose:   SCD type 1 load of product dimension from staging
    Source:    Stg.Product
    Target:    Dwh.DimProduct
*/
CREATE OR ALTER PROCEDURE Etl.usp_Etl_LoadDimProduct
    @BatchId int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    -- Metrics for the ETL log
    DECLARE @RowsUpdated int = 0;
    DECLARE @RowsInserted int = 0;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Type 1: overwrite changed attributes (matched by business key)
        UPDATE dp
        SET
            dp.ProductName  = sp.ProductName,
            dp.CategoryName = sp.CategoryName,
            dp.SeasonName   = sp.SeasonName,
            dp.UpdatedAt    = SYSUTCDATETIME()
        FROM Dwh.DimProduct AS dp
        INNER JOIN Stg.Product AS sp
            ON sp.ProductCode = dp.ProductCode
        WHERE sp.BatchId = @BatchId
          -- NULL-safe comparison: EXCEPT treats two NULLs as equal
          AND EXISTS (
                SELECT sp.ProductName, sp.CategoryName, sp.SeasonName
                EXCEPT
                SELECT dp.ProductName, dp.CategoryName, dp.SeasonName);

        SET @RowsUpdated = @@ROWCOUNT;

        -- New business keys get a new surrogate key (IDENTITY on DimProduct)
        INSERT INTO Dwh.DimProduct (ProductCode, ProductName, CategoryName, SeasonName, CreatedAt, UpdatedAt)
        SELECT
            sp.ProductCode,
            sp.ProductName,
            sp.CategoryName,
            sp.SeasonName,
            SYSUTCDATETIME(),
            SYSUTCDATETIME()
        FROM Stg.Product AS sp
        WHERE sp.BatchId = @BatchId
          AND NOT EXISTS (
                SELECT 1
                FROM Dwh.DimProduct AS dp
                WHERE dp.ProductCode = sp.ProductCode);

        SET @RowsInserted = @@ROWCOUNT;

        COMMIT TRANSACTION;

        SELECT
            @RowsInserted AS RowsInserted,
            @RowsUpdated  AS RowsUpdated;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
```

| Element | Wyjaśnienie |
|---|---|
| `Etl.usp_Etl_` | Prefiks warstwy i procesu w nazwie procedury |
| `SET XACT_ABORT ON` + `TRY/CATCH` | Pełna transakcja: albo wszystkie zmiany, albo żadna |
| `EXISTS ... EXCEPT` | Porównanie NULL-safe, pomija rekordy bez zmian |
| `THROW` | Przekazanie błędu do harmonogramu ETL po wycofaniu |

#### View – widok dla raportów

```sql
/*
    View:     Rpt.vw_SalesByChannel
    Purpose:  Flat, read-only view for BI tools (Power BI)
    Layer:    Rpt (reads only from Dwh)
*/
CREATE OR ALTER VIEW Rpt.vw_SalesByChannel
AS
SELECT
    dd.FullDate,
    dd.CalendarYear,
    dd.CalendarMonth,
    dc.ChannelName,
    dp.CategoryName,
    dp.SeasonName,
    SUM(fs.Quantity)                        AS UnitsSold,
    SUM(fs.GrossAmount - fs.DiscountAmount) AS NetSalesAmount
FROM Dwh.FactSales AS fs
INNER JOIN Dwh.DimDate    AS dd ON dd.DateKey    = fs.DateKey
INNER JOIN Dwh.DimChannel AS dc ON dc.ChannelKey = fs.ChannelKey
INNER JOIN Dwh.DimProduct AS dp ON dp.ProductKey = fs.ProductKey
-- Unknown members (key -1) are kept; reporting shows them as "Unknown"
GROUP BY
    dd.FullDate,
    dd.CalendarYear,
    dd.CalendarMonth,
    dc.ChannelName,
    dp.CategoryName,
    dp.SeasonName;
GO
```

| Element | Wyjaśnienie |
|---|---|
| `Rpt.vw_` | Widok w warstwie raportowej, tylko do odczytu |
| `CREATE OR ALTER` | Idempotentny skrypt wdrożeniowy (SQL Server 2016+) |
| Brak logiki biznesowej | Filtry statusu i zakresów dat zostawiamy zapytaniom raportowym |
