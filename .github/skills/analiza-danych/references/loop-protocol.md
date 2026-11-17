# Protokół pętli kroku

## Cykl jednego kroku

1. **Wykonaj** tylko zaakceptowane kroki.
2. **Zapisz** w handoffie (status, odkrycia ze źródłem, SQL, otwarte pytania).
3. **Podsumuj na czacie** ([szablon](../assets/step-summary-template.md)).
4. **Zapytaj** przez `vscode_askQuestions` o kolejne kroki.

Nie zadawaj pytania o kolejne kroki bez podsumowania z kroku 3. Jeśli użytkownik anuluje pytanie lub poprosi o podsumowanie: wypisz podsumowanie, potem zadaj pytanie ponownie.

Odpowiedź z wieloma zaznaczeniami wykonuj tylko wtedy, gdy opcje się nie wykluczają. Jeśli zaznaczono opcje sprzeczne (np. kroki i "zakończ"), nie wykonuj żadnej z nich i zapytaj ponownie.

## Format pytania `vscode_askQuestions`

- `header`: unikalny, max 50 znaków ("Kolejne kroki", "Zawartość raportu").
- `question`: jedno zdanie, max 200 znaków.
- `multiSelect: true`, gdy opcje się nie wykluczają (kroki, elementy raportu). `false` dla wyboru jednej ścieżki.
- `options`: 3-7 pozycji. Etykieta zaczyna się od litery kroku (A., B., ...), literki rosną w całej analizie i się nie powtarzają.
- `description` opcji: koszt i zakres ("ok. 4 wiersze", "kilkanaście wierszy", "bez bazy").
- `recommended: true` dla 1-3 opcji, które najlepiej prowadzą do odpowiedzi.
- Pole dowolne zostaw włączone (domyślnie). Użytkownik może wpisać własne pytanie lub krok.
- Opcja "Zakończ analizę" nie jest w tym samym pytaniu co kroki. Zadaj ją osobnym pytaniem po wykonaniu kroków. "Pokaż SQL do pliku" może być krokiem.
- Nie pytaj o rzeczy, które da się ustalić z kodu lub dokumentacji.

Pytania wielosekcyjne (np. zawartość raportu + luki + plik) łącz w jednym wywołaniu.

## Limity zapytań do bazy

- Max 3-4 zapytania na krok, każde małe: zakres dat, agregacja, `TOP`.
- Zawsze ogranicz: okres, ziarno, liczbę grup. Bez nieograniczonych `SELECT *`.
- Wiele grup w jednym zapytaniu: kompaktuj wynik do jednego tekstu (`STRING_AGG(CONCAT(...), CHAR(10))`), bo surowy wynik narzędzia jest rozwlekły (metadane kolumn).
- Nie ładuj całych tabel faktów do czatu; liczysz w bazie.
- Zapytania niezależne wykonuj równolegle, zależne po kolei.
- Kontrola spójności bezpośrednio związana z zaakceptowanym krokiem (np. suma = całość) jest dozwolona. Nowe hipotezy, inne okresy i źródła wymagają zgody.
- Zapytania zapisuj w handoffie (sekcja "Zapytania"), w kolejności kroków.

## Propozycje kolejnych kroków

- Dobieraj z [suggestion-checklists](./suggestion-checklists.md) według fazy i typu analizy.
- Przy wyborze próbek, wymiarów, okresów, ziaren lub hipotez pokaż kilka wariantów do wyboru plus "własna propozycja".
- Opisuj koszt (liczba zapytań/wierszy) i co krok rozstrzyga.

## Aktualizacja handoffu po kroku

Statusy zapisuj jako emoji z legendą z [handoff](../assets/handoff-template.md) (⬜ 🔄 ✅ ⏭️ ⛔ dla kroków, 💭 🟢 🔴 ❔ dla hipotez, ⚠️ dla uwag); legenda zostaje w pliku handoffu.

Wymagane pola: data/stan, status kroków, nowe odkrycia (z kodem źródła: `K` kod, `D` dane, `W` wyniki, `T` trend, `S` drill-down), otwarte pytania, zapisane SQL. Szczegóły: [handoff](../assets/handoff-template.md).

## Weryfikacja przed wysłaniem podsumowania

- Przelicz ręcznie procenty i różnice, które wpisujesz do tekstu.
- Sprawdź, że sumy częściowe zgadzają się z całością.
- Po zapisie pliku sprawdź, czy polskie znaki nie zostały uszkodzone.
