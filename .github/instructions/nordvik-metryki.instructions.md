---
description: "Definicje metryk Nordvik (sprzedaż, rentowność, zapas, zwroty, kalendarz) i ich pułapki przy liczeniu w SQL."
applyTo: "RetailDW/Views/**,docs/slownik-metryk.md"
---

# Nordvik – metryki

Źródło pełne: [slownik-metryk.md](../../docs/slownik-metryk.md). Ta instrukcja to skrót reguł do liczenia w SQL. Gdy użytkownik pyta o konkretną metrykę, otwórz słownik tylko w tej części, której dotyczy pytanie.

## Domyślne znaczenia słów

| Słowo w pytaniu | Znaczy |
|---|---|
| „sprzedaż” | Sprzedaż netto (`NetAmount`), przed odjęciem zwrotów |
| „sprzedaż brutto” | `GrossAmount`, z VAT, po rabacie. Gdy pytanie o kwotę zapłaconą przez klienta |
| „marża” | Marża brutto po zwrotach, patrz niżej |

## Sprzedaż

- Sprzedaż netto = `NetAmount` (VAT 23%, `GrossAmount / 1.23`).
- Sprzedaż netto po zwrotach = sprzedaż netto − `return_amount / 1.23` z tego samego okresu.
- Wartość przed rabatem = `SUM(quantity * unit_price)`, z VAT.
- Stopa rabatu = rabat / wartość przed rabatem.
- Udział kanału = sprzedaż netto kanału / sprzedaż netto wszystkich kanałów w tym samym okresie.
- Aktywne SKU = `COUNT(DISTINCT product_key)` w okresie. Sztuki na aktywne SKU = sztuki / aktywne SKU.
- Zmiana tydzień do tygodnia: oba tygodnie pełne i w tym samym przekroju.

## Rentowność

- Koszt własny (COGS) = `SUM(quantity * unit_cost)`.
- Marża brutto = sprzedaż netto − COGS − wartość zwrotów netto przyjętych w tym samym okresie.
- Marża % = marża brutto / sprzedaż netto.
- Zwroty obniżają marżę okresu **przyjęcia**, nie okresu sprzedaży.

Pułapka: `reporting.vw_MarginAnalysis` liczy `GrossMargin` jako sprzedaż netto − COGS, **bez zwrotów**. Nie jest to zgodne ze słownikiem. Przy pytaniu o marżę zgodną z definicją firmy nie używaj wyniku tego widoku wprost. Zgłoś rozbieżność.

## Transakcje i koszyk

- Liczba transakcji = `COUNT(DISTINCT transaction_no)`. Nie `COUNT(*)`, bo to liczba pozycji.
- Średni koszyk = sprzedaż netto / liczba transakcji.
- UPT = sztuki / liczba transakcji.

## Produktywność sklepu

- Przychód na m² = sprzedaż netto / powierzchnia. Tylko sklepy `STORE`. Online nie ma powierzchni.
- `sales_area_m2` to bieżący metraż. Przy porównaniu sprzed i po przebudowie obie strony dziel przez bieżący metraż i opisz to w wyniku.

## Zapas i dostępność

- Stan magazynowy = `stock_quantity` na koniec dnia dla SKU × sklep. To migawka: nie sumuj stanów z kolejnych dni.
- Dostępność = SKU ze stanem > 0 / SKU objęte feedem zapasu tego dnia i sklepu. Nie cały katalog.
- Sell-through = sprzedane w sezonie / (sprzedane w sezonie + stan na koniec okresu). Tylko w obrębie jednego sezonu. Feed zapasu obejmuje tylko bieżący sezon.
- Wartość zapasu w koszcie = stan × bieżący `unit_cost` z wymiaru. Nie jest to wycena księgowa.
- Różnica dwóch migawek to nie sprzedaż: wpływają dostawy i przesunięcia, których nie ma w hurtowni.

## Zwroty

- Wskaźnik zwrotów = sztuki zwrócone / sztuki sprzedane, w tym samym okresie i przekroju.
- Wartość zwrotów netto = `return_amount / 1.23`. `return_amount` jest z VAT.
- Powody: `DAMAGED`, `WRONG_SIZE`, `CHANGED_MIND`, `OTHER`.
- Data i sklep zwrotu to przyjęcie, nie sprzedaż. Kanały porównuj osobno.

## Kalendarz

- Tydzień handlowy: ISO-8601, poniedziałek–niedziela. Format `year_week`, np. `2026-W24`.
- Grupuj tygodnie po `iso_year` + `iso_week`. Nigdy `calendar_year` z `iso_week`.
- Sezon: `SS` = luty–lipiec, `AW` = sierpień–styczeń. `AW26` obejmuje sierpień 2025–styczeń 2026 (zgodnie z logiką seeda `DimDate`).

## Wymagania przy odpowiedzi

- Podaj, która definicja została użyta (sprzedaż netto vs brutto, z zwrotami czy bez).
- Jeśli mianownik wynosi zero, wskaźnik jest pusty (NULL). Nie zamieniaj go na 0.
- Kwoty w PLN, udziały i dynamiki w %.
