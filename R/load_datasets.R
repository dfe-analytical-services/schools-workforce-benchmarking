#Load in core data  

Data <- read_csv("Data/deploy_sfr_2016.csv",  col_types = cols(.default = "c"))

#Set SUPP and DNS to NA
Data[Data == 'SUPP'] <- NA
Data[Data == "DNS"] <- NA

#Set variables to numeric for plotting
Data[5:41] <- lapply(Data[,5:41], as.numeric)
Data[47] <- lapply(Data[,47], as.numeric)
Data[52:62] <- lapply(Data[,52:62], as.numeric)

#Create custom id column
Data$ID <- paste(Data$URN,' - ', Data$`School Name`, sep = '')

#Load in list of school characteristics and what school phase they relate to
characteristics_dd <- read_csv("Data/Characteristics.csv", col_types = cols(.default = "c")) 

#Load in list of characteristics and their type of match for comparisons

characteristics_match <- read_csv("Data/characteristics_match.csv", col_types = cols(.default = "c"))

# Create list of measure groupings

measure_groupings <- list("Staff Headcount" = colnames(Data)[5:12],
                          "Staff FTE" = colnames(Data)[13:21],
                          "Teacher Characteristics" = colnames(Data)[22:26],
                          "Teaching Assistant Characteristics" = colnames(Data)[27:29],
                          "Non-classroom based Support Staff Characteristics" = colnames(Data)[30:31],
                          "Auxiliary Staff Characteristics" = colnames(Data)[32:33],
                          "Staff Pay" = colnames(Data)[34:37],
                          "Teacher Absence" = colnames(Data)[38:41])