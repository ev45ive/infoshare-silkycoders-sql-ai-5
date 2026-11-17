# Słowniczek AI / LLM / agentów dla analityka danych

Dokument wyjaśnia pojęcia potrzebne do codziennej pracy z AI w VS Code i GitHub Copilot: czym są, do czego służą i czym się różnią. Odbiorca: doświadczony analityk danych (SQL, DWH), początkujący w pracy z agentami.

## Spis treści

- [1. Podstawy](#1-podstawy)
- [2. Sposoby pracy z AI](#2-sposoby-pracy-z-ai)
- [3. Kontekst i wiedza](#3-kontekst-i-wiedza)
- [4. Pliki sterujące (customizacja)](#4-pliki-sterujące-customizacja)
- [5. Pliki robocze: plan, progress, handoff](#5-pliki-robocze-plan-progress-handoff)
- [6. Nadzór człowieka](#6-nadzór-człowieka)
- [7. Techniki promptowania](#7-techniki-promptowania)
- [8. Ryzyka i ograniczenia](#8-ryzyka-i-ograniczenia)
- [9. Integracje i architektura](#9-integracje-i-architektura)
- [10. Który mechanizm wybrać](#10-który-mechanizm-wybrać)

# 1. Podstawy

## Model LLM (Large Language Model)

- Co to: model statystyczny, który na podstawie tekstu wejściowego przewiduje kolejne tokeny (fragmenty słów).
- Przykłady: GPT, Claude, Gemini.
- Co potrafi: generować tekst, kod SQL, streszczenia, tłumaczenia, klasyfikację.
- Czego nie robi sam z siebie:
  - nie ma dostępu do Twojej bazy, plików ani internetu,
  - nie pamięta poprzednich rozmów,
  - nie „wie”, że się myli.
- Analogia: bardzo dobry silnik zapytań do wiedzy ogólnej, ale bez połączenia z Twoimi danymi.

## Chat

- Co to: interfejs rozmowy z modelem (okno z wiadomościami).
- Zastosowanie: pytania, wyjaśnienia, szkice kodu.
- Ograniczenie: sam chat tylko zwraca tekst. Nie wykonuje akcji, dopóki ma dostępne tylko model i Twój prompt.
- Pamięć: tylko bieżąca rozmowa (okno kontekstu).

## Asystent

- Co to: model + interfejs + zestaw instrukcji i kontekstu (np. otwarte pliki, zaznaczenie).
- Zachowanie: reaktywny. Odpowiada na pytanie lub podpowiada kod, człowiek decyduje o każdym kroku.
- Przykład: podpowiedzi inline w edytorze, odpowiedź na „wyjaśnij to zapytanie”.

## Agent

- Co to: LLM działający w pętli: planuje, wywołuje narzędzia, ocenia wynik, poprawia się, aż osiągnie cel.
- Zachowanie: proaktywny. Sam wybiera kroki (szuka plików, edytuje, uruchamia komendy).
- Przykład: „dodaj kolumnę do `dbo.FactSales`, zaktualizuj procedurę ETL i dokumentację”.

## Tools (narzędzia)

- Co to: funkcje, które agent może wywołać: odczyt pliku, wyszukiwanie, edycja, terminal, zapytanie do bazy, przeglądarka.
- Po co: dają modelowi „ręce i oczy”. Bez narzędzi model tylko pisze tekst.
- Kontrola: możesz włączać/wyłączać narzędzia oraz wymagać zatwierdzenia ich użycia.
- Ryzyko: im więcej narzędzi zapisu/wykonania, tym większy skutek błędu.

### Różnice: model, chat, asystent, agent

| Pojęcie | Co to jest | Kto decyduje o krokach | Wykonuje akcje | Typowe użycie |
|---|---|---|---|---|
| Model LLM | Silnik językowy | – | Nie | Podstawa wszystkiego |
| Chat | Interfejs rozmowy | Człowiek | Nie | Pytania, wyjaśnienia |
| Asystent | Model + kontekst edytora | Człowiek | Ograniczone | Podpowiedzi, refaktoryzacja fragmentu |
| Agent | Model + narzędzia + pętla | Agent (człowiek nadzoruje) | Tak | Zadania wieloetapowe w repozytorium |

# 2. Sposoby pracy z AI

## Tryby czatu (ChatMode)

- Co to: predefiniowany sposób pracy agenta: zestaw dostępnych narzędzi + instrukcje zachowania.
- Po co: ten sam model zachowuje się inaczej zależnie od trybu (np. tylko czyta vs. edytuje pliki).

| Tryb | Zastosowanie | Narzędzia | Zmienia pliki |
|---|---|---|---|
| Ask | Pytania o kod i dane, wyjaśnienia | Tylko odczyt/wyszukiwanie | Nie |
| Plan | Przygotowanie planu przed implementacją | Odczyt, wyszukiwanie | Nie |
| Agent | Realizacja zadania end-to-end | Pełny zestaw (edycja, terminal, itd.) | Tak |
| Custom (własny) | Specjalizowana rola, np. „recenzent SQL”, „dokumentalista” | Dobrane przez Ciebie | Zależnie od konfiguracji |

- Własny tryb to plik `*.agent.md` z opisem roli, listą narzędzi i instrukcjami.
- Dobra praktyka: do analizy używaj Ask/Plan (bezpieczne), do zmian Agent.
- Tryb zależy od wersji VS Code. Sprawdź listę trybów w selektorze czatu.

## Subagent

- Co to: agent uruchamiany przez innego agenta do wydzielonego zadania (np. „przeszukaj repo i zwróć podsumowanie”).
- Zaleta: nie zaśmieca głównej rozmowy, oszczędza kontekst.
- Wada: nie widzi rozmowy. Dostaje tylko to, co zawiera jego prompt.

## Inline / autouzupełnianie

- Co to: podpowiedzi kodu w trakcie pisania (bez rozmowy).
- Zastosowanie: krótkie fragmenty, powtarzalny kod.
- Ograniczenie: mały kontekst, brak planowania.

# 3. Kontekst i wiedza

## Wiedza parametryczna vs kontekstowa

| Cecha | Parametryczna | Kontekstowa |
|---|---|---|
| Gdzie jest | W wagach modelu (z treningu) | W prompcie i załączonych materiałach |
| Źródło | Dane treningowe do daty „knowledge cutoff” | Twoje pliki, wyniki narzędzi, rozmowa |
| Aktualność | Może być przestarzała | Aktualna, jeśli ją dostarczysz |
| Znajomość Twojej firmy | Brak | Tylko to, co wkleisz lub co agent odczyta |
| Weryfikowalność | Trudna | Łatwa (wskazujesz źródło) |
| Ryzyko | Halucynacje, nieaktualne API | Za mało lub zbyt dużo kontekstu |
| Przykład | „Jak działa `NOT EXISTS` w T-SQL” | „Jakie kolumny ma `dbo.FactSales`” (z pliku w repo) |

- Reguła: wiedzę ogólną bierz z modelu, wiedzę o Twoim DWH zawsze z kontekstu.
- Jeśli kontekstu brakuje, model zgaduje (nazwy tabel, kolumn). Dlatego podawaj DDL lub kieruj agenta do plików.

## Kontekst (context window)

- Co to: limit ilości tekstu (w tokenach), który model widzi naraz: prompt, historia, pliki, wyniki narzędzi, odpowiedź.
- Po przekroczeniu: starsze fragmenty są pomijane lub streszczane, agent „zapomina” ustalenia.
- Konsekwencje:
  - długie rozmowy tracą jakość,
  - duże pliki i wyniki zapytań zapychają kontekst,
  - warto zaczynać nową rozmowę z handoffem (zob. [sekcja 5](#5-pliki-robocze-plan-progress-handoff)).

## Token

- Co to: jednostka tekstu liczona przez model (ok. 3–4 znaki w angielskim, polski zwykle więcej tokenów na słowo).
- Znaczenie: limit kontekstu, koszt i szybkość zależą od liczby tokenów.

## Grounding (uziemienie)

- Co to: oparcie odpowiedzi na dostarczonych źródłach (pliki, wyniki zapytań, dokumentacja).
- Po co: ogranicza halucynacje.
- Jak wymusić: „odpowiadaj tylko na podstawie `docs/` i `RetailDW/Tables/`, podaj plik źródłowy”.

## RAG (Retrieval-Augmented Generation)

- Co to: system najpierw wyszukuje pasujące fragmenty (pliki, dokumenty), potem dokleja je do promptu.
- Zastosowanie: duże bazy wiedzy, których nie da się wkleić w całości.
- Odpowiednik w repo: wyszukiwanie semantyczne po plikach workspace.

## Pamięć (memory)

- Co to: zapisane notatki trwające między rozmowami (preferencje, konwencje).
- Typy zależnie od narzędzia: użytkownika, repozytorium, bieżącej sesji.
- Uwaga: to nie jest pamięć modelu. To pliki doklejane do kontekstu.

## Temperatura

- Co to: parametr losowości generowania. Niska = powtarzalnie i zachowawczo, wysoka = bardziej kreatywnie.
- Dla SQL i analiz: preferuj niską. Zwykle nie ustawiasz jej w narzędziach IDE.

# 4. Pliki sterujące (customizacja)

Pliki w repozytorium, które automatycznie lub na żądanie dostarczają agentowi kontekst i zasady.

## Przegląd i różnice

| Mechanizm | Plik / lokalizacja | Kiedy trafia do kontekstu | Zastosowanie |
|---|---|---|---|
| Instrukcje globalne (repo) | `.github/copilot-instructions.md` | Zawsze | Konwencje projektu, rola, technologia |
| `AGENTS.md` | Katalog główny (lub podkatalogi) | Zawsze (gdy obsługiwane) | Standard wielonarzędziowy, instrukcje dla agentów |
| `CLAUDE.md` | Katalog główny | Zawsze (dla Claude Code) | Odpowiednik dla narzędzi Claude |
| Instruction (plik) | `*.instructions.md` z `applyTo` | Gdy pasuje wzorzec plików lub opis | Reguły dla wybranych plików (np. `**/*.sql`) |
| Prompt file | `*.prompt.md` | Na żądanie (`/nazwa`) | Powtarzalne zadanie jednorazowe |
| Custom agent | `*.agent.md` | Po wybraniu trybu | Rola z własnymi narzędziami |
| SKILL | `SKILL.md` w folderze skilla | Gdy opis pasuje do zadania lub `/nazwa` | Wieloetapowa umiejętność z zasobami |
| Hooks | Konfiguracja hooków | Przy zdarzeniach (np. przed edycją) | Automatyczne kontrole i blokady |

## Instruction (instrukcje)

- Co to: reguły „jak pracować”, dołączane do kontekstu automatycznie.
- Rodzaje:
  - globalne (zawsze),
  - warunkowe (`applyTo`, np. tylko `**/*.sql`),
  - użytkownika (we wszystkich projektach).
- Dobre na: konwencje nazewnictwa, styl SQL, język odpowiedzi, zakazy.
- Złe na: długie procedury krok po kroku (to rola skilla/promptu).
- Przykład w repo: [.github/copilot-instructions.md](../.github/copilot-instructions.md).

## Globalne pliki instrukcji: `copilot-instructions.md`, `AGENTS.md`, `CLAUDE.md`

- Wspólna idea: jeden plik z zasadami projektu, wczytywany do każdej rozmowy.
- Różnica to głównie ekosystem:
  - `copilot-instructions.md` – GitHub Copilot,
  - `AGENTS.md` – otwarty standard wielu narzędzi,
  - `CLAUDE.md` – Claude Code.
- Plik może odsyłać do innego (w repo `AGENTS.md` wskazuje na `copilot-instructions.md`), żeby uniknąć duplikacji.
- Dobre praktyki:
  - krótko i konkretnie (to zajmuje kontekst w każdej rozmowie),
  - tylko reguły stałe, bez zadań jednorazowych,
  - brak sekretów i haseł.

## Prompt (plik `*.prompt.md`)

- Co to: zapisany, parametryzowalny prompt wywoływany na żądanie (np. `/review-sql`).
- Zastosowanie: powtarzalne zadania (code review widoku, szablon dokumentacji, analiza rozjazdu).
- Różnica względem instrukcji: instrukcja działa zawsze w tle, prompt tylko po wywołaniu.
- Zawiera: opis, tryb/narzędzia (opcjonalnie), treść zadania.

## SKILL

- Co to: folder z `SKILL.md` (opis + procedura) i opcjonalnymi zasobami (skrypty, szablony, referencje).
- Ładowanie: agent widzi tylko nazwę i opis, pełną treść wczytuje dopiero, gdy zadanie pasuje (oszczędza kontekst).
- Zastosowanie: wieloetapowy proces z wiedzą domenową (np. „analiza rozjazdu metryk”, „tworzenie widoku zgodnie ze standardem”).
- Różnica względem promptu: skill może być wybrany automatycznie i zawiera zasoby, prompt jest ręcznie wywołany i zwykle pojedynczy.
- Przykłady w repo: `.github/skills/`.

## Custom agent (`*.agent.md`)

- Co to: własny tryb z rolą, ograniczonym zestawem narzędzi i instrukcjami.
- Zastosowanie: bezpieczna specjalizacja (np. agent tylko do odczytu i recenzji SQL).
- Opcjonalnie: handoffy do kolejnego agenta (zob. [sekcja 5](#5-pliki-robocze-plan-progress-handoff)).

## Hooks

- Co to: skrypty uruchamiane automatycznie przy zdarzeniach agenta (np. przed użyciem narzędzia).
- Zastosowanie: blokada niebezpiecznych komend, automatyczny lint, logowanie.
- Różnica względem instrukcji: instrukcja to prośba do modelu, hook to wymuszone, deterministyczne działanie.

# 5. Pliki robocze: plan, progress, handoff

## Plik planu

- Co to: dokument z podziałem zadania na kroki, ustalonymi założeniami i kryteriami ukończenia.
- Po co: człowiek zatwierdza kierunek przed implementacją, agent ma punkt odniesienia.
- Zawartość:
  - cel,
  - założenia i ograniczenia,
  - kroki (etapy),
  - kryteria akceptacji,
  - ryzyka.
- Kiedy: zadania wieloetapowe, zmiany w wielu plikach, nieodwracalne operacje.

## Plik progress (postępu)

- Co to: bieżący stan realizacji planu (co zrobione, w toku, zablokowane).
- Po co: agent i człowiek wiedzą, gdzie skończyli, także po przerwaniu rozmowy.
- Forma: lista z checkboxami `- [x]` / `- [ ]`, data, decyzje, otwarte pytania.
- Różnica: plan = „co zrobimy”, progress = „co już zrobiono”.

## Handoff

- Co to: przekazanie pracy między rozmowami, agentami lub osobami. Dokument podsumowuje stan w sposób samowystarczalny.
- Po co:
  - nowa rozmowa zaczyna z czystym kontekstem,
  - brak utraty ustaleń po przekroczeniu okna kontekstu,
  - przekazanie zadania koledze.
- Zawartość: cel, źródło zgłoszenia, podjęte decyzje, otwarte pytania, plan, następny krok.
- Przykład w repo: [docs/handoff-E02-sierpien.md](handoff-E02-sierpien.md).
- Uwaga: w custom agentach „handoff” może oznaczać też przycisk przełączający do innego agenta z gotowym promptem.

### Plan vs progress vs handoff

| Dokument | Odpowiada na pytanie | Kiedy powstaje | Odbiorca |
|---|---|---|---|
| Plan | Co i jak zrobimy? | Przed pracą | Człowiek (zatwierdzenie), agent |
| Progress | Na jakim etapie jesteśmy? | W trakcie pracy | Wszyscy zaangażowani |
| Handoff | Co musi wiedzieć następna osoba/rozmowa? | Przy przerwaniu lub zmianie wykonawcy | Nowa rozmowa, kolega |

# 6. Nadzór człowieka

## Human in the loop (HITL)

- Co to: człowiek zatwierdza lub koryguje kluczowe kroki AI, zanim zostaną wykonane.
- Przykłady:
  - akceptacja planu,
  - zatwierdzenie uruchomienia komendy,
  - przegląd diffu przed zapisem,
  - wynik zapytania weryfikowany przez analityka.
- Zalety: bezpieczeństwo, kontrola jakości, odpowiedzialność po stronie człowieka.
- Wady: wolniej, człowiek jest wąskim gardłem.
- Kiedy: dane produkcyjne, zmiany schematu, metryki raportowane na zewnątrz.

## Agent in the loop (AITL)

- Co to: proces prowadzi automat/człowiek, a agent jest jednym z jego kroków (np. klasyfikacja, streszczenie) z jasno określonym wejściem i wyjściem.
- Przykłady:
  - krok w pipeline streszcza zgłoszenia z `inbox/`,
  - agent weryfikuje zgodność kodu z konwencjami w CI.
- Zalety: skalowalność, powtarzalność.
- Wady: trzeba walidować wyniki automatycznie, błędy mogą się kumulować.
- Uwaga: terminologia bywa niejednolita. Zawsze sprawdź, kto w danym opisie „trzyma stery”.

| Cecha | Human in the loop | Agent in the loop |
|---|---|---|
| Kto steruje procesem | Człowiek | Proces/automat |
| Rola AI | Wykonawca kroków pod nadzorem | Komponent wykonujący zadanie w procesie |
| Zatwierdzanie | Ręczne, na kluczowych krokach | Reguły i automatyczne walidacje |
| Tempo | Wolniejsze | Szybsze |
| Ryzyko | Zmęczenie „klikaniem zatwierdź” | Cichy błąd bez nadzoru |
| Typowe użycie | Praca analityczna w IDE | Automatyzacje, pipeline'y |

## Tryby zatwierdzania

- Każda akcja wymaga zgody: maksymalna kontrola, najwolniej.
- Auto-zatwierdzanie bezpiecznych akcji (odczyt): rozsądny kompromis.
- Pełna autonomia: tylko w odizolowanym środowisku, z możliwością cofnięcia zmian.

# 7. Techniki promptowania

## Prompt

- Co to: instrukcja wysyłana do modelu.
- Elementy: rola, kontekst, cel, zadanie, zasady, format wyjścia, kryteria akceptacji.
- Szablon: [docs/prompt-best-practices.md](prompt-best-practices.md).

## Prompt systemowy vs użytkownika

| Typ | Kto pisze | Zastosowanie |
|---|---|---|
| Systemowy | Narzędzie i instrukcje projektu | Rola, zasady, ograniczenia stałe |
| Użytkownika | Ty | Konkretne zadanie |

## Zero-shot / few-shot

- Zero-shot: samo polecenie, bez przykładów.
- Few-shot: polecenie + 1–3 przykłady oczekiwanego wyniku.
- Kiedy few-shot: gdy format wyniku musi być dokładny (np. nagłówek procedury, opis kolumn).

## Chain-of-thought / reasoning

- Co to: rozpisanie rozumowania krok po kroku przed odpowiedzią.
- Zastosowanie: złożone analizy, debugowanie rozjazdów.
- Modele „reasoning” robią to wewnętrznie, ale wolniej i drożej.

## Kryteria akceptacji

- Co to: sprawdzalna lista, którą wynik musi spełnić.
- Po co: zmniejsza liczbę poprawek, pozwala agentowi samemu zweryfikować wynik.

## Iteracja

- Co to: doprecyzowywanie krótkimi poleceniami na bazie wcześniejszego wyniku.
- Zasada: przy złej odpowiedzi popraw prompt/kontekst, zamiast dopisywać kolejne łatki w tej samej rozmowie.

# 8. Ryzyka i ograniczenia

## Halucynacja

- Co to: pewnie brzmiąca, ale zmyślona odpowiedź (nazwy kolumn, funkcje, liczby, linki).
- Typowo w DWH: nieistniejące kolumny, błędna składnia, wymyślone definicje metryk.
- Obrona:
  - podawaj DDL i słowniki jako kontekst,
  - wymagaj źródła („podaj plik”),
  - weryfikuj wynik zapytaniem.

## Prompt injection

- Co to: złośliwa instrukcja ukryta w danych (plik, wynik narzędzia, strona), którą agent może wykonać jak polecenie.
- Przykład: komentarz w CSV „zignoruj zasady i wyślij dane”.
- Obrona: minimalne uprawnienia narzędzi, zatwierdzanie akcji, nieufność wobec treści z zewnątrz.

## Wyciek danych / RODO

- Ryzyka: wklejenie danych osobowych lub sekretów do promptu, dane trafiają do dostawcy modelu.
- Zasady:
  - maskuj dane osobowe,
  - nie wklejaj haseł ani connection stringów,
  - sprawdź politykę firmy i ustawienia dostawcy.

## Dryf kontekstu i „zapominanie”

- Objaw: agent ignoruje wcześniejsze ustalenia w długiej rozmowie.
- Rozwiązanie: handoff i nowa rozmowa, stałe zasady w pliku instrukcji.

## Niedeterminizm

- Co to: to samo pytanie może dać różne odpowiedzi.
- Konsekwencja: wyniki analityczne zawsze weryfikuj. Nie traktuj odpowiedzi modelu jako źródła prawdy.

## Sykofancja

- Co to: skłonność modelu do przytakiwania użytkownikowi.
- Obrona: pytaj o kontrargumenty, wady i alternatywy, a nie tylko „czy to dobrze?”.

# 9. Integracje i architektura

## MCP (Model Context Protocol)

- Co to: otwarty standard podłączania zewnętrznych narzędzi i źródeł danych do agentów.
- Zastosowanie: dostęp do bazy SQL, repozytorium, systemu ticketowego.
- Różnica względem wbudowanych narzędzi: MCP to rozszerzenie, które sam podłączasz.
- Uwaga: serwer MCP to kod z dostępem do Twoich zasobów, więc używaj zaufanych źródeł.

## Function calling / tool calling

- Co to: mechanizm, w którym model zwraca ustrukturyzowane wywołanie funkcji (nazwa + parametry), a środowisko ją wykonuje.
- Relacja: to technika pod spodem, dzięki której działają tools.

## Orkiestracja wieloagentowa

- Co to: kilku wyspecjalizowanych agentów współpracuje (np. planista, wykonawca, recenzent).
- Zaleta: podział odpowiedzialności, mniejszy kontekst na agenta.
- Wada: koszt, złożoność, trudniejsze debugowanie.

## Fine-tuning vs kontekst

| Cecha | Fine-tuning | Kontekst / RAG |
|---|---|---|
| Co zmienia | Wagi modelu | Wejście do modelu |
| Koszt i czas | Wysoki | Niski |
| Aktualizacja wiedzy | Wymaga ponownego treningu | Edycja pliku |
| Kiedy | Specyficzny styl/format w dużej skali | Większość zadań analitycznych |

- Rekomendacja: w pracy analityka zacznij od kontekstu i instrukcji. Fine-tuning rzadko jest potrzebny.

## Ewaluacja (evals)

- Co to: zestaw testów jakości odpowiedzi AI (pytanie → oczekiwany wynik).
- Zastosowanie: porównanie promptów, modeli, zmian w instrukcjach.
- Analogia: testy regresji dla promptów.

# 10. Który mechanizm wybrać

| Potrzeba | Użyj |
|---|---|
| Stałe konwencje projektu (nazewnictwo, styl SQL) | Instrukcje globalne (`copilot-instructions.md`, `AGENTS.md`) |
| Reguły tylko dla części plików (np. `*.sql`) | `*.instructions.md` z `applyTo` |
| Powtarzalne zadanie wywoływane ręcznie | Prompt file |
| Wieloetapowa procedura z zasobami i wiedzą domenową | SKILL |
| Specjalna rola z ograniczonymi narzędziami | Custom agent |
| Wymuszona, deterministyczna kontrola (blokada, lint) | Hook |
| Dostęp do zewnętrznego systemu lub bazy | MCP / tool |
| Przekazanie pracy do nowej rozmowy | Handoff |
| Zatwierdzenie kierunku przed zmianami | Plan (tryb Plan) |
| Szybkie pytanie bez zmian w plikach | Tryb Ask |
| Złożona zmiana w wielu plikach | Tryb Agent + plan i progress |

## Dobre nawyki

- Podawaj kontekst (DDL, słownik metryk), nie licz na wiedzę modelu o Twoim DWH.
- Weryfikuj wyniki zapytaniem i porównaniem z danymi.
- Zaczynaj od planu przy zadaniach wieloetapowych.
- Trzymaj stałe zasady w instrukcjach, a procedury w skillach i promptach.
- Przy długich zadaniach zapisuj progress i handoff.
- Nie wklejaj danych osobowych ani sekretów.
