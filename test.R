library(tidyverse)
library(svMisc) # for the progress bar
library(magrittr) # for the %<>% 

setwd("~/OneDrive - Imperial College London/Projects/OUTBREAKER2/GROUP")

source("simulate.R")
source("generate_clusters.R")
source("generate_group_data.R")
source("generate_new_coordinates.R")


# Input data:
groups_df <- generate_group_data(
  name = c("A", "B", "C"),
  n = c(10, 50, 100),
  lambda = c(1, 2, 3),
  p_transmission = c(0.1, 0.2, 0.35),
  move_to = list(c("A", "B", "C"), c("B", "C"), c("A", "C")),
  move_prob = list(c(0.7, 0.1, 0.2), c(0.8, 0.2), c(0.5, 0.5))
)
groups_df


# Simulation:
set.seed(123)
sim <- simulate(groups_df = groups_df,
                 intro_group = "B",
                 duration = 30)
sim

View(sim$stats)




library(plotly)
Noax <- list(
  title = "",
  zeroline = FALSE,
  showline = FALSE,
  showticklabels = FALSE,
  showgrid = FALSE
)

sim$data %>%
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
              text = paste("Group:", sim$data$group, "<br>",
                           "ID:", sim$data$id, "<br>",
                           "Contacts:", sim$data$contacts,"<br>")
  ) %>% 
  plotly::layout(showlegend = F,
                 title='Simulation',
                 xaxis = Noax,
                 yaxis = Noax,
                 plot_bgcolor='#2d3436',
                 paper_bgcolor = '#2d3436',
                 font = list(color = '#ffffff')) %>% 
  animation_opts(1000, redraw = FALSE)



# gganimate:
# library(gganimate)
# ggplot(sim$data,
#        aes(
#          x,
#          y,
#          shape = group,
#          color = as.factor(infected),
#          group = seq_along(date)
#        )) +
#   geom_point(size = 2, alpha = 0.7) +
#   coord_fixed() +
#   theme_void() +
#   scale_color_manual(values = c("black", "red")) +
#   guides(color = "none") +
#   labs(title = 'Day: {round(frame_time)}', x = '', y = '') +
#   transition_time(day) +
#   ease_aes('linear')
