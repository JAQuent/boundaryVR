# This script creates figures for chapter 4 (bondaryVR)

# Figure numbering starts with 3
# It creates the following plots
# 1. Data from Horner et al. (2016)
# 2. Interaction plot for exp1a, 1b and 1c
# 3. Plot for room & table question for for exp1a, 1b and 1c
# 4. Power analysis plot
# 5. Plot of boundary effect for exp 2 and 3

# /* 
# ----------------------------- Setting up ---------------------------
# */
######################################################
# Path to parent folder bondaryVR
path2parent <- "D:/Alex/Laptop/Documents/boundaryVR" # This need to be changed to run this document
######################################################

setwd(path2parent)

# Libs
library(plyr)
library(ggplot2)
library(cowplot)
library(gridExtra)
library(grid)
library(knitr)
library(assortedRFunctions)
library(MRColour)
library(egg)
library(reshape2)
library(latex2exp)

# Plot parameters
# Set theme default
updatedTheme <- theme_grey() + theme(axis.title.x  = element_text(size = 12),
                                     axis.title.y  = element_text(size = 10),
                                     axis.text.y  = element_text(size = 10),
                                     axis.text.x  = element_text(size = 10),
                                     plot.title = element_text(size = 12))

theme_set(updatedTheme)

# /* 
# ----------------------------- 1. Data from Horner et al. (2016) ---------------------------
# */
horner_exp1      <- read.table('data/Horner_data/exp1.txt', header = TRUE, sep = '\t')
horner_exp1_long <- melt(horner_exp1, id.vars=c("id", "group"))

horner_exp2        <- read.table('data/Horner_data/exp2.txt', header = TRUE, sep = '\t')
names(horner_exp2) <- tolower(names(horner_exp2))
horner_exp2_long   <- melt(horner_exp2, id.vars=c("id", "ord"))

horner_exp3        <- read.table('data/Horner_data/exp3.txt', header = TRUE, sep = '\t')
names(horner_exp3) <- tolower(names(horner_exp3))
horner_exp3_long   <- melt(horner_exp3, id.vars=c("id", "ord"))

## Aggregate to within vs. across
names(horner_exp1_long) <- c('id', 'group', 'boundary', 'value')

horner_exp2_long$boundary <- ifelse(horner_exp2_long$variable == 'after.within.context' | 
                                    horner_exp2_long$variable == 'before.within.context',
                                    'within', 'across')

horner_exp2_agg <- ddply(horner_exp2_long, c('id', 'boundary'), summarise, value = mean(value))

horner_exp3_long$boundary <- ifelse(horner_exp3_long$variable == 'after.within.context' | 
                                    horner_exp3_long$variable == 'before.within.context',
                                    'within', 'across')

horner_exp3_agg <- ddply(horner_exp3_long, c('id', 'boundary'), summarise, value = mean(value))

# Make boundary with capital letter
horner_exp1_long$Boundary <- horner_exp1_long$boundary
horner_exp2_agg$Boundary <- horner_exp2_agg$boundary
horner_exp3_agg$Boundary <- horner_exp3_agg$boundary


# Plot
horner_exp1_long$Boundary <- factor(horner_exp1_long$Boundary, levels = c('across', 'within'), labels = c('across', 'within'))
plt1 <- ggplot(horner_exp1_long, aes(x = Boundary, y = value, fill = Boundary)) + 
  #geom_line(aes(group = id)) +
  #geom_point() +
  geom_jitter(height = 0, width = 0.1) +
  geom_boxplot(width = 0.5, alpha = 0.5) + 
  geom_hline(yintercept = 1/3) +
  stat_summary(geom = "point", fun = "mean", col = 'black', size = 3, shape = 24, aes(fill = Boundary), key_glyph = "rect")+
  scale_fill_manual(values = mrc_pal("secondary")(4)[3:4], labels = c('across', 'within')) +
  labs(title = 'Horner et al. (2016): Exp 1', y = "3AFC accruacy", x = 'Boundary') +
  coord_cartesian(ylim = c(0, 1)) +
  theme(legend.justification = c(0, 1), 
        legend.position = c(0, 1),
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 9),
        legend.key.size = unit(0.5,"line"))

plt2 <- ggplot(horner_exp2_agg, aes(x = boundary, y = value, fill = Boundary)) + 
  #geom_line(aes(group = id)) +
  #geom_point() +
  geom_jitter(height = 0, width = 0.1) +
  geom_boxplot(width = 0.5, alpha = 0.5) + 
  geom_hline(yintercept = 1/3) +
  stat_summary(geom = "point", fun = "mean", col = 'black', size = 3, shape = 24, aes(fill = Boundary), key_glyph = "rect")+
  scale_fill_manual(values = mrc_pal("secondary")(4)[3:4], labels = c('across', 'within')) +
  labs(title = 'Horner et al. (2016): Exp 2', y = "3AFC accruacy", x = 'Boundary') +
  coord_cartesian(ylim = c(0, 1)) +
  theme(legend.justification = c(0, 1), 
        legend.position = 'none')

plt3 <- ggplot(horner_exp3_agg, aes(x = boundary, y = value, fill = Boundary)) + 
  #geom_line(aes(group = id)) +
  #geom_point() +
  geom_jitter(height = 0, width = 0.1) +
  geom_boxplot(width = 0.5, alpha = 0.5) + 
  geom_hline(yintercept = 1/3) +
  stat_summary(geom = "point", fun = "mean", col = 'black', size = 3, shape = 24, aes(fill = Boundary), key_glyph = "rect")+
  scale_fill_manual(values = mrc_pal("secondary")(4)[3:4], labels = c('across', 'within')) +
  labs(title = 'Horner et al. (2016): Exp 3', y = "3AFC accruacy", x = 'Boundary') +
  coord_cartesian(ylim = c(0, 1)) +
  theme(legend.justification = c(0, 1), 
        legend.position = 'none')


# /* 
# ----------------------------- 2. Interaction plot for exp1a, 1b and 1c ---------------------------
# */
# /* 
# ----------------------------- Load data Exp1a ---------------------------
# */
# Load all data
prefix         <- "data/Exp1/batch1/memoryTask/"
allFiles       <- list.files(paste(prefix, sep = ''))
allFiles_paths <- paste(prefix, allFiles, sep = '')
n              <- length(allFiles_paths)

for(i in 1:n){
  ##
  # Load data files
  tempDF <- read.csv(allFiles_paths[i], header = TRUE, na.strings = '')
  
  # Recode key presses
  response      <- rep(NA, dim(tempDF)[1])
  response[tempDF$key_press == 49] <- 1
  response[tempDF$key_press == 50] <- 2
  response[tempDF$key_press == 51] <- 3
  tempDF$response <- response
  
  ##
  # Temporal order
  temporalOrder    <- subset(tempDF, test_part == 'temporalOrder')
  temporalOrder$rt <- as.numeric(as.character(temporalOrder$rt))
  
  # Calculate accuracy
  accuracy <- rep(NA, dim(temporalOrder)[1])
  accuracy[temporalOrder$response == temporalOrder$corr_resp] <- 1
  accuracy[temporalOrder$response != temporalOrder$corr_resp] <- 0
  temporalOrder$accuracy <- accuracy
  
  ##
  # Room type question
  roomType      <- subset(tempDF, test_part == 'roomType')
  roomType$rt   <- as.numeric(as.character(roomType$rt))
  
  # Calculate accuracy
  accuracy <- rep(NA, dim(roomType)[1])
  accuracy[roomType$response == roomType$corr_resp] <- 1
  accuracy[roomType$response != roomType$corr_resp] <- 0
  roomType$accuracy <- accuracy
  
  ##
  # Table question
  tableNum      <- subset(tempDF, test_part == 'tableNum')
  tableNum$rt   <- as.numeric(as.character(tableNum$rt))
  
  # Recode because tables are named 2 and 3 in input data
  tableNum$response[tableNum$key_press == 49] <- 3 # for key press 1
  tableNum$response[tableNum$key_press == 50] <- 2 # for key press 2
  
  # Calculate accuracy
  accuracy <- rep(NA, dim(tableNum)[1])
  accuracy[tableNum$response == tableNum$corr_resp] <- 1
  accuracy[tableNum$response != tableNum$corr_resp] <- 0
  tableNum$accuracy <- accuracy
  
  # Add subject ID and concatenate to 1 data.frame
  if(i == 1){
    df_order    <- temporalOrder
    df_order$id <- i
    df_room     <- roomType
    df_room$id  <- i
    df_table    <- tableNum
    df_table$id <- i
  } else {
    temporalOrder$id <- i
    df_order         <- rbind(df_order, temporalOrder)
    roomType$id      <- i
    df_room          <- rbind(df_room, roomType)
    tableNum$id      <- i
    df_table         <- rbind(df_table, tableNum)
  }
}

