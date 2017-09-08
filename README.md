# Schools Workforce Benchmarking

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

1. Clone the repo

   `git clone https://github.com/adamrobinson361/schools-workforce-benchmarking.git`

2. Ensure that you have [Rtools](https://cran.r-project.org/bin/windows/Rtools/) installed. This is so that packrat can install dependencies correctly.

3. Open the project by double clicking the schools_working_benchmarking.Rproj file.

4. Wait for packrat to install the packages (this can take a while). Until you see the following do not stop the code:

   `Packrat bootstrap successfully completed. Restarting R and entering packrat mode...`
   
5. Open the UI.R or Server.R file and hit Run App.    
