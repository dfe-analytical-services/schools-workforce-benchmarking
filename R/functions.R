library(tidyverse)


# This following funciton is used to generate a subset of schools via the selected school ID
# and the characteristics selected.

fn_match_schools <- function(dataset,
                            school_id,
                            input_characteristics,
                            characteristics_lookup) {
  
  # Create a table for selected school
  selected_school <- dataset %>%
    filter(ID == school_id)

  # Create a variable for selected schools phase
  selected_phase <- selected_school %>%
    select(`School Phase`) %>%
    as.character()
  
  # Subset main dataframe based on selected schools phase
  selected_phase_data <- dataset %>%
    filter(`School Phase` == selected_phase)
  
  # For each characteristic that is selelected filter the dataset
  for (i in input_characteristics) {
    
    # Get measure value
    measure_value <- selected_school %>%
      select(i) %>%
      as.character()
    
    # Get typpe of measure to work out which filter to apply
    type <- characteristics_lookup %>%
      filter(Characteristic_Label == i) %>%
      select(Match_type) %>%
      as.character()
    
    #If numerical then apply 10 percentage tollearance
    if (type == "Percentage") {
      selected_phase_data <-
        filter(
          selected_phase_data,
          get(i) > as.numeric(measure_value) * 0.9,
          get(i) < as.numeric(measure_value) * 1.1
        )
    }
    #If percentage then apply +- 0.1 percentage point tollerance
    else if (type == "Percentage point") {
      selected_phase_data <-
        filter(
          selected_phase_data,
          get(i) > as.numeric(measure_value) - 0.1,
          get(i) < as.numeric(measure_value) + 0.1
        )
    }
    #Exact match for categorical variables
    else if (type == "Exact") {
      selected_phase_data <-
        filter(selected_phase_data, get(i) == measure_value)
    }
    rm(measure_value)
  }
  
  #Return the filtered dataset
  selected_phase_data
  
}
