**Szkic odpowiedzi (nie wysłany)**

**Do:** Tomasz Barski, controlling
**Temat:** Re: Sierpień 2026 — rozjazd przy przeglądzie III kwartału

Cześć Tomasz,

różnica wynika po naszej stronie. Sprzedaż netto za sierpień 2026 w hurtowni zawierała 223 zduplikowane linie sprzedaży sklepowej, które weszły do hurtowni z pliku POS_20260817_02.csv. Ten plik powtarza wiersze z POS_20260817.csv.

Po usunięciu duplikatów sprzedaż netto za sierpień wynosi 2 608 664,46 zł, czyli tyle, ile pokazują kasy i system zamówień online. Kwotę 2 608 664,46 zł można pokazać audytorowi.

Różnica 57 885,35 zł to dokładnie suma netto tych zduplikowanych linii. Nie wynika z odrzuconych wierszy ładowania (0) ani z odjęcia zwrotów (raporty nie odejmują zwrotów, a ich wartość netto za sierpień to ok. 86 939 zł, więc nie tłumaczy różnicy).

Dowody: zestawienie sum z hurtowni, lista duplikatów w pliku źródłowym oraz zapytania SQL są w docs/analizy/2026-11-17-E02-handoff.md.

Do potwierdzenia przed wysłaniem:
- czy sprzedaż netto ma być przed zwrotami (przyjęte założenie),
- skąd powstał plik POS_20260817_02.csv (ponowny eksport lub import),
- czy zespół zdecyduje o poprawce w źródle czy w ETL.

Pozdrawiam,
Zespół analiz
