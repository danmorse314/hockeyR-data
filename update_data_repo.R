##  Updating the hockeyR data repo

#devtools::install_github("danmorse314/hockeyR")

# get current season data
pbp <- hockeyR::load_pbp()

# get day's pbp data
pbp_day <- hockeyR::scrape_day()

# combine
pbp_updated <- dplyr::bind_rows(pbp, pbp_day)

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

  filename <- glue::glue("data/play_by_play_{season_first}_{season_last}")

  pbp_updated |> saveRDS(glue::glue("{filename}.rds"))
  pbp_updated |> crunch::write.csv.gz(glue::glue("{filename}.csv.gz"))

  # push to github
  repo <- git2r::repository(getwd())

  git2r::add(repo, glue::glue("{filename}.rds"))
  git2r::add(repo, glue::glue("{filename}.csv.gz"))

  #git2r::pull(repo)

  git2r::commit(repo, message = glue::glue("Data updated: {Sys.time()}"))

  git2r::push(repo, credentials = git2r::cred_token())
}
