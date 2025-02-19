from bs4 import BeautifulSoup
import requests
import re
import pandas as pd

def get_soup(year):
    """
    Fetch and parse the HTML content of a MLB schedule page for a given year.
    
    Parameters:
        year (int): The year to fetch data for.
        
    Returns:
        BeautifulSoup: The parsed HTML content.
    """
    url = f'https://www.baseball-reference.com/leagues/majors/{year}-schedule.shtml'
    response = requests.get(url).text
    return BeautifulSoup(response, 'html.parser')

def get_table_data(table, game_type, list):
    """
    Extracts game data from an HTML table and appends it to the provided list.
    
    Parameters:
        table (BeautifulSoup): The HTML table to extract data from.
        game_type (str): The type of game (e.g., 'regular' or 'postseason').
        list (list): The list to store extracted game data.
    """
    headers = table.find_all('h3')
    for header in headers:
        date = header.text.split(',', 1)[1].lstrip()
        season = date.split(',')[1].lstrip()
        games = header.find_next_siblings('p', class_='game')

        for game in games:
            if 'Spring' in game.text:
                continue
            
            lines = game.text.split('@')
            away_team, away_score = re.match(r'(.+?)\s+\((\d+)\)', lines[0].strip()).groups()
            home_team, home_score = re.match(r'(.+?)\s+\((\d+)\)', lines[1].strip()).groups()

            list.append({
                'Date': date,
                'Season': season,
                'Game': game_type,
                'Away Team': away_team,
                'Home Team': home_team,
                'Away Score': away_score,
                'Home Score': home_score
            })

def scrape_games(year, list):
    """
    Extracts data for regular season and postseason games from the parsed HTML content.
    
    Parameters:
        year (int): The year to scrape data for.
        list (list): The list to store extracted game data.
    """
    soup = get_soup(year)
    tables = soup.find_all('div', {'class': 'section_content'})

    get_table_data(tables[0], 'regular', list)
    get_table_data(tables[1], 'postseason', list)

def create_dataframe(first_year, last_year):
    """
    Scrapes game data for a range of years and converts it into a Pandas DataFrame.

    Parameters:
        first_year (int): The starting year of the range.
        last_year (int): The ending year of the range.

    Returns:
        pd.DataFrame: DataFrame containing the scraped game data.
    """
    data = []
    for year in range(first_year, last_year + 1):
        scrape_games(year, data)

    return pd.DataFrame(data)