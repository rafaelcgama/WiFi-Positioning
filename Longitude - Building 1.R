#+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=+
#### TRAINING MODEL - LONGITUDE - BUILDING 1 ####
#+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=+



# Group dataset by building
training_sampled_B1 <- training_sampled %>% 
  filter(BUILDINGID == 1)

nrow(training_sampled_B1)
0.75*nrow(training_sampled_B1)


#### inTrain for Longitude - Building 1 ####
inTrain_longitude_B1 <- createDataPartition(
  y = training_sampled_B1$LONGITUDE,
  p = 0.75,
  list = FALSE
)


longitude_index <- grep("LONGITUDE", colnames(training_sampled_B1))

#### Training and Testing partition for Longitude - Building 1 ####
training_part_longitude_B1 <- training_sampled_B1[ inTrain_longitude_B1, ][ , c(1:(ncol(training_sampled_B1) - 10), longitude_index)]
testing_part_longitude_B1 <- training_sampled_B1[-inTrain_longitude_B1, ][ , c(1:(ncol(training_sampled_B1) - 10), longitude_index)]

nrow(training_part_longitude_B1)
nrow(testing_part_longitude_B1)

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


#### MODELS FOR LONGITUDE - FLOOR 1 ####


#### KNN ####
training_knn_longitude_B1 <- train(LONGITUDE ~ . ,
                            data = training_part_longitude_B1,      # train data partition
                            method = "knn",                         # type of model
                            preProc = c("center", "scale"),         # normalization
                            tuneLength = 10,                        # how many Ks
                            trControl = ctrl,
                            metric = "RMSE"

)

training_knn_longitude_B1
# k   RMSE      Rsquared   MAE     
# 5  8.378444  0.9741367  5.979610

# Test dataset
knn_pred_longitude_B1 <- predict(training_knn_longitude_B1, testing_part_longitude_B1)

#Results testset
postResample(knn_pred_longitude_B1, testing_part_longitude_B1$LONGITUDE)
# RMSE         Rsquared       MAE 
# 7.7691588    0.9774644      5.1895351 








#### SVM ####
training_svm_longitude_B1 <- train(LONGITUDE ~ . ,
                                   data = training_part_longitude_B1,      # train data partition
                                   method = "svmLinear",                   # type of model
                                   preProc = c("center", "scale"),         # normalization
                                   tuneLength = 10,                        # how many Ks
                                   trControl = ctrl,
                                   metric = "RMSE"

)

training_svm_longitude_B1
# RMSE      Rsquared   MAE     
# 15.64786  0.9110266  11.21465


# Test dataset
svm_pred_longitude_B1 <- predict(training_svm_longitude_B1, testing_part_longitude_B1)

#Results testset
postResample(svm_pred_longitude_B1, testing_part_longitude_B1$LONGITUDE)
# RMSE   Rsquared        MAE 
# 14.1488333  0.9273799 10.0536550 








#### SVM3 ####
training_svm3_longitude_B1 <- train(LONGITUDE ~ . ,
                                    data = training_part_longitude_B1,          # train data partition
                                    method = "svmLinear3",                  # type of model
                                    preProc = c("center", "scale"),         # normalization
                                    tuneLength = 10,                        # how many Ks
                                    trControl = ctrl,
                                    metric = "RMSE"

)

training_svm3_longitude_B1
# cost    Loss  RMSE      Rsquared    MAE  
# 2.00    L2    7486.525  0.51775788  7486.374

# Test dataset
svm3_pred_longitude_B1 <- predict(training_svm3_longitude_B1, testing_part_longitude_B1)

#Results testset
postResample(svm3_pred_longitude_B1, testing_part_longitude_B1$LONGITUDE)







#+=++=+=+=+=+=+=+=+=+=+=
#### VALIDATION SET ####
#+=++=+=+=+=+=+=+=+=+=+=


longitude_B1_validation <- validation

# Substitute BuildingID data by the predicted BuildingID
longitude_B1_validation$BUILDINGID <- svm3_validation_building


# Test to check if it was substituted 
sum(validation$BUILDINGID != longitude_B1_validation$BUILDINGID)
names(longitude_B1_validation)

# Selects only building 1 from validation dataset
longitude_B1_validation <- longitude_B1_validation %>% 
  filter(BUILDINGID == 1)


# Removes columns in the validation set to match training set
longitude_B1_validation <- longitude_B1_validation[ , which(names(longitude_B1_validation) %in% names(testing_part_longitude_B1))]


#View(head(building_validation))

# Check number of columns
ncol(testing_part_longitude_B1)
ncol(longitude_B1_validation)
nrow(testing_part_longitude_B1)
nrow(longitude_B1_validation)
names(testing_part_longitude_B1)
names(longitude_B1_validation)
glimpse(longitude_B1_validation)


# Predicts validation set using KNN
knn_validation_longitude_B1 <- predict(training_knn_longitude_B1, longitude_B1_validation)

postResample(knn_validation_longitude_B1, longitude_B1_validation$LONGITUDE)
# RMSE        Rsquared       MAE 
# 9.9530115   0.9546155      6.9028390  


