## WUSTL Pathogen Report

### Overview
This repository contains code for a shiny application that displays summaries of clinical microbiology test results from BJC system hospitals. The application can be downloaded and run locally with:

```
$ git clone https://github.com/hughes-drew/wustl_pathogen_report
$ cd wustl_pathogen_report/code/app
$ Rscript app.R
```

Alternatively, a demo is also available at:

- [hughesdrew.shinyapps.io/pathogen_report/](https://hughesdrew.shinyapps.io/pathogen_report/)

Note: this application is a prototype, and core functions are still in development (see below). **The application and underlying data have not been validated and should not be used for clinical or public health purposes.**

### Preprocess
The source data are currently stored as individual .csv files (one per week) that include test-level results and associated metadata (not tracked in this repository). The following script aggregates these results, adds week and month labels, and pre-calculates seasonal summary statistics to improve performance:

- [preprocess.R](code/preprocess/preprocess.R)

The results are stored as an RData file in a public Dropbox folder.

### Shiny Application

The shiny application takes the preprocessed values and displays them in a web application:

- [app.R](code/app/app.R): main script
- [app_utils.R](code/app/app_utils.R): collection of helper functions and reference data

### To-Do List

Preprocessing
- [ ] Patient age (pediatric vs. adult): not captured by the current internal database query
- [ ] Patient clinical setting (ED, inpatient, outpatient): need to be mapped from patient location information
- [ ] Patient location: need to be mapped from patient location information

Shiny Application
- [ ] Filters calling the above information have been templated, but need to be validated