# Rename according for batch1
df_order_b1 <- df_order 
df_room_b1  <- df_room
df_table_b1 <- df_table

# Convert ID to factor
df_order_b1$id <- as.factor(df_order_b1$id)
df_room_b1$id  <- as.factor(df_room_b1$id)
df_table_b1$id <- as.factor(df_table_b1$id)

# Recode factor levels
levels(df_order_b1$context) <- c('across', 'within-open plane', 'within-M-shape')

# Calculate mean accuracy
agg_order_b1 <- ddply(df_order_b1, c('id', 'context'), summarise, acc = mean(accuracy), rt = mean(rt))
agg_room_b1  <- ddply(df_room_b1, c('id'), summarise, acc = mean(accuracy))
agg_table_b1 <- ddply(df_table_b1, c('id'), summarise, acc = mean(accuracy))

# Do arcsine transformation
agg_order_b1$trans_acc <- arcsine_transform(agg_order_b1$acc)
agg_room_b1$trans_acc  <- arcsine_transform(agg_room_b1$acc)
agg_table_b1$trans_acc <- arcsine_transform(agg_table_b1$acc)

# Rename factor
agg_order_b1$boundary <- ifelse(agg_order_b1$context == 'across', 'across', 'within')
agg_order_b1$Condition <- 'across'
agg_order_b1$Condition[agg_order_b1$context == 'within-no-walls'] <- 'O-room'
agg_order_b1$Condition[agg_order_b1$context == 'within-walls']    <- 'M-room'

# Get trial number etc. 
exp1a_trials     <- ddply(df_order_b1, c('id','condition', 'context'), summarise, n = length(id))
exp1a_trials_agg <- ddply(exp1a_trials, c('condition', 'context'), summarise, n = mean(n))



# Split across trials
df_order_b1_roomInfo           <- df_order_b1
df_order_b1_roomInfo$roomType  <- df_room_b1$corr_resp
df_order_b1_roomInfo$roomType  <- ifelse(df_order_b1_roomInfo$roomType == 1, 'O-room', 'M-room')
agg_order_b1_roomInfo          <- ddply(df_order_b1_roomInfo, c('id', 'context', 'roomType'), summarise, acc = mean(accuracy), rt = mean(rt))
agg_order_b1_roomInfo$boundary <- ifelse(agg_order_b1_roomInfo$context == 'across', 'across', 'within')
agg_order_b1_roomInfo$Condition <- 'across'
agg_order_b1_roomInfo$Condition[agg_order_b1_roomInfo$context == 'within-open plane'] <- 'O-room'
agg_order_b1_roomInfo$Condition[agg_order_b1_roomInfo$context == 'within-M-shape']    <- 'M-room'

# /* 
# ----------------------------- Plot Exp1a ---------------------------
# */

plt4 <- ggplot(agg_order_b1_roomInfo, aes(x = boundary, y = acc, fill = interaction(boundary,roomType))) + 
  geom_boxplot(alpha = 0.5,outlier.shape = NA, key_glyph = "rect") + 
  geom_point(position = position_jitterdodge(jitter.width = 0.2)) + 
  geom_hline(yintercept = 1/3) +
  stat_summary(geom = "point", fun = "mean", col = 'black', size = 3, shape = 24, aes(fill = interaction(boundary,roomType)),
               position=position_dodge(width =  0.75),
               key_glyph = "rect") + 
  scale_color_mrc(palette = 'secondary') + 
  scale_fill_manual(values = mrc_pal("secondary")(4), labels = c('M-room & across', 'M-room & within', 'O-room & across', 'O-room & within')) +
  labs(y = '3AFC accuracy', x = "Boundary", title = 'Exp 1a') + 
  theme(legend.justification = c(0, 1), 
        legend.position = c(0, 1),
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 9),
        legend.key.size = unit(0.5,"line")) +
  coord_cartesian(ylim = c(0, 1))  + 
  guides(fill = guide_legend("Room type x boundary"))

# /* 
# ----------------------------- Load data Exp1b ---------------------------
# */
# Load trial information
load("experiments/Exp1/batch2/r_supportFiles/trialData_20200522_182214.RData")
# Note that counterbalancing in that images goes from 1 to 8, while it goes from 0 to 7 in the javascript
# files.

# Order trial information
trials_cond5 <- trials_cond5[order(trials_cond5$objNum),]
trials_cond6 <- trials_cond6[order(trials_cond6$objNum),]
trials_cond7 <- trials_cond7[order(trials_cond7$objNum),]
trials_cond8 <- trials_cond8[order(trials_cond8$objNum),]

# Load all data
prefix         <- 'data/Exp1/batch2/memoryTask/'
allFiles       <- list.files(paste(prefix, sep = ''))
allFiles_paths <- paste(prefix, allFiles, sep = '')
n              <- length(allFiles_paths)

for(i in 1:n){
  ##
  # Loading data
  tempDF <- read.csv(allFiles_paths[i], header = TRUE, na.strings = '')
  
  # Recode key presses
  response      <- rep(NA, dim(tempDF)[1])
  response[tempDF$key_press == 49] <- 1
  response[tempDF$key_press == 50] <- 2
  response[tempDF$key_press == 51] <- 3
  tempDF$response                  <- response
  
  ##
  # Temporal order memory
  temporalOrder <- subset(tempDF, test_part == 'temporalOrder')
  
  # Sort by objectNumber
  temporalOrder <- temporalOrder[order(temporalOrder$probe),]
  
  # get trialinfo and add to temporalOrder
  cond <- temporalOrder$condition[1] + 1 # to correct for difference
  temporalOrder$foil1Pos <- get(paste0("trials_cond", cond))$foil1Pos
  temporalOrder$foil2Pos <- get(paste0("trials_cond", cond))$foil2Pos
  
  temporalOrder$rt <- as.numeric(as.character(temporalOrder$rt))
  
  # Calcalate accuracy 
  accuracy <- rep(NA, dim(temporalOrder)[1])
  accuracy[temporalOrder$response == temporalOrder$corr_resp] <- 1
  accuracy[temporalOrder$response != temporalOrder$corr_resp] <- 0
  temporalOrder$accuracy <- accuracy
  
  # Create variable that desribe whether target, foil1, foil2 was choosen
  choice <- rep('Target', dim(temporalOrder)[1])
  choice[temporalOrder$response == temporalOrder$foil1Pos] <- 'Foil 1'
  choice[temporalOrder$response == temporalOrder$foil2Pos] <- 'Foil 2'
  temporalOrder$choice <- choice
  
  ##
  # Room type question
  roomType      <- subset(tempDF, test_part == 'roomType')
  roomType$rt   <- as.numeric(as.character(roomType$rt))
  
  # get trialinfo and add to roomType
  cond               <- roomType$condition[1] + 1 # to correct for difference
  roomType$roomType  <- get(paste0("trials_cond", cond))$roomType
  
  corr_room <- rep(NA, nrow(roomType))
  corr_room[roomType$roomType  == "nw"] <- 1
  corr_room[roomType$roomType  == "ww"] <- 2
  roomType$corr_room <- corr_room
  
  # Calculate accuracy
  accuracy <- rep(NA, dim(roomType)[1])
  accuracy[roomType$response == roomType$corr_room] <- 1
  accuracy[roomType$response != roomType$corr_room] <- 0
  roomType$accuracy <- accuracy
  
  ##
  # Table question
  tableNum      <- subset(tempDF, test_part == 'tableNum')
  tableNum$rt   <- as.numeric(as.character(tableNum$rt))
  
  # Recode keypresses
  response      <- rep(NA, dim(tableNum)[1])
  response[tableNum$key_press == 49] <- 3 # for key press 1
  response[tableNum$key_press == 50] <- 2 # for key press 2
  tableNum$response                  <- response
  
  # Calculate accuracy
  accuracy <- rep(NA, dim(tableNum)[1])
  accuracy[tableNum$response == tableNum$corr_resp] <- 1
  accuracy[tableNum$response != tableNum$corr_resp] <- 0
  tableNum$accuracy <- accuracy
  
  # Create or bind to data.frame
  if(i == 1){
    df_order_b2    <- temporalOrder
    df_order_b2$id <- i
    df_room_b2     <- roomType
    df_room_b2$id  <- i
    df_table_b2    <- tableNum
    df_table_b2$id <- i
  } else {
    temporalOrder$id <- i
    df_order_b2      <- rbind(df_order_b2, temporalOrder)
    roomType$id      <- i
    df_room_b2       <- rbind(df_room_b2, roomType)
    tableNum$id      <- i
    df_table_b2      <- rbind(df_table_b2, tableNum)
  }
}

