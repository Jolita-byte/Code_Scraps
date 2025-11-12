Suranda šaltinio lentelę iš POWER BI M QUERY:
```excel
=MID(E5;SEARCH("entity=";E5)+8;SEARCH(",version=";E5)-SEARCH("entity=";E5)-9)
```
