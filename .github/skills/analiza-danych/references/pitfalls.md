# Pułapki z realnych analiz

Format: objaw, przyczyna, jak uniknąć. Dopisuj nowe po każdej analizie, jeśli są ogólne (specyfika domeny: [domain-retaildw](./domain-retaildw.md)).

## Proces

| Objaw | Przyczyna | Jak uniknąć |
|---|---|---|
| Użytkownik prosi o podsumowanie po anulowaniu pytania | pytanie zadane bez podsumowania | zawsze najpierw podsumowanie na czacie, potem `vscode_askQuestions` |
| Nieprzeliczone liczby w tekście (błąd rachunkowy) | przepisywanie z pamięci | przeliczać różnice i % z wyników zapytań, zanim wpiszesz do handoffu/raportu |
| Uszkodzone polskie znaki w pliku | błąd zapisu | po zapisie sprawdzić plik (np. wyszukać fragment) i poprawić |
| Wynik zapytania ogromny (metadane kolumn) | surowy wynik narzędzia | kompaktować wynik do tekstu (`STRING_AGG`), wiele grup w jednym zapytaniu |
| Raport pomija element wymagany przez zgłoszenie | użytkownik odznaczył element | wypisać lukę i konsekwencję, zapytać raz |
| Niepotwierdzone założenie w mailu jako fakt (np. waluta) | skrót w sformułowaniu | w mailu/raporcie oznaczyć "do potwierdzenia" lub pominąć |

## Dane

| Objaw | Przyczyna | Jak uniknąć |
|---|---|---|
| Liczba inna niż ta, którą biznes widział wcześniej | pełne przeładowanie danych po dacie pytania | sprawdzić log ładowania, zapisać datę załadunku w handoffie |
| Suma kolumny `Transactions` nie zgadza się | `COUNT(DISTINCT)` per grupa nie sumuje się | liczyć z faktu na właściwym ziarnie |
| Daty "tygodnia" nie pasują do kalendarza | `MIN/MAX` dat ze sprzedażą zamiast granic tygodnia | używać tygodnia ISO z wymiaru dat |
| Różnica groszy między netto a brutto/stawka | zaokrąglenie per linia | opisać w cross-checku, nie ukrywać |
| Wiersze znikają z wyniku | INNER JOIN do wymiarów | anti-join, `RowsRejected` |
| Wynik "po zwrotach" ≠ wynik z widoku | widok nie odejmuje zwrotów | jawna definicja miary w raporcie |

## Interpretacja

| Objaw | Przyczyna | Jak uniknąć |
|---|---|---|
| "Rośnie" na podstawie dwóch punktów | za krótka seria | seria kilkunastu okresów; wartość vs udział osobno |
| Największy region/kategoria "wyjaśnia" spadek | efekt skali | porównać zmiany procentowe, nie tylko bezwzględne |
| Przyczyna podana jako fakt (sezon, pogoda) | brak testu | oznaczyć jako hipotezę niezweryfikowaną |
| Dodatkowe odkrycie zasłania odpowiedź | zbyt dużo informacji | odpowiedź na pytanie zgłoszenia na początku, odkrycia dodatkowe w osobnej sekcji |
| Orientacyjne wartości z dokumentacji użyte jako dane | brak weryfikacji | zawsze oznaczać "orientacyjne" |
