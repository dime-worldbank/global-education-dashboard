
library(shiny)
library(shinyjs)
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
  "enrolled",
  "ln_gdp",
  "ln_dist_n_stud"
)

# Table Labels 
dvlab <- c("Student Knowledge", "ECD Knowledge", "Inputs", "Intrastructure", "Teacher Motivation", "Teacher Content Knowledge", "Operational Management", "Instructional Leadership", "Pricipal Knowledge", "Principal Management")

ivlab <- c("% Urban", "Literacy Rate", "% Schoolage", "% Electricity", "% Improved Dwelling")


#load data
md <- readRDS(file = "final-by-district.Rda") 

# create by-country objects
md.per <- md %>% 
  filter(countryname == "Peru")

md.jor <- md %>% 
  filter(countryname == "Jordan")

md.rwa <- md %>% 
  filter(countryname == "Rwanda")

md.moz <- md %>% 
  filter(countryname == "Mozambique")







# Define UI for application that draws a histogram
ui <- fluidPage(
  
  useShinyjs(),
   
   # Application title
   titlePanel("GECD Regression Explorer"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
        p(h3("Plot Input Selector")),
        
        # inputs 1: y var
        selectInput("yvar1", #inputid
                    "Outcome Variable", #label
                    choices = c("Student Knowledge" = "student_knowledge",
                                "1st Grade Student Knowledge" = "ecd_student_knowledge",
                                "Inputs" = "inputs",
                                "Infrastructure" = "infrastructure",
                                "Teacher Motivation" = "intrinsic_motivation",
                                "Teacher Content Knowledge" = "content_knowledge",
                                "Operational Management" = "operational_manage",
                                "Instructional Leadership" = "instr_leader",
                                "Principal Knowledge Score" = "principal_knowl_score",
                                "Principal Management" = "principal_manage"),
                    multiple = FALSE,
                    selected = "infrastructure"
        ),
        
        # inputs 1: x var
        selectInput("xvar1", #inputid
                    "Explanatory Variable", #label
                    choices = c("Bureaucracy Index" = "bi",
                                "National Learning Goals" = "national_learning_goals",
                                "Mandates and Accountability" = "mandates_accountability",
                                "Quality of Bureaucracy" = "quality_bureaucracy",
                                "Impartial Decision-Making" = "impartial_decision_making",
                                "Literacy Rate" = "pct_lit",
                                "% Urban" = "pct_urban",
                                "% Houses Electrified" = "pct_elec",
                                "% Houses Improved Dwelling" = "pct_dwell",
                                "% Schoolage" = "pct_schoolage",
                                "School Size" = "as.factor(enrolled)",
                                "Log GDP" = "ln_gdp",
                                "Log District Enrollment" = "ln_dist_n_stud"
                                ),
                    multiple = FALSE,
                    selected = "bi"
            ),
        
        
        # Regression Panel
        p(h3("Regression Input Selector")),
        
        # Country Selector
        p(h4("Country Toggle")),
        helpText("Pressing the toggles will show or hide regression ouputs."),
        actionButton("jor","JOR", width = "50px"),
        actionButton("moz","MOZ", width = "50px"),
        actionButton("per","PER", width = "50px"),
        actionButton("rwa","RWA", width = "50px"),
        actionButton("all","All", width = "50px"),
        
        

        # Outcome Vars
        selectInput("lmout1", #inputid
                    "Outcome Variable", #label
                    choices = c("Student Knowledge" = "student_knowledge",
                                "1st Grade Student Knowledge" = "ecd_student_knowledge",
                                "Inputs" = "inputs",
                                "Infrastructure" = "infrastructure",
                                "Teacher Motivation" = "intrinsic_motivation",
                                "Teacher Content Knowledge" = "content_knowledge",
                                "Operational Management" = "operational_manage",
                                "Instructional Leadership" = "instr_leader",
                                "Principal Knowledge Score" = "principal_knowl_score",
                                "Principal Management" = "principal_manage"),
                    multiple = FALSE,
                    selected = "infrastructure"
        ),
        
        
        # Explanatory Vars
        checkboxGroupInput("lmin1", #inputid
                    "Explanatory Variables", #label
                    choices = c("Bureaucracy Index" = "bi",
                                "National Learning Goals" = "national_learning_goals",
                                "Mandates and Accountability" = "mandates_accountability",
                                "Quality of Bureaucracy" = "quality_bureaucracy",
                                "Impartial Decision-Making" = "impartial_decision_making",
                                "Literacy Rate" = "pct_lit",
                                "% Urban" = "pct_urban",
                                "% Houses Electrified" = "pct_elec",
                                "% Houses Improved Dwelling" = "pct_dwell",
                                "% Schoolage" = "pct_schoolage",
                                "School Size" = "as.factor(enrolled)",
                                "Country FE" = "as.factor(countryname)",
                                "Log GDP" = "ln_gdp",
                                "Log District Enrollment" = "ln_dist_n_stud"
                                ),
                    selected = c("bi")
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
                   column(6, plotOutput('distribution2'))),
                 p(h5("Note the unit of analysis of Outcome Variable 1 (left) is at the school level
                      while that of Explanatory Variable 1 (right) is the district average indicator."))
                  
        ),
        tabPanel("Regression Output", 
                 p(h2("Regressions")),
                 p(h4("Model Specification")),
                 p(h5("All models include clustering standard errors at the district level (g2), with std. errors
                      specified to those used by default in Stata")),
                 p(),
                 p(h3("All Countries")),
                 p(h4("Regression")),
                 verbatimTextOutput('reg'),
                 p(h4("N Observations")),
                 verbatimTextOutput('reg_n'),
                 p(h3("Jordan")),
                 verbatimTextOutput('reg.jor'),
                 p(h4("N Observations: Jordan")),
                 verbatimTextOutput('reg_n.jor'),
                 p(h3("Mozambique")),
                 verbatimTextOutput('reg.moz'),
                 p(h4("N Observations: Mozambique")),
                 verbatimTextOutput('reg_n.moz'),
                 p(h3("Peru")),
                 verbatimTextOutput('reg.per'),
                 p(h4("N Observations: Peru")),
                 verbatimTextOutput('reg_n.per'),
                 p(h3("Rwanda")),
                 verbatimTextOutput('reg.rwa'),
                 p(h4("N Observations: Rwanda")),
                 verbatimTextOutput('reg_n.rwa')
                 
        )
      )
    )
   )
  )


# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  
   # Regression output
   ## Overall
    output$reg <- renderPrint({
      fit <- lm_robust(
                formula = reformulate(input$lmin1,input$lmout1) ,
                clusters = g2, se_type = "stata", 
                data = md)
      
      summary(fit)
    })
    
  
    output$reg_n <- renderPrint({
      fit <- lm_robust(
        formula = reformulate(input$lmin1,input$lmout1) ,
        clusters = g2, se_type = "stata", 
        data = md)
      
      fit$nobs
    })
    
    ## Peru
    output$reg.per <- renderPrint({
      fit.per <- lm_robust(
        formula = reformulate(input$lmin1,input$lmout1) ,
        clusters = g2, se_type = "stata", 
        data = md.per)
      
      summary(fit.per)
    })
    
    output$reg_n.per <- renderPrint({
      fit.per <- lm_robust(
        formula = reformulate(input$lmin1,input$lmout1) ,
        clusters = g2, se_type = "stata", 
        data = md.per)
      
      fit.per$nobs
    })
  
    
    
    ## Jordan
    output$reg.jor <- renderPrint({
      fit.jor <- lm_robust(
        formula = reformulate(input$lmin1,input$lmout1) ,
        clusters = g2, se_type = "stata", 
        data = md.jor)
      
      summary(fit.jor)
    })
    
    output$reg_n.jor <- renderPrint({
      fit.jor <- lm_robust(
        formula = reformulate(input$lmin1,input$lmout1) ,
        clusters = g2, se_type = "stata", 
        data = md.jor)
      
      fit.jor$nobs
    })
    
    
    
    
    ## Rwanda
    output$reg.rwa <- renderPrint({
      fit.rwa <- lm_robust(
        formula = reformulate(input$lmin1,input$lmout1) ,
        clusters = g2, se_type = "stata", 
        data = md.rwa)
      
      summary(fit.rwa)
    })
    
    output$reg_n.rwa <- renderPrint({
      fit.rwa <- lm_robust(
        formula = reformulate(input$lmin1,input$lmout1) ,
        clusters = g2, se_type = "stata", 
        data = md.rwa)
      
      fit.rwa$nobs
    })
    
    
    ## Mozambique
    output$reg.moz <- renderPrint({
      fit.moz <- lm_robust(
        formula = reformulate(input$lmin1,input$lmout1) ,
        clusters = g2, se_type = "stata", 
        data = md.moz)
      
      summary(fit.moz)
    })
    
    output$reg_n.moz <- renderPrint({
      fit.moz <- lm_robust(
        formula = reformulate(input$lmin1,input$lmout1) ,
        clusters = g2, se_type = "stata", 
        data = md.moz)
      
      fit.moz$nobs
    })
    
    
    
    
    
    
  
    
    
    # hide actions 
    ## Peru
    observeEvent(input$per, {
     toggle("reg.per", anim = TRUE, time = 0.4)
     toggle("reg_n.per", anim = TRUE, time = 0.4)
    })
    
    ## Jordan
    observeEvent(input$jor, {
      toggle("reg.jor", anim = TRUE, time = 0.4)
      toggle("reg_n.jor", anim = TRUE, time = 0.4)
    })
    
    ## Mozambique
    observeEvent(input$moz, {
      toggle("reg.moz", anim = TRUE, time = 0.4)
      toggle("reg_n.moz", anim = TRUE, time = 0.4)
    })
    
    ## Rwanda
    observeEvent(input$rwa, {
      toggle("reg.rwa", anim = TRUE, time = 0.4)
      toggle("reg_n.rwa", anim = TRUE, time = 0.4)
    })
    
    ## All
    observeEvent(input$all, {
      toggle("reg", anim = TRUE, time = 0.4)
      toggle("reg_n", anim = TRUE, time = 0.4)
    })
    
    
    
    
    
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

