---
description: "Pisanie i edycja kodu T-SQL w RetailDW: tabele, procedury, widoki, składnia i komentarze."
applyTo: "RetailDW/**/*.sql"
---

# RetailDW – pisanie kodu SQL

Zasada nadrzędna: struktura (schematy, nazwy warstw, lokalizacja plików) zgodna z istniejącym projektem. Składnia, komentarze i wzorce obiektów zgodne z dobrymi praktykami T-SQL. Nie kopiuj wzorców legacy, jeśli są gorsze.

Przewodnik: [sql-style-guide.md](../../docs/sql-style-guide.md). Gdy przewodnik różni się od kodu, obowiązuje ta instrukcja (zgodnie z ustaleniem: struktura z projektu, składnia i praktyki dobre).

## Struktura (zgodna z projektem)

- Schematy: `src`, `stg`, `etl`, `dbo`, `reporting`. Nie wprowadzaj `dwh`, `rpt` ani innych bez decyzji.
- Jeden obiekt na plik: `Tables/<schema>.<Name>.sql`, `Procedures/etl.Load<Name>.sql`, `Views/reporting.vw_<Name>.sql`.
- Nowy schemat: plik w `Security/<schema>.sql`. `RetailDW.sqlproj` (SDK-style) nie wymienia plików, więc nie dodawaj ich ręcznie.
- Nazwy: PascalCase, po angielsku, w nawiasach kwadratowych: `[dbo].[FactSales]`.

## Składnia (dobre praktyki)

- Słowa kluczowe wielkimi literami. Wcięcia 4 spacje.
- Każda kolumna w `SELECT` i każdy warunek w `JOIN`/`WHERE` w osobnej linii.
- Zawsze jawne kolumny. Bez `SELECT *` w widokach, procedurach i `INSERT ... SELECT`.
- Aliasy krótkie i stałe: `f` (FactSales), `d` (DimDate), `p` (DimProduct), `st` (DimStore). Kolumny przez `AS` w PascalCase.
- Średnik kończy każde polecenie.
- Typy: `DECIMAL(p,s)` dla pieniędzy, `INT` dla kluczy wymiarów, `BIGINT` dla kluczy faktów, `DATE` dla dat bez czasu, `DATETIME2(3)` dla znaczników czasu w UTC.
- Konwersje w warstwie `src` przez `TRY_CAST`/`TRY_CONVERT`. Nie używaj `CAST` na danych tekstowych ze źródła.
- Unikaj funkcji na kolumnach w `WHERE`, jeśli da się zapisać zakres (`>=`, `<`).
- Liczby i daty w literałach: daty jako `'yyyy-mm-dd'`, tekst Unicode z prefiksem `N'...'`.

## Nazewnictwo ograniczeń (jawne, zawsze)

| Prefiks | Wzorzec | Przykład |
|---|---|---|
| PK | `PK_<Table>` | `PK_FactSales` |
| FK | `FK_<Table>_<RefTable>` | `FK_FactSales_DimDate` |
| Unikalność | `UX_<Table>_<Column>` (indeks unikalny) | `UX_DimStore_StoreCode` |
| Indeks | `IX_<Table>_<Columns>` | `IX_FactSales_DateKey` |
| Domyślna | `DF_<Table>_<Column>` | `DF_LoadLog_Status` |
| Check | `CK_<Table>_<Column>` | `CK_DimStore_Channel` |

Nie pozostawiaj nazw generowanych przez SQL Server.

## Komentarze

- Nagłówek `/* ... */` na początku każdego obiektu: cel, ziarno (dla faktów), źródło, tryb ładowania.
- Komentarz inline tylko przy nieoczywistej logice: stała biznesowa, obejście, filtr statusu, wartość specjalna.
- Nie komentuj oczywistego kodu. Nie dopisuj komentarzy z tym samym tekstem co kod.
- Komentarze po angielsku.

## Procedury i widoki

- Procedury: `CREATE PROCEDURE [etl].[Load<Name>]`, `SET NOCOUNT ON;`, `SET XACT_ABORT ON;`, obsługa błędów wg wzorca z instrukcji ETL.
- Widoki: `CREATE VIEW [reporting].[vw_<Name>]`. Bez zapytań zagnieżdżonych tam, gdzie wystarczy CTE. Każdy widok ma nagłówek z ziarnem.
- Widok nie zawiera `ORDER BY` (sortowanie należy do zapytania konsumenta), chyba że to wymaga kontraktu raportu.
- Łączenia w widokach: `JOIN` do wymiarów, `LEFT JOIN` tylko gdy brak wiersza ma być widoczny w wyniku.

## Migracje i zmiany istniejących obiektów

- Projekt jest deklaratywny: zmiana definicji tabeli to edycja pliku w `Tables/`, a nie osobny skrypt `ALTER`. Zmiany dla istniejących danych ustal z zespołem przed implementacją.
- Przed zmianą kolumny sprawdź zależności (widoki, procedury) i zaktualizuj je w tym samym zadaniu.
- Nie zmieniaj nazw istniejących kolumn bez zgody. Mogą być używane w raportach.

## Czego nie robić

- Nie używaj `TRUNCATE` na tabelach z FK wskazującymi na nie.
- Nie wpisuj na sztywno dat, ścieżek, kont ani wartości środowiskowych.
- Nie generuj kodu, którego nie da się zweryfikować w projekcie SQL.
