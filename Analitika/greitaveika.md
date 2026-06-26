

## Gerosios praktikos:
### 1. Denormalizacija
Jei tradicinėse SQL duomenų bazėse mus moko duomenis normalizuoti (išmėtyti į kuo smulkesnes lenteles, kad nesidubliuotų tekstai), tai „Power BI“ pasaulyje galioja priešinga taisyklė: kuo mažiau lentelių ir kuo mažiau ryšių tarp jų – tuo greičiau veikia DAX.

**Kodėl denormalizacija pagreitina „VertiPaq“ (Import) variklį?**

Kai duomenys yra importuojami, „Power BI“ juos saugo stulpeliais, o ne eilutėmis. Jei apjungsite kelias smulkias dimensijas į vieną plačią lentelę (pvz., subkategorijas ir kategorijas įkelsite tiesiai į prekių lentelę):
- Žodynų efektyvumas: „Power BI“ tekstus vis tiek sukompresuos per žodynus (Dictionary encoding), todėl modelio dydis failo prasme beveik nepadidės.
- Ryšių eliminavimas: Ataskaitai vizuale nebereikės fone daryti „vaikščiojimo per ryšius“ (angl. Relationship traversal). Kiekvienas ryšys modelyje reikalauja CPU resursų. Jei visi klasifikatoriai yra vienoje lentelėje, Power BI filtrą pritaiko akimirksniu.

Vietoj to, kad turėtumėte 5–7 atskiras dimensijų lenteles, jas reikėtų denormalizuoti į dvi stambias dimensijas: Apjunkite visas su prekėmis susijusias lenteles į vieną bendrą: Dim_Prekes + Dim_Hierarchija (HSaka2, HSaka3 ir t.t.) + Dim_Brendas + Dim_BrendoPriklausomybe.

**Kada denormalizacija gali pakenkti? (Aukso viduriukas)**

Nors denormalizacija yra nuostabus dalykas, faktų lentelės (Fact_BiudzetasPKI) denormalizuoti (t. y. įkelti prekių pavadinimų ar klientų vardų tiesiai į pardavimų eilutes) nereikėtų.
Jei į milijoninę faktų lentelę įkelsite unikalius tekstus, faktų lentelė išsipūs, užims daug RAM ir sulėtins atnaujinimo laiką. Išlaikykite Žvaigždės schemą: faktų lentelėje lieka tik skaičiai ir ID raitai, o visi tekstiniai klasifikatoriai sugula į kelias stambias, denormalizuotas dimensijų lenteles.

### 2. Text ID > Numeric

„Power BI“ atminties variklis (VertiPaq) duomenis saugo stulpeliais ir naudoja du pagrindinius optimizavimo metodus: Value encoding (reikšmių kodavimą, taikomą skaičiams) ir Dictionary encoding (žodynų kodavimą, taikomą tekstams).

**Žymiai mažesnis modelio dydis (Atminties sutaupymas)**

Kai stulpelis yra tekstinio tipo, „Power BI“ fone privalo sukurti žodyną (angl. Dictionary), kuriame saugoma kiekviena unikali tekstinė reikšmė, ir tik tada pagrindinėje lentelėje įrašo nuorodas į tą žodyną.

- Tekstas (String): Jei turite 1 milijoną unikalių ID eilučių, pvz., "10002145", sistema saugo patį tekstą kaip simbolių seką žodyne + rodykles. Žodyno indeksavimas dideliems tekstams reikalauja labai daug RAM.
- Skaičius (Whole Number): Pavertus į skaičių 10002145, „Power BI“ dažniausiai pritaiko Value encoding. Sistema tiesiog matematiškai suspaudžia skaičių seką nenaudodama jokio papildomo žodyno atmintyje.

Reali nauda: Vien tik pakeitus didelio kardinalumo (unikalių reikšmių) stulpelį iš Text į Integer, to stulpelio užimama vieta modelyje dažnai sumažėja nuo 2 iki 5 kartų.

**Žaibiški ryšiai tarp lentelių (Relationships)**

Jei šį ID stulpelį naudojate kaip raktą ryšiui tarp dimensijos ir faktų lentelės (pavyzdžiui, jungiate Dim_Klientai ir Fact_Pardavimai per KlientoID):

Ryšiai per tekstinius stulpelius fone verčia „Power BI“ lyginti simbolių sekas (angl. String comparison). Tai reikalauja daug CPU resursų.

Ryšiai per skaičius yra apdorojami aparatinėje įrangoje (angl. Hardware level bitwise comparison). Skaičių palyginimas kompiuteriui yra pati natūraliausia ir greičiausia operacija.

Reali nauda: Ataskaitos vizualai (pvz., jūsų Sunburst ar matricos), kuriems reikia pereiti per ryšius iš dimensijos į faktus, persiskaičiuos 30–50% greičiau, ypač DirectQuery režime, nes SQL serveris JOIN veiksmus su skaičiais atlieka nepalyginamai sparčiau nei su tekstu.


