#ui.R

#This is the user interface, i.e. what you actually see in the app

#Clear the environment
rm(list = ls())

#load libraries
library(shiny)
library(shinycssloaders)
library(tidyverse)
library(rmarkdown)
library(shinyjs)
library(shinyBS)
library(DT)

#define the user interface
shinyUI(
  fluidPage(
    useShinyjs(), 
  #Hide navbar until button is pressed.
    tags$head(
	tags$script(src = "effects.js"),
	tags$script(src = "google-analytics.js")
    ),
  
  #create a page with navigation bar at the top
    navbarPage(
      "Schools Workforce Benchmarking",
      id = "navbar",
   
  #Front page of tool
  
      tabPanel(
        "Front Page",
        h2("Schools Workforce Benchmarking (BETA)"),
        
        sidebarLayout(
          sidebarPanel(
            id = "front_sidebar",
            
          #dropdown to select school ID/URN
            selectizeInput(
              't1_School_ID',
              label = "Enter School URN or Name (Type to Search):",
              choices = NULL
            ),
          #button to submit school ID and make tabs in navigation bar appear
            actionButton('submit_t1_School_ID', 'Submit'),
          
          #School details
            textOutput("t1_School_ID_name"),
            textOutput("t1_School_ID_phase"),
            br(),
          #button to change the School selected and hide the tabs
            actionButton('change_t1_School_ID', 'Change school')
          ),
          mainPanel(
            h3("Summary"),
            p(
              "This web application allows you to visually compare published measures on school's
               workforces against other schools of the same phase."
            ), 
            p("The data in this tool is drawn from the 2016", 
              a("School Workforce Census,", 
                href = "https://www.gov.uk/government/collections/statistics-school-workforce",
                target="_blank"), 
              "the January 2016", 
              a("School Census,", 
                href = "https://www.gov.uk/government/statistics/schools-pupils-and-their-characteristics-january-2016",
                target="_blank"),
              a("Edubase", href = "http://www.education.gov.uk/edubase/home.xhtml",
                target="_blank"),
              "and the latest",
              a("Schools Performance Tables.", href = "https://www.compare-school-performance.service.gov.uk/",
                target="_blank")
            ),
            h3("Similar Schools"),
            p("This tab allows you to visualise where a school sits on the national distribution for 
             each measure. By selecting characteristics, you can subset this distribution to compare 
             against schools that have similar characteristics to the selected school."
              ),
            h3("School to School"),
            p("This tab allows you to select up to 10 individual schools that you would like to 
              compare against the selected school and plots the resultant data."
              ),
            h3("Further Information"),
            p("From both of these tabs you are be able to generate printable reports with the charts
               for multiple measures"),
            p("Data that was recorded as Supressed or not submitted in the published SFR is set
              as blank throughout the tool."),
            br(),
            br(),
            br(),
            br(),
          #dfE logo
            img(
              src = "DfE_logo.png",
              height = 97.5,
              width = 195
            ),
            br(),
            h4("If you would like to provide feedback on your experience using the tool,
              please fill in our survey", 
              a("here.", href = "http://www.smartsurvey.co.uk/s/ZAVEJ/", target="_blank"))
            ),
          position = "right"
          )
      ),
  
  #tab 1 - main tool
  
      tabPanel(
        "Similar Schools",
        h2("Comparison of Measures to Similiar Schools"),
        sidebarLayout(
          sidebarPanel(
            id = "t1_sidebar",
          #dropdown for measures
            uiOutput("t1_measures"),
          #checkboxes for school characteristics
            uiOutput("t1_characteristics"),
          #button to clear selection of characteristics
            actionButton("t1_clear", label = "Clear"),
          #dialog box to choose measures for report
            bsModal(id = "t1_dialog_box", title = "Choose measures for report",
                    trigger = "t1_choose_measures", size = "large",
                  #dropdown of report measures
                    uiOutput("t1_report_measures"),
                  #option to choose type of plot
                    radioButtons("report_plot_type", "Plot type", c("density", "histogram")),
                    br(),
                    downloadButton("t1_report", "Generate report")
            )
          ),
          
          mainPanel(
            tabsetPanel(
              tabPanel("Plot",
                br(),
                fluidRow(
                  column(9, 
                    br(),
                   #text saying the number of schools in the comparison 
                    textOutput("t1_selected_schools")),
                  
                #radio buttons to choose density plot or histogram  
                  column(3, radioButtons("plot_type", "Plot type", c("density", "histogram"), inline = TRUE))
                ),
                em("If number of schools in the comparison falls below 15, it
                     may be more useful to look at the histogram"),
                br(),
                br(),
              #main plot of distribution  
                plotOutput('t1_chart') %>%
                #spinner to appear while chart is loading 
                 withSpinner(color = "grey", type = 5, size = getOption("spinner.size", default = 0.4)),
                br(),
                em("Please note, plots may be affected by outliers."),
                br(),
                br(),

              #text saying value of selected measure for selected school
                textOutput("t1_school_ID_value"),
              #text saying the range for group selected
                textOutput("t1_range"),
              #text saying the average for the group selected
                textOutput("t1_average"),
              #text saying the median for the group selected
                textOutput("t1_median"),
                br(),
              #button to open up dialog box
                actionButton("t1_choose_measures", "Choose measures for report")
              
              ),
              tabPanel("Data",
                      br(),
                    #data of schools in comparison  
                      dataTableOutput("t1_data_table")),
              tabPanel("Characteristics",
                       br(),
                       h3("Characteristics of School"),
                       br(),
                      #characteristics of schools in comparison  
                       dataTableOutput("t1_characteristics_table"))
              )
            )
          )
      ),
  
  #tab 2 - school to school comparison
      tabPanel(
        "School to School",
        h2("School to School Comparison of Measures"),
        sidebarLayout(
          sidebarPanel(
            id = "t2_sidebar",
          #dropdown for measures
            uiOutput("t2_measures"),
          #dropdown to choose other schools, limited to 10  
            selectizeInput(
              't2_Schools',
              label = "Select the Schools you would like to compare against:",
              choices = NULL,
              multiple = TRUE,
              options = list(maxItems = 10)
            ),
            em("Please note, comparing very different schools may not produce meaningful
            results."),

            bsModal(id = "t2_dialog_box", title = "Choose measures for report",
                    trigger = "t2_choose_measures", size = "large",
                    uiOutput("t2_report_measures"),
                    downloadButton("t2_report", "Generate report"))
          ),
          mainPanel(
            plotOutput("t2_chart") %>% 
              withSpinner(color = "grey", type = 5, size = getOption("spinner.size", default = 0.4)),
            br(),
            actionButton("t2_choose_measures", "Choose measures for report")
          )
        )
      )
    )
  )
)