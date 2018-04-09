#Test to check similar schools function is subsetting the data correctly

library(testthat)

context("Matching function")

source("R/functions.R")

#Load in core data  ------------------------------------------------------------------------

source("R/load_datasets.R")

# Load in test data ------------------------------------------------------------------------

test_data <- read_csv("tests/Data/subset_test_data.csv", col_types = cols(.default = "c")) %>%
  mutate(number_schls = as.numeric(number_schls))

# Run tests --------------------------------------------------------------------------------

#check that the number of schools in the subset created by the tool is equal the actual
#number of schools in that identified subset in the test data
for (i in 1:nrow(test_data)){
  test_that(paste(test_data$URN[i], "-", test_data$characteristics[i]), {
    
    temp <- fn_match_schools(Data, 
                             Data$ID[Data$URN == test_data$URN[i]],
                             unlist(strsplit(test_data$characteristics[i], ", ")),
                             characteristics_match)
    
    expect_equal(nrow(temp), test_data$number_schls[i])
    
  })
}
