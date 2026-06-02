




# Prompt: kokie klausimai gali būti atasakomi power BI ataskaitų pagalba, kurie būtų susijė su naujais klientais ar prekėmis? kaip tai reiktų išpildyti?


Čia atsiranda viena vertingiausių Power BI sričių — **augimo analizė**.
Nauji klientai ir naujos prekės leidžia atsakyti ne tik *„kiek pardavėm?“*, bet:

* iš kur ateina augimas,
* ar augimas tvarus,
* ar kuriame naują vertę,
* ar tiesiog „perstumdom“ esamus pardavimus.

Tai jau labai stiprus board-level analytics.

---

# 🧭 1. Klausimai apie naujus klientus

## 🔷 Acquisition / Growth

* Kiek turime naujų klientų?
* Kiek % pardavimų generuoja nauji klientai?
* Ar naujų klientų skaičius auga?
* Kurie padaliniai pritraukia daugiausiai naujų klientų?
* Ar nauji klientai pelningi?

👉 Insight:

> „Augimas ateina iš naujų klientų ar iš esamų?“

---

## 🔷 Retention / Quality

* Kiek naujų klientų grįžta antram pirkimui?
* Po kiek laiko klientas grįžta?
* Ar nauji klientai turi mažesnį / didesnį krepšelį?
* Ar naujų klientų marža skiriasi nuo esamų?

👉 Insight:

> „Ar mes tik pritraukiam, ar išlaikom?“

---

## 🔷 Customer mix

* Ar nauji klientai keičia pardavimų struktūrą?
* Kokias kategorijas renkasi nauji klientai?
* Ar nauji klientai perka daugiau SKU?

---

# 🧱 Kaip techniškai išpildyti „naują klientą“

## 1. Surasti pirmą pirkimą

```DAX id="g2p8vk"
First Purchase Date =
CALCULATE(
    MIN(Sales[Date]),
    ALLEXCEPT(Sales, Sales[CustomerID])
)
```

---

## 2. Nustatyti ar klientas naujas

```DAX id="v9x4bn"
New Customer =
IF(
    Sales[Date] = [First Purchase Date],
    1,
    0
)
```

---

## 3. Naujų klientų skaičius

```DAX id="h6q1tr"
New Customers =
CALCULATE(
    DISTINCTCOUNT(Sales[CustomerID]),
    FILTER(Sales, [New Customer] = 1)
)
```

---

# 📊 Kaip vizualizuoti

## Geriausi vizualai:

### 🟩 KPI

* New Customers
* % Revenue from New Customers

---

### 📈 Trend

* New customers by month

👉 klausimas:

> „Ar augame per naujus klientus?“

---

### ⚖️ Scatter

* X = Revenue
* Y = Margin
* Size = New customers

👉 rodo:

* kurie padaliniai generuoja kokybišką augimą

---

### 🔥 Cohort / retention heatmap

* mėnuo vs grįžimo %

👉 labai stipru board’ui

---

# 🧭 2. Klausimai apie naujas prekes (SKU)

Čia labai daug potencialo.

---

## 🔷 Growth drivers

* Kiek pardavimų generuoja naujos prekės?
* Ar naujos prekės prisideda prie augimo?
* Kurios naujos prekės sėkmingiausios?

👉 Insight:

> „Ar inovacijos realiai kuria vertę?“

---

## 🔷 Portfolio efficiency

* Ar naujos prekės kanibalizuoja senas?
* Ar daugiau SKU → daugiau pelno?
* Ar naujos prekės turi geresnę maržą?

👉 Insight:

> „Ar plečiam portfelį efektyviai?“

---

## 🔷 Product lifecycle

* Kaip greitai naujos prekės pasiekia piką?
* Kada pradeda kristi?
* Kiek laiko užtrunka tapti pelningomis?

---

# 🧱 Kaip nustatyti naują prekę

## 1. Pirmas pardavimo momentas

```DAX id="d4m7qy"
First SKU Sale =
CALCULATE(
    MIN(Sales[Date]),
    ALLEXCEPT(Sales, Sales[SKU])
)
```

---

## 2. Nauja prekė

```DAX id="t8n2wc"
New SKU =
IF(
    Sales[Date] = [First SKU Sale],
    1,
    0
)
```

---

# 📊 Vizualai naujoms prekėms

## 🟩 KPI

