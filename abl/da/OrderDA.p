ROUTINE-LEVEL ON ERROR UNDO, THROW.

FUNCTION NextOrderId RETURNS INTEGER ():
  DEFINE VARIABLE v AS INTEGER NO-UNDO INITIAL 1.
  FOR EACH "Order" NO-LOCK BY "Order".OrderId DESCENDING:
    v = "Order".OrderId + 1.
    LEAVE.
  END.
  RETURN v.
END FUNCTION.

PROCEDURE CreateOrder:
  DEFINE INPUT  PARAMETER pCustId AS INTEGER  NO-UNDO.
  DEFINE INPUT  PARAMETER pDocDate AS DATE    NO-UNDO.
  DEFINE OUTPUT PARAMETER pOrderId AS INTEGER NO-UNDO.

  DO TRANSACTION ON ERROR UNDO, THROW:
    CREATE "Order".
    ASSIGN "Order".OrderId = NextOrderId()
           "Order".OrderNo = SUBSTITUTE("O-&", STRING("Order".OrderId, "999999"))
           "Order".CustId  = pCustId
           "Order".DocDate = pDocDate
           "Order".Status  = "OPEN"
           "Order".TotalNet= 0.
    pOrderId = "Order".OrderId.
  END.
END PROCEDURE.

PROCEDURE AddOrderLine:
  DEFINE INPUT PARAMETER pOrderId  AS INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER pProdId   AS INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER pQty      AS DECIMAL NO-UNDO.
  DEFINE INPUT PARAMETER pUnitPrice AS DECIMAL NO-UNDO.

  DEFINE VARIABLE vLine AS INTEGER NO-UNDO.

  DO TRANSACTION ON ERROR UNDO, THROW:
    FIND "Order" EXCLUSIVE-LOCK WHERE "Order".OrderId = pOrderId NO-ERROR.
    IF NOT AVAILABLE "Order" THEN RETURN ERROR "Order not found".

    vLine = 1.
    FOR EACH OrderLine OF "Order" NO-LOCK BY OrderLine.LineNo DESCENDING:
      vLine = OrderLine.LineNo + 1.
      LEAVE.
    END.

    CREATE OrderLine.
    ASSIGN OrderLine.OrderId = pOrderId
           OrderLine.LineNo  = vLine
           OrderLine.ProdId  = pProdId
           OrderLine.Qty     = pQty
           OrderLine.UnitPrice = pUnitPrice
           OrderLine.Net     = pQty * pUnitPrice.

    ASSIGN "Order".TotalNet = "Order".TotalNet + OrderLine.Net.
  END.
END PROCEDURE.
