# Script to create the figures for my BNA 2021 poster
# Version 1.0
# Date:  01/04/2021
# Author: Joern Alexander Quent
# /* 
# ----------------------------- Libraries ---------------------------
# */
library(ggplot2)
library(cowplot)
library(MRColour)
library(BayesFactor)
library(assortedRFunctions)
library(plyr)
library(reshape2)
library(latex2exp)

######################################################
# Path to parent folder boundaryVR
path2parent <- "C:/Users/aq01/Documents/boundaryVR" # This need to be changed to run this document
######################################################

# Setting WD
setwd(paste0(path2parent, ""))
outputFolder <- "BNA2021_poster/figures/"

# /* 
# ----------------------------- Exp 1 Batch 1: Load data ---------------------------
# */
# Load all data
prefix         <- "/data/Exp1/batch1/memoryTask/"
allFiles       <- list.files(paste0(path2parent, prefix))
allFiles_paths <- paste0(path2parent, prefix, allFiles)
n              <- length(allFiles_paths)

# Prepare data for analysis
for(i in 1:n){
  ############
  # Load data files
  tempDF <- read.csv(allFiles_paths[i], header = TRUE, na.strings = '')
  
  # Recode key presses
  response      <- rep(NA, dim(tempDF)[1])
  response[tempDF$key_press == 49] <- 1
  response[tempDF$key_press == 50] <- 2
  response[tempDF$key_press == 51] <- 3
  tempDF$response <- response
  
  ############
  # Temporal order
  temporalOrder    <- subset(tempDF, test_part == 'temporalOrder')
  temporalOrder$rt <- as.numeric(as.character(temporalOrder$rt))
  
  # Calcalate accuracy
  accuracy <- rep(NA, dim(temporalOrder)[1])
  accuracy[temporalOrder$response == temporalOrder$corr_resp] <- 1
  accuracy[temporalOrder$response != temporalOrder$corr_resp] <- 0
  temporalOrder$accuracy <- accuracy
  
  ############
  # Room type question
  roomType      <- subset(tempDF, test_part == 'roomType')
  roomType$rt   <- as.numeric(as.character(roomType$rt))
  
  # Calculate accuracy
  accuracy <- rep(NA, dim(roomType)[1])
  accuracy[roomType$response == roomType$corr_resp] <- 1
  accuracy[roomType$response != roomType$corr_resp] <- 0
  roomType$accuracy <- accuracy
  
  ############
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
agg_order_b1$Condition[agg_order_b1$context == 'within-open plane'] <- 'O-room'
agg_order_b1$Condition[agg_order_b1$context == 'within-M-shape']    <- 'M-room'

# /* 
# ----------------------------- Exp 1 Batch 1: Plots ---------------------------
# */
plt1 <- ggplot(agg_order_b1, aes(x = boundary, y = trans_acc, group = Condition, colour = Condition)) + 
  geom_boxplot(alpha = 0.5,outlier.shape = NA, key_glyph = "rect") + 
  geom_point(position = position_jitterdodge(jitter.width = 0.2)) + 
  geom_hline(yintercept = arcsine_transform(1/3)) +
  stat_summary(geom = "point", fun = "mean", col = 'black', size = 3, shape = 24, aes(fill = Condition),
               position=position_dodge(width =  0.75),
               key_glyph = "rect") + 
  geom_segment(aes(x = 1.5, xend = 1.5, y= -0.75, yend= arcsine_transform(1/3)),colour = 'black',
               arrow = arrow(length = unit(0.30,"cm"), type = "closed"), show.legend = FALSE) +
  annotate('text', x = 1.5, y = - 0.75 - 0.03, label = 'Chance') +
  scale_color_mrc(palette = 'secondary') + 
  scale_fill_mrc(palette = 'secondary') +
  labs(y = 'arcsine(3AFC accuracy)', x = "Boundary", title = 'Temporal Order') + 
  theme(legend.justification = c(0, 1), 
        legend.position = c(0, 1),
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 9),
        legend.key.size = unit(0.5,"line"))

# Bind room and table together
roomTable_b1 <- data.frame(id = rep(1:n, 2),
                           Type = rep(c('Room', 'Table'), each = n),
                           acc = c(agg_room_b1$acc, agg_table_b1$acc),
                           trans_acc = c(agg_room_b1$trans_acc, agg_table_b1$trans_acc))

