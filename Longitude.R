#+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=+
#### TRAINING MODEL - LONGITUDE ####
#+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=+

#### inTrain for longitude ####
inTrain_longitude <- createDataPartition(
  y = training_sampled$LONGITUDE,
  p = 0.75,
  list = FALSE
)

longitude_index <- grep("LONGITUDE", colnames(training_sampled))

#### Training and Testing partition for longitude ####
training_part_longitude <- training_sampled[ inTrain_longitude, ][ ,c(1:(ncol(training_sampled) - 10), longitude_index)]
testing_part_longitude <- training_sampled[-inTrain_longitude, ][ ,c(1:(ncol(training_sampled) - 10), longitude_index)]

nrow(training_part_longitude)
ncol(training_part_longitude)





#+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=+
#### TRAIN/TEST MODELS ####
#+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=+

set.seed(123)

#system.time() to check how long it takes to run 

##### Set the k-fold cross validation ####
ctrl <- trainControl(method = "repeatedcv",
                     number = 10,
                     repeats = 3
)



#### MODELS FOR BUILDING ####


#### KNN ####
training_knn_longitude <- train(LONGITUDE ~ . ,
                                data = training_part_longitude,         # train data partition
                                method = "knn",                         # type of model
                                preProc = c("center", "scale"),         # normalization
                                tuneLength = 10,                        # how many Ks
                                trControl = ctrl,
                                metric = "RMSE"
)

training_knn_longitude
# k   RMSE       Rsquared   MAE     
# 5   9.125054  0.9945562  5.299332


# Test dataset
knn_pred_longitude <- predict(training_knn_longitude, testing_part_longitude)

#Results testset
postResample(knn_pred_longitude, testing_part_longitude$LONGITUDE)
# RMSE       Rsquared       MAE 
# 6.6461701  0.9972735      4.4697036 







# TESTING MODEL m5
# #### M5 ####
# system.time(training_M5_longitude <- train(LONGITUDE ~ . ,
#                                             data = training_part_longitude,         # train data partition
#                                             method = "M5",                          # type of model
#                                             preProc = c("center", "scale"),         # normalization
#                                             tuneLength = 10,                        # how many Ks
#                                             trControl = ctrl,
#                                             metric = "RMSE"
#                                             
# ))
# 
# # pruned  smoothed  rules  RMSE       Rsquared   MAE     
# # Yes     Yes       Yes     78.96528  0.6239508  66.48853
# 
# # Alternative way of training
# # training_M5_long <- M5P(LONGITUDE ~ . , data = training_part_longitude)
# summary(training_M5_longitude)
# 
# # Test dataset 
# M5_pred_longitude <- predict(training_M5_long, testing_part_longitude)
# 
# #Results testset 
# postResample(M5_pred_longitude, testing_part_longitude$LONGITUDE)
# # RMSE         Rsquared        MAE 
# # 74.1750486   0.6441996       62.2500612









#### SVM ####
system.time(training_svm_longitude <- train(LONGITUDE ~ . ,
                                            data = training_part_longitude,             # train data partition
                                            method = "svmLinear",                  # type of model
                                            preProc = c("center", "scale"),         # normalization
                                            tuneLength = 10,                        # how many Ks
                                            trControl = ctrl,
                                            metric = "RMSE"
                                            
))

training_svm_longitude
# RMSE      Rsquared   MAE    
# 34.06543  0.9275627  22.7902


# Test dataset 
svm_pred_longitude <- predict(training_svm_longitude, testing_part_longitude)

#Results testset 
postResample(svm_pred_longitude, testing_part_longitude$LONGITUDE)
# RMSE       Rsquared       MAE 
# 32.196540  0.935514 22.122769 









#### SVM3 ####
system.time(training_svm3_longitude <- train(LONGITUDE ~ . ,
                            data = training_part_longitude,             # train data partition
                            method = "svmLinear3",                  # type of model
                            preProc = c("center", "scale"),         # normalization
                            tuneLength = 10,                        # how many Ks
                            trControl = ctrl,
                            metric = "RMSE"

))


training_svm3_longitude
# cost    Loss  RMSE      Rsquared    MAE 
# 1.00  L2    7467.817  0.83838609  7467.366

# Test dataset
svm3_pred_longitude <- predict(training_svm3_longitude, testing_part_longitude)

#Results testset
postResample(svm3_pred_longitude, testing_part_longitude$LONGITUDE)
# RMSE            Rsquared          MAE 
# 7470.2193864    0.8898736 7470.0958986 











#+=++=+=+=+=+=+=+=+=+=+=
#### VALIDATION SET ####
#+=++=+=+=+=+=+=+=+=+=+=


# Removes columns in the validation set to match training set
longitude_validation <- validation[ , which(names(validation) %in% names(testing_part_longitude))]

#View(head(building_validation))

# Check number of columns
ncol(testing_part_longitude)
ncol(longitude_validation)
nrow(testing_part_longitude)
nrow(longitude_validation)
names(testing_part_longitude)
names(longitude_validation)
glimpse(longitude_validation)


# Predicts validation set using SVM
knn_validation_longitude <- predict(training_knn_longitude, longitude_validation)

postResample(knn_validation_longitude, longitude_validation$LONGITUDE)
# RMSE          Rsquared        MAE 
# 19.3114390    0.9745842       8.0232510 

