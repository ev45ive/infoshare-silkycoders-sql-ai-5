---
description: "Wyszukiwanie i analiza obiektów RetailDW: tabele, wymiary, fakty, relacje, widoki."
applyTo: "RetailDW/Tables/**,RetailDW/Views/**,RetailDW/Procedures/**"
---

# RetailDW – schemat i obiekty

Pełna dokumentacja: [retaildw-database.md](../../docs/retaildw-database.md). Ta instrukcja to ściąga do szybkiego wyszukiwania. Kolumny i indeksy zawsze sprawdzaj w pliku definicji.

## Gdzie szukać definicji

| Obiekt | Plik |
|---|---|
| Wymiar / fakt / audyt (`dbo`) | `RetailDW/Tables/dbo.<Name>.sql` |
| Landing (`src`) | `RetailDW/Tables/src.<Name>Raw.sql` |
| Staging (`stg`) | `RetailDW/Tables/stg.<Name>.sql` |
| Procedura ETL | `RetailDW/Procedures/etl.Load<Name>.sql` |
| Widok raportowy | `RetailDW/Views/reporting.vw_<Name>.sql` |
| Schemat | `RetailDW/Security/<schema>.sql` |

## Model gwiaździsty

| Obiekt | Typ | Ziarno | Klucz | Wymiary (FK) |
|---|---|---|---|---|
| `dbo.FactSales` | fakt | pozycja paragonu (SKU w transakcji) | `SalesKey` BIGINT | `DateKey`, `ProductKey`, `StoreKey` |
| `dbo.FactReturns` | fakt | pozycja zwrotu | `ReturnKey` BIGINT | `DateKey`, `ProductKey`, `StoreKey` |
| `dbo.FactInventoryDaily` | fakt (snapshot) | dzień × SKU × sklep | `InventoryKey` BIGINT | `DateKey`, `ProductKey`, `StoreKey` |
| `dbo.DimDate` | wymiar | dzień | `DateKey` INT `yyyymmdd` | – |
| `dbo.DimProduct` | wymiar | SKU | `ProductKey` INT IDENTITY | – |
| `dbo.DimStore` | wymiar | sklep lub online | `StoreKey` INT IDENTITY | – |
| `dbo.LoadLog` | audyt | jedno uruchomienie ETL | `LoadId` INT IDENTITY | – |

## Relacje i klucze

- Fakty łączą się z wymiarami wyłącznie przez surogaty (`*Key`), nie przez kody biznesowe.
- Kody biznesowe: `DimProduct.SKU`, `DimStore.StoreCode`, `DimDate.Date`. Są unikalne (indeksy `UX_*`).
- Degenerate dimensions w faktach: `TransactionNo`, `LineNumber`, `ReturnNo`, `ReturnReason`.
- `FactReturns` łączy się z `FactSales` po `TransactionNo` i `ProductKey`. Nie ma klucza obcego.
- `DimDate.Date` i `DimDate.DateKey` opisują ten sam dzień. Przy łączeniu z `src`/`stg` używaj `Date`.

## Zasady wyszukiwania

- Nazwy obiektów, kolumn i aliasy sprawdzaj w plikach `Tables/`, `Views/`, `Procedures/`. Nie zgaduj.
- Przy pytaniu o relację najpierw sprawdź klucze obce w definicji tabeli faktu.
- Przy pytaniu o miarę sprawdź definicję w widoku lub w procedurze, bo wzory (np. `NetAmount`) są tam.
- Przy pytaniu „co liczy widok” czytaj nagłówek komentarza w pliku widoku.
- Nie czytaj `data/`. Dane są w bazie, nie w repo.

## Konwencje w obiektach

- Nazwy: PascalCase, po angielsku, bez skrótów w miarach.
- Tabele faktów: `Fact<Name>`. Wymiary: `Dim<Name>`. Widoki: `reporting.vw_<Name>`.
- Klucze nazywane jawnie: `PK_<Table>`, `FK_<Table>_<Ref>`, `UX_<Table>_<Column>`, `IX_<Table>_<Columns>`, `DF_<Table>_<Column>`, `CK_<Table>_<Column>`.
- Każdy plik ma nagłówek komentarza z opisem, ziarnem i źródłem. Zachowaj ten wzorzec w nowych obiektach.
