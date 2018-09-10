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
df = fread("train_sample.csv",header=TRUE)
train = fread("train.csv",header=TRUE)
test = fread("test.csv",header=TRUE)
View(test)
test
#divide into timezones
df$click_time <- as.POSIXct(df$click_time, format = "%Y-%m-%d %H:%M:%S")
df$click_time <- format(strptime(df$click_time,"%Y-%m-%d %H:%M:%S"),'%H')
df$click_time[(df$click_time < 8)]<- 1
df$click_time[(df$click_time > 8)&(df$click_time < 16)]<- 2
df$click_time[(df$click_time > 16)&(df$click_time < 24)]<- 3


###
#Check the freqencies of categories and then comment it
###

# df1.a <- as.data.frame(table(df$app))
# df1.a <- df1.a[order(-df1.a$Freq),]
# df1.a$freq_pct = (df1.a$Freq) / (sum(df1.a$Freq))
# df1.a$app_new <- ifelse(df1.a$freq_pct > 0.05, df1.a$Var1, 234566)
# df$app<- as.character(df$app)
# df$app[(df$app != "3")& (df$app != "12") & (df$app != "2") & (df$app != "9") & (df$app != "15") & (df$app != "18") &(df$app != "14")]<-"234566"
# df$app<- as.factor(df$app)
# 
# #
# df1.d <- as.data.frame(table(df$device))
# df1.d <- df1.d[order(-df1.d$Freq),]
# df1.d$freq_pct = df1.d$Freq / sum(df1.d$Freq)
# df1.d$device_new <- ifelse(df1.d$freq_pct > 0.005, df1.d$Var1, 234567)
# df$device<- as.character(df$device)
# df$device[(df$device != "1") & (df$device != "2") & (df$device != "0")]<-"234567"
# df$device<- as.factor(df$device)
# #
# #
# df1.o <- as.data.frame(table(df$os))
# df1.o <- df1.o[order(-df1.o$Freq),]
# df1.o$freq_pct = df1.o$Freq / sum(df1.o$Freq)
# df1.o$os_new <- ifelse(df1.o$freq_pct > 0.05, df1x.o$Var1, 234568)
# df$os<- as.character(df$os)
# # #For further improvement, you can include more levels for device
# df$os[(df$os != "19") & (df$os != "13") & (df$os != "17")]<-"234568"
# df$os<- as.factor(df$os)
# #
# 
# df1.c <- as.data.frame(table(df$channel))
# df1.c <- df1.c[order(-df1.c$Freq),]
# df1.c$freq_pct = df1.c$Freq / sum(df1.c$Freq)
# df1.c$c_new <- ifelse(df1.c$freq_pct > 0.03, df1.c$Var1, 234569)
# df$channel<- as.character(df$channel)
# # #For further improvement, you can include more levels for channel
# df$channel[(df$channel != "280") & (df$channel != "245") & (df$channel != "107")&(df$channel != "477") & (df$channel != "134") & (df$channel != "259")& (df$channel != "265")]<-"234569"
# df$channel<- as.factor(df$channel)


###
#Decrease Categorical Levels
###
df$app<- as.character(df$app)
df$app[(df$app != "3")& (df$app != "12") & (df$app != "2") & (df$app != "9") & (df$app != "15") & (df$app != "18") &(df$app != "14")]<-"234566"
df$app<- as.factor(df$app)

df$device<- as.character(df$device)
df$device[(df$device != "1") & (df$device != "2") & (df$device != "0")]<-"234567"
df$device<- as.factor(df$device)

df$os<- as.character(df$os)
#For further improvement, you can include more levels for device
df$os[(df$os != "19") & (df$os != "13") & (df$os != "17")]<-"234568"
df$os<- as.factor(df$os)

df$channel<- as.character(df$channel)
df$channel[(df$channel != "280") & (df$channel != "245") & (df$channel != "107")&(df$channel != "477") & (df$channel != "134") & (df$channel != "259")& (df$channel != "265")]<-"234569"
df$channel<- as.factor(df$channel)

###
#Use Dummies
###
df <- cbind(df, dummy(df$app, sep = "_"))
df <- cbind(df, dummy(df$device, sep = "-"))
df <- cbind(df, dummy(df$os, sep = ":"))
df <- cbind(df, dummy(df$channel, sep = "|"))
df <- cbind(df, dummy(df$click_time, sep = "."))

