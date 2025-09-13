USING Progress.Json.ObjectModel.*.
PROCEDURE Health:
  DEFINE OUTPUT PARAMETER pJson AS LONGCHAR NO-UNDO.
  DEFINE VARIABLE o AS JsonObject NO-UNDO.
  o = NEW JsonObject().
  o:Add("ok", TRUE).
  o:Add("service", "NeoFlow PASOE").
  o:Write(pJson).
END PROCEDURE.
