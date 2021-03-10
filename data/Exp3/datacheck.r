# # Data was generated so that within is always correct and across is always wrong
# setwd("~/boundaryVR/data/Exp3/dataCheck")
# 
# data <- read.csv('jatos_results_20210127162354.txt', header = TRUE, na.strings = '')
# 
# 
# response      <- rep(NA, nrow(data))
# response[data$key_press == 49] <- 1
# response[data$key_press == 50] <- 2
# response[data$key_press == 51] <- 3
# data$response                  <- response
# 
# temporalOrder1 <- subset(data, test_part == 'temporalOrder')
# 
# 
# # Calculate accuracy 
# accuracy <- rep(NA, nrow(temporalOrder1))
# accuracy[temporalOrder1$response == temporalOrder1$corr_resp] <- 1
# accuracy[temporalOrder1$response != temporalOrder1$corr_resp] <- 0
# 
# temporalOrder1$accuracy <- accuracy
# 
# 
# ddply(temporalOrder1, c('context'), summarise, mean(accuracy))
# 
# 
# data1 <- read.csv('~/boundaryVR/data/Exp3/batch1/memoryTask1/jatos_results_20210127190833.txt', header = TRUE, na.strings = '')
# data2 <- read.csv('~/boundaryVR/data/Exp3/batch1/memoryTask2/jatos_results_20210127190919.txt', header = TRUE, na.strings = '')
# 

library(ggplot2)
library(BayesFactor)
library(plyr)
library(assortedRFunctions)

###################################################################
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
  # Loading daya
  tempDF <- read.csv(allFiles1_paths[i], header = TRUE, na.strings = '')
  
  # Recode key presses
  response      <- rep(NA, nrow(tempDF))
  response[tempDF$key_press == 49] <- 1
  response[tempDF$key_press == 50] <- 2
  response[tempDF$key_press == 51] <- 3
  tempDF$response                  <- response
  
  # Convert RT to numeric  
  tempDF$rt <- suppressWarnings(as.numeric(as.character(tempDF$rt)))
  
  ############
  # Temporal order memory 1
  temporalOrder1 <- subset(tempDF, test_part == 'temporalOrder')
  
  # Calculate accuracy 
  accuracy <- rep(NA, nrow(temporalOrder1))
  accuracy[temporalOrder1$response == temporalOrder1$corr_resp] <- 1
  accuracy[temporalOrder1$response != temporalOrder1$corr_resp] <- 0
  temporalOrder1$accuracy <- accuracy
  
  # Create variable that describe whether target, foil1, foil2 was chosen
  choice <- rep('Target', nrow(temporalOrder1))
  choice[temporalOrder1$response == temporalOrder1$foil1Pos] <- 'Foil 1'
  choice[temporalOrder1$response == temporalOrder1$foil2Pos] <- 'Foil 2'
  temporalOrder1$choice <- choice
  
  
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
  # Loading daya
  tempDF <- read.csv(allFiles2_paths[i], header = TRUE, na.strings = '')
  
  # Recode key presses
  response      <- rep(NA, nrow(tempDF))
  response[tempDF$key_press == 49] <- 1
  response[tempDF$key_press == 50] <- 2
  response[tempDF$key_press == 51] <- 3
  tempDF$response                  <- response
  
  # Convert RT to numeric  
  tempDF$rt <- suppressWarnings(as.numeric(as.character(tempDF$rt)))
  
  ############
  # Temporal order memory 1
  temporalOrder1 <- subset(tempDF, test_part == 'temporalOrder')
  
  # Calculate accuracy 
  accuracy <- rep(NA, nrow(temporalOrder1))
  accuracy[temporalOrder1$response == temporalOrder1$corr_resp] <- 1
  accuracy[temporalOrder1$response != temporalOrder1$corr_resp] <- 0
  temporalOrder1$accuracy <- accuracy
  
  # Create variable that desribe whether target, foil1, foil2 was choosen
  choice <- rep('Target', nrow(temporalOrder1))
  choice[temporalOrder1$response == temporalOrder1$foil1Pos] <- 'Foil 1'
  choice[temporalOrder1$response == temporalOrder1$foil2Pos] <- 'Foil 2'
  temporalOrder1$choice <- choice
  
  
  # Create or bind to data.frame
  if(i == 1){
    df_order_exp3_h2    <- temporalOrder1
    df_order_exp3_h2$id <- i
  } else {
    temporalOrder1$id <- i
    df_order_exp3_h2    <- rbind(df_order_exp3_h2, temporalOrder1)
  }
}


df_order_exp3 <- rbind(df_order_exp3_h1, df_order_exp3_h2)
df_order_exp3$half <- factor(df_order_exp3$half, levels = c(0, 1), labels = c('h1', 'h2'))

# Outlier detection
outlier_data <- ddply(df_order_exp3, c('worker_id'), summarise, accuracy = mean(accuracy), rt = mean(rt))
outlier_data$trans_acc         <- arcsine_transform(outlier_data$accuracy)
outlier_data$trans_acc_outlier <- mad_outlier(outlier_data$trans_acc, 2)
outlier_data$rt_outlier        <- mad_outlier(outlier_data$rt, 3)

# Outlier removal
df_order_exp3 <- df_order_exp3[!(df_order_exp3$worker_id %in% c(15177, outlier_data[outlier_data$trans_acc_outlier == 1, 'worker_id'])), ] 
# 15177 Didn't do whole task


agg1 <- ddply(df_order_exp3, c('worker_id', 'subjCond', 'half','context'), summarise, accuracy = mean(accuracy), rt = mean(rt))
agg2 <- ddply(df_order_exp3, c('worker_id', 'subjCond','context'), summarise, accuracy = mean(accuracy), rt = mean(rt))

agg2$trans_acc         <- arcsine_transform(agg2$accuracy)

ggplot(agg2, aes(x = context, y = rt)) + geom_hline(yintercept = arcsine_transform(1/3)) +
  geom_line(aes(group = worker_id)) +
  geom_point() + 
  geom_boxplot() 

ggplot(agg2, aes(x = context, y = trans_acc)) + geom_hline(yintercept = arcsine_transform(1/3)) +
  #facet_grid(~ subjCond) +
  geom_line(aes(group = worker_id)) +
  geom_point() + 
  geom_boxplot() 

ttestBF(agg2[agg2$context == 'within', "trans_acc"], 
        agg2[agg2$context == 'across', "trans_acc"], 
        paired = TRUE, 
        nullInterval = c(-Inf, 0))



t.test(agg2[agg2$context == 'within', "trans_acc"], agg2[agg2$context == 'across', "trans_acc"], alternative = 'greater')$p.value
#ggplot(agg2, aes(x = context, y = rt)) + geom_boxplot() + geom_line(aes(group = worker_id)) + geom_point()

table(agg1$worker_id)
length(unique(agg2$worker_id))

ddply(df_order_exp3, c('context'), summarise, accuracy = arcsine_transform(mean(accuracy)), rt = mean(rt))