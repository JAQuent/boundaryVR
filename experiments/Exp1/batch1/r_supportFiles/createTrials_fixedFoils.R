# This script creates trials for boundaryVR memory task as a javascript for batch 1 and 2
# /* 
# ----------------------------- General stuff ---------------------------
# */
before       <- 'In the video you just watched, which one of the three objects at the bottom of the screen appeared immediately before this object?'
after        <- 'In the video you just watched, which one of the three objects at the bottom of the screen appeared immediately after this object?'

# Setting wd
setwd("~/boundaryVR/experiments/Exp1/batch1/r_supportFiles")

# Loading object order
objectOrder        <- read.csv('objectOrder.csv', sep = '\t', header = FALSE)
names(objectOrder) <- c('objNum', 'objNam')
numObj             <- length(objectOrder$objNum)

# Setting seed
set.seed(322)

# Library
library(rjson)
library(assortedRFunctions)

# /* 
# ----------------------------- Condition 1 ---------------------------
# */
# Video 1 + before
rooms                 <- numObj/2
trials_cond1          <- objectOrder
trials_cond1$table    <- rep(c(2, 3), rooms/2)
trials_cond1$room     <- rep(1:rooms, each = 2)
trials_cond1$roomType <- rep(c('ww', 'ww', 'nw', 'nw'), rooms/2)
trials_cond1$target   <- c(NA, trials_cond1$objNum[1:(numObj-1)])

# Selecting foils that is in same room and in same position
foil1 <- rep(NA, numObj)
foil2 <- rep(NA, numObj)
for(i in 1:numObj){
  if(i - 5 >= 1){
    # run only if defined
    foil1[i] <- trials_cond1$objNum[i - 5]
  }
  if(i + 5 <= numObj){
    # run only if defined
    foil2[i] <- trials_cond1$objNum[i + 3]
  }
}
trials_cond1$foil1 <- foil1
trials_cond1$foil2 <- foil2

# Add position of target and foils on the screen during 3AFC task
targetPos <- c()
foil1Pos  <- c()
foil2Pos  <- c()
for(i in 1:dim(trials_cond1)[1]){
  shuffle        <- sample(1:3)
  targetPos[i] <- shuffle[1]
  foil1Pos[i]  <- shuffle[2]
  foil2Pos[i]  <- shuffle[3]
}
trials_cond1$targetPos <- targetPos
trials_cond1$foil1Pos  <- foil1Pos
trials_cond1$foil2Pos  <- foil2Pos
trials_cond1$corRoom   <- 1 # for nw rooms
trials_cond1$corRoom[trials_cond1$roomType == 'ww'] <- 2
trials_cond1$question <- before

# Get same room and context information
sameRoom   <- rep(NA, numObj)
for(i in 1:numObj){
  if(trials_cond1$question[i] == after){
    if(i + 1 < 89){
      if(trials_cond1$room[i + 1] == trials_cond1$room[i]){
        sameRoom[i] <- 1
      } else {
        sameRoom[i] <- 0
      }
    }
  } else {
    if(i - 1 > 0){
      if(trials_cond1$room[i - 1] == trials_cond1$room[i]){
        sameRoom[i] <- 1
      } else {
        sameRoom[i] <- 0
      }
    }
  }
}
trials_cond1$sameRoom   <- sameRoom
context <- rep(NA, numObj)
context[trials_cond1$sameRoom == 0] <- 'across'
context[trials_cond1$sameRoom == 1 & trials_cond1$roomType == 'ww'] <- 'within-walls'
context[trials_cond1$sameRoom == 1 & trials_cond1$roomType == 'nw'] <- 'within-no-walls'
trials_cond1$context <- context

# /* 
# ----------------------------- Condition 2 ---------------------------
# */
# Video 2 + before
rooms                 <- numObj/2
trials_cond2          <- objectOrder
trials_cond2$table    <- rep(c(2, 3), rooms/2)
trials_cond2$room     <- rep(1:rooms, each = 2)
trials_cond2$roomType <- rep(c('nw', 'nw', 'ww', 'ww'), rooms/2)
trials_cond2$target   <- c(NA, trials_cond2$objNum[1:(numObj-1)])

