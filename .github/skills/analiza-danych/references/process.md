# Proces analizy: fazy i bramki

Każda faza ma **wejście**, **wyjście** i **bramkę** (warunek przejścia dalej). Jeśli bramka nie jest spełniona, zapytaj użytkownika lub oznacz lukę w handoffie.

## Faza 0. Intake

Wejście: treść zgłoszenia lub pytanie.

Zrób:
- Wczytaj instrukcje domenowe (zob. [domain-retaildw](./domain-retaildw.md)).
- Zmapuj słowa ze zgłoszenia na definicje domyślne (np. "sprzedaliśmy", "online", "tydzień", "rośnie").
- Określ **typ pracy** z [analysis-types](./analysis-types.md) (główny i dodatkowy).
- Wypisz: okres, miara, przekrój, rola pytającego, ryzyka komunikacyjne.

Wyjście: krótki outline (max ok. 15 linii): dotyczy, pyta, typ pracy, niewiadome, wykonalność.

**Bramka G0:** definicja miary i okresu jest ustalona albo zapisana jako założenie "do potwierdzenia".

## Faza 1. Setup

Zadaj jedno pytanie `vscode_askQuestions` z kilkoma polami:
1. **Ścieżka handoffu** (propozycja domyślna obok pliku zgłoszenia).
2. **Dostęp do bazy:** tak (tylko SELECT, z ograniczeniami) / nie (tylko kod i SQL do pliku).
3. **Pierwsze kroki** (multiSelect): przegląd kodu, stan danych, liczba główna, tylko SQL do pliku, pytanie do zgłaszającego.

Utwórz handoff z [szablonu](../assets/handoff-template.md) po pierwszym kroku (nie wcześniej niż masz co zapisać).

**Bramka G1:** zgoda na bazę potwierdzona (lub tryb bez bazy). Bez zgody nie łącz się.

## Faza 2. Rekonesans definicji (bez bazy)

Zrób:
- Przeczytaj definicje obiektów, z których pochodzi miara: widok, fakt, wymiary, ETL.
- Ustal: **ziarno** (co jest jednym wierszem), **miara** (wzór, zaokrąglenia, VAT, zwroty), **filtry i JOIN-y** (INNER gubi wiersze), **które kolumny nie sumują się** (DISTINCT, średnie, udziały).
- Zapisz każdy fakt ze źródłem (plik i linia).

**Bramka G2:** wiesz, jak liczona jest miara i jakie ma pułapki. Inaczej nie interpretuj liczb.

## Faza 3. Stan danych

Zrób (małe zapytania):
- Ostatni load: czas, status, `RowsRead/Loaded/Rejected`.
- Świeżość względem okresu analizy: czy dane były przeładowywane po dacie pytania.
- Kompletność zakresu: min/max daty, brak dziur.

**Bramka G3:** znasz moment załadunku i liczbę odrzuceń. Jeśli dane są nowsze niż pytanie, zapisz w handoffie: "liczba może różnić się od widzianej wcześniej".

## Faza 4. Wynik główny

Zrób: policz odpowiedź na pytanie, z jawną definicją i filtrami, z **tego samego obiektu, z którego korzysta biznes** (zwykle widok raportowy).

Wyjście: tabela (wartość, porównanie, rozbicie) + interpretacja.

**Bramka G4:** części sumują się do całości; definicja i filtry zapisane w handoffie.

## Faza 5. Cross-check

Zrób: ta sama liczba inną drogą ([crosschecks](./crosschecks.md)). Zaproponuj kilka dróg, użytkownik wybiera.

**Bramka G5:** wynik zgodny z drugą drogą (lub rozbieżność wyjaśniona), albo wynik oznaczony "niezweryfikowany" w raporcie.

## Faza 6. Drill-down, hipotezy, trend

Zrób: [drilldown-methods](./drilldown-methods.md). Każdy krok to hipoteza z testem. Zatrzymaj się, gdy spełnione jest kryterium stopu.

**Bramka G6:** każde twierdzenie "dlaczego" jest oznaczone: **potwierdzone** (dowód), **niezaprzeczone** (nie obalone, brak testu) lub **hipoteza** (bez testu).

## Faza 7. Zamknięcie

Zrób:
1. Porównaj wyniki z **kryteriami akceptacji** ze zgłoszenia. Wypisz luki (np. zwroty, data załadunku, cross-check).
2. Zaproponuj zakończenie albo domknięcie luk (`vscode_askQuestions`, multiSelect).
3. Zaproponuj zawartość raportu (domyślnie: to, czego wymagało zgłoszenie + dowody). Użytkownik wybiera elementy i ścieżkę pliku.
4. Zapisz raport z [szablonu](../assets/report-template.md); opcjonalnie szkic maila z [szablonu](../assets/email-template.md).
5. Zamknij handoff: status "zakończona", decyzje o zakresie raportu, kroki niewykonane.

**Bramka G7 (zamknięcia):**
- Jeśli użytkownik odznaczył element wymagany przez zgłoszenie, wypisz konsekwencję (luka) i zapytaj raz, czy na pewno.
- Twierdzenia w raporcie i mailu nie zawierają niepotwierdzonych założeń podanych jako fakt (np. waluta, definicja netto/brutto): oznacz je lub je pomiń.
- Liczby w tekście przeliczone ponownie z wyników zapytań.

## Kryteria zakończenia analizy

- Odpowiedź na każde pytanie ze zgłoszenia (albo jawna luka).
- Cross-check wykonany lub świadomie pominięty (zapis w handoffie).
- Handoff zaktualizowany; raport zapisany (lub decyzja "tylko czat").
