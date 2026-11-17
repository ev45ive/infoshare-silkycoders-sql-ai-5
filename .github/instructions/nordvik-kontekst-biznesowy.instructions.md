---
description: "Kontekst biznesowy Nordvik (sklepy, asortyment, sezony, kanały, rytm pracy, ograniczenia danych) do interpretacji pytań i wyników."
applyTo: "docs/nordvik-opis-firmy.md,RetailDW/Views/**,RetailDW/Tables/**"
---

# Nordvik – kontekst biznesowy

Pełny opis: [nordvik-opis-firmy.md](../../docs/nordvik-opis-firmy.md). Ta instrukcja zawiera tylko to, co zmienia interpretację danych. Sekcje opisu wskazane poniżej otwieraj wyłącznie, gdy pytanie tego wymaga.

## Co wczytać do jakiego zadania

| Zadanie | Sekcja opisu |
|---|---|
| Pytanie o sklep, kanał, region | 3. Sklepy i kanały |
| Pytanie o produkt, model, SKU, rozmiar | 4. Asortyment i produkt |
| Pytanie „kto za to odpowiada” | 5. Organizacja |
| Pytanie o porę roku, tydzień, raport cykliczny | 6. Rytm pracy firmy |
| Pytanie o źródła, warstwy, model gwiazdy | 7. Dane: źródła i hurtownia |
| Pytanie o zakres danych, braki, jakość | 7.5 i 7.6 |
| Model predykcyjny, prognoza, data science | 9. Data Science |
| Nieznany termin | 10. Słownik pojęć |

## Profil

- Sieć odzieżowa własnego projektu (*own brand*), PLN, VAT 23%.
- 5 sklepów `STORE` i 1 sklep `ONLINE`.
- Ok. 120 SKU (uproszczenie, nie cały asortyment).
- Sprzedaż od stycznia 2025. Stany i zwroty tylko za bieżący sezon.

## Sklepy

- Powierzchnia w hurtowni to bieżący metraż.
- Kraków Rynek: 180 m² do marca 2026, 320 m² od kwietnia 2026. Porównania sprzed i po przebudowie wymagają opisu tej zmiany.
- Online nie ma powierzchni i nie jest w scorecardzie sklepu.

## Asortyment

- Hierarchia: dział (WOMEN/MEN/UNISEX) → kategoria → `StyleCode` → SKU (model × kolor × rozmiar).
- Rozmiary `XS`, `S`, `M`, `L`, `XL`. Akcesoria: `ONE`.
- Kolekcje: np. `AW25`, `SS26`, `AW26`.
- `ListPrice` jest bieżący i z VAT. `unit_cost` jest kopiowany na pozycję sprzedaży.

## Sezony i cykl przeceny

- Sezon jest w wymiarze daty. Nazwa kolumny zależy od wariantu bazy (w repo SQL Server: `dbo.DimDate`, sprawdź w `RetailDW/Tables/`).
- Cykl: wejście (pełna cena, 4–6 tyg.), sezon podstawowy (do ok. 8 tyg.), rabat sezonowy (−20% do −30%, 2–3 tyg.), wyprzedaż końcowa (−40% do −60%).
- Czas trwania etapów to założenie, nie dane.

## Kanały

- Sklepy stacjonarne: ok. 78% przychodu, zwroty ok. 4% (orientacyjnie, opis nie precyzuje miary).
- Sklep internetowy: ok. 22% przychodu, zwroty ok. 18% (orientacyjnie, opis nie precyzuje miary).
- Kanały porównuj osobno. Wyższe zwroty online to cecha kanału.

## Ograniczenia danych (ważne przy wnioskach)

- Brak danych o kliencie: nie ma ID klienta, karty ani konta. Analiz klientów (segmentacja, RFM, odejścia) nie da się zrobić z tego zbioru.
- Brak dostaw i przesunięć między sklepami. Stany to wynik, nie przyczyna.
- Brak historii cen (jest cena na pozycji, nie cennik).
- Brak danych z sesji web i lejka e-commerce.
- Brak historii metrażu sklepu.
- Ponowne wgranie pliku może zduplikować wiersze.
- Plik stanów bywa niekompletny (brak pliku za dzień).
- Zwroty są księgowane w dniu przyjęcia.
- Nazwa widoku nie zawsze oznacza to, co liczy. Sprawdź definicję w pliku widoku.

## Założenia do oznaczenia w wyniku

- Udziały kanałów, wskaźniki zwrotów, czasy etapów cyklu i sezon lutowy jako dołek są **orientacyjne**. Oznacz je tak w odpowiedzi.
- Liczby z rozmowy o rynku (np. „500 modeli”) nie są zweryfikowane i nie należą do opisu Nordvik.

## Rytm pracy (kiedy co się dzieje)

- Codziennie: pliki źródłowe raz na dobę, hurtownia ładowana w całości.
- Poniedziałek: przegląd sprzedaży netto poprzedniego tygodnia ISO.
- Koniec miesiąca: zamknięcie, przegląd marżowy, karta wyników sklepów.
- Listopad (Black Friday) i grudzień: szczyty. Luty: dołek (orientacyjnie).
- Przy porównaniach rok do roku uwzględnij te okresy.