# Convert to id factor
df_order_b2$id <- as.factor(df_order_b2$id)
df_room_b2$id  <- as.factor(df_room_b2$id)
df_table_b2$id <- as.factor(df_table_b2$id)

# Recode factor levels
levels(df_order_b2$context) <- c('across', 'within-open plane', 'within-M-shape')

# Calculate mean accuracy
agg_order_b2 <- ddply(df_order_b2, c('id', 'context'), summarise, acc = mean(accuracy), rt = mean(rt))
agg_room_b2  <- ddply(df_room_b2, c('id'), summarise, acc = mean(accuracy))
agg_table_b2 <- ddply(df_table_b2, c('id'), summarise, acc = mean(accuracy))

# Transform accuracy
agg_order_b2$trans_acc <- arcsine_transform(agg_order_b2$acc)
agg_room_b2$trans_acc  <- arcsine_transform(agg_room_b2$acc)
agg_table_b2$trans_acc <- arcsine_transform(agg_table_b2$acc)

# Rename factor
agg_order_b2$boundary <- ifelse(agg_order_b2$context == 'across', 'across', 'within')
agg_order_b2$Condition <- 'across'
agg_order_b2$Condition[agg_order_b2$context == 'within-no-walls'] <- 'O-room'
agg_order_b2$Condition[agg_order_b2$context == 'within-walls']    <- 'M-room'

# Get trial number etc. 
exp1b_trials     <- ddply(df_order_b2, c('id','condition', 'context'), summarise, n = length(id))
exp1b_trials_agg <- ddply(exp1b_trials, c('condition', 'context'), summarise, n = mean(n))


# Splitting across trials
df_order_b2_roomInfo <- df_order_b2
df_order_b2_roomInfo <- df_order_b2_roomInfo[order(df_order_b2_roomInfo$id,df_order_b2_roomInfo$trial_index),]
df_room_b2           <- df_room_b2[order(df_room_b2$id, df_room_b2$trial_index),]
df_order_b2_roomInfo$roomType  <- df_room_b2$corr_resp
df_order_b2_roomInfo$roomType  <- ifelse(df_order_b2_roomInfo$roomType == 1, 'O-room', 'M-room')
agg_order_b2_roomInfo          <- ddply(df_order_b2_roomInfo, c('id', 'context', 'roomType'), summarise, acc = mean(accuracy), rt = mean(rt))
agg_order_b2_roomInfo$boundary <- ifelse(agg_order_b2_roomInfo$context == 'across', 'across', 'within')
agg_order_b2_roomInfo$Condition <- 'across'
agg_order_b2_roomInfo$Condition[agg_order_b2_roomInfo$context == 'within-open plane'] <- 'O-room'
agg_order_b2_roomInfo$Condition[agg_order_b2_roomInfo$context == 'within-M-shape']    <- 'M-room'

# /* 
# ----------------------------- Plot Exp1b ---------------------------
# */
plt5 <- ggplot(agg_order_b2_roomInfo, aes(x = boundary, y = acc, fill = interaction(boundary,roomType))) + 
  geom_boxplot(alpha = 0.5,outlier.shape = NA, key_glyph = "rect") + 
  geom_point(position = position_jitterdodge(jitter.width = 0.2)) + 
  geom_hline(yintercept = 1/3) +
  stat_summary(geom = "point", fun = "mean", col = 'black', size = 3, shape = 24, aes(fill = interaction(boundary,roomType)),
               position=position_dodge(width =  0.75),
               key_glyph = "rect") + 
  scale_color_mrc(palette = 'secondary') + 
  scale_fill_mrc(palette = 'secondary') +
  labs(y = '3AFC accuracy', x = "Boundary", title = 'Exp 1b') + 
  theme(legend.justification = c(0, 1), 
        legend.position = 'none') +
  coord_cartesian(ylim = c(0, 1))


# /* 
# ----------------------------- Load data Exp1c ---------------------------
# */
# Load all data
prefix         <- 'data/Exp1/batch3/memoryTask/'
allFiles       <- list.files(paste(prefix, sep = ''))
allFiles_paths <- paste(prefix, allFiles, sep = '')
n              <- length(allFiles_paths)

# Load trial information
load("experiments/Exp1/batch3/r_supportFiles/trialData_randomFoils.RData")
# Note that counterbalancing in that images goes from 1 to 8, while it goes from 0 to 7 in the javascript
# files.

# Order trial information
# Due to an error only 78 trials were tested during 
trials_cond5 <- trials_cond5[order(trials_cond5$objNum),][1:78,]
trials_cond6 <- trials_cond6[order(trials_cond6$objNum),][1:78,]
trials_cond7 <- trials_cond7[order(trials_cond7$objNum),][1:78,]
trials_cond8 <- trials_cond8[order(trials_cond8$objNum),][1:78,]

for(i in 1:n){
  ##
  # Loading data
  tempDF <- read.csv(allFiles_paths[i], header = TRUE, na.strings = '')
  
  # Recode key presses
  response      <- rep(NA, dim(tempDF)[1])
  response[tempDF$key_press == 49] <- 1
  response[tempDF$key_press == 50] <- 2
  response[tempDF$key_press == 51] <- 3
  tempDF$response                  <- response
  
  ##
  # Temporal order memory
  temporalOrder <- subset(tempDF, test_part == 'temporalOrder')
  
  # Sort by objectNumber
  temporalOrder <- temporalOrder[order(temporalOrder$probe),]
  
  # get trialinfo and add to temporalOrder
  cond <- temporalOrder$condition[1] + 1 # to correct for difference
  temporalOrder$foil1Pos <- get(paste0("trials_cond", cond))$foil1Pos
  temporalOrder$foil2Pos <- get(paste0("trials_cond", cond))$foil2Pos
  
  temporalOrder$rt <- as.numeric(as.character(temporalOrder$rt))
  
  # Calculate accuracy 
  accuracy <- rep(NA, dim(temporalOrder)[1])
  accuracy[temporalOrder$response == temporalOrder$corr_resp] <- 1
  accuracy[temporalOrder$response != temporalOrder$corr_resp] <- 0
  temporalOrder$accuracy <- accuracy
  
  # Create variable that describe whether target, foil1, foil2 was chosen
  choice <- rep('Target', dim(temporalOrder)[1])
  choice[temporalOrder$response == temporalOrder$foil1Pos] <- 'Foil 1'
  choice[temporalOrder$response == temporalOrder$foil2Pos] <- 'Foil 2'
  temporalOrder$choice <- choice
  
  ##
  # Room type question
  roomType          <- subset(tempDF, test_part == 'roomType')
  roomType$rt       <- as.numeric(as.character(roomType$rt))
  roomType$roomType <- NA
  
  # Assign room type
  cond <- roomType$condition[1] + 1 # to correct for difference
  for(j in 1:nrow(roomType)){
    temp <- get(paste0("trials_cond", cond, '_full'))
    roomType$roomType[j] <- temp[temp$room == roomType$roomNum[j], 'roomType'][1]
  }
  
  corr_room <- rep(NA, nrow(roomType))
  corr_room[roomType$roomType  == "nw"] <- 1
  corr_room[roomType$roomType  == "ww"] <- 2
  roomType$corr_room <- corr_room
  
  # Calculate accuracy
  accuracy <- rep(NA, dim(roomType)[1])
  accuracy[roomType$response == roomType$corr_room] <- 1
  accuracy[roomType$response != roomType$corr_room] <- 0
  roomType$accuracy <- accuracy
  
  # Adding table information to temporal order memory
  # Get right information and create temp variable
  tempInfo      <- get(paste0("trials_cond",  temporalOrder$condition[1]))
  tempInfo_full <- get(paste0("trials_cond",  temporalOrder$condition[1], '_full'))
  # Order both data frames by objNum/probe
  tempInfo <- tempInfo[1:78, ] # Because of an error in the code only 78 trials exist per participant
  tempInfo <- tempInfo[order(tempInfo$objNum),]
  temporalOrder <- temporalOrder[order(temporalOrder$probe),]
  
  # Transferring information between dfs
  temporalOrder$probeTable <- tempInfo$table
  # Loop through df to get table of target, foil1 and foil2
  targetTable <- c()
  foil1Table  <- c()
  foil2Table  <- c()
  for(j in 1:dim(tempInfo)[1]){
    targetTable[j] <- tempInfo_full[tempInfo_full$objNum == tempInfo$target[j], 'table']
    foil1Table[j]  <- tempInfo_full[tempInfo_full$objNum == tempInfo$foil1[j], 'table']
    foil2Table[j]  <- tempInfo_full[tempInfo_full$objNum == tempInfo$foil2[j], 'table']
  }
  
  # Add the information to main data.frame
  temporalOrder$targetTable <- targetTable
  temporalOrder$foil1Table  <- foil1Table
  temporalOrder$foil2Table  <- foil2Table
  
  ##
  # Table question
  tableNum      <- subset(tempDF, test_part == 'tableNum')
  tableNum$rt   <- as.numeric(as.character(tableNum$rt))
  
  # Recode keypresses
  response      <- rep(NA, dim(tableNum)[1])
  response[tableNum$key_press == 49] <- 3 # for key press 1
  response[tableNum$key_press == 50] <- 2 # for key press 2
  tableNum$response                  <- response
  
  # Calculate accuracy
  accuracy <- rep(NA, dim(tableNum)[1])
  accuracy[tableNum$response == tableNum$corr_resp] <- 1
  accuracy[tableNum$response != tableNum$corr_resp] <- 0
  tableNum$accuracy <- accuracy
  
  # Create or bind to data.frame
  if(i == 1){
    df_order_b3    <- temporalOrder
    df_order_b3$id <- i
    df_room_b3     <- roomType
    df_room_b3$id  <- i
    df_table_b3    <- tableNum
    df_table_b3$id <- i
  } else {
    temporalOrder$id <- i
    df_order_b3      <- rbind(df_order_b3, temporalOrder)
    roomType$id      <- i
    df_room_b3       <- rbind(df_room_b3, roomType)
    tableNum$id      <- i
    df_table_b3      <- rbind(df_table_b3, tableNum)
  }
}


