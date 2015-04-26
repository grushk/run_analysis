# Required Libraries
library(dplyr)
library(qdap)
library(reshape2)

# Read in the data from the .txt files
test.data<- read.table("./test/X_test.txt")
train.data<- read.table("./train/X_train.txt")
test.activities <- read.table("./test/y_test.txt")
train.activities <- read.table("./train/y_train.txt")
test.subjects<-read.table("./test/subject_test.txt")
train.subjects<-read.table("./train/subject_train.txt")
activities<-read.table("activity_labels.txt")
features<-read.table("features.txt")

# Combine the two data sets
combined.data<-rbind(test.data,train.data)
combined.activities<-rbind(test.activities,train.activities)
combined.subjects<-rbind(test.subjects,train.subjects)

#Extract mean and std columns from combined.data
names(combined.data)<-features[,2]
names(combined.data) <- make.names(names=names(combined.data), unique=TRUE, allow_ = TRUE)
combined.data<-combined.data[,grepl("mean\\(\\)|std\\(\\)", features[,2])]

# Clean up column names to remove extra periods created when making column names unique
names(combined.data) <- gsub("..","",names(combined.data),fixed=TRUE)

# Rename combined.activites to be descriptive
combined.activities<-apply(combined.activities,2,lookup,activities)
combined.activities<-data.frame(combined.activities)

# Rename columns and bind data into one table
names(combined.activities)<-"Activity"
names(combined.subjects)<-"Subject"
combined.data<-cbind(combined.activities,combined.subjects,combined.data)

# Reshape data to summarize means by Subject, Activity, and variable
new.data<-melt(combined.data,id=c("Subject","Activity"),measure.vars=names(select(combined.data,-Activity,-Subject)))
new.data<-ddply(new.data,.(Subject,Activity,variable),summarize,mean=mean(value))

# Write the data set into a text file and store it in the local directory
write.table(new.data,file="./run_analysis.txt",row.names=FALSE,col.names=TRUE,quote=FALSE)