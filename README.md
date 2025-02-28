# Baseball Elo Model

### Overview

This project implements an Elo rating system for MLB teams, using historical game results to track and predict team performance over time. The model adjusts Elo ratings based on game outcomes and incorporates factors like home-field advantage, travel distance, and rest days to calculate pre-game Elo ratings based on current team ratings. These pre-game Elo ratings are then used to predict game results. 

### Inspiration

This project is inspired by [FiveThirtyEight's MLB Elo Model](https://fivethirtyeight.com/methodology/how-our-mlb-predictions-work/), which applies the Elo rating system to baseball to evaluate and predict team performance over time. Their approach, which factors in home-field advantage, travel distance, rest days, and starting pitchers, influenced the development of this model. Building on that foundation, this project focuses on using pre-game Elo ratings, adjusted for key factors to predict game outcomes. 

### Shiny App

Check out the interactive Shiny app for visualizing Elo ratings: [Baseball Elo Shiny App](https://patrickhernandez.shinyapps.io/baseball-elo/)

### Repository Structure

```plaintext
baseball-elo-model/
├── LICENSE
├── README.md
├── app.R 								
├── data
│   ├── processed
│   │   ├── mlb_elo_current.csv
│   │   ├── mlb_elo_history.csv
│   │   └── mlb_game_results_final.csv
│   └── raw
│       ├── mlb_game_results.csv
│       └── team_stadium_locations.csv
├── scripts
│   └── baseball_elo_model.Rmd
└── src
    ├── modeling
    │   └── baseball_elo_functions.R
    └── scraping
        ├── save_team_scores.py
        └── scrape_team_scores.py
```

### License

This project is licensed under the MIT License.