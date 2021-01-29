# This script creates trial information for boundaryVR (Exp 3) memory task and returns a javascript
# The foils here are selected randomly with the following constraints:
# 1. Foils are not in the same room with target.
# 2. Foils are not in adjacent room. 
# 3. Foils can be repeatedly sampled. 
# A notable change between Exp 2 and Exp 3, is that task is now split in two parts. 
#
# /* 
# ----------------------------- General stuff ---------------------------
# */
# Setting seed
set.seed(8142)


# Library
library(rjson)
library(assortedRFunctions)

# Setting wd
setwd("~/boundaryVR/experiments/Exp3/r_supportFiles")

# /* 
# ----------------------------- General variables ---------------------------
# */
after  <- 'In the video you just watched, which one of the three objects at the bottom of the screen appeared <strong>immediately after</strong> this object?'

# Loading object order
objectOrder        <- read.csv('objectOrder.csv', sep = '\t', header = FALSE)
names(objectOrder) <- c('objNum', 'objNam')
objNum             <- objectOrder$objNum
numObj             <- length(objectOrder$objNum)

# Guide
# Video 1: M-shape room starting with within-association
# Video 2: M-shape room starting with across-association
# Video 3: O-plane room starting with within-association
# Video 4: O-plane room starting with across-association
# Order of question is controlled in javascript. 

# /* 
# ----------------------------- Video 1 ---------------------------
# */
# Video 1: M-shape room starting with within-association

# /* 
# ----------------------------- After ---------------------------
# */
rooms               <- numObj/2
vid1_after          <- objectOrder
vid1_after$table    <- rep(c(2, 3), rooms/2)
vid1_after$room     <- rep(1:rooms, each = 2)
vid1_after$roomType <- rep(c('m', 'm', 'm', 'm'), rooms/2)
vid1_after$target   <- c(vid1_after$objNum[1:(numObj -1) + 1], NA)

vid1_after_h1 <- vid1_after[1:44,]
vid1_after_h2 <- vid1_after[45:88,]

# /* 
# ----------------------------- h1 ---------------------------
# */
# Selecting foils that meet constraints above
numOj_half <- numObj/2
foil1 <- rep(NA, numOj_half)
dist1 <- rep(NA, numOj_half)
foil2 <- rep(NA, numOj_half)
dist2 <- rep(NA, numOj_half)
for(i in 1:nrow(vid1_after_h1)){
  if(any(vid1_after_h1$room < vid1_after_h1$room[i] - 1)){
    # If there is a room that is after the probe/cue
    availObj <- c() # Reset var
    # Find object that meet the constraints and then select random sample
    availObj <- vid1_after_h1[vid1_after_h1$room < vid1_after_h1$room[i] - 1, 'objNum']
    # Check if there is more than 1 object avail
    if(length(availObj) == 1){
      foil1[i] <- availObj
    } else {
      foil1[i] <- sample(availObj, 1)  
    } 
    dist1[i] <- which(foil1[i] == vid1_after_h1$objNum) - i
  }
  
  if(any(vid1_after_h1$room > vid1_after_h1$room[i] + 1)){
    # If there is a room that is after the probe/cue
    availObj <- c() # Reset var
    # Find object that meet the constraints and then select random sample
    availObj <- vid1_after_h1[vid1_after_h1$room > vid1_after_h1$room[i] + 1, 'objNum']
    # Check if there is more than 1 object avail
    if(length(availObj) == 1){
      foil2[i] <- availObj
    } else {
      foil2[i] <- sample(availObj, 1)  
    }
    dist2[i] <- which(foil2[i] == vid1_after_h1$objNum) - i
  }
}

# Assign to data.frame
vid1_after_h1$foil1 <- foil1
vid1_after_h1$foil2 <- foil2
vid1_after_h1$dist1 <- dist1
vid1_after_h1$dist2 <- dist2

# Add position of target and foils on the screen during 3AFC task
targetPos <- c()
foil1Pos  <- c()
foil2Pos  <- c()
for(i in 1:dim(vid1_after_h1)[1]){
  shuffle      <- sample(1:3)
  targetPos[i] <- shuffle[1]
  foil1Pos[i]  <- shuffle[2]
  foil2Pos[i]  <- shuffle[3]
}
vid1_after_h1$targetPos <- targetPos
vid1_after_h1$foil1Pos  <- foil1Pos
vid1_after_h1$foil2Pos  <- foil2Pos
vid1_after_h1$question  <- after

# Get same room and context information
sameRoom   <- rep(NA, numOj_half)
for(i in 1:numOj_half){
  if(vid1_after_h1$question[i] == after){
    if(i + 1 < numOj_half + 1){
      if(vid1_after_h1$room[i + 1] == vid1_after_h1$room[i]){
        sameRoom[i] <- 1
      } else {
        sameRoom[i] <- 0
      }
    }
  } else {
    if(i - 1 > 0){
      if(vid1_after_h1$room[i - 1] == vid1_after_h1$room[i]){
        sameRoom[i] <- 1
      } else {
        sameRoom[i] <- 0
      }
    }
  }
}

vid1_after_h1$sameRoom   <- sameRoom
context <- rep(NA, numOj_half)
context[vid1_after_h1$sameRoom == 0] <- 'across'
context[vid1_after_h1$sameRoom == 1] <- 'within'
vid1_after_h1$context <- context

# Get the table of the foils
foil1Table <- rep(NA, nrow(vid1_after_h1))
foil2Table <- rep(NA, nrow(vid1_after_h1))
for(i in 1:nrow(vid1_after_h1)){
  # Foil 1
  if(!is.na(vid1_after_h1$foil1[i])){
    foil1Table[i] <- vid1_after_h1[vid1_after_h1$objNum == vid1_after_h1$foil1[i], 'table']
  }
  
  # Foil 2
  if(!is.na(vid1_after_h1$foil2[i])){
    foil2Table[i] <- vid1_after_h1[vid1_after_h1$objNum == vid1_after_h1$foil2[i], 'table']
  }
}
vid1_after_h1$foil1Table <- foil1Table
vid1_after_h1$foil2Table <- foil2Table

