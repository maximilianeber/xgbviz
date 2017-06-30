shinyUI(
  ui <- fluidPage(
    # theme = "bootstrap.css",
    # Title
    titlePanel("Calibrating XGBOOST"),
    fluidRow(column(width = 1, h6("maximilian.eber@quantco.com"))),
    # Left Sidebar
    sidebarPanel(
      sliderInput(
        inputId = "gamma",
        label = "Gamma", 
        min = 0, 
        max = 1000,
        value = 0),
      sliderInput(
        inputId = "min_child_weight",
        label = "Min. Child Weight", 
        min = 0, 
        max = 100, 
        value = 0),
      sliderInput(
        inputId = "n_sample",
        label = "Sample Size", 
        min = 2, 
        max = 10000, 
        value = 1000),
      h6("Parameters"),
      sliderInput(
        inputId = "max_depth",
        label = "Max. Depth", 
        min = 1, 
        max = 25, 
        value = 6),
      numericInput(
        inputId = "nrounds",
        label = "Max. Number of Boosting Iterations", 
        value = 100,
        min = 1,
        max = 500),
      numericInput(
        inputId = "early_stopping",
        label = "Early Stopping", 
        value = 10,
        min = 1,
        max = 500),
      numericInput(
        inputId = "eta",
        label = "Learning Rate (eta)", 
        value = .3,
        min = .001,
        max = .999)#,
      # actionButton(
      #   inputId = "rerun",
      #   label = "Re-Run Model")
    ),
    # Main Panel
    mainPanel(
      tabsetPanel(
        # title = img(src = "quantco.png", width = 200, align = "right"),
        # title = "Calibrating XGBOOST",
        # position = "fixed-top",
        # inverse = TRUE,
        # tabPanel(
        #   title = "Data",
        #   plotOutput("plot_sim")),
        # tabPanel(
        #   title = "Loss Function",
        #   h6("Loss Function"),
        #   textOutput("Loss Function")#,
        #   # htmlOutput("model_summary")
        # ),
        # tabPanel(
        #   title = "Model KPIs",
        #   h6("main panel"),
        #   textOutput("selected_inputs"),
        #   htmlOutput("model_summary")
        # ),
        tabPanel(
          title = "Partial Dependency Plot",
          plotOutput("partial_dep")
        ),
        tabPanel(
          title = "Loss Function",
          plotOutput("loss")
        ),
        tabPanel(
          title = "KPIs",
          tableOutput("score")
        )
      )
    )
  )
)