# Convert to id factor
df_order_b3$id <- as.factor(df_order_b3$id)
df_room_b3$id  <- as.factor(df_room_b3$id)
df_table_b3$id <- as.factor(df_table_b3$id)

# Recode factor levels
levels(df_order_b3$context) <- c('across', 'within-open plane', 'within-M-shape')

# Calculate mean accuracy
agg_order_b3 <- ddply(df_order_b3, c('id', 'context'), summarise, acc = mean(accuracy), rt = mean(rt))
agg_room_b3  <- ddply(df_room_b3, c('id'), summarise, acc = mean(accuracy))
agg_table_b3 <- ddply(df_table_b3, c('id'), summarise, acc = mean(accuracy))

# Transform values
agg_order_b3$trans_acc <- arcsine_transform(agg_order_b3$acc)
agg_room_b3$trans_acc  <- arcsine_transform(agg_room_b3$acc)
agg_table_b3$trans_acc <- arcsine_transform(agg_table_b3$acc)

# Rename factor
agg_order_b3$boundary <- ifelse(agg_order_b3$context == 'across', 'across', 'within')
agg_order_b3$Condition <- 'across'
agg_order_b3$Condition[agg_order_b3$context == 'within-no-walls'] <- 'O-room'
agg_order_b3$Condition[agg_order_b3$context == 'within-walls']    <- 'M-room'

# Get trial number etc. 
exp1c_trials     <- ddply(df_order_b3, c('id','condition', 'context'), summarise, n = length(id))
exp1c_trials_agg <- ddply(exp1c_trials, c('condition', 'context'), summarise, n = mean(n))

# Splitting across trials
df_order_b3_roomInfo <- df_order_b3
df_order_b3_roomInfo <- df_order_b3_roomInfo[order(df_order_b3_roomInfo$id, df_order_b3_roomInfo$trial_index),]
df_room_b3           <- df_room_b3[order(df_room_b3$id, df_room_b3$trial_index),]
df_order_b3_roomInfo$roomType  <- df_room_b3$roomType
df_order_b3_roomInfo$roomType  <- ifelse(df_order_b3_roomInfo$roomType == 'nw', 'O-room', 'M-room')
agg_order_b3_roomInfo           <- ddply(df_order_b3_roomInfo, c('id', 'context', 'roomType', 'condition'), summarise, acc = mean(accuracy), rt = mean(rt))
agg_order_b3_roomInfo$boundary  <- ifelse(agg_order_b3_roomInfo$context == 'across', 'across', 'within')
agg_order_b3_roomInfo$Condition <- 'across'
agg_order_b3_roomInfo$Condition[agg_order_b3_roomInfo$context == 'within-open plane'] <- 'O-room'
agg_order_b3_roomInfo$Condition[agg_order_b3_roomInfo$context == 'within-M-shape']    <- 'M-room'

# /* 
# ----------------------------- Plot Exp1c ---------------------------
# */
plt6 <- ggplot(agg_order_b3_roomInfo, aes(x = boundary, y = acc, fill = interaction(boundary,roomType))) + 
  geom_boxplot(alpha = 0.5, outlier.shape = NA, key_glyph = "rect") + 
  geom_point(position = position_jitterdodge(jitter.width = 0.2)) + 
  geom_hline(yintercept = 1/3) +
  stat_summary(geom = "point", fun = "mean", col = 'black', size = 3, shape = 24, aes(fill = interaction(boundary,roomType)),
               position=position_dodge(width =  0.75),
               key_glyph = "rect") + 
  scale_color_mrc(palette = 'secondary') + 
  scale_fill_mrc(palette = 'secondary') +
  labs(y = '3AFC accuracy', x = "Boundary", title = 'Exp 1c') + 
  theme(legend.justification = c(0, 1), 
        legend.position = 'none')+
  coord_cartesian(ylim = c(0, 1))


# /* 
# ----------------------------- Plot: 2. Interaction plot for exp1a, 1b and 1c ---------------------------
# */
figure3 <- plot_grid(plt1, plt2, plt3, plt4, plt5, plt6, ncol = 3 , labels = 'AUTO')

save_plot("figures/figure3.png", figure3,
          base_height = 19/cm(1)*1.3,
          base_width = 19/cm(1)*1.5,
          base_aspect_ratio = 1)


# /* 
# ----------------------------- 3. Plot for room & table question for for exp1a, 1b and 1c ---------------------------
# */

# Bind room and table together
roomTable_b1 <- data.frame(id = rep(1:nrow(agg_room_b1), 2),
                           Type = rep(c('Room', 'Table'), each = nrow(agg_room_b1)),
                           acc = c(agg_room_b1$acc, agg_table_b1$acc),
                           trans_acc = c(agg_room_b1$trans_acc, agg_table_b1$trans_acc))

plt1 <- ggplot(roomTable_b1, aes(x = Type, y = acc)) + 
  geom_boxplot(alpha = 0.5,outlier.shape = NA) + 
  geom_jitter(width = 0.1, height = 0) +
  geom_hline(yintercept = 0.5) +
  stat_summary(geom = "point", fun = "mean", col = 'black', size = 3, shape = 24, fill = 'red') +
  labs(y = '2AFC accuracy', x = "Memory type", title = 'Exp 1a') +
  coord_cartesian(ylim = c(0, 1))


# Bind room and table together
roomTable_b2 <- data.frame(id = rep(1:nrow(agg_room_b2), 2),
                           Type = rep(c('Room', 'Table'), each = nrow(agg_room_b2)),
                           acc = c(agg_room_b2$acc, agg_table_b2$acc),
                           trans_acc = c(agg_room_b2$trans_acc, agg_table_b2$trans_acc))

plt2 <- ggplot(roomTable_b2, aes(x = Type, y = acc)) + 
  geom_boxplot(alpha = 0.5,outlier.shape = NA) + 
  geom_jitter(width = 0.1, height = 0) +
  geom_hline(yintercept = 0.5) +
  stat_summary(geom = "point", fun = "mean", col = 'black', size = 3, shape = 24, fill = 'red') +
  labs(y = '2AFC accuracy', x = "Memory type", title = 'Exp 1b') +
  coord_cartesian(ylim = c(0, 1))


