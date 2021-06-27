### WUSTL Pathogen Report

#### Overview
This repository contains code for a shiny application that displays summaries of hospital test results for a set of target pathogens with limited reactivity. Note: this application is a prototype, and core functions are still in development (see below). **This application and the underlying data are not validated and should not be used for clinical or public health purposes.**

#### Preprocess
The source data are currently stored in a folder of .csv files (one per week) that include individual-level results in addition to test metadata (not tracked in this repository). The following script aggregates these results, adds week and month labels, and pre-calculates seasonal summaries (July 1 through June 30):

- [preprocess.R](code/preprocess/preprocess.R)

The results are saved as an RData file.

#### Shiny App

j
