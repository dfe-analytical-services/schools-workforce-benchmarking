#Functions used in tool
#1. Similar Schools function
#2. Similar Schools chart
#3. School to School chart

library(tidyverse)

# 1. This following funciton is used to generate a subset of schools via the selected school ID
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
  
  # For each characteristic that is selected filter the dataset
  for (i in input_characteristics) {
    
    # Get measure value
    measure_value <- selected_school %>%
      select(i) %>%
      as.character()
    
    
    # Get type of characteristic to work out which filter to apply
    type <- characteristics_lookup %>%
      filter(Characteristic_Label == i) %>%
      select(Match_type) %>%
      as.character()
    
    #create tolerance - i.e. very small number to add to measure value due to R's floating
    #point issue - https://cran.r-project.org/doc/FAQ/R-FAQ.html#Why-doesn_0027t-R-think-these-numbers-are-equal_003f 
    tolerance <- 1e-10
   
    #If characteristic is numerical then apply 10 percentage tolerance
    #i.e. include schools within 10% of the selected schools characteristic value
    if (type == "Percentage") {
      selected_phase_data <-
        filter(
          selected_phase_data,
          get(i) > as.numeric(measure_value) * 0.9,
          get(i) < as.numeric(measure_value) * 1.1
        )
    }
    
    #If characteristic is a percentage then apply +- 10 percentage point tolerance
    #e.g. % pupils with SEN support
    else if (type == "Percentage point 1") {
      selected_phase_data <-
        filter(
          selected_phase_data,
          get(i) > as.numeric(measure_value) - 10,
          get(i) < as.numeric(measure_value) + 10
        )
    }
    
    
    #If Value Added then apply +- 0.1 percentage point tollerance
    #include the extra tolerance created above
    else if (type == "Percentage point 2") {
      selected_phase_data <-
        filter(
          selected_phase_data,
          get(i) - tolerance > as.numeric(measure_value) - 0.1,
          get(i) + tolerance < as.numeric(measure_value) + 0.1
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

# 2. The following is a function that creates chart 1 - similar schools chart

fn_chart1 <- function(matched_dataset, selected_dataset, plot_measure, plot_type){
  if (plot_type == "density plot") {
    ggplot() + 
      geom_density(data = matched_dataset,
                   mapping = aes(x = get(plot_measure)),
                   adjust = 5, #smoothes out the distribution curve
                   na.rm = TRUE) +
      #red dashed line showing the selected school
      geom_vline(data = selected_dataset,aes(xintercept = get(plot_measure)), 
                 colour = "red", linetype = "dashed",
                 na.rm = TRUE) +
      xlab(plot_measure) + theme_bw()
    
  } else if (plot_type == "histogram") {
    ggplot() + 
      geom_histogram(data = matched_dataset,
                     mapping = aes(x = get(plot_measure)), fill = "#104f75",
                     na.rm = TRUE, bins = 30) +
      geom_vline(data = selected_dataset,aes(xintercept = get(plot_measure)), 
                 colour = "red", linetype = "dashed",
                 na.rm = TRUE) +
      xlab(plot_measure) + theme_bw()
  }
}

# 3. The following is a function that creates chart 2

fn_chart2 <- function(comp_dataset, selected_dataset, plot_measure){
  
  #combine comparison schools and selected school datasets and add columns to allow for labelling NAs
  full_datset <- rbind(comp_dataset, selected_dataset) %>% 
    mutate(labels = ifelse(is.na(get(plot_measure)), "DNS or SUPP", get(plot_measure)),
           numbers_plot = ifelse(is.na(get(plot_measure)), 0, get(plot_measure)))
  
  #barplot with labels
  p <- ggplot(full_datset) +
    geom_bar(mapping = aes(
      x = reorder(ID, numbers_plot),
      y = numbers_plot,
      fill = color), 
      stat = "identity",
      na.rm = TRUE) + #remove NAs silently
    scale_fill_manual(values = c("#9fb9c8","#104f75")) + #DfE colours
    guides(fill = FALSE) + #remove legend
    coord_flip() + 
    xlab("Schools") + 
    ylab(plot_measure) + 
    theme_bw() + 
    geom_text(aes(x = ID, y = numbers_plot, label = labels), 
              position = position_dodge(.9), hjust=-0.25)
  
  #change limits of plot for NAs and when value is 0 so that label appears at the start of chart
  if (is.na(max(full_datset$numbers_plot)) | max(full_datset$numbers_plot) == 0) {
    p + 
      scale_y_continuous(expand = c(0,0), limits=c(0,1))
  } else {
    p
  }

}
