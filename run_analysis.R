## Set download URL
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

## Download zip file into working diectory
download.file(fileUrl, "./UCI.zip")

## Unzip data and define the dataDir as the UCI HAR Dataset folder
unzip("UCI.zip")
dataDir <- "./UCI HAR Dataset/"

## Read in the data
x_test <- read.table(paste(dataDir, "test/X_test.txt", sep = ""), header = F)
x_train <- read.table(paste(dataDir, "train/X_train.txt", sep = ""), header = F)
activity_labels <- read.table(paste(dataDir, "activity_labels.txt", sep = ""), header = F, col.names = c("activityID", "activityType"))[,2]
y_test <- read.table(paste(dataDir, "test/y_test.txt", sep = ""), header = F, col.names = "activityType")
y_train <- read.table(paste(dataDir, "train/y_train.txt", sep = ""), header = F, col.names = "activityType")
subject_test <- read.table(paste(dataDir, "test/subject_test.txt", sep = ""), header = F, col.names = "subjectID")
subject_train <- read.table(paste(dataDir, "train/subject_train.txt", sep = ""), header = F, col.names = "subjectID")
features <- read.table(paste(dataDir, "features.txt", sep = ""), header = F, stringsAsFactors = F, col.names = c("featureID","featureName"))

## read features, create new column for revised feature names, clean up feature names
## create a new column in features of the revised, tidy feature names
features$featureNameNew <- features$featureName
features$featureNameNew <- gsub("\\()","",features$featureNameNew)
features$featureNameNew <- gsub("std","StdDev",features$featureNameNew)
features$featureNameNew <- gsub("mean","Mean",features$featureNameNew)
features$featureNameNew <- gsub("^(t)","time",features$featureNameNew)
features$featureNameNew <- gsub("^(f)","freq",features$featureNameNew)
features$featureNameNew <- gsub("([Gg]ravity)","Gravity",features$featureNameNew)
features$featureNameNew <- gsub("([Bb]ody)","Body",features$featureNameNew)
features$featureNameNew <- gsub("[Gg]yro","Gyro",features$featureNameNew)
features$featureNameNew <- gsub("Acc","Accel", features$featureNameNew)

## after cleaning up the feature names, create a vector to identify which columns to keep
columnstokeep <- grep("mean|std", features$featureName)

## create "X" data set
x_data <- rbind(x_train, x_test)

## update column names for the x_data set, but using the new, cleaned up name.
colnames(x_data) <- features$featureNameNew

## removecolumns that dont contain mean or standard deviation measurements 
x_data <- x_data[,columnstokeep]

## asssign the activity name to each of the individual test and train data sets
y_test$activityName = activity_labels[y_test[,1]]
y_train$activityName = activity_labels[y_train[,1]]
## remove unnecessary variables
y_test$activityType = NULL
y_train$activityType = NULL

## create 'y' data set
y_data <- rbind(y_train, y_test)

## create 'subject' data set
subject_data <- rbind(subject_train, subject_test)

## create the tidy data set
all_data_tidy <- cbind(x_data, y_data, subject_data)

## create a data set aggregated to averages for each variable for each activity and each subject.
all_data_tidy_subject_avg <- aggregate(all_data_tidy, by=list(activity = all_data_tidy$activityName, subject = all_data_tidy$subjectID), mean)

## remove a few unneeded columns from the tidy data set
all_data_tidy_subject_avg$activityName = NULL
all_data_tidy_subject_avg$subjectID = NULL

## rename two colums for consistency between both tidy data sets
colnames(all_data_tidy_subject_avg)[1] <- "activityName"
colnames(all_data_tidy_subject_avg)[2] <- "subjectID"

## write the all_data_tidy_subject_avg.txt file to your working directory
write.table(all_data_tidy_subject_avg, "all_data_tidy_subject_avg.txt", sep="\t", row.name = F)
