# This script power analysis for boundary VR
# 
# /* 
# ----------------------------- General stuff ---------------------------
# */
# Setting seed
set.seed(322)

# Library
library(plyr)
library(ggplot2)
library(cowplot)
theme_set(theme_grey()) # Important to retain the ggplot theme
library(ez)

# /* 
# ----------------------------- Load data frame ---------------------------
# */
prefix         <- 'U:/Projects/boundaryVR/analysis/powerAnalysisData/'
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
  
  if(i == 1){
    temporalOrder_comb    <- temporalOrder
    temporalOrder_comb$id <- i
  } else {
    temporalOrder$id   <- i
    temporalOrder_comb <- rbind(temporalOrder_comb, temporalOrder)
  }
}


# Create a data.frame that can used to do power analysis
# Duplicate data sets
simData1 <- temporalOrder_comb
simData2 <- temporalOrder_comb
simData3 <- temporalOrder_comb

# change ID
simData2$id <- simData2$id + 4
simData3$id <- simData3$id + 8

simData <- rbind(simData1, simData2, simData3)

# /* 
# ----------------------------- Simulation ---------------------------
# */
# Sim parameters
nSim        <- 10000
simResults  <- list()
responseOpt <- c(1, 2, 3)
nTrials     <- dim(simData)[1]
accuracy    <- rep(NA, dim(simData)[1])


# Simulation loop
for(i in 1:nSim){
  # Shuffle responses
  simData$response <- sample(responseOpt, nTrials, replace = TRUE)
  
  # Relcalate accuracy
  accuracy[simData$response == simData$corr_resp] <- 1
  accuracy[simData$response != simData$corr_resp] <- 0
  simData$accuracy <- accuracy
  
  
  simResults[i]    <- list(data = ddply(simData, 
                                        c('id','context'), 
                                        summarise,
                                        n = length(rt),
                                        acc = mean(accuracy),
                                        number = sum(accuracy)))
  
}

# /* 
# ----------------------------- Calculate p-values ---------------------------
# */
pValues     <- c()
for(i in 1:nSim){
  tempData    <- simResults[[i]]
  tempData$id <- as.factor(tempData$id)
  tempResults <- ezANOVA(tempData , dv = acc, wid = id, within = context)
  pValues[i] <- tempResults$`Sphericity Corrections`$`p[GG]`
}

# /* 
# ----------------------------- Create 1 data frame ---------------------------
# */
for(i in 1:nSim){
  if(i == 1){
    df <- simResults[[i]] 
  } else {
    df <- rbind(df, simResults[[i]] )
  }
}

# Plot
ggplot(df, aes(x = context, y = acc)) + 
  geom_boxplot(alpha = 0.5,outlier.shape = NA) + 
  geom_jitter(width = 0.1) +
  geom_hline(yintercept = 1/3) +
  annotate('text', x = 2, y = 0.31, label = 'Chance') +
  labs(y = '3AFC accuracy', x = "Room type", title = 'Temporal Order')

sort(table(df$acc))

