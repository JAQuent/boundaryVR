library(rjson)

allFiles_paths <- 'U:/Projects/boundaryVR/ignore_boundaryAnalysis/data/mainVideo/jatos_results_20191104222504.txt'
n              <- length(allFiles_paths)



jsonString <- readChar(allFiles_paths, file.info(allFiles_paths)$size)
resultsList <- fromJSON(jsonString)

plot(resultsList$timeStamps, resultsList$whichKey)
