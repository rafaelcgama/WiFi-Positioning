#+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=+
#### TRAINING MODEL - LATITUDE ####
#+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=+

#### inTrain for latitude ####
inTrain_latitude <- createDataPartition(
  y = training_sampled$LATITUDE,
  p = 0.75,
  list = FALSE
)


latitude_index <- grep("LATITUDE", colnames(training_sampled))

#### Training and Testing partition for latitude ####
training_part_latitude <- training_sampled[ inTrain_latitude, ][ ,c(1:(ncol(training_sampled) - 10), latitude_index)]
testing_part_latitude <- training_sampled[-inTrain_latitude, ][ ,c(1:(ncol(training_sampled) - 10), latitude_index)]

nrow(training_part_latitude)
ncol(training_part_latitude)
glimpse(training_sampled)
glimpse(training_part_latitude)

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
training_knn_latitude <- train(LATITUDE ~ . ,
                               data = training_part_latitude,             # train data partition
                               method = "knn",                         # type of model
                               preProc = c("center", "scale"),         # normalization
                               tuneLength = 10,                        # how many Ks
                               trControl = ctrl,
                               metric = "RMSE"

)

training_knn_latitude
# k   RMSE      Rsquared   MAE     
# 5  6.852280  0.9891351  4.435267


# Test dataset
knn_pred_latitude <- predict(training_knn_latitude, testing_part_latitude)

#Results testset
postResample(knn_pred_latitude, testing_part_latitude$LATITUDE)
# RMSE      Rsquared       MAE 
# 7.0676166 0.9884155      4.5166917










### SVM ####
system.time(training_svm_latitude <- train(LATITUDE ~ . ,
                                           data = training_part_latitude,             # train data partition
                                           method = "svmLinear",                  # type of model
                                           preProc = c("center", "scale"),         # normalization
                                           tuneLength = 10,                        # how many Ks
                                           trControl = ctrl,
                                           metric = "RMSE"

))

training_svm_latitude
# RMSE      Rsquared   MAE     
# 20.65362  0.9079696  13.73426

# Test dataset
svm_pred_latitude <- predict(training_svm_latitude, testing_part_latitude)

#Results testset
postResample(svm_pred_latitude, testing_part_latitude$LATITUDE)
# RMSE        Rsquared        MAE 
# 18.8668469  0.9187707       11.2802857 










#### SVM3 ####
system.time(training_svm3_latitude <- train(LATITUDE ~ . ,
                            data = training_part_latitude,             # train data partition
                            method = "svmLinear3",                  # type of model
                            preProc = c("center", "scale"),         # normalization
                            tuneLength = 10,                        # how many Ks
                            trControl = ctrl,
                            metric = "RMSE"

))
#user  system elapsed
#1440.31   43.23 1494.08


training_svm3_latitude
# cost    Loss  RMSE     Rsquared     MAE
# 0.50    L2    4864389  0.017347227  4864296

# Test dataset
svm3_pred_latitude <- predict(training_svm3_latitude, testing_part_latitude)

#Results testset
postResample(svm3_pred_latitude, testing_part_latitude$LATITUDE)
# RMSE         Rsquared          MAE 
# 4.860573e+06 2.216539e-03      4.859817e+06 









#+=++=+=+=+=+=+=+=+=+=+=
#### VALIDATION SET ####
#+=++=+=+=+=+=+=+=+=+=+=


# Removes columns in the validation set to match training set
latitude_validation <- validation[ , which(names(validation) %in% names(testing_part_latitude))]

#View(head(building_validation))

# Check number of columns
ncol(testing_part_latitude)
ncol(latitude_validation)
nrow(testing_part_latitude)
nrow(latitude_validation)
names(testing_part_latitude)
names(latitude_validation)
glimpse(latitude_validation)


# Predicts validation set using SVM
knn_validation_latitude <- predict(training_knn_latitude, latitude_validation)

postResample(knn_validation_latitude, latitude_validation$LATITUDE)
# RMSE        Rsquared        MAE 
# 12.5630354  0.9680811  7.4933480

