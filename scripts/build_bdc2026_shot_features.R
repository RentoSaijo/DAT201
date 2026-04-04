library(data.table)
library(jsonlite)

# ----- Helpers ----- #

clock_to_seconds <- function(clock_chr) {
  clock_split <- tstrsplit(clock_chr, ':', fixed = TRUE)
  as.integer(clock_split[[1]]) * 60L + as.integer(clock_split[[2]])
}

flip_side <- function(side_chr) {
  fifelse(side_chr == 'Home', 'Away', 'Home')
}

get_goalie_right_side <- function(period_num, goalie_right_odd_chr) {
  fifelse(period_num %% 2L == 1L, goalie_right_odd_chr, flip_side(goalie_right_odd_chr))
}

attacks_right <- function(team_side_chr, period_num, goalie_right_odd_chr) {
  team_side_chr != get_goalie_right_side(period_num, goalie_right_odd_chr)
}

download_bdc2026_files <- function(data_dir = 'data/bdc2026') {
  dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)

  release_url <- 'https://api.github.com/repos/bigdatacup/Big-Data-Cup-2026/releases/tags/Data'
  release_jsn <- jsonlite::fromJSON(release_url)

  asset_tbl <- data.table::as.data.table(release_jsn$assets)[
    grepl('\\.Events\\.csv$|Tracking_|camera_orientations\\.csv$', name)
  ]

  for (i in seq_len(nrow(asset_tbl))) {
    asset_path <- file.path(data_dir, asset_tbl$name[i])
    if (file.exists(asset_path) && file.info(asset_path)$size == asset_tbl$size[i]) {
      next
    }
    download.file(asset_tbl$browser_download_url[i], asset_path, mode = 'wb', quiet = TRUE)
  }

  invisible(asset_tbl$name)
}

read_events <- function(data_dir = 'data/bdc2026') {
  event_files <- list.files(data_dir, pattern = '\\.Events\\.csv$', full.names = TRUE)
  if (length(event_files) == 0L) {
    stop('No event files were found in data/bdc2026/.')
  }

  event_list <- lapply(event_files, function(file_path) {
    event_dt <- data.table::fread(file_path)
    event_dt[, source_stub := sub('\\.Events\\.csv$', '', basename(file_path))]
    event_dt[, source_file := basename(file_path)]
    event_dt[, event_idx := .I]
    event_dt
  })

  events_dt <- data.table::rbindlist(event_list, fill = TRUE)
  events_dt[, game_id := sprintf('%s %s @ %s', Date, Away_Team, Home_Team)]
  events_dt[, clock_seconds := clock_to_seconds(Clock)]
  events_dt[, event_seq := seq_len(.N), by = source_stub]

  events_dt
}

add_pre_shot_context <- function(shot_dt, events_dt) {
  play_dt <- events_dt[Event == 'Play',
                       .(source_stub, Period, Team, event_seq, clock_seconds,
                         play_type = Detail_1,
                         play_x = X_Coordinate,
                         play_y = Y_Coordinate,
                         play_x2 = X_Coordinate_2,
                         play_y2 = Y_Coordinate_2)]

  shot_dt[, `:=`(
    pre_shot_play = FALSE,
    pre_shot_seconds = NA_integer_,
    pre_shot_play_type = NA_character_,
    pre_shot_dx = NA_real_,
    pre_shot_dy = NA_real_,
    pre_shot_lateral_ft = NA_real_,
    pre_shot_cross_slot = FALSE,
    pre_shot_to_slot = FALSE
  )]

  for (i in seq_len(nrow(shot_dt))) {
    shot_row <- shot_dt[i]
    cand_dt <- play_dt[
      source_stub == shot_row$source_stub &
        Period == shot_row$Period &
        Team == shot_row$Team &
        event_seq < shot_row$event_seq &
        clock_seconds >= shot_row$clock_seconds &
        clock_seconds <= shot_row$clock_seconds + 5L
    ]

    if (nrow(cand_dt) == 0L) {
      next
    }

    cand_dt[, dt := clock_seconds - shot_row$clock_seconds]
    setorder(cand_dt, dt, -event_seq)
    play_row <- cand_dt[1]

    shot_dt[i, `:=`(
      pre_shot_play = TRUE,
      pre_shot_seconds = play_row$dt,
      pre_shot_play_type = play_row$play_type,
      pre_shot_dx = play_row$play_x2 - play_row$play_x,
      pre_shot_dy = play_row$play_y2 - play_row$play_y,
      pre_shot_lateral_ft = abs(play_row$play_y2 - play_row$play_y),
      pre_shot_cross_slot = abs(play_row$play_y) > 10 &
        abs(play_row$play_y2) > 10 &
        play_row$play_y * play_row$play_y2 < 0,
      pre_shot_to_slot = abs(play_row$play_y) > 10 &
        abs(play_row$play_y2) <= 10
    )]
  }

  shot_dt[]
}