# /* 
# ----------------------------- h2 ---------------------------
# */
# Selecting foils that meet constraints above
numOj_half <- numObj/2
foil1 <- rep(NA, numOj_half)
dist1 <- rep(NA, numOj_half)
foil2 <- rep(NA, numOj_half)
dist2 <- rep(NA, numOj_half)
for(i in 1:nrow(vid1_after_h2)){
  if(any(vid1_after_h2$room < vid1_after_h2$room[i] - 1)){
    # If there is a room that is after the probe/cue
    availObj <- c() # Reset var
    # Find object that meet the constraints and then select random sample
    availObj <- vid1_after_h2[vid1_after_h2$room < vid1_after_h2$room[i] - 1, 'objNum']
    # Check if there is more than 1 object avail
    if(length(availObj) == 1){
      foil1[i] <- availObj
    } else {
      foil1[i] <- sample(availObj, 1)  
    } 
    dist1[i] <- which(foil1[i] == vid1_after_h2$objNum) - i
  }
  
  if(any(vid1_after_h2$room > vid1_after_h2$room[i] + 1)){
    # If there is a room that is after the probe/cue
    availObj <- c() # Reset var
    # Find object that meet the constraints and then select random sample
    availObj <- vid1_after_h2[vid1_after_h2$room > vid1_after_h2$room[i] + 1, 'objNum']
    # Check if there is more than 1 object avail
    if(length(availObj) == 1){
      foil2[i] <- availObj
    } else {
      foil2[i] <- sample(availObj, 1)  
    }
    dist2[i] <- which(foil2[i] == vid1_after_h2$objNum) - i
  }
}

# Assign to data.frame
vid1_after_h2$foil1 <- foil1
vid1_after_h2$foil2 <- foil2
vid1_after_h2$dist1 <- dist1
vid1_after_h2$dist2 <- dist2

# Add position of target and foils on the screen during 3AFC task
targetPos <- c()
foil1Pos  <- c()
foil2Pos  <- c()
for(i in 1:dim(vid1_after_h2)[1]){
  shuffle      <- sample(1:3)
  targetPos[i] <- shuffle[1]
  foil1Pos[i]  <- shuffle[2]
  foil2Pos[i]  <- shuffle[3]
}
vid1_after_h2$targetPos <- targetPos
vid1_after_h2$foil1Pos  <- foil1Pos
vid1_after_h2$foil2Pos  <- foil2Pos
vid1_after_h2$question  <- after

# Get same room and context information
sameRoom   <- rep(NA, numOj_half)
for(i in 1:numOj_half){
  if(vid1_after_h2$question[i] == after){
    if(i + 1 < numOj_half +1){
      if(vid1_after_h2$room[i + 1] == vid1_after_h2$room[i]){
        sameRoom[i] <- 1
      } else {
        sameRoom[i] <- 0
      }
    }
  } else {
    if(i - 1 > 0){
      if(vid1_after_h2$room[i - 1] == vid1_after_h2$room[i]){
        sameRoom[i] <- 1
      } else {
        sameRoom[i] <- 0
      }
    }
  }
}
vid1_after_h2$sameRoom   <- sameRoom
context <- rep(NA, numOj_half)
context[vid1_after_h2$sameRoom == 0] <- 'across'
context[vid1_after_h2$sameRoom == 1] <- 'within'
vid1_after_h2$context <- context

# Get the table of the foils
foil1Table <- rep(NA, nrow(vid1_after_h2))
foil2Table <- rep(NA, nrow(vid1_after_h2))
for(i in 1:nrow(vid1_after_h2)){
  # Foil 1
  if(!is.na(vid1_after_h2$foil1[i])){
    foil1Table[i] <- vid1_after_h2[vid1_after_h2$objNum == vid1_after_h2$foil1[i], 'table']
  }
  
  # Foil 2
  if(!is.na(vid1_after_h2$foil2[i])){
    foil2Table[i] <- vid1_after_h2[vid1_after_h2$objNum == vid1_after_h2$foil2[i], 'table']
  }
}
vid1_after_h2$foil1Table <- foil1Table
vid1_after_h2$foil2Table <- foil2Table

# /* 
# ----------------------------- Video 2 ---------------------------
# */
# Video 2: M-shape room starting with across-association

# /* 
# ----------------------------- After ---------------------------
# */
rooms               <- numObj/2+1
vid2_after          <- objectOrder
vid2_after$table    <- c(rep(c(3, 2), (rooms - 1)/2))
room                <- rep(1:rooms, each = 2)
vid2_after$room     <- room[2:(length(room)-1)]
roomType            <- rep(c('m', 'm', 'm', 'm'),21)
vid2_after$roomType <- c('m', roomType, 'm', 'm', 'm')
vid2_after$target   <- c(vid2_after$objNum[1:(numObj -1) + 1], NA)

vid2_after_h1 <- vid2_after[1:44,]
vid2_after_h2 <- vid2_after[45:88,]

# /* 
# ----------------------------- h1 ---------------------------
# */
# Selecting foils that meet constraints above
numOj_half <- numObj/2
foil1 <- rep(NA, numOj_half)
dist1 <- rep(NA, numOj_half)
foil2 <- rep(NA, numOj_half)
dist2 <- rep(NA, numOj_half)
for(i in 1:nrow(vid2_after_h1)){
  if(any(vid2_after_h1$room < vid2_after_h1$room[i] - 1)){
    # If there is a room that is after the probe/cue
    availObj <- c() # Reset var
    # Find object that meet the constraints and then select random sample
    availObj <- vid2_after_h1[vid2_after_h1$room < vid2_after_h1$room[i] - 1, 'objNum']
    # Check if there is more than 1 object avail
    if(length(availObj) == 1){
      foil1[i] <- availObj
    } else {
      foil1[i] <- sample(availObj, 1)  
    } 
    dist1[i] <- which(foil1[i] == vid2_after_h1$objNum) - i
  }
  
  if(any(vid2_after_h1$room > vid2_after_h1$room[i] + 1)){
    # If there is a room that is after the probe/cue
    availObj <- c() # Reset var
    # Find object that meet the constraints and then select random sample
    availObj <- vid2_after_h1[vid2_after_h1$room > vid2_after_h1$room[i] + 1, 'objNum']
    # Check if there is more than 1 object avail
    if(length(availObj) == 1){
      foil2[i] <- availObj
    } else {
      foil2[i] <- sample(availObj, 1)  
    }
    dist2[i] <- which(foil2[i] == vid2_after_h1$objNum) - i
  }
}

