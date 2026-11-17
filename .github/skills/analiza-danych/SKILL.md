---
name: analiza-danych
description: 'Interaktywna analiza danych krok po kroku z plikiem handoff, pętlą propozycji (vscode_askQuestions), podsumowaniem po każdym kroku, drill-downem po hipotezach, cross-checkami i raportem/mailem na koniec. Use when: analiza zgłoszenia biznesowego na danych, "ile sprzedaliśmy", porównanie okresów, trend, spadek/wzrost, przyczyna zmiany, weryfikacja liczby, rozjazd danych, raport z dowodami, handoff analizy.'
argument-hint: 'Treść zgłoszenia lub pytanie analityczne (opcjonalnie: plik zgłoszenia)'
---

# Analiza danych (interaktywna, z handoffem)

Cel: nie tylko wynik, ale **zrozumienie drogi do niego**: hipotezy, dowody, weryfikacja. Użytkownik na każdym kroku decyduje, co dalej.

## Kiedy używać

- Pytanie biznesowe wymaga liczb z bazy (liczba, porównanie, trend, przyczyna zmiany, rozjazd).
- Użytkownik chce prowadzić analizę krok po kroku, z zapisem postępu i dowodów.

Nie używać do: pisania/zmiany kodu SQL w projekcie, samej analizy treści zgłoszenia bez danych (prompt `analiza-zgloszenia`), jednorazowego "pokaż SELECT".

## Zasady nienegocjowalne

1. **Wykonuj tylko zaakceptowane kroki.** Każdy następny krok proponujesz, nie wykonujesz z własnej inicjatywy.
2. **Pytania o kolejne kroki zawsze przez `vscode_askQuestions`**: multiSelect, jeśli ma sens, zawsze pole dowolne, zawsze opcja zatrzymania/własnej propozycji.
3. **Przed każdym pytaniem krótkie podsumowanie na czacie**: co zrobiłem, co odkryłem, tabela dowodów, interpretacja, zastrzeżenia. Bez tego nie pytaj. Format: [step-summary](./assets/step-summary-template.md).
4. **Handoff jest źródłem prawdy.** Proponujesz ścieżkę na starcie i aktualizujesz po każdym kroku: [handoff](./assets/handoff-template.md).
5. **Mało i małe zapytania.** Zakres dat, agregacja, `TOP`; skompaktowany wynik. Baza może być duża.
6. **Drill-down przez hipotezy**, nie "zrzut wszystkiego": [drilldown](./references/drilldown-methods.md).
7. **Każde odkrycie ma źródło** (plik+linia, obiekt, zapytanie). Fakt oddzielaj od interpretacji i hipotezy; hipotezy oznaczaj jako niezweryfikowane.
8. **Nie zgaduj, nie zakładaj.** Brak informacji = pytanie lub jawne założenie w handoffie, oznaczone do potwierdzenia.
9. **Nie łącz się z bazą bez zgody** i tylko `SELECT`. Zgoda na starcie, w pytaniu o ustawienia.
10. **Zanim zamkniesz analizę:** zaproponuj cross-check lub zakończenie, sprawdź kryteria akceptacji ze zgłoszenia, wskaż luki.

## Przebieg

| Faza | Cel | Szczegóły |
|---|---|---|
| 0. Intake | zrozumieć pytanie, typ pracy, kontekst | [process](./references/process.md) |
| 1. Setup | ścieżka handoffu, zgoda na bazę, pierwsze kroki | [process](./references/process.md) |
| 2. Rekonesans definicji | definicje miar, ziarno, filtry (bez bazy) | [process](./references/process.md) |
| 3. Stan danych | świeżość, log ładowania, kompletność | [process](./references/process.md) |
| 4. Wynik główny | liczba/odpowiedź z jawną definicją | [analysis-types](./references/analysis-types.md) |
| 5. Cross-check | ta sama liczba inną drogą | [crosschecks](./references/crosschecks.md) |
| 6. Drill-down / hipotezy / trend | zrozumieć dlaczego | [drilldown](./references/drilldown-methods.md) |
| 7. Zamknięcie | luki, raport, mail | [report](./assets/report-template.md), [email](./assets/email-template.md) |

Kolejność faz 3-6 jest elastyczna, ale każda faza ma bramkę (gate) w [process](./references/process.md).

## Pętla jednego kroku

1. Wykonaj zaakceptowane kroki (limit zapytań: [loop-protocol](./references/loop-protocol.md)).
2. Zapisz w handoffie: status, odkrycia ze źródłem, SQL, otwarte pytania.
3. Podsumuj na czacie (szablon kroku).
4. Zaproponuj kolejne kroki przez `vscode_askQuestions` ([suggestion-checklists](./references/suggestion-checklists.md)).
5. Gdy jest odpowiedź: zaproponuj cross-check lub zamknięcie.

## Zasoby

| Zasób | Po co |
|---|---|
| [references/process.md](./references/process.md) | fazy, bramki wejścia/wyjścia, kryteria zamknięcia |
| [references/loop-protocol.md](./references/loop-protocol.md) | protokół kroku, format pytań, limity zapytań, kompaktowanie wyników |
| [references/suggestion-checklists.md](./references/suggestion-checklists.md) | co proponować w której fazie |
| [references/drilldown-methods.md](./references/drilldown-methods.md) | drabiny wymiarów, dekompozycja, hipotezy, kryteria stopu |
| [references/analysis-types.md](./references/analysis-types.md) | bramki i hipotezy dla typów analiz |
| [references/crosschecks.md](./references/crosschecks.md) | katalog cross-checków i kryteria wystarczalności |
| [references/pitfalls.md](./references/pitfalls.md) | pułapki z realnych analiz |
| [references/domain-retaildw.md](./references/domain-retaildw.md) | specyfika repo RetailDW (jedyny plik zależny od domeny) |
| [assets/handoff-template.md](./assets/handoff-template.md) | szablon handoffu |
| [assets/step-summary-template.md](./assets/step-summary-template.md) | szablon podsumowania kroku na czacie |
| [assets/report-template.md](./assets/report-template.md) | szablon raportu końcowego |
| [assets/email-template.md](./assets/email-template.md) | szablon odpowiedzi do zgłaszającego |

Ładuj zasoby tylko wtedy, gdy są potrzebne w danej fazie.

## Rozszerzanie skilla

- Nowy typ analizy: dodaj sekcję w `analysis-types.md` (bramki, hipotezy, minimalne dowody).
- Nowa metoda drill-down lub cross-check: dopisz do odpowiedniego katalogu, z warunkiem użycia.
- Nowa domena/baza: skopiuj `domain-retaildw.md` jako `domain-<nazwa>.md` i dodaj wiersz do tabeli zasobów.
- Nowy szablon: dodaj do `assets/` i podlinkuj tutaj.
- Nowa pułapka: dopisz do `pitfalls.md` (objaw, przyczyna, jak uniknąć).
