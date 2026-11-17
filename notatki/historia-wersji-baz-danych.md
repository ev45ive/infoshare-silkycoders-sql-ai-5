# Historia wersji: Microsoft SQL Server, PostgreSQL, MySQL

Stan na 2026-11-17. Daty w formacie RRRR-MM-DD.

Źródła:
- Microsoft: [Latest updates and version history for SQL Server](https://learn.microsoft.com/en-us/troubleshoot/sql/releases/download-and-install-latest-updates)
- Wikipedia: [History of Microsoft SQL Server](https://en.wikipedia.org/wiki/History_of_Microsoft_SQL_Server), [PostgreSQL](https://en.wikipedia.org/wiki/PostgreSQL), [MySQL](https://en.wikipedia.org/wiki/MySQL)
- [endoflife.date](https://endoflife.date) (API: mssqlserver, postgresql, mysql)

---

## Microsoft SQL Server

### Wersje główne

| Wersja | Numer wewnętrzny | Data wydania | Koniec wsparcia | Uwagi |
| --- | --- | --- | --- | --- |
| SQL Server 1.0 | 1.0 | 1989 | - | OS/2, 16-bit, wspólnie z Sybase i Ashton-Tate |
| SQL Server 4.2 | 4.2 | 1992 | - | w pakiecie z OS/2 1.3 |
| SQL Server 4.21 | 4.21 | 1993 | - | pierwsza wersja dla Windows NT 3.1 |
| SQL Server 6.0 | 6.0 | 1995-06-13 (SP3) | 1999-03-31 | pierwsza wersja zaprojektowana dla NT |
| SQL Server 6.5 | 6.50 | 1996* | 2002-01-01 | ostatni SP5a: 1998-12-24 |
| SQL Server 7.0 | 7.00.623 | 1998-11* | 2011-01-11 | przepisany silnik (C++), strony 8 KB |
| SQL Server 2000 | 8.00.194 | 2000-08* | 2013-04-09 | |
| SQL Server 2005 | 9.00.1399 | 2005-11 | 2016-04-12 | |
| SQL Server 2008 | 10.00.1600.22 | 2008-08-06 | 2019-07-09 | |
| SQL Server 2008 R2 | 10.50.1600.1 | 2010-04-21 (RTM) | 2019-07-09 | build 10.50.1600.1 w tabeli MS: 2010-05-10 |
| SQL Server 2012 | 11.0.2100.60 | 2012-03-06 | 2022-07-12 | |
| SQL Server 2014 | 12.0.2000.8 | 2014-04-01 (RTM: 2014-03-18) | 2024-07-09 | ESU do 2027-07-12 |
| SQL Server 2016 | 13.0.1601.5 | 2016-06-01 | 2026-07-14 (SP3) | ostatnia wersja z Service Packami |
| SQL Server 2017 | 14.0.1000.169 | 2017-09-29 (premiera: 2017-10-02) | 2027-10-12 | pierwsza wersja na Linuksa |
| SQL Server 2019 | 15.0.2000.5 | 2019-11-04 | 2030-01-08 | |
| SQL Server 2022 | 16.0.1000.6 | 2022-11-16 | 2033-01-11 | |
| SQL Server 2025 | 17.0.1000.7 | 2025-11-18 | 2036-01-06 | aktualna wersja główna |

\* Daty spoza źródeł pobranych w tej sesji (wiedza własna), do weryfikacji.

### Service Packi

| Wersja | SP1 | SP2 | SP3 | SP4 |
| --- | --- | --- | --- | --- |
| 2000 | - | - | - | 2005-05-06 |
| 2005 | 2006-04-18 | 2007-02-19 | 2008-12-15 | 2010-12-16 |
| 2008 | 2009-04-07 | 2010-09-29 | 2011-10-06 | 2014-09-30 |
| 2008 R2 | 2011-07-12 | 2012-07-26 | 2014-09-26 | - |
| 2012 | 2012-11-07 | 2014-06-10 | 2015-11-20 | 2017-10-04 |
| 2014 | 2015-05-04 | 2016-07-11 | 2018-10-30 | - |
| 2016 | 2016-11-15 | 2018-04-24 | 2021-09-15 | - |

### Najnowsze buildy (2026-11-17)

| Wersja | Build | Data |
| --- | --- | --- |
| SQL Server 2025 | 17.0.5065.9 (CU11) | 2026-11-12 |
| SQL Server 2022 | 16.0.4325.4 (CU28) | 2026-11-12 |
| SQL Server 2019 | 15.0.4510.2 (CU32 + GDR) | 2026-11-10 |
| SQL Server 2017 | 14.0.3570.2 (CU31 + GDR) | 2026-11-10 |
| SQL Server 2016 SP3 | 13.0.7095.1 (Azure Connect + GDR) | 2026-07-14 |

---

## PostgreSQL

### Okres przed nazwą PostgreSQL

| Wersja | Data |
| --- | --- |
| POSTGRES 1 | 1989-06 |
| POSTGRES 2 | 1990-06 |
| POSTGRES 3 | 1991 |
| POSTGRES 4.2 | 1994-06-30 |
| Postgres95 0.01 (beta) | 1995-05-05 |
| Postgres95 1.0 | 1995-09-05 |

### Wersje główne

| Wersja | Data wydania | Koniec wsparcia | Ostatnia wersja pomocnicza |
| --- | --- | --- | --- |
| 19 | RC2: 2026-11-12 (jeszcze niewydana) | - | - |
| 18 | 2025-09-25 | 2030-11-14 | 18.7 |
| 17 | 2024-09-26 | 2029-11-08 | 17.12 |
| 16 | 2023-09-14 | 2028-11-09 | 16.16 |
| 15 | 2022-10-13 | 2027-11-11 | 15.20 |
| 14 | 2021-09-30 | 2026-11-12 | 14.25 |
| 13 | 2020-09-24 | 2025-11-13 | 13.23 |
| 12 | 2019-10-03 | 2024-11-21 | 12.22 |
| 11 | 2018-10-18 | 2023-11-09 | 11.22 |
| 10 | 2017-10-05 | 2022-11-10 | 10.23 |
| 9.6 | 2016-09-29 | 2021-11-11 | 9.6.24 |
| 9.5 | 2016-01-07 | 2021-02-11 | 9.5.25 |
| 9.4 | 2014-12-18 | 2020-02-13 | 9.4.26 |
| 9.3 | 2013-09-09 | 2018-11-08 | 9.3.25 |
| 9.2 | 2012-09-10 | 2017-11-09 | 9.2.24 |
| 9.1 | 2011-09-12 | 2016-10-27 | 9.1.24 |
| 9.0 | 2010-09-20 | 2015-10-08 | 9.0.23 |
| 8.4 | 2009-07-01 | 2014-07-24 | 8.4.22 |
| 8.3 | 2008-02-04 | 2013-02-07 | 8.3.23 |
| 8.2 | 2006-12-05 | 2011-12-05 | 8.2.23 |
| 8.1 | 2005-11-08 | 2010-11-08 | 8.1.23 |
| 8.0 | 2005-01-19 | 2010-10-01 | 8.0.26 |
| 7.4 | 2003-11-17 | 2010-10-01 | 7.4.30 |
| 7.3 | 2002-11-27 | 2007-11-27 | 7.3.21 |
| 7.2 | 2002-02-04 | 2007-02-04 | 7.2.8 |
| 7.1 | 2001-04-13 | 2006-04-13 | 7.1.3 |
| 7.0 | 2000-05-08 | 2005-05-08 | 7.0.3 |
| 6.5 | 1999-06-09 | 2004-06-09 | 6.5.3 |
| 6.4 | 1998-10-30 | 2003-10-30 | 6.4.2 |
| 6.3 | 1998-03-01 | 2003-03-01 | 6.3.2 |
| 6.2 | 1997-10-02 | - | 6.2.1 |
| 6.1 | 1997-06-08 | - | 6.1.1 |
| 6.0 | 1997-01-29 | - | 6.0 |

Numeracja: do 9.6 wersja główna to dwa człony (np. 9.6), od 10 jeden (np. 18).

---

## MySQL

### Wersje główne

| Wersja | Data wydania | Koniec wsparcia | Typ | Ostatnia wersja pomocnicza |
| --- | --- | --- | --- | --- |
| 26.10 | 2026-09-18 | - | Innovation | 26.10.0 |
| 26.7 | 2026-07-28 | 2026-10-20 | Innovation | 26.7.1 |
| 9.7 | 2026-04-21 | 2034-04-30 | LTS | 9.7.4 |
| 9.6 | 2026-01-20 | 2026-04-21 | Innovation | 9.6.1 |
| 9.5 | 2025-10-10 | 2026-01-20 | Innovation | 9.5.2 |
| 9.4 | 2025-07-22 | 2025-10-21 | Innovation | 9.4.2 |
| 9.3 | 2025-04-15 | 2025-07-22 | Innovation | 9.3.2 |
| 9.2 | 2025-01-21 | 2025-04-15 | Innovation | 9.2.2 |
| 9.1 | 2024-10-15 | 2025-01-21 | Innovation | 9.1.2 |
| 9.0 | 2024-07-01 (GA 9.0.1: 2024-07-23) | 2024-10-15 | Innovation | 9.0.1 |
| 8.4 | 2024-04-30 | 2032-04-30 | LTS | 8.4.13 |
| 8.3 | 2024-01-16 | 2024-04-30 | Innovation | 8.3.0 |
| 8.2 | 2023-10-25 | 2024-01-16 | Innovation | 8.2.0 |
| 8.1 | 2023-07-18 | 2023-10-25 | Innovation | 8.1.0 |
| 8.0 | 2018-04-19 | 2026-04-30 | GA | 8.0.46 |
| 5.7 | 2015-10-09 | 2023-10-31 | GA | 5.7.44 |
| 5.6 | 2013-02-01 | 2021-02-28 | GA | 5.6.51 |
| 5.5 | 2010-12-03 | 2018-12-31 | GA | 5.5.63 |
| 5.1 | 2008-11-27 | 2013-12-31 | GA | 5.1.73 |
| 5.0 | 2005-10-24 | 2011-12-31 | GA | 5.0.96 |
| 4.1 | 2004-10-23 | 2009-12-31 | GA | 4.1.24 |
| 4.0 | 2003-03-15 | 2008-09-30 | GA | 4.0.30 |
| 3.23 | 2001-01-22 | 2006-12-31 | GA | 3.23.58 |

Uwagi:
- Wersje 6.x nie wydano (prace wstrzymano po przejęciu przez Sun); MySQL Cluster używa 7.x, następną główną wersją było 8.
- Od lipca 2026 (wersja 26.7) MySQL używa wersjonowania kalendarzowego RR.M.
- Daty 5.1 (2008-11-27), 3.23 (2001-01-22), 9.5 (2025-10-10) i 26.10 (2026-09-18) pochodzą z Wikipedii / notatek wydania. endoflife.date podaje odpowiednio 2008-12-08, 2001-01-17, 2025-10-21 i 2026-10-20.

### Wcześniejsze etapy

| Wydarzenie | Data |
| --- | --- |
| Pierwsze wydanie wewnętrzne | 1995-05-23 |
| 3.19 | koniec 1996 |
| 3.20 | 1997-01 |
| 3.21 | 1998 |
