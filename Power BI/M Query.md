# Kalendoriaus kūrimas
## Šventinės dienos
```
let
    StartYear = 2025,  // Pradžios metai
    EndYear = Date.Year(DateTime.LocalNow()) + 1, // Dabartiniai + ateinantys metai
    YearList = List.Numbers(StartYear, EndYear - StartYear + 1),  
 
    // API pagrindinis adresas
    BaseUrl = "https://date.nager.at/api/v3/PublicHolidays/",
 
    // Funkcija užklausai su fiksuotu Web.Contents šaltiniu
    GetHolidays = (y) => 
        let
            Source = Json.Document(Web.Contents(BaseUrl, [RelativePath = Text.From(y) & "/LT"])),  
            Table = Table.FromList(Source, Record.FieldValues, {"date", "localName", "name", "countryCode", "fixed", "global", "counties", "launchYear", "types"}),
            AddedYear = Table.AddColumn(Table, "Year", each y, Int64.Type)  
        in
            AddedYear,
 
    // Užklausos vykdymas visiems metams ir sujungimas į vieną lentelę
    AllHolidays = List.Transform(YearList, each GetHolidays(_)),
    CombinedTable = Table.Combine(AllHolidays),
    #"Removed other columns" = Table.SelectColumns(CombinedTable, {"date", "localName", "name"}),
    #"Changed column type" = Table.TransformColumnTypes(#"Removed other columns", {{"date", type date}, {"localName", type text}, {"name", type text}}),
    after_holiday = Table.TransformColumnTypes(Table.AddColumn(#"Changed column type", "after_holiday", each if List.Contains({"Easter Sunday", "All Saints' Day", "Christmas Day"}, [name]) 
        then Date.AddDays(DateTime.Date([date]), 2) 
        else if [name] = "Christmas Eve" then Date.AddDays(DateTime.Date([date]), 3) 
        else Date.AddDays(DateTime.Date([date]), 1)), {{"after_holiday", type date}}),
  after_hweekend = Table.TransformColumnTypes(Table.AddColumn(after_holiday, "after_hweekend", each if Date.DayOfWeek([after_holiday]) = 5 then Date.AddDays(DateTime.Date([after_holiday]), 2) else if Date.DayOfWeek([after_holiday]) = 6 then Date.AddDays(DateTime.Date([after_holiday]), 1) else [after_holiday]), {{"after_hweekend", type date}})
in
    after_hweekend
```
## Kalendorius
TODO: sutvarkyti tuos kelis kodo gabalus kad būtų vienas
```
let
    FactsMin = List.Min(Facts[DateKey]),
    FactsMax = List.Max(Facts[DateKey]),
    FactBudgetsMin = List.Min(FactBudgets[DateKey]),
    FactBudgetsMax = List.Max(FactBudgets[DateKey]),

    MinDate = List.Min({FactsMin, FactBudgetsMin}),
    MaxDate = List.Max({FactsMax, FactBudgetsMax}),
    //    MinDate = #date(2004, 01, 01),
    //    MaxDate = #date(Date.Year(Date.From(DateTime.LocalNow())), 12, 31),
    Duration = Duration.Days(MaxDate - MinDate) + 1,



    MinDate = List.Min(factsales[Date]),
    MaxDate = List.Max(factsales[Date]),
    Duration = Duration.Days(MaxDate - MinDate) + 1,
    #"Dates List" = List.Dates(MinDate, Duration, #duration(1,0,0,0)),
    #"Converted to Table" = Table.FromList(#"Dates List", Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Renamed Columns" = Table.RenameColumns(#"Converted to Table",{{"Column1", "Date Key"}}),
    #"Changed Type" = Table.TransformColumnTypes(#"Renamed Columns",{{"Date Key", type date}}),
    #"Inserted Year" = Table.AddColumn(#"Changed Type", "Year", each Date.Year([Date Key]), Int64.Type),
    #"Inserted Quarter" = Table.AddColumn(#"Inserted Year", "Quarter", each Date.QuarterOfYear([Date Key]), Int64.Type),
    #"Inserted Month" = Table.AddColumn(#"Inserted Quarter", "Month", each Date.Month([Date Key]), Int64.Type),
    #"Inserted Day" = Table.AddColumn(#"Inserted Month", "Day", each Date.Day([Date Key]), Int64.Type),
    #"Inserted Month Name" = Table.AddColumn(#"Inserted Day", "Month Name", each Date.MonthName([Date Key]), type text)
in
    #"Inserted Month Name"
```
```
let
   Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("i45WMjIwNNI1MAQipdhYAA==", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [StartDate = _t]),
   #"Added EndDate" = Table.TransformColumnTypes(Table.AddColumn(Source, "EndDate", each DateTime.Date(Date.EndOfYear(DateTime.LocalNow()))), {{"EndDate", type date}}),
   #"Changed StartDate type to date" = Table.TransformColumnTypes(#"Added EndDate", {{"StartDate", type date}}),
   #"Added Date" = Table.AddColumn(#"Changed StartDate type to date", "Date", each {Number.From([StartDate])..Number.From([EndDate])}),
   #"Expanded Data" = Table.ExpandListColumn(#"Added Date", "Date"),
   #"Changed Data type to date" = Table.TransformColumnTypes(#"Expanded Data", {{"Date", type date}}),
   #"Removed other columns" = Table.SelectColumns(#"Changed Data type to date", {"Date"}),
   #"Added Year" = Table.AddColumn(#"Removed other columns", "Year", each Date.Year([Date]), Int64.Type),
   #"Added Month" = Table.AddColumn(#"Added Year", "Month", each Date.Month([Date]), Int64.Type),
   #"Added Day" = Table.AddColumn(#"Added Month", "Day", each Date.Day([Date]), Int64.Type),
   #"Added Quarter" = Table.AddColumn(#"Added Day", "Quarter", each Date.QuarterOfYear([Date]), Int64.Type),
   #"Added Week" = Table.AddColumn(#"Added Quarter", "Week", each Date.WeekOfYear([Date]), Int64.Type),
   #"Added Week Day" = Table.AddColumn(#"Added Week", "Week Day", each Date.DayOfWeek([Date]), Int64.Type),
    #"Inserted Day Name" = Table.AddColumn(#"Added Week Day", "Week Day Name", each Date.DayOfWeekName([Date]), type text),
   #"Added Month Name" = Table.AddColumn(#"Inserted Day Name", "Month Name", each Date.MonthName([Date]), type text),
   #"Added Month Name Short" = Table.AddColumn(#"Added Month Name", "Month Name Short", each Text.Start([Month Name], 3), type text),
   #"Added Quarter Text" = Table.AddColumn(#"Added Month Name Short", "Quarter Text", each "Qtr " & Number.ToText([Quarter]), type text),
    #"Added Year Week" = Table.AddColumn(#"Added Quarter Text", "Year Week", each Number.ToText([Year]) & "-" & Number.ToText([Week]), type text),
#"Added Year Month" = Table.AddColumn(#"Added Year Week", "Year Month", each Date.ToText([Date], "yyyy-MM"), type text)
    #"Added Week Day Name LT" = Table.AddColumn(#"Added Year Month", "Week Day Name LT", each if [Week Day] = 0 then "Sekmadienis" else if [Week Day] = 1 then "Pirmadienis" else if [Week Day] = 2 then "Antradienis" else if [Week Day] = 3 then "Trečiadienis" else if [Week Day] = 4 then "Ketvirtadienis" else if [Week Day] = 5 then "Penktadiens" else if [Week Day] = 6 then "Šeštadienis" else null, type text),
   #"Added Month Name LT" = Table.AddColumn(#"Added Week Day Name LT", "Month Name LT", each if [Month] = 1 then "Sausis" else if [Month] = 2 then "Vasaris" else if [Month] = 3 then "Kovas" else if [Month] = 4 then "Balandis" else if [Month] = 5 then "Gegužė" else if [Month] = 6 then "Birželis" else if [Month] = 7 then "Liepa" else if [Month] = 8 then "Rugpjūtis" else if [Month] = 9 then "Rugsėjis" else if [Month] = 10 then "Spalis" else if [Month] = 11 then "Lapkritis" else "Gruodis", type text),
   #"Added Month Name Short LT" = Table.AddColumn(#"Added Month Name LT", "Month Name Short LT", each if [Month Name LT] = "Rugpjūtis" or [Month Name LT] = "Rugsėjis" then Text.Start([Month Name LT], 4) else Text.Start([Month Name LT], 3), type text),
   #"Added Quarter Text LT" = Table.AddColumn(#"Added Month Name Short LT", "Quarter Text LT", each "Ketv. " & Number.ToText([Quarter]), type text),
   #"Added DateID" = Table.TransformColumnTypes(Table.AddColumn(#"Added Quarter Text LT", "DateID", each [Date]), {{"DateID", Int64.Type}})
in
    #"Added DateID"

```
```
let
   Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("i45WMjIwtNA1MAQipdhYAA==", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [StartDate = _t]),
   #"Added EndDate" = Table.TransformColumnTypes(Table.AddColumn(Source, "EndDate", each DateTime.Date(DateTime.LocalNow())), {{"EndDate", type date}}),
   #"Changed StartDate type to date" = Table.TransformColumnTypes(#"Added EndDate", {{"StartDate", type date}}),
   #"Added Date" = Table.AddColumn(#"Changed StartDate type to date", "Data", each {Number.From([StartDate])..Number.From([EndDate])}),
   #"Expanded Data" = Table.ExpandListColumn(#"Added Date", "Data"),
   #"Changed Data type to date" = Table.TransformColumnTypes(#"Expanded Data", {{"Data", type date}}),
   #"Removed other columns" = Table.SelectColumns(#"Changed Data type to date", {"Data"}),
   #"Added Metai" = Table.AddColumn(#"Removed other columns", "Metai", each Date.Year([Data]), Int64.Type),
   #"Added Menesis" = Table.AddColumn(#"Added Metai", "Menesis", each Date.Month([Data]), Int64.Type),
   #"Added MenesioPav" = Table.AddColumn(#"Added Menesis", "MenesioPav", each Date.MonthName([Data]), type text),
   #"Added TrumpasMenesioPav" = Table.AddColumn(#"Added MenesioPav", "TrumpasMenesioPav", each Text.Start([MenesioPav], 3), type text),
   #"Added Ketvirtis" = Table.AddColumn(#"Added TrumpasMenesioPav", "Ketvirtis", each Date.QuarterOfYear([Data]), Int64.Type),
   #"Added KetvircioTekstas" = Table.AddColumn(#"Added Ketvirtis", "KetvircioTekstas", each "Qtr " & Number.ToText([Ketvirtis]), type text),
   #"Added Savaite" = Table.AddColumn(#"Added KetvircioTekstas", "Savaite", each Date.WeekOfYear([Data]), Int64.Type),
   #"Added MetaiMenesisTekstas" = Table.AddColumn(#"Added Savaite", "MetaiMenesisTekstas", each if [Menesis] < 10 then Number.ToText([Metai]) & "-0" & Number.ToText([Menesis]) else Number.ToText([Metai]) & "-" & Number.ToText([Menesis]), type text),
   #"Replace errors" = Table.ReplaceErrorValues(#"Added MetaiMenesisTekstas", {{"MetaiMenesisTekstas", null}}),
   #"Added SavaitesDiena" = Table.AddColumn(#"Replace errors", "SavaitesDiena", each Date.DayOfWeek([Data]), Int64.Type),
   #"Added Diena" = Table.AddColumn(#"Added SavaitesDiena", "Diena", each Date.Day([Data]), Int64.Type),
   #"Added MetaiSavaiteTekstas" = Table.AddColumn(#"Added Diena", "MetaiSavaiteTekstas", each Number.ToText([Metai]) & "-" & Number.ToText([Savaite]), type text),
   #"Reordered columns" = Table.ReorderColumns(#"Added MetaiSavaiteTekstas", {"Data", "Metai", "Menesis", "Diena", "Ketvirtis", "Savaite", "SavaitesDiena", "MenesioPav", "TrumpasMenesioPav", "KetvircioTekstas", "MetaiSavaiteTekstas", "MetaiMenesisTekstas"}),
   #"Added MenesioPavLT" = Table.AddColumn(#"Reordered columns", "MenesioPavLT", each if [Menesis] = 1 then "Sausis" else if [Menesis] = 2 then "Vasaris" else if [Menesis] = 3 then "Kovas" else if [Menesis] = 4 then "Balandis" else if [Menesis] = 5 then "Gegužė" else if [Menesis] = 6 then "Birželis" else if [Menesis] = 7 then "Liepa" else if [Menesis] = 8 then "Rugpjūtis" else if [Menesis] = 9 then "Rugsėjis" else if [Menesis] = 10 then "Spalis" else if [Menesis] = 11 then "Lapkritis" else "Gruodis", type text),
   #"Added TrumpasMenesioPavLT" = Table.AddColumn(#"Added MenesioPavLT", "TrumpasMenesioPavLT", each if [MenesioPavLT] = "Rugpjūtis" or [MenesioPavLT] = "Rugsėjis" then Text.Start([MenesioPavLT], 4) else Text.Start([MenesioPavLT], 3), type text),
   #"Added KetvircioTekstasLT" = Table.DuplicateColumn(#"Added TrumpasMenesioPavLT", "KetvircioTekstas", "KetvircioTekstasLT"),
   #"Replaced Qtr with Ketv." = Table.ReplaceValue(#"Added KetvircioTekstasLT", "Qtr ", "Ketv. ", Replacer.ReplaceText, {"KetvircioTekstasLT"}),
   #"Added DateID" = Table.TransformColumnTypes(Table.AddColumn(#"Replaced Qtr with Ketv.", "DateID", each [Data]), {{"DateID", Int64.Type}}),
   #"Added Sort" = Table.AddColumn(#"Added DateID", "YearMonthSort", each if [Menesis] < 10 then Number.ToText([Metai])&"0"&Number.ToText([Menesis]) else Number.ToText([Metai])&Number.ToText([Menesis])),
   #"Changed Type" = Table.TransformColumnTypes(#"Added Sort",{{"YearMonthSort", Int64.Type}})
in
   #"Changed Type"

```
## kalendorius su laukų pavadinimais EN kalba
```
let
   // MinDate = List.Min(List.Combine({Facts[DateKey], FactBudgets[DateKey]})),
   // MaxDate = List.Max(List.Combine({Facts[DateKey], FactBudgets[DateKey]})),
   MinDate = #date(2004, 01, 01),
   MaxDate = #date(Date.Year(Date.From(DateTime.LocalNow())), 12, 31),
   Duration = Duration.Days(MaxDate - MinDate) + 1,
   #"Dates List" = List.Dates(MinDate, Duration, #duration(1,0,0,0)),
   #"Converted to Table" = Table.FromList(#"Dates List", Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Renamed Columns" = Table.RenameColumns(#"Converted to Table",{{"Column1", "Date"}}),
    #"Changed Data type to date" = Table.TransformColumnTypes(#"Renamed Columns", {{"Date", type date}}),
   #"Added Year" = Table.AddColumn(#"Changed Data type to date", "Year", each Date.Year([Date]), Int64.Type),
   #"Added Month" = Table.AddColumn(#"Added Year", "Month", each Date.Month([Date]), Int64.Type),
   #"Added Day" = Table.AddColumn(#"Added Month", "Day", each Date.Day([Date]), Int64.Type),
   #"Added Quarter" = Table.AddColumn(#"Added Day", "Quarter", each Date.QuarterOfYear([Date]), Int64.Type),
   #"Added Week" = Table.AddColumn(#"Added Quarter", "Week", each Date.WeekOfYear([Date]), Int64.Type),
   #"Added Week Day" = Table.AddColumn(#"Added Week", "Week Day", each Date.DayOfWeek([Date]), Int64.Type),
    #"Inserted Day Name" = Table.AddColumn(#"Added Week Day", "Week Day Name", each Date.DayOfWeekName([Date]), type text),
   #"Added Month Name" = Table.AddColumn(#"Inserted Day Name", "Month Name", each Date.MonthName([Date]), type text),
   #"Added Month Name Short" = Table.AddColumn(#"Added Month Name", "Month Name Short", each Text.Start([Month Name], 3), type text),
   #"Added Quarter Text" = Table.AddColumn(#"Added Month Name Short", "Quarter Text", each "Qtr " & Number.ToText([Quarter]), type text),
    #"Added Year Week" = Table.AddColumn(#"Added Quarter Text", "Year Week", each Number.ToText([Year]) & "-" & Number.ToText([Week]), type text),
   #"Added Year Month" = Table.AddColumn(#"Added Year Week", "Year Month", each if [Month] < 10 then Number.ToText([Year]) & "-0" & Number.ToText([Month]) else Number.ToText([Year]) & "-" & Number.ToText([Month]), type text),
    #"Added Week Day Name LT" = Table.AddColumn(#"Added Year Month", "Week Day Name LT", each if [Week Day] = 0 then "Sekmadienis" else if [Week Day] = 1 then "Pirmadienis" else if [Week Day] = 2 then "Antradienis" else if [Week Day] = 3 then "Trečiadienis" else if [Week Day] = 4 then "Ketvirtadienis" else if [Week Day] = 5 then "Penktadiens" else if [Week Day] = 6 then "Šeštadienis" else null, type text),
   #"Added Month Name LT" = Table.AddColumn(#"Added Week Day Name LT", "Month Name LT", each if [Month] = 1 then "Sausis" else if [Month] = 2 then "Vasaris" else if [Month] = 3 then "Kovas" else if [Month] = 4 then "Balandis" else if [Month] = 5 then "Gegužė" else if [Month] = 6 then "Birželis" else if [Month] = 7 then "Liepa" else if [Month] = 8 then "Rugpjūtis" else if [Month] = 9 then "Rugsėjis" else if [Month] = 10 then "Spalis" else if [Month] = 11 then "Lapkritis" else "Gruodis", type text),
   #"Added Month Name Short LT" = Table.AddColumn(#"Added Month Name LT", "Month Name Short LT", each if [Month Name LT] = "Rugpjūtis" or [Month Name LT] = "Rugsėjis" then Text.Start([Month Name LT], 4) else Text.Start([Month Name LT], 3), type text),
   #"Added Quarter Text LT" = Table.AddColumn(#"Added Month Name Short LT", "Quarter Text LT", each "Ketv. " & Number.ToText([Quarter]), type text),
   #"Added DateID" = Table.TransformColumnTypes(Table.AddColumn(#"Added Quarter Text LT", "DateID", each [Date]), {{"DateID", Int64.Type}}),
    #"Renamed Columns1" = Table.RenameColumns(#"Added DateID",{{"Date", "DateKey"}})
in
    #"Renamed Columns1"

```