# Assign to data.frame
vid2_after_h1$foil1 <- foil1
vid2_after_h1$foil2 <- foil2
vid2_after_h1$dist1 <- dist1
vid2_after_h1$dist2 <- dist2

# Add position of target and foils on the screen during 3AFC task
targetPos <- c()
foil1Pos  <- c()
foil2Pos  <- c()
for(i in 1:dim(vid2_after_h1)[1]){
  shuffle      <- sample(1:3)
  targetPos[i] <- shuffle[1]
  foil1Pos[i]  <- shuffle[2]
  foil2Pos[i]  <- shuffle[3]
}
vid2_after_h1$targetPos <- targetPos
vid2_after_h1$foil1Pos  <- foil1Pos
vid2_after_h1$foil2Pos  <- foil2Pos
vid2_after_h1$question  <- after

# Get same room and context information
sameRoom   <- rep(NA, numOj_half)
for(i in 1:numOj_half){
  if(vid2_after_h1$question[i] == after){
    if(i + 1 < numOj_half + 1){
      if(vid2_after_h1$room[i + 1] == vid2_after_h1$room[i]){
        sameRoom[i] <- 1
      } else {
        sameRoom[i] <- 0
      }
    }
  } else {
    if(i - 1 > 0){
      if(vid2_after_h1$room[i - 1] == vid2_after_h1$room[i]){
        sameRoom[i] <- 1
      } else {
        sameRoom[i] <- 0
      }
    }
  }
}
vid2_after_h1$sameRoom   <- sameRoom
context <- rep(NA, numOj_half)
context[vid2_after_h1$sameRoom == 0] <- 'across'
context[vid2_after_h1$sameRoom == 1] <- 'within'
vid2_after_h1$context <- context

# Get the table of the foils
foil1Table <- rep(NA, nrow(vid2_after_h1))
foil2Table <- rep(NA, nrow(vid2_after_h1))
for(i in 1:nrow(vid2_after_h1)){
  # Foil 1
  if(!is.na(vid2_after_h1$foil1[i])){
    foil1Table[i] <- vid2_after_h1[vid2_after_h1$objNum == vid2_after_h1$foil1[i], 'table']
  }
  
  # Foil 2
  if(!is.na(vid2_after_h1$foil2[i])){
    foil2Table[i] <- vid2_after_h1[vid2_after_h1$objNum == vid2_after_h1$foil2[i], 'table']
  }
}
vid2_after_h1$foil1Table <- foil1Table
vid2_after_h1$foil2Table <- foil2Table

# /* 
# ----------------------------- h2 ---------------------------
# */
# Selecting foils that meet constraints above
numOj_half <- numObj/2
foil1 <- rep(NA, numOj_half)
dist1 <- rep(NA, numOj_half)
foil2 <- rep(NA, numOj_half)
dist2 <- rep(NA, numOj_half)
for(i in 1:nrow(vid2_after_h2)){
  if(any(vid2_after_h2$room < vid2_after_h2$room[i] - 1)){
    # If there is a room that is after the probe/cue
    availObj <- c() # Reset var
    # Find object that meet the constraints and then select random sample
    availObj <- vid2_after_h2[vid2_after_h2$room < vid2_after_h2$room[i] - 1, 'objNum']
    # Check if there is more than 1 object avail
    if(length(availObj) == 1){
      foil1[i] <- availObj
    } else {
      foil1[i] <- sample(availObj, 1)  
    } 
    dist1[i] <- which(foil1[i] == vid2_after_h2$objNum) - i
  }
  
  if(any(vid2_after_h2$room > vid2_after_h2$room[i] + 1)){
    # If there is a room that is after the probe/cue
    availObj <- c() # Reset var
    # Find object that meet the constraints and then select random sample
    availObj <- vid2_after_h2[vid2_after_h2$room > vid2_after_h2$room[i] + 1, 'objNum']
    # Check if there is more than 1 object avail
    if(length(availObj) == 1){
      foil2[i] <- availObj
    } else {
      foil2[i] <- sample(availObj, 1)  
    }
    dist2[i] <- which(foil2[i] == vid2_after_h2$objNum) - i
  }
}

# Assign to data.frame
vid2_after_h2$foil1 <- foil1
vid2_after_h2$foil2 <- foil2
vid2_after_h2$dist1 <- dist1
vid2_after_h2$dist2 <- dist2

# Add position of target and foils on the screen during 3AFC task
targetPos <- c()
foil1Pos  <- c()
foil2Pos  <- c()
for(i in 1:dim(vid2_after_h2)[1]){
  shuffle      <- sample(1:3)
  targetPos[i] <- shuffle[1]
  foil1Pos[i]  <- shuffle[2]
  foil2Pos[i]  <- shuffle[3]
}
vid2_after_h2$targetPos <- targetPos
vid2_after_h2$foil1Pos  <- foil1Pos
vid2_after_h2$foil2Pos  <- foil2Pos
vid2_after_h2$question  <- after

# Get same room and context information
sameRoom   <- rep(NA, numOj_half)
for(i in 1:numOj_half){
  if(vid2_after_h2$question[i] == after){
    if(i + 1 < numOj_half +1){
      if(vid2_after_h2$room[i + 1] == vid2_after_h2$room[i]){
        sameRoom[i] <- 1
      } else {
        sameRoom[i] <- 0
      }
    }
  } else {
    if(i - 1 > 0){
      if(vid2_after_h2$room[i - 1] == vid2_after_h2$room[i]){
        sameRoom[i] <- 1
      } else {
        sameRoom[i] <- 0
      }
    }
  }
}
vid2_after_h2$sameRoom   <- sameRoom
context <- rep(NA, numOj_half)
context[vid2_after_h2$sameRoom == 0] <- 'across'
context[vid2_after_h2$sameRoom == 1] <- 'within'
vid2_after_h2$context <- context

