# Domena: RetailDW (Nordvik)

Jedyny plik skilla zależny od repozytorium. Dla innej bazy skopiuj go jako `domain-<nazwa>.md` i zmień treść.

## Kontekst i instrukcje do wczytania

Wczytaj z `.github/instructions/` według typu zgłoszenia:

| Instrukcja | Kiedy |
|---|---|
| `nordvik-kontekst-biznesowy` | zawsze (interpretacja: sklepy, kanały, sezony) |
| `retaildw-schema` | zawsze (obiekty, relacje, ziarno) |
| `nordvik-metryki` | miary: sprzedaż, marża, zapas, zwroty, kalendarz |
| `retaildw-analysis` | analizy, widoki `reporting` |
| `retaildw-etl` | ładowanie, odrzucenia, `LoadLog` |

Duże dokumenty w `docs/` czytaj tylko we wskazanych sekcjach i tylko, gdy instrukcje nie wystarczą (zob. `AGENTS.md`).

## Zakazane ścieżki

Nie czytaj: `.specstory/`, `notatki/` (poza wskazanym zgłoszeniem), `docs/analizy/` (poza wskazanym plikiem lub plikami tworzonymi w tej analizie), `data/`.

## Połączenie z bazą

- Baza: SQL Server 2022. Dostępne serwery sprawdź narzędziem listy serwerów, nie zgaduj nazwy.
- Tylko `SELECT`. Bez zapisu, bez uruchamiania skryptów, bez commitów bez prośby.
- Połączenie dopiero po zgodzie użytkownika (bramka G1).

## Obiekty typowe dla analiz

| Obiekt | Użycie |
|---|---|
| `reporting.vw_SalesWeekly` | sprzedaż tygodniowa (ISO), przekroje kanał/region/dział/kategoria |
| `reporting.vw_SalesDaily` | sprzedaż dzienna |
| `reporting.vw_StoreScorecard`, `vw_ProductPerformance`, `vw_MarginAnalysis`, `vw_StockAvailability` | karty sklepów, produkty, marża, dostępność |
| `dbo.FactSales`, `dbo.FactReturns`, `dbo.FactInventoryDaily` | fakty do cross-checków |
| `dbo.DimDate`, `dbo.DimStore`, `dbo.DimProduct` | kalendarz ISO, kanał/region, kategorie |
| `dbo.LoadLog` | świeżość, status, odrzucone |
| `src.*Raw`, `stg.*` | rekoncyliacja ze źródłem |

Nazw kolumn nie zgaduj: sprawdź w `RetailDW/Tables/` i `RetailDW/Views/`.

## Domyślne definicje (do potwierdzenia ze zgłaszającym)

- "Sprzedaż" = sprzedaż netto przed zwrotami (`NetAmount`).
- "Online" = kanał `ONLINE` w wymiarze sklepów; "sklepy" = kanał `STORE`.
- "Tydzień" = tydzień ISO, poniedziałek-niedziela.
- Waluta nie jest zapisana w repo: pytanie do zgłaszającego.
- Wartości orientacyjne z dokumentacji (udziały kanałów, wskaźniki zwrotów) oznaczaj jako orientacyjne.

## Pułapki specyficzne

- Widok tygodniowy nie odejmuje zwrotów.
- `Transactions` w widoku nie sumuje się między grupami.
- `WeekStart/WeekEnd` w widoku to MIN/MAX dat ze sprzedażą.
- ETL to pełne przeładowanie z INNER JOIN do wymiarów i bez deduplikacji źródła.
- Netto liczone per linia (`brutto / 1.23`, zaokrąglone), więc drobne różnice względem sumy brutto/1.23.
- `SalesAreaM2` w wymiarze sklepu jest bieżące, nie historyczne; NULL dla online.

## Język

Odpowiedzi po polsku; nazwy obiektów i komentarze w kodzie po angielsku.
