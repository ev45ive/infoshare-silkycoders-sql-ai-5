---
description: "Analiza danych i pisanie zapytań raportowych na RetailDW: miary, pułapki, widoki reporting."
applyTo: "RetailDW/Views/**"
---

# RetailDW – analiza i raporty

Pełne opisy: [retaildw-database.md](../../docs/retaildw-database.md), sekcje 5, 10 i 12.

## Źródła do raportów

| Pytanie | Użyj |
|---|---|
| Sprzedaż dzienna | `reporting.vw_SalesDaily` |
| Sprzedaż tygodniowa (ISO, Pn–Nd) | `reporting.vw_SalesWeekly` |
| Marża po stylu i miesiącu | `reporting.vw_MarginAnalysis` |
| Scorecard SKU | `reporting.vw_ProductPerformance` |
| Dostępność na półce | `reporting.vw_StockAvailability` |
| Miesięczny scorecard sklepu | `reporting.vw_StoreScorecard` |

Zapytania analityczne czytają z widoków `reporting`, nie z tabel `stg`/`src`.

## Miary

- `NetAmount` = `GrossAmount / 1.23` (VAT 23%, stała w procedurze). Nie licz VAT samodzielnie.
- `GrossMargin` = `NetAmount - Quantity * UnitCost`. `UnitCost` jest zapisany w fakcie w chwili ładowania.
- `Transactions` = liczba różnych `TransactionNo`. Nie sumuj liczby transakcji po wymiarach, które dzielą transakcję.
- `UnitsPerTransaction` i `AvgBasketValue` liczone są na poziomie sklepu i miesiąca. Nie uśredniaj ich dalej bez wag.
- Miary addytywne (`Units`, `NetAmount`, `GrossAmount`) sumuj. Wskaźniki (`GrossMarginPct`, `AvailabilityPct`, `SellThroughPct`) licz z sum, nie ze średniej procentów.

## Pułapki

- Stany (`FactInventoryDaily`) to snapshot. Nie sumuj stanów po dniach. Do stanu bieżącego użyj ostatniego `DateKey`.
- Stany są tylko za bieżący sezon. Porównania rok do roku dla stanów są niemożliwe.
- `SellThroughPct` liczony za bieżący sezon. Nie zestawiaj go z `UnitsSoldTotal`.
- `DimStore.SalesAreaM2` to wartość bieżąca. Wskaźniki per m² za przeszłość używają obecnej powierzchni.
- Sklep online ma `SalesAreaM2 = NULL` i jest wykluczony z `vw_StoreScorecard`.
- Tydzień ISO: `IsoYear` może różnić się od roku kalendarzowego wokół 1 stycznia. Grupuj po `IsoYear` + `IsoWeek`.
- Brak wiersza `Unknown` w wymiarach: rekordy bez dopasowania SKU, sklepu lub daty nie są w faktach. Porównuj z `LoadLog.RowsRejected`.
- Zwroty nie są powiązane kluczem obcym ze sprzedażą. Łącz po `TransactionNo` i `ProductKey`.
- Wymiary typu 1: historia atrybutów (cena, nazwa, kategoria) nie jest zachowana.

## Zasady pisania zapytań

- Filtruj po `DateKey` (INT) lub po `Date` z `DimDate`. Nie filtruj po funkcjach na kolumnach.
- Nie wykonuj nieograniczonych zapytań na `FactSales`. Zawsze zawężaj okres lub sklep.
- Podawaj wynik z jawnymi kolumnami i jednostką. Jednostka waluty nie jest zapisana w repo, więc nie zakładaj PLN bez potwierdzenia.
- Przy każdym wniosku podaj, z którego widoku lub tabeli pochodzi liczba i jakie filtry zastosowano.
- Przy różnicach między widokami wyjaśnij, czy wynika to z danych, czy z definicji miary.
