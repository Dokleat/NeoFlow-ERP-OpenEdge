ROUTINE-LEVEL ON ERROR UNDO, THROW.
USING Progress.Json.ObjectModel.*.

PROCEDURE ErrorToJson:
  DEFINE INPUT  PARAMETER pMsg  AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER pJson AS LONGCHAR  NO-UNDO.
  DEFINE VARIABLE o AS JsonObject NO-UNDO.
  o = NEW JsonObject().
  o:Add("error", TRUE).
  o:Add("message", pMsg).
  o:Write(pJson).
END PROCEDURE.
