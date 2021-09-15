devtools::install_github("danmorse314/hockeyR")

library(tidyverse)
library(hockeyR)
library(glue)
library(git2r)

# get current season data
pbp <- load_pbp()

# get day's pbp data
pbp_day <- scrape_day()

# combine
pbp_updated <- bind_rows(pbp, pbp_day)

if(is.null(pbp) & nrow(pbp_updated) > 0){
  # first save of the season
  new_data <- TRUE
} else if(!is.null(pbp)){
  # season already begun, some data already exists
  # check to see if new games were played, otherwise no need to save
  if(nrow(pbp_updated) > nrow(pbp)){
    # new games added
    new_data <- TRUE
  } else {
    # no new games
    new_data <- FALSE
  }
} else {
  # season not started yet
  new_data <- FALSE
}

if(new_data){
  # new games added, create save file
  season_first <- substr(last(pbp_updated$season), 1,4)
  season_last <- substr(last(pbp_updated$season), 7,8)

  filename <- glue("data/play_by_play_{season_first}_{season_last}")

  pbp_updated |> saveRDS(glue("{filename}.rds"))
  pbp_updated |> crunch::write.csv.gz(glue("{filename}.csv.gz"))

  # push to github
  repo <- repository(getwd())

  add(repo, glue("{filename}.rds"))
  add(repo, glue("{filename}.csv.gz"))

  #git2r::pull(repo)

  commit(repo, message = paste0("Data updated: ", Sys.time()))

  push(repo, credentials = cred_token())
}