plt2 <- ggplot(roomTable_b1, aes(x = Type, y = trans_acc)) + 
  geom_boxplot(alpha = 0.5,outlier.shape = NA) + 
  geom_jitter(width = 0.1, height = 0) +
  geom_hline(yintercept = arcsine_transform(0.5)) +
  stat_summary(geom = "point", fun = "mean", col = 'black', size = 3, shape = 24, fill = 'red') +
  geom_segment(aes(x = 1.5, xend = 1.5, y= -0.2, yend= arcsine_transform(0.5)),colour = 'black',
               arrow = arrow(length = unit(0.30,"cm"), type = "closed"), show.legend = FALSE) +
  annotate('text', x = 1.5, y = - 0.2 - 0.03, label = 'Chance') +
  labs(y = 'arcsine(2AFC accuracy)', x = "Memory type", title = 'Room type and table')

# Combine 2 1 figure
figure1 <- plot_grid(plt1, plt2)

# save as image
save_plot(paste0(outputFolder, "figure1.png"), figure1,
          base_height = 10/cm(1),
          base_width = 19/cm(1),
          base_aspect_ratio = 1)

# /* 
# ----------------------------- Exp 1 Batch 2: Load data ---------------------------
# */
# Load trial information
load(paste0(path2parent, '/experiments/Exp1/batch2/r_supportFiles/trialData_20200522_182214.RData'))
# Note that counterbalancing in that images goes from 1 to 8, while it goes from 0 to 7 in the javascript
# files.

# Order trial information
trials_cond5 <- trials_cond5[order(trials_cond5$objNum),]
trials_cond6 <- trials_cond6[order(trials_cond6$objNum),]
trials_cond7 <- trials_cond7[order(trials_cond7$objNum),]
trials_cond8 <- trials_cond8[order(trials_cond8$objNum),]

# Load all data
prefix         <- "/data/Exp1/batch2/memoryTask/"
allFiles       <- list.files(paste0(path2parent, prefix))
allFiles_paths <- paste0(path2parent, prefix, allFiles)
n              <- length(allFiles_paths)

for(i in 1:n){
  ############
  # Loading data
  tempDF <- read.csv(allFiles_paths[i], header = TRUE, na.strings = '')
  
  # Recode key presses
  response      <- rep(NA, dim(tempDF)[1])
  response[tempDF$key_press == 49] <- 1
  response[tempDF$key_press == 50] <- 2
  response[tempDF$key_press == 51] <- 3
  tempDF$response                  <- response
  
  ############
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
  
  ############
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
  
  ############
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
agg_order_b2$Condition[agg_order_b2$context == 'within-open plane'] <- 'O-room'
agg_order_b2$Condition[agg_order_b2$context == 'within-M-shape']    <- 'M-room'

# /* 
# ----------------------------- Exp 1 Batch 2: Plots ---------------------------
# */
plt1 <- ggplot(agg_order_b2, aes(x = boundary, y = trans_acc, group = Condition, colour = Condition)) + 
  geom_boxplot(alpha = 0.5,outlier.shape = NA, key_glyph = "rect") + 
  geom_point(position = position_jitterdodge(jitter.width = 0.2)) + 
  geom_hline(yintercept = arcsine_transform(1/3)) +
  stat_summary(geom = "point", fun = "mean", col = 'black', size = 3, shape = 24, aes(fill = Condition),
               position=position_dodge(width =  0.75),
               key_glyph = "rect") + 
  geom_segment(aes(x = 1.5, xend = 1.5, y= -0.75, yend= arcsine_transform(1/3)),colour = 'black',
               arrow = arrow(length = unit(0.30,"cm"), type = "closed"), show.legend = FALSE) +
  annotate('text', x = 1.5, y = - 0.75 - 0.03, label = 'Chance') +
  scale_color_mrc(palette = 'secondary') + 
  scale_fill_mrc(palette = 'secondary') +
  labs(y = 'arcsine(3AFC accuracy)', x = "Boundary", title = 'Temporal Order') + 
  theme(legend.justification = c(0, 1), 
        legend.position = c(0, 1),
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 9),
        legend.key.size = unit(0.5,"line"))

# Bind room and table together
roomTable_b2 <- data.frame(id = rep(1:n, 2),
                           Type = rep(c('Room', 'Table'), each = n),
                           acc = c(agg_room_b2$acc, agg_table_b2$acc),
                           trans_acc = c(agg_room_b2$trans_acc, agg_table_b2$trans_acc))

