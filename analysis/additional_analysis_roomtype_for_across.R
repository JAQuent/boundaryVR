# Room 1 = O-room
# Room 2 = M-room


# Split by whether the cue object was in M or O-room

# Libraries
library(plyr)
library(ggplot2)
library(cowplot)
library(gridExtra)
library(grid)
library(knitr)
library(assortedRFunctions)
library(kableExtra)
library(MRColour)
library(reshape2)
library(latex2exp)
library(BayesFactor)
theme_set(theme_grey()) 


# /* 
# ----------------------------- Load data ---------------------------
# */
# Load all data
prefix         <- "~/boundaryVR/data/Exp1/batch1/memoryTask/"
allFiles       <- list.files(paste(prefix, sep = ''))
allFiles_paths <- paste(prefix, allFiles, sep = '')
n              <- length(allFiles_paths)

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
  
  # Calculate accuracy
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



df_order_b1_roomInfo           <- df_order_b1
df_order_b1_roomInfo$roomType  <- df_room_b1$corr_resp
df_order_b1_roomInfo$roomType  <- ifelse(df_order_b1_roomInfo$roomType == 1, 'O-room', 'M-Room')
agg_order_b1_roomInfo          <- ddply(df_order_b1_roomInfo, c('id', 'context', 'roomType'), summarise, acc = mean(accuracy), rt = mean(rt))
agg_order_b1_roomInfo$boundary <- ifelse(agg_order_b1_roomInfo$context == 'across', 'across', 'within')
agg_order_b1_roomInfo$Condition <- 'across'
agg_order_b1_roomInfo$Condition[agg_order_b1_roomInfo$context == 'within-open plane'] <- 'O-room'
agg_order_b1_roomInfo$Condition[agg_order_b1_roomInfo$context == 'within-M-shape']    <- 'M-room'

# /* 
# ----------------------------- Plot ---------------------------
# */

plt1 <- ggplot(agg_order_b1_roomInfo, aes(x = boundary, y = acc, fill = interaction(boundary,roomType))) + 
  geom_boxplot(alpha = 0.5,outlier.shape = NA, key_glyph = "rect") + 
  geom_point(position = position_jitterdodge(jitter.width = 0.2)) + 
  geom_hline(yintercept = 1/3) +
  stat_summary(geom = "point", fun = "mean", col = 'black', size = 3, shape = 24, aes(fill = interaction(boundary,roomType)),
               position=position_dodge(width =  0.75),
               key_glyph = "rect") + 
  geom_segment(aes(x = 1.5, xend = 1.5, y= 0.1, yend= 1/3),colour = 'black',
               arrow = arrow(length = unit(0.30,"cm"), type = "closed"), show.legend = FALSE) +
  annotate('text', x = 1.5, y = 0.1 - 0.03, label = 'Chance') +
  scale_color_mrc(palette = 'secondary') + 
  scale_fill_mrc(palette = 'secondary') +
  labs(y = '3AFC accuracy', x = "Boundary", title = 'Temporal Order (Exp 1a)') + 
  theme(legend.justification = c(0, 1), 
        legend.position = c(0, 1),
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 9),
        legend.key.size = unit(0.5,"line")) +
  coord_cartesian(ylim = c(0, 1))



# /* 
# ----------------------------- Load data Exp1b ---------------------------
# */
# Load trial information
load("~/boundaryVR/experiments/Exp1/batch2/r_supportFiles/trialData_20200522_182214.RData")
# Note that counterbalancing in that images goes from 1 to 8, while it goes from 0 to 7 in the javascript
# files.

# Order trial information
trials_cond5 <- trials_cond5[order(trials_cond5$objNum),]
trials_cond6 <- trials_cond6[order(trials_cond6$objNum),]
trials_cond7 <- trials_cond7[order(trials_cond7$objNum),]
trials_cond8 <- trials_cond8[order(trials_cond8$objNum),]

# Load all data
prefix         <- '~/boundaryVR/data/Exp1/batch2/memoryTask/'
allFiles       <- list.files(paste(prefix, sep = ''))
allFiles_paths <- paste(prefix, allFiles, sep = '')
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


df_order_b2_roomInfo <- df_order_b2
df_order_b2_roomInfo <- df_order_b2_roomInfo[order(df_order_b2_roomInfo$id,df_order_b2_roomInfo$trial_index),]
df_room_b2           <- df_room_b2[order(df_room_b2$id, df_room_b2$trial_index),]

