#server.R

#Load Required Packages ----------------------------------------------------------------------

library(tidyverse)

source('R/functions.R')

#Load in relevant data  ----------------------------------------------------------------------

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

#list of school characteristics and what school phase they relate to
characteristics_dd <- read_csv("Data/Characteristics.csv", col_types = cols(.default = "c")) 

#list of characteristics and their type of match for comparisons

characteristics_match <- read_csv("Data/characteristics_match.csv", col_types = cols(.default = "c"))

measure_groupings <- list("Staff Headcount" = colnames(Data)[5:12],
     "Staff FTE" = colnames(Data)[13:21],
     "Teacher Characteristics" = colnames(Data)[22:26],
     "Teaching Assistant Characteristics" = colnames(Data)[27:29],
     "Non-classroom based Support Staff Characteristics" = colnames(Data)[30:31],
     "Auxiliary Staff Characteristics" = colnames(Data)[32:33],
     "Staff Pay" = colnames(Data)[34:37],
     "Teacher Absence" = colnames(Data)[38:41])

#define server logic -------------------------------------------------------------------------

shinyServer(function(input, output, session) {
  
  ##front page###-----------------------------------------------------------------    
  
  #only enable submit button when school ID is selected
  observe({
    shinyjs::toggleState("submit_t1_School_ID", 
                         !is.null(input$t1_School_ID) && input$t1_School_ID != "")
  })
  
  #response to event of clicking submit School ID button
  observeEvent(input$submit_t1_School_ID, {
    
    #Show the navigation bar at the top
    show("navbar")
    
    #school name
    output$t1_School_ID_name <- renderText({
      paste("School:", t1_selected_ID()$`School Name`)
    })
    #school phase
    output$t1_School_ID_phase <- renderText({
      paste("Phase:", t1_selected_ID()$`School Phase`)
    })
    
    #Hide School ID dropdown 
    hide("t1_School_ID")
    
    #Hide submit button
    hide("submit_t1_School_ID")
    
    #show a new button to change school selected
    show("change_t1_School_ID")
    
    #show school name
    show("t1_School_ID_name")
    
    #show school phase
    show("t1_School_ID_phase")
    
  })
  
  #response to event of clicking chnage School ID button
  observeEvent(input$change_t1_School_ID,{
    #show school ID dropdown
    show("t1_School_ID")
    
    #show submit button
    show("submit_t1_School_ID")
    
    #hide school name
    hide("t1_School_ID_name")
    
    #hide school phase
    hide("t1_School_ID_phase")
    
    #hide button to chamge School ID
    hide("change_t1_School_ID")
    
    #hide tabs in navigation bar
    hide("navbar")
    
  })
  
  ##tab 1###----------------------------------------------------------------------
  
  #update school ID dropdown when value is selected
  updateSelectizeInput(
    session = session, 
    inputId = 't1_School_ID',
    choices = Data$ID,
    server = TRUE)
  
  #Create reactive dropdown for measures based on selected phase 
  output$t1_measures <- renderUI({
    selectizeInput(
      inputId = "t1_measures", 
      label = "Select Measure:",
      choices = measure_groupings
    )  
  })
  
  #Create reactive list box for characteristics based on selected phase
  output$t1_characteristics <- renderUI({
    checkboxGroupInput(
      inputId = "t1_characteristics", 
      label = "Characteristics of Schools to compare against (by selecting a 
      characteristic here you are comparing against schools that are
      similar to you in that characteristic):",
      choices = characteristics_dd$Characteristic_Label[characteristics_dd$Type == Data$`School Phase`[Data$ID == input$t1_School_ID]])
  })
  
  #Create reaction to clear check boxes.
  observe({
    if (input$t1_clear > 0) {
      updateCheckboxGroupInput(
        session = session, 
        inputId = "t1_characteristics", 
        choices = characteristics_dd$Characteristic_Label[characteristics_dd$Type ==  Data$`School Phase`[Data$ID == input$t1_School_ID]],
        selected = NULL)
    }
  })
  
  #Create reactive dataset for Selected ID 
  t1_selected_ID <- reactive({
    filter(Data, ID == input$t1_School_ID)
  })
  
  #Create reactive dataset of schools matched to characteristics
  matched_schools <- reactive({
    
    #require the school ID and the measure to be selected
    req(input$t1_School_ID, input$t1_measures)
    
    #Apply matched schools function
    
    fn_match_schools(
      Data, 
      input$t1_School_ID,
      input$t1_characteristics,
      characteristics_match
    )
    
  })
  
  # Define the chart as an output variable - option for density plot or histogram
  output$t1_chart <- renderPlot({
    
    fn_chart1(matched_schools(), t1_selected_ID(), input$t1_measures, input$plot_type)

  })
  
  #table showing the data of the matched schools
  output$t1_data_table <-  DT::renderDataTable({
    matched_schools() %>%
      mutate(Value = matched_schools()[[input$t1_measures]]) %>% 
      mutate(`School Name` = paste("<a href='https://www.get-information-schools.service.gov.uk/Establishments/Establishment/Details/",
                                   URN, "' target='_blank'",">", `School Name`, "</a>", sep = "")) %>%
      select(URN, `School Name`, Value)
  }, options = list(pageLength = 15, autoWidth = FALSE), escape = FALSE)
  
  #table showing the characteristics of the selected school ID
  output$t1_characteristics_table <-  DT::renderDataTable({
    df <- data.frame(Characteristic = colnames(t1_selected_ID()[1,42:66]), Value = t(t1_selected_ID()[1,42:66]))
    phase_characteristics <- characteristics_dd$Characteristic_Label[characteristics_dd$Type ==  Data$`School Phase`[Data$ID == input$t1_School_ID]]
    row.names(df) <- NULL
    df <- filter(df, Characteristic %in% phase_characteristics)
  }, options = list(pageLength = 26, autoWidth = FALSE))
  
  
  #text saying number of schools in comparison
  output$t1_selected_schools <- renderText({
    paste("Number of schools in comparison is", nrow(matched_schools()))
  })
  
  
  
  #text saying value of selected measure for selected school
  output$t1_school_ID_value <- renderText({
    req(input$t1_School_ID, input$t1_measures)
    paste("Your", input$t1_measures, "is", t1_selected_ID()[[input$t1_measures]])
  })
  
  #text saying the range for group selected
  output$t1_range <- renderText({
    paste("The range for the group you have selected is", 
          min(matched_schools()[[input$t1_measures]], na.rm = TRUE), "to", 
          max(matched_schools()[[input$t1_measures]], na.rm = TRUE))
  })
  
  #text saying the average for the group selected
  output$t1_average <- renderText({
    paste("The mean average for the group you have selected is",
          round(mean(matched_schools()[[input$t1_measures]], na.rm = TRUE),1))
  })
  
  #text saying the median for the group selected
  output$t1_median <- renderText({
    paste("The median for the group you have selected is",
          median(matched_schools()[[input$t1_measures]], na.rm = TRUE))
  })
  
  ##tab 1 Dialog box###----------------------------------------------------------------------------------------------------------------
  
  #dropdpwn for measures for report
  output$t1_report_measures <- renderUI({
    selectizeInput(
      inputId = "t1_report_measures", 
      label = "Select Measure:",
      choices = measure_groupings,
      multiple = TRUE
    )
  })
  
  
  ##tab 1 Report###----------------------------------------------------------------------
  
  #download report
  output$t1_report <- downloadHandler(
    filename = "report.docx",
    content = function(file) {
      # Copy the report file to a temporary directory before processing it, in
      # case we don't have write permissions to the current working dir (which
      # can happen when deployed).
      tempReport <- file.path(tempdir(), "t1_Report.Rmd")
      file.copy("R/t1_Report.Rmd", tempReport, overwrite = TRUE)
      
      # Set up parameters to pass to Rmd document
      params <- list(
        measures = input$t1_report_measures,
        plot_type = input$report_plot_type,
        matched = matched_schools(),
        selected = t1_selected_ID(),
        number_of_schools = input$t1_selected_schools
      )
      
      # Knit the document, passing in the `params` list, and eval it in a
      # child of the global environment (this isolates the code in the document
      # from the code in this app).
      rmarkdown::render(tempReport, 
                        output_file = file,
                        params = params,
                        envir = new.env(parent = globalenv())
      )
    }
  )
  
  
  
  ##tab 2###----------------------------------------------------------------------
  
  #Use the update Selectize input method to prepopulate the selected schools box
  #Using this is much faster for large datasets.
  updateSelectizeInput(
    session = session, 
    inputId = 't2_Schools',
    choices = Data$ID[Data$`School Phase` == Data$`School Phase`[Data$ID == 1]],
    server = TRUE)
  
  #Add an observe event to update the selected schools based on phase in same way as on tab1
  #See tab 1 comment for further details.
  observe({
    updateSelectizeInput(
      session = session, 
      inputId = 't2_Schools',
      choices = Data$ID[Data$`School Phase` == Data$`School Phase`[Data$ID == input$t1_School_ID] & 
                          Data$ID != input$t1_School_ID],
      server = TRUE)
  })
  
  
  #Create reactive dropdown for measures based on selected phase
  output$t2_measures <- renderUI({
    selectizeInput(
      inputId = "t2_measures", 
      label = "Select Measure:",
      choices = measure_groupings
    )
  }) 
  
  #Create reactive dataset for Selected ID tab 2 
  t2_selected_ID <- reactive({
    filter(Data, ID == input$t1_School_ID) %>%
      mutate(color = "blue")
  })
  
  #Create reactive dataset for the selected schools to plot against each other
  selected_schools <- reactive({
    filter(Data, ID %in% input$t2_Schools) %>%
      mutate(color = "dodgerblue4")
  })
  
  #bar chat of selected schools
  output$t2_chart <- renderPlot({
    req(input$t2_measures)

    fn_chart2(selected_schools(), t2_selected_ID(), input$t2_measures)
    
  })
  
  ##tab 2 Dialog box###----------------------------------------------------------------------------------------------------------------
  
  #dropdpwn for measures for report
  output$t2_report_measures <- renderUI({
    selectizeInput(
      inputId = "t2_report_measures", 
      label = "Select Measure:",
      choices = measure_groupings,
      multiple = TRUE)
  })
  
  ##tab 2 Report###----------------------------------------------------------------------
  
  #download report
  output$t2_report <- downloadHandler(
    filename = "report2.docx",
    content = function(file) {
      # Copy the report file to a temporary directory before processing it, in
      # case we don't have write permissions to the current working dir (which
      # can happen when deployed).

      t2_tempReport <- file.path(tempdir(), "t2_Report.Rmd")
      file.copy("R/t2_Report.Rmd", t2_tempReport, overwrite = TRUE)
      
      # Set up parameters to pass to Rmd document
      params <- list(
        t2_measures = input$t2_report_measures,
        t2_matched = selected_schools(),
        t2_selected = t2_selected_ID()
      )
      
      # Knit the document, passing in the `params` list, and eval it in a
      # child of the global environment (this isolates the code in the document
      # from the code in this app).
      rmarkdown::render(t2_tempReport, output_file = file,
                        params = params,
                        envir = new.env(parent = globalenv())
      )
    }
  )
  
  #stop app running when closed in browser
  session$onSessionEnded(function() { stopApp() })
  
})
