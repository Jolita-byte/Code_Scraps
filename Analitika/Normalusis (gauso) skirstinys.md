
Measure:
```dax
PardavimuVidurkis = 
CALCULATE(
    AVERAGE(Fact_BiudzetasPKI[FaktinePardavimoKaina2]),
    Fact_BiudzetasPKI[Saltinis] = "PKI_Fact",
    Dim_IrasoTipas[IrasoTipoNr] = 1,
    ALLSELECTED(Fact_BiudzetasPKI)
)
```
```dax
PardavimuStandartinisNuokrypis = 
CALCULATE(
    STDEV.S(Fact_BiudzetasPKI[FaktinePardavimoKaina2]),
    ALLSELECTED(Fact_BiudzetasPKI),
    Fact_BiudzetasPKI[Saltinis] = "PKI_Fact",
    Dim_IrasoTipas[IrasoTipoNr] = 1
)
```
```
PardavimuGausoKreive = 
-- Paimame rėžio reikšmę tiesiai iš X ašies konteksto
VAR EsamasRezis = MAX(Fact_BiudzetasPKI[FaktinePardavimoKaina2 (bins)]) 

RETURN
IF(
    NOT(ISBLANK(EsamasRezis)) && [PardavimuStandartinisNuokrypis] > 0,
    NORM.DIST(
        EsamasRezis,
        [PardavimuVidurkis],
        [PardavimuStandartinisNuokrypis],
        FALSE()
    ),
    BLANK()
)
```

# -----------------------------
Analizuojant pagal Gauso (normalųjį) pasiskirstymą, svarbiausia ne pati „graži varpo forma“, o tai, ką ji pasako apie:

* proceso stabilumą,
* variaciją,
* anomalijas,
* prognozuojamumą,
* segmentaciją.

Tavo kainodaros/pardavimų atveju pagrindiniai akcentai būtų šie.

---

# 1. Vidurkis (μ)

Tai centrinis taškas:

\mu = \frac{1}{n}\sum_{i=1}^{n} x_i

Verslo interpretacija:

> aplink kokią kainą natūraliai koncentruojasi pardavimai

Tavo atveju:

* ~8.74 = „tipinė“ pardavimo kaina

Klausimai:

* ar ši kaina pelninga?
* ar ji strategiškai norima?
* ar ji sutampa su didžiausiu conversion?

---

# 2. Standartinis nuokrypis (σ)

Svarbiausias stabilumo indikatorius.

\sigma = \sqrt{\frac{1}{n-1}\sum_{i=1}^{n}(x_i-\mu)^2}

Jis parodo:

* kiek kainos išsimėčiusios
* kiek procesas kontroliuojamas

---

## Mažas σ

Reiškia:

* kainodara nuosekli
* procesas stabilus
* mažai chaoso

Galimai:

* gera pricing governance
* standartizuoti pasiūlymai

---

## Didelis σ

Reiškia:

* kainodara labai skirtinga
* vadybininkai dirba nevienodai
* daug išimčių

Galimai:

* discounting problema
* segmentavimo trūkumas
* skirtingi klientų tipai

---

# 3. 68–95–99.7 taisyklė

Klasikinė Gauso interpretacija.

Jei duomenys normalūs:

* ~68% reikšmių yra:

  ```text id="z9evui"
  μ ± 1σ
  ```

* ~95%:

  ```text id="vkx69w"
  μ ± 2σ
  ```

* ~99.7%:

  ```text id="jdf8ik"
  μ ± 3σ
  ```

---

## Praktinė reikšmė

Jei:

* μ = 8.74
* σ = 2

Tada:

### Normalus diapazonas:

```text id="2j1h0u"
6.74 – 10.74
```

### Retos kainos:

```text id="84z7jv"
< 4.74 arba > 12.74
```

---

# 4. Outlieriai (anomalijos)

Svarbiausia praktinė nauda.

Jei kaina:

* labai toli nuo vidurkio
* už ±2σ arba ±3σ

tai gali reikšti:

* klaidą
* nestandartinį deal'ą
* specialų klientą
* pricing problemą

---

# 5. Simetriškumas

Ideali Gauso kreivė:

* simetriška
* vienodas pasiskirstymas į abi puses

Jei ne:

* atsiranda skewness

---

## Dešininis skew

Tavo grafike jo truputį yra.

Reiškia:

* dauguma kainų normalios
* bet yra dalis labai aukštų kainų

Versle tai dažna:

* premium klientai
* enterprise deals
* išskirtiniai projektai

---

## Kairinis skew

Reikštų:

* daug discount'ų
* agresyvus pigimas
* galimas maržos spaudimas

---

# 6. Multimodalumas

Labai svarbu.

Jei histogramoje:

* keli pikai

tai reiškia:

> egzistuoja skirtingi klientų ar produktų segmentai

Pvz:

* SMB klientai
* Enterprise klientai

Tokiu atveju:

* viena Gauso kreivė tampa netinkama

Reikia:

* segmentuoti
* modeliuoti atskirai

---

# 7. Histogram vs Gaussian mismatch

Čia viena vertingiausių analizių.

Jei:

* realūs stulpeliai stipriai nesutampa su kreive

tai reiškia:

* procesas nėra „natūralus“
* yra business rules
* kainos dirbtinai formuojamos

Pvz:

* daug kainų ties 9.99
* fixed pricing tiers
* discount approval ribos

---

# 8. Prognozuojamumas

Normalus pasiskirstymas leidžia:

* prognozuoti tikėtinus intervalus
* nustatyti control limits
* vertinti riziką

Pvz:

> kokia tikimybė, kad kaina viršys 12?

Tam naudojama:

```DAX id="sffhmp"
NORM.DIST(x, mean, std, TRUE())
```

(TRUE = cumulative)

---

# 9. Ar duomenys apskritai normalūs?

Labai svarbu.

Daug verslo duomenų:

* nėra normalūs
* turi skew
* turi outlierius
* turi sezoniką
* turi segmentus

Todėl Gauso kreivė dažnai:

* ne „tiesa“
* o benchmark/modelis

---

# 10. Svarbiausias praktinis klausimas

Ne:

> „ar kreivė graži?“

O:

> „kodėl realūs duomenys nukrypsta nuo normalumo?“

Ten dažniausiai slypi:

* verslo taisyklės
* klientų elgsena
* pricing strategija
* vadybininkų sprendimai
* proceso problemos
* segmentacija

Ir būtent tai vertingiausia analizėje.




# ------------------------------------
Sukurti Gauso (normaliojo pasiskirstymo) diagramą „Power BI“ aplinkoje galima keliais būdais. Kadangi standartinių vizualizacijų sąraše tokios diagramos nėra, geriausias ir lanksčiausias kelias – panaudoti **DAX formules** ir standartinę **stulpelinę/linijinę diagramą (Clustered Column / Line Chart)**.

Štai žingsnis po žingsnio gidas, kaip tai padaryti naudojant jūsų pardavimų duomenis (pavyzdžiui, užsakymo sumas arba parduotų prekių kiekį).

---

## 1 Žingsnis: Duomenų paruošimas (Grupavimas / Bins)

Gauso kreivei reikalinga horizontali ašis ($X$), kuri vaizduoja reikšmių rėžius (pvz., užsakymų sumos kas 10 €).

1. „Power BI“ duomenų vaizde (Data view) suraskite stulpelį, kurio pasiskirstymą norite matyti (pvz., `PardavimoSuma`).
2. Spustelkite ant jo dešiniuoju pelės klavišu ir pasirinkite **New groups**.
3. Atsidariusiame lange:
* **Group type:** Pasirinkite *Bin*.
* **Bin size:** Įveskite žingsnį, priklausomai nuo jūsų duomenų (pvz., jei pardavimai svyruoja nuo 0 iki 1000 €, įveskite `50` arba `100`).


4. Spustelkite **OK**. Atsiras naujas stulpelis, pavyzdžiui, `PardavimoSuma (bins)`.

---

## 2 Žingsnis: Vidurkio ir Standartinio nuokrypio skaičiavimas (DAX)

Gauso funkcijai apskaičiuoti mums reikės dviejų pagrindinių statistinių rodiklių: vidurkio ($\mu$) ir standartinio nuokrypio ($\sigma$). Sukurkite šiuos matus (Measures):

**1. Pardavimų vidurkis:**

```dax
PardavimuVidurkis = AVERAGE(Pardavimai[PardavimoSuma])

```

**2. Standartinis nuokrypis:**

```dax
StandartinisNuokrypis = STDEV.S(Pardavimai[PardavimoSuma])

```

---

## 3 Žingsnis: Gauso kreivės formulė (DAX)

Dabar sukursime matą, kuris apskaičiuos normaliojo pasiskirstymo tankį kiekvienam rėžiui. Naudosime „Power BI“ integruotą funkciją `NORM.DIST`.

Sukurkite naują matą:

```dax
GausoKreive = 
NORM.DIST(
    SELECTEDVALUE(Pardavimai[PardavimoSuma (bins)]),
    [PardavimuVidurkis],
    [StandartinisNuokrypis],
    FALSE()
)

```

> 💡 **Svarbu:** Parametras `FALSE()` nurodo, kad skaičiuojame tankio funkciją (kreivę), o ne sukauptąją (kumuliacinę) tikimybę.

---

## 4 Žingsnis: Diagramos vizualizavimas

Norint matyti ir realius pardavimų faktus (stulpelius), ir teorinę Gauso kreivę (liniją), naudosime kombinuotą diagramą.

1. Vizualizacijų panele pasirinkite **Line and clustered column chart**.
2. Į **X-axis** įkelkite pirmajame žingsnyje sukurtą grupuotą stulpelį: `PardavimoSuma (bins)`.
3. Į **Column y-axis** įkelkite realų pardavimų skaičių (pvz., unikalių užsakymų kiekį: `COUNT(Pardavimai[UžsakymoID])`).
4. Į **Line y-axis** įkelkite sukurtą matą `[GausoKreive]`.

Štai ir viskas! Diagramoje pamatysite stulpelius, rodančius realų pardavimų pasiskirstymą, ir tolygią liniją, kuri nubrėžia teorinę Gauso varpo formos kreivę pagal jūsų duomenų vidurkį ir nuokrypį.