* Revenue from new SKUs
* Profit from new SKUs

---

## 📈 Trend

* New SKU contribution over time

---

## 🧨 Waterfall

* kiek augimo atėjo iš:

  * naujų SKU
  * esamų SKU

---

## ⚖️ Scatter

* X = Sales
* Y = Margin
* Bubble size = SKU age

👉 labai stiprus insight

---

# 🧠 Galingiausi klausimai (board-level)

Šitie daro wow efektą:

---

## Apie klientus

* Ar augimas ateina iš naujų ar esamų klientų?
* Ar nauji klientai tampa lojaliais?
* Kiek pelno generuoja nauji klientai?

---

## Apie prekes

* Ar naujos prekės generuoja papildomą augimą?
* Ar naujų SKU daugėjimas didina ar mažina maržą?
* Kiek portfelio sudaro neefektyvūs SKU?

---

# 🎯 Storytelling logika

## 1.

> „Augimas ateina iš naujų klientų / neateina“

## 2.

> „Naujų klientų kokybė yra aukšta / žema“

## 3.

> „Naujos prekės generuoja / negeneruoja papildomą pelną“

## 4.

> „Portfelio plėtra yra efektyvi / neefektyvi“

---

# 🚀 Jei nori next level

Galiu tau:

* sukurti **customer cohort analizę**
* padaryti **new vs existing customer dashboard**
* sukurti **SKU lifecycle analizę**
* arba parašyti DAX:

  * retention,
  * churn,
  * repeat purchase,
  * cannibalization

Tai jau būtų labai stiprus analytics lygis.






------------------------------------------------------------------------------


# Prompt: naujų prekių acceleration. kaip atvaizduoti?
„Naujų prekių pagreitis“ (angl. *New Product Acceleration*) yra puikus analitinis rodiklis, rodantis, **kaip greitai naujai įvestos prekės pasiekia savo pardavimo piką** arba kaip jų pardavimų augimo tempas skiriasi nuo ankstesnių metų/mėnesių naujų prekių bangų.

Kadangi jūsų modelyje jau sukurta protinga laiko intelekto funkcija (`MeasureRef`), atvaizduoti šį pagreitį Power BI galima keliais labai vizualiais ir verslui vertingais būdais.

Štai 3 geriausios praktikos, kaip tai apskaičiuoti ir pateikti vizualuose:

---

### 1. Kohortų analizė (Mėnesiai po starto) – *Geriausias būdas grafike*

Užuot žiūrėjus į kalendorines datas (sausį, vasarį), prekių pardavimai suvedami į **„Mėnesius nuo pirmo pirkimo“** (Mėnuo 0, Mėnuo 1, Mėnuo 2 ir t. t.).

Tai leidžia palyginti, pavyzdžiui, *2025 m. startavusias prekes* su *2026 m. startavusiomis prekėmis* ir pamatyti, kurios grupės kreivė kyla stačiau (tai ir yra pagreitis).

* **Kaip atvaizduoti:** **Line Chart (Linijinė diagrama)**.
* **X ašis:** Virtualus stulpelis `Mėnesiai po starto` (skaičiuojamas kaip skirtumas tarp pardavimo fakto datos ir `Dim_Prekes[PirmoPardavimoData]`).
* **Y ašis:** `[_Pardavimu Faktai]` (tik naujoms prekėms).
* **Legenda (Legend):** Prekių įvedimo metai (pvz., `2025 naujienos`, `2026 naujienos`).


* **Ką matysite:** Jei 2026 m. linija antrąjį mėnesį yra aukščiau nei 2025 m. linija, vadinasi, jūsų naujų prekių akceleracija yra sėkminga.

---

### 2. Kaupiamasis (Cumulative / YTD) naujų prekių augimas

Šis rodiklis parodo, kaip greitai naujos prekės „krauna“ bendrą įmonės apyvartą. Jei kreivė tampa statesnė, tai indikuoja pagreitį.

* **Kaip atvaizduoti:** **Area Chart (Plonų linijų / plotų diagrama)**.
* **DAX logika:** Sukuriamas kaupiamasis matas, kuris naudoja jūsų anksčiau paruoštą naujų prekių logiką:

```dax
Naujų Prekių Kumuliatyvas = 
CALCULATE(
    [_Pardavimu Faktai, nauju prekiu pilna suma], -- Matas, kurį sukūrėme pokalbio pradžioje
    WINDOW(1, ABS, 0, REL, ORDERBY(Dim_DATE[Data]))
)

```

---

### 3. Skaitmeninis „Acceleration“ matas (Pokyčio pokytis)

Fizikoje pagreitis yra greičio pokytis. Versle naujų prekių pagreitį galime išreikšti matu, kuris palygina **šio mėnesio naujų prekių pardavimų augimą su praėjusio mėnesio naujų prekių augimu**.

Jei praėjusį mėnesį naujos prekės augo +10%, o šį mėnesį auga +25%, pagreitis yra teigiamas (+15%).

* **Kaip atvaizduoti:** **KPI kortelė (KPI Card)** puslapio viršuje arba **Gauge (Spidometro)** vizualas.
* **DAX konstrukcija (naudojant jūsų naująją funkciją):**

```dax
Naujų Prekių Pagreitis (MoM) = 
VAR _SioMenesioAugimas = MyFunctions.PeriodoPokytis([_Pardavimu Faktai, naujos prekės])
VAR _PraeitoMenesioAugimas = CALCULATE(_SioMenesioAugimas, DATEADD(Dim_DATE[Data], -1, MONTH))

RETURN
    _SioMenesioAugimas - _PraeitoMenesioAugimas

```

---

### 💡 Rekomendacija jūsų ataskaitos puslapiui:

Sukurkite atskirą skirtuką **„Naujų produktų sėkmė“**, kur:

1. Viršuje įdedate **KPI kortelę** su `Naujų Prekių Pagreitis (MoM)`.
2. Centre – **Line Chart**, kur lygiagrečiai paleidžiate šių metų naujų prekių gyvavimo kreivę prieš praėjusių metų (Kohortų analizė).
3. Apačioje – jūsų turimą matricą su dinaminiu `_Pardavimu Faktai, periodo pokytis %` rodikliu, kad vartotojas matytų tikslius skaičius.

-----------------------------------------------------------------------------
--------------------------------------------------------------------------------

# Prompt: o pagreitį rodyti vienu skaičiu ar laike? 
Idealu yra rodyti **abu variantus kartu**, nes jie atlieka visiškai skirtingas funkcijas: **vienas skaičius** yra skirtas vadovams greitam situacijos įvertinimui (KPI), o **vaizdas laike** – analitikams, kad suprastų, *kodėl* tas skaičius yra būtent toks.

Štai kaip teisingai juos išskirstyti ir suderinti viename puslapyje:

---

### 1. Vienas skaičius (KPI kortelė) – *Greitam statusui*

Vienas skaičius puslapio viršuje veikia kaip „ataskaitos šviesoforas“. Jis iškart pasako, ar jūsų naujų prekių įvedimo strategija šiuo metu greitėja, ar lėtėja.

* **Ką rodyti:** Einamojo mėnesio pagreitį (pavyzdžiui, šio mėnesio naujų prekių augimo greitis minus praėjusio mėnesio greitis).
* **Vizualas:** **KPI Card** arba **Card with States** (naudokite žalią spalvą, jei skaičius teigiamas, ir raudoną, jei neigiamas).
* **Verslo vertė:** Vadovas užėjęs iškart mato: `+15%`. Tai reiškia, kad naujos prekės rinką užkariauja sparčiau nei praėjusį mėnesį.

---

### 2. Laike (Linijinė diagrama) – *Tendencijoms ir sezoniškumui*

Tik žiūrėdamas laiko ašį, vartotojas gali suprasti, ar tas vienas KPI skaičius yra atsitiktinis šuolis, ar ilgalaikė sėkminga tendencija.

* **Ką rodyti:** Pagreičio matą, išskleistą per mėnesius (X ašis – Metai-Mėnuo).
* **Vizualas:** **Line Chart (Linijinė diagrama)** arba **Bar Chart (Stulpelinė)**.
* **Verslo vertė:** Pamatysite „bangas“. Pavyzdžiui, pastebėsite, kad kiekvienų metų pavasarį naujų prekių akceleracija šauna į viršų (sezoniškumas), o rudenį nukrenta. Tai padeda planuoti rinkodaros biudžetus ateičiai.

---

### 🎯 Tobulas išdėstymas puslapyje (Best Practice)

Geriausia praktika ataskaitose yra **„Nuo bendro prie detalaus“**:

1. **Puslapio viršuje (Kairėje):** Įdėkite didelę KPI kortelę su vienu skaičiumi (pvz., `Naujų prekių pagreitis (Šį mėn.)`).
2. **Puslapio centre (Dešinėje):** Šalia kortelės pastatykite grafiką, kuris rodo tą patį pagreitį laiko ašyje per paskutinius 12 mėnesių.

Taip vartotojas gauna pilną vaizdą: iškart pamato esamą būseną (vieną skaičių) ir akimis sekdamas į dešinę supranta visą kontekstą laike.

----------------------------------------
-------------------------------------

# Prompt: jeigu acceleration rodo 14.76% kaip interpretuoti šį matą?

Kai jūsų naujų prekių pagreičio (*Acceleration*) matas rodo **14.76%**, verslo kalba tai reiškia viena: **naujų prekių pardavimų augimas įgauna pagreitį ir jie plečiasi sparčiau nei anksčiau.**

Šio skaičiaus interpretacija tiesiogiai priklauso nuo to, kaip tiksliai sukonstruotas jūsų matas, tačiau dažniausiai verslo analitikoje jis skaitomas per šias tris prizmes:

---

### 1. Pagrindinė interpretacija (Mėnuo prieš mėnesį)

Jei jūsų matas skaičiuoja šio mėnesio naujų prekių augimo tempą, palyginti su praėjusio mėnesio tempu:

* **Reikšmė:** Šį mėnesį naujų prekių pardavimų augimo greitis yra **14.76 procentinio punkto didesnis** nei buvo praėjusį mėnesį.
* **Pavyzdys:** Jei praėjusį mėnesį naujų prekių pardavimai paaugo $+10\%$, tai šį mėnesį jie šovė į viršų net $+24.76\%$. Tai rodo, kad prekių adaptacija rinkoje stiprėja.

---

### 2. Kohortų interpretacija (Metai prieš metus)

Jei jūsų matas lygina šių metų naujų prekių bangą su praėjusių metų tos pačios stadijos naujomis prekėmis (pvz., abiejų grupių pardavimus 3-ąjį mėnesį po jų starto):

* **Reikšmė:** Šių metų naujos prekės startuoja **14.76% efektyviau/greičiau** nei praėjusių metų naujienos.
* **Išvada:** Jūsų komanda išmoko geriau, taikliau įvesti produktus į rinką, arba rinkodaros kampanija suveikė operatyviau nei pernai.

---

### 3. Kaip tai pristatyti vadovams susirinkimo metu?

> *„Mūsų naujų prekių krepšelis ne tiesiog auga – jis **akseleruoja**. Šiuo metu fiksuojame **14.76% pagreitį**, o tai reiškia, kad pirkėjai naujas prekes atranda ir perka sparčiau, nei tai vyko ankstesniu periodu. Tai indikatorius, kad investicijos į naujų prekių reklamą / pozicionavimą pasiteisina ir atsiperka greitėjančiu tempu.“*

### 📊 Ką daryti, jei skaičius pasikeis?

* **Virš 0% (kaip jūsų 14.76%):** Žalia šviesa. Tempas greitėja. Rinka „virškina“ produktus greičiau.
* **Ties 0%:** Pardavimai auga stabiliu, tokiu pačiu greičiu kaip praėjusį mėnesį. Pagreičio nėra, bet nėra ir stabdymo.
* **Žemiau 0% (Neigiamas):** Raudona vėliava. Naujos prekės vis dar gali generuoti apyvartą, bet jų augimo kreivė pradeda plokštėti (lėtėti). Vadinasi, pradinis susidomėjimo bumas praėjo ir prekių gyvavimo ciklas pasiekė „brandos“ arba stagnacijos stadiją.
-------------------------------------------
---------------------------------------
# Prompt: ką reikia matuoti vertinant greitį? ar parduotų vienetų kiekį, ar apyvartą ar pelną ar naujų prekių kiekį?

Vertinant naujų prekių įvedimo greitį ir pagreitį, **universalaus vieno atsakymo nėra – reikia matuoti kelis rodiklius, tačiau griežtai tam tikra eilės tvarka.** Rodiklio pasirinkimas tiesiogiai priklauso nuo to, kokioje **gyvavimo ciklo stadijoje** yra naujas produktas. Jei pasirinksite netinkamą rodiklį per anksti, galite padaryti klaidingas išvadas.