# Bind room and table together
roomTable_b3 <- data.frame(id = rep(1:nrow(agg_room_b3), 2),
                           Type = rep(c('Room', 'Table'), each = nrow(agg_room_b3)),
                           acc = c(agg_room_b3$acc, agg_table_b3$acc),
                           trans_acc = c(agg_room_b3$trans_acc, agg_table_b3$trans_acc))

plt3 <- ggplot(roomTable_b3, aes(x = Type, y = acc)) + 
  geom_boxplot(alpha = 0.5,outlier.shape = NA) + 
  geom_jitter(width = 0.1, height = 0) +
  geom_hline(yintercept = 0.5) +
  stat_summary(geom = "point", fun = "mean", col = 'black', size = 3, shape = 24, fill = 'red') +
  labs(y = '2AFC accuracy', x = "Memory type", title = 'Exp 1c') +
  coord_cartesian(ylim = c(0, 1))

# Plot all
figure4 <- plot_grid(plt1, plt2, plt3, ncol = 3, labels = 'AUTO')

save_plot("figures/figure4.png", figure4,
          base_height = 10/cm(1)*1.3,
          base_width = 19/cm(1)*1.5,
          base_aspect_ratio = 1)


# /* 
# ----------------------------- 4. Power analysis plot---------------------------
# */
# Load data
load("analysis/powerAnalysis_Exp2_2.RData")

# For plotting
minN         <- 12
maxN         <- 36
barWidth     <- 0.9
panMar       <- 0.1
bar_yAxis    <- 0.7
hist_yAxis   <- 2900
middle_xlim  <- c(-5.5, 5.5)
crit1        <- 6
crit2        <- 1/6
breaksVal    <- c(-5, -2, 0, 2, 5)
breaksLab    <- c('1/6', '1/3', '1', '3', '6')

# Input for plot
plot_caption   <- "A"
da_sim_results <- df_H0

##
# Preparation of data
da_sim_results$trans_bf <- NA
da_sim_results$trans_bf[da_sim_results$bf < 1] <- -1/da_sim_results$bf[da_sim_results$bf < 1] + 1
da_sim_results$trans_bf[da_sim_results$bf > 1] <- da_sim_results$bf[da_sim_results$bf > 1] - 1

da_sim_results_agg <- ddply(da_sim_results, c('id'), summarise, n = n[length(n)], bf = bf[length(bf)])
da_sim_results_agg$support <- 'undecided'
da_sim_results_agg$support[da_sim_results_agg$bf > crit1] <- 'H1'
da_sim_results_agg$support[da_sim_results_agg$bf < crit2] <- 'H0'

# Creates band
da_sim_results_agg$band                                           <- '> 10'
da_sim_results_agg$band[da_sim_results_agg$bf < 10 & da_sim_results_agg$bf > 6]     <- '> 6'
da_sim_results_agg$band[da_sim_results_agg$bf < 6 & da_sim_results_agg$bf > 3]      <- '> 3'
da_sim_results_agg$band[da_sim_results_agg$bf < 3 & da_sim_results_agg$bf > 1]      <- '> 1'
da_sim_results_agg$band[da_sim_results_agg$bf < 1 & da_sim_results_agg$bf > 1/3]    <- '< 1'
da_sim_results_agg$band[da_sim_results_agg$bf < 1/3 & da_sim_results_agg$bf > 1/6]  <- '< 1/3'
da_sim_results_agg$band[da_sim_results_agg$bf < 1/6 & da_sim_results_agg$bf > 1/10] <- '< 1/6'
da_sim_results_agg$band[da_sim_results_agg$bf < 1/10]                      <- '< 1/10'

# Create factor band
da_sim_results_agg$band <- factor(da_sim_results_agg$band, levels = c('> 10', '> 6', '> 3', '> 1', '< 1', '< 1/3', '< 1/6', '< 1/10'))


# Get back to main DF
da_sim_results$band <- rep(da_sim_results_agg$band, table(da_sim_results$id))


# DF for upper histogram
da_sim_results_agg_supp_H1 <- ddply(subset(da_sim_results_agg, support == 'H1'),
                                    c('n', 'band'),
                                    summarise,
                                    freq = length(bf)/nIter)

# DF for right histogram
da_sim_results_agg_undecided <- subset(da_sim_results_agg, da_sim_results_agg$n == maxN & da_sim_results_agg$bf < crit1 & da_sim_results_agg$bf > crit2)
da_sim_results_agg_undecided$trans_bf <- NA
da_sim_results_agg_undecided$trans_bf[da_sim_results_agg_undecided$bf < 1] <- -1/da_sim_results_agg_undecided$bf[da_sim_results_agg_undecided$bf < 1] + 1
da_sim_results_agg_undecided$trans_bf[da_sim_results_agg_undecided$bf > 1] <- da_sim_results_agg_undecided$bf[da_sim_results_agg_undecided$bf > 1] - 1

# DF for lower histrogram
da_sim_results_agg_supp_H0 <- ddply(subset(da_sim_results_agg, support == 'H0'),
                                    c('n', 'band'),
                                    summarise,
                                    freq = length(bf)/nIter)

# If there are no values for this
if(nrow(da_sim_results_agg_supp_H0) == 0){
  da_sim_results_agg_supp_H0 <- data.frame(n = seq(minN, maxN, batchSize),
                                           band = rep('< 1/10', 5),
                                           freq = rep(0, 5))
}


# Upper Histogram
upper_hist <- ggplot(da_sim_results_agg_supp_H1, aes(x = n, y = freq, fill = band)) + 
  geom_bar(stat = "identity", show.legend = FALSE, alpha = 0.5, width = barWidth)  +
  scale_fill_BF() +
  coord_cartesian(ylim = c(0, bar_yAxis), xlim = c(minN - 0.5, maxN + 0.5), expand = FALSE) +
  labs(y = 'Frequency', x = '') +
  scale_x_continuous(position = 'top') + 
  theme(axis.title.x = element_text(colour = "black", size = 20),
        axis.text.x = element_text(colour = "white"),
        axis.ticks.x = element_line(colour = "white"),
        plot.margin = unit(c(panMar, panMar, panMar, 0), "cm"))

# Create line plot
linePlot <- ggplot(da_sim_results, aes(x = n, y = trans_bf, group = id, colour = band)) + 
  geom_line(alpha = 0.05, show.legend = FALSE) + 
  scale_colour_BF() +
  geom_hline(yintercept = 5) +
  geom_hline(yintercept = -5) +
  scale_y_continuous(breaks = breaksVal,
                     labels = breaksLab) +
  coord_cartesian(xlim = c(minN, maxN), ylim = middle_xlim, expand = FALSE) +
  labs(y = expression(BF[10]), x = NULL) +
  theme(axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        plot.margin = unit(c(panMar, panMar, panMar, 0), "cm"))

# Create right histogram
right_hist <- ggplot(da_sim_results_agg_undecided, aes(x = trans_bf, fill = band)) +
  coord_flip(ylim = c(0, hist_yAxis), xlim = middle_xlim, expand = FALSE) +
  geom_histogram(alpha = 0.5, show.legend = FALSE) +
  scale_fill_BF(drop = FALSE) +
  labs(y = 'Count', x = NULL) +
  theme(axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        plot.margin = unit(c(panMar, panMar, panMar, 0), "cm"))

# Create lower histogram
lower_hist <- ggplot(da_sim_results_agg_supp_H0, aes(x = n, y = freq, fill = band)) + 
  scale_y_reverse() +
  scale_fill_BF(drop = F) +
  geom_bar(stat = "identity", show.legend = FALSE, alpha = 0.5, width = barWidth) + 
  labs(y = 'Frequency', x = 'Sample size') +
  coord_cartesian(ylim = c(bar_yAxis, 0), xlim = c(minN -0.5, maxN + 0.5), expand = FALSE) +
  theme(plot.margin = unit(c(panMar, panMar, panMar, 0), "cm"))

blank <- ggplot() + theme_void()


# Combine everything into one plot
## Get Grobs
gplot1 <- ggplotGrob(upper_hist)
gplot2 <- ggplotGrob(linePlot)
gplot3 <- ggplotGrob(right_hist) 
gplot4 <- ggplotGrob(lower_hist)
gblank <- ggplotGrob(blank)

