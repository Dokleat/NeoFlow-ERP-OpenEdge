-- Beispiel-Queries für CSV-Export (via bcp)
SELECT ProdId, Sku, Name, Unit, Price, Active, CreatedAt FROM dbo.Product;
SELECT CustId, [No], Name, Address, City, Country, Email FROM dbo.Customer;
SELECT ProdId, OnHand, Reserved, Location FROM dbo.Inventory;
SELECT OrderId, OrderNo, CustId, DocDate, Status, TotalNet FROM dbo.[Order];
SELECT OrderId, LineNo, ProdId, Qty, UnitPrice, Net FROM dbo.OrderLine;
-- bcp Beispiel (Host): 
-- bcp "SELECT ProdId, Sku, Name, Unit, Price, Active, CreatedAt FROM dbo.Product" queryout products.csv -c -t, -S localhost,1433 -U sa -P ***** 
