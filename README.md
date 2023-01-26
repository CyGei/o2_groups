`simulate()` function

This function simulates the spread of an infection within and between groups over a specified number of days. The function takes three inputs `groups_df` and `intro_group` and `duration`.

-   `groups_df` is the input dataframe. It contains information about each group such as group size, within group contact rate as the average number of contacts per individual (`lambda`), within-group transmission probability (`p_transmission`), between group movement allocation (`move_to`) and movement probability (`move_prob`).
-   `intro_group` is the name of the group where the initial infected individual is introduced.
-   `duration` is the number of days for which the simulation runs.

The function uses the `generate_clusters()` function to create an initial dataframe with the positions of individuals in each group and assigns each individual an ID and sets their initial infected and contacts status to 0. Then the simulation introduces an infected individual in the designated `intro_group`. After that, the function starts a loop for the specified duration, for each day it

-   The function allows for movement of individuals from one group to another, based on the `move_to` and `move_prob` columns of `groups_df`. It checks if an individual will move to another group, and if so, it uses a helper function to generate new coordinates for that individual in the new group, and updates the group variable.
-   Assigns the number of contacts for every individual for each group using a Poisson distribution with the lambda parameter specified in the `lambda` column of the `groups_df` dataframe.
-   Identifies the infected individuals and, for each infected individual, it
    -   Gets the current group of the infector.
    -   Gets the number of contacts for the infector.
    -   Draws the number of transmissions with probability `p_transmission` specified in the `groups_df` dataframe for the group the infector is located in.
    -   Identifies the possible individuals from the same group of the infector.
    -   Samples the possible IDs for the number of transmissions.
    -   Updates the infected status for those individuals.
    -   Append the current day information to the main dataframe.
-   Returns a list containing the dataframe with the detailed information of each individual for each day (`data`) and the summary statistics (`stats`) for each group for each day.