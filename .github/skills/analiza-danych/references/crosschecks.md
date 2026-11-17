# Katalog cross-checków

Cross-check = ta sama liczba (lub wniosek) uzyskana **inną drogą**. Celem jest wykrycie błędu w definicji, JOIN-ie, ETL lub w interpretacji.

## Jak proponować

Zaproponuj 3-5 dróg do wyboru z kosztem (liczba zapytań/wierszy), zaznacz `recommended` dla najtańszej niezależnej. Użytkownik wybiera.

## Katalog

| # | Cross-check | Co sprawdza | Koszt | Kiedy |
|---|---|---|---|---|
| X1 | Widok vs tabela faktów, ten sam zakres i grupowanie | poprawność widoku (JOIN-y, grupowanie) | 1-2 zapytania | zawsze, gdy liczba pochodzi z widoku |
| X2 | Miara z innego wzoru (np. brutto / stawka VAT, ilość × cena − rabat) | definicja miary, zaokrąglenia | 1 zapytanie | gdy miara ma wzór |
| X3 | Suma części = całość (kanały, regiony, kategorie) | kompletność rozbicia | w ramach wyniku | zawsze |
| X4 | Zakres dat: min/max `DateKey` w tygodniu, brak dat spoza okresu | granice okresu, ISO | 1 zapytanie | porównanie okresów |
| X5 | Duplikaty po kluczu naturalnym (np. transakcja + linia) | duplikaty w fakcie | 1 zapytanie | zawsze przy sprzedaży |
| X6 | Źródło vs hurtownia (liczba wierszy, suma, rejected) | ETL, odrzucenia | 2 zapytania | rekoncyliacja, podejrzenie ETL |
| X7 | Brak dopasowania do wymiarów (anti-join) | gubienie wierszy przy INNER JOIN | 1 zapytanie | gdy `RowsRejected > 0` lub różnice |
| X8 | Log ładowania: status, rejected, czas | świeżość i kompletność | 1 zapytanie | zawsze (faza 3) |
| X9 | Inny poziom ziarna (dzień zamiast tygodnia i suma) | spójność agregacji | 1 zapytanie | gdy widok ma inne ziarno |
| X10 | Inny okres referencyjny (np. tydzień sąsiedni) | czy wynik w normie | 1 zapytanie | ocena wiarygodności |
| X11 | Niezależne przeliczenie w tekście (kalkulator) | błędy rachunkowe w podsumowaniu | 0 | zawsze przed zapisem |

## Kryteria wystarczalności

Wynik uznaj za zweryfikowany, gdy:
- co najmniej jedna **niezależna** droga (X1, X2, X6 lub X9) daje tę samą liczbę (po zaokrągleniu),
- części sumują się do całości (X3),
- brak duplikatów i brak odrzuceń, albo są policzone i opisane (X5, X7, X8).

Jeśli droga daje rozbieżność:
1. Zapisz ją w handoffie jako odkrycie, z wartościami po obu stronach.
2. Zaproponuj kroki diagnostyczne (X4, X5, X7, X9).
3. Nie zamykaj analizy bez wyjaśnienia lub jawnego zastrzeżenia w raporcie.

## Różnice dopuszczalne

- Zaokrąglenie per linia (np. miara dzielona stawką): różnice rzędu groszy na tygodniu. Opisz, nie ukrywaj.
- Różnice większe niż zaokrąglenie = błąd do wyjaśnienia.

## Dowody w raporcie

W raporcie pokaż tabelę: kontrola → wynik → status. Przykład: "Widok vs fakt, 4 grupy: identyczne", "Duplikaty w zakresie: 0", "Odrzucone w ostatnim ładowaniu: 0".
