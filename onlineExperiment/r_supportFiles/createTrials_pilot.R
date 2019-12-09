# This script creates trials for boundaryVR memory task as a javascript
# This script was used for the pilot (before batch 1 and 2). For this pilot
# both next and before was used as a question. 
# It includes the following constraints:
# For temporal memory: foils can't be in the same room as target. Each object
# is used twice as foil. 
# For context memory: no constraints 

# /* 
# ----------------------------- Set up ---------------------------
# */
nTrials      <- 88 # 88 - 2 because first and last object are fixed
before       <- 'What came before this object?'
after        <- 'What came after this object?'
tempQuestion <- rep(c(before, after), each = 86/2)

# Setting wd
setwd("U:/Projects/boundaryVR/onlineExperiment/r_supportFiles")

# /* 
# ----------------------------- Video2 ---------------------------
# */
# This pilot only included video2.
# Loading object order
objectOrder        <- read.csv('objectOrder.csv', sep = '\t', header = FALSE)
names(objectOrder) <- c('objNum', 'objNam')
numObj             <- length(objectOrder$objNum)
rooms              <- numObj/2
objectOrder$pos    <- 1:numObj
objectOrder$table  <- rep(c(2, 3), rooms)
objectOrder$room   <- rep(1:rooms, each = 2)
objNum             <- objectOrder$objNum

# /* 
# ----------------------------- Temporal order ---------------------------
# */
# Creating trial data
set.seed(222)
trialData_video2 <- objectOrder

# Assign temporal order question with constraint that first and last are set to be after and before respectively
trialData_video2$tempQuestion <-  c(after, sample(tempQuestion), before)

# Get the temporal order target depending on the question
# and determine whether the target is in the same room
tempTarget <- c()
sameRoom   <- c()
for(i in 1:numObj){
  if(trialData_video2$tempQuestion[i] == after){
    tempTarget[i] <- trialData_video2$objNum[i + 1]
    if(trialData_video2$room[i + 1] == trialData_video2$room[i]){
      sameRoom[i] <- 1
    } else {
      sameRoom[i] <- 0
    }
  } else {
    tempTarget[i] <- trialData_video2$objNum[i - 1]
    if(trialData_video2$room[i - 1] == trialData_video2$room[i]){
      sameRoom[i] <- 1
    } else {
      sameRoom[i] <- 0
    }
  }
}
trialData_video2$tempTarget <- tempTarget
trialData_video2$sameRoom   <- sameRoom

# Selecting foils
# Only constraint used here is that foils can't be in the same room with target. 
# Otherwise randomly shuffled until they can serve as foil
# Get temporal Foil 1 and 2
index          <- sample(1:numObj)
tempFoil1      <- objNum[index]
tempFoil1_room <- trialData_video2$room[index]

index          <- sample(1:numObj)
tempFoil2      <- objNum[index]
tempFoil2_room <- trialData_video2$room[index]

# Run until all conditions are fulfilled
while(any(tempFoil1 == tempFoil2) | 
      any(tempFoil1 == tempTarget) | 
      any(tempFoil2 == tempTarget) |
      any(tempFoil1_room == trialData_video2$room) |
      any(tempFoil2_room == trialData_video2$room)){
  index          <- sample(1:numObj)
  tempFoil1      <- objNum[index]
  tempFoil1_room <- trialData_video2$room[index]
  
  index          <- sample(1:numObj)
  tempFoil2      <- objNum[index]
  tempFoil2_room <- trialData_video2$room[index]
}
trialData_video2$tempFoil1 <- tempFoil1
trialData_video2$tempFoil2 <- tempFoil2

# /* 
# ----------------------------- Context memory ---------------------------
# */
# Get context Foil 1 and 2
index    <- sample(1:numObj)
conFoil1 <- trialData_video2$room[index]
index    <- sample(1:numObj)
conFoil2 <- trialData_video2$room[index]

# Run until all conditions are fulfilled
while(any(conFoil1 == conFoil2) | 
      any(conFoil1 == trialData_video2$room) | 
      any(conFoil2 == trialData_video2$room)){
  index           <- sample(1:numObj)
  conFoil1       <- trialData_video2$room[index]
  index           <- sample(1:numObj)
  conFoil2       <- trialData_video2$room[index]
  
}
trialData_video2$conFoil1 <- conFoil1
trialData_video2$conFoil2 <- conFoil2

# /* 
# ----------------------------- Foil position ---------------------------
# */
# Randomly select position of target and foils for temporal order
temp_targetPos <- c()
temp_foil1Pos  <- c()
temp_foil2Pos  <- c()
for(i in 1:nTrials){
  shuffle        <- sample(1:3)
  temp_targetPos[i] <- shuffle[1]
  temp_foil1Pos[i]  <- shuffle[2]
  temp_foil2Pos[i]  <- shuffle[3]
}
trialData_video2$temp_targetPos <- temp_targetPos
trialData_video2$temp_foil1Pos  <- temp_foil1Pos
trialData_video2$temp_foil2Pos  <- temp_foil2Pos

