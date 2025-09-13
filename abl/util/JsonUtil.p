USING Progress.Json.ObjectModel.*.

PROCEDURE WriteTTToJson:
  /* Writes a temp-table buffer to JSON array */
  DEFINE INPUT  PARAMETER phBuffer AS HANDLE   NO-UNDO.
  DEFINE OUTPUT PARAMETER pJson    AS LONGCHAR NO-UNDO.
  DEFINE VARIABLE oArr AS JsonArray NO-UNDO.
  DEFINE VARIABLE oObj AS JsonObject NO-UNDO.
  DEFINE VARIABLE hFld AS HANDLE NO-UNDO.
  DEFINE VARIABLE i    AS INTEGER NO-UNDO.
  oArr = NEW JsonArray().
  phBuffer:FOR EACH BUFFER:
    oObj = NEW JsonObject().
    DO i = 1 TO phBuffer:NUM-FIELDS:
      hFld = phBuffer:BUFFER-FIELD(i).
      oObj:Add(hFld:NAME, hFld:BUFFER-VALUE).
    END.
    oArr:Add(oObj).
  END.
  oArr:Write(pJson).
END PROCEDURE.
