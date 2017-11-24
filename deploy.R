# Create conditional app name based on branch

app_name <- if (Sys.getenv("TRAVIS_BRANCH") == "master"){
  "schools-workforce-benchmarking"
} else if (Sys.getenv("TRAVIS_BRANCH") == "develop"){
  "dev-schools-workforce-benchmarking"
}

# Set account info
rsconnect::setAccountInfo(
  name=Sys.getenv("APP_NAME"),
  token=Sys.getenv("SHINYAPPS_TOKEN"),
  secret=Sys.getenv("SHINYAPPS_SECRET")
  )

# Deploy
rsconnect::deployApp()