# Selecting foils that is in same room and in same position
foil1 <- rep(NA, numObj)
foil2 <- rep(NA, numObj)
for(i in 1:numObj){
  if(i - 5 >= 1){
    # run only if defined
    foil1[i] <- trials_cond2$objNum[i - 5]
  }
  if(i + 5 <= numObj){
    # run only if defined
    foil2[i] <- trials_cond2$objNum[i + 3]
  }
}
trials_cond2$foil1 <- foil1
trials_cond2$foil2 <- foil2

# Add position of target and foils on the screen during 3AFC task
targetPos <- c()
foil1Pos  <- c()
foil2Pos  <- c()
for(i in 1:dim(trials_cond2)[1]){
  shuffle        <- sample(1:3)
  targetPos[i] <- shuffle[1]
  foil1Pos[i]  <- shuffle[2]
  foil2Pos[i]  <- shuffle[3]
}
trials_cond2$targetPos <- targetPos
trials_cond2$foil1Pos  <- foil1Pos
trials_cond2$foil2Pos  <- foil2Pos
trials_cond2$corRoom   <- 1 # for nw rooms
trials_cond2$corRoom[trials_cond2$roomType == 'ww'] <- 2
trials_cond2$question <- before

# Get same room and context information
sameRoom   <- rep(NA, numObj)
for(i in 1:numObj){
  if(trials_cond2$question[i] == after){
    if(i + 1 < 89){
      if(trials_cond2$room[i + 1] == trials_cond2$room[i]){
        sameRoom[i] <- 1
      } else {
        sameRoom[i] <- 0
      }
    }
  } else {
    if(i - 1 > 0){
      if(trials_cond2$room[i - 1] == trials_cond2$room[i]){
        sameRoom[i] <- 1
      } else {
        sameRoom[i] <- 0
      }
    }
  }
}
trials_cond2$sameRoom   <- sameRoom
context <- rep(NA, numObj)
context[trials_cond2$sameRoom == 0] <- 'across'
context[trials_cond2$sameRoom == 1 & trials_cond2$roomType == 'ww'] <- 'within-walls'
context[trials_cond2$sameRoom == 1 & trials_cond2$roomType == 'nw'] <- 'within-no-walls'
trials_cond2$context <- context

# /* 
# ----------------------------- Condition 3 ---------------------------
# */
# Video 3 + before
rooms                 <- numObj/2+1
trials_cond3          <- objectOrder
trials_cond3$table    <- c(rep(c(3, 2), (rooms - 1)/2))
room                  <- rep(1:rooms, each = 2)
trials_cond3$room     <- room[2:(length(room)-1)]
roomType              <- rep(c('nw', 'nw', 'ww', 'ww'),21)
trials_cond3$roomType <- c('ww', roomType, 'nw', 'nw', 'ww')
trials_cond3$target   <- c(NA, trials_cond3$objNum[1:(numObj-1)])

# Selecting foils that is in same room and in same position
foil1 <- rep(NA, numObj)
foil2 <- rep(NA, numObj)
for(i in 1:numObj){
  if(i - 5 >= 1){
    # run only if defined
    foil1[i] <- trials_cond3$objNum[i - 5]
  }
  if(i + 5 <= numObj){
    # run only if defined
    foil2[i] <- trials_cond3$objNum[i + 3]
  }
}
trials_cond3$foil1 <- foil1
trials_cond3$foil2 <- foil2

# Add position of target and foils on the screen during 3AFC task
targetPos <- c()
foil1Pos  <- c()
foil2Pos  <- c()
for(i in 1:dim(trials_cond3)[1]){
  shuffle        <- sample(1:3)
  targetPos[i] <- shuffle[1]
  foil1Pos[i]  <- shuffle[2]
  foil2Pos[i]  <- shuffle[3]
}
trials_cond3$targetPos <- targetPos
trials_cond3$foil1Pos  <- foil1Pos
trials_cond3$foil2Pos  <- foil2Pos
trials_cond3$corRoom   <- 1 # for nw rooms
trials_cond3$corRoom[trials_cond3$roomType == 'ww'] <- 2
trials_cond3$question <- before

