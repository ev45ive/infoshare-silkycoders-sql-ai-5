# <ID zgłoszenia> - Handoff i status analizy

- **Zgłoszenie:** <link do pliku zgłoszenia/analizy>
- **Baza:** <serwer/baza, zakres uprawnień, np. tylko SELECT z ograniczeniami>
- **Ostatnia aktualizacja:** <data>, po kroku <n>

## Cel

<jedno-dwa zdania: co zgłaszający chce wiedzieć, miara, okres, przekrój>

## Status kroków

| # | Krok | Status | Wynik |
|---|---|---|---|
| 1 | <np. Przegląd kodu> | zrobiony / w toku / do wyboru / pominięty | <odnośnik do odkryć: K1-K3> |
| 2 | <np. Stan danych: LoadLog> | | <D1-D2> |

Statusy: do wyboru, w toku, zrobiony, pominięty, zablokowany.

## Odkrycia (ze źródłem)

Kody: **K** kod/definicje, **D** dane/stan, **W** wyniki główne, **T** trend, **S** drill-down, **X** cross-check.

**Kod**
- K1. <fakt>. Źródło: <plik#linia>.

**Dane**
- D1. <fakt>. Źródło: <obiekt/zapytanie>.

**Wyniki**
- W1. <wartość z definicją>. Źródło: <widok, filtry>.

**Cross-check**
- X1. <kontrola i wynik>. Źródło: <zapytanie>.

**Trend / drill-down**
- T1. <seria, wniosek>. Źródło: <zapytanie>.
- S1. <przyczynek grupy>. Źródło: <zapytanie>.

## Hipotezy

| # | Hipoteza | Test | Status | Źródło |
|---|---|---|---|---|
| H1 | <twierdzenie> | <metoda> | hipoteza / potwierdzona / obalona / niezweryfikowana | |

## Decyzje

- <data/krok>: <decyzja użytkownika, np. zakres raportu, dostęp do bazy>

## Założenia (do potwierdzenia)

- <założenie, np. definicja miary, waluta>

## Otwarte pytania

- <pytanie> (do kogo, domyślna odpowiedź)

## Zapytania (SQL)

Krok <n> (<nazwa>):

```sql
<zapytanie>
```

## Luki / niewykonane kroki

- <krok niewykonany, powód, konsekwencja dla raportu>