# Get the table of the foils
foil1Table <- rep(NA, nrow(vid2_after_h2))
foil2Table <- rep(NA, nrow(vid2_after_h2))
for(i in 1:nrow(vid2_after_h2)){
  # Foil 1
  if(!is.na(vid2_after_h2$foil1[i])){
    foil1Table[i] <- vid2_after_h2[vid2_after_h2$objNum == vid2_after_h2$foil1[i], 'table']
  }
  
  # Foil 2
  if(!is.na(vid2_after_h2$foil2[i])){
    foil2Table[i] <- vid2_after_h2[vid2_after_h2$objNum == vid2_after_h2$foil2[i], 'table']
  }
}
vid2_after_h2$foil1Table <- foil1Table
vid2_after_h2$foil2Table <- foil2Table

# /* 
# ----------------------------- Video 3 ---------------------------
# */
# Video 3: O-plane room starting with within-assoication

# /* 
# ----------------------------- After ---------------------------
# */
rooms               <- numObj/2
vid3_after          <- objectOrder
vid3_after$table    <- rep(c(2, 3), rooms/2)
vid3_after$room     <- rep(1:rooms, each = 2)
vid3_after$roomType <- rep(c('o', 'o', 'o', 'o'), rooms/2)
vid3_after$target   <- c(vid3_after$objNum[1:(numObj - 1) + 1], NA)

vid3_after_h1 <- vid3_after[1:44,]
vid3_after_h2 <- vid3_after[45:88,]

# /* 
# ----------------------------- h1 ---------------------------
# */
# Selecting foils that meet constraints above
numOj_half <- numObj/2
foil1 <- rep(NA, numOj_half)
dist1 <- rep(NA, numOj_half)
foil2 <- rep(NA, numOj_half)
dist2 <- rep(NA, numOj_half)
for(i in 1:nrow(vid3_after_h1)){
  if(any(vid3_after_h1$room < vid3_after_h1$room[i] - 1)){
    # If there is a room that is after the probe/cue
    availObj <- c() # Reset var
    # Find object that meet the constraints and then select random sample
    availObj <- vid3_after_h1[vid3_after_h1$room < vid3_after_h1$room[i] - 1, 'objNum']
    # Check if there is more than 1 object avail
    if(length(availObj) == 1){
      foil1[i] <- availObj
    } else {
      foil1[i] <- sample(availObj, 1)  
    } 
    dist1[i] <- which(foil1[i] == vid3_after_h1$objNum) - i
  }
  
  if(any(vid3_after_h1$room > vid3_after_h1$room[i] + 1)){
    # If there is a room that is after the probe/cue
    availObj <- c() # Reset var
    # Find object that meet the constraints and then select random sample
    availObj <- vid3_after_h1[vid3_after_h1$room > vid3_after_h1$room[i] + 1, 'objNum']
    # Check if there is more than 1 object avail
    if(length(availObj) == 1){
      foil2[i] <- availObj
    } else {
      foil2[i] <- sample(availObj, 1)  
    }
    dist2[i] <- which(foil2[i] == vid3_after_h1$objNum) - i
  }
}

# Assign to data.frame
vid3_after_h1$foil1 <- foil1
vid3_after_h1$foil2 <- foil2
vid3_after_h1$dist1 <- dist1
vid3_after_h1$dist2 <- dist2

# Add position of target and foils on the screen during 3AFC task
targetPos <- c()
foil1Pos  <- c()
foil2Pos  <- c()
for(i in 1:dim(vid3_after_h1)[1]){
  shuffle      <- sample(1:3)
  targetPos[i] <- shuffle[1]
  foil1Pos[i]  <- shuffle[2]
  foil2Pos[i]  <- shuffle[3]
}
vid3_after_h1$targetPos <- targetPos
vid3_after_h1$foil1Pos  <- foil1Pos
vid3_after_h1$foil2Pos  <- foil2Pos
vid3_after_h1$question  <- after

# Get same room and context information
sameRoom   <- rep(NA, numOj_half)
for(i in 1:numOj_half){
  if(vid3_after_h1$question[i] == after){
    if(i + 1 < numOj_half +1){
      if(vid3_after_h1$room[i + 1] == vid3_after_h1$room[i]){
        sameRoom[i] <- 1
      } else {
        sameRoom[i] <- 0
      }
    }
  } else {
    if(i - 1 > 0){
      if(vid3_after_h1$room[i - 1] == vid3_after_h1$room[i]){
        sameRoom[i] <- 1
      } else {
        sameRoom[i] <- 0
      }
    }
  }
}
vid3_after_h1$sameRoom   <- sameRoom
context <- rep(NA, numOj_half)
context[vid3_after_h1$sameRoom == 0] <- 'across'
context[vid3_after_h1$sameRoom == 1] <- 'within'
vid3_after_h1$context <- context

# Get the table of the foils
foil1Table <- rep(NA, nrow(vid3_after_h1))
foil2Table <- rep(NA, nrow(vid3_after_h1))
for(i in 1:nrow(vid3_after_h1)){
  # Foil 1
  if(!is.na(vid3_after_h1$foil1[i])){
    foil1Table[i] <- vid3_after_h1[vid3_after_h1$objNum == vid3_after_h1$foil1[i], 'table']
  }
  
  # Foil 2
  if(!is.na(vid3_after_h1$foil2[i])){
    foil2Table[i] <- vid3_after_h1[vid3_after_h1$objNum == vid3_after_h1$foil2[i], 'table']
  }
}
vid3_after_h1$foil1Table <- foil1Table
vid3_after_h1$foil2Table <- foil2Table