### 3. Žvaigždės schema (Star Schema) – Šventasis Raštas
„Power BI“ variklis (VertiPaq) yra optimizuotas išskirtinai Žvaigždės schemai. Venkite „Snaigės“ schemų (angl. Snowflake Schema), kur dimensijos filtruoja kitas dimensijas (pvz., Faktai $\rightarrow$ Prekės $\rightarrow$ Subkategorijos $\rightarrow$ Kategorijos).Kodėl tai svarbu dideliems kiekiams: Kiekvienas papildomas ryšys (ryšių grandinė) DirectQuery režime verčia SQL serverį daryti sunkius JOIN veiksmus. Apjunkite susijusias dimensijas į vieną plačią lentelę dar duomenų bazės / ETL lygmenyje.Vienpusis filtravimas: Ryšiai tarp dimensijų ir faktų lentelių visada turėtų būti Single (Vienpusis), iš dimensijos į faktus ($1 \rightarrow *$). Dvipusis filtravimas (Bi-directional cross-filtering) ant didelių lentelių gali visiškai paralyžiuoti ataskaitos veikimą.

### 4. Agregacijos (Aggregations) – Didžiausias DirectQuery išsigelbėjimas
Jei faktų lentelė turi dešimtis ar šimtus milijonų eilučių, nenaudokite gryno DirectQuery visiems vizualams.
Sukurkite Agregacijų lenteles.Duomenų bazėje paruoškite suvestinę lentelę (pvz., pardavimai sugrupuoti pagal Datą, Padalinį ir Prekės ženklą). 
Ši lentelė užims minimaliai vietos ir ją galima importuoti (Import mode).„Power BI“ aplinkoje sukonfigūruokite Manage Aggregations. 
Kai vartotojas žiūrės bendrus įmonės rodiklius, Power BI duomenis ims akimirksniu iš Importuotos agreguotos lentelės.
Tik tada, kai vartotojas „pasigilins“ iki konkretaus artikulo ar čekio, Power BI fone fone tyliai paleis DirectQuery užklausą į didžiąją duomenų bazę.

### 5. Duomenų tipų optimizavimas (VertiPaq kompresija)
Jei dalis duomenų yra importuojama, VertiPaq variklis duomenis suspaudžia stulpeliais, vertindamas jų kardinalumą (unikalių reikšmių skaičių stulpelyje).
Atsisakykite laiko dalių datų stulpeliuose: Stulpelis su 2026-06-26 08:35:43 turi milžinišką kardinalumą. 
Atskirkite datą į Date tipo stulpelį, o laiką (jei jis būtinas) – į atskirą stulpelį (arba suapvalinkite iki valandų/pusvalandžių).
ID stulpelių naikinimas: Faktų lentelėje esantys unikalūs eilučių ID (pvz., transakcijos GUID) užima daugiausiai atminties, nes kiekviena eilutė yra unikali. 
Jei šio ID nereikia verslo logikai ar ryšiams – ištrinkite jį.Skaičių kableliai: Jei valiutos ar svoriai turi 4 ar daugiau skaičių po kablelio, suapvalinkite juos iki 2 skaičių po kablelio arba pakeiskite tipą į Fixed Decimal Number.


### 6. DAX Gerosios praktikos dideliems duomenims
Netinkamai parašytas DAX matas DirectQuery aplinkoje gali priversti ataskaitą „suktis“ dešimtis sekundžių.
Naudokite DIVIDE vietoj /: DIVIDE funkcija yra optimizuota fone automatiškai tikrinti dalybą iš nulio ir veikia saugiau.
Venkite FILTER(Tabelė, ...): Naudojant CALCULATE(..., FILTER(Lentelė, Lentelė[Stulpelis] = "X")), fone nuskaitoma ir filtruojama visa lentelė. 
Vietoj to naudokite tiesioginį filtravimą: CALCULATE(..., Lentelė[Stulpelis] = "X").
Kintamieji (VAR): Kintamieji apskaičiuoja reikšmę tik vieną kartą ir išsaugo ją atmintyje. 
Jei tą patį skaičiavimą kode naudojate kelis kartus, įrašykite jį į kintamąjį, kad Power BI nesiųstų dubliuotų užklausų į duomenų bazę.
Lauko parametrai su ISINSCOPE: Kaip pastebėjote ankstesnėje mūsų diskusijoje, DirectQuery režime lauko parametrai sukuria sudėtinius raktus. 
Norint dinamiškai keisti kontekstą (pvz., skaičiuoti procentą nuo Total), geriau naudoti ISINSCOPE tikrinimą ant konkrečių dimensijų stulpelių – tai sugeneruoja žymiai švaresnį ir greitesnį SQL kodą fone.