# Get same room and context information
sameRoom   <- rep(NA, numObj)
for(i in 1:numObj){
  if(trials_cond3$question[i] == after){
    if(i + 1 < 89){
      if(trials_cond3$room[i + 1] == trials_cond3$room[i]){
        sameRoom[i] <- 1
      } else {
        sameRoom[i] <- 0
      }
    }
  } else {
    if(i - 1 > 0){
      if(trials_cond3$room[i - 1] == trials_cond3$room[i]){
        sameRoom[i] <- 1
      } else {
        sameRoom[i] <- 0
      }
    }
  }
}
trials_cond3$sameRoom   <- sameRoom
context <- rep(NA, numObj)
context[trials_cond3$sameRoom == 0] <- 'across'
context[trials_cond3$sameRoom == 1 & trials_cond3$roomType == 'ww'] <- 'within-walls'
context[trials_cond3$sameRoom == 1 & trials_cond3$roomType == 'nw'] <- 'within-no-walls'
trials_cond3$context <- context


# /* 
# ----------------------------- Condition 4 ---------------------------
# */
# Video 4 + before
rooms                 <- numObj/2+1
trials_cond4          <- objectOrder
trials_cond4$table    <- c(rep(c(3, 2), (rooms - 1)/2))
room                  <- rep(1:rooms, each = 2)
trials_cond4$room     <- room[2:(length(room)-1)]
roomType              <- rep(c('ww', 'ww', 'nw', 'nw'),21)
trials_cond4$roomType <- c('nw', roomType, 'ww', 'ww', 'nw')
trials_cond4$target   <- c(NA, trials_cond4$objNum[1:(numObj-1)])

# Selecting foils that is in same room and in same position
foil1 <- rep(NA, numObj)
foil2 <- rep(NA, numObj)
for(i in 1:numObj){
  if(i - 5 >= 1){
    # run only if defined
    foil1[i] <- trials_cond4$objNum[i - 5]
  }
  if(i + 5 <= numObj){
    # run only if defined
    foil2[i] <- trials_cond4$objNum[i + 3]
  }
}
trials_cond4$foil1 <- foil1
trials_cond4$foil2 <- foil2

# Add position of target and foils on the screen during 3AFC task
targetPos <- c()
foil1Pos  <- c()
foil2Pos  <- c()
for(i in 1:dim(trials_cond4)[1]){
  shuffle        <- sample(1:3)
  targetPos[i] <- shuffle[1]
  foil1Pos[i]  <- shuffle[2]
  foil2Pos[i]  <- shuffle[3]
}
trials_cond4$targetPos <- targetPos
trials_cond4$foil1Pos  <- foil1Pos
trials_cond4$foil2Pos  <- foil2Pos
trials_cond4$corRoom   <- 1 # for nw rooms
trials_cond4$corRoom[trials_cond4$roomType == 'ww'] <- 2
trials_cond4$question <- before

# Get same room and context information
sameRoom   <- rep(NA, numObj)
for(i in 1:numObj){
  if(trials_cond4$question[i] == after){
    if(i + 1 < 89){
      if(trials_cond4$room[i + 1] == trials_cond4$room[i]){
        sameRoom[i] <- 1
      } else {
        sameRoom[i] <- 0
      }
    }
  } else {
    if(i - 1 > 0){
      if(trials_cond4$room[i - 1] == trials_cond4$room[i]){
        sameRoom[i] <- 1
      } else {
        sameRoom[i] <- 0
      }
    }
  }
}
trials_cond4$sameRoom   <- sameRoom
context <- rep(NA, numObj)
context[trials_cond4$sameRoom == 0] <- 'across'
context[trials_cond4$sameRoom == 1 & trials_cond4$roomType == 'ww'] <- 'within-walls'
context[trials_cond4$sameRoom == 1 & trials_cond4$roomType == 'nw'] <- 'within-no-walls'
trials_cond4$context <- context