# /* 
# ----------------------------- h2 ---------------------------
# */
# Selecting foils that meet constraints above
numOj_half <- numObj/2
foil1 <- rep(NA, numOj_half)
dist1 <- rep(NA, numOj_half)
foil2 <- rep(NA, numOj_half)
dist2 <- rep(NA, numOj_half)
for(i in 1:nrow(vid3_after_h2)){
  if(any(vid3_after_h2$room < vid3_after_h2$room[i] - 1)){
    # If there is a room that is after the probe/cue
    availObj <- c() # Reset var
    # Find object that meet the constraints and then select random sample
    availObj <- vid3_after_h2[vid3_after_h2$room < vid3_after_h2$room[i] - 1, 'objNum']
    # Check if there is more than 1 object avail
    if(length(availObj) == 1){
      foil1[i] <- availObj
    } else {
      foil1[i] <- sample(availObj, 1)  
    } 
    dist1[i] <- which(foil1[i] == vid3_after_h2$objNum) - i
  }
  
  if(any(vid3_after_h2$room > vid3_after_h2$room[i] + 1)){
    # If there is a room that is after the probe/cue
    availObj <- c() # Reset var
    # Find object that meet the constraints and then select random sample
    availObj <- vid3_after_h2[vid3_after_h2$room > vid3_after_h2$room[i] + 1, 'objNum']
    # Check if there is more than 1 object avail
    if(length(availObj) == 1){
      foil2[i] <- availObj
    } else {
      foil2[i] <- sample(availObj, 1)  
    }
    dist2[i] <- which(foil2[i] == vid3_after_h2$objNum) - i
  }
}

# Assign to data.frame
vid3_after_h2$foil1 <- foil1
vid3_after_h2$foil2 <- foil2
vid3_after_h2$dist1 <- dist1
vid3_after_h2$dist2 <- dist2

# Add position of target and foils on the screen during 3AFC task
targetPos <- c()
foil1Pos  <- c()
foil2Pos  <- c()
for(i in 1:dim(vid3_after_h2)[1]){
  shuffle      <- sample(1:3)
  targetPos[i] <- shuffle[1]
  foil1Pos[i]  <- shuffle[2]
  foil2Pos[i]  <- shuffle[3]
}
vid3_after_h2$targetPos <- targetPos
vid3_after_h2$foil1Pos  <- foil1Pos
vid3_after_h2$foil2Pos  <- foil2Pos
vid3_after_h2$question  <- after

# Get same room and context information
sameRoom   <- rep(NA, numOj_half)
for(i in 1:numOj_half){
  if(vid3_after_h2$question[i] == after){
    if(i + 1 < numOj_half +1){
      if(vid3_after_h2$room[i + 1] == vid3_after_h2$room[i]){
        sameRoom[i] <- 1
      } else {
        sameRoom[i] <- 0
      }
    }
  } else {
    if(i - 1 > 0){
      if(vid3_after_h2$room[i - 1] == vid3_after_h2$room[i]){
        sameRoom[i] <- 1
      } else {
        sameRoom[i] <- 0
      }
    }
  }
}
vid3_after_h2$sameRoom   <- sameRoom
context <- rep(NA, numOj_half)
context[vid3_after_h2$sameRoom == 0] <- 'across'
context[vid3_after_h2$sameRoom == 1] <- 'within'
vid3_after_h2$context <- context

# Get the table of the foils
foil1Table <- rep(NA, nrow(vid3_after_h2))
foil2Table <- rep(NA, nrow(vid3_after_h2))
for(i in 1:nrow(vid3_after_h2)){
  # Foil 1
  if(!is.na(vid3_after_h2$foil1[i])){
    foil1Table[i] <- vid3_after_h2[vid3_after_h2$objNum == vid3_after_h2$foil1[i], 'table']
  }
  
  # Foil 2
  if(!is.na(vid3_after_h2$foil2[i])){
    foil2Table[i] <- vid3_after_h2[vid3_after_h2$objNum == vid3_after_h2$foil2[i], 'table']
  }
}
vid3_after_h2$foil1Table <- foil1Table
vid3_after_h2$foil2Table <- foil2Table

# /* 
# ----------------------------- Video 4 ---------------------------
# */
# Video 4: O-plane room starting with across-assoication


# /* 
# ----------------------------- After ---------------------------
# */
rooms               <- numObj/2+1
vid4_after          <- objectOrder
vid4_after$table    <- c(rep(c(3, 2), (rooms - 1)/2))
room                <- rep(1:rooms, each = 2)
vid4_after$room     <- room[2:(length(room)-1)]
roomType            <- rep(c('o', 'o', 'o', 'o'), 21)
vid4_after$roomType <- c('o', roomType, 'o', 'o', 'o')
vid4_after$target   <- c(vid4_after$objNum[1:(numObj -1) + 1], NA)

vid4_after_h1 <- vid4_after[1:44,]
vid4_after_h2 <- vid4_after[45:88,]

# /* 
# ----------------------------- h1 ---------------------------
# */
# Selecting foils that meet constraints above
numOj_half <- numObj/2
foil1 <- rep(NA, numOj_half)
dist1 <- rep(NA, numOj_half)
foil2 <- rep(NA, numOj_half)
dist2 <- rep(NA, numOj_half)
for(i in 1:nrow(vid4_after_h1)){
  if(any(vid4_after_h1$room < vid4_after_h1$room[i] - 1)){
    # If there is a room that is after the probe/cue
    availObj <- c() # Reset var
    # Find object that meet the constraints and then select random sample
    availObj <- vid4_after_h1[vid4_after_h1$room < vid4_after_h1$room[i] - 1, 'objNum']
    # Check if there is more than 1 object avail
    if(length(availObj) == 1){
      foil1[i] <- availObj
    } else {
      foil1[i] <- sample(availObj, 1)  
    } 
    dist1[i] <- which(foil1[i] == vid4_after_h1$objNum) - i
  }
  
  if(any(vid4_after_h1$room > vid4_after_h1$room[i] + 1)){
    # If there is a room that is after the probe/cue
    availObj <- c() # Reset var
    # Find object that meet the constraints and then select random sample
    availObj <- vid4_after_h1[vid4_after_h1$room > vid4_after_h1$room[i] + 1, 'objNum']
    # Check if there is more than 1 object avail
    if(length(availObj) == 1){
      foil2[i] <- availObj
    } else {
      foil2[i] <- sample(availObj, 1)  
    }
    dist2[i] <- which(foil2[i] == vid4_after_h1$objNum) - i
  }
}

