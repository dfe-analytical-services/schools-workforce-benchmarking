#server.R

#this is essentially how the app is built

#Load Required Packages ----------------------------------------------------------------------

library(tidyverse)

#Load in relevant data  ----------------------------------------------------------------------
#Data <- read_csv("Data/deploy data.csv")

Data <- read_csv("Data/deploy_sfr_2016.csv")

#Added this in to remove the SUPP measures until we decide what to do with them.
Data[Data == 'SUPP'] <- NA
Data[Data == "DNS"] <- NA


Data[11:33] <- lapply(Data[,11:33], as.numeric)

Data$ID <- paste(Data$URN,' - ', Data$`School Name`, sep = '')





#list of school characteristics and what school phase they relate to
characteristics_dd <- read_csv("Data/Characteristics.csv") 

#list of characteristics and their type of match for comparisons
characteristics_match <- read_csv("Data/characteristics_match.csv")

# #list of deployment measures and what school phase they relate to
# measures_dd <- read_csv("Data/Deployment_Measures.csv")

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
    
    #The text for the school
    # #school name
    # output$t1_School_ID_name <- renderText({
    #   paste("School:", t1_selected_ID()$`Auxiliary Name`)
    # })
    
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
    choices = Data$ID[Data$`School Phase` %in% c('Primary','Secondary','Special')],
    server = TRUE)
  
  
  # #Create reactive dropdown for measures based on selected phase 
  # output$t1_measures <- renderUI({
  #   selectizeInput(
  #     inputId = "t1_measures", 
  #     label = "Select Deployment Measure:",
  #     choices = measures_dd$Deployment_Measure[measures_dd$Type == Data$`School Phase`[Data$ID == input$t1_School_ID]])
  # })
  
  #Create reactive dropdown for measures based on selected phase 
  output$t1_measures <- renderUI({
    selectizeInput(
      inputId = "t1_measures", 
      label = "Select Deployment Measure:",
      choices = list("Staff Numbers" = colnames(Data)[11:27],
                     "Staff Characteristics" = colnames(Data)[28:31],
                     "Staff Pay" = list(colnames(Data)[32]),
                     "Teacher Absence" = list(colnames(Data)[33]))
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
  
  #Create reactive dataset for all schools filtered by phase
  selected_phase_data <- reactive({
    filter(Data, `School Phase` == Data$`School Phase`[Data$ID == input$t1_School_ID])
  })
  
  #Create reactive dataset of schools matched to characteristics
  matched_schools <- reactive({
    #require the school ID and the deployment measure to be selected
    req(input$t1_School_ID, input$t1_measures)

    temp <- selected_phase_data()

    for (i in input$t1_characteristics) {
      val <- as.character(t1_selected_ID()[,i])

      type <- as.character(characteristics_match[characteristics_match$Characteristic_Label == i,
                                                 "Match_type"])
      if (type == "Percentage") {
        #This line is where the 10% tolerance is applied to numerical variables 
        #deprivation and number of pupils
        temp <- filter(temp, get(i) > as.numeric(val) * 0.9, get(i) < as.numeric(val) * 1.1 )
      }
      #this is for all other numerical variables
      else if (type == "Percentage point") {
        temp <- filter(temp,  get(i) > as.numeric(val) - 0.1, get(i) < as.numeric(val) + 0.1)
      }
      #this is where similar schools will have the exact same value as chosen school
      else if (type == "Exact") {
        temp <- filter(temp, get(i) == val)
      }
      rm(val)
    }
    temp
  })
  
  
  
  # Define the chart as an output variable - option for density plot or histogram
  output$t1_chart <- renderPlot({
    if (input$plot_type == "density") {
      ggplot() + 
        geom_density(data = matched_schools(),
                     mapping = aes(x = get(input$t1_measures)),
                     na.rm = TRUE) +
        #red dashed line showing the selected school
        geom_vline(data = t1_selected_ID(),aes(xintercept = get(input$t1_measures)), 
                   colour = "red", linetype = "dashed",
                   na.rm = TRUE) +
        xlab(input$t1_measures) + theme_bw()
      
    } else if (input$plot_type == "histogram") {
      ggplot() + 
        geom_histogram(data = matched_schools(),
                       mapping = aes(x = get(input$t1_measures)), fill = "#104f75",
                       na.rm = TRUE, bins = 30) +
        geom_vline(data = t1_selected_ID(),aes(xintercept = get(input$t1_measures)), 
                   colour = "red", linetype = "dashed",
                   na.rm = TRUE) +
        xlab(input$t1_measures) + theme_bw()
    }
  })
  
  #table showing the data of the matched schools
  output$t1_data_table <-  DT::renderDataTable({
      matched_schools() %>%
      mutate(Value = matched_schools()[[input$t1_measures]]) %>% 
      # mutate(Link = "http://www.education.gov.uk/edubase/home.xhtml") %>%
      select(URN, `School Name`, Value)
  }, options = list(pageLength = 15, autoWidth = FALSE))
  
  #table showing the characteristics of the selected school ID
  output$t1_characteristics_table <-  DT::renderDataTable({
    df <- data.frame(Characteristic = colnames(t1_selected_ID()[1,34:59]), Value = t(t1_selected_ID()[1,34:59]))
    phase_characteristics <- characteristics_dd$Characteristic_Label[characteristics_dd$Type ==  Data$`School Phase`[Data$ID == input$t1_School_ID]]
    row.names(df) <- NULL
    df <- filter(df, Characteristic %in% phase_characteristics)
  }, options = list(pageLength = 26, autoWidth = FALSE))
  
  
  #text saying number of schools in comparison
  output$t1_selected_schools <- renderText({
    paste("Number of schools in comparison is", nrow(matched_schools()))
  })
  

  
  #text saying value of selected deployment measure for selected school
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
        label = "Select Deployment Measure:",
        choices = list("Staff Numbers" = colnames(Data)[11:27],
                       "Staff Characteristics" = colnames(Data)[28:31],
                       "Staff Pay" = list(colnames(Data)[32]),
                       "Teacher Absence" = list(colnames(Data)[33])),
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
      file.copy("t1_Report.Rmd", tempReport, overwrite = TRUE)
      
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
      label = "Select Deployment Measure:",
      choices = list("Staff Numbers" = colnames(Data)[11:27],
                     "Staff Characteristics" = colnames(Data)[28:31],
                     "Staff Pay" = list(colnames(Data)[32]),
                     "Teacher Absence" = list(colnames(Data)[33]))
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
    
    # plot_data <- rbind(selected_schools(), t2_selected_ID())
    # 
    # plot_data[is.na(plot_data)] <- 0
    
    ggplot(data = rbind(selected_schools(), t2_selected_ID())) +
      geom_bar(mapping = aes(
        x = reorder(ID, get(input$t2_measures)),
        y = get(input$t2_measures),
        fill = color), 
        stat = "identity") + 
      scale_fill_manual(values = c("#9fb9c8","#104f75")) +
      guides(fill = FALSE) +
      coord_flip() + 
      xlab("School") + 
      ylab(input$t2_measures) + 
      theme_bw()
  })

  ##tab 2 Dialog box###----------------------------------------------------------------------------------------------------------------
  
  #dropdpwn for measures for report
  output$t2_report_measures <- renderUI({
    selectizeInput(
      inputId = "t2_report_measures", 
      label = "Select Deployment Measure:",
      choices = list("Staff Numbers" = colnames(Data)[11:27],
                     "Staff Characteristics" = colnames(Data)[28:31],
                     "Staff Pay" = list(colnames(Data)[32]),
                     "Teacher Absence" = list(colnames(Data)[33])),
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
      file.copy("t2_Report.Rmd", t2_tempReport, overwrite = TRUE)
  
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
