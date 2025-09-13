USING Progress.Json.ObjectModel.*.
{ abl/da/OrderDA.p }
{ abl/da/InventoryDA.p }
{ abl/da/ProductDA.p }
{ abl/util/ErrorUtil.p }

PROCEDURE CreateOrderFromJson:
  DEFINE INPUT  PARAMETER pReqJson AS LONGCHAR NO-UNDO.
  DEFINE OUTPUT PARAMETER pResJson AS LONGCHAR NO-UNDO.

  DEFINE VARIABLE oReq   AS JsonObject NO-UNDO.
  DEFINE VARIABLE oLines AS JsonArray  NO-UNDO.
  DEFINE VARIABLE i      AS INTEGER    NO-UNDO.
  DEFINE VARIABLE vOrderId AS INTEGER  NO-UNDO.
  DEFINE VARIABLE vCustId  AS INTEGER  NO-UNDO.

  oReq = CAST( JsonParser:Parse(pReqJson), JsonObject ).
  vCustId = oReq:GetInteger("custId").

  DO TRANSACTION ON ERROR UNDO, THROW:
    RUN CreateOrder (INPUT vCustId, INPUT TODAY, OUTPUT vOrderId).
    oLines = oReq:GetJsonArray("lines").
    DO i = 1 TO oLines:Length:
      DEFINE VARIABLE oL  AS JsonObject NO-UNDO.
      DEFINE VARIABLE pId AS INTEGER    NO-UNDO.
      DEFINE VARIABLE q   AS DECIMAL    NO-UNDO.
      DEFINE VARIABLE up  AS DECIMAL    NO-UNDO.
      oL  = oLines:GetJsonObject(i).
      pId = oL:GetInteger("prodId").
      q   = DECIMAL(oL:GetString("qty")).
      up  = DECIMAL(oL:GetString("unitPrice")).
      RUN ReserveStock (INPUT pId, INPUT q).
      RUN AddOrderLine (INPUT vOrderId, INPUT pId, INPUT q, INPUT up).
    END.
  END.

  pResJson = SUBSTITUTE('{"orderId":&, "status":"OPEN"}', vOrderId).
END PROCEDURE.