# Assign to data.frame
vid4_after_h1$foil1 <- foil1
vid4_after_h1$foil2 <- foil2
vid4_after_h1$dist1 <- dist1
vid4_after_h1$dist2 <- dist2

# Add position of target and foils on the screen during 3AFC task
targetPos <- c()
foil1Pos  <- c()
foil2Pos  <- c()
for(i in 1:dim(vid4_after_h1)[1]){
  shuffle      <- sample(1:3)
  targetPos[i] <- shuffle[1]
  foil1Pos[i]  <- shuffle[2]
  foil2Pos[i]  <- shuffle[3]
}
vid4_after_h1$targetPos <- targetPos
vid4_after_h1$foil1Pos  <- foil1Pos
vid4_after_h1$foil2Pos  <- foil2Pos
vid4_after_h1$question  <- after

# Get same room and context information
sameRoom   <- rep(NA, numOj_half)
for(i in 1:numOj_half){
  if(vid4_after_h1$question[i] == after){
    if(i + 1 < numOj_half +1){
      if(vid4_after_h1$room[i + 1] == vid4_after_h1$room[i]){
        sameRoom[i] <- 1
      } else {
        sameRoom[i] <- 0
      }
    }
  } else {
    if(i - 1 > 0){
      if(vid4_after_h1$room[i - 1] == vid4_after_h1$room[i]){
        sameRoom[i] <- 1
      } else {
        sameRoom[i] <- 0
      }
    }
  }
}
vid4_after_h1$sameRoom   <- sameRoom
context <- rep(NA, numOj_half)
context[vid4_after_h1$sameRoom == 0] <- 'across'
context[vid4_after_h1$sameRoom == 1] <- 'within'
vid4_after_h1$context <- context

# Get the table of the foils
foil1Table <- rep(NA, nrow(vid4_after_h1))
foil2Table <- rep(NA, nrow(vid4_after_h1))
for(i in 1:nrow(vid4_after_h1)){
  # Foil 1
  if(!is.na(vid4_after_h1$foil1[i])){
    foil1Table[i] <- vid4_after_h1[vid4_after_h1$objNum == vid4_after_h1$foil1[i], 'table']
  }
  
  # Foil 2
  if(!is.na(vid4_after_h1$foil2[i])){
    foil2Table[i] <- vid4_after_h1[vid4_after_h1$objNum == vid4_after_h1$foil2[i], 'table']
  }
}
vid4_after_h1$foil1Table <- foil1Table
vid4_after_h1$foil2Table <- foil2Table

# /* 
# ----------------------------- h2 ---------------------------
# */
# Selecting foils that meet constraints above
numOj_half <- numObj/2
foil1 <- rep(NA, numOj_half)
dist1 <- rep(NA, numOj_half)
foil2 <- rep(NA, numOj_half)
dist2 <- rep(NA, numOj_half)
for(i in 1:nrow(vid4_after_h2)){
  if(any(vid4_after_h2$room < vid4_after_h2$room[i] - 1)){
    # If there is a room that is after the probe/cue
    availObj <- c() # Reset var
    # Find object that meet the constraints and then select random sample
    availObj <- vid4_after_h2[vid4_after_h2$room < vid4_after_h2$room[i] - 1, 'objNum']
    # Check if there is more than 1 object avail
    if(length(availObj) == 1){
      foil1[i] <- availObj
    } else {
      foil1[i] <- sample(availObj, 1)  
    } 
    dist1[i] <- which(foil1[i] == vid4_after_h2$objNum) - i
  }
  
  if(any(vid4_after_h2$room > vid4_after_h2$room[i] + 1)){
    # If there is a room that is after the probe/cue
    availObj <- c() # Reset var
    # Find object that meet the constraints and then select random sample
    availObj <- vid4_after_h2[vid4_after_h2$room > vid4_after_h2$room[i] + 1, 'objNum']
    # Check if there is more than 1 object avail
    if(length(availObj) == 1){
      foil2[i] <- availObj
    } else {
      foil2[i] <- sample(availObj, 1)  
    }
    dist2[i] <- which(foil2[i] == vid4_after_h2$objNum) - i
  }
}

# Assign to data.frame
vid4_after_h2$foil1 <- foil1
vid4_after_h2$foil2 <- foil2
vid4_after_h2$dist1 <- dist1
vid4_after_h2$dist2 <- dist2

# Add position of target and foils on the screen during 3AFC task
targetPos <- c()
foil1Pos  <- c()
foil2Pos  <- c()
for(i in 1:dim(vid4_after_h2)[1]){
  shuffle      <- sample(1:3)
  targetPos[i] <- shuffle[1]
  foil1Pos[i]  <- shuffle[2]
  foil2Pos[i]  <- shuffle[3]
}
vid4_after_h2$targetPos <- targetPos
vid4_after_h2$foil1Pos  <- foil1Pos
vid4_after_h2$foil2Pos  <- foil2Pos
vid4_after_h2$question  <- after

# Get same room and context information
sameRoom   <- rep(NA, numOj_half)
for(i in 1:numOj_half){
  if(vid4_after_h2$question[i] == after){
    if(i + 1 < numOj_half +1){
      if(vid4_after_h2$room[i + 1] == vid4_after_h2$room[i]){
        sameRoom[i] <- 1
      } else {
        sameRoom[i] <- 0
      }
    }
  } else {
    if(i - 1 > 0){
      if(vid4_after_h2$room[i - 1] == vid4_after_h2$room[i]){
        sameRoom[i] <- 1
      } else {
        sameRoom[i] <- 0
      }
    }
  }
}
vid4_after_h2$sameRoom   <- sameRoom
context <- rep(NA, numOj_half)
context[vid4_after_h2$sameRoom == 0] <- 'across'
context[vid4_after_h2$sameRoom == 1] <- 'within'
vid4_after_h2$context <- context

