SELECT * FROM Product;
SELECT * FROM v_order_summary ORDER BY DocDate DESC;
--------------------
# Revenue & orders – monthly trend + YoY/perc
WITH lines AS (
  SELECT ol."OrderId",
         ol."Net" AS line_net
  FROM "OrderLine" ol
),
orders AS (
  SELECT o."OrderId",
         o."DocDate",
         SUM(l.line_net) AS order_net
  FROM "Order" o
  JOIN lines l ON l."OrderId" = o."OrderId"
  GROUP BY o."OrderId", o."DocDate"
),
by_month AS (
  SELECT DATE_TRUNC('month', o."DocDate") AS month,
         COUNT(*)                        AS orders_cnt,
         SUM(o.order_net)                AS revenue
  FROM orders o
  GROUP BY DATE_TRUNC('month', o."DocDate")
)
SELECT bm.*,
       LAG(revenue) OVER (ORDER BY month)                       AS prev_month_rev,
       CASE WHEN LAG(revenue) OVER (ORDER BY month) IS NULL THEN NULL
            WHEN LAG(revenue) OVER (ORDER BY month) = 0 THEN NULL
            ELSE (revenue - LAG(revenue) OVER (ORDER BY month))
                 / NULLIF(LAG(revenue) OVER (ORDER BY month),0) * 100 END AS mom_growth_pct,
       LAG(revenue,12) OVER (ORDER BY month)                    AS last_year_rev,
       CASE WHEN LAG(revenue,12) OVER (ORDER BY month) IS NULL THEN NULL
            WHEN LAG(revenue,12) OVER (ORDER BY month) = 0 THEN NULL
            ELSE (revenue - LAG(revenue,12) OVER (ORDER BY month))
                 / NULLIF(LAG(revenue,12) OVER (ORDER BY month),0) * 100 END AS yoy_growth_pct
FROM by_month bm
ORDER BY month;

------------------
#Price deviation (discounts) vs list (Product."Price")
SELECT ol."OrderId",
       ol."LineNo",
       p."Sku",
       p."Name",
       p."Price"              AS list_price,
       ol."UnitPrice"         AS sold_price,
       (p."Price" - ol."UnitPrice")            AS abs_discount,
       CASE WHEN p."Price" = 0 THEN NULL
            ELSE (p."Price" - ol."UnitPrice") / p."Price" * 100 END AS discount_pct,
       ol."Qty",
       ol."Net"
FROM "OrderLine" ol
JOIN "Product" p ON p."ProdId" = ol."ProdId"
WHERE ol."UnitPrice" < p."Price"       -- rreshta me ulje
ORDER BY discount_pct DESC NULLS LAST;

-----------------

#Top customers & simple LTV (net total, average order value, frequency)

WITH orders_net AS (
  SELECT o."OrderId", o."CustId", o."DocDate",
         SUM(ol."Net") AS order_net
  FROM "Order" o
  JOIN "OrderLine" ol ON ol."OrderId" = o."OrderId"
  GROUP BY o."OrderId", o."CustId", o."DocDate"
),
by_customer AS (
  SELECT c."CustId",
         c."No",
         c."Name",
         COUNT(*)                  AS orders_cnt,
         SUM(order_net)            AS revenue,
         AVG(order_net)            AS avg_order_value,
         MIN("DocDate")            AS first_order,
         MAX("DocDate")            AS last_order
  FROM orders_net onet
  JOIN "Customer" c ON c."CustId" = onet."CustId"
  GROUP BY c."CustId", c."No", c."Name"
)
SELECT *,
       revenue / NULLIF(orders_cnt,0) AS aov_again,
       DATE_PART('day', AGE(last_order, first_order)) + 1 AS lifespan_days
FROM by_customer
ORDER BY revenue DESC
FETCH FIRST 50 ROWS ONLY;

----------------------------

# ABC analysis of products (Pareto 80/15/5 according to turnover)

WITH prod_sales AS (
  SELECT p."ProdId", p."Sku", p."Name",
         SUM(ol."Net") AS revenue
  FROM "Product" p
  LEFT JOIN "OrderLine" ol ON ol."ProdId" = p."ProdId"
  GROUP BY p."ProdId", p."Sku", p."Name"
),
ranked AS (
  SELECT *,
         SUM(revenue) OVER ()                                  AS total_rev,
         RANK() OVER (ORDER BY revenue DESC)                   AS rnk,
         SUM(revenue) OVER (ORDER BY revenue DESC
                            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_rev
  FROM prod_sales
)
SELECT "Sku","Name",revenue,
       cum_rev,
       total_rev,
       CASE
         WHEN total_rev = 0 THEN 'C'
         WHEN cum_rev / total_rev <= 0.80 THEN 'A'
         WHEN cum_rev / total_rev <= 0.95 THEN 'B'
         ELSE 'C'
       END AS abc_class
FROM ranked
ORDER BY revenue DESC;

---------------------

#Stock rotation & days of coverage (based on 90-day sales)

WITH last_90 AS (
  SELECT ol."ProdId",
         SUM(ol."Qty") AS qty_sold_90
  FROM "Order" o
  JOIN "OrderLine" ol ON ol."OrderId" = o."OrderId"
  WHERE o."DocDate" >= CURRENT_DATE - INTERVAL '90 day'
  GROUP BY ol."ProdId"
),
joined AS (
  SELECT p."ProdId", p."Sku", p."Name",
         i."OnHand", i."Reserved",
         COALESCE(l90.qty_sold_90,0) AS qty_sold_90
  FROM "Product" p
  LEFT JOIN "Inventory" i ON i."ProdId" = p."ProdId"
  LEFT JOIN last_90 l90   ON l90."ProdId" = p."ProdId"
)
SELECT *,
       GREATEST("OnHand" - COALESCE("Reserved",0), 0)                       AS free_stock,
       CASE WHEN qty_sold_90 = 0 THEN NULL
            ELSE (GREATEST("OnHand" - COALESCE("Reserved",0),0)) / (qty_sold_90/90.0) END AS days_of_cover,
       CASE WHEN qty_sold_90 = 0 THEN 0
            ELSE (qty_sold_90/90.0) END AS avg_daily_demand
FROM joined
ORDER BY days_of_cover NULLS FIRST, avg_daily_demand DESC;

-----------------
# Backorder risk (active orders > free stock)

WITH open_orders AS (
  SELECT ol."ProdId",
         SUM(ol."Qty") AS qty_on_orders
  FROM "Order" o
  JOIN "OrderLine" ol ON ol."OrderId" = o."OrderId"
  WHERE o."Status" IN ('Open','Released','Confirmed')   -- përshtate me statuset reale
  GROUP BY ol."ProdId"
),
stock AS (
  SELECT i."ProdId",
         GREATEST(i."OnHand" - COALESCE(i."Reserved",0),0) AS free_stock
  FROM "Inventory" i
)
SELECT p."Sku", p."Name",
       COALESCE(s.free_stock,0) AS free_stock,
       COALESCE(oo.qty_on_orders,0) AS qty_on_orders,
       COALESCE(oo.qty_on_orders,0) - COALESCE(s.free_stock,0) AS shortfall
FROM "Product" p
LEFT JOIN stock s     ON s."ProdId" = p."ProdId"
LEFT JOIN open_orders oo ON oo."ProdId" = p."ProdId"
WHERE COALESCE(oo.qty_on_orders,0) > COALESCE(s.free_stock,0)
ORDER BY shortfall DESC;