### 7. Užklausų mažinimas (Query Reduction) ataskaitos puslapyje
Kai jūsų modelis milžiniškas, kiekvienas vartotojo paspaudimas filtre (Slicer) siunčia užklausas į visus puslapio vizualus. 
Tai galima apriboti:Eikite į File $\rightarrow$ Options and settings $\rightarrow$ Options.
Skiltyje Query reduction pažymėkite:Disabling cross-highlighting/filtering by default (išjungia automatinį vizualų filtravimąsi tarpusavyje, kol vartotojas to aiškiai nenurodo per ryšius).Pridėkite „Apply“ mygtuką prie filtrų (Slicers). 
Vartotojas susidėlios 3–4 filtrus ir tik paspaudus Apply, Power BI vienu kartu išsiųs užklausas į duomenų bazę, vietoj to, kad siųstų jas po kiekvieno paspaudimo.

### 8. Atkabinkite (Disable) „Auto Date/Time“ nustatymą
Tai viena dažniausių klaidų, kuri fone nepastebimai suvalgo milžiniškus kiekius RAM. Pagal nutylėjimą „Power BI“ kiekvienam jūsų modelio datų stulpeliui fone sukuria po atskirą, paslėptą kalendoriaus lentelę su visais metų, ketvirčių ir mėnesių lygiais.Sprendimas: Eikite į File $\rightarrow$ Options and settings $\rightarrow$ Options $\rightarrow$ Current File $\rightarrow$ Data Load ir išjunkite varnelę nuo Auto date/time.Efektas: Jei jūsų faktų lentelė turi daug datų stulpelių (pvz., Užsakymo data, Išsiuntimo data, Mokėjimo data), modelio dydis gali sumažėti net iki 30–40%, o DirectQuery užklausos taps kur kas paprastesnės. Vietoj to naudokite vieną tvarkingą, centralizuotą dimensiją Dim_DATE.

### 9. Naudokite „Intelectual Cache“ (Užklausų talpinimą keše)
Jei jūsų ataskaita veikia DirectQuery režimu per Premium / Fabric talpą (Capacity), būtinai įjunkite Query Caching.

Kaip tai veikia: Kai vartotojas atidaro puslapį, „Power BI“ išsaugo vizualų sugeneruotus SQL rezultatus atmintyje. Jei kitas vartotojas (arba tas pats vartotojas po kelių minučių) atidaro tą patį puslapį su tais pačiais filtrais, duomenys nebeužklausiami iš SQL serverio, o akimirksniu paimami iš kešo.

Kur tai rasti: Ataskaitos nustatymuose „Power BI Service“ aplinkoje arba pačios talpos (Capacity) valdymo skyde.

### 10. VertiPaq Analyzer ir DAX Studio (Skenavimas ir diagnostika)
Norint pagreitinti darbą, reikia tiksliai žinoti, kas stabdo sistemą. Įsidiekite nemokamą įrankį DAX Studio ir paleiskite VertiPaq Analyzer.

Ką jis daro: Šis įrankis parodo tikslų jūsų modelio stulpelių svorį baitais ir procentais.

Efektas: Dažnai pamatysite, kad vienas ar du stulpeliai (pavyzdžiui, ilgi komentarų tekstai, sisteminiai sistemų logai ar didelio kardinalumo ID), kurių vartotojai net nenaudoja ataskaitose, užima 80% visos modelio atminties. Juos ištrynus, modelis tiesiog pradeda „skraidyti“.

### 11. Griežtas stulpelių filtravimas „prieš srovę“ (Query Folding)
Kraunant duomenis per Power Query, visi filtravimo ir stulpelių šalinimo veiksmai turi būti atliekami pačioje pradžioje. Įsitikinkite, kad vyksta Query Folding (kai Power Query žingsniai paverčiami į grynus SQL SELECT sakinius ir vykdomi pačiame serveryje, o ne vartotojo kompiuterio RAM atmintyje).

Atsisakykite principo „pasiimsiu viską, gal vėliau prireiks“: Jei jūsų SQL lentelė turi 80 stulpelių, o ataskaitoje naudojate tik 15 – likusius 65 stulpelius ištrinkite pačiame pirmame Power Query žingsnyje. Mažesnis stulpelių skaičius dramatiškai pagreitina stulpelinį suspaudimą.

### 12. Ryšių optimizavimas (Referential Integrity)
DirectQuery režime kiekvienas jūsų vizualas fone sugeneruoja SQL užklausą, kurioje dimensijos ir faktai jungiami naudojant LEFT OUTER JOIN (kad būtų parodytos reikšmės, net jei faktai neturi atitikmens dimensijoje). LEFT JOIN didelėse duomenų bazėse yra brangi operacija.

Sprendimas: Jei esate 100% tikra, kad visi faktų lentelės ID turi savo porą dimensijų lentelėse (duomenų vientisumas yra idealus), ryšio nustatymuose galite pažymėti Assume Referential Integrity.

Efektas: „Power BI“ pakeis fone generuojamą SQL kodą iš LEFT JOIN į INNER JOIN. Duomenų bazės (SQL Server / Fabric) INNER JOIN užklausas vykdo iki kelių kartų greičiau, nes joms nereikia ieškoti tuščių (Null) palikimų fone.






