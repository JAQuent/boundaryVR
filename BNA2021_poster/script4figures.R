# Script to create the figures for my BNA 2021 poster
# Version 1.0
# Date:  31/03/2021
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
  annotate('text', x = 1.5, y = arcsine_transform(1/3) - 0.03, label = 'Chance') +
  scale_color_mrc(palette = 'secondary') + 
  scale_fill_mrc(palette = 'secondary') +
  labs(y = 'arcsine(3AFC accuracy)', x = "Boundary", title = 'Temporal Order') + 
  theme(legend.justification = c(1, 0), 
        legend.position = c(1, 0),
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
  stat_summary(geom = "point", fun = "mean", col = 'black', size = 3, shape = 24, fill = 'red')+
  annotate('text', x = 1.5, y = arcsine_transform(0.5) - 0.04, label = 'Chance') +
  labs(y = 'arcsine(2AFC accuracy)', x = "Memory type", title = 'Room type and table')

# Combine 2 1 figure
figure1 <- plot_grid(plt1, plt2)

# save as image
save_plot(paste0(outputFolder, "figure1.png"), figure1,
          base_height = 10/cm(1),
          base_width = 19/cm(1),
          base_aspect_ratio = 1)