# Get the table of the foils
foil1Table <- rep(NA, nrow(vid4_after_h2))
foil2Table <- rep(NA, nrow(vid4_after_h2))
for(i in 1:nrow(vid4_after_h2)){
  # Foil 1
  if(!is.na(vid4_after_h2$foil1[i])){
    foil1Table[i] <- vid4_after_h2[vid4_after_h2$objNum == vid4_after_h2$foil1[i], 'table']
  }
  
  # Foil 2
  if(!is.na(vid4_after_h2$foil2[i])){
    foil2Table[i] <- vid4_after_h2[vid4_after_h2$objNum == vid4_after_h2$foil2[i], 'table']
  }
}
vid4_after_h2$foil1Table <- foil1Table
vid4_after_h2$foil2Table <- foil2Table


# /* 
# ----------------------------- Excluding trials without possible foils ---------------------------
# */
# Create df that containt all objects (important for getting table information)
vid1_after_h1_full <- vid1_after_h1
vid2_after_h1_full <- vid2_after_h1
vid3_after_h1_full <- vid3_after_h1
vid4_after_h1_full <- vid4_after_h1

vid1_after_h2_full <- vid1_after_h2
vid2_after_h2_full <- vid2_after_h2
vid3_after_h2_full <- vid3_after_h2
vid4_after_h2_full <- vid4_after_h2

# Omit NA for all
vid1_after_h1 <- na.omit(vid1_after_h1)
vid2_after_h1 <- na.omit(vid2_after_h1)
vid3_after_h1 <- na.omit(vid3_after_h1)
vid4_after_h1 <- na.omit(vid4_after_h1)

vid1_after_h2 <- na.omit(vid1_after_h2)
vid2_after_h2 <- na.omit(vid2_after_h2)
vid3_after_h2 <- na.omit(vid3_after_h2)
vid4_after_h2 <- na.omit(vid4_after_h2)

# /* 
# ----------------------------- Creating JSON strings ---------------------------
# */
## Temporal order
prefix <- 'images/stimuli/'
suffix <- '.png'

question        <- list(after)

question_string <- create_json_variable_str('question', question)

objNum <- list(list(vid1_after_h1$objNum, vid1_after_h2$objNum),
               list(vid2_after_h1$objNum, vid2_after_h2$objNum),
               list(vid3_after_h1$objNum, vid3_after_h2$objNum),
               list(vid4_after_h1$objNum, vid4_after_h2$objNum))
objNum_string <- create_json_variable_str('objNum', objNum)


probe <- list(list(paste(prefix, vid1_after_h1$objNum, suffix, sep = ''), paste(prefix, vid1_after_h2$objNum, suffix, sep = '')),
              list(paste(prefix, vid2_after_h1$objNum, suffix, sep = ''), paste(prefix, vid2_after_h2$objNum, suffix, sep = '')),
              list(paste(prefix, vid3_after_h1$objNum, suffix, sep = ''), paste(prefix, vid3_after_h2$objNum, suffix, sep = '')),
              list(paste(prefix, vid4_after_h1$objNum, suffix, sep = ''), paste(prefix, vid4_after_h2$objNum, suffix, sep = '')))
probe_string <- create_json_variable_str('probe', probe)



target <- list(list(paste(prefix, vid1_after_h1$target, suffix, sep = ''),  paste(prefix, vid1_after_h2$target, suffix, sep = '')),
               list(paste(prefix, vid2_after_h1$target, suffix, sep = ''),  paste(prefix, vid2_after_h2$target, suffix, sep = '')),
               list(paste(prefix, vid3_after_h1$target, suffix, sep = ''),  paste(prefix, vid3_after_h2$target, suffix, sep = '')),
               list(paste(prefix, vid4_after_h1$target, suffix, sep = ''),  paste(prefix, vid4_after_h2$target, suffix, sep = '')))
target_string <- create_json_variable_str('target', target)

targetPos <- list(list(vid1_after_h1$targetPos, vid1_after_h2$targetPos),
                  list(vid2_after_h1$targetPos, vid2_after_h2$targetPos),
                  list(vid3_after_h1$targetPos, vid3_after_h2$targetPos),
                  list(vid4_after_h1$targetPos, vid4_after_h2$targetPos))
targetPos_string <- create_json_variable_str('targetPos', targetPos)


foil1 <- list(list(paste(prefix ,vid1_after_h1$foil1, suffix, sep = ''), paste(prefix ,vid1_after_h2$foil1, suffix, sep = '')),
              list(paste(prefix ,vid2_after_h1$foil1, suffix, sep = ''), paste(prefix ,vid2_after_h2$foil1, suffix, sep = '')),
              list(paste(prefix ,vid3_after_h1$foil1, suffix, sep = ''), paste(prefix ,vid3_after_h2$foil1, suffix, sep = '')),
              list(paste(prefix ,vid4_after_h1$foil1, suffix, sep = ''), paste(prefix ,vid4_after_h2$foil1, suffix, sep = '')))
foil1_string <- create_json_variable_str('foil1', foil1)

foil1Pos <- list(list(vid1_after_h1$foil1Pos, vid1_after_h2$foil1Pos),
                 list(vid2_after_h1$foil1Pos, vid2_after_h2$foil1Pos),
                 list(vid3_after_h1$foil1Pos, vid3_after_h2$foil1Pos),
                 list(vid4_after_h1$foil1Pos, vid4_after_h2$foil1Pos))
foil1Pos_string <- create_json_variable_str('foil1Pos', foil1Pos)


foil1Table <- list(list(vid1_after_h1$foil1Table, vid1_after_h2$foil1Table),
                   list(vid2_after_h1$foil1Table, vid2_after_h2$foil1Table),
                   list(vid3_after_h1$foil1Table, vid3_after_h2$foil1Table),
                   list(vid4_after_h1$foil1Table, vid4_after_h2$foil1Table))
