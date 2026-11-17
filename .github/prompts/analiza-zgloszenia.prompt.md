---
description: "Interaktywna analiza zgłoszenia od biznesu (bez bazy i bez SQL): krótki outline, pętla pytań i odpowiedzi ze źródłami, opcjonalny zapis do docs/analizy."
argument-hint: "Wklej treść zgłoszenia (lub wskaż plik z notatki/inbox)"
agent: agent
---

# Analiza zgłoszenia od biznesu

Cel: pomóc analitykowi lub developerowi DW **zrozumieć** zgłoszenie, a nie zasypać go danymi. Analizujesz zgłoszenie, nie dane. Odpowiadasz po polsku, w krótkich punktach.

## Wejście

- Treść zgłoszenia pochodzi z argumentu lub z wiadomości w czacie. Jeśli jej brak, poproś o nią i zakończ.
- Plik z `notatki/inbox/` czytaj tylko wtedy, gdy użytkownik wskaże konkretny plik.

## Zakazy

- Nie łącz się z bazą, nie uruchamiaj skryptów, nie pisz SQL.
- Nie czytaj `data/`, `.specstory/`, `notatki/` (poza wskazanym zgłoszeniem) ani istniejących plików w `docs/analizy/`.
- Do `docs/analizy/` wolno Ci tylko zapisać nowy plik, i to po potwierdzeniu ścieżki przez użytkownika (krok 6).
- Nie zgaduj, nie zakładaj, nie wymyślaj. Brak informacji zgłoś wprost i zamień na pytanie.

## Krok 1: cicha praca wstępna (bez wypisywania wyników)

Wczytaj z `.github/instructions/`:
- zawsze: `nordvik-kontekst-biznesowy`, `retaildw-schema`,
- gdy zgłoszenie dotyczy liczb lub miar: `nordvik-metryki` i `retaildw-analysis`,
- gdy dotyczy danych, braków lub załadunku: `retaildw-etl`.

Potem:
- zmapuj słowa ze zgłoszenia na domyślne znaczenia z `nordvik-metryki` (np. "sprzedaż", "marża"), zanim zapytasz o miarę,
- otwórz tylko te pliki w `RetailDW/` (widok, tabela, procedura), które są potrzebne, żeby podać źródła,
- duże dokumenty z `docs/` czytaj tylko we wskazanych sekcjach i tylko jeśli instrukcje nie wystarczą.

## Krok 2: outline startowy

Pokaż **max ok. 15 linii**, w punktach, bez tabel i bez pełnego szablonu:
- **Dotyczy:** temat, okres, miara, przekrój.
- **Pyta:** rola i jedno zdanie, co z niej wynika dla języka odpowiedzi.
- **Typ pracy:** jeden z typów z sekcji "Typologia".
- **Najważniejsze niewiadome lub ryzyka:** 3–5 punktów.
- **Wykonalność z obecnych danych:** tak, częściowo albo nie, z jednym powodem.

## Krok 3: pytanie do użytkownika

Użyj `vscode_askQuestions` (wielokrotny wybór plus pole swobodne), pytanie "Co chcesz pogłębić?". Opcje:
- tematy z sekcji "Materiał do pogłębiania" jeszcze nieomówione,
- 1–3 propozycje kolejnych kroków dobranych do tego zgłoszenia (np. "sprawdź, czy liczba z września się zgadza", "ustal, czy zwroty wchodzą do wyniku"),
- zawsze ostatnia opcja: **Koniec analizy**.

## Krok 4: odpowiedź na wybór

- Odpowiadaj tylko na to, o co użytkownik poprosił: max ok. 8 punktów, każdy krótki.
- Każde twierdzenie ma dowód: link do pliku i linii (`[plik](ścieżka#L10)`), nazwa widoku lub sekcja dokumentu. Fakty oddziel od interpretacji i oznacz interpretację.
- Zakończ jedną sugestią następnego kroku (zdanie).
- Wartości orientacyjne (udziały kanałów, wskaźniki zwrotów, czasy etapów cyklu) oznacz jako orientacyjne.

## Krok 5: powtórz pętlę

Wróć do kroku 3. Nie pokazuj tematów już omówionych. Zakończ pętlę, gdy użytkownik wybierze **Koniec analizy**.

## Krok 6: zapis (po zakończeniu pętli)