## Get gtables
gt_gplot1  <- gtable_frame(gplot1,  width = unit(12, "null"))
gt_gplot2  <- gtable_frame(gplot2,  width = unit(12, "null"))
gt_gplot3  <- gtable_frame(gplot3,  width = unit(3, "null"))
gt_gplot4  <- gtable_frame(gplot4,  width = unit(12, "null"))
gt_gBlank2 <- gtable_frame(gblank, width = unit(3, "null"))

## Combine components
gt_upper   <- gtable_frame(gtable_cbind(gt_gplot1, gt_gBlank2)) 
gt_middle  <- gtable_frame(gtable_cbind(gt_gplot2, gt_gplot3))
gt_lower   <- gtable_frame(gtable_cbind(gt_gplot4, gt_gBlank2))

## Combine into 1 plot
gtable_combined1 <- gtable_frame(gtable_rbind(gt_upper, gt_middle, gt_lower))

# Input for plot
plot_caption   <- "B"
da_sim_results <- df_H1

##
# Preparation of data
da_sim_results$trans_bf <- NA
da_sim_results$trans_bf[da_sim_results$bf < 1] <- -1/da_sim_results$bf[da_sim_results$bf < 1] + 1
da_sim_results$trans_bf[da_sim_results$bf > 1] <- da_sim_results$bf[da_sim_results$bf > 1] - 1

da_sim_results_agg <- ddply(da_sim_results, c('id'), summarise, n = n[length(n)], bf = bf[length(bf)])
da_sim_results_agg$support <- 'undecided'
da_sim_results_agg$support[da_sim_results_agg$bf > crit1] <- 'H1'
da_sim_results_agg$support[da_sim_results_agg$bf < crit2] <- 'H0'

# Creates band
da_sim_results_agg$band                                           <- '> 10'
da_sim_results_agg$band[da_sim_results_agg$bf < 10 & da_sim_results_agg$bf > 6]     <- '> 6'
da_sim_results_agg$band[da_sim_results_agg$bf < 6 & da_sim_results_agg$bf > 3]      <- '> 3'
da_sim_results_agg$band[da_sim_results_agg$bf < 3 & da_sim_results_agg$bf > 1]      <- '> 1'
da_sim_results_agg$band[da_sim_results_agg$bf < 1 & da_sim_results_agg$bf > 1/3]    <- '< 1'
da_sim_results_agg$band[da_sim_results_agg$bf < 1/3 & da_sim_results_agg$bf > 1/6]  <- '< 1/3'
da_sim_results_agg$band[da_sim_results_agg$bf < 1/6 & da_sim_results_agg$bf > 1/10] <- '< 1/6'
da_sim_results_agg$band[da_sim_results_agg$bf < 1/10]                      <- '< 1/10'

# Create factor band
da_sim_results_agg$band <- factor(da_sim_results_agg$band, levels = c('> 10', '> 6', '> 3', '> 1', '< 1', '< 1/3', '< 1/6', '< 1/10'))


# Get back to main DF
da_sim_results$band <- rep(da_sim_results_agg$band, table(da_sim_results$id))


# DF for upper histogram
da_sim_results_agg_supp_H1 <- ddply(subset(da_sim_results_agg, support == 'H1'),
                                    c('n', 'band'),
                                    summarise,
                                    freq = length(bf)/nIter)

# DF for right histogram
da_sim_results_agg_undecided <- subset(da_sim_results_agg, da_sim_results_agg$n == maxN & da_sim_results_agg$bf < crit1 & da_sim_results_agg$bf > crit2)
da_sim_results_agg_undecided$trans_bf <- NA
da_sim_results_agg_undecided$trans_bf[da_sim_results_agg_undecided$bf < 1] <- -1/da_sim_results_agg_undecided$bf[da_sim_results_agg_undecided$bf < 1] + 1
da_sim_results_agg_undecided$trans_bf[da_sim_results_agg_undecided$bf > 1] <- da_sim_results_agg_undecided$bf[da_sim_results_agg_undecided$bf > 1] - 1

# DF for lower histrogram
da_sim_results_agg_supp_H0 <- ddply(subset(da_sim_results_agg, support == 'H0'),
                                    c('n', 'band'),
                                    summarise,
                                    freq = length(bf)/nIter)

# If there are no values for this
if(nrow(da_sim_results_agg_supp_H0) == 0){
  da_sim_results_agg_supp_H0 <- data.frame(n = seq(minN, maxN, batchSize),
                                           band = rep('< 1/10', 5),
                                           freq = rep(0, 5))
}


# Upper Histogram
upper_hist <- ggplot(da_sim_results_agg_supp_H1, aes(x = n, y = freq, fill = band)) + 
  geom_bar(stat = "identity", show.legend = FALSE, alpha = 0.5, width = barWidth)  +
  scale_fill_BF() +
  coord_cartesian(ylim = c(0, bar_yAxis), xlim = c(minN - 0.5, maxN + 0.5), expand = FALSE) +
  labs(y = 'Frequency', x = '') +
  scale_x_continuous(position = 'top') + 
  theme(axis.title.x = element_text(colour = "black", size = 20),
        axis.text.x = element_text(colour = "white"),
        axis.ticks.x = element_line(colour = "white"),
        plot.margin = unit(c(panMar, panMar, panMar, 0), "cm"))

# Create line plot
linePlot <- ggplot(da_sim_results, aes(x = n, y = trans_bf, group = id, colour = band)) + 
  geom_line(alpha = 0.05, show.legend = FALSE) + 
  scale_colour_BF() +
  geom_hline(yintercept = 5) +
  geom_hline(yintercept = -5) +
  scale_y_continuous(breaks = breaksVal,
                     labels = breaksLab) +
  coord_cartesian(xlim = c(minN, maxN), ylim = middle_xlim, expand = FALSE) +
  labs(y = expression(BF[10]), x = NULL) +
  theme(axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        plot.margin = unit(c(panMar, panMar, panMar, 0), "cm"))

# Create right histogram
right_hist <- ggplot(da_sim_results_agg_undecided, aes(x = trans_bf, fill = band)) +
  coord_flip(ylim = c(0, hist_yAxis), xlim = middle_xlim, expand = FALSE) +
  geom_histogram(alpha = 0.5, show.legend = FALSE) +
  scale_fill_BF(drop = FALSE) +
  labs(y = 'Count', x = NULL) +
  theme(axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        plot.margin = unit(c(panMar, panMar, panMar, 0), "cm"))

# Create lower histogram
lower_hist <- ggplot(da_sim_results_agg_supp_H0, aes(x = n, y = freq, fill = band)) + 
  scale_y_reverse() +
  scale_fill_BF(drop = F) +
  geom_bar(stat = "identity", show.legend = FALSE, alpha = 0.5, width = barWidth) + 
  labs(y = 'Frequency', x = 'Sample size') +
  coord_cartesian(ylim = c(bar_yAxis, 0), xlim = c(minN -0.5, maxN + 0.5), expand = FALSE) +
  theme(plot.margin = unit(c(panMar, panMar, panMar, 0), "cm"))


# Combine everything into one plot
## Get Grobs
gplot1 <- ggplotGrob(upper_hist)
gplot2 <- ggplotGrob(linePlot)
gplot3 <- ggplotGrob(right_hist) 
gplot4 <- ggplotGrob(lower_hist)

## Get gtables
gt_gplot1  <- gtable_frame(gplot1,  width = unit(12, "null"))
gt_gplot2  <- gtable_frame(gplot2,  width = unit(12, "null"))
gt_gplot3  <- gtable_frame(gplot3,  width = unit(3, "null"))
gt_gplot4  <- gtable_frame(gplot4,  width = unit(12, "null"))

## Combine components
gt_upper   <- gtable_frame(gtable_cbind(gt_gplot1, gt_gBlank2)) 
gt_middle  <- gtable_frame(gtable_cbind(gt_gplot2, gt_gplot3))
gt_lower   <- gtable_frame(gtable_cbind(gt_gplot4, gt_gBlank2))

## Combine into 1 plot
gtable_combined2 <- gtable_frame(gtable_rbind(gt_upper, gt_middle, gt_lower))

# Input for plot
plot_caption   <- "C"
da_sim_results <- df_H2