# /* 
# ----------------------------- Condition 5 ---------------------------
# */
# Video 1 + after
rooms                 <- numObj/2
trials_cond5          <- objectOrder
trials_cond5$table    <- rep(c(2, 3), rooms/2)
trials_cond5$room     <- rep(1:rooms, each = 2)
trials_cond5$roomType <- rep(c('ww', 'ww', 'nw', 'nw'), rooms/2)
trials_cond5$target   <- c(trials_cond5$objNum[1:(numObj -1) + 1], NA)

# Selecting foils that is in same room and in same position
foil1 <- rep(NA, numObj)
foil2 <- rep(NA, numObj)
for(i in 1:numObj){
  if(i - 5 >= 1){
    # run only if defined
    foil1[i] <- trials_cond5$objNum[i - 3]
  }
  if(i + 5 <= numObj){
    # run only if defined
    foil2[i] <- trials_cond5$objNum[i + 5]
  }
}
trials_cond5$foil1 <- foil1
trials_cond5$foil2 <- foil2

# Add position of target and foils on the screen during 3AFC task
targetPos <- c()
foil1Pos  <- c()
foil2Pos  <- c()
for(i in 1:dim(trials_cond5)[1]){
  shuffle        <- sample(1:3)
  targetPos[i] <- shuffle[1]
  foil1Pos[i]  <- shuffle[2]
  foil2Pos[i]  <- shuffle[3]
}
trials_cond5$targetPos <- targetPos
trials_cond5$foil1Pos  <- foil1Pos
trials_cond5$foil2Pos  <- foil2Pos
trials_cond5$corRoom   <- 1 # for nw rooms
trials_cond5$corRoom[trials_cond5$roomType == 'ww'] <- 2
trials_cond5$question <- after

# Get same room and context information
sameRoom   <- rep(NA, numObj)
for(i in 1:numObj){
  if(trials_cond5$question[i] == after){
    if(i + 1 < 89){
      if(trials_cond5$room[i + 1] == trials_cond5$room[i]){
        sameRoom[i] <- 1
      } else {
        sameRoom[i] <- 0
      }
    }
  } else {
    if(i - 1 > 0){
      if(trials_cond5$room[i - 1] == trials_cond5$room[i]){
        sameRoom[i] <- 1
      } else {
        sameRoom[i] <- 0
      }
    }
  }
}
trials_cond5$sameRoom   <- sameRoom
context <- rep(NA, numObj)
context[trials_cond5$sameRoom == 0] <- 'across'
context[trials_cond5$sameRoom == 1 & trials_cond5$roomType == 'ww'] <- 'within-walls'
context[trials_cond5$sameRoom == 1 & trials_cond5$roomType == 'nw'] <- 'within-no-walls'
trials_cond5$context <- context


# /* 
# ----------------------------- Condition 6 ---------------------------
# */
# Video 2 + after
rooms                 <- numObj/2
trials_cond6          <- objectOrder
trials_cond6$table    <- rep(c(2, 3), rooms/2)
trials_cond6$room     <- rep(1:rooms, each = 2)
trials_cond6$roomType <- rep(c('nw', 'nw', 'ww', 'ww'), rooms/2)
trials_cond6$target   <- c(trials_cond6$objNum[1:(numObj -1) + 1], NA)

# Selecting foils that is in same room and in same position
foil1 <- rep(NA, numObj)
foil2 <- rep(NA, numObj)
for(i in 1:numObj){
  if(i - 5 >= 1){
    # run only if defined
    foil1[i] <- trials_cond6$objNum[i - 3]
  }
  if(i + 5 <= numObj){
    # run only if defined
    foil2[i] <- trials_cond6$objNum[i + 5]
  }
}
trials_cond6$foil1 <- foil1
trials_cond6$foil2 <- foil2

