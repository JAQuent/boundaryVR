library(rjson)

allFiles_paths <- 'U:/Projects/boundaryVR/ignore_boundaryAnalysis/testData/new/jatos_results_20191104204947.txt'
n              <- length(allFiles_paths)



jsonString <- readChar(allFiles_paths, file.info(allFiles_paths)$size)
resultsList <- fromJSON(jsonString)

