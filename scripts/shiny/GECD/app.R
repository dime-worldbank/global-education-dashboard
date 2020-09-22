
library(shiny)
library(readstata13)
library(tidyverse)
library(estimatr)
library(sjPlot)


# object with outcome variables
yvars <- c("student_knowledge",
           "ecd_student_knowledge",
           "inputs",
           "infrastructure",
           "intrinsic_motivation",
           "content_knowledge",
           "operational_manage",
           "instr_leader",
           "principal_knowl_score",
           "principal_manage",
           "bi",
           "national_learning_goals",
           "mandates_accountability",
           "quality_bureaucracy",
           "impartial_decision_making"
)


condl <- c(
  "pct_urban",
  "med_age",
  "pct_school",
  "pct_lit",
  "pct_edu1",
  "pct_edu2",
  "pct_work",
  "pct_schoolage",
  "pct_elec" ,
  "pct_dwell",
  "enrolled"
)

# Table Labels 
dvlab <- c("Student Knowledge", "ECD Knowledge", "Inputs", "Intrastructure", "Teacher Motivation", "Teacher Content Knowledge", "Operational Management", "Instructional Leadership", "Pricipal Knowledge", "Principal Management")

ivlab <- c("% Urban", "Literacy Rate", "% Schoolage", "% Electricity", "% Improved Dwelling")


#load data
md <- read.dta13(file = "C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/global-edu-dashboard/baseline/DataSets/final/merge_district_tdist.dta",
                 convert.factors = TRUE) 








# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("GECD Regression Explorer"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
        
        # inputs 1: y var
        selectInput("yvar1", #inputid
                    "Outcome Variable 1", #label
                    choices = c("Student Knowledge" = "student_knowledge",
                                "1st Grade Student Knowledge" = "ecd_student_knowledge",
                                "Inputs" = "inputs",
                                "Infrastructure" = "infrastructure",
                                "Teacher Motivation" = "intrinsic_motivation",
                                "Teacher Content Knowledge" = "content_knowledge",
                                "Operational Management" = "operational_manage",
                                "Instructional Leadership" = "instr_leadership",
                                "Principal Knolwedge Score" = "principal_knowl_score",
                                "Principal Management" = "principal_manage"),
                    multiple = FALSE,
                    selected = "infrastructure"
        ),
        
        # inputs 1: x var
        selectInput("xvar1", #inputid
                    "Explanatory Variable 1", #label
                    choices = c("Bureaucracy Index" = "bi",
                                "National Learning Goals" = "national_learning_goals",
                                "Mandates and Accountability" = "mandates_accountability",
                                "Quality of Bureaucracy" = "quality_bureaucracy",
                                "Impartial Decision-Making" = "impartial_decision_making"),
                    multiple = FALSE,
                    selected = "bi"
            )
       ),
      
      # Main Panel
      mainPanel(
        
        
        tabsetPanel(type = "tabs",
        
        
        tabPanel("Scatterplot", plotOutput('scatter'),
                 h5("Note that the superimposed lines are simple best fit with confidence intervals; they are not the resultsing
                    line of the regression specified by the model")),
        tabPanel("Distribution",
                 fluidRow(
                   column(6, plotOutput('distribution1')),
                   column(6, plotOutput('distribution2')))
                  ),
        
        tabPanel("Regression Output", verbatimTextOutput('reg'),
                 p(h2("Model Specification")),
                 p(h5("1. Country Fixed Effects, 2. School size Fixed Effects,
                    3. Standard Errors clustered on District, specified to standard clustering in Stata, 
                    4. District-level averages of Percent Urban, Literacy Rate, Percent of population that is of school age, Percent of households with access to electricity,
             Percent of households with improved dwelling construction materials"))
              
        )
      )
    )
   )
)


# Define server logic required to draw a histogram
server <- function(input, output) {
  
  
   # Regression output
   ## make the regression object
    output$reg <- renderPrint({
      fit <- lm_robust(
                formula = input$yvar1 ~ input$xvar1 + pct_urban + pct_lit + pct_schoolage + pct_elec + pct_dwell + as.factor(enrolled) + as.factor(countryname),
                clusters = g2, se_type = "stata", 
                data = md)
      tab_model(fit)
    })
    
    # + pct_urban + pct_lit + pct_schoolage + pct_elec + pct_dwell + as.factor(enrolled) + as.factor(countryname)
  
  
   # Regression Plot
   output$scatter <-renderPlot({
       
     # plot1 
       ggplot(md, aes_string(input$xvar1, input$yvar1)) +
         geom_jitter() +
         geom_smooth(method = lm) +
         facet_wrap(~ countryname)
       
     },
     # plot options
     width  = 500,
     height = 400,
     res = 100
     )
   
   
   # Histogram 1 
   output$distribution1 <- renderPlot({
     hist(md[,input$yvar1], main = "", xlab = input$yvar1)
   }, height = 300, width = 300)
     
   
   # Histogram 2 
   output$distribution2 <- renderPlot({
     hist(md[,input$xvar1], main = "", xlab = input$xvar1)
   }, height = 300, width = 300)
}

# Run the application 
shinyApp(ui = ui, server = server)

