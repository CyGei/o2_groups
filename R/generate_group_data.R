generate_group_data <- function(name, n, lambda, p_transmission, move_to, move_prob){
  tibble(name = name, # a character vector
         n = n, # an integer vector
         lambda = lambda, # an integer vector
         p_transmission = p_transmission, # a numeric vector
         move_to = move_to, # a list containing character vectors
         move_prob = move_prob, # a list containing character vectors
  )
}

# generate_group_data(
#   name = c("A", "B", "C"), #creating 3 groups
#   n = c(100, 200, 300), #their respective size
#   lambda = c(1, 2, 3), #the average contact per person
#   p_transmission = c(0.2, 0.4, 0.5), #the probability of transmitting when infected 
#   move_to = list(c("A", "B", "C"),c("B", "C"), c("A","C")), #movement allocations
#   move_prob = list(c(0.5, 0.2,0.3), c(0.8, 0.2), c(0.5, 0.5)) #movement probabilities
# )

