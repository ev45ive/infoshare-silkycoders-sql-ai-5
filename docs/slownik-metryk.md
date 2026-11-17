# Słownik metryk Nordvik

Definicje używane w raportach sprzedaży, rentowności i zapasu. Kwoty podajemy w PLN, a udziały i dynamiki w procentach. Metryki liczymy dla wskazanego okresu i przekroju; jeśli w mianowniku jest zero, wynik wskaźnika pozostaje pusty.

Nazwy w kolumnie „Źródło” dotyczą bazy PostgreSQL `retaildw` (`databases/RetailDW-postgres/`): wymiary i fakty są w schemacie `dw`, widoki raportowe w `reporting`. Dawne nazwy z SQL Server (`dbo.FactSales` itd.) są zebrane w sekcji „Mapowanie nazw” na końcu.

## Sprzedaż

| Metryka | Definicja | Źródło |
| --- | --- | --- |
| **Sprzedaż brutto** | Wartość sprzedanego towaru z VAT, po rabacie. | `fact_sales.gross_amount` |
| **Rabat** | Kwota obniżki udzielonej na pozycjach sprzedaży. | `fact_sales.discount_amount` |
| **Sprzedaż netto** | Sprzedaż brutto bez VAT; dla odzieży obowiązuje 23% VAT. | `fact_sales.net_amount` |
| **Sztuki** | Liczba sprzedanych sztuk. | `fact_sales.quantity` |
| **Wartość przed rabatem** | Wartość towaru według ceny sprzedaży przed obniżką, z VAT. | `SUM(fact_sales.quantity * fact_sales.unit_price)` |
| **Stopa rabatu** | Rabat / wartość przed rabatem. | `fact_sales` |
| **Średnia cena netto sztuki** | Sprzedaż netto / sztuki. | `fact_sales` |
| **Udział kanału w sprzedaży** | Sprzedaż netto kanału / sprzedaż netto wszystkich kanałów w tym samym okresie. | `fact_sales` + `dim_store.channel` |
| **Zmiana sprzedaży tydzień do tygodnia** | (Sprzedaż netto bieżącego pełnego tygodnia − sprzedaż netto poprzedniego pełnego tygodnia) / sprzedaż netto poprzedniego tygodnia; oba tygodnie w tym samym przekroju. | `fact_sales` + `dim_date` |
| **Sprzedaż po zwrotach netto** | Sprzedaż netto − wartość zwrotów bez VAT przyjętych w tym okresie. | `fact_sales.net_amount`, `fact_returns.return_amount` |
| **Aktywne SKU** | Liczba różnych SKU sprzedanych w okresie. | `fact_sales.product_key` |
| **Sztuki na aktywne SKU** | Sztuki / liczba aktywnych SKU. | `fact_sales` |

W raportach zarządczych słowo **„sprzedaż”** bez doprecyzowania oznacza **sprzedaż netto**, przed odjęciem zwrotów. Sprzedaży brutto używamy, gdy pytanie dotyczy kwoty zapłaconej przez klienta.

Kanały to `ONLINE` i `STORE` z `dim_store.channel`.

## Rentowność

| Metryka | Definicja | Źródło |
| --- | --- | --- |
| **Koszt własny (COGS)** | Koszt sprzedanych sztuk: `SUM(quantity * unit_cost)`. | `fact_sales` |
| **Marża brutto** | Sprzedaż netto − koszt własny − wartość zwrotów bez VAT przyjętych w tym samym okresie. | `fact_sales`, `fact_returns` |
| **Marża %** | Marża brutto / sprzedaż netto. | Jak wyżej |
| **Średni koszt sprzedanej sztuki** | Koszt własny / liczba sprzedanych sztuk. | `fact_sales` |
| **Udział kosztu własnego w sprzedaży** | Koszt własny / sprzedaż netto. | `fact_sales` |

Zwroty obniżają marżę okresu **przyjęcia zwrotu**, nie okresu pierwotnej sprzedaży. `fact_returns.return_amount` jest kwotą z VAT; wartość zwrotów w definicji marży podajemy bez VAT.

## Transakcje i koszyk

| Metryka | Definicja | Źródło |
| --- | --- | --- |
| **Liczba transakcji** | Liczba unikalnych paragonów: `COUNT(DISTINCT transaction_no)`. | `fact_sales` |
| **Średni koszyk** | Sprzedaż netto / liczba transakcji. | `fact_sales` |
| **UPT** (units per transaction) | Sztuki / liczba transakcji. | `fact_sales` |

## Produktywność sklepu

| Metryka | Definicja | Źródło |
| --- | --- | --- |
| **Przychód na m²** | Sprzedaż netto / powierzchnia sprzedaży; liczony osobno dla sklepów stacjonarnych. | `fact_sales`, `dim_store.sales_area_m2` |

`dim_store.sales_area_m2` zawiera **bieżącą** powierzchnię. Przy porównaniu sprzed i po przebudowie (`dim_store.remodel_date`) obie strony są dzielone przez dzisiejszą powierzchnię. Kanał online nie ma powierzchni sprzedaży.

## Zapas i dostępność