# Add position of target and foils on the screen during 3AFC task
targetPos <- c()
foil1Pos  <- c()
foil2Pos  <- c()
for(i in 1:dim(trials_cond6)[1]){
  shuffle        <- sample(1:3)
  targetPos[i] <- shuffle[1]
  foil1Pos[i]  <- shuffle[2]
  foil2Pos[i]  <- shuffle[3]
}
trials_cond6$targetPos <- targetPos
trials_cond6$foil1Pos  <- foil1Pos
trials_cond6$foil2Pos  <- foil2Pos
trials_cond6$corRoom   <- 1 # for nw rooms
trials_cond6$corRoom[trials_cond6$roomType == 'ww'] <- 2
trials_cond6$question <- after

# Get same room and context information
sameRoom   <- rep(NA, numObj)
for(i in 1:numObj){
  if(trials_cond6$question[i] == after){
    if(i + 1 < 89){
      if(trials_cond6$room[i + 1] == trials_cond6$room[i]){
        sameRoom[i] <- 1
      } else {
        sameRoom[i] <- 0
      }
    }
  } else {
    if(i - 1 > 0){
      if(trials_cond6$room[i - 1] == trials_cond6$room[i]){
        sameRoom[i] <- 1
      } else {
        sameRoom[i] <- 0
      }
    }
  }
}
trials_cond6$sameRoom   <- sameRoom
context <- rep(NA, numObj)
context[trials_cond6$sameRoom == 0] <- 'across'
context[trials_cond6$sameRoom == 1 & trials_cond6$roomType == 'ww'] <- 'within-walls'
context[trials_cond6$sameRoom == 1 & trials_cond6$roomType == 'nw'] <- 'within-no-walls'
trials_cond6$context <- context

# /* 
# ----------------------------- Condition 7 ---------------------------
# */
# Video 3 + before
rooms                 <- numObj/2+1
trials_cond7          <- objectOrder
trials_cond7$table    <- c(rep(c(3, 2), (rooms - 1)/2))
room                  <- rep(1:rooms, each = 2)
trials_cond7$room     <- room[2:(length(room)-1)]
roomType              <- rep(c('nw', 'nw', 'ww', 'ww'),21)
trials_cond7$roomType <- c('ww', roomType, 'nw', 'nw', 'ww')
trials_cond7$target   <- c(trials_cond7$objNum[1:(numObj -1) + 1], NA)

# Selecting foils that is in same room and in same position
foil1 <- rep(NA, numObj)
foil2 <- rep(NA, numObj)
for(i in 1:numObj){
  if(i - 5 >= 1){
    # run only if defined
    foil1[i] <- trials_cond7$objNum[i - 3]
  }
  if(i + 5 <= numObj){
    # run only if defined
    foil2[i] <- trials_cond7$objNum[i + 5]
  }
}
trials_cond7$foil1 <- foil1
trials_cond7$foil2 <- foil2

# Add position of target and foils on the screen during 3AFC task
targetPos <- c()
foil1Pos  <- c()
foil2Pos  <- c()
for(i in 1:dim(trials_cond7)[1]){
  shuffle        <- sample(1:3)
  targetPos[i] <- shuffle[1]
  foil1Pos[i]  <- shuffle[2]
  foil2Pos[i]  <- shuffle[3]
}
trials_cond7$targetPos <- targetPos
trials_cond7$foil1Pos  <- foil1Pos
trials_cond7$foil2Pos  <- foil2Pos
trials_cond7$corRoom   <- 1 # for nw rooms
trials_cond7$corRoom[trials_cond7$roomType == 'ww'] <- 2
trials_cond7$question <- after

