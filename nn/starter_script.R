###
### Read the data in:
###

train = read.csv("train.csv", header = TRUE)
test  = read.csv("test.csv",  header = TRUE)

###
### Quickly look at some summaries
###

dim(train)
dim(test)

###
### Just change the response to log:
###

train$SalePrice = log(train$SalePrice)

###
### We don't need train Id:
###

train$Id = NULL

###
### Get rid of test Id but save it for later:
###

test_Id = test$Id
test$Id = NULL

###
### Take a quick look:
###

summary(train)
summary(test)

###
### Remove some variables that have too many missing values:
###

train$PoolQC = NULL
test$PoolQC  = NULL

train$Fence  = NULL
test$Fence   = NULL

train$Alley  = NULL
test$Alley   = NULL

train$MiscFeature = NULL
test$MiscFeature  = NULL

###
### This is a function to pick a value at random from 
###  a vector of categorical values:
###

pick_at_random = function(x)
{
  possible_levels = levels(x)
  index           = sample(1:length(possible_levels), size = 1)
  return(possible_levels[index])
}

###
### Fill in the missing values for both train and test.
###
### This is crude but gets us going.
###

for (i in 1:ncol(train))
{
  tmp_var = train[,i]
  if ( class(tmp_var) == "factor" )  {
    tmp_var[is.na(tmp_var)] = pick_at_random(tmp_var)
  } else {
    tmp_var[is.na(tmp_var)] = median(tmp_var, na.rm = T)
  }
  train[,i] = tmp_var
}

###
### Do the same for the test data:
###

for (i in 1:ncol(test))
{
  tmp_var = test[,i]
  if ( class(tmp_var) == "factor" )  {
    tmp_var[is.na(tmp_var)] = pick_at_random(tmp_var)
  } else {
    tmp_var[is.na(tmp_var)] = median(tmp_var, na.rm = T)
  }
  test[,i] = tmp_var
}

###
### First model:
###

base_model = lm(SalePrice ~ ., data = train)

y_hat = predict(base_model, test)

summary(y_hat)

###
### Some coefficients are not estimated.
###

###
### Make sure you exponentiate the predictions:
###

SalePrice = exp(y_hat)
my_submission = data.frame(Id = test_Id, 	SalePrice = SalePrice)

###
### Save to local drive for submission:
###

write.csv(my_submission, "my_first_submission.csv", row.names = F)

###
### You will get 0.13904
###




