#' @title Instantiate a pm25 diurnal ggplot
#'
#' @description
#' Create a plot using ggplot with default mappings and styling. Layers can then
#' be added to this plot using \code{ggplot2} syntax.
#'
#' @inheritParams custom_pm25DiurnalScales
#'
#' @param ws_data Default dataset to use when adding layers. Must be either a
#'   \code{ws_monitor} object or \code{ws_tidy} object.
#' @param startdate Desired startdate for data to include, in a format that can
#'   be parsed with \link{parseDatetime}.
#' @param enddate Desired enddate for data to include, in a format that can be
#'   parsed with \link{parseDatetime}.
#' @param timezone Timezone to use to set hours of the day
#' @param shadedNight add nighttime shading based on of middle day in selected
#'   period
#' @param mapping Default mapping for the plot
#' @param base_size Base font size for theme
#' @param ... Additional arguments passed on to
#'   \code{\link{custom_pm25DiurnalScales}}.
#'
#' @import ggplot2
#' @importFrom rlang .data
#' @export
#'
#' @examples
#' ws_monitor <- PWFSLSmoke::Carmel_Valley
#' ggplot_pm25Diurnal(ws_monitor) +
#'   coord_polar() +
#'   geom_pm25Points() +
#'   custom_aqiStackedBar(width = 1, alpha = .3)
#'
#' ggplot_pm25Diurnal(ws_monitor,
#'                    startdate = 20160801,
#'                    enddate = 20160810) +
#'   stat_boxplot(aes(group = hour))
#'
ggplot_pm25Diurnal <- function(
  ws_data,
  startdate = NULL,
  enddate = NULL,
  timezone = NULL,
  ylim = NULL,
  shadedNight = TRUE,
  mapping = aes_(x = ~hour, y = ~pm25),
  base_size = 11,
  ...
) {

  # ----- Validate Parameters --------------------------------------------------

  if ( !is.logical(shadedNight) )
    stop("shadedNight must be logical")

  if ( !is.numeric(base_size) )
    stop("base_size must be numeric")

  if ( monitor_isMonitor(ws_data) ) {
    ws_tidy <- monitor_toTidy(ws_data)
  } else if ( monitor_isTidy(ws_data) ) {
    ws_tidy <- ws_data
  } else {
    stop("ws_data must be either a ws_monitor object or ws_tidy object.")
  }

  # Determine the timezone (code borrowed from custom_pm25TimeseriesScales.R)
  if ( is.null(timezone) ) {
    if ( length(unique(ws_tidy$timezone) ) > 1) {
      timezone <- "UTC"
      xlab <- "Time of Day (UTC)"
    } else {
      timezone <- ws_tidy$timezone[1]
      xlab <- "Time of Day (Local)"
    }
  } else if ( is.null(xlab) ) {
    xlab <- paste0("Time of Day (", timezone, ")")
  }

  if ( !is.null(startdate) ) {
    startdate <- MazamaCoreUtils::parseDatetime(startdate, timezone = timezone)
    if ( startdate > range(ws_tidy$datetime)[2] ) {
      stop("startdate is outside of data date range")
    }
  } else {
    startdate <- range(ws_tidy$datetime)[1]
  }

  if ( !is.null(enddate) ) {
    enddate <- MazamaCoreUtils::parseDatetime(enddate, timezone = timezone)
    if ( enddate < range(ws_tidy$datetime)[1] ) {
      stop("enddate is outside of data date range")
    }
  } else {
    enddate <- range(ws_tidy$datetime)[2]
  }

  # ----- Prepare data ---------------------------------------------------------

  # MazamaCoreUtils::dateRange() was built for this!
  dateRange <- MazamaCoreUtils::dateRange(
    startdate,
    enddate,
    timezone = timezone,
    ceilingEnd = TRUE
  )
  startdate <- dateRange[1]
  enddate <- dateRange[2]

  # Subset based on startdate and enddate
  ws_tidy <- ws_tidy %>%
    dplyr::filter(.data$datetime >= startdate) %>%
    dplyr::filter(.data$datetime <= enddate)

  # Add column for 'hour'
  ws_tidy$hour <- as.numeric(strftime(ws_tidy$datetime, "%H", tz = timezone))
  ws_tidy$day  <- strftime(ws_tidy$datetime, "%Y%m%d", tz = timezone)

  # ----- Create plot ----------------------------------------------------------

  gg <- ggplot(ws_tidy, mapping) +
    theme_pwfsl(base_size = base_size) +
    custom_pm25DiurnalScales(ws_tidy, xlab = xlab, ylim = ylim, ...)

  # Calculate day/night shading
  if (shadedNight) {
    # Get the sunrise/sunset information
    ti <- timeInfo(
      ws_tidy$datetime,
      longitude = ws_tidy$longitude[1],
      latitude = ws_tidy$latitude[1],
      timezone = ws_tidy$timezone[1]
    )

    # Extract the middle row
    ti <- ti[round(nrow(ti) / 2), ]

    # Get sunrise and sunset in units of hours
    sunrise <- lubridate::hour(ti$sunrise) + (lubridate::minute(ti$sunrise) / 60)
    sunset <- lubridate::hour(ti$sunset) + (lubridate::minute(ti$sunset) / 60)

    # Add shaded night
    scales <- layer_scales(gg)

    morning <- annotate(
      "rect",
      xmin = scales$x$limits[1],
      xmax = sunrise,
      ymin = scales$y$limits[1],
      ymax = scales$y$limits[2],
      fill = "black",
      alpha = 0.1
    )
    night <-   annotate(
      "rect",
      xmin = sunset,
      xmax = scales$x$limits[2],
      ymin = scales$y$limits[1],
      ymax = scales$y$limits[2],
      fill = "black",
      alpha = 0.1
    )

    gg <- gg + morning + night
  }

  # ----- Return ---------------------------------------------------------------

  return(gg)

}