plt2 <- ggplot(roomTable_b2, aes(x = Type, y = trans_acc)) + 
  geom_boxplot(alpha = 0.5,outlier.shape = NA) + 
  geom_jitter(width = 0.1, height = 0) +
  geom_hline(yintercept = arcsine_transform(0.5)) +
  stat_summary(geom = "point", fun = "mean", col = 'black', size = 3, shape = 24, fill = 'red')+
  geom_segment(aes(x = 1.5, xend = 1.5, y= -0.2, yend= arcsine_transform(0.5)),colour = 'black',
               arrow = arrow(length = unit(0.30,"cm"), type = "closed"), show.legend = FALSE) +
  annotate('text', x = 1.5, y = - 0.2 - 0.03, label = 'Chance') +
  labs(y = 'arcsine(2AFC accuracy)', x = "Memory type", title = 'Room type and table')

# Combine 2 1 figure
figure2 <- plot_grid(plt1, plt2)

# save as image
save_plot(paste0(outputFolder, "figure2.png"), figure2,
          base_height = 10/cm(1),
          base_width = 19/cm(1),
          base_aspect_ratio = 1)


# /* 
# ----------------------------- Exp 1 Batch 3: Load data ---------------------------
# */
# Load all data
# Load all data
prefix         <- "/data/Exp1/batch3/memoryTask/"
allFiles       <- list.files(paste0(path2parent, prefix))
allFiles_paths <- paste0(path2parent, prefix, allFiles)
n              <- length(allFiles_paths)

# Load trial information
load(paste0(path2parent, '/experiments/Exp1/batch3/r_supportFiles/trialData_randomFoils.RData'))
# Note that counterbalancing in that images goes from 1 to 8, while it goes from 0 to 7 in the javascript
# files.

# Order trial information
# Due to an error only 78 trials were tested during 
trials_cond5 <- trials_cond5[order(trials_cond5$objNum),][1:78,]
trials_cond6 <- trials_cond6[order(trials_cond6$objNum),][1:78,]
trials_cond7 <- trials_cond7[order(trials_cond7$objNum),][1:78,]
trials_cond8 <- trials_cond8[order(trials_cond8$objNum),][1:78,]

for(i in 1:n){
  ############
  # Loading data
  tempDF <- read.csv(allFiles_paths[i], header = TRUE, na.strings = '')
  
  # Recode key presses
  response      <- rep(NA, dim(tempDF)[1])
  response[tempDF$key_press == 49] <- 1
  response[tempDF$key_press == 50] <- 2
  response[tempDF$key_press == 51] <- 3
  tempDF$response                  <- response
  
  ############
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
  
  ############
  # Room type question
  roomType      <- subset(tempDF, test_part == 'roomType')
  roomType$rt   <- as.numeric(as.character(roomType$rt))
  
  # get trialinfo and add to roomType
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
  
  # Adding table information to temporal order memory
  # Get right information and create temp variable
  tempInfo      <- get(paste0("trials_cond",  temporalOrder$condition[1]))
  tempInfo_full <- get(paste0("trials_cond",  temporalOrder$condition[1], '_full'))
  # Order both data frames by objNum/probe
  tempInfo <- tempInfo[1:78, ] # Because of an error in the code only 78 trials exist per participant
  tempInfo <- tempInfo[order(tempInfo$objNum),]
  temporalOrder <- temporalOrder[order(temporalOrder$probe),]
  
  # Transfering information between dfs
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
  
  ############
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
agg_order_b3$Condition[agg_order_b3$context == 'within-open plane'] <- 'O-room'
agg_order_b3$Condition[agg_order_b3$context == 'within-M-shape']    <- 'M-room'

# /* 
# ----------------------------- Exp 1 Batch 3: Plots ---------------------------
# */
plt1 <- ggplot(agg_order_b3, aes(x = boundary, y = trans_acc, group = Condition, colour = Condition)) + 
  geom_boxplot(alpha = 0.5,outlier.shape = NA, key_glyph = "rect") + 
  geom_point(position = position_jitterdodge(jitter.width = 0.2)) + 
  geom_hline(yintercept = arcsine_transform(1/3)) +
  stat_summary(geom = "point", fun = "mean", col = 'black', size = 3, shape = 24, aes(fill = Condition),
               position=position_dodge(width =  0.75),
               key_glyph = "rect") + 
  geom_segment(aes(x = 1.5, xend = 1.5, y= -0.6, yend= arcsine_transform(1/3)),colour = 'black',
               arrow = arrow(length = unit(0.30,"cm"), type = "closed"), show.legend = FALSE) +
  annotate('text', x = 1.5, y = - 0.6 - 0.03, label = 'Chance') +
  scale_color_mrc(palette = 'secondary') + 
  scale_fill_mrc(palette = 'secondary') +
  labs(y = 'arcsine(3AFC accuracy)', x = "Boundary", title = 'Temporal Order') + 
  theme(legend.justification = c(0, 1), 
        legend.position = c(0, 1),
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 9),
        legend.key.size = unit(0.5,"line"))

