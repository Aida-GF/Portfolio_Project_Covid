library(tidyverse)
# Load the dplyr package
library(dplyr)
rmcomma_function <- function(x) { 
  return (gsub(",", "", x))
}

str_new <- rmcomma_function("a,b,,,,")
print(str_new)

fix_csv_function <- function(filename) { 
  print(filename)
  data <- read.csv(filename, header = TRUE, skip = 1)
  print("1")
  columns_to_modify <- names(data)[5:ncol(data)]
  print("2")
  # data[columns_to_modify][is.na(data[columns_to_modify])] <- 0
  print("3")
  data[columns_to_modify] <- lapply(data[columns_to_modify], rmcomma_function)
  print("4")
  new_filename <- paste0(tools::file_path_sans_ext(filename), "_new.csv")
  print("5")
  write.csv(data, file = new_filename, row.names = FALSE, na = "")
}

fix_csv_function("Covid-Death.csv")
fix_csv_function(filename="Covid-Vaccination.csv")

data <- read.csv("Covid-Death_new.csv")#, header = TRUE, skip = 1)
# Search for cells containing a comma in 'tests_units' column using grepl
comma_cells <- grepl("test", data$tests_units)

# Subset the dataframe to include only rows with comma cells
result <- data[comma_cells, ]

# Print the result
print(result)



