rsconnect::setAccountInfo(
  name="department-for-education",
  token=Sys.getenv("SHINYAPPS_TOKEN"),
  secret=Sys.getenv("SHINYAPPS_SECRET")
  )

rsconnect::deployApp()