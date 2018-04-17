# Schools Workforce Benchmarking [![Build Status](https://travis-ci.org/dfe-analytical-services/schools-workforce-benchmarking.svg?branch=master)](https://travis-ci.org/dfe-analytical-services/schools-workforce-benchmarking)

## Summary

This project defines an [R Shiny](https://shiny.rstudio.com/) application that visualises the published school level [2016 School Workforce SFR](https://www.gov.uk/government/statistics/school-workforce-in-england-november-2016) underlying data.

The application is under development.

## What does the application do?

The application allows you to do the following:

1. Select an Individual School 
2. See where it sits on the national distribution for each measure in the SFR underlying data
3. Subset the distribution to compare schools against schools with similar characteristics 
4. Compare measures for individual schools against one another
5. Generate reports with multiple variables for sharing

## Running the project

To run the project on your machine you need to do the following:

1. Clone the repo.

`git clone https://github.com/dfe-analytical-services/schools-workforce-benchmarking.git`

2. Ensure that you have [Rtools](https://cran.r-project.org/bin/windows/Rtools/) installed. This is so that packrat can install dependencies correctly.

3. Open the project by double clicking the schools_working_benchmarking.Rproj file.

4. Wait for packrat to install the packages (this can take a while). Until you see the following do not stop the code:

`Packrat bootstrap successfully completed. Restarting R and entering packrat mode...`
   
5. Open the UI.R or Server.R file and hit Run App.    

## Project Structure

Throughout the project code is modulated and all files are in relevant sub folders. Chunks of code are loaded using `source("script_name.R")`. This allows code to be reused and split into manageable scripts.

### Data folder

This folder contains the data for the tool. 

- **Characteristics.csv** - list of the school characteristics and corresponding phase type
- **characteristics_match.csv** - list of characteristics and the type of match for creating subset of similar schools
- **deploy_sfr_2016.csv** - raw data for the tool (includes workforce data and school characteristics)

### packrat folder

Contains the packages and keeps the versions contained.

### R folder

This folder contains all of the R scripts that make up the project. 

- **functions.R** - contains functions to create subset of similar schools and generate charts
- **load_datasets.R** - loads the raw data into the app
- **t1_Report.Rmd** - creates downloadable report for similar schools charts
- **t2_Report.Rmd** - creates downloadable report for individual schools charts

### tests folder

Contains R scripts to test that the similar schools function and the app itself are running correctly and accurately

### www folder

Contains DfE logo image, Google Analytics tracking code and script to add extra functionality to app.

## Data Sources

The majority of the data is from the 2016 School Workforce Census.

The school characteristics data are from various external publications including:
- School Census
- Pupil Absence data
- Peformance Tables
- Ofsted