##
# Preparation of data
da_sim_results$trans_bf <- NA
da_sim_results$trans_bf[da_sim_results$bf < 1] <- -1/da_sim_results$bf[da_sim_results$bf < 1] + 1
da_sim_results$trans_bf[da_sim_results$bf > 1] <- da_sim_results$bf[da_sim_results$bf > 1] - 1

da_sim_results_agg <- ddply(da_sim_results, c('id'), summarise, n = n[length(n)], bf = bf[length(bf)])
da_sim_results_agg$support <- 'undecided'
da_sim_results_agg$support[da_sim_results_agg$bf > crit1] <- 'H1'
da_sim_results_agg$support[da_sim_results_agg$bf < crit2] <- 'H0'

# Creates band
da_sim_results_agg$band                                           <- '> 10'
da_sim_results_agg$band[da_sim_results_agg$bf < 10 & da_sim_results_agg$bf > 6]     <- '> 6'
da_sim_results_agg$band[da_sim_results_agg$bf < 6 & da_sim_results_agg$bf > 3]      <- '> 3'
da_sim_results_agg$band[da_sim_results_agg$bf < 3 & da_sim_results_agg$bf > 1]      <- '> 1'
da_sim_results_agg$band[da_sim_results_agg$bf < 1 & da_sim_results_agg$bf > 1/3]    <- '< 1'
da_sim_results_agg$band[da_sim_results_agg$bf < 1/3 & da_sim_results_agg$bf > 1/6]  <- '< 1/3'
da_sim_results_agg$band[da_sim_results_agg$bf < 1/6 & da_sim_results_agg$bf > 1/10] <- '< 1/6'
da_sim_results_agg$band[da_sim_results_agg$bf < 1/10]                      <- '< 1/10'

# Create factor band
da_sim_results_agg$band <- factor(da_sim_results_agg$band, levels = c('> 10', '> 6', '> 3', '> 1', '< 1', '< 1/3', '< 1/6', '< 1/10'))


# Get back to main DF
da_sim_results$band <- rep(da_sim_results_agg$band, table(da_sim_results$id))


# DF for upper histogram
da_sim_results_agg_supp_H1 <- ddply(subset(da_sim_results_agg, support == 'H1'),
                                    c('n', 'band'),
                                    summarise,
                                    freq = length(bf)/nIter)

# DF for right histogram
da_sim_results_agg_undecided <- subset(da_sim_results_agg, da_sim_results_agg$n == maxN & da_sim_results_agg$bf < crit1 & da_sim_results_agg$bf > crit2)
da_sim_results_agg_undecided$trans_bf <- NA
da_sim_results_agg_undecided$trans_bf[da_sim_results_agg_undecided$bf < 1] <- -1/da_sim_results_agg_undecided$bf[da_sim_results_agg_undecided$bf < 1] + 1
da_sim_results_agg_undecided$trans_bf[da_sim_results_agg_undecided$bf > 1] <- da_sim_results_agg_undecided$bf[da_sim_results_agg_undecided$bf > 1] - 1

# DF for lower histrogram
da_sim_results_agg_supp_H0 <- ddply(subset(da_sim_results_agg, support == 'H0'),
                                    c('n', 'band'),
                                    summarise,
                                    freq = length(bf)/nIter)

# If there are no values for this
if(nrow(da_sim_results_agg_supp_H0) == 0){
  da_sim_results_agg_supp_H0 <- data.frame(n = seq(minN, maxN, batchSize),
                                           band = rep('< 1/10', 5),
                                           freq = rep(0, 5))
}


# Upper Histogram
upper_hist <- ggplot(da_sim_results_agg_supp_H1, aes(x = n, y = freq, fill = band)) + 
  geom_bar(stat = "identity", show.legend = FALSE, alpha = 0.5, width = barWidth)  +
  scale_fill_BF() +
  coord_cartesian(ylim = c(0, bar_yAxis), xlim = c(minN - 0.5, maxN + 0.5), expand = FALSE) +
  labs(y = 'Frequency', title = '', x = '') +
  scale_x_continuous(position = 'top') + 
  theme(axis.title.x = element_text(colour = "black", size = 20),
        axis.text.x = element_text(colour = "white"),
        axis.ticks.x = element_line(colour = "white"),
        plot.margin = unit(c(panMar, panMar, panMar, 0), "cm"))

# Create line plot
linePlot <- ggplot(da_sim_results, aes(x = n, y = trans_bf, group = id, colour = band)) + 
  geom_line(alpha = 0.05, show.legend = FALSE) + 
  scale_colour_BF() +
  geom_hline(yintercept = 5) +
  geom_hline(yintercept = -5) +
  scale_y_continuous(breaks = breaksVal,
                     labels = breaksLab) +
  coord_cartesian(xlim = c(minN, maxN), ylim = middle_xlim, expand = FALSE) +
  labs(y = expression(BF[10]), x = NULL) +
  theme(axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        plot.margin = unit(c(panMar, panMar, panMar, 0), "cm"))

# Create right histogram
right_hist <- ggplot(da_sim_results_agg_undecided, aes(x = trans_bf, fill = band)) +
  coord_flip(ylim = c(0, hist_yAxis), xlim = middle_xlim, expand = FALSE) +
  geom_histogram(alpha = 0.5, show.legend = FALSE) +
  scale_fill_BF(drop = FALSE) +
  labs(y = 'Count', x = NULL) +
  theme(axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        plot.margin = unit(c(panMar, panMar, panMar, 0), "cm"))

# Create lower histogram
lower_hist <- ggplot(da_sim_results_agg_supp_H0, aes(x = n, y = freq, fill = band)) + 
  scale_y_reverse() +
  scale_fill_BF(drop = F) +
  geom_bar(stat = "identity", show.legend = FALSE, alpha = 0.5, width = barWidth) + 
  labs(y = 'Frequency', x = 'Sample size') +
  coord_cartesian(ylim = c(bar_yAxis, 0), xlim = c(minN -0.5, maxN + 0.5), expand = FALSE) +
  theme(plot.margin = unit(c(panMar, panMar, panMar, 0), "cm"))


# Combine everything into one plot
## Get Grobs
gplot1 <- ggplotGrob(upper_hist)
gplot2 <- ggplotGrob(linePlot)
gplot3 <- ggplotGrob(right_hist) 
gplot4 <- ggplotGrob(lower_hist)

## Get gtables
gt_gplot1  <- gtable_frame(gplot1,  width = unit(12, "null"))
gt_gplot2  <- gtable_frame(gplot2,  width = unit(12, "null"))
gt_gplot3  <- gtable_frame(gplot3,  width = unit(3, "null"))
gt_gplot4  <- gtable_frame(gplot4,  width = unit(12, "null"))


## Combine components
gt_upper   <- gtable_frame(gtable_cbind(gt_gplot1, gt_gBlank2)) 
gt_middle  <- gtable_frame(gtable_cbind(gt_gplot2, gt_gplot3))
gt_lower   <- gtable_frame(gtable_cbind(gt_gplot4, gt_gBlank2))

## Combine into 1 plot
gtable_combined3 <- gtable_frame(gtable_rbind(gt_upper, gt_middle, gt_lower))

# Create legend plot
legendPlot <- ggplot(da_sim_results_agg_undecided, aes(x = trans_bf, fill = band)) +
  geom_histogram(alpha = 0.5) +
  scale_fill_BF(drop = FALSE) +
  theme(plot.margin = unit(c(0, 0, 0, 0), "cm")) +
  guides(fill = guide_legend(title = expression(BF[10])))
legend <- cowplot::get_legend(legendPlot)

# Combine plots with legend
#figure5 <- arrangeGrob(gtable_combined1, gtable_combined2, gtable_combined3, legend, ncol = 2)

figure5 <- plot_grid(gtable_combined1, gtable_combined2, gtable_combined3, legend, ncol = 2, labels = 'AUTO')

# Save as image
save_plot('figures/figure5.png', figure5,
          base_height = 19/cm(1),
          base_width = 19/cm(1),
          base_aspect_ratio = 1)

# /* 
# -----------------------------  4. Plot of boundary effect for exp 2 and 3 ---------------------------
# */
# Load data from Exp 2
exp2_path      <- "data/Exp2"
folder         <- '/memoryTask/'
allFiles       <- list.files(paste0(exp2_path, folder))
allFiles_paths <- paste0(exp2_path, folder, allFiles)
n              <- length(allFiles_paths)

