# This script power analysis for boundary VR - Exp 2
# Version 2.0
# 
# /* 
# ----------------------------- General stuff ---------------------------
# */
# Setting seed
set.seed(224)

# Libraries
library(doParallel)
library(BayesFactor)

# Money and experiment parameteres
balance      <- 431.66 # GBP
payPerHour   <- 6      # GBP
surcharge    <- 1.4    # GBP Percent from prolific
expDuration  <- 40/60  # Hours
costPerSlot  <- expDuration*payPerHour*surcharge # GBP
maxSlots     <- floor(balance/costPerSlot) # Maximum number of slots with that balance and costs
slotsPerCond <- floor((floor(maxSlots/2)/4))*4 # Maximum number of slots per between subject condition

# Effect sizes 
d0  <- 0.89 # across vs. within (Collapsed across both room types)
d1  <- 0.44 # within-open plane vs. across
d2  <- 0.78 # within-M-shape vs. across
#d3  <- 0.52 # within-M-shape vs. within-open plane. This is now a between subject comparison

# /* 
# ----------------------------- Function and parameters for simulation ---------------------------
# */
# Function
sequential_tTest_oneSample_directed <- function(params){
  # Parse input
  maxN      <- params[1]
  minN      <- params[2]
  d         <- params[3]
  crit      <- params[4]
  increment <- as.numeric(params[5])
  addedN    <- (maxN - minN)/increment
  bf        <- c()
  results   <- list()
  
  # Create minium sample and calculate BF
  n    <- as.numeric(minN)
  data <- rnorm(n, d, 1)
  bf   <- reportBF(ttestBF(data, nullInterval = c(-Inf, 0))[2], 4)
  
  # Within simulation loop
  if(bf[1] < crit & bf[1] > 1/crit){
    for(i in 1:addedN){
      data      <- c(data, rnorm(increment, d, 1))
      n         <- n + increment
      bf[i + 1] <- reportBF(ttestBF(data, nullInterval = c(-Inf, 0))[2], 4)
      
      if(bf[i + 1] > crit | bf[i + 1] < 1/crit){
        break
      }
    }
  } 
  
  # Return results
  results$n    <- n 
  results$data <- data
  results$bf   <- bf
  return(results)
}

# Setting parameters 
nIter       <- 10000
minN        <- 12
increment   <- 4
crit        <- 6
paramsH0    <- data.frame(maxN = rep(slotsPerCond, nIter),
                          minN = rep(minN, nIter),
                          d    = rep(0, nIter),
                          crit = rep(crit, nIter),
                          increment = rep(increment, nIter))

paramsH1    <- data.frame(maxN = rep(slotsPerCond, nIter),
                          minN = rep(minN, nIter),
                          d    = rep(d1, nIter),
                          crit = rep(crit, nIter),
                          increment = rep(increment, nIter))

paramsH2    <- data.frame(maxN = rep(slotsPerCond, nIter),
                          minN = rep(minN, nIter),
                          d    = rep(d2, nIter),
                          crit = rep(crit, nIter),
                          increment = rep(increment, nIter))

# /* 
# ----------------------------- Simulation ---------------------------
# */
# Create Cluster
no_cores <- detectCores() - 2 
registerDoParallel(cores = no_cores)  
cl       <- makeCluster(no_cores)  
clusterExport(cl, c('ttestBF', 'reportBF'))

# Run Simulation
results_H0 <- parRapply(cl, paramsH0, sequential_tTest_oneSample_directed)
results_H1 <- parRapply(cl, paramsH1, sequential_tTest_oneSample_directed)  
results_H2 <- parRapply(cl, paramsH2, sequential_tTest_oneSample_directed)  
stopCluster(cl)  

# Convert to DF
#H0
for(i in 1:nIter){
  if(i == 1){
    df_H0 <- data.frame(id = i,
                        n = seq(minN, results_H0[[i]]$n, increment),
                        bf = results_H0[[i]]$bf)
  } else {
    temp <- data.frame(id = i,
                       n = seq(minN, results_H0[[i]]$n, increment),
                       bf = results_H0[[i]]$bf)
    df_H0 <- rbind(df_H0, temp)
  }
}

#H1
# Parse list to df
for(i in 1:nIter){
  if(i == 1){
    df_H1 <- data.frame(id = i,
                        n = seq(minN, results_H1[[i]]$n, increment),
                        bf = results_H1[[i]]$bf)
  } else {
    temp <- data.frame(id = i,
                       n = seq(minN, results_H1[[i]]$n, increment),
                       bf = results_H1[[i]]$bf)
    df_H1 <- rbind(df_H1, temp)
  }
}

#H2
# Parse list to df
for(i in 1:nIter){
  if(i == 1){
    df_H2 <- data.frame(id = i,
                        n = seq(minN, results_H2[[i]]$n, increment),
                        bf = results_H2[[i]]$bf)
  } else {
    temp <- data.frame(id = i,
                       n = seq(minN, results_H2[[i]]$n, increment),
                       bf = results_H2[[i]]$bf)
    df_H2 <- rbind(df_H2, temp)
  }
}


# Save results
save.image('powerAnalysis_Exp2_2.RData')