1. Użyj `vscode_askQuestions`: "Zapisać analizę do pliku?". Opcje: tak, nie. Dla "tak" zaproponuj ścieżkę `docs/analizy/RRRR-MM-DD-<id-zgłoszenia>-<slug>.md` (data dzisiejsza, id z nazwy zgłoszenia lub `zgloszenie`, krótki slug po angielsku lub bez polskich znaków) i pozwól ją potwierdzić lub zmienić w polu swobodnym.
2. Przy odpowiedzi "nie" zakończ krótkim podsumowaniem w czacie (max 5 punktów).
3. Po potwierdzeniu utwórz plik. Nie nadpisuj istniejącego pliku: przy kolizji nazwy zapytaj o inną ścieżkę.
4. Treść pliku (uporządkowana, z linkami do źródeł, bez historii pytań i wyborów):
   - nagłówek: tytuł, data, nadawca i rola, treść zgłoszenia w cytacie,
   - czego dotyczy,
   - kto pyta (wie, nie musi wiedzieć, ryzyka komunikacji),
   - co wiemy ze zgłoszenia,
   - co sprawdzić: w kodzie, w dokumentacji, w bazie (osobne listy),
   - domyślne znaczenia słów i co zostaje do potwierdzenia,
   - pytania do zadającego (z uzasadnieniem i proponowaną wartością domyślną),
   - typ pracy,
   - kryteria akceptacji,
   - zawartość odpowiedzi dla zgłaszającego,
   - zadanie dla analityka lub developera DW,
   - przyjęte założenia i otwarte pytania.
   Uzupełnij tylko sekcje, które wypracowano w pętli. Pozostałe uzupełnij na podstawie kroku 1 albo oznacz jako "do ustalenia".
5. Potwierdź zapis jednym zdaniem z linkiem do pliku.

## Materiał do pogłębiania

Tematy do opcji w kroku 3:
- **Kto pyta:** rola, co wie, czego nie musi wiedzieć, ryzyka komunikacji.
- **Co wiemy:** fakty ze zgłoszenia i definicje domyślne.
- **Co sprawdzić w kodzie i dokumentacji:** widoki, tabele, procedury, sekcje dokumentów.
- **Co sprawdzić w bazie:** konkretne kontrole (bez wykonywania ich).
- **O co dopytać:** pytania z uzasadnieniem i propozycją domyślnej wartości.
- **Typ pracy i uzasadnienie.**
- **Kryteria akceptacji.**
- **Zawartość odpowiedzi do zgłaszającego.**
- **Pułapki danych istotne dla tego zgłoszenia** (z listy poniżej, tylko te, które mają znaczenie).
- **Zadanie dla analityka lub developera DW.**

## Typologia pracy

Wybierz jeden typ (lub jeden główny i jeden dodatkowy):
- **Raport lub odczyt z widoku** – kryterium: liczba z jawną definicją, okresem, filtrami i źródłem.
- **Analiza przyczyn lub trendu** – kryterium: hipotezy, dowody, wniosek oddzielony od faktów.
- **Lineage lub rozbieżność liczb** – kryterium: wskazana przyczyna różnicy (dane, definicja miary, przeładowanie).
- **Zmiana lub nowy widok `reporting`** – kryterium: zgodność z definicją metryki, ziarno, opis w nagłówku, aktualizacja dokumentacji.
- **Zmiana ETL (`etl.Load*`)** – kryterium: poprawny przepływ `src → stg → dbo`, wpis w `LoadLog`, brak regresji w liczbach.
- **Zmiana modelu (tabela, kolumna, wymiar)** – kryterium: klucze i ograniczenia nazwane jawnie, wpływ na ETL i widoki opisany.
- **Migracja** – kryterium: zgodność liczb przed i po, plan wycofania.
- **Dokumentacja** – kryterium: odpowiedź wskazuje źródło w repo, a zmiany są spójne z kodem.
- **Jakość danych** – kryterium: skala problemu (`LoadLog.RowsRejected`, duplikaty, braki plików) i rekomendacja.
- **Niewykonalne z obecnych danych** – kryterium: jasne uzasadnienie braku (np. brak ID klienta, brak historii cen, brak dostaw) i propozycja alternatywy.

## Lista pułapek (sprawdzaj, wskazuj tylko istotne)

- "Sprzedaż" domyślnie to netto przed zwrotami. Brutto, po zwrotach, przed rabatem to osobne definicje (`nordvik-metryki`).
- Marża z `reporting.vw_MarginAnalysis` jest bez zwrotów, czyli nie zgadza się ze słownikiem firmy.
- Liczba transakcji to `COUNT(DISTINCT TransactionNo)`. Nie sumuje się jej po wymiarach, które dzielą transakcję. Wskaźniki liczy się z sum.
- Tydzień ISO (Pn–Nd). Grupowanie po `IsoYear` + `IsoWeek`. Porównania tydzień do tygodnia wymagają pełnych tygodni i tego samego przekroju.
- Zwroty są księgowane w dniu przyjęcia i nie mają klucza obcego do sprzedaży.
- Online nie ma metrażu. Metraż sklepu jest bieżący (Kraków Rynek zmienił się w 2026).
- Stany to migawki. Stany i zwroty są tylko za bieżący sezon.
- Brak ID klienta, brak historii cen, brak dostaw i przesunięć, brak danych web.
- Brak wiersza `Unknown` w wymiarach: rekordy bez dopasowania nie trafiają do faktów (porównaj z `LoadLog.RowsRejected`).
- Pełne przeładowanie ETL: dzisiejsza liczba może różnić się od wcześniejszej. Ponowne wgranie pliku może zduplikować wiersze.
- Szczyty (Black Friday, grudzień) i dołek (luty) wpływają na porównania rok do roku.
- Waluta: PLN i VAT 23% wg `nordvik-kontekst-biznesowy`. Nazwa widoku nie zawsze oznacza to, co liczy, więc sprawdź jego definicję.
