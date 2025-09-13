RUN migration/import/ImportCSVToOE.p.

PROCEDURE ImportCsvAll:
  DEFINE OUTPUT PARAMETER pJson AS LONGCHAR NO-UNDO.
  RUN ImportAll.
  ASSIGN pJson = '{"ok":true,"import":"completed"}'.
END PROCEDURE.