# Get same room and context information
sameRoom   <- rep(NA, numObj)
for(i in 1:numObj){
  if(trials_cond7$question[i] == after){
    if(i + 1 < 89){
      if(trials_cond7$room[i + 1] == trials_cond7$room[i]){
        sameRoom[i] <- 1
      } else {
        sameRoom[i] <- 0
      }
    }
  } else {
    if(i - 1 > 0){
      if(trials_cond7$room[i - 1] == trials_cond7$room[i]){
        sameRoom[i] <- 1
      } else {
        sameRoom[i] <- 0
      }
    }
  }
}
trials_cond7$sameRoom   <- sameRoom
context <- rep(NA, numObj)
context[trials_cond7$sameRoom == 0] <- 'across'
context[trials_cond7$sameRoom == 1 & trials_cond7$roomType == 'ww'] <- 'within-walls'
context[trials_cond7$sameRoom == 1 & trials_cond7$roomType == 'nw'] <- 'within-no-walls'
trials_cond7$context <- context


# /* 
# ----------------------------- Condition 8 ---------------------------
# */
# Video 4 + after
rooms                 <- numObj/2+1
trials_cond8          <- objectOrder
trials_cond8$table    <- c(rep(c(3, 2), (rooms - 1)/2))
room                  <- rep(1:rooms, each = 2)
trials_cond8$room     <- room[2:(length(room)-1)]
roomType              <- rep(c('ww', 'ww', 'nw', 'nw'),21)
trials_cond8$roomType <- c('nw', roomType, 'ww', 'ww', 'nw')
trials_cond8$target   <- c(trials_cond8$objNum[1:(numObj -1) + 1], NA)

# Selecting foils that is in same room and in same position
foil1 <- rep(NA, numObj)
foil2 <- rep(NA, numObj)
for(i in 1:numObj){
  if(i - 5 >= 1){
    # run only if defined
    foil1[i] <- trials_cond8$objNum[i - 3]
  }
  if(i + 5 <= numObj){
    # run only if defined
    foil2[i] <- trials_cond8$objNum[i + 5]
  }
}
trials_cond8$foil1 <- foil1
trials_cond8$foil2 <- foil2

# Add position of target and foils on the screen during 3AFC task
targetPos <- c()
foil1Pos  <- c()
foil2Pos  <- c()
for(i in 1:dim(trials_cond8)[1]){
  shuffle        <- sample(1:3)
  targetPos[i] <- shuffle[1]
  foil1Pos[i]  <- shuffle[2]
  foil2Pos[i]  <- shuffle[3]
}
trials_cond8$targetPos <- targetPos
trials_cond8$foil1Pos  <- foil1Pos
trials_cond8$foil2Pos  <- foil2Pos
trials_cond8$corRoom   <- 1 # for nw rooms
trials_cond8$corRoom[trials_cond8$roomType == 'ww'] <- 2
trials_cond8$question <- after

# Get same room and context information
sameRoom   <- rep(NA, numObj)
for(i in 1:numObj){
  if(trials_cond8$question[i] == after){
    if(i + 1 < 89){
      if(trials_cond8$room[i + 1] == trials_cond8$room[i]){
        sameRoom[i] <- 1
      } else {
        sameRoom[i] <- 0
      }
    }
  } else {
    if(i - 1 > 0){
      if(trials_cond8$room[i - 1] == trials_cond8$room[i]){
        sameRoom[i] <- 1
      } else {
        sameRoom[i] <- 0
      }
    }
  }
}
trials_cond8$sameRoom   <- sameRoom
context <- rep(NA, numObj)
context[trials_cond8$sameRoom == 0] <- 'across'
context[trials_cond8$sameRoom == 1 & trials_cond8$roomType == 'ww'] <- 'within-walls'
context[trials_cond8$sameRoom == 1 & trials_cond8$roomType == 'nw'] <- 'within-no-walls'
trials_cond8$context <- context

# /* 
# ----------------------------- Excluding trials without possible foils ---------------------------
# */
# Omit NA for all
trials_cond1 <- na.omit(trials_cond1)
trials_cond2 <- na.omit(trials_cond2)
trials_cond3 <- na.omit(trials_cond3)
trials_cond4 <- na.omit(trials_cond4)
trials_cond5 <- na.omit(trials_cond5)
trials_cond6 <- na.omit(trials_cond6)
trials_cond7 <- na.omit(trials_cond7)
trials_cond8 <- na.omit(trials_cond8)
nTrials      <- dim(trials_cond8)[1]

