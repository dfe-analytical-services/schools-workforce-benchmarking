library(testthat)

context("Matching function")

source('R/functions.R')

#Load in core data  ------------------------------------------------------------------------

Data <- read_csv("Data/deploy_sfr_2016.csv",  col_types = cols(.default = "c"))

#Set SUPP and DNS to NA
Data[Data == 'SUPP'] <- NA
Data[Data == "DNS"] <- NA

#Set variables to numeric for plotting
Data[5:41] <- lapply(Data[,5:41], as.numeric)
Data[47] <- lapply(Data[,47], as.numeric)
Data[52:63] <- lapply(Data[,52:63], as.numeric)

#Create custom id column
Data$ID <- paste(Data$URN,' - ', Data$`School Name`, sep = '')

# Load in Characteristics type -------------------------------------------------------------
characteristics_match <- read_csv("Data/characteristics_match.csv", col_types = cols(.default = "c"))

# Load in test data ------------------------------------------------------------------------

test_data <- read_csv("tests/data/subset_test_data.csv", col_types = cols(.default = "c")) %>%
  mutate(number_schls = as.numeric(number_schls))

# Run tests --------------------------------------------------------------------------------

for (i in 1:nrow(test_data)){
  test_that(paste(test_data$URN[i], "-", test_data$characteristics[i]), {
    
    temp <- fn_match_schools(Data, 
                             Data$ID[Data$URN == test_data$URN[i]],
                             test_data$characteristics[i],
                             characteristics_match)
    
    expect_equal(nrow(temp), test_data$number_schls[i])
    
  })
}
