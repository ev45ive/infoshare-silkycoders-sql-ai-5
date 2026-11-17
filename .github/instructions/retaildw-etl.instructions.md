---
description: "Pisanie i zmiana procedur ETL RetailDW (etl.Load*) oraz przepływu src → stg → dbo."
applyTo: "RetailDW/Procedures/**,scripts/dw.ps1"
---

# RetailDW – ETL

Pełny przepływ i diagram: [retaildw-database.md](../../docs/retaildw-database.md), sekcja 9.

## Przepływ

| Krok | Z | Do | Wykonuje |
|---|---|---|---|
| Import CSV | plik CSV | `src.*Raw` | `scripts/dw.ps1 import-p0` / `import-pack` (bez ETL) |
| Konwersja | `src.*Raw` | `stg.*` | krok 1 procedury `etl.Load*` |
| Fakt | `stg.*` + `dbo.Dim*` | `dbo.Fact*` | krok 2 procedury `etl.Load*` |
| Audyt | wynik | `dbo.LoadLog` | wewnątrz procedury |

Warstwy zależą tylko w jednym kierunku: `src` → `stg` → `dbo`. Procedura nie czyta z `dbo.Fact*` w kroku konwersji.

## Wzorzec procedury

Każda nowa procedura `etl.Load<Name>` ma ten sam szkielet:

1. Nagłówek komentarza: cel, kroki, tryb ładowania.
2. `SET NOCOUNT ON;` i `SET XACT_ABORT ON;`.
3. Zmienne `@LoadId`, `@RowsRead`, `@RowsLoaded`, `@RowsRejected`.
4. Wpis w `dbo.LoadLog` ze statusem startowym, `SCOPE_IDENTITY()`.
5. `BEGIN TRY` … `BEGIN CATCH`: w `CATCH` status `FAILED`, `ERROR_MESSAGE()`, `THROW`.
6. Liczba odrzuconych = `@RowsRead - @RowsLoaded`. Zapis w `LoadLog`.

## Zasady dobrych praktyk przy pisaniu ETL

- Konwersje tylko przez `TRY_CAST` / `TRY_CONVERT` w kroku `src` → `stg`. Wiersz z błędem nie trafia dalej.
- Filtr jakości w kroku konwersji wymienia każde pole, które musi być NOT NULL po konwersji.
- Łączenia z wymiarami: `JOIN` (nie `LEFT JOIN`) tylko świadomie. Brak dopasowania jest liczony jako odrzucony.
- Miary wyliczaj raz, w procedurze, i zapisuj w fakcie. Stałych biznesowych (np. stawki VAT) nie wpisuj na sztywno w kodzie bez komentarza uzasadniającego. Preferuj tabelę parametrów, jeśli zmiana jest realna.
- Tryb ładowania: obecnie pełne przeładowanie (`DELETE` + `INSERT`). Dla nowej, dużej tabeli rozważ `TRUNCATE` (bez FK do tabeli) lub inkrementalne ładowanie i zapytaj o wymagania przed zmianą.
- Nie używaj kursorów ani pętli `WHILE` do transformacji zbiorów.
- Nie używaj `SELECT *` w `INSERT ... SELECT`. Wypisz kolumny.
- Procedury mają `XACT_ABORT ON`, ale wpis w `LoadLog` nie jest częścią transakcji ładowania. Przy błędzie status zostaje zaktualizowany w `CATCH`.

## Import CSV (`scripts/dw.ps1`)

- Nagłówek CSV musi być identyczny z kolumnami w manifeście, w tej samej kolejności.
- Liczba pól w każdym wierszu musi zgadzać się z nagłówkiem.
- Liczba wierszy musi zgadzać się z manifestem.
- Import działa w jednej transakcji dla wszystkich plików.
- Skrypt nie wypełnia `SourceFile` i nie uruchamia ETL. Nie zakładaj, że te kolumny są wypełnione.
## Pułapki

- Wiersze odrzucone nie są logowane osobno. Zmiana tej zasady wymaga nowego mechanizmu (np. tabeli odrzuceń) i zgody.
- Brak wiersza `Unknown` (`-1`) w wymiarach. Nie dodawaj go bez decyzji o modelu.
- Indeksy w `stg`: `stg.Sales` i `stg.Inventory` mają indeks na dacie, `stg.Returns` nie ma żadnego. Przy dodaniu indeksu sprawdź wpływ na czas ładowania.