# /* 
# ----------------------------- Creating JSON strings ---------------------------
# */
## Temporal order
prefix <- 'images/stimuli/'
suffix <- '.png'

# This is only needed once
question        <- list(before, before, before, before, after, after, after, after)
question_string <- create_json_variable_str('question', question)

# The is the same for all conditions
objNum_string          <- paste(trials_cond1$objNum, ',', sep = '')
objNum_string[1]       <- paste('var objNum = [', trials_cond1$objNum[1], ',', sep = '')
objNum_string[nTrials] <- paste(trials_cond1$objNum[nTrials], '];', sep = '')
objNum_string          <- paste(objNum_string , collapse = '', sep = '')

# The is the same for all conditions
probe_string          <- paste('\t"', prefix ,trials_cond1$objNum, suffix, '"', ',\n', sep = '')
probe_string[1]       <- paste('var probe = ["', prefix, trials_cond1$objNum[1], suffix, '"', ',\n', sep = '')
probe_string[nTrials] <- paste('\t"', prefix, trials_cond1$objNum[nTrials], suffix, '"', '];', sep = '')
probe_string          <- paste(probe_string , collapse = '', sep = '')

target <- list(paste(prefix ,trials_cond1$target, suffix, sep = ''),
                   paste(prefix ,trials_cond2$target, suffix, sep = ''),
                   paste(prefix ,trials_cond3$target, suffix, sep = ''),
                   paste(prefix ,trials_cond4$target, suffix, sep = ''),
                   paste(prefix ,trials_cond5$target, suffix, sep = ''),
                   paste(prefix ,trials_cond6$target, suffix, sep = ''),
                   paste(prefix ,trials_cond7$target, suffix, sep = ''),
                   paste(prefix ,trials_cond8$target, suffix, sep = ''))
target_string <- create_json_variable_str('target', target)

targetPos <- list(trials_cond1$targetPos,
                  trials_cond2$targetPos,
                  trials_cond3$targetPos,
                  trials_cond4$targetPos,
                  trials_cond5$targetPos,
                  trials_cond6$targetPos,
                  trials_cond7$targetPos,
                  trials_cond8$targetPos)

targetPos_string <- create_json_variable_str('targetPos', targetPos)

foil1 <- list(paste(prefix ,trials_cond1$foil1, suffix, sep = ''),
                         paste(prefix ,trials_cond2$foil1, suffix, sep = ''),
                         paste(prefix ,trials_cond3$foil1, suffix, sep = ''),
                         paste(prefix ,trials_cond4$foil1, suffix, sep = ''),
                         paste(prefix ,trials_cond5$foil1, suffix, sep = ''),
                         paste(prefix ,trials_cond6$foil1, suffix, sep = ''),
                         paste(prefix ,trials_cond7$foil1, suffix, sep = ''),
                         paste(prefix ,trials_cond8$foil1, suffix, sep = ''))
foil1_string <- create_json_variable_str('foil1', foil1)

foil1Pos <- list(trials_cond1$foil1Pos,
                 trials_cond2$foil1Pos,
                 trials_cond3$foil1Pos,
                 trials_cond4$foil1Pos,
                 trials_cond5$foil1Pos,
                 trials_cond6$foil1Pos,
                 trials_cond7$foil1Pos,
                 trials_cond8$foil1Pos)
foil1Pos_string <- create_json_variable_str('foil1Pos', foil1Pos)

foil2 <- list(paste(prefix ,trials_cond1$foil2, suffix, sep = ''),
              paste(prefix ,trials_cond2$foil2, suffix, sep = ''),
              paste(prefix ,trials_cond3$foil2, suffix, sep = ''),
              paste(prefix ,trials_cond4$foil2, suffix, sep = ''),
              paste(prefix ,trials_cond5$foil2, suffix, sep = ''),
              paste(prefix ,trials_cond6$foil2, suffix, sep = ''),
              paste(prefix ,trials_cond7$foil2, suffix, sep = ''),
              paste(prefix ,trials_cond8$foil2, suffix, sep = ''))