foil1Table_string <- create_json_variable_str('foil1Table', foil1Table)


dist1 <- list(list(vid1_after_h1$dist1,  vid1_after_h2$dist1),
              list(vid2_after_h1$dist1,  vid2_after_h2$dist1),
              list(vid3_after_h1$dist1,  vid3_after_h2$dist1),
              list(vid4_after_h1$dist1,  vid4_after_h2$dist1))
dist1_string <- create_json_variable_str('dist1', dist1)

foil2 <- list(list(paste(prefix, vid1_after_h1$foil2, suffix, sep = ''), paste(prefix, vid1_after_h2$foil2, suffix, sep = '')),
              list(paste(prefix, vid2_after_h1$foil2, suffix, sep = ''), paste(prefix, vid2_after_h2$foil2, suffix, sep = '')),
              list(paste(prefix, vid3_after_h1$foil2, suffix, sep = ''), paste(prefix, vid3_after_h2$foil2, suffix, sep = '')),
              list(paste(prefix, vid4_after_h1$foil2, suffix, sep = ''), paste(prefix, vid4_after_h2$foil2, suffix, sep = '')))
foil2_string <- create_json_variable_str('foil2', foil2)

foil2Pos <- list(list(vid1_after_h1$foil2Pos, vid1_after_h2$foil2Pos),
                 list(vid2_after_h1$foil2Pos, vid2_after_h2$foil2Pos),
                 list(vid3_after_h1$foil2Pos, vid3_after_h2$foil2Pos),
                 list(vid4_after_h1$foil2Pos, vid4_after_h2$foil2Pos))
foil2Pos_string <- create_json_variable_str('foil2Pos', foil2Pos)

foil2Table <- list(list(vid1_after_h1$foil2Table, vid1_after_h2$foil2Table),
                   list(vid2_after_h1$foil2Table, vid2_after_h2$foil2Table),
                   list(vid3_after_h1$foil2Table, vid3_after_h2$foil2Table),
                   list(vid4_after_h1$foil2Table, vid4_after_h2$foil2Table))
foil2Table_string <- create_json_variable_str('foil2Table', foil2Table)


dist2 <- list(list(vid1_after_h1$dist2, vid1_after_h2$dist2),
              list(vid2_after_h1$dist2, vid2_after_h2$dist2),
              list(vid3_after_h1$dist2, vid3_after_h2$dist2),
              list(vid4_after_h1$dist2, vid4_after_h2$dist2))
dist2_string <- create_json_variable_str('dist2', dist2)


roomNum_probe <- list(list(vid1_after_h1$room, vid1_after_h2$room),
                      list(vid2_after_h1$room, vid2_after_h2$room),
                      list(vid3_after_h1$room, vid3_after_h2$room),
                      list(vid4_after_h1$room, vid4_after_h2$room))
roomNum_probe_string <- create_json_variable_str('roomNum_probe', roomNum_probe)


roomType <- list(list(vid1_after_h1$roomType, vid1_after_h2$roomType),
                 list(vid2_after_h1$roomType, vid2_after_h2$roomType),
                 list(vid3_after_h1$roomType, vid3_after_h2$roomType),
                 list(vid4_after_h1$roomType, vid4_after_h2$roomType))
roomType_string <- create_json_variable_str('roomType', roomType)


table  <- list(list(vid1_after_h1$table,  vid1_after_h2$table),
               list(vid2_after_h1$table,  vid2_after_h2$table),
               list(vid3_after_h1$table,  vid3_after_h2$table),
               list(vid4_after_h1$table,  vid4_after_h2$table))
table_string <- create_json_variable_str('table', table)

sameRoom <- list(list(vid1_after_h1$sameRoom, vid1_after_h2$sameRoom),
                 list(vid2_after_h1$sameRoom, vid2_after_h2$sameRoom),
                 list(vid3_after_h1$sameRoom, vid3_after_h2$sameRoom),
                 list(vid4_after_h1$sameRoom, vid4_after_h2$sameRoom))
sameRoom_string <- create_json_variable_str('sameRoom', sameRoom)

context <- list(list(vid1_after_h1$context, vid1_after_h2$context),
                list(vid2_after_h1$context, vid2_after_h2$context),
                list(vid3_after_h1$context, vid3_after_h2$context),
                list(vid4_after_h1$context, vid4_after_h2$context))
context_string <- create_json_variable_str('context', context)

# /* 
# ----------------------------- Create JS file ---------------------------
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
cat(foil1Table_string)
cat('\n\n')
cat(dist1_string)
cat('\n\n')
cat(foil2_string)
cat('\n\n')
cat(foil2Pos_string)
cat('\n\n')
cat(foil2Table_string)
cat('\n\n')
cat(dist2_string)
cat('\n\n')
cat(roomNum_probe_string)
cat('\n\n')
cat(roomType_string)
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
cat('probe = JSON.parse(probe);')
cat('\n\n')
cat('objNum = JSON.parse(objNum);')
cat('\n\n')
cat('targetPos = JSON.parse(targetPos);')
cat('\n\n')
cat('foil1 = JSON.parse(foil1);')
cat('\n\n')
cat('foil1Pos = JSON.parse(foil1Pos);')
cat('\n\n')
cat('foil1Table = JSON.parse(foil1Table);')
cat('\n\n')
cat('dist1 = JSON.parse(dist1);')
cat('\n\n')
cat('foil2 = JSON.parse(foil2);')
cat('\n\n')
cat('foil2Pos = JSON.parse(foil2Pos);')
cat('\n\n')
cat('foil2Table = JSON.parse(foil2Table);')
cat('\n\n')
cat('dist2 = JSON.parse(dist2);')
cat('\n\n')
cat('roomNum_probe = JSON.parse(roomNum_probe);')
cat('\n\n')
cat('roomType = JSON.parse(roomType);')
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
save.image('trialData_randomFoils_exp3.RData')