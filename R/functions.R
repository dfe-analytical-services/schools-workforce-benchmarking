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
    
    tolerance <- 1e-10
   
    #If numerical then apply 10 percentage tollearance
    if (type == "Percentage") {
      selected_phase_data <-
        filter(
          selected_phase_data,
          get(i) > as.numeric(measure_value) * 0.9,
          get(i) < as.numeric(measure_value) * 1.1
        )
    }
    #If percentage then apply +- 10 percentage point tollerance
    else if (type == "Percentage point 1") {
      selected_phase_data <-
        filter(
          selected_phase_data,
          get(i) > as.numeric(measure_value) - 10,
          get(i) < as.numeric(measure_value) + 10
        )
    }
    
    
    #If Value Added then apply +- 0.1 percentage point tollerance
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

# The following is a function that creates chart 1

fn_chart1 <- function(matched_dataset, selected_dataset, plot_measure, plot_type){
  if (plot_type == "density") {
    ggplot() + 
      geom_density(data = matched_dataset,
                   mapping = aes(x = get(plot_measure)),
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

# The following is a function that creates chart 2

fn_chart2 <- function(comp_dataset, selected_dataset, plot_measure){
  
  full_datset <- rbind(comp_dataset, selected_dataset) %>% 
    mutate(labels = ifelse(is.na(get(plot_measure)), "DNS or SUPP", get(plot_measure)),
           numbers_plot = ifelse(is.na(get(plot_measure)), 0, get(plot_measure)))
  
  p <- ggplot(full_datset) +
    geom_bar(mapping = aes(
      x = reorder(ID, numbers_plot),
      y = numbers_plot,
      fill = color), 
      stat = "identity",
      na.rm = TRUE) + #remove NAs silently
    scale_fill_manual(values = c("#9fb9c8","#104f75")) +
    guides(fill = FALSE) +
    coord_flip() + 
    xlab("Schools") + 
    ylab(plot_measure) + 
    theme_bw() + 
    geom_text(aes(x = ID, y = numbers_plot, 
                  label = labels), #label the values
              #all values label except for NAs
              position = position_dodge(.9), hjust=-0.25)
  
  if (is.na(max(full_datset$numbers_plot)) | max(full_datset$numbers_plot) == 0) {
    p + 
      scale_y_continuous(expand = c(0,0), limits=c(0,1))
  } else {
    p
  }

}


# fn_chart2 <- function(comp_dataset, selected_dataset, plot_measure){
#   ggplot(data = rbind(comp_dataset, selected_dataset)) +
#     geom_bar(mapping = aes(
#       x = reorder(ID, get(plot_measure)),
#       y = get(plot_measure),
#       fill = color), 
#       stat = "identity",
#       na.rm = TRUE) + #remove NAs silently
#     scale_fill_manual(values = c("#9fb9c8","#104f75")) +
#     guides(fill = FALSE) +
#     coord_flip() + 
#     xlab("Schools") + 
#     ylab(plot_measure) + 
#     theme_bw() +
#     geom_text(aes(x = ID, y = get(plot_measure), 
#                   label = get(plot_measure)), #label the values
#               #all values label except for NAs
#               position = position_dodge(.9), hjust=-0.25)
# }


#Tried to label the NAs but just get blank
# ifelse(get(plot_measure) == 0, "",
#        ifelse(get(plot_measure) > 0, get(plot_measure), "NA"))

#ifelse(is.na(get(plot_measure)), "NA", get(plot_measure))


#make it so schools with NAs don't appear in the chart
# fn_chart2 <- function(comp_dataset, selected_dataset, plot_measure){
#   ggplot(data = subset(rbind(comp_dataset, selected_dataset),!is.na(get(plot_measure)))) +
#     geom_bar(mapping = aes(
#       x = reorder(ID, get(plot_measure)),
#       y = get(plot_measure),
#       fill = color), 
#       stat = "identity") + 
#     scale_fill_manual(values = c("#9fb9c8","#104f75")) +
#     guides(fill = FALSE) +
#     coord_flip() + 
#     xlab("Schools") + 
#     ylab(plot_measure) + 
#     theme_bw()
# }