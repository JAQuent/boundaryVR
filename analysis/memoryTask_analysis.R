# Analysis of pilot data

library(plyr)
library(ggplot2)
library(cowplot)
theme_set(theme_grey()) # Important to retain the ggplot theme
library(ez)

# Load all data
prefix         <- 'U:/Projects/boundaryVR/analysis/batch3/memoryTask/'
#prefix         <- 'U:/Projects/boundaryVR/analysis/batch3/memoryTask/'
allFiles       <- list.files(paste(prefix, sep = ''))
allFiles_paths <- paste(prefix, allFiles, sep = '')
n              <- length(allFiles_paths)

for(i in 1:n){
  tempDF <- read.csv(allFiles_paths[i], header = TRUE, na.strings = '')
  # To be able to visualise
  #tempDF$stimulus         <- NULL 
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
  
  # Calcalate accuracy
  accuracy <- rep(NA, dim(temporalOrder)[1])
  accuracy[temporalOrder$response == temporalOrder$corr_resp] <- 1
  accuracy[temporalOrder$response != temporalOrder$corr_resp] <- 0
  temporalOrder$accuracy <- accuracy
  
  roomType      <- subset(tempDF, test_part == 'roomType')
  roomType$rt   <- as.numeric(as.character(roomType$rt))
  response      <- rep(NA, dim(roomType)[1])
  response[roomType$key_press == 49] <- 1
  response[roomType$key_press == 50] <- 2
  roomType$response                  <- response
  accuracy <- rep(NA, dim(roomType)[1])
  accuracy[roomType$response == roomType$corr_resp] <- 1
  accuracy[roomType$response != roomType$corr_resp] <- 0
  roomType$accuracy <- accuracy
  
  tableNum      <- subset(tempDF, test_part == 'tableNum')
  tableNum$rt   <- as.numeric(as.character(tableNum$rt))
  response      <- rep(NA, dim(tableNum)[1])
  response[tableNum$key_press == 49] <- 3 # for key press 1
  response[tableNum$key_press == 50] <- 2 # for key press 2
  tableNum$response                  <- response
  accuracy <- rep(NA, dim(tableNum)[1])
  accuracy[tableNum$response == tableNum$corr_resp] <- 1
  accuracy[tableNum$response != tableNum$corr_resp] <- 0
  tableNum$accuracy <- accuracy
  
  if(i == 1){
    temporalOrder_comb    <- temporalOrder
    temporalOrder_comb$id <- i
    roomType_comb         <- roomType
    roomType_comb$id      <- i
    tableNum_comb         <- tableNum
    tableNum_comb$id      <- i
  } else {
    temporalOrder$id   <- i
    temporalOrder_comb <- rbind(temporalOrder_comb, temporalOrder)
    roomType$id        <- i
    roomType_comb      <- rbind(roomType_comb, roomType)
    tableNum$id        <- i
    tableNum_comb      <- rbind(tableNum_comb, tableNum)
  }
}

temporalOrder_comb$id <- as.factor(temporalOrder_comb$id)
roomType_comb$id      <- as.factor(roomType_comb$id)
tableNum_comb$id      <- as.factor(tableNum_comb$id)



temporalOrder_agg <- ddply(temporalOrder_comb, c('id','worker_id', 'context'), 
                           summarise, 
                           n = length(rt),
                           acc = mean(accuracy), 
                           number = sum(accuracy),
                           rt = mean(rt),
                           condition = condition[1])
temporalOrder_agg

conditions <- ddply(temporalOrder_comb, c('id', 'worker_id'), summarise, condition = condition[1])
table(conditions$condition)


afcPlot <- ggplot(temporalOrder_agg, aes(x = context, y = acc)) + 
  geom_boxplot(alpha = 0.5,outlier.shape = NA) + 
  geom_jitter(width = 0.1) +
  geom_hline(yintercept = 1/3) +
  annotate('text', x = 2, y = 0.31, label = 'Chance') +
  labs(y = '3AFC accuracy', x = "Room type", title = 'Temporal Order')


rtPlot <- ggplot(temporalOrder_agg, aes(x = context, y = rt)) + 
  geom_boxplot(alpha = 0.5, outlier.shape = NA) + 
  geom_jitter(width = 0.5) +
  labs(y = 'RT (msec)', x = "Room type", title = '')

plot_grid(afcPlot, rtPlot)


roomType_comb_agg <- ddply(roomType_comb, c('id'), summarise, acc = mean(accuracy), rt = mean(rt))
tableNum_comb_agg <- ddply(tableNum_comb, c('id'), summarise, acc = mean(accuracy), rt = mean(rt))

# Tests
# Overall against chance
overall  <- ddply(temporalOrder_comb, c('id'), summarise, acc = mean(accuracy))
t.test(overall$acc - 1/3)

# Temporal order
ezANOVA(temporalOrder_agg, dv = acc, wid = id, within = context)


# Room type task against chance
t.test(roomType_comb_agg$acc - 0.5)

#  Table task against chance
t.test(tableNum_comb_agg$acc - 0.5)

