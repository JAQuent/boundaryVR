# This script get matches the worker_ids with the prolific_ids to get demographics 
# for participants whose data is in the analysed sample
# Version 1.0
# Date:  21/04/2021
# Author: Joern Alexander Quent
# /* 
# ----------------------------- Libraries ---------------------------
# */
library(plyr)
library(jsonlite)
library(pacman)
library(tidyverse)

# /* 
# ----------------------------- Load data to get worker_ids ---------------------------
# */
# Path
exp3_path <- "~/boundaryVR/data/Exp3/batch1/"

# Get all files
folder1         <- '/memoryTask1/'
folder2         <- '/memoryTask2/'
allFiles1       <- list.files(paste0(exp3_path, folder1))
allFiles2       <- list.files(paste0(exp3_path, folder2))
allFiles1_paths <- paste0(exp3_path, folder1, allFiles1)
allFiles2_paths <- paste0(exp3_path, folder2, allFiles2)
n1              <- length(allFiles1_paths)
n2              <- length(allFiles2_paths)

# Half 1 
for(i in 1:n1){
  ############
  # Loading data
  tempDF <- read.csv(allFiles1_paths[i], header = TRUE, na.strings = '')
  
  # Convert RT to numeric  
  tempDF$rt <- suppressWarnings(as.numeric(as.character(tempDF$rt)))
  
  ############
  # Temporal order memory 1
  temporalOrder1 <- subset(tempDF, test_part == 'temporalOrder')
  
  # Create or bind to data.frame
  if(i == 1){
    df_order_exp3_h1    <- temporalOrder1
    df_order_exp3_h1$id <- i
  } else {
    temporalOrder1$id <- i
    df_order_exp3_h1      <- rbind(df_order_exp3_h1, temporalOrder1)
  }
}

# Half 2
for(i in 1:n2){
  ############
  # Loading data
  tempDF <- read.csv(allFiles2_paths[i], header = TRUE, na.strings = '')
  
  ############
  # Temporal order memory 1
  temporalOrder1 <- subset(tempDF, test_part == 'temporalOrder')

  # Create or bind to data.frame
  if(i == 1){
    df_order_exp3_h2    <- temporalOrder1
    df_order_exp3_h2$id <- i
  } else {
    temporalOrder1$id <- i
    df_order_exp3_h2    <- rbind(df_order_exp3_h2, temporalOrder1)
  }
}

# Bind together
df_order_exp3         <- rbind(df_order_exp3_h1, df_order_exp3_h2)
df_order_exp3$half    <- factor(df_order_exp3$half, levels = c(0, 1), labels = c('h1', 'h2'))

# Get trials
trials <- ddply(df_order_exp3, c('worker_id'), summarise, n = length(worker_id))

# Get workers
workers <- trials$worker_id

# /* 
# ----------------------------- Load prolific ids ---------------------------
# */
# Solution found here https://labjs.readthedocs.io/en/latest/learn/deploy/3c-jatos.html
path2file <- "~/boundaryVR/data/Exp3/ignore_prolific_ids/jatos_results_20210421085620_prolific_ids.txt"
# Read the text file from JATOS ...
jsonString  <- readChar(path2file, file.info(path2file)$size)
# ... split it into lines ...
jsonString_split <- str_split(jsonString, '\n')
jsonString_split <- first(jsonString_split)
# ... filter empty rows ...
jsonString_split <- discard(jsonString_split, function(x) x == '')
# ... parse JSON into a data.frame
prolific_ids     <- map_dfr(jsonString_split, fromJSON, flatten = T)


# /* 
# ----------------------------- Remove prolific ids from workers that are not analysed ---------------------------
# */
prolific_ids <- prolific_ids[prolific_ids$worker_id %in% workers,]

# /* 
# ----------------------------- Get demographics only for those ---------------------------
# */
# Load demographic data with prolific ids
demographics <- read.table("~/boundaryVR/data/Exp3/ignore_prolific_ids/exp3_demographics_with_ids.csv", header = TRUE, sep = ',')

# Retain only demographics for workers in prolific_ids
demographics <- demographics[demographics$participant_id  %in% prolific_ids$prolific_ID, ]

# /* 
# ----------------------------- Save demographic data for analysis ---------------------------
# */
# Remove PID
demographics$session_id     <- NULL
demographics$participant_id <- NULL

# Write .csv
write.csv(demographics, '~/boundaryVR/data/Exp3/exp3_demographics.csv', row.names = FALSE, quote = FALSE)