Štai kaip verslo analitikoje vertinamas kiekvienas iš jūsų įvardintų rodiklių ir kada kurį naudoti:

---

### 1. Parduotų vienetų kiekis (Kiekis / Qty) – *Geriausias pradiniam greičiui (Rinkos penetracijai)*

Tai yra pati gryniausia „greičio“ išraiška pačioje pradžioje. Ji parodo, kaip fiziškai prekė juda iš sandėlio pas klientus, eliminuojant kainų svyravimus ar nuolaidas.

* **Kada matuoti:** Pirmąsias 1–4 savaites po prekės pasirodymo.
* **Kodėl:** Jei naujų prekių vienetų pardavimai auga eksponentiškai (didelis pagreitis), vadinasi, logistika veikia, prekė yra lentynose, o pirkėjai ją pastebi ir ima.
* **Pavojus:** Vienetų kiekis neparodo, ar tas judėjimas įmonei yra pelningas.

### 2. Apyvarta (Eur) – *Geriausias masto ir vertės vertinimui*

Apyvarta sujungia fizinį prekių judėjimą su jų komercine verte.

* **Kada matuoti:** Nuo 2-ojo iki 6-ojo mėnesio.
* **Kodėl:** Tai parodo realią naujų prekių finansinę įtaką įmonei. Vadovams svarbu žinoti ne tik tai, kad pardavėme 10 000 vienetų, bet ir tai, kad tai atnešė 50 000 € apyvartos, kuri tiesiogiai didina įmonės rinkos dalį.
* **Pavojus:** Didelė apyvarta gali būti apgaulinga, jei prekės parduodamos su milžiniškomis nuolaidomis (akcijomis), kurios degina įmonės pinigus.

### 3. Grynoji marža / Pelnas (Eur) – *Svarbiausias brandos stadijoje (Sėkmės matas)*

Galutinis taškas, kuris pasako, ar nauja prekė buvo sėkmingas verslo sprendimas, ar tik „oras, kurį varinėjame“.

* **Kada matuoti:** Praėjus 3–6 mėnesiams po įvedimo.
* **Kodėl:** Pradinėje stadijoje naujas produktas dažnai turi didelių rinkodaros išlaidų, todėl jo pelnas gali būti mažas ar net neigiamas. Tačiau vėliau, kai greitis nusistovi, **pelnas tampa svarbiausiu matu**. Jei apyvartos greitis didelis, bet pelno pagreitis krenta – prekė generuoja nuostolį (pvz., dėl per mažos maržos).

### 4. Naujų prekių kiekis (Asortimento plotis) – *Proceso, o ne pardavimų matas*

Tai rodiklis, rodantis jūsų pirkimų skyriaus ar gamybos aktyvumą (kiek naujų kodų / SKU sukūrėte), bet jis **nieko nepasako apie pardavimų greitį**.

* **Kada naudoti:** Tik vertinant inovacijų tempą (angl. *Time-to-Market*). Jei įvedate 100 naujų prekių, o rinkoje pajuda tik 2, jūsų naujų prekių kiekio rodiklis bus geras, bet pardavimų pagreitis – tragiškas.

---

### 🎯 Rekomenduojama strategija: „Piltuvėlio“ principas

Kad Power BI ataskaita veiktų idealiai, sujunkite šiuos rodiklius į seką. Kadangi savo modelyje jau turite sukurtą dinaminį `Rodiklis` parinkimą per `SWITCH`, vartotojui leiskite juos analizuoti šia tvarka:

1. **Žingsnis (KIEKIS):** Ar rinka priima prekę fiziškai? (Tikriname pirmosiomis savaitėmis).
2. **Žingsnis (APYVARTA):** Ar pasiekiame planuojamą piniginę masę? (Tikriname po mėnesio).
3. **Žingsnis (PELNAS / MARŽA):** Ar šis pasiektas greitis uždirba įmonei pinigus? (Galutinis vertinimas po ketvirčio).

Jei jūsų matytas **14.76%** pagreitis yra fiksuojamas ties **Apyvarta** arba **Pelnas** rodikliais – tai yra puikus kokybinio augimo ženklas. Jei tai tik vienetų kiekis – verta pasitikrinti, ar kainodara nėra per žema.


