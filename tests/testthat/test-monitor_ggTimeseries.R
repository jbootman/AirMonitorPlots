test_that("parameters are validated", {

  ws_cv <- PWFSLSmoke::Carmel_Valley

  expect_error(monitor_ggTimeseries("ws_cv"))
  expect_error(monitor_ggTimeseries(ws_cv, startdate = 20200101))
  expect_error(monitor_ggTimeseries(ws_cv, enddate = 11111111111111))
  expect_error(monitor_ggTimeseries(ws_cv, style = "invalid"))
  expect_error(monitor_ggTimeseries(ws_cv, monitorIDs = "invalid"))

})

test_that("return has the class 'ggplot'", {

  ws_cv <- PWFSLSmoke::Carmel_Valley

  expect_s3_class(monitor_ggTimeseries(ws_cv), "ggplot")

})