# Loop
for(i in 1:n){
  ##
  # Loading daya
  tempDF <- read.csv(allFiles_paths[i], header = TRUE, na.strings = '')
  
  # Recode key presses
  response      <- rep(NA, nrow(tempDF))
  response[tempDF$key_press == 49] <- 1
  response[tempDF$key_press == 50] <- 2
  response[tempDF$key_press == 51] <- 3
  tempDF$response                  <- response
  
  # Convert RT to numeric  
  tempDF$rt <- suppressWarnings(as.numeric(as.character(tempDF$rt)))
  
  ##
  # Temporal order memory 1
  temporalOrder1 <- subset(tempDF, test_part == 'temporalOrder1')
  
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
  
  # Direction of question
  if(temporalOrder1$questionOrder[1] == 0){
    temporalOrder1$questionType = 'before'
  } else {
    temporalOrder1$questionType = 'after'
  }
  
  ##
  # Temporal order memory 2
  temporalOrder2 <- subset(tempDF, test_part == 'temporalOrder2')
  
  # Calcalate accuracy 
  accuracy <- rep(NA, nrow(temporalOrder2))
  accuracy[temporalOrder2$response == temporalOrder2$corr_resp] <- 1
  accuracy[temporalOrder2$response != temporalOrder2$corr_resp] <- 0
  temporalOrder2$accuracy <- accuracy
  
  # Create variable that desribe whether target, foil1, foil2 was choosen
  choice <- rep('Target', nrow(temporalOrder2))
  choice[temporalOrder2$response == temporalOrder2$foil1Pos] <- 'Foil 1'
  choice[temporalOrder2$response == temporalOrder2$foil2Pos] <- 'Foil 2'
  temporalOrder2$choice <- choice
  
  # Direction of question
  if(temporalOrder2$questionOrder[1] == 0){
    temporalOrder2$questionType = 'after'
  } else {
    temporalOrder2$questionType = 'before'
  }
  
  # Create or bind to data.frame
  if(i == 1){
    df_order_exp2    <- rbind(temporalOrder1, temporalOrder2)
    df_order_exp2$id <- i
  } else {
    temporalOrder1$id <- i
    temporalOrder2$id <- i
    df_order_exp2      <- rbind(df_order_exp2, rbind(temporalOrder1, temporalOrder2))
  }
}

# Convert to id factor
df_order_exp2$id       <- as.factor(df_order_exp2$id)
df_order_exp2$stimulus <- as.character(df_order_exp2$stimulus)

# Get trial number etc. 
exp2_trials     <- ddply(df_order_exp2, c('worker_id','counterbalance_condition', 'questionType', 'context'), summarise, n = length(worker_id))
exp2_trials_agg <- ddply(exp2_trials, c('counterbalance_condition', 'questionType', 'context'), summarise, n = mean(n))

# Aggregate
agg_order_exp2 <- ddply(df_order_exp2, c('worker_id', 
                                         'roomType', 
                                         'context', 
                                         'test_part', 
                                         'questionType', 
                                         'counterbalance_condition'), 
                        summarise, 
                        n = length(accuracy),
                        acc = mean(accuracy), 
                        rt = mean(rt))

# Transform values
agg_order_exp2$trans_acc <- arcsine_transform(agg_order_exp2$acc)

# Subset to first block
agg_order_exp2_sub1 <- subset(agg_order_exp2, test_part  == 'temporalOrder1')
agg_order_exp2_sub1$Boundary <- agg_order_exp2_sub1$context

plt1 <- ggplot(agg_order_exp2_sub1, aes(x = context, y = acc, fill = Boundary)) + 
  geom_line(aes(group = worker_id)) +
  geom_point() +
  geom_boxplot(width = 0.5, alpha = 0.5) + 
  geom_hline(yintercept = 1/3) +
  stat_summary(geom = "point", fun = "mean", col = 'black', size = 3, shape = 24, aes(fill = Boundary), key_glyph = "rect")+
  scale_fill_manual(values = mrc_pal("secondary")(4)[3:4], labels = c('across', 'within')) +
  labs(title = 'Exp 2', y = "3AFC accruacy", x = 'Boundary') +
  theme(legend.justification = c(0, 1), 
        legend.position = c(0, 1),
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 9),
        legend.key.size = unit(0.5,"line"))


### Load data
# Path
exp3_path <- "data/Exp3/batch1/"

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
  ##
  # Loading data
  tempDF <- read.csv(allFiles1_paths[i], header = TRUE, na.strings = '')
  
  # Recode key presses
  response      <- rep(NA, nrow(tempDF))
  response[tempDF$key_press == 49] <- 1
  response[tempDF$key_press == 50] <- 2
  response[tempDF$key_press == 51] <- 3
  tempDF$response                  <- response
  
  # Convert RT to numeric  
  tempDF$rt <- suppressWarnings(as.numeric(as.character(tempDF$rt)))
  
  ##
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
  ##
  # Loading data
  tempDF <- read.csv(allFiles2_paths[i], header = TRUE, na.strings = '')
  
  # Recode key presses
  response      <- rep(NA, nrow(tempDF))
  response[tempDF$key_press == 49] <- 1
  response[tempDF$key_press == 50] <- 2
  response[tempDF$key_press == 51] <- 3
  tempDF$response                  <- response
  
  # Convert RT to numeric  
  tempDF$rt <- suppressWarnings(as.numeric(as.character(tempDF$rt)))
  
  ##
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
    df_order_exp3_h2    <- temporalOrder1
    df_order_exp3_h2$id <- i
  } else {
    temporalOrder1$id <- i
    df_order_exp3_h2    <- rbind(df_order_exp3_h2, temporalOrder1)
  }
}


df_order_exp3         <- rbind(df_order_exp3_h1, df_order_exp3_h2)
df_order_exp3$half    <- factor(df_order_exp3$half, levels = c(0, 1), labels = c('h1', 'h2'))
df_order_exp3$context <- factor(df_order_exp3$context, levels = c('across', 'within'), labels = c('across', 'within'))

# Get trial number etc. 
exp3_trials     <- ddply(df_order_exp3, c('worker_id','counterbalance_condition', 'context'), summarise, n = length(worker_id))
exp3_trials_agg <- ddply(exp3_trials, c('counterbalance_condition', 'context'), summarise, n = mean(n))

# Outlier detection
outlier_data <- ddply(df_order_exp3, c('worker_id'), summarise, accuracy = mean(accuracy), rt = mean(rt))
outlier_data$trans_acc         <- arcsine_transform(outlier_data$accuracy)
outlier_data$trans_acc_outlier <- mad_outlier(outlier_data$trans_acc, 2)
outlier_data$rt_outlier        <- mad_outlier(outlier_data$rt, 3)

# Outlier removal
df_order_exp3 <- df_order_exp3[!(df_order_exp3$worker_id %in% c(15177, outlier_data[outlier_data$trans_acc_outlier == 1, 'worker_id'])), ] 
# 15177 Didn't do whole task

excluded <- round(mean(outlier_data$trans_acc_outlier)*100, 1)

# Final sample size
n <- length(unique(df_order_exp3$worker_id))

## Aggregate data
agg_order_exp3 <- ddply(df_order_exp3, c('worker_id', 'subjCond','context'), summarise, accuracy = mean(accuracy), rt = mean(rt))

# Transform accuracy
agg_order_exp3$trans_acc <- arcsine_transform(agg_order_exp3$accuracy)
agg_order_exp3$Boundary  <- agg_order_exp3$context

# Plot
plt2 <- ggplot(agg_order_exp3, aes(x = context, y = accuracy, fill = Boundary)) + 
  geom_line(aes(group = worker_id)) +
  geom_point() +
  geom_boxplot(width = 0.5, alpha = 0.5) + 
  geom_hline(yintercept = 1/3) +
  stat_summary(geom = "point", fun = "mean", col = 'black', size = 3, shape = 24, aes(fill = Boundary), key_glyph = "rect")+
  scale_fill_manual(values = mrc_pal("secondary")(4)[3:4], labels = c('across', 'within')) +
  labs(title = 'Exp 3', y = "3AFC accruacy", x = 'Boundary') +
  coord_cartesian(ylim = c(0, 1)) +
  theme(legend.position = 'none')


# Plot all
figure6 <- plot_grid(plt1, plt2, ncol = 2, labels = 'AUTO')

save_plot("figures/figure6.png", figure6,
          base_height = 10/cm(1)*1.3,
          base_width = 12.66/cm(1)*1.5,
          base_aspect_ratio = 1)
