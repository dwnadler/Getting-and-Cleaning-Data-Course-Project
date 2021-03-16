# Data downloaded and extracted from 
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

#This script:
#1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive activity names.
# 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# check if data table is needed
if (!require("data.table")) {
  install.packages("data.table")
}

# check if the reshape2 package is installed
if (!require("reshape2")) {
  install.packages("reshape2")
}

require("data.table")
require("reshape2")

# activity labels
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

# data column names
features <- read.table("./UCI HAR Dataset/features.txt")[,2]

# extract the mean and standard deviations.
extract_features <- grepl("mean|std", features)

# process the X_test & y_test data.
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

names(X_test) = features

# extract the mean and standard deviations.
X_test = X_test[,extract_features]

# activity labels
y_test[,2] = activity_labels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

# bind
test_data <- cbind(as.data.table(subject_test), y_test, X_test)

# Load and process X_train & y_train data.
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")

subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

names(X_train) = features

# extract the mean and standard deviations
X_train = X_train[,extract_features]

# activity data
y_train[,2] = activity_labels[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

# bind
train_data <- cbind(as.data.table(subject_train), y_train, X_train)

# Merge test and train 
data = rbind(test_data, train_data)

id_labels   = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)
melt_data      = melt(data, id = id_labels, measure.vars = data_labels)

# apply mean function to dataset using dcast 
tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)

write.table(tidy_data, file = "./tidy_data.txt")