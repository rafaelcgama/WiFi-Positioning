#+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=+
#### TRAINING MODEL - latitude - BUILDING 0 ####
#+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=+



# Group dataset by building
training_sampled_B0 <- training_sampled %>% 
  filter(BUILDINGID == 0)


# # Refactor latitude to make sure building 0 has the appropriate amount of factors for latitude
# training_sampled_B0$LATITUDE <- factor(training_sampled_B0$LATITUDE)


#### inTrain for LATITUDE - Building 0  ####
inTrain_latitude_B0 <- createDataPartition(
  y = training_sampled_B0$LATITUDE,
  p = 0.75,
  list = FALSE
)


latitude_index <- grep("LATITUDE", colnames(training_sampled_B0))

#### Training and Testing partition for latitude - Building 0  ####
training_part_latitude_B0 <- training_sampled_B0[ inTrain_latitude_B0, ][ , c(1:(ncol(training_sampled_B0) - 10), latitude_index)]
testing_part_latitude_B0 <- training_sampled_B0[-inTrain_latitude_B0, ][ , c(1:(ncol(training_sampled_B0) - 10), latitude_index)]



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


#### MODELS FOR LATITUDE - FLOOR 0 ####


# #### KNN ####
training_knn_latitude_B0 <- train(LATITUDE ~ . ,
                            data = training_part_latitude_B0,      # train data partition
                            method = "knn",                         # type of model
                            preProc = c("center", "scale"),         # normalization
                            tuneLength = 10,                        # how many Ks
                            trControl = ctrl,
                            metric = "RMSE"

)

training_knn_latitude_B0
# k   RMSE      Rsquared   MAE     
# 5   5.830904  0.9690223  3.876568

# Test dataset
knn_pred_latitude_B0 <- predict(training_knn_latitude_B0, testing_part_latitude_B0)

#Results testset
postResample(knn_pred_latitude_B0, testing_part_latitude_B0$LATITUDE)
# RMSE       Rsquared       MAE 
# 6.1014845  0.9666877      4.0159692 










### SVM ####
training_svm_latitude_B0 <- train(LATITUDE ~ . ,
                                   data = training_part_latitude_B0,          # train data partition
                                   method = "svmLinear",                   # type of model
                                   preProc = c("center", "scale"),         # normalization
                                   tuneLength = 10,                        # how many Ks
                                   trControl = ctrl,
                                   metric = "RMSE"

)

training_svm_latitude_B0
# RMSE      Rsquared   MAE     
# 10.17991  0.9053047  7.651087


# Test dataset
svm_pred_latitude_B0 <- predict(training_svm_latitude_B0, testing_part_latitude_B0)

#Results testset
postResample(svm_pred_latitude_B0, testing_part_latitude_B0$LATITUDE)
# RMSE        Rsquared        MAE 
# 11.1402547  0.8936888       8.2544027 










#### SVM3 ####
training_svm3_latitude_B0 <- train(LATITUDE ~ . ,
                                    data = training_part_latitude_B0,       # train data partition
                                    method = "svmLinear3",                  # type of model
                                    preProc = c("center", "scale"),         # normalization
                                    tuneLength = 10,                        # how many Ks
                                    trControl = ctrl,
                                    metric = "RMSE"

)

training_svm3_latitude_B0
# cost  Loss  RMSE     Rsquared    MAE 
# 1.00  L2    4863916  0.04668388  4863794


# Test dataset
svm3_pred_latitude_B0 <- predict(training_svm3_latitude_B0, testing_part_latitude_B0)

#Results testset
postResample(svm3_pred_latitude_B0, testing_part_latitude_B0$LATITUDE)
# RMSE           Rsquared          MAE 
# 4.866609e+06   1.546621e-02      4.866477e+06 











#+=++=+=+=+=+=+=+=+=+=+=
#### VALIDATION SET ####
#+=++=+=+=+=+=+=+=+=+=+=

latitude_B0_validation <- validation

# Substitute BuildingID data by the predicted BuildingID
latitude_B0_validation$BUILDINGID <- svm3_validation_building


# Test to check if it was substituted 
sum(validation$BUILDINGID != latitude_B0_validation$BUILDINGID)
names(latitude_B0_validation)

# Selects only building 0 from validation dataset
latitude_B0_validation <- latitude_B0_validation %>% 
  filter(BUILDINGID == 0)


# Removes columns in the validation set to match training set
latitude_B0_validation <- latitude_B0_validation[ , which(names(latitude_B0_validation) %in% names(testing_part_latitude_B0))]




#View(head(building_validation))

# Check number of columns
ncol(testing_part_latitude_B0)
ncol(latitude_B0_validation)
nrow(testing_part_latitude_B0)
nrow(latitude_B0_validation)
names(testing_part_latitude_B0)
names(latitude_B0_validation)
glimpse(latitude_B0_validation)


# Predicts validation set using SVM
knn_validation_latitude_B0 <- predict(training_knn_latitude_B0, latitude_B0_validation)

postResample(knn_validation_latitude_B0, latitude_B0_validation$LATITUDE)
# RMSE   Rsquared        MAE 
# 10.6981227  0.8901857  5.7931744 

