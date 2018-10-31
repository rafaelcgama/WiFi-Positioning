#+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=+
#### TRAINING MODEL - LONGITUDE - BUILDING 0 ####
#+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=+



# Group dataset by building
training_sampled_B0 <- training_sampled %>% 
  filter(BUILDINGID == 0)


# # Refactor Longitude to make sure building 1 has the appropriate amount of factors for longitude
# training_sampled_B1$LONGITUDE <- factor(training_sampled_B1$LONGITUDE)


#### inTrain for Longitude - Building 0  ####
inTrain_longitude_B0 <- createDataPartition(
  y = training_sampled_B0$LONGITUDE,
  p = 0.75,
  list = FALSE
)


longitude_index <- grep("LONGITUDE", colnames(training_sampled_B0))

#### Training and Testing partition for Longitude - Building 0  ####
training_part_longitude_B0 <- training_sampled_B0[ inTrain_longitude_B0, ][ , c(1:(ncol(training_sampled_B0) - 10), longitude_index)]
testing_part_longitude_B0 <- training_sampled_B0[-inTrain_longitude_B0, ][ , c(1:(ncol(training_sampled_B0) - 10), longitude_index)]



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


#### MODELS FOR LONGITUDE - FLOOR 0 ####


#### KNN ####
training_knn_longitude_B0 <- train(LONGITUDE ~ . ,
                            data = training_part_longitude_B0,      # train data partition
                            method = "knn",                         # type of model
                            preProc = c("center", "scale"),         # normalization
                            tuneLength = 10,                        # how many Ks
                            trControl = ctrl,
                            metric = "RMSE"

)

training_knn_longitude_B0
# k   RMSE      Rsquared   MAE     
# 6.478668  0.9385446  4.564552

# Test dataset
knn_pred_longitude_B0 <- predict(training_knn_longitude_B0, testing_part_longitude_B0)

#Results testset
postResample(knn_pred_longitude_B0, testing_part_longitude_B0$LONGITUDE)
# RMSE      Rsquared       MAE 
# 5.4904152 0.9573618      4.0539237 




# Check data integrity  
names(training_part_longitude_B0)
nrow(training_part_longitude_B0)
ncol(training_part_longitude_B0)
#View(training_part_longitude_B0$LONGITUDE)




#### SVM ####
training_svm_longitude_B0 <- train(LONGITUDE ~ . ,
                               data = training_part_longitude_B0,      # train data partition
                               method = "svmLinear",                   # type of model
                               preProc = c("center", "scale"),         # normalization
                               tuneLength = 10,                        # how many Ks
                               trControl = ctrl,
                               metric = "RMSE"

)

training_svm_longitude_B0
# RMSE      Rsquared   MAE     
# 8.894759  0.8868629  6.696175


# Test dataset
svm_pred_longitude_B0 <- predict(training_svm_longitude_B0, testing_part_longitude_B0)

#Results testset
postResample(svm_pred_longitude_B0, testing_part_longitude_B0$LONGITUDE)
# RMSE        Rsquared        MAE 
# 12.0418897  0.7833766  8.2978075 








#### SVM3 ####
training_svm3_longitude_B0 <- train(LONGITUDE ~ . ,
                                    data = training_part_longitude_B0,          # train data partition
                                    method = "svmLinear3",                  # type of model
                                    preProc = c("center", "scale"),         # normalization
                                    tuneLength = 10,                        # how many Ks
                                    trControl = ctrl,
                                    metric = "RMSE"

)

training_svm3_longitude_B0
# cost    Loss  RMSE      Rsquared    MAE 
# 16.00   L2    7635.783  0.20866704  7635.466

# Test dataset
svm3_pred_longitude_B0 <- predict(training_svm3_longitude_B0, testing_part_longitude_B0)

#Results testset
postResample(svm3_pred_longitude_B0, testing_part_longitude_B0$LONGITUDE)
# RMSE            Rsquared          MAE 
# 7652.5516806    0.1619226 7652.3082598 





# #### C5.0 ####
# training_C5.0_longitude_B0 <- train(LONGITUDE ~ . ,
#                                      data = training_part_longitude_B0,     # train data partition
#                                      method = "C5.0",                        # type of model
#                                      preProc = c("center", "scale"),         # normalization
#                                      tuneLength = 10,                        # how many Ks
#                                      trControl = ctrl,
#                                      metric = "RMSE"
#                                      
# )
# 
# training_C5.0_longitude_B0
# 
# 
# 
# # Test dataset 
# C5.0_pred_longitude_B0 <- predict(training_C5.0_longitude_B0, testing_part_longitude_B0)
# 
# #Results testset 
# postResample(C5.0_pred_longitude_B0, testing_part_longitude_B0$LONGITUDE)







#+=++=+=+=+=+=+=+=+=+=+=
#### VALIDATION SET ####
#+=++=+=+=+=+=+=+=+=+=+=

longitude_B0_validation <- validation

# Substitute BuildingID data by the predicted BuildingID
longitude_B0_validation$BUILDINGID <- svm3_validation_building


# Test to check if it was substituted 
sum(validation$BUILDINGID != longitude_B0_validation$BUILDINGID)
names(longitude_B0_validation)

# Selects only building 0 from validation dataset
longitude_B0_validation <- longitude_B0_validation %>% 
  filter(BUILDINGID == 0)


# Removes columns in the validation set to match training set
longitude_B0_validation <- longitude_B0_validation[ , which(names(longitude_B0_validation) %in% names(testing_part_longitude_B0))]




#View(head(building_validation))

# Check number of columns
ncol(testing_part_longitude_B0)
ncol(longitude_B0_validation)
nrow(testing_part_longitude_B0)
nrow(longitude_B0_validation)
names(testing_part_longitude_B0)
names(longitude_B0_validation)
glimpse(longitude_B0_validation)


# Predicts validation set using SVM
knn_validation_longitude_B0 <- predict(training_knn_longitude_B0, longitude_B0_validation)

postResample(knn_validation_longitude_B0, longitude_B0_validation$LONGITUDE)
# RMSE          Rsquared        MAE 
# 10.6769225    0.8414661       6.1205738


