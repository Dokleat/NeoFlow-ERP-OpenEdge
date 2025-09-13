/* Import CSVs exportiert aus SQL Server (mit Header-Zeilen) */
DEFINE VARIABLE cDir AS CHARACTER NO-UNDO INITIAL "migration/import/csv-samples/".

PROCEDURE SkipHeader:
  DEFINE INPUT PARAMETER pcFile AS CHARACTER NO-UNDO.
  DEFINE VARIABLE lc AS LONGCHAR NO-UNDO.
  INPUT FROM VALUE(pcFile) NO-ECHO.
  IMPORT UNFORMATTED lc. /* Header überspringen */
END PROCEDURE.

FUNCTION ParseISODate RETURNS DATE (INPUT c AS CHARACTER):
  /* Erwartet YYYY-MM-DD */
  IF LENGTH(c) >= 10 THEN
    RETURN DATE(INTEGER(SUBSTRING(c,6,2)), INTEGER(SUBSTRING(c,9,2)), INTEGER(SUBSTRING(c,1,4))).
  RETURN TODAY.
END FUNCTION.

PROCEDURE ImportProducts:
  DEFINE VARIABLE cFile AS CHARACTER NO-UNDO INITIAL cDir + "products.csv".
  DEFINE VARIABLE ProdId    AS INTEGER   NO-UNDO.
  DEFINE VARIABLE Sku       AS CHARACTER NO-UNDO.
  DEFINE VARIABLE Name      AS CHARACTER NO-UNDO.
  DEFINE VARIABLE Unit      AS CHARACTER NO-UNDO.
  DEFINE VARIABLE Price     AS DECIMAL   NO-UNDO.
  DEFINE VARIABLE Active    AS LOGICAL   NO-UNDO.
  DEFINE VARIABLE CreatedAt AS CHARACTER NO-UNDO.
  RUN SkipHeader(cFile).
  REPEAT:
    IMPORT DELIMITER "," ProdId Sku Name Unit Price Active CreatedAt NO-ERROR.
    IF ERROR-STATUS:ERROR THEN LEAVE.
    CREATE Product.
    ASSIGN Product.ProdId = ProdId
           Product.Sku    = Sku
           Product.Name   = Name
           Product.Unit   = Unit
           Product.Price  = Price
           Product.Active = Active
           Product.CreatedAt = NOW.
  END.
  INPUT CLOSE.
END PROCEDURE.

PROCEDURE ImportCustomers:
  DEFINE VARIABLE cFile AS CHARACTER NO-UNDO INITIAL cDir + "customers.csv".
  DEFINE VARIABLE CustId AS INTEGER   NO-UNDO.
  DEFINE VARIABLE No     AS CHARACTER NO-UNDO.
  DEFINE VARIABLE Name   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE Address AS CHARACTER NO-UNDO.
  DEFINE VARIABLE City   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE Country AS CHARACTER NO-UNDO.
  DEFINE VARIABLE Email  AS CHARACTER NO-UNDO.
  RUN SkipHeader(cFile).
  REPEAT:
    IMPORT DELIMITER "," CustId No Name Address City Country Email NO-ERROR.
    IF ERROR-STATUS:ERROR THEN LEAVE.
    CREATE Customer.
    ASSIGN Customer.CustId = CustId
           Customer.No     = No
           Customer.Name   = Name
           Customer.Address= Address
           Customer.City   = City
           Customer.Country= Country
           Customer.Email  = Email.
  END.
  INPUT CLOSE.
END PROCEDURE.

PROCEDURE ImportInventory:
  DEFINE VARIABLE cFile AS CHARACTER NO-UNDO INITIAL cDir + "inventory.csv".
  DEFINE VARIABLE ProdId AS INTEGER NO-UNDO.
  DEFINE VARIABLE OnHand AS DECIMAL NO-UNDO.
  DEFINE VARIABLE Reserved AS DECIMAL NO-UNDO.
  DEFINE VARIABLE Location AS CHARACTER NO-UNDO.
  RUN SkipHeader(cFile).
  REPEAT:
    IMPORT DELIMITER "," ProdId OnHand Reserved Location NO-ERROR.
    IF ERROR-STATUS:ERROR THEN LEAVE.
    CREATE Inventory.
    ASSIGN Inventory.ProdId = ProdId
           Inventory.OnHand = OnHand
           Inventory.Reserved = Reserved
           Inventory.Location = Location.
  END.
  INPUT CLOSE.
END PROCEDURE.

PROCEDURE ImportOrders:
  DEFINE VARIABLE cFile AS CHARACTER NO-UNDO INITIAL cDir + "orders.csv".
  DEFINE VARIABLE OrderId  AS INTEGER   NO-UNDO.
  DEFINE VARIABLE OrderNo  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE CustId   AS INTEGER   NO-UNDO.
  DEFINE VARIABLE DocDate  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE Status   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE TotalNet AS DECIMAL   NO-UNDO.
  RUN SkipHeader(cFile).
  REPEAT:
    IMPORT DELIMITER "," OrderId OrderNo CustId DocDate Status TotalNet NO-ERROR.
    IF ERROR-STATUS:ERROR THEN LEAVE.
    CREATE "Order".
    ASSIGN "Order".OrderId  = OrderId
           "Order".OrderNo  = OrderNo
           "Order".CustId   = CustId
           "Order".DocDate  = ParseISODate(DocDate)
           "Order".Status   = Status
           "Order".TotalNet = TotalNet.
  END.
  INPUT CLOSE.
END PROCEDURE.

PROCEDURE ImportOrderLines:
  DEFINE VARIABLE cFile AS CHARACTER NO-UNDO INITIAL cDir + "orderlines.csv".
  DEFINE VARIABLE OrderId   AS INTEGER NO-UNDO.
  DEFINE VARIABLE LineNo    AS INTEGER NO-UNDO.
  DEFINE VARIABLE ProdId    AS INTEGER NO-UNDO.
  DEFINE VARIABLE Qty       AS DECIMAL NO-UNDO.
  DEFINE VARIABLE UnitPrice AS DECIMAL NO-UNDO.
  DEFINE VARIABLE Net       AS DECIMAL NO-UNDO.
  RUN SkipHeader(cFile).
  REPEAT:
    IMPORT DELIMITER "," OrderId LineNo ProdId Qty UnitPrice Net NO-ERROR.
    IF ERROR-STATUS:ERROR THEN LEAVE.
    CREATE OrderLine.
    ASSIGN OrderLine.OrderId   = OrderId
           OrderLine.LineNo    = LineNo
           OrderLine.ProdId    = ProdId
           OrderLine.Qty       = Qty
           OrderLine.UnitPrice = UnitPrice
           OrderLine.Net       = Net.
  END.
  INPUT CLOSE.
END PROCEDURE.

PROCEDURE ImportAll:
  RUN ImportProducts.
  RUN ImportCustomers.
  RUN ImportInventory.
  RUN ImportOrders.
  RUN ImportOrderLines.
END PROCEDURE.
