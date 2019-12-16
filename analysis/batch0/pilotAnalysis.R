# Analysis of pilot data
load("U:/Projects/boundary/boundaryAnalysis/trialData_video2.RData")
trialData_video2 <- trialData_video2[order(trialData_video2$objNum),]

library(plyr)
library(ggplot2)
library(cowplot)
theme_set(theme_grey()) # Important to retain the ggplot theme

# Load all data
folder         <- 'testData/'
prefix         <- 'U:/Projects/boundary/boundaryAnalysis/'
allFiles       <- list.files(paste(prefix, folder, sep = ''))
allFiles_paths <- paste(prefix, folder, allFiles, sep = '')
bla            <- matrix(NA, nrow = n, ncol = 22)

allFiles_paths <- 'jatos_results_20191104073801'
n              <- length(allFiles_paths)

for(i in 1:n){
  tempDF <- read.csv(allFiles_paths[i], header = TRUE, na.strings = '')
  # To be able to visualise
  tempDF$stimulus         <- NULL 
  tempDF$success          <- NULL
  tempDF$trial_type       <- NULL
  tempDF$internal_node_id <- NULL
  
  temporalOrder    <- subset(tempDF, test_part == 'temporalOrder')
  temporalOrder$rt <- as.numeric(as.character(temporalOrder$rt))
  
  response      <- rep(NA, dim(temporalOrder)[1])
  response[temporalOrder$key_press == 49] <- 1
  response[temporalOrder$key_press == 50] <- 2
  response[temporalOrder$key_press == 51] <- 3
  temporalOrder$response                  <- response
  
  # Sort by objNum
  temporalOrder <- temporalOrder[order(temporalOrder$probe),]
  
  # Add trial data
  temporalOrder$objNam       <- trialData_video2$objNam
  temporalOrder$room         <- trialData_video2$room
  temporalOrder$tempQuestion <- trialData_video2$tempQuestion
  temporalOrder$sameRoom     <- trialData_video2$sameRoom
  
  # Calculate conditions
  expConditions <- rep(NA, dim(temporalOrder)[1])
  expConditions[temporalOrder$sameRoom == 0] <- 'across'
  expConditions[temporalOrder$sameRoom == 1 & temporalOrder$room %% 2 == 0] <- 'walls'
  expConditions[temporalOrder$sameRoom == 1 & temporalOrder$room %% 2 != 0] <- 'no-walls'
  temporalOrder$expConditions <- expConditions
  
  # Calcalate accuracy
  accuracy <- rep(NA, dim(temporalOrder)[1])
  accuracy[temporalOrder$response == temporalOrder$correct_response] <- 1
  accuracy[temporalOrder$response != temporalOrder$correct_response] <- 0
  temporalOrder$accuracy <- accuracy
  bla[i, ] <- temporalOrder[temporalOrder$expConditions == 'no-walls', 'accuracy']
  
  # Aggregate
  agg1 <- ddply(temporalOrder, c('expConditions'), summarise, acc = mean(accuracy), rt = mean(rt))
  
  # Context memory
  contextMemory    <- subset(tempDF, test_part == 'contextMemory')
  contextMemory$rt <- as.numeric(as.character(contextMemory$rt))
  
  response      <- rep(NA, dim(contextMemory)[1])
  response[contextMemory$key_press == 49] <- 1
  response[contextMemory$key_press == 50] <- 2
  response[contextMemory$key_press == 51] <- 3
  contextMemory$response                  <- response
  
  # Sort by objNum
  contextMemory <- contextMemory[order(contextMemory$probe),]
  
  # Add trial data
  contextMemory$objNam       <- trialData_video2$objNam
  contextMemory$room         <- trialData_video2$room
  contextMemory$tempQuestion <- trialData_video2$tempQuestion
  contextMemory$sameRoom     <- trialData_video2$sameRoom
  
  # Calculate conditions
  expConditions <- rep(NA, dim(contextMemory)[1])
  expConditions[contextMemory$room %% 2 == 0] <- 'walls'
  expConditions[contextMemory$room %% 2 != 0] <- 'no-walls'
  contextMemory$expConditions <- expConditions
  
  # Calcalate accuracy
  accruacy <- rep(NA, dim(contextMemory)[1])
  accruacy[contextMemory$response == contextMemory$correct_response] <- 1
  accruacy[contextMemory$response != contextMemory$correct_response] <- 0
  contextMemory$accuracy <- accruacy
  
  # Aggregate
  agg2 <- ddply(contextMemory, c('expConditions'), summarise, acc = mean(accuracy), rt = mean(rt))
  
  if(i == 1){
    temporalOrder_agg <- agg1
    contextMemory_agg <- agg2
  } else {
    temporalOrder_agg <- rbind(temporalOrder_agg, agg1)
    contextMemory_agg <- rbind(contextMemory_agg, agg2)
  }
}

ddply(temporalOrder_agg, c('expConditions'), summarise, acc = mean(acc), rt = mean(rt))
ddply(contextMemory_agg, c('expConditions'), summarise, acc = mean(acc), rt = mean(rt))

# Plot
accPlot_temp <- ggplot(temporalOrder_agg, aes(x = expConditions, y = acc)) + 
  geom_boxplot() + 
  geom_hline(yintercept = 0.33) +
  annotate('text', x = 2, y = 0.31, label = 'Chance') +
  labs(y = '3AFC accuracy', x = "Room type", title = 'Temporal Order')

accPlot_con<- ggplot(contextMemory_agg, aes(x = expConditions, y = acc)) + 
  geom_boxplot() + 
  geom_hline(yintercept = 0.33) +
  annotate('text', x = 2, y = 0.31, label = 'Chance') +
  labs(y = '3AFC accuracy', x = "Room type", title = 'Context memory')

rtPlot_temp <- ggplot(temporalOrder_agg, aes(x = expConditions, y = rt)) + 
  geom_boxplot() + 
  labs(y = 'RT', x = "Room type")
rtPlot_con<- ggplot(contextMemory_agg, aes(x = expConditions, y = rt)) + 
  geom_boxplot() + 
  labs(y = 'RT', x = "Room type")

combinedPlot <- plot_grid(accPlot_temp, accPlot_con, rtPlot_temp, rtPlot_con, ncol = 2)
save_plot("combinedPlot.png", combinedPlot,
          base_height = 16/cm(1),
          base_width = 16/cm(1),
          base_aspect_ratio = 1)