| Metryka | Definicja | Źródło |
| --- | --- | --- |
| **Stan magazynowy** | Liczba sztuk na koniec dnia handlowego dla SKU w sklepie. | `fact_inventory_daily.stock_quantity` |
| **Dostępność** | Udział SKU ze stanem > 0 wśród SKU objętych zapasem na dany dzień i sklep. | `fact_inventory_daily` |
| **Sell-through** | Sztuki sprzedane w sezonie / (sztuki sprzedane w sezonie + stan na koniec okresu). | `fact_sales`, `fact_inventory_daily` |
| **SKU dostępne** | Liczba SKU ze stanem > 0 w zgłoszonym zapasie dla dnia i sklepu. | `fact_inventory_daily` |
| **SKU niedostępne** | Liczba SKU ze stanem ≤ 0 w zgłoszonym zapasie dla dnia i sklepu. | `fact_inventory_daily` |
| **Wartość zapasu w koszcie** | Suma stanu sztuk × bieżący koszt jednostkowy SKU na wybrany dzień. | `fact_inventory_daily`, `dim_product.unit_cost` |

Stan jest **migawką**, więc nie sumujemy stanów z kolejnych dni. Dostępność obejmuje SKU obecne w feedzie zapasu, nie cały katalog `dim_product`. Wartość zapasu używa bieżącego kosztu z wymiaru, więc nie jest historyczną wyceną księgową. Sell-through liczymy w obrębie jednego sezonu, zestawiając sprzedaż i stan z tego samego zakresu; feed zapasu obejmuje tylko bieżący sezon.

## Zwroty

| Metryka | Definicja | Źródło |
| --- | --- | --- |
| **Wskaźnik zwrotów** | Sztuki zwrócone / sztuki sprzedane w tym samym okresie i przekroju. | `fact_returns`, `fact_sales` |
| **Sztuki zwrócone** | Liczba sztuk przyjętych jako zwrot w okresie. | `SUM(fact_returns.quantity)` |
| **Wartość zwrotów netto** | Wartość przyjętych zwrotów bez VAT. | `SUM(fact_returns.return_amount) / 1.23` |

Powody zwrotów: `DAMAGED`, `WRONG_SIZE`, `CHANGED_MIND`, `OTHER`. Kanały porównujemy osobno, bo udział zwrotów online jest zwykle większy. Data i sklep w `fact_returns` oznaczają **przyjęcie zwrotu**; nie zakładaj, że to data i kanał pierwotnej sprzedaży.

## Kalendarz

- **Tydzień handlowy:** pełny tydzień ISO-8601 od poniedziałku do niedzieli; `dim_date.year_week` ma format np. `2026-W24`.
- **Rok ISO:** na przełomie roku może różnić się od roku kalendarzowego. Do grupowania tygodni używaj `iso_year` razem z `iso_week`, nigdy `calendar_year` z `iso_week`.
- **Sezon:** `SS` obejmuje luty–lipiec, a `AW` sierpień–styczeń, np. `AW26`.

## Mapowanie nazw: SQL Server → PostgreSQL

Reguła: PascalCase → snake_case, schemat `dbo` → `dw`, widoki bez prefiksu `vw_`. Typy: `NVARCHAR` → `varchar`, `DECIMAL` → `numeric`, `BIT` → `boolean`, `DATETIME2` → `timestamptz`.

| SQL Server | PostgreSQL |
| --- | --- |
| `dbo.DimDate`, `dbo.DimProduct`, `dbo.DimStore` | `dw.dim_date`, `dw.dim_product`, `dw.dim_store` |
| `dbo.FactSales`, `dbo.FactInventoryDaily`, `dbo.FactReturns` | `dw.fact_sales`, `dw.fact_inventory_daily`, `dw.fact_returns` |
| `dbo.LoadLog` | `etl.load_log` |
| `src.SalesRaw`, `src.InventoryRaw`, `src.ReturnsRaw` | `src.sales_raw`, `src.inventory_raw`, `src.returns_raw` |
| `stg.Sales`, `stg.Inventory`, `stg.Returns` | `stg.sales`, `stg.inventory`, `stg.returns` |
| `EXEC etl.LoadSales` / `LoadInventory` / `LoadReturns` | `CALL etl.load_sales()` / `load_inventory()` / `load_returns()` |
| `reporting.vw_SalesDaily`, `vw_SalesWeekly` | `reporting.sales_daily`, `reporting.sales_weekly` |
| `reporting.vw_MarginAnalysis`, `vw_StoreScorecard` | `reporting.margin_analysis`, `reporting.store_scorecard` |
| `reporting.vw_StockAvailability`, `vw_ProductPerformance` | `reporting.stock_availability`, `reporting.product_performance` |

Kolumny zmieniają nazwę według tej samej reguły (`NetAmount` → `net_amount`, `SalesAreaM2` → `sales_area_m2`, `YearWeek` → `year_week`, `SalesDate` w widoku → `sales_date`). Wyjątki w `dim_date`:

| SQL Server | PostgreSQL |
| --- | --- |
| `DimDate.Date` | `dim_date.full_date` |
| `DimDate.Year`, `Quarter`, `Month` | `dim_date.calendar_year`, `calendar_quarter`, `calendar_month` |
| `DimDate.IsWeekend`, `DimProduct.IsActive` (0/1) | `dim_date.is_weekend`, `dim_product.is_active` (`true`/`false`) |

Dane syntetyczne w wersji PostgreSQL generuje ta sama logika popytu, ale inna funkcja skrótu zastępuje `CHECKSUM`. Rozkłady, sezonowość i wbudowane anomalie (dublowany plik POS, brak plików magazynu, wyprzedane kurtki) są zachowane, jednak sumy nie są identyczne z wersją SQL Server.

