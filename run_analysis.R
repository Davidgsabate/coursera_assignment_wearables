library(dplyr)
library(reshape)

# Download and unzip archive
zipUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipFile <- "UCI HAR Dataset.zip"
download.file(zipUrl, zipFile, mode = "wb")
ruta <- "UCI HAR Dataset"
unzip(zipFile)

# read archives
trainingSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
trainingValues <- read.table("UCI HAR Dataset/train/X_train.txt")
trainingActivity <- read.table("UCI HAR Dataset/train/y_train.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
testValues <- read.table("UCI HAR Dataset/test/X_test.txt")
testActivity <- read.table("UCI HAR Dataset/test/y_test.txt")
features <- read.table("UCI HAR Dataset/features.txt", as.is = TRUE)
activities <- read.table("UCI HAR Dataset/activity_labels.txt")
colnames(activities) <- c("activityId", "activityLabel")

# 1. Merges the training and the test sets to create one data set.

# Join columns
testcolumns <- cbind(testSubjects, testValues, testActivity)
trainingColumns <- cbind(trainingSubjects, trainingValues, trainingActivity)

# Join training and test
finalTable <- rbind(testcolumns, trainingColumns)

# assign column names
colnames(finalTable) <- c("subject", features[, 2], "activity")

# 2. Extract only the measurements on the mean and standard deviation for each measurement
finalTable <- finalTable[, grep("subject|activity|mean|std", colnames(finalTable))]

# 3. Use descriptive activity names to name the activities in the dataset
finalTable$activity <- factor(finalTable$activity, levels = activities[,1], labels = activities[,2])

# 4. Appropriately label the data set with descriptive variable names
finalTableCols <- colnames(finalTable)
finalTableCols <- gsub("[()-]", "", finalTableCols)
finalTableCols <- gsub("^f", "frequencyDomain", finalTableCols)
finalTableCols <- gsub("^t", "timeDomain", finalTableCols)
finalTableCols <- gsub("Acc", "Accelerometer", finalTableCols)
finalTableCols <- gsub("Gyro", "Gyroscope", finalTableCols)
finalTableCols <- gsub("Mag", "Magnitude", finalTableCols)
finalTableCols <- gsub("Freq", "Frequency", finalTableCols)
finalTableCols <- gsub("mean", "Mean", finalTableCols)
finalTableCols <- gsub("std", "StandardDeviation", finalTableCols)
finalTableCols <- gsub("BodyBody", "Body", finalTableCols)

colnames(finalTable) <- finalTableCols

# 5. Create a second, independent tidy set with the average of each variable for each activity and each subject

finalTidy <- melt(finalTable, id = c("subject","activity"))
finalTidy <- cast(finalTidy, subject+activity~variable, mean)
write.table(finalTidy, "output.txt")
