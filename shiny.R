library(shiny)
library(shinythemes)
library(plotly)
library(tidyverse) # for dplyr functions
library(magrittr) # for the %<>% (looks cool)
linebreaks <- function(n){HTML(strrep(br(), n))}


ui <- fluidPage(
  theme = shinytheme('slate'),
  
  shinyWidgets::progressBar(
    id = "sim_progress",
    value = 0,
    total = 100,
    display_pct = TRUE
  ),
  
  sidebarLayout(
    sidebarPanel(
      textInput("name", "Group names (separate by ',')", "A, B, C"),
      textInput("n", "Group sizes (separate by ',')", "50, 100, 150"),
      textInput("lambda", "Group contact rate (separate by ',')", "1, 2, 3"),
      textInput(
        "p_transmission",
        "Group transmission rate (separate by ',')",
        "0.1, 0.3, 0.5"
      ),
      textInput(
        "move_to",
        "Move to groups (separate groups by ';')",
        "A,B,C; B,C; A,C"
      ),
      textInput(
        "move_prob",
        "Move to group probability (separate groups by ';')",
        "0.5,0.2,0.3; 0.8,0.2; 0.7,0.3"
      ),
      textInput("intro_group", "Introduce the pathogen to a group", "B"),
      sliderInput(
        "duration",
        "Duration (in days):",
        min = 1,
        max = 100,
        value = 15
      ),
      actionButton("run", "Run simulation"),
      downloadButton('downloadData', 'Download Data'),
      downloadButton('downloadStats', 'Download Stats')
    ),
    mainPanel(linebreaks(2),
              plotlyOutput("animation", height = "80vh"))
  ),
  
  # Description
  #   markdown(
  #     "This app simulates the spread of an infection within and between groups over a specified number of days. The function takes the following inputs
  #
  # -   **`name`**: the groups' name.
  # -   **`n`**: the group's sizes.
  # -   **`lambda`**: the within group contact rate measured as the average number of contacts per individual.
  # -   **`p_transmission`**: within-group transmission probability.
  # -    **`move_to`**: between group movement allocation .
  # -   **`move_prob`**: movement probability.
  # -   **`intro_group`**: the name of the group where the initial infected individual is introduced.
  # -   **`duration`**: the number of days for which the simulation runs."
  #   )
  
  
  
)


server <- function(input, output) {
  
  source("simulate_shiny.R")
  source("generate_clusters.R")
  source("generate_group_data.R")
  source("generate_new_coordinates.R")
  
  #Generate data
  groups_df <- eventReactive(input$run, {
    generate_group_data(
      name = gsub(" ", "", input$name) %>% strsplit(",") %>% unlist(),
      n = gsub(" ", "", input$n) %>% strsplit(",") %>% unlist() %>% as.numeric(),
      lambda = gsub(" ", "", input$lambda) %>% strsplit(",") %>% unlist() %>% as.numeric(),
      p_transmission =  gsub(" ", "", input$p_transmission) %>% strsplit(",") %>% unlist() %>% as.numeric(),
      move_to = gsub(" ", "", input$move_to) %>% strsplit(";") %>% unlist() %>% strsplit(","),
      move_prob = gsub(" ", "", input$move_prob) %>% strsplit(";") %>% unlist() %>% strsplit(",") %>% lapply(as.numeric) 
      )
  })
  
  
  #Simulate
  
  
  set.seed(123)
  sim <- reactive({
    
    simulate(groups_df = groups_df(),
             intro_group = input$intro_group,
             duration = input$duration)
  })
  
  
  
  #Plot
  Noax <- list(
    title = "",
    zeroline = FALSE,
    showline = FALSE,
    showticklabels = FALSE,
    showgrid = FALSE
  )
  output$animation <- renderPlotly({
    sim()$data %>% 
      plot_ly(
        x = ~ x,
        y = ~ y
      ) %>% 
      add_markers(frame = ~ day, 
                  color = ~as.factor(infected), 
                  colors = c("gray", "red"),
                  opacity = 0.9,
                  size = 2,
                  marker = list(
                    line = list(
                      color = "white",
                      width = 1)),
                  hoverinfo = "text",
                  text = paste("Group:", sim()$data$group, "<br>",
                               "ID:", sim()$data$id, "<br>",
                               "Contacts:", sim()$data$contacts,"<br>")
      ) %>% 
      plotly::layout(showlegend = F,
                     title='Simulation',
                     xaxis = Noax,
                     yaxis = Noax,
                     plot_bgcolor='#2d3436',
                     paper_bgcolor = '#2d3436',
                     font = list(color = '#ffffff')) %>% 
      animation_opts(1000, redraw = TRUE)
  })
  
  
  #Download data:
  output$downloadData <- downloadHandler(
    filename = function() { paste("data-", Sys.Date(), ".csv", sep = "") },
    content = function(file) {
      write.csv(sim()$data, file, row.names = FALSE)
    }
  )
  
  #Download Stats:
  output$downloadStats <- downloadHandler(
    filename = function() { paste("stats-", Sys.Date(), ".csv", sep = "") },
    content = function(file) {
      write.csv(sim()$stats, file, row.names = FALSE)
    }
  )
  

  
  
}

shinyApp(ui, server)
