# Checklisty propozycji kolejnych kroków

Wybierz 3-7 pozycji z właściwej listy, dopasuj do zgłoszenia, dodaj koszt. Oznacz `recommended` te, które najszybciej domykają odpowiedź lub bramkę.

## Po Intake / Setup

- Przegląd kodu: widok, fakt, wymiary, ETL (bez bazy).
- Stan danych: log ładowania, świeżość.
- Liczba główna z widoku raportowego.
- Pytanie pomocnicze do zgłaszającego (definicja miary, waluta, zakres).
- Pokaż SQL i zapisz do pliku, bez wykonywania.

## Po rekonesansie definicji / stanie danych

- Liczba główna (okres + porównanie).
- Cross-check od razu (jeśli liczba jest prosta).
- Sprawdzenie pułapek zidentyfikowanych w kodzie (duplikaty, brak dopasowania wymiarów, zakres dat).
- Zwroty/korekty osobno, jeśli zgłoszenie dotyczy sprzedaży.

## Po wyniku głównym

- Cross-check inną drogą ([crosschecks](./crosschecks.md)): tabela faktów, źródło, inna miara.
- Trend: dłuższa seria, żeby ocenić "rośnie/spada".
- Drill-down zmiany (jeśli jest wyraźna różnica): wymiar po wymiarze.
- Zwroty / korekty.
- Pytanie pomocnicze do zgłaszającego.
- Zakończenie i raport (jeśli wszystkie kryteria spełnione).

## Po trendzie

- Test stabilności: udział/miara w oknie różnej długości (8, 16, 52 tygodni).
- Rok do roku (jeśli dane istnieją): porównanie tego samego okresu.
- Sezonowość/kalendarz: święta, promocje, początek sezonu.
- Rozbicie trendu na wymiar (region, kategoria).

## Po drill-down

- Zejście o jeden poziom niżej w wymiarze, który tłumaczy największą część zmiany.
- Seria czasowa dla głównego "winowajcy" (jednorazowy skok czy trend).
- Hipotezy przyczynowe do testu: zapas, cena/rabat, mix, kalendarz, jakość danych. Wybór wg [drilldown-methods](./drilldown-methods.md).
- Wymiar poboczny: kanał, format sklepu, region.
- Zatrzymanie: przyczyna poza zakresem danych, zapis jako hipoteza w raporcie.

## Gdy mamy odpowiedź / przed zamknięciem

- Cross-check (kilka dróg do wyboru).
- Domknięcie luk ze zgłoszenia (zwroty, data załadunku, definicje).
- Zakończ analizę i zaproponuj zawartość raportu.
- Szkic maila/odpowiedzi do zgłaszającego.

## Zawartość raportu (menu do wyboru, domyślnie to, czego wymagało zgłoszenie + dowody)

1. Odpowiedź: liczba z definicją i filtrami.
2. Rozbicie i porównanie (tabela).
3. Trend: co wiadomo, a czego nie.
4. Informacje wymagane przez zgłoszenie (np. zwroty, data przeładowania).
5. Dowody: cross-check, kontrole jakości.
6. Odkrycia dodatkowe (poza zakresem zgłoszenia).
7. Ograniczenia i otwarte pytania.
8. Załącznik: użyte SQL.
9. Szkic odpowiedzi do zgłaszającego.

Plik raportu: zaproponuj ścieżkę obok handoffu, z opcją "tylko czat".

## Zasady doboru

- Nigdy nie proponuj kroku, który wymaga danych niedostępnych (sprawdź w kodzie).
- Nie powtarzaj kroków już wykonanych (zajrzyj do handoffu).
- Jeśli różne próbki/okresy/ziarna są możliwe: pokaż 2-4 warianty z kosztem.
- Jeśli odkrycie jest nieoczekiwane, zaproponuj najpierw weryfikację odkrycia (jakość danych), potem interpretację.