foil2_string <- create_json_variable_str('foil2', foil2)

foil2Pos <- list(trials_cond1$foil2Pos,
                 trials_cond2$foil2Pos,
                 trials_cond3$foil2Pos,
                 trials_cond4$foil2Pos,
                 trials_cond5$foil2Pos,
                 trials_cond6$foil2Pos,
                 trials_cond7$foil2Pos,
                 trials_cond8$foil2Pos)
foil2Pos_string <- create_json_variable_str('foil2Pos', foil2Pos)

roomNum_probe <- list(trials_cond1$room,
                      trials_cond2$room,
                      trials_cond3$room,
                      trials_cond4$room,
                      trials_cond5$room,
                      trials_cond6$room,
                      trials_cond7$room,
                      trials_cond8$room)
roomNum_probe_string <- create_json_variable_str('roomNum_probe', roomNum_probe)


corRoom <- list(trials_cond1$corRoom,
                trials_cond2$corRoom,
                trials_cond3$corRoom,
                trials_cond4$corRoom,
                trials_cond5$corRoom,
                trials_cond6$corRoom,
                trials_cond7$corRoom,
                trials_cond8$corRoom)
corRoom_string <- create_json_variable_str('corRoom', corRoom)


table <- list(trials_cond1$table,
              trials_cond2$table,
              trials_cond3$table,
              trials_cond4$table,
              trials_cond5$table,
              trials_cond6$table,
              trials_cond7$table,
              trials_cond8$table)
table_string <- create_json_variable_str('table', table)

sameRoom  <- list(trials_cond1$sameRoom,
                  trials_cond2$sameRoom,
                  trials_cond3$sameRoom,
                  trials_cond4$sameRoom,
                  trials_cond5$sameRoom,
                  trials_cond6$sameRoom,
                  trials_cond7$sameRoom,
                  trials_cond8$sameRoom)
sameRoom_string <- create_json_variable_str('sameRoom', sameRoom)

context <- list(trials_cond1$context,
                trials_cond2$context,
                trials_cond3$context,
                trials_cond4$context,
                trials_cond5$context,
                trials_cond6$context,
                trials_cond7$context,
                trials_cond8$context)
context_string <- create_json_variable_str('context', context)

# /* 
# ----------------------------- Create JS file  ---------------------------
# */
sink('trialInformation.js')
cat(question_string)
cat('\n\n')
cat(objNum_string)
cat('\n\n')
cat(probe_string)
cat('\n\n')
cat(target_string)
cat('\n\n')
cat(targetPos_string)
cat('\n\n')
cat(foil1_string)
cat('\n\n')
cat(foil1Pos_string)
cat('\n\n')
cat(foil2_string)
cat('\n\n')
cat(foil2Pos_string)
cat('\n\n')
cat(roomNum_probe_string)
cat('\n\n')
cat(corRoom_string)
cat('\n\n')
cat(table_string)
cat('\n\n')
cat(sameRoom_string)
cat('\n\n')
cat(context_string)
cat('\n\n')
cat('question = JSON.parse(question);')
cat('\n\n')
cat('target = JSON.parse(target);')
cat('\n\n')
cat('targetPos = JSON.parse(targetPos);')
cat('\n\n')
cat('foil1 = JSON.parse(foil1);')
cat('\n\n')
cat('foil1Pos = JSON.parse(foil1Pos);')
cat('\n\n')
cat('foil2 = JSON.parse(foil2);')
cat('\n\n')
cat('foil2Pos = JSON.parse(foil2Pos);')
cat('\n\n')
cat('roomNum_probe = JSON.parse(roomNum_probe);')
cat('\n\n')
cat('corRoom = JSON.parse(corRoom);')
cat('\n\n')
cat('table = JSON.parse(table);')
cat('\n\n')
cat('sameRoom = JSON.parse(sameRoom);')
cat('\n\n')
cat('context = JSON.parse(context);')
sink()

# /* 
# ----------------------------- Save image ---------------------------
# */
save.image(datedFileNam('trialData', '.RData'))