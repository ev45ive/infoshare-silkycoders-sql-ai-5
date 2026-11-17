# Metody drill-down i hipotezy

Drill-down to seria testów hipotez, nie zrzut danych. Każdy krok odpowiada na pytanie "co tłumaczy największą część zmiany?".

## Zasady

1. **Zacznij od przyczynku (contribution):** ile różnicy tłumaczy każda grupa (`różnica grupy / różnica całości`). Idź w grupę o największym przyczynku (co do wartości bezwzględnej).
2. **Jeden wymiar na krok**, od najbardziej ogólnego. Zapytaj użytkownika, który wymiar wybrać (kilka opcji).
3. **Sprawdź resztę:** po wskazaniu głównej grupy policz, co robią pozostałe (czy kompensują, czy też spadają).
4. **Przyczynek >100%** oznacza, że reszta ma przeciwny znak. Zapisz to wprost.
5. **Duża grupa vs duży spadek:** największy region/kategoria zawsze tłumaczy najwięcej. Porównaj zmianę procentową, nie tylko bezwzględną.
6. **Stop**, gdy spełnione jest kryterium stopu (niżej).

## Drabiny wymiarów (do wyboru)

| Drabina | Kroki |
|---|---|
| Struktura sprzedaży | kanał → region → format sklepu → sklep |
| Asortyment | dział → kategoria → podkategoria → SKU |
| Czas | rok → miesiąc → tydzień → dzień (dzień tygodnia) |
| Klient/transakcja | typ transakcji → wielkość koszyka (jeśli dostępne) |

Nazwy kolumn i poziomów sprawdź w definicjach (nie zgaduj). Zob. [domain-retaildw](./domain-retaildw.md).

## Metody

| Metoda | Kiedy | Wynik |
|---|---|---|
| Przyczynek do zmiany | zmiana między okresami | ranking grup wg udziału w różnicy |
| Dekompozycja wolumen × cena × mix | zmiana wartości | ile z różnicy to ilość, cena (średnia), mix produktów |
| Seria czasowa dla głównej grupy | po wskazaniu grupy | skok jednorazowy vs trend |
| Test koncentracji | grupa tłumaczy >50% zmiany | czy zmiana jest wąska (1 grupa) czy szeroka |
| Porównanie z bazą (poprzedni okres/rok) | ocena "czy to normalne" | zakres wahań tygodniowych |
| Przekrój kanałowy | zmiana w sprzedaży łącznej | czy kanały idą w przeciwne strony |
| Test jakości danych | wynik nieoczekiwany | duplikaty, brak wymiarów, zakres dat, zmiana ETL |

## Szablon hipotezy

```
H<n>: <twierdzenie, np. "spadek sklepów wynika z kategorii Kurtki">
Test: <zapytanie/metoda, zakres, koszt>
Dowód potwierdza, jeśli: <warunek>
Dowód obala, jeśli: <warunek>
Status: 💭 hipoteza / 🟢 potwierdzona / 🔴 obalona / ❔ niezweryfikowana (legenda w szablonie handoffu)
Źródło: <zapytanie, plik>
```

## Hipotezy przyczynowe (lista do wyboru)

Zapytaj użytkownika, które testować; podaj koszt.

| Grupa | Hipoteza | Dane potrzebne |
|---|---|---|
| Popyt | efekt kalendarza/sezonu/pogody | seria czasowa, rok do roku |
| Podaż | brak zapasu (stockout) | zapas dzienny wg SKU/sklepu |
| Cena | zmiana cen/rabatów | średnia cena, rabat per jednostka |
| Mix | zmiana struktury produktów/regionów | udziały w czasie |
| Kanał | przesunięcie sprzedaży między kanałami | kanał × czas |
| Jakość danych | duplikaty, brak dopasowania, opóźniony załadunek | log ładowania, kontrole kluczy |
| Zwroty | wysoki zwrot w grupie | zwroty per grupa |

Przyczyn spoza danych (pogoda, promocje bez danych) nie potwierdzaj: oznacz "hipoteza, wymaga danych spoza hurtowni".

## Kryteria stopu

Zatrzymaj drill-down, gdy:
- zmiana jest wyjaśniona w ≥80% przez wąską grupę, a dalszy podział nie zmienia wniosku,
- dalsze zejście wymaga danych, których nie ma w hurtowni,
- zgłaszający nie potrzebuje tego poziomu (zakres zgłoszenia),
- kolejny krok miałby koszt większy niż wartość odpowiedzi.

Zapisz w handoffie: co wyjaśnia zmianę, czego nie wyjaśnia, jakie hipotezy zostają.

## Trend

- Seria minimum kilkunastu okresów (tygodni), nie dwa punkty.
- Pokaż wartość i udział (gdy sensowne).
- Policz: liczbę okresów wzrostu/spadku, min/max udziału, zakres wahań.
- Odróżnij wzrost **wartości** od wzrostu **udziału**; to różne pytania.
- Sezonowość oznacz jako hipotezę, dopóki nie ma porównania rok do roku.
