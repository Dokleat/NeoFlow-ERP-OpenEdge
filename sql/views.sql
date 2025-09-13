CREATE VIEW v_order_summary AS
SELECT o.OrderId,
       o.OrderNo,
       c.Name      AS CustomerName,
       o.DocDate,
       o.Status,
       SUM(ol.Net) AS TotalNet
FROM "Order" o
JOIN Customer c ON c.CustId = o.CustId
LEFT JOIN OrderLine ol ON ol.OrderId = o.OrderId
GROUP BY o.OrderId, o.OrderNo, c.Name, o.DocDate, o.Status;
