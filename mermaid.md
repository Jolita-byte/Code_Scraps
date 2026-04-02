

[mermaid naudojimo aprašas](https://github.blog/developer-skills/github/include-diagrams-markdown-files-mermaid/)

[mermaid sintaksė](https://mermaid.js.org/intro/syntax-reference.html#syntax-structure)

````
```mermaid
sequenceDiagram
    participant dotcom
    participant iframe
    participant viewscreen
    dotcom->>iframe: loads html w/ iframe url
    iframe->>viewscreen: request template
    viewscreen->>iframe: html & javascript
    iframe->>dotcom: iframe ready
    dotcom->>iframe: set mermaid data on iframe
    iframe->>iframe: render mermaid
```
````

```mermaid
sequenceDiagram
    participant dotcom
    participant iframe
    participant viewscreen
    dotcom->>iframe: loads html w/ iframe url
    iframe->>viewscreen: request template
    viewscreen->>iframe: html & javascript
    iframe->>dotcom: iframe ready
    dotcom->>iframe: set mermaid data on iframe
    iframe->>iframe: render mermaid
```


````
```mermaid
  graph TD;
      start -->A;
      A-->B;
      A-->C;
      B-->D;
      C-->D;
```
````


```mermaid
  graph TD;
      start -->A;
      A-->B;
      A-->C;
      B-->D;
      C-->D;
```
