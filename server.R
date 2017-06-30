# Title: Calibrating XGBOOST
# Author: Maximilian Eber
# Date: 30 April 2017

# Load libraries
library(dplyr)
library(ggplot2)
library(xgboost)

# One-off calculations
# - function for data generation
y_fun <- function(x){
  (x < 0)*(.5*x^3 + 3*x - 2) +
    (x > 1 )*3 + (x > 1.5)*(-5*x)
}

# - data for plotting y_fun
df_y <- data_frame(
  x = seq(-3, 3, by = .01),
  y = y_fun(seq(-3, 3, by = .01)))

# Server calculations
# - simulate data
# - run model
# - visualize partial dependency
# - plot loss function
# - get kpis

shinyServer(function(input, output) {

  # Simulate Data
  sim <- reactive({
    # Create data
    x <- rnorm(input$n_sample) # signal
    eps1 <- rnorm(input$n_sample)  # noise
    eps2 <- rnorm(input$n_sample)  # noise
    y <- y_fun(x + .1*eps1) + 2*eps2 # outcome
    train_id <- sample(
      x = c(TRUE, FALSE),
      prob = c(.8, .2),
      replace = TRUE,
      size = input$n_sample)

    # Format for later use
    df_all <- data_frame(x, y, train_id)
    xgb_train <- xgb.DMatrix(
      data = df_all[train_id,"x"] %>% as.matrix(),
      label = df_all[train_id, ][["y"]])
    xgb_test <- xgb.DMatrix(
      data = df_all[!train_id,"x"] %>% as.matrix(),
      label = df_all[!train_id,][["y"]])

    list(df_all = df_all, xgb_train = xgb_train, xgb_test = xgb_test)
  })

  # Parameters for model training
  params <- reactive({
    list(gamma = input$gamma,
         min_child_weight = input$min_child_weight,
         nrounds = input$nrounds,
         early_stopping = input$early_stopping,
         eta = input$eta,
         max_depth = input$max_depth)
  })

  # Estimate model
  xgb_trained <- reactive({
    xgb.train(
      data = sim()[["xgb_train"]],
      watchlist = list(
        "train" = sim()[["xgb_train"]],
        "test" = sim()[["xgb_test"]]),
      nrounds = params()[["nrounds"]],
      early_stopping_rounds = params()[["early_stopping"]],
      eta = params()[["eta"]],
      gamma = params()[["gamma"]],
      max_depth = params()[["max_depth"]],
      min_child_weight = params()[["min_child_weight"]],
      save_period = NULL)
  })

  # Partial dependency plot
  output$partial_dep <- renderPlot({
    data_frame(
      pred = predict(object = xgb_trained(),
                     newdata = df_y$x %>% as.matrix()),
      grid = df_y$x) %>%
      ggplot() +
      # Simulated observations
      geom_point(data = sim()[["df_all"]], aes(x = x, y = y), alpha = .4, size = .5, color = "black") +
      # Predicted values
      geom_line(aes(x = grid, y = pred, color = "Model"), size = 1) +
      coord_cartesian(ylim = c(-8, 5)) +
      # The function itself
      geom_line(data = df_y, aes(x = x, y = y, color = "Truth"), size = 1) +

      # Formatting
      coord_cartesian(xlim = c(-2, 2), ylim = c(-8, 5)) +
      theme_bw() +
      guides(linetype = "none") +
      labs(x = "Input", y = "Prediction/Actual", color = NULL) +
      theme(legend.position = "top") +
      scale_color_manual(values = c("red", "#337ab7"), breaks = c("Model", "Truth"))
  })

  # Plot loss function
  output$loss <- renderPlot({
    ggplot(data = xgb_trained()[["evaluation_log"]], aes(x = iter)) +
      geom_line(aes(color = "Test", y = test_rmse), size = 1) +
      geom_line(aes(color = "Train", y = train_rmse), size = 1) +
      geom_vline(xintercept = xgb_trained()[["best_iteration"]], linetype = 2) +
      theme_bw() +
      scale_color_manual(values = c("red", "#337ab7"), breaks = c("Test", "Train")) +
      labs(x = "Boosting Iteration", y = "RMSE", color = NULL) +
      theme(legend.position = "top")
  })

  # Table with numeric scores
  output$score <- renderTable({
    xgb_trained()[["evaluation_log"]][1:xgb_trained()[["best_iteration"]],] %>% arrange(-iter)
    })
})