df1 = select(df, -1:-7)
View(df1)

###
#Test
###
test$click_time <- as.POSIXct(test$click_time, format = "%Y-%m-%d %H:%M:%S")
test$click_time <- format(strptime(test$click_time,"%Y-%m-%d %H:%M:%S"),'%H')
test$click_time[(test$click_time < 8)]<- 1
test$click_time[(test$click_time > 8)&(test$click_time < 16)]<- 2
test$click_time[(test$click_time > 16)&(test$click_time < 24)]<- 3

###
#Check the freqencies of categories and then comment it
###
# test.a <- table(test$app)
# View(test.a)
# test.a = as.numeric(test.a)
# 
# test.a <- test.a[order(-test.a$freq),] 
# test.a$freq_pct = test.a$freq / sum(test.a$freq)
# test.a$app_new <- ifelse(test.a$freq_pct > 0.05, test.a$app, 234566)
# View(df1.a)
# df$app<- as.character(df$app)
# df[(df$app != "3")& (df$app != "12") & (df$app != "2") & (df$app != "9") & (df$app != "15") & (df$app != "18") &(df$app != "14")]<-"234566"
# df$app<- as.factor(df$app)
# 
# 
# df = fread("train_sample.csv",header=TRUE)
# df1.d <- count(df,"device")
# df1.d <- df1.d[order(-df1.d$freq),]
# df1.d$freq_pct = df1.d$freq / sum(df1.d$freq)
# df1.d$device_new <- ifelse(df1.d$freq_pct > 0.005, df1.d$device, 234567)
# View(df1.d)
# df$device<- as.character(df$device)
# df[(df$device != "1") & (df$device != "2") & (df$device != "0")]<-"234567"
# df$device<- as.factor(df$device)
# 
# 
# df = fread("train_sample.csv",header=TRUE)
# df1.o <- count(df,"os")
# df1.o <- df1.o[order(-df1.o$freq),]
# df1.o$freq_pct = df1.o$freq / sum(df1.o$freq)
# df1.o$os_new <- ifelse(df1.o$freq_pct > 0.05, df1.o$os, 234568)
# View(df1.o)
# df$os<- as.character(df$os)
# #For further improvement, you can include more levels for device
# df[(df$os != "19") & (df$os != "13") & (df$os != "17")]<-"234568"
# df$os<- as.factor(df$os)
# 
# df = fread("train_sample.csv",header=TRUE)
# df1.c <- count(df,"channel")
# df1.c <- df1.c[order(-df1.c$freq),]
# df1.c$freq_pct = df1.c$freq / sum(df1.c$freq)
# df1.c$c_new <- ifelse(df1.c$freq_pct > 0.03, df1.c$channel, 234569)
# View(df1.c)
# df$channel<- as.character(df$channel)
# #For further improvement, you can include more levels for channel
# df[(df$channel != "280") & (df$channel != "245") & (df$channel != "107")&(df$channel != "477") & (df$channel != "134") & (df$channel != "259")& (df$channel != "265")]<-"234569"
# df$channel<- as.factor(df$channel)






###
# sample submission
###

logistic_model  = glm(is_attributed ~ . ,  data = train.df1, family = binomial)
predictions = predict(logistic_model, newdata = test.df1, type = "response" )
predictions <- ifelse(predictions > 0.5,1,0)
View(predictions)




###
#over_sampling
###
table(df1$is_attributed)
df1 <- sapply( df1, as.numeric )
df1 <- data.frame(df1)

df1_balanced_over <- ovun.sample(is_attributed ~ ., data = df1, method = "over",N = 199546)$data

df1_balanced_both <- ovun.sample(is_attributed ~ ., data = df1, method = "both", p=0.5,N=100000, seed = 1)$data

#tree.over <- rpart(cls ~ ., data = data_balanced_over)
#pred.tree.over <- predict(tree.over, newdata = hacide.test)




###
#USE SMOTE
###

df1$is_attributed <- as.factor(df1$is_attributed)
df1.smote <- SMOTE(is_attributed ~ ., df1, perc.over = 5000, perc.under=100)
df1$is_attributed <- as.numeric(df1$is_attributed)

#tbmodel <- train(target ~ ., data = trainSplit, method = "treebag",trControl = ctrl)