df_order_b2_roomInfo$roomType  <- df_room_b2$corr_resp
df_order_b2_roomInfo$roomType  <- ifelse(df_order_b2_roomInfo$roomType == 1, 'O-room', 'M-Room')
agg_order_b2_roomInfo          <- ddply(df_order_b2_roomInfo, c('id', 'context', 'roomType'), summarise, acc = mean(accuracy), rt = mean(rt))
agg_order_b2_roomInfo$boundary <- ifelse(agg_order_b2_roomInfo$context == 'across', 'across', 'within')
agg_order_b2_roomInfo$Condition <- 'across'
agg_order_b2_roomInfo$Condition[agg_order_b2_roomInfo$context == 'within-open plane'] <- 'O-room'
agg_order_b2_roomInfo$Condition[agg_order_b2_roomInfo$context == 'within-M-shape']    <- 'M-room'

# /* 
# ----------------------------- Plot Exp1b ---------------------------
# */
plt2 <- ggplot(agg_order_b2_roomInfo, aes(x = boundary, y = acc, fill = interaction(boundary,roomType))) + 
  geom_boxplot(alpha = 0.5,outlier.shape = NA, key_glyph = "rect") + 
  geom_point(position = position_jitterdodge(jitter.width = 0.2)) + 
  geom_hline(yintercept = 1/3) +
  stat_summary(geom = "point", fun = "mean", col = 'black', size = 3, shape = 24, aes(fill = interaction(boundary,roomType)),
               position=position_dodge(width =  0.75),
               key_glyph = "rect") + 
  geom_segment(aes(x = 1.5, xend = 1.5, y= 0.1, yend= 1/3),colour = 'black',
               arrow = arrow(length = unit(0.30,"cm"), type = "closed"), show.legend = FALSE) +
  annotate('text', x = 1.5, y = 0.1 - 0.03, label = 'Chance') +
  scale_color_mrc(palette = 'secondary') + 
  scale_fill_mrc(palette = 'secondary') +
  labs(y = '3AFC accuracy', x = "Boundary", title = 'Temporal Order (Exp 1b)') + 
  theme(legend.justification = c(0, 1), 
        legend.position = c(0, 1),
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 9),
        legend.key.size = unit(0.5,"line")) +
  coord_cartesian(ylim = c(0, 1))


# /* 
# ----------------------------- Plot Exp1c ---------------------------
# */

# Load all data
prefix         <- '~/boundaryVR/data/Exp1/batch3/memoryTask/'
allFiles       <- list.files(paste(prefix, sep = ''))
allFiles_paths <- paste(prefix, allFiles, sep = '')
n              <- length(allFiles_paths)

# Load trial information
load("~/boundaryVR/experiments/Exp1/batch3/r_supportFiles/trialData_randomFoils.RData")
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
  
  ############
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
plt3 <- ggplot(agg_order_b3_roomInfo, aes(x = boundary, y = acc, fill = interaction(boundary,roomType))) + 
  geom_boxplot(alpha = 0.5,outlier.shape = NA, key_glyph = "rect") + 
  geom_point(position = position_jitterdodge(jitter.width = 0.2)) + 
  geom_hline(yintercept = 1/3) +
  stat_summary(geom = "point", fun = "mean", col = 'black', size = 3, shape = 24, aes(fill = interaction(boundary,roomType)),
               position=position_dodge(width =  0.75),
               key_glyph = "rect") + 
  geom_segment(aes(x = 1.5, xend = 1.5, y= 0.1, yend= 1/3),colour = 'black',
               arrow = arrow(length = unit(0.30,"cm"), type = "closed"), show.legend = FALSE) +
  annotate('text', x = 1.5, y = 0.1 - 0.03, label = 'Chance') +
  scale_color_mrc(palette = 'secondary') + 
  scale_fill_mrc(palette = 'secondary') +
  labs(y = '3AFC accuracy', x = "Boundary", title = 'Temporal Order (Exp 1c)') + 
  theme(legend.justification = c(0, 1), 
        legend.position = c(0, 1),
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 9),
        legend.key.size = unit(0.5,"line"))+
  coord_cartesian(ylim = c(0, 1))


# /* 
# ----------------------------- Plot all ---------------------------
# */
all_plots <- plot_grid(plt1, plt2, plt3, ncol = 3)

save_plot("spliiting_across_trials.png", all_plots,
          base_height = 10/cm(1)*1.5,
          base_width = 19/cm(1)*1.5,
          base_aspect_ratio = 1)