build_shot_feature_file <- function(
  data_dir = 'data/bdc2026',
  out_file = 'data/bdc2026_shot_features.csv',
  force = FALSE
) {
  if (file.exists(out_file) && !force) {
    return(data.table::fread(out_file))
  }

  if (!dir.exists(data_dir) || length(list.files(data_dir, pattern = '\\.csv$', full.names = TRUE)) == 0L) {
    download_bdc2026_files(data_dir = data_dir)
  }

  events_dt <- read_events(data_dir = data_dir)
  orient_path <- file.path(data_dir, 'camera_orientations.csv')
  orient_dt <- data.table::fread(orient_path)
  setnames(orient_dt, c('Game', 'GoalieTeamOnRightSideOfRink1stPeriod'), c('game_id', 'goalie_right_odd'))

  shot_dt <- events_dt[Event == 'Shot']
  shot_dt <- merge(shot_dt, orient_dt, by = 'game_id', all.x = TRUE, sort = FALSE)

  shot_dt[, team_side := fifelse(Team == Home_Team, 'Home', 'Away')]
  shot_dt[, opp_side := flip_side(team_side)]
  shot_dt[, attack_right := attacks_right(team_side, Period, goalie_right_odd)]
  shot_dt[, goal_x := fifelse(attack_right, 89, -89)]
  shot_dt[, shot_distance_ft := sqrt((goal_x - X_Coordinate)^2 + Y_Coordinate^2)]
  shot_dt[, abs_y_ft := abs(Y_Coordinate)]
  shot_dt[, even_strength := Home_Team_Skaters == 5L & Away_Team_Skaters == 5L]
  shot_dt[, on_net := Detail_2 == 'On Net']
  shot_dt[, blocked := Detail_2 == 'Blocked']
  shot_dt[, missed := Detail_2 == 'Missed']
  shot_dt[, got_through := !blocked]
  shot_dt[, shooter_jersey := as.character(Player_Id)]

  shot_dt <- add_pre_shot_context(shot_dt = shot_dt, events_dt = events_dt)

  shot_dt[, `:=`(
    tracking_frame_id = NA_character_,
    shooter_track_x = NA_real_,
    shooter_track_y = NA_real_,
    frame_match_error_ft = NA_real_,
    nearest_defender_ft = NA_real_,
    defenders_within_6ft = NA_integer_,
    defenders_within_10ft = NA_integer_
  )]

  shot_dt[, tracking_file := fifelse(
    Period <= 3L,
    file.path(data_dir, sprintf('%s.Tracking_P%s.csv', source_stub, Period)),
    file.path(data_dir, sprintf('%s.Tracking_POT.csv', source_stub))
  )]

  track_groups <- unique(shot_dt[, .(tracking_file, source_stub, Period)])

  for (g in seq_len(nrow(track_groups))) {
    file_path <- track_groups$tracking_file[g]
    if (!file.exists(file_path)) {
      next
    }

    tracking_dt <- data.table::fread(file_path, showProgress = FALSE)
    setnames(
      tracking_dt,
      c(
        'Image Id',
        'Game Clock',
        'Player or Puck',
        'Player Jersey Number',
        'Rink Location X (Feet)',
        'Rink Location Y (Feet)'
      ),
      c(
        'image_id',
        'game_clock',
        'player_or_puck',
        'player_jersey_number',
        'track_x',
        'track_y'
      )
    )

    tracking_dt[, team := as.character(Team)]
    tracking_dt[, clock_seconds := clock_to_seconds(game_clock)]
    tracking_dt[, player_jersey_number := as.character(player_jersey_number)]
    tracking_dt[, player_jersey_number := fifelse(player_jersey_number == 'NA', NA_character_, player_jersey_number)]

    shot_idx <- shot_dt[tracking_file == file_path, which = TRUE]

    for (i in shot_idx) {
      shot_row <- shot_dt[i]
      team_rows <- tracking_dt[
        Period == shot_row$Period &
          clock_seconds == shot_row$clock_seconds &
          player_or_puck == 'Player' &
          team == shot_row$team_side
      ]

      if (nrow(team_rows) == 0L) {
        next
      }

      shooter_rows <- team_rows[player_jersey_number == shot_row$shooter_jersey]
      if (nrow(shooter_rows) == 0L) {
        shooter_rows <- team_rows
      }

      shooter_rows[, event_dist := sqrt((track_x - shot_row$X_Coordinate)^2 + (track_y - shot_row$Y_Coordinate)^2)]
      setorder(shooter_rows, event_dist)
      shooter_row <- shooter_rows[1]

      frame_dt <- tracking_dt[image_id == shooter_row$image_id & player_or_puck == 'Player']
      defender_dt <- frame_dt[team == shot_row$opp_side]
      if (nrow(defender_dt) > 0L) {
        defender_dt[, def_dist := sqrt((track_x - shooter_row$track_x)^2 + (track_y - shooter_row$track_y)^2)]
        defender_dt <- defender_dt[!is.na(def_dist)]
        if (nrow(defender_dt) > 0L) {
          nearest_defender <- defender_dt[, min(def_dist)]
          within_6 <- defender_dt[, sum(def_dist <= 6)]
          within_10 <- defender_dt[, sum(def_dist <= 10)]
        } else {
          nearest_defender <- NA_real_
          within_6 <- NA_integer_
          within_10 <- NA_integer_
        }
      } else {
        nearest_defender <- NA_real_
        within_6 <- NA_integer_
        within_10 <- NA_integer_
      }

      shot_dt[i, `:=`(
        tracking_frame_id = shooter_row$image_id,
        shooter_track_x = shooter_row$track_x,
        shooter_track_y = shooter_row$track_y,
        frame_match_error_ft = shooter_row$event_dist,
        nearest_defender_ft = nearest_defender,
        defenders_within_6ft = within_6,
        defenders_within_10ft = within_10
      )]
    }
  }

  dir.create(dirname(out_file), recursive = TRUE, showWarnings = FALSE)
  data.table::fwrite(shot_dt, out_file)
  shot_dt
}

shot_feature_dt <- build_shot_feature_file()
