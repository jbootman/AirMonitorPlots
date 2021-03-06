# reproduce https://tools.airfire.org/monitor-plot/v4/plot?databaseversion=4.0&webserviceapi=4.0&plottype=timeseries&monitorid=060631010_01
# and https://tools.airfire.org/monitor-plot/v4/plot?databaseversion=4.0&webserviceapi=4.0&plottype=dailybarplot&monitorid=060631010_01

library(AirMonitorPlots)
ws_monitor <- airnow_loadLatest()
monitorID <- "060631010_01"
startdate <- lubridate::floor_date(lubridate::now() - lubridate::ddays(6), "day")
enddate <- lubridate::now()

# Timeseries ---------------------------------------------------------------------------

png("timeseries.png", width = 700, height = 700, units = "px")
monitor_ggTimeseries(ws_monitor,
                     startdate = startdate,
                     enddate = enddate,
                     monitorIDs = monitorID,
                     style = "large")
dev.off()

png("smalltimeseries.png", width = 450, height = 450, units = "px")
monitor_ggTimeseries(ws_monitor,
                     startdate = startdate,
                     enddate = enddate,
                     monitorIDs = monitorID,
                     style = "small")
dev.off()


# Barplot ---------------------------------------------------------------------------

monitor_ggDailyBarplot(ws_monitor,
                       startdate = startdate,
                       enddate = enddate,
                       monitorIDs = "483230004_01")


b <- monitor_ggDailyBarplot(ws_monitor,
                            startdate = startdate,
                            enddate = enddate,
                            monitorIDs = monitorID,
                            style = "large")


png("barplot.png", width = 700, height = 700, units = "px")
b
dev.off()

png("barplot.png", width = 700, height = 700, units = "px")
monitor_ggDailyBarplot(ws_monitor,
                     startdate = startdate,
                     enddate = enddate,
                     monitorIDs = monitorID,
                     style = "large") %>%
  brandPlot()
dev.off()

png("smallbarplot.png", width = 450, height = 450, units = "px")
monitor_ggDailyBarplot(ws_monitor,
                       startdate = startdate,
                       enddate = enddate,
                       monitorIDs = monitorID,
                       style = "small") %>%
  brandPlot()
dev.off()

# DailyByHour ---------------------------------------------------------------------------

monitor_ggDailyByHour(ws_monitor,
                      startdate = startdate,
                      enddate = enddate,
                      monitorID = monitorID,
                      style = "large")
png("dailybyhour.png", width = 700, height = 700, units = "px")
monitor_ggDailyByHour(ws_monitor,
                      startdate = startdate,
                      enddate = enddate,
                      monitorID = monitorID,
                      style  = "large")
dev.off()

png("smalldailybyhour.png", width = 450, height = 450, units = "px")
monitor_ggDailyByHour(ws_monitor,
                      startdate = startdate,
                      enddate = enddate,
                      monitorID = monitorID,
                      style = "small")
dev.off()


