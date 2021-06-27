## WUSTL Pathogen Report

### Overview
This repository contains code for a shiny application that displays summaries of clinical microbiology test results from multiple hospitals. The application can be downloaded and run locally with:

```
$ git clone https://github.com/hughes-drew/wustl_pathogen_report
$ cd wustl_pathogen_report/code/app
$ Rscript app.R
```

A demo is also available at the following URL:

- [hughesdrew.shinyapps.io/pathogen_report/](https://hughesdrew.shinyapps.io/pathogen_report/)

Note: this application is a prototype, and core functions are still in development (see below). **This application and the underlying data are not validated and should not be used for clinical or public health purposes.**

### Preprocess
The source data are currently stored as individual .csv files (one per week) that include test-level results and associated metadata (not tracked in this repository). The following script aggregates these results, adds week and month labels, and pre-calculates seasonal summary statistics (July 1 through June 30) to improve performance:

- [preprocess.R](code/preprocess/preprocess.R)

The results are saved as an RData file and stored in a public Dropbox folder.

### Shiny Application

The shiny application takes the preprocessed values and displays them in a web application:

- [app.R](code/app/app.R): main application script
- [app_utils.R](code/app/app_utils.R): collection of helper functions and reference data called by [app.R](code/app/app.R)

### To-Do List

- Patient age (pediatric vs. adult): not captured by the current internal database query
- Patient clinical setting (ED, inpatient, outpatient): need to be mapped from patient location information
- Patient location: need to be mapped from patient location information
