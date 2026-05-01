

# 1

Prompt: pateik klausimų sąrašą, į kuriuos atsakymus galima būtų pateikti power bi ataskaitoje? noriu kaip įmanoma kokybiškiau bei įdomiau vizualizuoti pardavimų fakto atitikimą planui. Turiu pardavimų, pelno, svorio bei maržos sumas bei pardavimų duomenis.

Jei tikslas – **aukšto lygio, įdomi ir vertę kurianti ataskaita apie fakto vs plano vykdymą**, klausimai turi vesti ne tik į *“ar pasiekėm planą?”*, bet į *“kodėl / kur / kas lemia rezultatą?”*.

Žemiau – struktūruotas klausimų rinkinys, kurį gali tiesiogiai „išversti“ į Power BI vizualus.

---

# 🧭 1. Strateginiai (board-level) klausimai

Tai pirmas ekranas – 5 sekundžių suvokimas.

* Ar bendras pardavimų planas įvykdytas?
* Kiek % atsiliekame / viršijame planą?
* Ar pelno planas vykdomas taip pat gerai kaip pardavimų?
* Ar augimas yra pelningas (marža ↑ ar ↓)?
* Ar tendencija rodo, kad mėnesio/ketvirčio planas bus pasiektas?

👉 Vizualai:

* KPI + target
* Bullet chart
* Trend vs target

---

# 🔍 2. Kur yra problema / sėkmė?

Čia prasideda analizė.

* Kurie padaliniai labiausiai viršija planą?
* Kurie padaliniai labiausiai atsilieka?
* Kiek top 3 padaliniai prisideda prie bendro rezultato?
* Ar keli geri padaliniai „užtempia“ visą rezultatą?

👉 Vizualai:

* Variance waterfall
* Top / Bottom bar chart
* Contribution %

---

# ⚖️ 3. Pardavimai vs pelnas vs marža

Dažniausiai čia atsiranda įdomiausios įžvalgos.

* Ar didžiausi pardavimai generuoja ir didžiausią pelną?
* Kur turime didelę apyvartą, bet mažą maržą?
* Ar planas pasiektas per nuolaidas (maržos kritimas)?
* Kur pelno planas nepasiektas, nors pardavimai – taip?

👉 Vizualai:

* Scatter (Sales vs Margin)
* Combo chart (Sales + Margin)
* Matrix su conditional formatting

---

# 📦 4. Produkto / SKU dinamika

Jei turi SKU skaičių – čia aukso vertės įžvalgos.

* Ar planas pasiektas per didesnį SKU kiekį ar per efektyvumą?
* Ar daugiau SKU → didesni pardavimai?
* Ar mažiau SKU → didesnė marža?

👉 Vizualai:

* Scatter (SKU vs Sales vs Margin)
* Trend SKU vs Revenue

---

# ⚙️ 5. Operaciniai klausimai

Padeda suprasti *mechaniką*.

* Ar planas vykdomas per daugiau transakcijų ar didesnį krepšelį?
* Kaip keičiasi vidutinė transakcijos suma vs planas?
* Ar klientų aktyvumas atitinka planą?

👉 Vizualai:

* Avg transaction vs target
* Transactions vs sales (scatter)

---

# 📉 6. Trendai ir prognozė

Vienas svarbiausių blokų board’ui.

* Ar einame link plano įvykdymo?
* Kuriose savaitėse/mėnesiuose atsirado atsilikimas?
* Ar tempas pakankamas pasiekti tikslą?

👉 Vizualai:

* Line: Actual vs Target
* Forecast (Power BI analytics)

---

# 🧨 7. Variance analizė (kodėl)

Tai jau „advanced“, bet labai stipru.

* Kiek plano neįvykdymo sudaro:

  * mažesnis kiekis (volume)
  * mažesnė kaina / marža
* Ar kritimą lemia apimtis ar pelningumas?

👉 Čia gali daryti:

* Decomposition tree
* Waterfall (Volume vs Margin effect)

---

# 🎯 8. Fokusas į veiksmus

Board’ui svarbiausia – ką daryti.

* Kur reikia įsikišti dabar?
* Kur galime greitai pagerinti rezultatą?
* Kur verta investuoti (aukšta marža + augimas)?

👉 Vizualai:

* Scatter su kvadrantais:

  * High Sales / High Margin → invest
  * High Sales / Low Margin → optimize
  * Low Sales / High Margin → scale
  * Low / Low → review

---

# 🧠 9. „Smart insight“ klausimai (labai rekomenduoju)

Šitie padaro reportą „wow“.

* Kiek % pardavimų sudaro padaliniai, viršijantys planą?
* Kiek prarandame dėl blogiausių 3 padalinių?
* Koks vienas veiksnys labiausiai paveikė rezultatą?

👉 Realizuojama per DAX tekstinius insight’us

---

# 🧱 Kaip tai sudėti į vieną ataskaitą

### 🟩 1 puslapis (Executive)

* KPI (Actual vs Target)
* Bullet chart (by department)
* Trend vs Target
* Variance waterfall

---

### 🟨 2 puslapis (Analysis)

* Sales vs Margin scatter
* Top / Bottom
* Matrix (heatmap)

---

### 🟦 3 puslapis (Drivers)

* SKU / Transactions analizė
* Decomposition tree
* Variance breakdown

---

# ⚠️ Kritinė pastaba

Didžiausia klaida:

> rodyti tik „faktas vs planas“

Tai yra **ataskaita be vertės**.

Tu turi atsakyti:

* *kodėl*
* *kur*
* *ką daryti*

---

# 🚀 Jei nori aukštesnio lygio

Galiu tau padėti:

* sukurti **konkrečius DAX (variance decomposition: price vs volume)**
* arba padaryti **pilną dashboard logiką pagal tavo duomenų modelį**
* arba sukurti **storytelling flow (ką sakyti board’ui)**

Parašyk, kokio lygio nori – techninio ar prezentacinio.
