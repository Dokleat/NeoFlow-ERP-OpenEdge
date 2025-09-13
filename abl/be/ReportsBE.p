USING Progress.Json.ObjectModel.*.

/* OrderSummaryJson: builds aggregated order summary (equivalent to SQL view) */
PROCEDURE OrderSummaryJson:
  DEFINE INPUT  PARAMETER pFrom   AS DATE      NO-UNDO.
  DEFINE INPUT  PARAMETER pTo     AS DATE      NO-UNDO.
  DEFINE INPUT  PARAMETER pStatus AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER pJson   AS LONGCHAR  NO-UNDO.

  DEFINE VARIABLE oArr AS JsonArray  NO-UNDO.
  DEFINE VARIABLE oObj AS JsonObject NO-UNDO.

  oArr = NEW JsonArray().

  FOR EACH "Order" NO-LOCK
       WHERE (pFrom = ? OR "Order".DocDate >= pFrom)
         AND (pTo   = ? OR "Order".DocDate <= pTo)
         AND (pStatus = "" OR "Order".Status = pStatus)
       BY "Order".DocDate DESCENDING:

    /* aggregate sum of lines */
    DEFINE VARIABLE dTotal AS DECIMAL NO-UNDO INITIAL 0.
    FOR EACH OrderLine NO-LOCK WHERE OrderLine.OrderId = "Order".OrderId:
      dTotal = dTotal + OrderLine.Net.
    END.

    FIND Customer NO-LOCK WHERE Customer.CustId = "Order".CustId NO-ERROR.

    oObj = NEW JsonObject().
    oObj:Add("OrderId", "Order".OrderId).
    oObj:Add("OrderNo", "Order".OrderNo).
    oObj:Add("CustomerName", (IF AVAILABLE Customer THEN Customer.Name ELSE "" ) ).
    oObj:Add("DocDate", STRING("Order".DocDate, "9999-99-99")).
    oObj:Add("Status", "Order".Status).
    oObj:Add("TotalNet", dTotal).

    oArr:Add(oObj).
  END.

  oArr:Write(pJson).
END PROCEDURE.