plt1

# Bind room and table together
roomTable_b3 <- data.frame(id = rep(1:n, 2),
                           Type = rep(c('Room', 'Table'), each = n),
                           acc = c(agg_room_b3$acc, agg_table_b3$acc),
                           trans_acc = c(agg_room_b3$trans_acc, agg_table_b3$trans_acc))

plt2 <- ggplot(roomTable_b3, aes(x = Type, y = trans_acc)) + 
  geom_boxplot(alpha = 0.5,outlier.shape = NA) + 
  geom_jitter(width = 0.1, height = 0) +
  geom_hline(yintercept = arcsine_transform(0.5)) +
  stat_summary(geom = "point", fun = "mean", col = 'black', size = 3, shape = 24, fill = 'red')+
  geom_segment(aes(x = 1.5, xend = 1.5, y= -0.2, yend= arcsine_transform(0.5)),colour = 'black',
               arrow = arrow(length = unit(0.30,"cm"), type = "closed"), show.legend = FALSE) +
  annotate('text', x = 1.5, y = - 0.2 - 0.03, label = 'Chance') +
  labs(y = 'arcsine(2AFC accuracy)', x = "Memory type", title = 'Room type and table')

# Combine 2 1 figure
figure3 <- plot_grid(plt1, plt2)

# save as image
save_plot(paste0(outputFolder, "figure3.png"), figure3,
          base_height = 10/cm(1),
          base_width = 19/cm(1),
          base_aspect_ratio = 1)

# /* 
# ----------------------------- Exp 2: Load data ---------------------------
# */
# Get file paths
prefix         <- "/data/Exp2/memoryTask/"
allFiles       <- list.files(paste0(path2parent, prefix))
allFiles_paths <- paste0(path2parent, prefix, allFiles)
n              <- length(allFiles_paths)

