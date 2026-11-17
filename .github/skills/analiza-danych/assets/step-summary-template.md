# Szablon podsumowania kroku (na czacie, przed pytaniem o kolejne kroki)

Zasady: krótko, tabele zamiast opisów, interpretacja oddzielona od faktów. Plik handoffu zaktualizowany przed wysłaniem podsumowania.

```markdown
## Podsumowanie kroków <litery>

**Co zrobiłem**
- <krok>: <jedno zdanie, zakres, liczba zapytań>
- Zaktualizowałem handoff: <link>

**Dowody**

| <wymiar> | <miara A> | <miara B> | Zmiana |
|---|---|---|---|
| ... | ... | ... | ... |

| Kontrola | Wynik |
|---|---|
| <np. widok vs fakt> | <identyczne / różnica> |

**Interpretacja**
- <wniosek 1: fakt z dowodem>
- <wniosek 2: oznacz hipotezę, jeśli bez testu>

**Odkrycia i zastrzeżenia**
- <nieoczekiwane odkrycie>
- <czego nie sprawdziłem / niepotwierdzone założenia>
```

Potem `vscode_askQuestions` z kolejnymi krokami (zob. [loop-protocol](../references/loop-protocol.md), [suggestion-checklists](../references/suggestion-checklists.md)).

## Lista kontrolna przed wysłaniem

- [ ] Różnice i procenty przeliczone ręcznie z wyników.
- [ ] Sumy częściowe = całość.
- [ ] Każde twierdzenie ma dowód (tabela lub źródło).
- [ ] Hipotezy oznaczone.
- [ ] Zastrzeżenia (waluta, definicja, niewykonane kontrole) wymienione.
- [ ] Handoff zaktualizowany.
