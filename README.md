### WUSTL Pathogen Report

#### Overview
This repository contains code for a shiny application that displays a weekly summary of hospital system-wide clincal test results for a set of predoiminantly respiratory pathogens with limited interactivity. Note: this application is a prototype, and core functions are still in development (see below). In addition, the application and underlying data have not been validated and should not be used for clinical or public health purposes.

#### Preprocess
The source data are currently stored as collection of .csv files (one per week) that include individual-level test results for requested targets in addition to specimen metadata (not tracked in this repository). The following script aggregates these results, adds week and month labels, and pre-calculates summaries for  seasonal periods of interest (July 1 through June 30):

- [preprocess.R](code/preprocess/preprocess.R)

The results are saved as an RData file.

#### Shiny App

j
