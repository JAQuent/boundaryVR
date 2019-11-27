library(rjson)


# Question and answer string
q_id <- c('video_viewing', 
          'q_answering', 
          'breaks', 
          'room_feeling1', 
          'room_feeling2', 
          'room_feeling3', 
          'object_recognition',
          'exp_problems',
          'navigation',
          'object_time',
          'memory1',
          'memory2', 
          'instructions')

questions <- c('Did you do anything else while watching the video?',
               'Did you do your best to answer the questions correctly?',
               'Did you take breaks during the experiment?',
               'Did rooms with a partition feel like they were a single room (similar to the room without a partition) or did they feel like two separate rooms? (Please elaborate below.)',
               'Did you feel it was harder/easier to remember the order of objects in the rooms without a partition relative to those with a partition?',
               'When crossing from one part of the room to the next in a partitioned room, did that feel like you were moving to a new room (a bit like walking through a door)?',
               'Did you recognise all objects in the video and in the memory task? (If you can, please try describe the/those object(s) briefly.)',
               'Did you experience any problems viewing the videos? Or problems in the experiment in general? (If yes, please elaborate.)',
               'Did the navigation feel too fast?',
               'Did you think the time the objects were visible was long enough?',
               'Did you anticipate there would be a memory test on the objects? If so, did you anticipate you would be asked about the order of the objects?',
               'Did you use any strategy to remember the objects and their order? (If yes, please elaborate.)',
               'Now, you\'ve completed the task. Can we somehow improve our instructions? (If yes, please elaborate.)')

answerQuestionID <- c(1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5 ,5, 5, 6, 6, 6, 7, 7, 7,
                      8, 8, 9, 9, 10, 11, 11, 11, 12, 12, 13, 13)

answerValue <- c('other_things',
                 'unattentive',
                 'attentive',
                 'did_best',
                 'random',
                 'partly_random',
                 'yes',
                 'short_breaks',
                 'no',
                 'yes',
                 'cannot_say',
                 'no',
                 'easierWithout',
                 'noDiff',
                 'easierWith',
                 'yes',
                 'cannot_say',
                 'no',
                 'all',
                 'nearlyAll',
                 'manyNot',
                 'yes',
                 'no',
                 'yes',
                 'no',
                 'expOrder',
                 'expTest',
                 'expNone',
                 'yes',
                 'no',
                 'yes',
                 'no')

answerString <- c('Yes, at times I was busy with other things and missed parts of the video.',
                  'I didn\'t do anything else, but did not always watch attentively.',
                  'No, I watched all the whole video attentively.',
                  'Yes, I tried my best to answer everything correctly.',
                  'I answered randomly for the most part.',
                  'At least some of the time I answered randomly.',
                  'Yes, I took breaks.',
                  'I took some, but they were short (up to 1 minute).',
                  'No, I completed the experiment in one go.',
                  'Yes, I both type of rooms felt like one.',
                  'I can\'t say.',
                  'No, the room with walls in the middle felt like two separate rooms.',
                  'It was easier without partition.',
                  'There was no diferrence.',
                  'It was easier with partition.',
                  'Yes, did feel like this.',
                  'I can\'t say.',
                  'No, I didn\'t feel like this.',
                  'I recognised all.',
                  'I recognised nearly all.',
                  'I  didn\'t recognise many objects.',
                  'Yes.',
                  'No.',
                  'Yes.',
                  'No.',
                  'I anticipated I would be tested on order.',
                  'I anticipated there would be a test, but not which questions would be asked.',
                  'I didn’t anticipate memory would be tested.',
                  'Yes.',
                  'No.',
                  'Yes.',
                  'No.')


# Load data

allFiles_paths <- 'U:/Projects/boundaryVR/ignore_boundaryAnalysis/batch2/debrief/jatos_results_20191121155808.txt'
n              <- length(allFiles_paths)



jsonString <- readChar(allFiles_paths, file.info(allFiles_paths)$size)
resultsList <- fromJSON(jsonString)
