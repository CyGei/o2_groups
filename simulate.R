library(tidyverse) # for dplyr functions
library(magrittr) # for the %<>% (looks cool)
library(svMisc) # for the progress bar! (looks extra cool)


simulate <- function(groups_df, intro_group, duration) {
  # Initialize data frame with initial positions of individuals in each group
  df <-
    generate_clusters(
      num_groups = nrow(groups_df),
      group_sizes = groups_df$n,
      group_names = groups_df$name,
      spread = 0.2,
      shape = "square"
    ) %>%
    bind_rows() %>%
    as_tibble() %>%
    mutate(
      id = row_number(),
      contacts = 0,
      infected = 0,
      day = 0
    )
  
  # Introduce an infected individual in one of the groups, randomly.
  intro_id <- sample(which(df$group == intro_group), 1) 
  df$infected[which(df$id == intro_id)] <- 1
  
  # Record basic statistics
  stats_df <- df %>%
    group_by(group) %>%
    summarize(
      total_people = n(),
      total_infected = sum(as.integer(infected)),
      total_contacts = sum(contacts),
      avg_contacts = mean(contacts),
      day = 0
    )
  
  temp_stats <- stats_df
  temp_df <- df
  
  #Loop through days:
  for(i in 1:duration){
    
    #progress bar
    svMisc::progress(i, max.value = duration, progress.bar = TRUE)
    
    # New day starting
    temp_df %<>% mutate(day = i)
    
    # Check if the individual will move
    for (k in 1:nrow(temp_df)) {
      move_prob <- unlist(groups_df[groups_df$name == temp_df$group[k], ]$move_prob)
      move_to <- unlist(groups_df[groups_df$name == temp_df$group[k], ]$move_to)
      new_group <- sample(move_to, size = 1, prob = move_prob)
      
      if (new_group != temp_df$group[k]) {
        # Generate new coordinates for the individual if they have moved
        new_coords <- generate_new_coordinates(df = temp_df, group = new_group, spread = 0.1)
        temp_df$x[k] <- new_coords[1]
        temp_df$y[k] <- new_coords[2]
        temp_df$group[k] <- new_group
      }
    }
        
        
    # Assign number of contacts for every id for each group
    temp_df %<>%
      group_by(id) %>%
      mutate(contacts = rpois(1, lambda = groups_df$lambda[groups_df$name == group]))
    
    
    
    # Identify the infected individuals
    infected_indices <- which(temp_df$infected == 1)

    for (j in infected_indices) {
      
      # Get the current group of the infector
      inf_group <- temp_df[j,]$group
      
      # Get the number of contacts for the infector
      n_contacts <- temp_df$contacts[j]
      
      # Draw the number of transmissions from a binomial distribution 
      # with probability p_transmission respective to the group the infector is located in
      n_transmissions <-
        rbinom(n = 1,
               size = n_contacts,
               prob = groups_df[groups_df$name == inf_group, ]$p_transmission)
      
      #identify IDs from the same group of the infector
      possible_ids <- setdiff(temp_df[temp_df$group == inf_group,]$id, temp_df[j,]$id)
      
      #sample the possible IDs n_transmission durations
      temp_id <-  sample(possible_ids, n_transmissions)

      # Update the infected status for n(contacts) of the infector
      temp_df$infected[temp_df$id %in% temp_id] <- 1 #here this is a bit silly because we might assign 1 to a contact that was already one but I doubt a if statement will save speed
      
      
    }
    #bind to temp_df to df
    df <- rbind(df, temp_df)
    
    #get stats for day i (temp_df)
    temp_stats <- temp_df %>%
      group_by(group) %>%
      summarize(
        total_people = n(),
        total_infected = sum(as.integer(infected)),
        total_contacts = sum(contacts),
        avg_contacts = mean(contacts),
        day = i
      )
    stats_df <- rbind(stats_df, temp_stats)
    
  }
  
  return(list(data = df, stats = stats_df))
}
  