# Loop
for(i in 1:n){
  ############
  # Loading data
  tempDF <- read.csv(allFiles_paths[i], header = TRUE, na.strings = '')
  
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
  
  ############
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
df_order_exp2$id <- as.factor(df_order_exp2$id)
df_order_exp2$stimulus <- as.character(df_order_exp2$stimulus)

agg_order_exp2 <- ddply(df_order_exp2, c('worker_id', 'roomType', 'context', 'test_part', 'questionType', 'counterbalance_condition'), 
                        summarise, 
                        n = length(accuracy),
                        acc = mean(accuracy), 
                        rt = mean(rt))

# Transform values
agg_order_exp2$trans_acc <- arcsine_transform(agg_order_exp2$acc)

agg_order_exp2_sub1 <- subset(agg_order_exp2, test_part  == 'temporalOrder1')

# /* 
# ----------------------------- Exp 2: Plots ---------------------------
# */
plt1 <- ggplot(agg_order_exp2_sub1, aes(x = context, y = trans_acc)) + 
  geom_line(aes(group = worker_id)) +
  geom_point() +
  geom_boxplot(width = 0.5, alpha = 0.5) + 
  geom_hline(yintercept = arcsine_transform(1/3)) +
  stat_summary(geom = "point", fun = "mean", col = 'black', size = 3, shape = 24, fill = 'red')+
  geom_segment(aes(x = 0.7, xend = 0.7, y= -0.5, yend= arcsine_transform(1/3)),colour = 'black',
               arrow = arrow(length = unit(0.30,"cm"), type = "closed"), show.legend = FALSE) +
  annotate('text', x = 0.7, y = - 0.5 - 0.03, label = 'Chance') +
  labs(title = 'Temporal order', y = "arcsine(3AFC accruacy)", x = 'Boundary')


plt2 <- ggplot(agg_order_exp2_sub1, aes(x = context, y = rt)) + 
  geom_line(aes(group = worker_id)) +
  geom_point() +
  geom_boxplot(width = 0.5, alpha = 0.5) + 
  stat_summary(geom = "point", fun = "mean", col = 'black', size = 3, shape = 24, fill = 'red')+
  labs(title = 'Reaction time', y = "RT in msec", x = 'Boundary')


figure4 <- plot_grid(plt1, plt2)

# save as image
save_plot(paste0(outputFolder, "figure4.png"), figure4,
          base_height = 10/cm(1),
          base_width = 19/cm(1),
          base_aspect_ratio = 1)

# /* 
# ----------------------------- Exp 3: Load data ---------------------------
# */
# Get all files
folder1         <- "/data/Exp3/batch1/memoryTask1/"
folder2         <- "/data/Exp3/batch1/memoryTask2/"
allFiles1       <- list.files(paste0(path2parent, folder1))
allFiles2       <- list.files(paste0(path2parent, folder2))
allFiles1_paths <- paste0(path2parent, folder1, allFiles1)
allFiles2_paths <- paste0(path2parent, folder2, allFiles2)
n1              <- length(allFiles1_paths)
n2              <- length(allFiles2_paths)

# Half 1 
for(i in 1:n1){
  ############
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

df_order_exp3$context <- factor(df_order_exp3$context, levels = c('across', 'within'), labels = c('across', 'within'))

# Outlier detection
outlier_data <- ddply(df_order_exp3, c('worker_id'), summarise, accuracy = mean(accuracy), rt = mean(rt))
outlier_data$trans_acc         <- arcsine_transform(outlier_data$accuracy)
outlier_data$trans_acc_outlier <- mad_outlier(outlier_data$trans_acc, 2)
outlier_data$rt_outlier        <- mad_outlier(outlier_data$rt, 3)

# Outlier removal
df_order_exp3 <- df_order_exp3[!(df_order_exp3$worker_id %in% c(15177, outlier_data[outlier_data$trans_acc_outlier == 1, 'worker_id'])), ] 
# 15177 Didn't do whole task

excluded <- round(mean(outlier_data$trans_acc_outlier)*100, 1)

# /* 
# ----------------------------- Exp 3: Plots ---------------------------
# */

agg1 <- ddply(df_order_exp3, c('worker_id', 'subjCond', 'half','context'), summarise, accuracy = mean(accuracy), rt = mean(rt))
agg2 <- ddply(df_order_exp3, c('worker_id', 'subjCond','context'), summarise, accuracy = mean(accuracy), rt = mean(rt))

agg2$trans_acc <- arcsine_transform(agg2$accuracy)
agg1$trans_acc <- arcsine_transform(agg1$accuracy)


plt1 <- ggplot(agg2, aes(x = context, y = trans_acc)) + 
  geom_line(aes(group = worker_id)) +
  geom_point() +
  geom_boxplot(width = 0.5, alpha = 0.5) + 
  geom_hline(yintercept = arcsine_transform(1/3)) +
  stat_summary(geom = "point", fun = "mean", col = 'black', size = 3, shape = 24, fill = 'red')+
  geom_segment(aes(x = 0.7, xend = 0.7, y= -0.5, yend= arcsine_transform(1/3)),colour = 'black',
               arrow = arrow(length = unit(0.30,"cm"), type = "closed"), show.legend = FALSE) +
  annotate('text', x = 0.7, y = - 0.5 - 0.03, label = 'Chance') +
  labs(title = 'Temporal order', y = "arcsine(3AFC accruacy)", x = 'Boundary')


plt2 <- ggplot(agg2, aes(x = context, y = rt)) + 
  geom_line(aes(group = worker_id)) +
  geom_point() +
  geom_boxplot(width = 0.5, alpha = 0.5) + 
  stat_summary(geom = "point", fun = "mean", col = 'black', size = 3, shape = 24, fill = 'red')+
  labs(title = 'Reaction time', y = "RT in msec", x = 'Boundary')


figure5 <- plot_grid(plt1, plt2)

# save as image
save_plot(paste0(outputFolder, "figure5.png"), figure5,
          base_height = 10/cm(1),
          base_width = 19/cm(1),
          base_aspect_ratio = 1)