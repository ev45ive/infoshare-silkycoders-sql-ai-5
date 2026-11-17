---
description: "Import paczki uczestnika do src i pełne załadowanie ETL w RetailDW_Workshop, z weryfikacją wyniku (bez restore i bez zmiany danych źródłowych)."
argument-hint: "Ścieżka do manifest.json paczki uczestnika, np. data/paczka/manifest.json"
agent: agent
---

# Import i ETL RetailDW

Cel: załadować dane do `src`, uruchomić ETL i potwierdzić wynik. Prompt jest interaktywny: proponujesz opcje, pytasz o wybór i potwierdzasz, gdy coś jest niejasne. Odpowiadasz po polsku, krótko.

## Zakazy

- Nie czyść tabel ani nie uruchamiaj `restore` bez wyraźnej zgody użytkownika w kroku 2.
- Nie uruchamiaj `apply-sql` ani `backup` z `-Force`.
- Nie edytuj plików CSV ani `manifest.json`.
- Nie czytaj `data/` bezpośrednio.

## Krok 1: manifest paczki

- Ścieżka do `manifest.json` pochodzi z argumentu. Jeśli jej brak, zapytaj o nią (wolny tekst) i zakończ, dopóki użytkownik jej nie poda.
- Zaproponuj ścieżkę z argumentu jako wartość domyślną i poproś o potwierdzenie (Tak / Podam inną).

## Krok 2: stan `src` i czyszczenie

Uruchom `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dw.ps1 verify` i odczytaj liczby w `src.*Raw`.

- Jeśli wszystkie są 0: przejdź dalej bez pytania o czyszczenie.
- Jeśli któraś tabela ma wiersze: zapytaj (pojedynczy wybór), dla każdej paczki:
  - **Nie czyść, zatrzymaj się**, rekomendowane. Import dopisuje wiersze, a ETL przeładowuje fakty ze `src`, więc niepusty `src` daje duplikaty.
  - **Przywróć checkpoint v0** (`restore -Name v0 -Force`). Nadpisuje `RetailDW_Workshop`, więc wymaga osobnego potwierdzenia przed wykonaniem.

## Krok 2a: feedy dostępne w manifeście

Sprawdź, które tabele `src` deklaruje manifest. Używaj wyłącznie pola `files[].table` (np. komendą PowerShell `ConvertFrom-Json`, która wypisuje tylko te nazwy). Mapowanie: `src.SalesRaw` → sales, `src.InventoryRaw` → inventory, `src.ReturnsRaw` → returns. Jeśli manifest nie zawiera wszystkich trzech feedów, zaproponuj tylko dostępne i zapytaj, czy kontynuować. Jeśli manifest ma nieznaną tabelę, zatrzymaj się i zapytaj.

Kontrakt paczki (`contract`) pokaż użytkownikowi. Jeśli nie jest zgodny z oczekiwanym (P0), zapytaj przed dalszą pracą.

## Krok 3: feedy ETL

Zapytaj przez vscode_askQuestions (**wielokrotny wybór**, domyślnie zaznaczone wszystkie feedy z kroku 2a):
- sales
- inventory
- returns

Jeśli wybrano wszystkie feedy z manifestu, użyj `etl -Feed all`. Przy jednym feedzie użyj `etl -Feed <nazwa>`. Przy dwóch uruchamiaj kolejno po jednym feedzie, bo skrypt przyjmuje jedną wartość.

## Krok 4: potwierdzenie

Przed wykonaniem pokaż podsumowanie: źródło, czy czyścić, wybrane feedy. Zapytaj o zgodę (Tak / Nie). Bez zgody nic nie uruchamiaj.

## Krok 5: wykonanie

1. Jeśli wybrano czyszczenie: `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dw.ps1 restore -Name v0 -Force`.
2. Import: `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dw.ps1 import-pack -PackPath <ścieżka>`.
3. ETL: `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dw.ps1 etl -Feed <feed>` dla każdego wybranego feedu.
4. Weryfikacja: `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dw.ps1 verify`.

Przy błędzie zatrzymaj się, podaj komunikat i pierwszy krok naprawy. Nie obchodź walidacji i nie zgaduj przyczyny.

## Wynik

Podaj krótko:
- liczby wierszy w `src`, `stg` i `dbo.Fact*`,
- statusy ostatnich przebiegów w `dbo.LoadLog` (oczekiwane SUCCEEDED),
- zgodność: `stg` i `dbo.Fact*` powinny równać się `RowsRead` − `RowsRejected` z `dbo.LoadLog`, a nie surowej liczbie `src`. Odrzucone wiersze są normalne, jeśli `RowsRejected` > 0; wtedy podaj je i zapytaj, czy kontynuować.
