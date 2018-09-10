setwd("C:/Users/user/Desktop/OR/ISLR/Project")

library(data.table)
library(anytime)
library(plyr)
library(dummies)
library(dplyr)
library(glmnet)
library(pROC)
library(rpart)
library(ROSE)
library(DMwR)

#train and test
train = fread("train.csv",header=TRUE)

train$click_time <- as.POSIXct(train$click_time, format = "%Y-%m-%d %H:%M:%S")
df$click_time <- format(strptime(df$click_time,"%Y-%m-%d %H:%M:%S"),'%H')
df$click_time[(df$click_time < 8)]<- 1
df$click_time[(df$click_time > 8)&(df$click_time < 16)]<- 2
df$click_time[(df$click_time > 16)&(df$click_time < 24)]<- 3