# Randomly select position of target and foils for context memory
con_targetPos <- c()
con_foil1Pos  <- c()
con_foil2Pos  <- c()
for(i in 1:nTrials){
  shuffle        <- sample(1:3)
  con_targetPos[i] <- shuffle[1]
  con_foil1Pos[i]  <- shuffle[2]
  con_foil2Pos[i]  <- shuffle[3]
}
trialData_video2$con_targetPos <- con_targetPos
trialData_video2$con_foil1Pos  <- con_foil1Pos
trialData_video2$con_foil2Pos  <- con_foil2Pos

# /* 
# ----------------------------- Create strings ---------------------------
# */
## Temporal order
prefix <- 'stimuli/temporalOrder/'
suffix <- '.png'

objNum_string          <- paste(trialData_video2$objNum, ',', sep = '')
objNum_string[1]       <- paste('objNum = [', trialData_video2$objNum[1], ',', sep = '')
objNum_string[nTrials] <- paste(trialData_video2$objNum[nTrials], '];', sep = '')
objNum_string          <- paste(objNum_string , collapse = '', sep = '')

tempProbe_string          <- paste('\t"', prefix ,trialData_video2$objNum, suffix, '"', ',\n', sep = '')
tempProbe_string[1]       <- paste('tempProbe = ["', prefix, trialData_video2$objNum[1], suffix, '"', ',\n', sep = '')
tempProbe_string[nTrials] <- paste('\t"', prefix, trialData_video2$objNum[nTrials], suffix, '"', '];', sep = '')
tempProbe_string          <- paste(tempProbe_string , collapse = '', sep = '')

tempTarget_string          <- paste('\t"', prefix ,trialData_video2$tempTarget, suffix, '"', ',\n', sep = '')
tempTarget_string[1]       <- paste('tempTarget = ["', prefix, trialData_video2$tempTarget[1], suffix, '"', ',\n', sep = '')
tempTarget_string[nTrials] <- paste('\t"', prefix, trialData_video2$tempTarget[nTrials], suffix, '"', '];', sep = '')
tempTarget_string          <- paste(tempTarget_string , collapse = '', sep = '')

temp_targetPos_string          <- paste(trialData_video2$temp_targetPos, ',', sep = '')
temp_targetPos_string[1]       <- paste('temp_targetPos = [', trialData_video2$temp_targetPos[1], ',', sep = '')
temp_targetPos_string[nTrials] <- paste(trialData_video2$temp_targetPos[nTrials], '];', sep = '')
temp_targetPos_string          <- paste(temp_targetPos_string , collapse = '', sep = '')

tempFoil1_string          <- paste('\t"', prefix ,trialData_video2$tempFoil1, suffix, '"', ',\n', sep = '')
tempFoil1_string[1]       <- paste('tempFoil1 = ["', prefix, trialData_video2$tempFoil1[1], suffix, '"', ',\n', sep = '')
tempFoil1_string[nTrials] <- paste('\t"', prefix, trialData_video2$tempFoil1[nTrials], suffix, '"', '];', sep = '')
tempFoil1_string          <- paste(tempFoil1_string , collapse = '', sep = '')

temp_foil1Pos_string          <- paste(trialData_video2$temp_foil1Pos, ',', sep = '')
temp_foil1Pos_string[1]       <- paste('temp_foil1Pos = [', trialData_video2$temp_foil1Pos[1], ',', sep = '')
temp_foil1Pos_string[nTrials] <- paste(trialData_video2$temp_foil1Pos[nTrials], '];', sep = '')
temp_foil1Pos_string          <- paste(temp_foil1Pos_string , collapse = '', sep = '')

tempFoil2_string          <- paste('\t"', prefix ,trialData_video2$tempFoil2, suffix, '"', ',\n', sep = '')
tempFoil2_string[1]       <- paste('tempFoil2 = ["', prefix, trialData_video2$tempFoil2[1], suffix, '"', ',\n', sep = '')
tempFoil2_string[nTrials] <- paste('\t"', prefix, trialData_video2$tempFoil2[nTrials], suffix, '"', '];', sep = '')
tempFoil2_string          <- paste(tempFoil2_string , collapse = '', sep = '')

temp_foil2Pos_string          <- paste(trialData_video2$temp_foil2Pos, ',', sep = '')
temp_foil2Pos_string[1]       <- paste('temp_foil2Pos = [', trialData_video2$temp_foil2Pos[1], ',', sep = '')
temp_foil2Pos_string[nTrials] <- paste(trialData_video2$temp_foil2Pos[nTrials], '];', sep = '')
temp_foil2Pos_string          <- paste(temp_foil2Pos_string , collapse = '', sep = '')

questionString          <- paste('\t"', trialData_video2$tempQuestion, '"', ',\n', sep = '')
questionString[1]       <- paste('question = ["',trialData_video2$tempQuestion[1], '"', ',\n', sep = '')
questionString[nTrials] <- paste('\t"', trialData_video2$tempQuestion[nTrials], '"', '];', sep = '')
questionString          <- paste(questionString, collapse = '', sep = '')

