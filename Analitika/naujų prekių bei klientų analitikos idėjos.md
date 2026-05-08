




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
