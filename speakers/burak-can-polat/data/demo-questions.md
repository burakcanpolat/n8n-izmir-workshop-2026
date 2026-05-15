# Demo Question Bank — Chinook Text-to-SQL Workshop

12 curated natural-language questions, ranked trivial → ambitious, with
reference SQL. Use these to sanity-check the agent's output during prep
and as a Q&A backup if the room goes quiet.

**Verified against:** Chinook v1.4.5 SQLite (loaded into Cloudflare D1)

---

## ⭐ Wow question (use this around 26:00 in the 30-min plan)

**Q12. What is the month-over-month revenue growth rate for the entire catalog?**

```sql
WITH monthly AS (
  SELECT strftime('%Y-%m', InvoiceDate) AS mo, SUM(Total) AS rev
  FROM Invoice
  GROUP BY mo
),
lagged AS (
  SELECT mo, rev, LAG(rev) OVER (ORDER BY mo) AS prev
  FROM monthly
)
SELECT mo, ROUND(100.0 * (rev - prev) / prev, 1) AS MoM_Pct
FROM lagged
WHERE prev IS NOT NULL
ORDER BY mo;
```

**Why this lands:** CTE chain + LAG window function. The agent constructs
three logical hops in <3 sec; a human in Excel takes 15 min.

---

## 🪤 Trap questions (use during 22:00–26:00 to demo the test-step retry)

**T1. Revenue per artist**

Trap: agent might JOIN Artist → Album → Track and sum `Track.UnitPrice` (list
price), ignoring that the realized transaction price is `InvoiceLine.UnitPrice`.
Wrong numbers, no error thrown. The test step exposes the row pattern that
catches it.

```sql
-- CORRECT
SELECT ar.Name AS Artist, ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS Revenue
FROM InvoiceLine il
JOIN Track t   ON il.TrackId  = t.TrackId
JOIN Album al  ON t.AlbumId   = al.AlbumId
JOIN Artist ar ON al.ArtistId = ar.ArtistId
GROUP BY ar.ArtistId
ORDER BY Revenue DESC
LIMIT 10;
```

**T2. "Most active customers this year"**

Trap: agent filters on `Customer` with a date predicate, but `Customer` has
no date column. Or filters `InvoiceDate > '2026-01-01'` against a static
dataset whose latest year is 2013 — silent zero-result.

```sql
-- CORRECT (the agent should ask: "this year means 2013, right?")
SELECT c.FirstName || ' ' || c.LastName AS Customer, COUNT(*) AS Orders
FROM Invoice i
JOIN Customer c ON i.CustomerId = c.CustomerId
WHERE strftime('%Y', i.InvoiceDate) = '2013'
GROUP BY c.CustomerId
ORDER BY Orders DESC
LIMIT 10;
```

---

## Full question bank

| # | Difficulty | Question | Reference SQL | Demonstrates |
|---|---|---|---|---|
| 1 | Trivial | Müşterilerimiz hangi ülkelerden geliyor? | `SELECT DISTINCT BillingCountry FROM Invoice ORDER BY 1;` | Table access warmup |
| 2 | Easy | En çok satan ilk 5 müzik türü? | `SELECT g.Name, COUNT(*) Sold FROM InvoiceLine il JOIN Track t ON il.TrackId=t.TrackId JOIN Genre g ON t.GenreId=g.GenreId GROUP BY g.Name ORDER BY Sold DESC LIMIT 5;` | 3-table JOIN + aggregation |
| 3 | Easy | Harcamaya göre ilk 10 müşterimiz kim? | `SELECT c.FirstName\|\|' '\|\|c.LastName Customer, SUM(i.Total) Revenue FROM Customer c JOIN Invoice i ON c.CustomerId=i.CustomerId GROUP BY c.CustomerId ORDER BY Revenue DESC LIMIT 10;` | Classic customer-value cut |
| 4 | Easy | Yıllara göre toplam ciro? | `SELECT strftime('%Y',InvoiceDate) Year, ROUND(SUM(Total),2) Revenue FROM Invoice GROUP BY Year ORDER BY Year;` | strftime + grouping |
| 5 | Medium | Hangi destek temsilcisi en çok geliri sağlıyor? | `SELECT e.FirstName\|\|' '\|\|e.LastName Rep, ROUND(SUM(i.Total),2) Revenue FROM Employee e JOIN Customer c ON c.SupportRepId=e.EmployeeId JOIN Invoice i ON i.CustomerId=c.CustomerId GROUP BY e.EmployeeId ORDER BY Revenue DESC;` | 3-table JOIN through bridge |
| 6 | Medium | En az 5 faturası olan ülkeler için ortalama sipariş tutarı? | `SELECT BillingCountry, ROUND(AVG(Total),2) AOV, COUNT(*) Invoices FROM Invoice GROUP BY BillingCountry HAVING COUNT(*)>=5 ORDER BY AOV DESC;` | HAVING clause |
| 7 | Medium | $10'dan fazla gelir getiren albümler? | `SELECT al.Title, ar.Name Artist, ROUND(SUM(il.UnitPrice*il.Quantity),2) Revenue FROM InvoiceLine il JOIN Track t ON il.TrackId=t.TrackId JOIN Album al ON t.AlbumId=al.AlbumId JOIN Artist ar ON al.ArtistId=ar.ArtistId GROUP BY al.AlbumId HAVING Revenue>10 ORDER BY Revenue DESC;` | 4-table JOIN |
| 8 | Medium | 2011 aylık ciro (sıfır aylar dahil) | `WITH months(m) AS (SELECT '2011-01' UNION SELECT '2011-02' UNION SELECT '2011-03' UNION SELECT '2011-04' UNION SELECT '2011-05' UNION SELECT '2011-06' UNION SELECT '2011-07' UNION SELECT '2011-08' UNION SELECT '2011-09' UNION SELECT '2011-10' UNION SELECT '2011-11' UNION SELECT '2011-12') SELECT m.m, COALESCE(ROUND(SUM(i.Total),2),0) Revenue FROM months m LEFT JOIN Invoice i ON strftime('%Y-%m',i.InvoiceDate)=m.m GROUP BY m.m;` | LEFT JOIN + zero-fill |
| 9 | Hard | Çalışanları gelir bazında RANK() ile sırala | `SELECT e.FirstName\|\|' '\|\|e.LastName, ROUND(SUM(i.Total),2) Rev, RANK() OVER (ORDER BY SUM(i.Total) DESC) Rnk FROM Employee e JOIN Customer c ON c.SupportRepId=e.EmployeeId JOIN Invoice i ON i.CustomerId=c.CustomerId GROUP BY e.EmployeeId;` | RANK window function |
| 10 | Hard | Hiç satılmamış parçalar? | `SELECT t.Name, al.Title FROM Track t JOIN Album al ON t.AlbumId=al.AlbumId WHERE t.TrackId NOT IN (SELECT DISTINCT TrackId FROM InvoiceLine);` | Anti-join pattern |
| 11 | Hard | Her türün toplam cirodaki yüzdesi? | `SELECT g.Name, ROUND(100.0*SUM(il.UnitPrice*il.Quantity)/(SELECT SUM(UnitPrice*Quantity) FROM InvoiceLine),2) PctRevenue FROM InvoiceLine il JOIN Track t ON il.TrackId=t.TrackId JOIN Genre g ON t.GenreId=g.GenreId GROUP BY g.Name ORDER BY PctRevenue DESC;` | Correlated share-of-total |
| ⭐12 | Ambitious | Aylık ciro büyüme oranı (MoM)? | (see top of file) | LAG window function + CTE chain |
