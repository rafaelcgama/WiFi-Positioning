#+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=+
#### TRAINING MODEL - LATITUDE - BUILDING 1 ####
#+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=+



# Group dataset by building
training_sampled_B1 <- training_sampled %>% 
  filter(BUILDINGID == 1)

nrow(training_sampled_B1)
0.75*nrow(training_sampled_B1)
nrow(inTrain_latitude_B1)


#### inTrain for latitude - Building 1 ####
inTrain_latitude_B1 <- createDataPartition(
  y = training_sampled_B1$LATITUDE,
  p = 0.75,
  list = FALSE
)


latitude_index <- grep("LATITUDE", colnames(training_sampled_B1))

#### Training and Testing partition for latitude - Building 1 ####
training_part_latitude_B1 <- training_sampled_B1[ inTrain_latitude_B1, ][ , c(1:(ncol(training_sampled_B1) - 10), latitude_index)]
testing_part_latitude_B1 <- training_sampled_B1[-inTrain_latitude_B1, ][ , c(1:(ncol(training_sampled_B1) - 10), latitude_index)]

nrow(training_part_latitude_B1)
nrow(testing_part_latitude_B1)

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


#### MODELS FOR LATITUDE - FLOOR 1 ####


#### KNN ####
training_knn_latitude_B1 <- train(LATITUDE ~ . ,
                            data = training_part_latitude_B1,      # train data partition
                            method = "knn",                         # type of model
                            preProc = c("center", "scale"),         # normalization
                            tuneLength = 10,                        # how many Ks
                            trControl = ctrl,
                            metric = "RMSE"

)

training_knn_latitude_B1
# k   RMSE       Rsquared   MAE     
# 5   7.733383  0.9564665  5.453958


# Test dataset
knn_pred_latitude_B1 <- predict(training_knn_latitude_B1, testing_part_latitude_B1)

#Results testset
postResample(knn_pred_latitude_B1, testing_part_latitude_B1$LATITUDE)
# RMSE        Rsquared       MAE 
# 7.0678615   0.9641733      5.0551430 









#### SVM ####
training_svm_latitude_B1 <- train(LATITUDE ~ . ,
                                  data = training_part_latitude_B1,      # train data partition
                                  method = "svmLinear",                   # type of model
                                  preProc = c("center", "scale"),         # normalization
                                  tuneLength = 10,                        # how many Ks
                                  trControl = ctrl,
                                  metric = "RMSE"

)

training_svm_latitude_B1
# RMSE      Rsquared   MAE     
# 11.52866  0.9072928  8.370274


# Test dataset
svm_pred_latitude_B1 <- predict(training_svm_latitude_B1, testing_part_latitude_B1)

#Results testset
postResample(svm_pred_latitude_B1, testing_part_latitude_B1$LATITUDE)
# RMSE   Rsquared        MAE 
# 12.6077439  0.8861071  8.7170816 









#### SVM3 ####
training_svm3_latitude_B1 <- train(LATITUDE ~ . ,
                                    data = training_part_latitude_B1,          # train data partition
                                    method = "svmLinear3",                  # type of model
                                    preProc = c("center", "scale"),         # normalization
                                    tuneLength = 10,                        # how many Ks
                                    trControl = ctrl,
                                    metric = "RMSE"

)

training_svm3_latitude_B1
# cost    Loss  RMSE     Rsquared    MAE 
# 128.00  L2    4863745  0.05532201  4863579

# Test dataset
svm3_pred_latitude_B1 <- predict(training_svm3_latitude_B1, testing_part_latitude_B1)

#Results testset
postResample(svm3_pred_latitude_B1, testing_part_latitude_B1$LATITUDE)
# RMSE         Rsquared          MAE 
# 4.861465e+06 7.519210e-04 4.861411e+06 








#+=++=+=+=+=+=+=+=+=+=+=
#### VALIDATION SET ####
#+=++=+=+=+=+=+=+=+=+=+=

latitude_B1_validation <- validation

# Substitute BuildingID data by the predicted BuildingID
latitude_B1_validation$BUILDINGID <- svm3_validation_building


# Test to check if it was substituted 
sum(validation$BUILDINGID != latitude_B1_validation$BUILDINGID)
names(latitude_B1_validation)

# Selects only building 1 from validation dataset
latitude_B1_validation <- latitude_B1_validation %>% 
  filter(BUILDINGID == 1)


# Removes columns in the validation set to match training set
latitude_B1_validation <- latitude_B1_validation[ , which(names(latitude_B1_validation) %in% names(testing_part_latitude_B1))]




#View(head(building_validation))

# Check number of columns
ncol(testing_part_latitude_B1)
ncol(latitude_B1_validation)
nrow(testing_part_latitude_B1)
nrow(latitude_B1_validation)
names(testing_part_latitude_B1)
names(latitude_B1_validation)
glimpse(latitude_B1_validation)


# Predicts validation set using SVM
knn_validation_latitude_B1 <- predict(training_knn_latitude_B1, latitude_B1_validation)

postResample(knn_validation_latitude_B1, latitude_B1_validation$LATITUDE)
# RMSE         Rsquared        MAE 
# 12.4773632   0.8780378       8.3096979 


