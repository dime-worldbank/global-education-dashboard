
library(shiny)
library(shinyjs)
library(tidyverse)
library(estimatr)
library(sjPlot)
library(plotly)
library(RColorBrewer)
library(markdown)

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
md <- readRDS(file = "final-by-district2.Rda") 

# create by-country objects
md.per <- md %>% 
  filter(countryname == "Peru")

md.jor <- md %>% 
  filter(countryname == "Jordan")

md.rwa <- md %>% 
  filter(countryname == "Rwanda")

md.moz <- md %>% 
  filter(countryname == "Mozambique")


# colorscales 

cs.pval <- brewer.pal(5, "Purples")
cs.coef <- brewer.pal(7, "PRGn")
cs.se   <- brewer.pal(7, "PRGn")



# hover text 
ht.p <- paste('School Outcome: %{y}<br>',
            'BI: %{x}<br>',
            '<b>p-val: %{z:.3f} </b>')
ht.coef <- paste('School Outcome: %{y}<br>',
              'BI: %{x}<br>',
              '<b>Coef: %{z:.2f} </b><br>')
ht.se <- paste('School Outcome: %{y}<br>',
              'BI: %{x}<br>',
              '<b>Std.Err: %{z:.3f} </b>')




# Define UI  -------
ui <- fluidPage(
  
  useShinyjs(),
   
   # Application title
   titlePanel("GECD Regression Explorer"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
        p(h3("Plot Input Selector")),
        
        width = 3,
        
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
        helpText("Outcome Variable selector is not valid for the Heatmap as all iterations have been mapped"),
        
        
        
        # Explanatory Vars
        selectInput("lmin1", #inputid
                    "BI Variables", #label
                    choices = c("Bureaucracy Index" = "bi",
                                "National Learning Goals" = "national_learning_goals",
                                "Mandates and Accountability" = "mandates_accountability",
                                "Quality of Bureaucracy" = "quality_bureaucracy",
                                "Impartial Decision-Making" = "impartial_decision_making"
                                ),
                    multiple = FALSE,
                    selected = c("bi")
       ),
       
       checkboxGroupInput("lmin2", #inputid
                          "Explanatory Variables", #label
                          choices = c("Literacy Rate" = "pct_lit",
                                      "% Urban" = "pct_urban",
                                      "% Houses Electrified" = "pct_elec",
                                      "% Houses Improved Dwelling" = "pct_dwell",
                                      "% Schoolage" = "pct_schoolage",
                                      "School Size" = "as.factor(enrolled)",
                                      #"Country FE" = "as.factor(countryname)",
                                      "Log GDP" = "ln_gdp",
                                      "Log District Enrollment" = "ln_dist_n_stud"
                          ),
                          selected = c("bi")
       ),
       
       checkboxGroupInput('lmin3',
                          "Country Fixed Effects",
                    choices = c("Country FE" = "as.factor(countryname)")
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
                 
        ),
        
        
        tabPanel("Heatmap",
                 tags$h2("Multi-Dimensional Heatmap"), 
                 tags$h5("Note that the scale displays more favorable colors as darker."),
                 plotlyOutput('heatmap1'),
                 plotlyOutput('heatmap2'),
                 plotlyOutput('heatmap3')
                 
                 ),
        
        tabPanel("Notes",
                 includeMarkdown("notes.md") # %% fix this tomorrow
                 
                 
                 
            )
        
      )
    )
   )
  )


# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  
  
  
  
  
  
  
  # reactive objects ----
  # all.tidy.sk <- reactive({
  #   tidy(fit.sk())
  # })
    ## input vars
    rhs <- reactive({
      c(input$lmin1, input$lmin2, input$lmin3)
    })
    
    # this version does not include country fixed effects
    rhs2 <- reactive({
      c(input$lmin1, input$lmin2)
    })
    
    bivar <- reactive({input$lmin1})

    
    ## equations: Student Knowledge ----
    fit.sk <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("student_knowledge ~ ", paste(rhs(), collapse="+"))) , # input$lmout1 gets changed to one of 10 outcome vars
        clusters = g2, se_type = "stata", 
        data = md)) %>%
        filter( term == bivar()) %>%
        mutate(country = "ALL") })

    fit.per.sk <- reactive({
      tidy(lm_robust(
      formula = as.formula(paste("student_knowledge ~ ", paste(rhs2(), collapse="+"))) ,
      clusters = g2, se_type = "stata",
      data = md.per)) %>%
        filter( term == bivar()) %>%
        mutate(country = "PER") })

    fit.jor.sk <- reactive({
      tidy(lm_robust(
      formula = as.formula(paste("student_knowledge ~ ", paste(rhs2(), collapse="+"))) ,
      clusters = g2, se_type = "stata",
      data = md.jor)) %>%
        filter( term == bivar()) %>%
        mutate(country = "JOR") })

    fit.rwa.sk <- reactive({
      tidy(lm_robust(
      formula = as.formula(paste("student_knowledge ~ ", paste(rhs2(), collapse="+"))),
      clusters = g2, se_type = "stata",
      data = md.rwa)) %>%
        filter( term == bivar()) %>%
        mutate(country = "RWA") })

  
    
    ## equations: ECD Student Knowledge ----
    fit.ecd <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("ecd_student_knowledge ~ ", paste(rhs(), collapse="+"))) , # input$lmout1 gets changed to one of 10 outcome vars
        clusters = g2, se_type = "stata", 
        data = md)) %>%
        filter( term == bivar()) %>%
        mutate(country = "ALL") })
    
    fit.per.ecd <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("ecd_student_knowledge ~ ", paste(rhs2(), collapse="+"))) ,
        clusters = g2, se_type = "stata",
        data = md.per)) %>%
        filter( term == bivar()) %>%
        mutate(country = "PER") })
    
    fit.jor.ecd <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("ecd_student_knowledge ~ ", paste(rhs2(), collapse="+"))) ,
        clusters = g2, se_type = "stata",
        data = md.jor)) %>%
        filter( term == bivar()) %>%
        mutate(country = "JOR") })
    
    fit.rwa.ecd <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("ecd_student_knowledge ~ ", paste(rhs2(), collapse="+"))),
        clusters = g2, se_type = "stata",
        data = md.rwa)) %>%
        filter( term == bivar()) %>%
        mutate(country = "RWA") })
    
    # fit.moz.ecd <- reactive({
    #   tidy(lm_robust(
    #     formula = as.formula(paste("ecd_student_knowledge ~ ", paste(rhs2(), collapse="+"))),
    #     clusters = g2, se_type = "stata",
    #     data = md.moz)) %>%
    #     filter( term == bivar()) %>%
    #     mutate(country = "MOZ") })
    
    
    ## equations: Inputs ----
    fit.in <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("inputs ~ ", paste(rhs(), collapse="+"))) , # input$lmout1 gets changed to one of 10 outcome vars
        clusters = g2, se_type = "stata", 
        data = md)) %>%
        filter( term == bivar()) %>%
        mutate(country = "ALL") })
    
    fit.per.in <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("inputs ~ ", paste(rhs2(), collapse="+"))) ,
        clusters = g2, se_type = "stata",
        data = md.per)) %>%
        filter( term == bivar()) %>%
        mutate(country = "PER") })
    
    fit.jor.in <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("inputs ~ ", paste(rhs2(), collapse="+"))) ,
        clusters = g2, se_type = "stata",
        data = md.jor)) %>%
        filter( term == bivar()) %>%
        mutate(country = "JOR") })
    
    fit.rwa.in <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("inputs ~ ", paste(rhs2(), collapse="+"))),
        clusters = g2, se_type = "stata",
        data = md.rwa)) %>%
        filter( term == bivar()) %>%
        mutate(country = "RWA") })
    
    # fit.moz.in <- reactive({
    #   tidy(lm_robust(
    #     formula = as.formula(paste("inputs ~ ", paste(rhs2(), collapse="+"))),
    #     clusters = g2, se_type = "stata",
    #     data = md.moz)) %>%
    #     filter( term == bivar()) %>%
    #     mutate(country = "MOZ") })
    
    
    ## equations: infrastructure ----
    fit.fr <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("infrastructure ~ ", paste(rhs(), collapse="+"))) , # input$lmout1 gets changed to one of 10 outcome vars
        clusters = g2, se_type = "stata", 
        data = md)) %>%
        filter( term == bivar()) %>%
        mutate(country = "ALL") })
    
    fit.per.fr <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("infrastructure ~ ", paste(rhs2(), collapse="+"))) ,
        clusters = g2, se_type = "stata",
        data = md.per)) %>%
        filter( term == bivar()) %>%
        mutate(country = "PER") })
    
    fit.jor.fr <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("infrastructure ~ ", paste(rhs2(), collapse="+"))) ,
        clusters = g2, se_type = "stata",
        data = md.jor)) %>%
        filter( term == bivar()) %>%
        mutate(country = "JOR") })
    
    fit.rwa.fr <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("infrastructure ~ ", paste(rhs2(), collapse="+"))),
        clusters = g2, se_type = "stata",
        data = md.rwa)) %>%
        filter( term == bivar()) %>%
        mutate(country = "RWA") })
    
    # fit.moz.fr <- reactive({
    #   tidy(lm_robust(
    #     formula = as.formula(paste("infrastructure ~ ", paste(rhs2(), collapse="+"))),
    #     clusters = g2, se_type = "stata",
    #     data = md.moz)) %>%
    #     filter( term == bivar()) %>%
    #     mutate(country = "MOZ") })
    
    
    ## equations: Intrinsic Motivation ----
    fit.mot <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("intrinsic_motivation ~ ", paste(rhs(), collapse="+"))) , # input$lmout1 gets changed to one of 10 outcome vars
        clusters = g2, se_type = "stata", 
        data = md)) %>%
        filter( term == bivar()) %>%
        mutate(country = "ALL") })
    
    fit.per.mot <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("intrinsic_motivation ~ ", paste(rhs2(), collapse="+"))) ,
        clusters = g2, se_type = "stata",
        data = md.per)) %>%
        filter( term == bivar()) %>%
        mutate(country = "PER") })
    
    fit.jor.mot <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("intrinsic_motivation ~ ", paste(rhs2(), collapse="+"))) ,
        clusters = g2, se_type = "stata",
        data = md.jor)) %>%
        filter( term == bivar()) %>%
        mutate(country = "JOR") })
    
    fit.rwa.mot <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("intrinsic_motivation ~ ", paste(rhs2(), collapse="+"))),
        clusters = g2, se_type = "stata",
        data = md.rwa)) %>%
        filter( term == bivar()) %>%
        mutate(country = "RWA") })
    
    # fit.moz.mot <- reactive({
    #   tidy(lm_robust(
    #     formula = as.formula(paste("intrinsic_motivation ~ ", paste(rhs2(), collapse="+"))),
    #     clusters = g2, se_type = "stata",
    #     data = md.moz)) %>%
    #     filter( term == bivar()) %>%
    #     mutate(country = "MOZ") })
    
    
    ## equations: Content Knowledge ----
    fit.cnk <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("content_knowledge ~ ", paste(rhs(), collapse="+"))) , # input$lmout1 gets changed to one of 10 outcome vars
        clusters = g2, se_type = "stata", 
        data = md)) %>%
        filter( term == bivar()) %>%
        mutate(country = "ALL") })
    
    fit.per.cnk <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("content_knowledge ~ ", paste(rhs2(), collapse="+"))) ,
        clusters = g2, se_type = "stata",
        data = md.per)) %>%
        filter( term == bivar()) %>%
        mutate(country = "PER") })
    
    fit.jor.cnk <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("content_knowledge ~ ", paste(rhs2(), collapse="+"))) ,
        clusters = g2, se_type = "stata",
        data = md.jor)) %>%
        filter( term == bivar()) %>%
        mutate(country = "JOR") })
    
    fit.rwa.cnk <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("content_knowledge ~ ", paste(rhs2(), collapse="+"))),
        clusters = g2, se_type = "stata",
        data = md.rwa)) %>%
        filter( term == bivar()) %>%
        mutate(country = "RWA") })
    
    # fit.moz.cnk <- reactive({
    #   tidy(lm_robust(
    #     formula = as.formula(paste("content_knowledge ~ ", paste(rhs2(), collapse="+"))),
    #     clusters = g2, se_type = "stata",
    #     data = md.moz)) %>%
    #     filter( term == bivar()) %>%
    #     mutate(country = "MOZ") })
    
    
    
    ## equations: Operational Management ----
    fit.om <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("operational_manage ~ ", paste(rhs(), collapse="+"))) , # input$lmout1 gets changed to one of 10 outcome vars
        clusters = g2, se_type = "stata", 
        data = md)) %>%
        filter( term == bivar()) %>%
        mutate(country = "ALL") })
    
    fit.per.om <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("operational_manage ~ ", paste(rhs2(), collapse="+"))) ,
        clusters = g2, se_type = "stata",
        data = md.per)) %>%
        filter( term == bivar()) %>%
        mutate(country = "PER") })
    
    fit.jor.om <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("operational_manage ~ ", paste(rhs2(), collapse="+"))) ,
        clusters = g2, se_type = "stata",
        data = md.jor)) %>%
        filter( term == bivar()) %>%
        mutate(country = "JOR") })
    
    fit.rwa.om <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("operational_manage ~ ", paste(rhs2(), collapse="+"))),
        clusters = g2, se_type = "stata",
        data = md.rwa)) %>%
        filter( term == bivar()) %>%
        mutate(country = "RWA") })
    
    # fit.moz.om <- reactive({
    #   tidy(lm_robust(
    #     formula = as.formula(paste("operational_manage ~ ", paste(rhs2(), collapse="+"))),
    #     clusters = g2, se_type = "stata",
    #     data = md.moz)) %>%
    #     filter( term == bivar()) %>%
    #     mutate(country = "MOZ") })
    
  
    ## equations: Intructional Leadership ----
    fit.il <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("instr_leader ~ ", paste(rhs(), collapse="+"))) , # input$lmout1 gets changed to one of 10 outcome vars
        clusters = g2, se_type = "stata", 
        data = md)) %>%
        filter( term == bivar()) %>%
        mutate(country = "ALL") })
    
    fit.per.il <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("instr_leader ~ ", paste(rhs2(), collapse="+"))) ,
        clusters = g2, se_type = "stata",
        data = md.per)) %>%
        filter( term == bivar()) %>%
        mutate(country = "PER") })
    
    fit.jor.il <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("instr_leader ~ ", paste(rhs2(), collapse="+"))) ,
        clusters = g2, se_type = "stata",
        data = md.jor)) %>%
        filter( term == bivar()) %>%
        mutate(country = "JOR") })
    
    fit.rwa.il <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("instr_leader ~ ", paste(rhs2(), collapse="+"))),
        clusters = g2, se_type = "stata",
        data = md.rwa)) %>%
        filter( term == bivar()) %>%
        mutate(country = "RWA") })
    
    # fit.moz.il <- reactive({
    #   tidy(lm_robust(
    #     formula = as.formula(paste("instr_leader ~ ", paste(rhs2(), collapse="+"))),
    #     clusters = g2, se_type = "stata",
    #     data = md.moz)) %>%
    #     filter( term == bivar()) %>%
    #     mutate(country = "MOZ") })
    
    
    ## equations: Principal Knowledge Score ----
    fit.pks <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("principal_knowl_score ~ ", paste(rhs(), collapse="+"))) , # input$lmout1 gets changed to one of 10 outcome vars
        clusters = g2, se_type = "stata", 
        data = md)) %>%
        filter( term == bivar()) %>%
        mutate(country = "ALL") })
    
    fit.per.pks <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("principal_knowl_score ~ ", paste(rhs2(), collapse="+"))) ,
        clusters = g2, se_type = "stata",
        data = md.per)) %>%
        filter( term == bivar()) %>%
        mutate(country = "PER") })
    
    fit.jor.pks <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("principal_knowl_score ~ ", paste(rhs2(), collapse="+"))) ,
        clusters = g2, se_type = "stata",
        data = md.jor)) %>%
        filter( term == bivar()) %>%
        mutate(country = "JOR") })
    
    fit.rwa.pks <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("principal_knowl_score ~ ", paste(rhs2(), collapse="+"))),
        clusters = g2, se_type = "stata",
        data = md.rwa)) %>%
        filter( term == bivar()) %>%
        mutate(country = "RWA") })
    
    # fit.moz.pks <- reactive({
    #   tidy(lm_robust(
    #     formula = as.formula(paste("principal_knowl_score ~ ", paste(rhs2(), collapse="+"))),
    #     clusters = g2, se_type = "stata",
    #     data = md.moz)) %>%
    #     filter( term == bivar()) %>%
    #     mutate(country = "MOZ") })
    
    
    ## equations: Principal Management ----
    fit.pm <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("principal_manage ~ ", paste(rhs(), collapse="+"))) , # input$lmout1 gets changed to one of 10 outcome vars
        clusters = g2, se_type = "stata", 
        data = md)) %>%
        filter( term == bivar()) %>%
        mutate(country = "ALL") })
    
    fit.per.pm <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("principal_manage ~ ", paste(rhs2(), collapse="+"))) ,
        clusters = g2, se_type = "stata",
        data = md.per)) %>%
        filter( term == bivar()) %>%
        mutate(country = "PER") })
    
    fit.jor.pm <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("principal_manage ~ ", paste(rhs2(), collapse="+"))) ,
        clusters = g2, se_type = "stata",
        data = md.jor)) %>%
        filter( term == bivar()) %>%
        mutate(country = "JOR") })
    
    fit.rwa.pm <- reactive({
      tidy(lm_robust(
        formula = as.formula(paste("principal_manage ~ ", paste(rhs2(), collapse="+"))),
        clusters = g2, se_type = "stata",
        data = md.rwa)) %>%
        filter( term == bivar()) %>%
        mutate(country = "RWA") })
    
  
      # append 
      data <- reactive({as.data.frame(bind_rows(
        fit.sk(), fit.per.sk(), fit.jor.sk(), fit.rwa.sk(), 
        fit.ecd(), fit.per.ecd(), fit.jor.ecd(), fit.rwa.ecd(), 
        fit.in(), fit.per.in(), fit.jor.in(), fit.rwa.in(), 
        fit.fr(), fit.per.fr(), fit.jor.fr(), fit.rwa.fr(), 
        fit.mot(), fit.per.mot(), fit.jor.mot(), fit.rwa.mot(), 
        fit.cnk(), fit.per.cnk(), fit.jor.cnk(), fit.rwa.cnk(), 
        fit.om(), fit.per.om(), fit.jor.om(), fit.rwa.om(), 
        fit.il(), fit.per.il(), fit.jor.il(), fit.rwa.il(), 
        fit.pks(), fit.per.pks(), fit.jor.pks(), fit.rwa.pks(), 
        fit.pm(), fit.per.pm(), fit.jor.pm(), fit.rwa.pm()
        ))

      
    })
      
    
    
  
   # Regression output ----
   ## Overall
      fit <- reactive({lm_robust(
        formula = reformulate(rhs(),input$lmout1) ,
        clusters = g2, se_type = "stata",
        data = md)})
      
    output$reg <- renderPrint({

      summary(fit())
    })
    
  
    output$reg_n <- renderPrint({

      
      
      paste0("Obs N = ", fit()$nobs, "   Clusters N = ", fit()$nclusters)
      
    })
    
    # ## Peru
    fit.per <- reactive({lm_robust(
      formula = reformulate(rhs2(),input$lmout1) ,
      clusters = g2, se_type = "stata",
      data = md.per)})
    
    
    output$reg.per <- renderPrint({ summary(fit.per()) })

    output$reg_n.per <- renderPrint({  
      paste0("Obs N = ", fit.per()$nobs, "   Clusters N = ", fit.per()$nclusters)
      
      })



    # ## Jordan
    fit.jor <- reactive({lm_robust(
      formula = reformulate(rhs2(),input$lmout1) ,
      clusters = g2, se_type = "stata",
      data = md.jor)})
    
    output$reg.jor <- renderPrint({

      summary(fit.jor())
    })

    output$reg_n.jor <- renderPrint({
      paste0("Obs N = ", fit.jor()$nobs, "   Clusters N = ", fit.jor()$nclusters)
    })




    ## Rwanda
    fit.rwa <- reactive({lm_robust(
      formula = reformulate(rhs2(),input$lmout1) ,
      clusters = g2, se_type = "stata",
      data = md.rwa)})
    
    output$reg.rwa <- renderPrint({
      summary(fit.rwa())
    })

    output$reg_n.rwa <- renderPrint({
      paste0("Obs N = ", fit.rwa()$nobs, "   Clusters N = ", fit.rwa()$nclusters)
    })


    ## Mozambique
    fit.moz <- reactive({lm_robust(
      formula = reformulate(rhs2(),input$lmout1) ,
      clusters = g2, se_type = "stata",
      data = md.moz)})
    
    output$reg.moz <- renderPrint({
      summary(fit.moz())
    })

    output$reg_n.moz <- renderPrint({
      paste0("Obs N = ", fit.moz()$nobs, "   Clusters N = ", fit.moz()$nclusters)
    })
    
    
    
    # regression heatmap ----
    
    
    output$heatmap1 <- renderPlotly(
      plot_ly(
        data = data(),
        type = 'heatmap',
        #colorscale = cs.pval,
        y = ~outcome, # all the school vars
        x = ~country,
        z = ~p.value, # this is reactive
        zauto = FALSE,
        zmin = 0, 
        zmax = 1,
        zmid = 0.1,
        hovertemplate = ht.p,
        hoverlabel = list(
          namelength = 0
        )
      ) %>%
        layout(
          title = list(
            text = "P-Value",
            size = 12
          ),
          yaxis = list(
            title = list(
              text = ""
            )
          ),
          xaxis = list(
            title = list(
              text = ""
            )
          )
        )
    )
      
      
    output$heatmap2 <- renderPlotly(
      plot_ly(
        data = data(),
        type = 'heatmap',
        #colorscale = cs.coef,
        reversescale = TRUE,
        zauto = FALSE,
        zmin = -1, 
        zmax = 1,
        zmid = 0,
        hovertemplate = ht.coef,
        hoverlabel = list(
          namelength = 0
        ),
        y = ~outcome, # all the school vars
        x = ~country,
        z = ~estimate # this is reactive
      ) %>%
        layout(
          title = list(
            text = "Coefficients",
            size = 12
          ),
          yaxis = list(
            title = list(
              text = ""
            )
          ),
          xaxis = list(
            title = list(
              text = ""
            )
          )
        )
    )
      
    output$heatmap3 <- renderPlotly(
      plot_ly(
        data = data(),
        type = 'heatmap',
        #colorscale = cs.se,
        zauto = FALSE,
        zmin = 0, 
        zmax = 1,
        zmid = 0.25,
        hovertemplate = ht.se,
        hoverlabel = list(
          namelength = 0
        ),
        y = ~outcome, # all the school vars
        x = ~country,
        z = ~std.error # this is reactive
      )%>%
        layout(
          title = list(
            text = "Std. Error",
            size = 12
          ),
          yaxis = list(
            title = list(
              text = ""
            )
          ),
          xaxis = list(
            title = list(
              text = ""
            )
          )
        )
    )
      
  
    
    
    
    
    
    
    
    
  
    
    
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


# https://stackoverflow.com/questions/43217170/creating-a-reactive-dataframe-with-shiny-apps
