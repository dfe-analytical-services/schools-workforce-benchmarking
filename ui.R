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
    tags$head(tags$script(src = "effects.js")
    ),
  
  
    
  #create a page with navigation bar at the top
    navbarPage(
      "Schools Workforce Benchmarking",
      id = "navbar",
   
  #Front page of tool
  
      tabPanel(
        "Front Page",
        h2("Schools Workforce Benchmarking (BETA version)"),
        
        sidebarLayout(
          sidebarPanel(
            id = "front_sidebar",
            
          #dropdown to select school ID/URN
            selectizeInput(
              't1_School_ID',
              label = "Enter Schol URN or Name (Type to Search):",
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
            p(
              "This tool enables your school to compare a variety of deployment approaches 
              (e.g. the number of teachers employed, percentage of teachers that are employed part-time, 
              and the average age of teachers employed) to other schools."
            ),
            br(),
            "On the ‘Main tool’ tab, you will be able to select the deployment 
            measure you would like to compare, and then a group of similar schools 
            will be calculated based on you ticking school characteristics of your 
            choice such as region, number of pupils and Ofsted rating. This will 
            produce a distribution of the deployment measure and an indication of 
            where your school lies on this distribution.",
            p("Please note that here you will only be able to compare your school to 
            other schools of the same phase."),
            br(),
            "On the ‘School to school’ tab, you will again be able to select a 
            deployment measure to compare, but here you will be able to select up to 
            10 individual schools of your choice to compare against.",
            p("Please note, comparing very different schools may not produce meaningful
            results."),
            br(),
            "From both of these tabs you will be able to generate reports.",
            br(),
            br(),
            "Our ‘Methodology’ tab details how the group of similar schools is calculated.",
            br(),
            br(),
            p("The data in this tool is drawn from the 2016", 
              a("School Workforce Census,", 
                href = "https://www.gov.uk/government/collections/statistics-school-workforce"), 
              "the January 2016", 
              a("School Census,", 
                href = "https://www.gov.uk/government/statistics/schools-pupils-and-their-characteristics-january-2016"),
              a("Edubase", href = "http://www.education.gov.uk/edubase/home.xhtml"),
              "and the latest",
              a("Schools Performance Tables.", href = "https://www.compare-school-performance.service.gov.uk/")
            ),
            p("This tool is based on data provided to us by schools. 
              Please note that not all school data is used for data quality/disclosure reasons.",
            br(),
            br(),
            "Please find full guidance on using this tool attached."),
            br(),
            h4("Please begin by typing in your school’s name/URN on the right and
               clicking submit:"),
            h4("You can then navigate between the tabs at the top of the page."),
            br(),
            br(),
          #dfE logo
            img(
              src = "DfE_logo.png",
              height = 65,
              width = 130
            ),
            br(),
            p("If you have any comments or feedback, please email", 
              a("TeachersAnalysisUnit.MAILBOX@education.gov.uk", 
                href = "mailto:TeachersAnalysisUnit.MAILBOX@education.gov.uk"))
            ),
          position = "right"
          )
      ),
  
  #tab 1 - main tool
  
      tabPanel(
        "Main Tool",
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