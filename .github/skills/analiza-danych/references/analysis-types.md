# Typy analiz: bramki, hipotezy, minimalne dowody

Zgłoszenie ma typ główny i opcjonalnie dodatkowy. Dla każdego typu: pytanie kluczowe, bramki, hipotezy startowe, minimalne dowody w raporcie, typowe pułapki. Dodaj nowy typ jako nową sekcję według tego wzoru.

## 1. Liczba / odczyt z raportu (lookup)

Pytanie: "ile było X w okresie Y?"
- Bramki: definicja miary (np. netto przed zwrotami), okres (granice), przekrój, świeżość danych.
- Minimalne dowody: wynik z widoku raportowego + cross-check z faktu + log ładowania.
- Hipotezy startowe: liczba różni się od widzianej wcześniej, bo dane przeładowano.
- Pułapki: sumowanie kolumn nieaddytywnych, INNER JOIN gubiący wiersze, zakres dat vs tydzień ISO.

## 2. Porównanie okresów (variance)

Pytanie: "czy X wzrosło/spadło względem Y i dlaczego?"
- Bramki: te same definicje i granice w obu okresach, porównywalna długość i liczba dni handlowych.
- Minimalne dowody: wartości i różnica (bezwzględna i %), rozbicie na kanał, przyczynek grup.
- Hipotezy: struktura (mix), kategoria dominująca, region, kalendarz, jakość danych.
- Pułapki: różna liczba dni, świeżo otwarte/zamknięte sklepy, wynik dodatni łączny przy przeciwnych znakach kanałów.
- Kolejny krok: [drilldown-methods](./drilldown-methods.md).

## 3. Trend

Pytanie: "czy rośnie/spada?"
- Bramki: seria min. kilkunastu okresów, jedna definicja w całej serii, spójne granice.
- Minimalne dowody: tabela serii (wartość, udział), zakres wahań, liczba okresów wzrostu/spadku.
- Hipotezy: sezonowość, zmiana struktury, efekt jednorazowy.
- Wniosek rozdziel: trend **wartości** vs trend **udziału**.
- Pułapki: dwa punkty to nie trend; początek/koniec serii obcięty; sezon.

## 4. Przyczyna zmiany (root cause)

Pytanie: "dlaczego spadło/wzrosło?"
- Bramki: zmiana potwierdzona w dwóch drogach (nie artefakt jakości danych).
- Kolejność: jakość danych → mix/struktura → cena/rabat → zapas → kalendarz.
- Minimalne dowody: przyczynek grup, seria dla głównej grupy, test przynajmniej jednej hipotezy przyczynowej.
- Pułapki: przyczyna spoza hurtowni (pogoda, promocja bez danych): oznacz jako hipotezę.

## 5. Rentowność / marża

Pytanie: "ile zarabiamy na X?"
- Bramki: definicja marży (netto vs brutto, koszt jednostkowy kopiowany przy ładowaniu), rabaty.
- Minimalne dowody: marża w kwocie i %, rozbicie na wymiar, zgodność kosztu z wymiarem produktu.
- Hipotezy: zmiana rabatów, zmiana mixu, zmiana kosztu.
- Pułapki: średnia z procentów zamiast ważonej; koszt bieżący vs historyczny.

## 6. Zapas

Pytanie: "ile mamy / ile brakuje?"
- Bramki: zapas to stan na dzień (nie sumowalny w czasie), dostępność = SKU w sklepie z zapasem >0.
- Minimalne dowody: stan na konkretny dzień, rozbicie, braki.
- Pułapki: sumowanie zapasu po dniach; porównanie z miesięczną sprzedażą bez normalizacji.

## 7. Zwroty

Pytanie: "ile zwrotów / jaki wskaźnik?"
- Bramki: zwrot przypisany do daty zwrotu (nie sprzedaży); definicja wskaźnika (kwota czy sztuki).
- Minimalne dowody: kwota zwrotów w okresie, wskaźnik, rozbicie na kanał.
- Pułapki: zwroty z poprzedniego okresu w bieżącym; wynik "po zwrotach" nie jest sprzedażą z widoku.

## 8. Jakość danych / rozjazd

Pytanie: "dlaczego liczby się nie zgadzają?"
- Bramki: porównanie dwóch źródeł w tym samym zakresie, ta sama definicja.
- Kolejność: log ładowania → liczba wierszy → duplikaty → brak dopasowania wymiarów → zakres dat → definicje.
- Minimalne dowody: tabela różnic (źródło A vs B), wyjaśniona przyczyna.
- Pułapki: pełne przeładowanie zmienia dane wstecz; różne filtry w dwóch raportach.

## 9. Rekoncyliacja (źródło vs hurtownia)

Pytanie: "czy hurtownia zgadza się ze źródłem?"
- Bramki: znany zakres, znane transformacje ETL.
- Minimalne dowody: liczba wierszy i suma po obu stronach, rejected, duplikaty.
- Pułapki: transformacje (rzutowanie, zaokrąglenia, VAT), odrzucenia w ETL.

## Typ mieszany

Zgłoszenie często łączy np. lookup + trend + variance. Zrealizuj w kolejności: lookup (wynik) → cross-check → variance → trend → root cause (tylko jeśli pytanie tego wymaga lub użytkownik wybierze).
