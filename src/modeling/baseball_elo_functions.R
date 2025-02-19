# convert degrees to radians
deg_to_rad <- function(deg){
  return (deg * pi / 180)
}

# calculate distance in miles between two locations
calc_distance <- function(lat_1, lon_1, lat_2, lon_2){
  lat_1 <- deg_to_rad(lat_1)
  lon_1 <- deg_to_rad(lon_1)
  lat_2 <- deg_to_rad(lat_2)
  lon_2 <- deg_to_rad(lon_2)
  
  delta_lat <- lat_2 - lat_1
  delta_lon <- lon_2 - lon_1
  
  hav_comp <- sin(delta_lat / 2)^2 + cos(lat_1) * cos(lat_2) * sin(delta_lon / 2)^2
  ang_dist <- 2 * atan2(sqrt(hav_comp), sqrt(1 - hav_comp))
  
  return (ang_dist * 3959)
}

# calculate win probability
calc_win_prob <- function(elo1, elo2){
  win_prob <- 1 / (1 + 10^((elo2 - elo1) / 400))
  return (win_prob)
}

# calculate new team elos after game result
calc_new_elo <- function(team_elo, team_1, team_2, score_1, score_2, k){
  elo_1 <- team_elo$Elo[team_elo$Team == team_1]
  elo_2 <- team_elo$Elo[team_elo$Team == team_2]
  
  win_prob_1 <- calc_win_prob(elo_1, elo_2)
  win_prob_2 <- 1 - win_prob_1
  
  result_1 <- ifelse(score_1 > score_2, 1, ifelse(score_1 < score_2, 0, 0.5))
  result_2 <- 1 - result_1
  
  new_elo_1 <- elo_1 + k * (result_1 - win_prob_1)
  new_elo_2 <- elo_2 + k * (result_2 - win_prob_2)
  
  team_elo$Elo[team_elo$Team == team_1] <- new_elo_1
  team_elo$Elo[team_elo$Team == team_2] <- new_elo_2
  
  return (team_elo)
}

# calculate pre-game elo adjustments
calc_adjustment <- function(travel, rest, location="away"){
  home_advantage <- ifelse(location=="home", 24, 0)
  adjustment <- home_advantage + (-0.31 * travel^(1/3)) + (2.3 * rest) 
  
  return (adjustment)
}
