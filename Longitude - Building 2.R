#+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=+
#### TRAINING MODEL - LONGITUDE - BUILDING 2 ####
#+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=+



# Group dataset by building
training_sampled_B2 <- training_sampled %>% 
  filter(BUILDINGID == 2)



#### inTrain for Longitude - Building 2 ####
inTrain_longitude_B2 <- createDataPartition(
  y = training_sampled_B2$LONGITUDE,
  p = 0.75,
  list = FALSE
)


longitude_index <- grep("LONGITUDE", colnames(training_sampled_B2))

#### Training and Testing partition for Longitude - Building 2####
training_part_longitude_B2 <- training_sampled_B2[ inTrain_longitude_B2, ][ , c(1:(ncol(training_sampled_B2) - 10), longitude_index)]
testing_part_longitude_B2 <- training_sampled_B2[-inTrain_longitude_B2, ][ , c(1:(ncol(training_sampled_B2) - 10), longitude_index)]

nrow(training_part_longitude_B2)
nrow(testing_part_longitude_B2)

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


#### MODELS FOR LONGITUDE - FLOOR 2 ####


#### KNN ####
training_knn_longitude_B2 <- train(LONGITUDE ~ . ,
                            data = training_part_longitude_B2,      # train data partition
                            method = "knn",                         # type of model
                            preProc = c("center", "scale"),         # normalization
                            tuneLength = 10,                        # how many Ks
                            trControl = ctrl,
                            metric = "RMSE"

)

training_knn_longitude_B2
# k   RMSE       Rsquared   MAE     
# 5   7.930174  0.9260331  4.800811

# Test dataset
knn_pred_longitude_B2 <- predict(training_knn_longitude_B2, testing_part_longitude_B2)

#Results testset
postResample(knn_pred_longitude_B2, testing_part_longitude_B2$LONGITUDE)
# RMSE      Rsquared       MAE 
# 7.2353711 0.9413867      4.5797666 




#### SVM ####
training_svm_longitude_B2 <- train(LONGITUDE ~ . ,
                                   data = training_part_longitude_B2,          # train data partition
                                   method = "svmLinear",                   # type of model
                                   preProc = c("center", "scale"),         # normalization
                                   tuneLength = 10,                        # how many Ks
                                   trControl = ctrl,
                                   metric = "RMSE"

)

training_svm_longitude_B2
# RMSE      Rsquared   MAE     
# 14.35795  0.7783125  10.12651



# Test dataset
svm_pred_longitude_B2 <- predict(training_svm_longitude_B2, testing_part_longitude_B2)

#Results testset
postResample(svm_pred_longitude_B2, testing_part_longitude_B2$LONGITUDE)
# RMSE        Rsquared        MAE 
# 14.6714597  0.7704589       10.2841887 








#### SVM3 ####
training_svm3_longitude_B2 <- train(LONGITUDE ~ . ,
                                    data = training_part_longitude_B2,          # train data partition
                                    method = "svmLinear3",                  # type of model
                                    preProc = c("center", "scale"),         # normalization
                                    tuneLength = 10,                        # how many Ks
                                    trControl = ctrl,
                                    metric = "RMSE"

)

training_svm3_longitude_B2
# cost    Loss  RMSE      Rsquared    MAE 
# 128.00  L1    7350.982  0.30422482  7350.073

# Test dataset
svm3_pred_longitude_B2 <- predict(training_svm3_longitude_B2, testing_part_longitude_B2)

#Results testset
postResample(svm3_pred_longitude_B2, testing_part_longitude_B2$LONGITUDE)









#+=++=+=+=+=+=+=+=+=+=+=
#### VALIDATION SET ####
#+=++=+=+=+=+=+=+=+=+=+=

longitude_B2_validation <- validation

# Substitute BuildingID data by the predicted BuildingID
longitude_B2_validation$BUILDINGID <- svm3_validation_building


# Test to check if it was substituted 
sum(validation$BUILDINGID != longitude_B2_validation$BUILDINGID)
names(longitude_B2_validation)

# Selects only building 2 from validation dataset
longitude_B2_validation <- longitude_B2_validation %>% 
  filter(BUILDINGID == 2)


# Removes columns in the validation set to match training set
longitude_B2_validation <- longitude_B2_validation[ , which(names(longitude_B2_validation) %in% names(testing_part_longitude_B2))]




#View(head(building_validation))

# Check number of columns
ncol(testing_part_longitude_B2)
ncol(longitude_B2_validation)
nrow(testing_part_longitude_B2)
nrow(longitude_B2_validation)
names(testing_part_longitude_B2)
names(longitude_B2_validation)
glimpse(longitude_B2_validation)


# Predicts validation set using SVM
knn_validation_longitude_B2 <- predict(training_knn_longitude_B2, longitude_B2_validation)

postResample(knn_validation_longitude_B2, longitude_B2_validation$LONGITUDE)
# RMSE          Rsquared        MAE 
# 11.2276256    0.8728729       7.7953387


