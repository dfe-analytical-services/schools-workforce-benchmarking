rsconnect::setAccountInfo(
  name="department-for-education",
  token="42FE83A31CD60148BB558FA2B5EB1FE9",
  secret=Sys.getenv("SHINYAPPS_SECRET")
  )

rsconnect::deployApp()