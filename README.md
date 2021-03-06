## WUSTL Pathogen Report

### Overview
This repository contains code for a shiny app that displays summaries of clinical microbiology test results from BJC system hospitals.

### Getting Started
Required R packages:

- [ggiraph](https://github.com/davidgohel/ggiraph)
- [lubridate](https://github.com/tidyverse/lubridate)
- [reactable](https://github.com/glin/reactable)
- [shiny](https://github.com/rstudio/shiny)
- [shinythemes](https://github.com/rstudio/shinythemes)
- [shinyWidgets](https://github.com/dreamRs/shinyWidgets)
- [tidyverse](https://github.com/tidyverse/tidyverse)

The app can be downloaded and run locally with:

```
$ git clone https://github.com/hughes-drew/wustl_pathogen_report
$ cd wustl_pathogen_report/code/app
$ Rscript app.R
```

In addition, a demo is available at:

- [hughesdrew.shinyapps.io/pathogen_report/](https://hughesdrew.shinyapps.io/pathogen_report/)

Note: this app is a prototype, and core functions are still in development (see below). **The app and underlying data have not been validated and should not be used for clinical or public health purposes.**

### Preprocessing
The source data are currently stored as individual .csv files (one per week) that include test-level results and associated metadata (not tracked in this repository). The following script aggregates these results, adds week and month labels, and calculates summary statistics:

- [preprocess.R](code/preprocess/preprocess.R)

The results are stored as an RData file in a public Dropbox folder.

### App

The app displays preprocessed values in a web browser with limited reactivity:

- [app.R](code/app/app.R): main script
- [app_utils.R](code/app/app_utils.R): collection of helper functions and reference data

### To Do

Preprocessing
- Patient age (pediatric, adult): not captured by the current internal database query
- Patient clinical setting (ED, inpatient, outpatient): need to be mapped from patient location
- Patient hospital: need to be mapped from patient location

App
- Filters using age, clinical setting, and hospital have been templated, but need to be validated once data are available
