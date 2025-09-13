# NeoFlow ERP – OpenEdge (ABL + PASOE + SQL‑92)

Ein leichtgewichtiges **Demo‑ERP** auf Basis von **Progress OpenEdge 12.x** zur Demonstration praxisnaher Kompetenzen im **OpenEdge‑/proALPHA‑Ökosystem** (Datenbank, ABL/4GL, PAS for OpenEdge REST, SQL‑92 Reporting). Das Projekt spiegelt typische ERP‑Domänen (Stammdaten, Auftrag, Lager) wider und ist als **Proof of Capability** für Rollen wie *ERP Developer (OpenEdge/proALPHA)* konzipiert.

[![Status](https://img.shields.io/badge/status-demo-lightgrey)](#)
[![Stack](https://img.shields.io/badge/stack-OpenEdge%2012.x%20%7C%20ABL%20%7C%20PASOE%20%7C%20SQL--92-blue)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](./LICENSE)

---

## Features auf einen Blick
- **Domänen**: `Product`, `Customer`, `Order`/`OrderLine`, `Inventory`
- **REST‑API mit PASOE**: 
  - `GET /api/health` (Healthcheck)  
  - `GET /api/products` (Produktliste)  
  - `POST /api/orders` (Auftragserfassung inkl. Reservierung)
- **Transaktionen & Validierungen** in ABL (ACID, Sperren, Fehlerbehandlung)
- **SQL‑92 Views** für Reporting (z. B. `v_order_summary`)
- **Seed‑Daten** & **CSV‑Importe** (Migration aus SQL Server/Docker)
- **Saubere Schichtenarchitektur** (DA/BE/BL), klare PROPATH‑Struktur, Skripte für Windows

---

## Architektur & Code‑Organisation
```
NeoFlow_ERP_OpenEdge/
├─ db/                        # Schema (.df), Seed
├─ abl/
│  ├─ util/                   # Utilities (Error/JSON/Tx)
│  ├─ da/                     # Data Access (CRUD, Queries)
│  ├─ be/                     # Business Entities (Temp-Tables, Mapping)
│  └─ bl/                     # Business Logic (REST-Fassaden)
├─ pasoe/
│  ├─ rest-catalog/           # REST-Katalog (oerest-app.json)
│  └─ conf/                   # Basis-Konfiguration (Auszug)
├─ sql/                       # SQL-92 Views/Beispiele
├─ client-demo/js/            # Minimales Frontend (optional)
├─ migration/                 # SQL Server → CSV → OpenEdge Import
├─ tools/                     # Postman-Collection
└─ scripts/                   # Windows-Skripte (Setup/Test)
```

**Schichtenprinzip**  
- **DA** (*Data Access*): direkte DB‑Operationen (FIND/FOR EACH, CREATE/UPDATE)  
- **BE** (*Business Entities*): Domänen‑TTs/DS, Mapping JSON↔TT  
- **BL** (*Business Logic*): Anwendungsfälle (z. B. Auftrag anlegen, Lager reservieren) und REST‑Prozeduren

---

## Systemvoraussetzungen
- **Windows** (empfohlen): OpenEdge 12.2+ inkl. PASOE & PDSOE  
  *(macOS: bitte Windows‑ oder Linux‑VM nutzen)*
- **Java 11+** (für PASOE Runtime)
- **Portfreigaben** für DB/PASOE (z. B. 12345 / 8810)

---

## Installation (Windows, Schritt für Schritt)

> Öffnen Sie die **Proenv** (OpenEdge‑Eingabeaufforderung) und passen Sie Pfade an.

1) **Projekt entpacken**  
   ```bat
   set BASE=C:\neo\NeoFlow_ERP_OpenEdge
   cd %BASE%\db
   ```

2) **Datenbank anlegen & Schema laden**  
   ```bat
   prodb neoflow empty
   proutil neoflow -C load schema df %BASE%\db\schema.df
   ```

3) **Datenbank starten & Seed einspielen**  
   ```bat
   proserve neoflow -S 12345 -H localhost
   mpro -b -p %BASE%\db\seed.p -db neoflow -H localhost -S 12345
   ```

4) **PASOE‑Instanz erstellen & starten**  
   ```bat
   tcman create -p 8810 oepas1
   tcman start oepas1
   ```

5) **ABL WebApp deployen (PDSOE empfohlen)**  
   - Neues **ABL WebApp Project** anlegen (Name: `neoflow`, Target: `oepas1`)  
   - **PROPATH**: `%BASE%\abl` hinzufügen  
   - **DB‑Verbindung**: `-db neoflow -H localhost -S 12345`  
   - **REST‑Katalog importieren**: `%BASE%\pasoe\rest-catalog\oerest-app.json`  
   - Projekt auf `oepas1` **publizieren**

**Basis‑URL** (typisch):  
```
http://localhost:8810/neoflow/
```

---

## REST‑API (Überblick)

### Health
```
GET /api/health
→ { "ok": true, "service": "NeoFlow PASOE" }
```

### Produkte
```
GET /api/products
→ JSON‑Array von Produkten (ProdId, Sku, Name, Price, Active, …)
```

### Auftrag anlegen
```
POST /api/orders
Content-Type: application/json

{
  "custId": 1,
  "lines": [
    {"prodId": 1, "qty": "2", "unitPrice": "4.50"},
    {"prodId": 2, "qty": "1", "unitPrice": "49.90"}
  ]
}
→ { "orderId": <Int>, "status": "OPEN" }
```

Eine vollständige **Postman‑Collection** finden Sie unter `tools/postman_collection.json`.

---

## Lizenz
MIT – siehe [LICENSE](./LICENSE).
