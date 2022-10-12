##  Updating the hockeyR data repo

devtools::install_github("danmorse314/hockeyR")
install.packages(c("dplyr","glue","crunch"))

# get current season data
pbp <- hockeyR::load_pbp()

# get day's pbp data
#   running for yesterday, because this code runs after midnight
pbp_day <- hockeyR::scrape_day(Sys.Date()-1)

# combine
pbp_updated <- dplyr::bind_rows(pbp, pbp_day) |>
  dplyr::distinct()

season_first <- substr(dplyr::last(pbp_updated$season), 1,4)
season_last <- substr(dplyr::last(pbp_updated$season), 7,8)

filename <- glue::glue("data/play_by_play_{season_first}_{season_last}")

# add smaller version w/o line change events
pbp_lite <- pbp_updated |>
  dplyr::filter(event_type != "CHANGE")

pbp_updated |> saveRDS(glue::glue("{filename}.rds"))
pbp_lite |> saveRDS(glue::glue("{filename}_lite.rds"))
pbp_updated |> crunch::write.csv.gz(glue::glue("{filename}.csv.gz"))
pbp_lite |> crunch::write.csv.gz(glue::glue("{filename}_lite.csv.gz"))
