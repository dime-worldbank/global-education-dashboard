
library(shiny)
library(readstata13)
library(tidyverse)
library(estimatr)

# intro 
md <- read.dta13(file = "C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/global-edu-dashboard/baseline/DataSets/final/merge_district_tdist.dta",
                 convert.factors = TRUE) 

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Old Faithful Geyser Data"),
   
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
          # regression summary
         verbatimTextOutput(outputId = "regression"),
         
         # plot output
         plotOutput("distPlot")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  
   # Regression output
   ## make the regression object
    lm <- reactive({
      lm_robust(
                input$yvar1 ~ 
                  input$xvar1,
                  + pct_urban + pct_lit + pct_schoolage + pct_elec + pct_dwell 
                  + as.factor(enrolled) + as.factor(countryname),
                clusters = g2, se_type = "stata", 
                data = md)
                })
    
    ## make the summary 
    output$regression <- renderPrint({
      tab_model(lm,
                pred.labels = c("Bureaucracy Index"),
                #dv.labels = dvlab,
                wrap.labels = 20,
                title = "Bureaucracy Index",
                show.ci = FALSE,
                show.se = TRUE,
                collapse.se = TRUE,
                linebreak = TRUE,
                show.intercept = FALSE,
                show.r2 = FALSE,
                p.style = "numeric"
                #terms = c("bi", "pct_lit", "pct_urban", "pct_schoolage", "pct_elec", "pct_dwell")
                )
    })
  
  
   # Regression Plot
   output$distPlot <-renderPlot({
       
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
     
}

# Run the application 
shinyApp(ui = ui, server = server)

