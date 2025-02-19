# import necessary libraries
library(shiny)
library(tidyverse)
library(plotly)
library(DT)

# load in data
elo_history <- read.csv("data/processed/mlb_elo_history.csv")
elo_history <- elo_history |>
  mutate(Date = as.Date(Date),
         Season = as.numeric(format(Date, "%Y")),
         Elo = round(Elo, 2),
         Regular.Record = paste(Regular.Wins, "-", Regular.Losses),
         Postseason.Record = paste(Postseason.Wins, "-", Postseason.Losses))

# get final elo rating for each team at the end of each season
elo_final <- elo_history |>
  group_by(Team, Season) |>
  filter(Date == max(Date)) |>
  slice_tail(n = 1) |>
  ungroup()

# define team colors of visualization
team_colors <- c(
  "Arizona Diamondbacks" = "#A71930",
  "Atlanta Braves" = "#13274F",
  "Baltimore Orioles" = "#DF4601",
  "Boston Red Sox" = "#BD3039",
  "Chicago Cubs" = "#0E3386",
  "Chicago White Sox" = "#27251F",
  "Cincinnati Reds" = "#C6011F",
  "Cleveland Guardians" = "#00385D",
  "Colorado Rockies" = "#333366",
  "Detroit Tigers" = "#0C2340",
  "Houston Astros" = "#EB6E1F",
  "Kansas City Royals" = "#004687",
  "Los Angeles Angels" = "#BA0021",
  "Los Angeles Dodgers" = "#005A9C",
  "Miami Marlins" = "#00A3E0",
  "Milwaukee Brewers" = "#12284B",
  "Minnesota Twins" = "#002B5C",
  "New York Mets" = "#FF5910",
  "New York Yankees" = "#003087",
  "Oakland Athletics" = "#003831",
  "Philadelphia Phillies" = "#E81828",
  "Pittsburgh Pirates" = "#FDB827",
  "San Diego Padres" = "#2F241D",
  "San Francisco Giants" = "#FD5A1E",
  "Seattle Mariners" = "#005C5C",
  "St. Louis Cardinals" = "#C41E3A",
  "Tampa Bay Rays" = "#8FBCE6",
  "Texas Rangers" = "#C0111F",
  "Toronto Blue Jays" = "#134A8E",
  "Washington Nationals" = "#AB0003"
)

# define UI
ui <- fluidPage(
  titlePanel("MLB Elo Ratings"),
  tabsetPanel(
    # historical elo ratings tab
    tabPanel("Historical",
             sidebarLayout(
               sidebarPanel(
                 selectInput("Team1", "Select Team:", choices = sort(unique(elo_history$Team))),
                 selectInput("Team2", "Compare With:", choices = c("None", sort(unique(elo_history$Team))), selected = "None"),
                 dateRangeInput("DateRange", "Select Date Range:", start = as.Date(paste0(min(elo_history$Season), "-01-01")), end = as.Date(paste0(max(elo_history$Season), "-12-31")))
               ),
               mainPanel(
                 plotlyOutput("EloPlot"),
                 style = "width: 100%;"
               )
             )
    ),
    # end of season elo ratings tab
    tabPanel("End of Season",
             sidebarLayout(
               sidebarPanel(
                 selectInput("SelectedSeason", "Select Season:", choices = sort(unique(elo_final$Season), decreasing = TRUE), selected = max(elo_final$Season))
               ),
               mainPanel(
                 DTOutput("FinalEloTable"),
                 uiOutput("FinalEloTableCSS"),
                 style = "width: 100%; height: 71.25vh; overflow-y:auto;"
               )
             )
    )
  )
)

# define server
server <- function(input, output){
  # render historical elo ratings plot
  output$EloPlot <- renderPlotly({
    filtered_history <- elo_history |>
      filter((Team == input$Team1 | (input$Team2 != "None" & Team == input$Team2)) &
               Date >= input$DateRange[1] & Date <= input$DateRange[2]) |>
      arrange(Team, Date) |>
      mutate(Record = ifelse(Postseason.Wins == 0 & Postseason.Losses == 0, Regular.Record, Postseason.Record),
             Breaks = c(0, diff(Date) > 30)) # create breaks in plot for offseason
    
    # filter for each team's highest elo
    elo_highest <- filtered_history |>
      group_by(Team) |>
      filter(Elo == max(Elo))
    
    history_plot <- ggplot(filtered_history, aes(x = Date, y = Elo, color = Team, group = Team, text = paste("Date:", Date,"<br>Team:", Team, "<br>Elo:", Elo,"<br>Record:", Record))) +
      geom_line(aes(group = cumsum(Breaks)), linewidth = 0.75) +
      geom_point(data = elo_highest, aes(x = Date, y = Elo), size = 3, shape = 21, fill = "white") +
      scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
      scale_color_manual(values = team_colors) +
      labs(title = "MLB Team Elo", x = "Season", y = "Elo Rating") +
      theme_minimal()
    
    ggplotly(history_plot, tooltip = "text", height = 425)
  })
  
  # render end of season elo rating table
  output$FinalEloTable <- renderDT({
    filtered_final <- elo_final |>
      filter(Season == input$SelectedSeason) |>
      rename("Regular Season Record" = Regular.Record,
             "Postseason Record" = Postseason.Record)
    
    datatable(
      filtered_final |>
        select(Team, Elo, "Regular Season Record", "Postseason Record", Regular.Wins, Regular.Losses, Postseason.Wins, Postseason.Losses),
      options = list(
        ordering = TRUE,
        paging = FALSE,
        columnDefs = list(
          list(targets = c(4, 5, 6, 7), visible = FALSE),
          list(targets = 1, orderSequence = c("desc", "asc")),
          list(targets = 2, orderData = c(4, 5), orderSequence = c("desc", "asc")),
          list(targets = 3, orderData = c(6, 7), orderSequence = c("desc", "asc"))
        )
      ),
      rownames = FALSE) |>
      formatStyle(columns = c("Team", "Elo", "Regular Season Record", "Postseason Record"), border = "1px solid #ddd")
  })
  
  # center table headers and rows
  output$FinalEloTableCSS <- renderUI({
    tags$style(HTML("#FinalEloTable th {text-align: center;}
                    #FinalEloTable td {text-align: center;}")
    )
  })
}

# run the shiny app locally
shinyApp(ui, server)
