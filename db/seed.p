/* Seed demo data */
CREATE Customer. ASSIGN CustId=1 No="C0001" Name="Alpha GmbH" Address="Musterstr. 1" City="Hamburg" Country="DE" Email="sales@alpha.de".
CREATE Customer. ASSIGN CustId=2 No="C0002" Name="Beta AG"   Address="Allee 2"      City="Berlin"  Country="DE" Email="info@beta.de".

CREATE Product. ASSIGN ProdId=1 Sku="SKU-1001" Name="Paper A4" Unit="PCS" Price=4.50 Active=TRUE CreatedAt=NOW.
CREATE Product. ASSIGN ProdId=2 Sku="SKU-2001" Name="Toner 12A" Unit="PCS" Price=49.90 Active=TRUE CreatedAt=NOW.

CREATE Inventory. ASSIGN ProdId=1 OnHand=500 Reserved=0 Location="MAIN".
CREATE Inventory. ASSIGN ProdId=2 OnHand=100 Reserved=0 Location="MAIN".

MESSAGE "Seed completed" VIEW-AS ALERT-BOX INFO BUTTONS OK.
