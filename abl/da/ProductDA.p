ROUTINE-LEVEL ON ERROR UNDO, THROW.

FUNCTION NextProdId RETURNS INTEGER ():
  DEFINE VARIABLE v AS INTEGER NO-UNDO INITIAL 1.
  FOR EACH Product NO-LOCK BY Product.ProdId DESCENDING:
    v = Product.ProdId + 1.
    LEAVE.
  END.
  RETURN v.
END FUNCTION.

PROCEDURE CreateProduct:
  DEFINE INPUT  PARAMETER pSku   AS CHARACTER NO-UNDO.
  DEFINE INPUT  PARAMETER pName  AS CHARACTER NO-UNDO.
  DEFINE INPUT  PARAMETER pUnit  AS CHARACTER NO-UNDO.
  DEFINE INPUT  PARAMETER pPrice AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER pProdId AS INTEGER  NO-UNDO.

  DO TRANSACTION ON ERROR UNDO, THROW:
    CREATE Product.
    ASSIGN Product.ProdId = NextProdId()
           Product.Sku    = pSku
           Product.Name   = pName
           Product.Unit   = pUnit
           Product.Price  = pPrice
           Product.Active = TRUE
           Product.CreatedAt = NOW.
    pProdId = Product.ProdId.
  END.
END PROCEDURE.

PROCEDURE FindById:
  DEFINE INPUT  PARAMETER pProdId AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER pFound  AS LOGICAL   NO-UNDO.
  FIND FIRST Product NO-LOCK WHERE Product.ProdId = pProdId NO-ERROR.
  pFound = AVAILABLE Product.
END PROCEDURE.

PROCEDURE ListAll:
  DEFINE TEMP-TABLE ttProduct NO-UNDO
    FIELD ProdId AS INTEGER FIELD Sku AS CHARACTER FIELD Name AS CHARACTER
    FIELD Price AS DECIMAL FIELD Active AS LOGICAL INDEX pk IS PRIMARY ProdId.

  FOR EACH Product NO-LOCK:
    CREATE ttProduct.
    ASSIGN ttProduct.ProdId = Product.ProdId
           ttProduct.Sku    = Product.Sku
           ttProduct.Name   = Product.Name
           ttProduct.Price  = Product.Price
           ttProduct.Active = Product.Active.
  END.

  DEFINE OUTPUT PARAMETER TABLE FOR ttProduct.
END PROCEDURE.