---

### Alternatyvūs būdai (Jei norite greitesnio rezultato)

Jei DAX formulės atrodo per sudėtingos, Gauso diagramą „Power BI“ galima sukurti ir kitais būdais:

* **R arba Python vizualizacijos:** Jei mokate R arba Python, galite tiesiog įsikelti standartinį vizualą ir panaudoti `ggplot2` (R) arba `seaborn` (Python) bibliotekas, kurios Gauso kreivę nubraižo viena kodo eilute (`geom_density` arba `kdeplot`).
* **Custom Visuals:** „AppSource“ parduotuvėje galite paieškoti paruoštų kreivių vizualizacijų (pvz., *Histogram Chart by MAQ Software*), kurios turi integruotą normaliojo pasiskirstymo linijos funkciją.

# -------------------------------------
# Kaip interpretuoti gauso diagramą? 
Sveikinimai įveikus techninę dalį! Gauso (normaliojo pasiskirstymo) kreivė pardavimuose yra galingas įrankis, leidžiantis suprasti jūsų pirkėjų elgseną, kainodarą ir atrasti anomalijas.

Štai kaip reikėtų „skaityti“ ir interpretuoti gautą vaizdą:

---

## 1. Kur yra jūsų „Centras“? (Vidurkis ir Viršūnė)

Gauso kreivės pati aukščiausia vieta (viršūnė) rodo jūsų **dažniausią/tipinį pardavimą**.

* Jei viršūnė yra ties 50 €, vadinasi, jūsų verslo „duona kasdieninė“ yra 50 € vertės užsakymai.
* **Verslo įžvalga:** Visi rinkodaros veiksmai, akcijos ar puslapio patobulinimai turėtų būti orientuoti į tai, kaip šią viršūnę pastumti į dešinę (padidinti vidutinį krepšelį).

---

## 2. Kreivės plotis (Standartinis nuokrypis)

Kreivės plotis parodo jūsų pardavimų **stabilumą ir nuspėjamumą**.

* **Siaura ir aukšta kreivė:** Jūsų pardavimai yra labai nuspėjami. Dauguma klientų perka už labai panašią sumą (pvz., visi užsakymai sukasi tarp 40 € ir 60 €).
* **Plati ir plokščia kreivė:** Jūsų pardavimai labai skirtingi. Turite ir labai pigių, ir labai brangių užsakymų. Tai rodo didelę klientų segmentų įvairovę.

---

## 3. „68–95–99.7“ taisyklė (Standartinė statistika)

Normalusis pasiskirstymas paklūsta griežtai matematinei taisyklei. Pažiūrėkite į savo apskaičiuotą Vidurkį ir Standartinį nuokrypį:

* **68% visų pardavimų** krenta į rėžį: `Vidurkis +/- 1 Standartinis nuokrypis`. Tai yra jūsų pagrindinis klientų srautas.
* **95% visų pardavimų** krenta į rėžį: `Vidurkis +/- 2 Standartiniai nuokrypiai`. Tai apima beveik visą jūsų standartinę veiklą.

---

## 4. Realybės ir Teorijos palyginimas (Stulpeliai vs. Linija)

Kadangi grafike matote ir realius stulpelius, ir teorinę liniją, ieškokite neatitikimų:

### A. Kreivė pasvirusi į vieną pusę (Asimetrija / Skewness)

Pardavimuose idealiai simetriškas Gauso varpas pasitaiko retai. Dažniausiai kreivė turi „ilgą uodegą“ dešinėje pusėje.

* **Ką tai reiškia:** Jūsų pagrindiniai pardavimai yra nedideli (kreivės viršūnė kairėje), tačiau turite nedidelį kiekį *labai didelių* užsakymų (uodega dešinėje). Tai visiškai normalu elektroninėje prekyboje (B2C).

### B. Dviejų kuprų efektas (Bimodalinis pasiskirstymas)

Jei jūsų realūs stulpeliai suformuoja ne vieną, o **dvi viršūnes** (lyg kupranugario nugarą), o Gauso linija bando tai „apvalinti“ per vidurį:

* **Ką tai reiškia:** Jūs turite du visiškai skirtingus pirkėjų segmentus. Pavyzdžiui, vieni perka tik pigias smulkmenas (pirma viršūnė ties 15 €), o kiti – brangius rinkinius (antra viršūnė ties 150 €). Tokiu atveju bendras „vidurkis“ (pvz., 80 €) yra apgaulingas, nes už tokią sumą beveik niekas neperka.

### C. „Išsišokėliai“ (Anomalijos / Outliers)

Jei dešiniajame grafiko krašte, toli nuo visos kreivės, matote vienišą stulpelį:

* **Ką tai reiškia:** Tai anomalūs užsakymai (pvz., didmeninis pirkimas arba sistemos klaida). Analizuojant įprastą elgseną, tokius duomenis kartais verta filtruoti, kad jie neiškreiptų bendro vidurkio.

Ar jūsų gauta kreivė gavosi simetriška, ar labiau patempta į dešinę pusę su ilga „uodega“?
