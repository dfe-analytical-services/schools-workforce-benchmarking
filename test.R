library(testthat)
library(RSelenium)

user <- Sys.getenv("SAUCE_USERNAME") # Your Sauce Labs username
pass <- Sys.getenv("SAUCE_SECRET_KEY") # Your Sauce Labs access key 
port <- 4445
ip <- paste0(user, ':', pass, "@localhost")
rdBrowser <- "chrome"
version <- "48"
platform <- "Linux"
extraCapabilities <- list(name = "R Shiny Testing", username = user
                          , accessKey = pass, 
                          tags = list("R", "Travis", "Shiny"), 
                          'tunnel-identifier' = 
                            Sys.getenv("TRAVIS_JOB_NUMBER"))
remDr <- remoteDriver$new(remoteServerAddr = ip, port = port, 
                          browserName = rdBrowser
                          , version = version, platform = platform
                          , extraCapabilities = extraCapabilities)

remDr$open()
# check tunnel identifier
Sys.getenv("TRAVIS_JOB_NUMBER")
appURL <- "http://localhost:3000"

test_that("can connect to app", {  
  remDr$setImplicitWaitTimeout(2000) # wait for elements for 2 seconds
  remDr$navigate(appURL)
  Sys.sleep(2)
  appTitle <- remDr$getTitle()[[1]]
  expect_equal(appTitle, "Schools Workforce Benchmarking")  
})

remDr$close()