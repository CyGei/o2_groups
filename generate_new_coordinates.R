# helper function:
# generates new coordinates for individuals that move to a different group.

generate_new_coordinates <- function(df, group, spread) {
  # Get the mean x and y coordinates of individuals in the new group
  group_mean_x <- mean(df$x[df$group == group])
  group_mean_y <- mean(df$y[df$group == group])
  
  # Generate new coordinates based on the spread of the group and the mean coordinates
  new_x <- rnorm(1, mean = group_mean_x, sd = spread)
  new_y <- rnorm(1, mean = group_mean_y, sd = spread)
  
  return(c(new_x, new_y))
}