## Context memory
prefix <- 'stimuli/contextMemory/'
suffix <- '.png'

# conProbe_string          <- paste('\t"', prefix ,trialData_video2$room, suffix, '"', ',\n', sep = '')
# conProbe_string[1]       <- paste('conProbe = ["', prefix, trialData_video2$room[1], suffix, '"', ',\n', sep = '')
# conProbe_string[nTrials] <- paste('\t"', prefix, trialData_video2$room[nTrials], suffix, '"', '];', sep = '')
# conProbe_string          <- paste(conProbe_string , collapse = '', sep = '')
conProbe_string <- 'conProbe = tempProbe;'

conTarget_string          <- paste('\t"', prefix ,trialData_video2$room, suffix, '"', ',\n', sep = '')
conTarget_string[1]       <- paste('conTarget = ["', prefix, trialData_video2$room[1], suffix, '"', ',\n', sep = '')
conTarget_string[nTrials] <- paste('\t"', prefix, trialData_video2$room[nTrials], suffix, '"', '];', sep = '')
conTarget_string          <- paste(conTarget_string , collapse = '', sep = '')

con_targetPos_string          <- paste(trialData_video2$con_targetPos, ',', sep = '')
con_targetPos_string[1]       <- paste('con_targetPos = [', trialData_video2$con_targetPos[1], ',', sep = '')
con_targetPos_string[nTrials] <- paste(trialData_video2$con_targetPos[nTrials], '];', sep = '')
con_targetPos_string          <- paste(con_targetPos_string , collapse = '', sep = '')

conFoil1_string          <- paste('\t"', prefix ,trialData_video2$conFoil1, suffix, '"', ',\n', sep = '')
conFoil1_string[1]       <- paste('conFoil1 = ["', prefix, trialData_video2$conFoil1[1], suffix, '"', ',\n', sep = '')
conFoil1_string[nTrials] <- paste('\t"', prefix, trialData_video2$conFoil1[nTrials], suffix, '"', '];', sep = '')
conFoil1_string          <- paste(conFoil1_string , collapse = '', sep = '')

con_foil1Pos_string          <- paste(trialData_video2$con_foil1Pos, ',', sep = '')
con_foil1Pos_string[1]       <- paste('con_foil1Pos = [', trialData_video2$con_foil1Pos[1], ',', sep = '')
con_foil1Pos_string[nTrials] <- paste(trialData_video2$con_foil1Pos[nTrials], '];', sep = '')
con_foil1Pos_string          <- paste(con_foil1Pos_string , collapse = '', sep = '')

conFoil2_string          <- paste('\t"', prefix ,trialData_video2$conFoil2, suffix, '"', ',\n', sep = '')
conFoil2_string[1]       <- paste('conFoil2 = ["', prefix, trialData_video2$conFoil2[1], suffix, '"', ',\n', sep = '')
conFoil2_string[nTrials] <- paste('\t"', prefix, trialData_video2$conFoil2[nTrials], suffix, '"', '];', sep = '')
conFoil2_string          <- paste(conFoil2_string , collapse = '', sep = '')

con_foil2Pos_string          <- paste(trialData_video2$con_foil2Pos, ',', sep = '')
con_foil2Pos_string[1]       <- paste('con_foil2Pos = [', trialData_video2$con_foil2Pos[1], ',', sep = '')
con_foil2Pos_string[nTrials] <- paste(trialData_video2$con_foil2Pos[nTrials], '];', sep = '')
con_foil2Pos_string          <- paste(con_foil2Pos_string , collapse = '', sep = '')

# /* 
# ----------------------------- Create text file  ---------------------------
# */
sink('stimuliList_video2.js')
cat(objNum_string)
cat('\n\n')
cat(tempProbe_string)
cat('\n\n')
cat(tempTarget_string)
cat('\n\n')
cat(temp_targetPos_string)
cat('\n\n')
cat(tempFoil1_string)
cat('\n\n')
cat(temp_foil1Pos_string)
cat('\n\n')
cat(tempFoil2_string)
cat('\n\n')
cat(temp_foil2Pos_string)
cat('\n\n')
cat(questionString)
cat('\n\n')
cat(conProbe_string)
cat('\n\n')
cat(conTarget_string)
cat('\n\n')
cat(con_targetPos_string)
cat('\n\n')
cat(conFoil1_string)
cat('\n\n')
cat(con_foil1Pos_string)
cat('\n\n')
cat(conFoil2_string)
cat('\n\n')
cat(con_foil2Pos_string)
sink()

# Write image file
save.image('trialData_video2.RData')


# /* 
# ----------------------------- Checks ---------------------------
# */
# How often does it uses the same room?
table(sameRoom)

# How often is one room type used? 
test1 <- subset(trialData_video2, sameRoom == 1)
table(test1$room %% 2 == 0)
