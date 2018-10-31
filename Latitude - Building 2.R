#+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=+
#### TRAINING MODEL - LATITUDE - BUILDING 2 ####
#+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=+



# Group dataset by building
training_sampled_B2 <- training_sampled %>% 
  filter(BUILDINGID == 2)

nrow(training_sampled_B2)
0.75*nrow(training_sampled_B2)



#### inTrain for latitude - Building 2 ####
inTrain_latitude_B2 <- createDataPartition(
  y = training_sampled_B2$LATITUDE,
  p = 0.75,
  list = FALSE
)


latitude_index <- grep("LATITUDE", colnames(training_sampled_B2))

#### Training and Testing partition for latitude - Building 2####
training_part_latitude_B2 <- training_sampled_B2[ inTrain_latitude_B2, ][ , c(1:(ncol(training_sampled_B2) - 10), latitude_index)]
testing_part_latitude_B2 <- training_sampled_B2[-inTrain_latitude_B2, ][ , c(1:(ncol(training_sampled_B2) - 10), latitude_index)]

nrow(training_part_latitude_B2)
nrow(testing_part_latitude_B2)

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


#### MODELS FOR LATITUDE - FLOOR 2 ####


#### KNN ####
training_knn_latitude_B2 <- train(LATITUDE ~ . ,
                            data = training_part_latitude_B2,      # train data partition
                            method = "knn",                         # type of model
                            preProc = c("center", "scale"),         # normalization
                            tuneLength = 10,                        # how many Ks
                            trControl = ctrl,
                            metric = "RMSE"

)

training_knn_latitude_B2
# k   RMSE      Rsquared   MAE     
# 5   5.728701  0.9538075  3.888619

# Test dataset
knn_pred_latitude_B2 <- predict(training_knn_latitude_B2, testing_part_latitude_B2)

#Results testset
postResample(knn_pred_latitude_B2, testing_part_latitude_B2$LATITUDE)
# RMSE        Rsquared       MAE 
# 7.4843301   0.9320437      4.3832111 











### SVM ####
training_svm_latitude_B2 <- train(LATITUDE ~ . ,
                                  data = training_part_latitude_B2,          # train data partition
                                  method = "svmLinear",                   # type of model
                                  preProc = c("center", "scale"),         # normalization
                                  tuneLength = 10,                        # how many Ks
                                  trControl = ctrl,
                                  metric = "RMSE"

)

training_svm_latitude_B2
# RMSE     Rsquared   MAE     
# 11.2524  0.8283423  7.907218


# Test dataset
svm_pred_latitude_B2 <- predict(training_svm_latitude_B2, testing_part_latitude_B2)

#Results testset
postResample(svm_pred_latitude_B2, testing_part_latitude_B2$LATITUDE)
# RMSE        Rsquared        MAE 
# 14.1745094  0.7696263  8.5895962 










#### SVM3 ####
training_svm3_latitude_B2 <- train(LATITUDE ~ . ,
                                    data = training_part_latitude_B2,          # train data partition
                                    method = "svmLinear3",                  # type of model
                                    preProc = c("center", "scale"),         # normalization
                                    tuneLength = 10,                        # how many Ks
                                    trControl = ctrl,
                                    metric = "RMSE"

)

training_svm3_latitude_B2
# cost    Loss  RMSE     Rsquared     MAE 
# 64.00   L2    4861191  0.007615348  4860060

# Test dataset
svm3_pred_latitude_B2 <- predict(training_svm3_latitude_B2, testing_part_latitude_B2)

#Results testset
postResample(svm3_pred_latitude_B2, testing_part_latitude_B2$LATITUDE)
# RMSE         Rsquared          MAE 
# 4.862235e+06 6.694730e-05 4.862031e+06 











#+=++=+=+=+=+=+=+=+=+=+=
#### VALIDATION SET ####
#+=++=+=+=+=+=+=+=+=+=+=

latitude_B2_validation <- validation

# Substitute BuildingID data by the predicted BuildingID
latitude_B2_validation$BUILDINGID <- svm3_validation_building


# Test to check if it was substituted 
sum(validation$BUILDINGID != latitude_B2_validation$BUILDINGID)
names(latitude_B2_validation)

# Selects only building 2 from validation dataset
latitude_B2_validation <- latitude_B2_validation %>% 
  filter(BUILDINGID == 2)


# Removes columns in the validation set to match training set
latitude_B2_validation <- latitude_B2_validation[ , which(names(latitude_B2_validation) %in% names(testing_part_latitude_B2))]




#View(head(building_validation))

# Check number of columns
ncol(testing_part_latitude_B2)
ncol(latitude_B2_validation)
nrow(testing_part_latitude_B2)
nrow(latitude_B2_validation)
names(testing_part_latitude_B2)
names(latitude_B2_validation)
glimpse(latitude_B2_validation)


# Predicts validation set using SVM
knn_validation_latitude_B2 <- predict(training_knn_latitude_B2, latitude_B2_validation)

postResample(knn_validation_latitude_B2, latitude_B2_validation$LATITUDE)
# RMSE        Rsquared       MAE 
# 11.875792   0.837127       7.614126 


