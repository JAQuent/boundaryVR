# Analysis of pilot data

library(plyr)
library(ggplot2)
library(cowplot)
theme_set(theme_grey()) # Important to retain the ggplot theme
library(ez)

# Load all data
prefix         <- 'U:/Projects/boundaryVR/ignore_boundaryAnalysis/combinedBatches/'
allFiles       <- list.files(paste(prefix, sep = ''))
allFiles_paths <- paste(prefix, allFiles, sep = '')
n              <- length(allFiles_paths)

for(i in 1:n){
  tempDF <- read.csv(allFiles_paths[i], header = TRUE, na.strings = '')
  # To be able to visualise
  tempDF$stimulus         <- NULL 
  tempDF$success          <- NULL
  tempDF$trial_type       <- NULL
  tempDF$internal_node_id <- NULL
  
  # Reformating for different files
  tempDF <- data.frame(test_part = tempDF$test_part,
                       rt = tempDF$rt,
                       key_press = tempDF$key_press,
                       context = tempDF$context,
                       corr_resp = tempDF$corr_resp)

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
  

  
  if(i == 1){
    temporalOrder_comb    <- temporalOrder
    temporalOrder_comb$id <- i
  } else {
    temporalOrder$id   <- i
    temporalOrder_comb <- rbind(temporalOrder_comb, temporalOrder)
  }
}

temporalOrder_comb$id <- as.factor(temporalOrder_comb$id)

temporalOrder_comb <- subset(temporalOrder_comb, temporalOrder_comb$condition != 6 | temporalOrder_comb$condition != 7)

temporalOrder_agg <- ddply(temporalOrder_comb, c('worker_id', 'context'), summarise, acc = mean(accuracy), rt = mean(rt), condition = condition[1])
temporalOrder_agg

afcPlot <- ggplot(temporalOrder_agg, aes(x = context, y = acc)) + 
  geom_boxplot(alpha = 0.5,outlier.shape = NA) + 
  geom_jitter(width = 0.1, height = 0) +
  geom_hline(yintercept = 1/3) +
  annotate('text', x = 2, y = 0.31, label = 'Chance') +
  labs(y = '3AFC accuracy', x = "Room type", title = 'Temporal Order')


rtPlot <- ggplot(temporalOrder_agg, aes(x = context, y = rt)) + 
  geom_boxplot(alpha = 0.5, outlier.shape = NA) + 
  geom_jitter(width = 0.5, height = 0) +
  labs(y = 'RT (msec)', x = "Room type", title = '')

plot_grid(afcPlot, rtPlot)



# Tests
# Overall against chance
overall  <- ddply(temporalOrder_comb, c('id'), summarise, acc = mean(accuracy))
t.test(overall$acc - 1/3)

# Each condition against chance
t.test(temporalOrder_agg$acc[temporalOrder_agg$context =='across'] - 1/3)
t.test(temporalOrder_agg$acc[temporalOrder_agg$context =='within-no-walls'] - 1/3)
t.test(temporalOrder_agg$acc[temporalOrder_agg$context =='within-walls'] - 1/3)

# Temporal order
ezANOVA(temporalOrder_agg, dv = acc, wid = id, within = context)


t.test(tableNum_comb_agg$acc - 0.5)
t.test(roomType_comb_agg$acc - 0.5)