
# Prompt: iš ko dar gali ateiti augimas? kaip jį galima papildomai analizuoti?


Labai geras klausimas.
Kai pradedi analizuoti **iš kur ateina augimas**, pereini iš „reporting“ į tikrą **business analytics**.

Dažniausia klaida:

> matyti tik bendrą augimą.

Stipri analizė atsako:

> *kas konkrečiai sukūrė augimą?*
> *ar tas augimas sveikas?*
> *ar jis tvarus?*

---

# 🧭 Pagrindiniai augimo šaltiniai

Augimas dažniausiai ateina iš 7 sričių:

```text id="xw7d2p"
1. Nauji klientai
2. Esami klientai
3. Didesnis krepšelis
4. Daugiau transakcijų
5. Kainos pokytis
6. Naujos prekės / kategorijos
7. Kanalų / regionų pokytis
```

---

# 🟩 1. Augimas iš naujų klientų

## Klausimai

* Kiek augimo sugeneravo nauji klientai?
* Ar jie pelningi?
* Ar jie grįžta?

## Vizualai

* New vs Existing revenue split
* Cohort retention
* Acquisition trend

## Insight

> „Augimas ateina iš rinkos plėtros.“

---

# 🟦 2. Augimas iš esamų klientų

Dažnai tai pats vertingiausias augimas.

## Klausimai

* Ar esami klientai perka daugiau?
* Ar didėja jų krepšelis?
* Ar jie perka dažniau?

## Analizė

### Revenue decomposition:

```text id="7j0c5r"
Growth =
More customers
+
Higher frequency
+
Larger basket
```

---

# 🟨 3. Didesnis vidutinis krepšelis

## Klausimai

* Ar klientai išleidžia daugiau?
* Kuriose kategorijose?
* Ar tai dėl kainų ar kiekių?

## Vizualai

* Avg basket trend
* Basket by customer segment

## Insight

> „Augimas ateina ne iš daugiau klientų, o iš didesnės vertės.“

---

# 🟧 4. Daugiau transakcijų

## Klausimai

* Ar klientai perka dažniau?
* Kuris padalinys didina srautą?
* Ar daugiau transakcijų generuoja pelną?

## Vizualai

* Transactions trend
* Transactions vs margin scatter

---

# 🟥 5. Kainos / maržos augimas

Labai svarbu.

## Klausimai

* Ar augimas ateina iš kainos?
* Ar kainų didinimas mažina kiekį?
* Ar marža gerėja?

## Advanced analizė

### Price vs Volume decomposition

```text id="9vh3zk"
Sales Growth =
Price Effect
+
Volume Effect
```

👉 Viena stipriausių board analizių.

---

# 🟪 6. Naujos prekės / kategorijos

## Klausimai

* Kiek augimo sukuria naujos prekės?
* Ar jos pelningesnės?
* Ar jos kanibalizuoja senas?

## Vizualai

* New SKU contribution
* SKU lifecycle
* Pareto

---

# 🟫 7. Kanalai / regionai / padaliniai

## Klausimai

* Kur geografiškai auga verslas?
* Kuris kanalas generuoja augimą?
* Ar augimas koncentruotas?

## Vizualai

* Map
* Regional heatmap
* Channel trend

---

# 🧠 Advanced augimo analizės

Čia prasideda „wow“ lygis.

---

# 🔥 A. Growth decomposition

Išskaidyk augimą į:

```text id="3tq6pn"
Growth =
New Customers
+
Existing Customer Expansion
+
Price Increase
+
New Products
```

👉 Board’as iškart supranta:

* kas kuria vertę
* ar augimas sveikas

---

# 🔥 B. Price vs Volume analysis

Vienas stipriausių vizualų.

## Klausimai

* Augame dėl kainų ar kiekių?
* Ar kainų didinimas mažina pardavimus?

## Vizualai

* Waterfall
* Variance bridge

---

# 🔥 C. Mix effect analysis

Labai „executive“.

## Klausimas

* Ar augimą keičia produkto/padalinio mix?

Pvz:

* daugiau premium → marža kyla
* daugiau low-margin → marža krenta

---

# 🔥 D. Customer quality analysis

Ne visi klientai vienodi.

## Klausimai

* Ar nauji klientai pelningi?
* Kurie segmentai vertingiausi?
* Kur churn didžiausias?

---

# 🔥 E. Growth sustainability

Board’ui labai svarbu.

## Klausimai

* Ar augimas stabilus?
* Ar priklausom nuo kelių SKU?
* Ar augimas vienkartinis?

---

# 📊 Kaip tai atvaizduoti Power BI

---

# 🟩 Executive page

## Klausimas:

> „Iš kur ateina augimas?“

### Vizualai:

* KPI growth split
* Waterfall
* Forecast

---

# 🟨 Customer page

## Klausimas:

> „Kas vyksta su klientais?“

### Vizualai:

* Cohort
* Retention
* Basket trend

---

# 🟦 Product page

## Klausimas:

> „Kas vyksta su portfeliu?“

### Vizualai:

* Pareto
* SKU lifecycle
* New vs Existing SKU

---

# 🟥 Margin page

## Klausimas:

> „Ar augimas pelningas?“

### Vizualai:

* Scatter
* Price vs volume
* Margin bridge

---

# 🧠 Svarbiausia mintis

Silpna analizė:

> „pardavimai paaugo 10%“

Stipri analizė:

> „Augimą sugeneravo esami klientai ir premium produktų mix, tačiau marža pradeda mažėti dėl akcinių pardavimų.“

---

# 🚀 Jei nori next level

Galiu tau padaryti:

* konkretų **growth decomposition modelį**
* DAX:

  * price effect
  * volume effect
  * mix effect
* arba pilną:

  * customer retention,
  * cohort,
  * churn,
  * basket analytics modelį Power BI.
