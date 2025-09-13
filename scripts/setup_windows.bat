@echo off
REM Run this inside OpenEdge "Proenv"
set BASE=C:\neo\NeoFlow_ERP_OpenEdge
if not exist %BASE% mkdir %BASE%
xcopy /E /I /Y "%CD%" "%BASE%"
cd %BASE%\db
prodb neoflow empty
proutil neoflow -C load schema df %BASE%\db\schema.df
proserve neoflow -S 12345 -H localhost
mpro -b -p %BASE%\db\seed.p -db neoflow -H localhost -S 12345
tcman create -p 8810 oepas1
tcman start oepas1
echo Done. Deploy ABL WebApp in PDSOE; import REST catalog: %BASE%\pasoe\rest-catalog\oerest-app.json
