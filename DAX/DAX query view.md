## užklausos lentalių duomenų parodymui
```dax
EVALUATE
CALCULATETABLE(
    SUMMARIZE(
        Fact_BiudzetasPKI,
        Fact_BiudzetasPKI[KlientoNr],
        Dim_Klientai[pirmoPirkimoData]
    ),
    Dim_DATE[PirmaSavaitesDiena] = DATE(2026, 06, 29)
)
```
```dax
EVALUATE
CALCULATETABLE(
    ADDCOLUMNS(
        DISTINCT(Fact_BiudzetasPKI[KlientoNr]),
        "Pirmo Pirkimo Data", CALCULATE(SELECTEDVALUE(Dim_Klientai[pirmoPirkimoData]))
    ),
    Dim_DATE[PirmaSavaitesDiena] = DATE(2026, 06, 29)
)
```
