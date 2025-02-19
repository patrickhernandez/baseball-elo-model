from scrape_team_scores import create_dataframe
import pandas as pd

# create dataframe with game scores from 2005 to 2024
mlb_scores = create_dataframe(2005, 2024)

# change older team names to current team names
mlb_scores[['Away Team', 'Home Team']] = mlb_scores[['Away Team', 'Home Team']].replace({"Arizona D'Backs": 'Arizona Diamondbacks', 
                                                                                         'Cleveland Indians': 'Cleveland Guardians',
                                                                                         'Florida Marlins': 'Miami Marlins', 
                                                                                         'LA Angels of Anaheim': 'Los Angeles Angels',
                                                                                         'Tampa Bay Devil Rays': 'Tampa Bay Rays'})

# each team's home stadiums and their location
mlb_stadiums = pd.read_csv('data/raw/team_stadium_locations.csv', index_col=[0])

# merge mlb_scores and mlb_stadiums to get location of each game
df_combined = pd.merge(mlb_scores, mlb_stadiums, left_on='Home Team', right_on='Team', how='left')
df_combined = df_combined.drop(columns=['City', 'State', 'Capacity', 'League', 'Team'])
df_combined = df_combined.rename(columns={'Name': 'Venue', 'Latitude': 'Venue Latitude', 'Longitude': 'Venue Longitude'})

# save merged dataframe
df_combined.to_csv('data/raw/mlb_game_results.csv')