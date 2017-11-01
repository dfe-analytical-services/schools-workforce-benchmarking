library(testthat)

context("Matching function")

source("R/functions.R")

#Load in core data  ------------------------------------------------------------------------

source("R/load_datasets.R")

# Load in test data ------------------------------------------------------------------------

test_data <- read_csv("tests/Data/subset_test_data.csv", col_types = cols(.default = "c")) %>%
  mutate(number_schls = as.numeric(number_schls))

# Run tests --------------------------------------------------------------------------------

for (i in 1:nrow(test_data)){
  test_that(paste(test_data$URN[i], "-", test_data$characteristics[i]), {
    
    temp <- fn_match_schools(Data, 
                             Data$ID[Data$URN == test_data$URN[i]],
                             unlist(strsplit(test_data$characteristics[i], ", ")),
                             characteristics_match)
    
    expect_equal(nrow(temp), test_data$number_schls[i])
    
  })
}
