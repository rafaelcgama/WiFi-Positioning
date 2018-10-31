#+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=+
#### TRAINING MODEL - FLOOR - BUILDING 1 ####
#+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=+



# Group dataset by building
training_sampled_B1 <- training_sampled %>% 
  filter(BUILDINGID == 1)

# Refactor Floor because there are 5 levels(4 floors) but building 0 and 1 have only 4 floors 
training_sampled_B1$FLOOR <- factor(training_sampled_B1$FLOOR)


#### inTrain for Floor ####
inTrain_floor_B1 <- createDataPartition(
  y = training_sampled_B1$FLOOR,
  p = 0.75,
  list = FALSE
)

floor_index <- grep("FLOOR", colnames(training_sampled_B1))

#### Training and Testing partition for Floor 1 ####
training_part_floor_B1 <- training_sampled_B1[ inTrain_floor_B1, ][ , c(1:(ncol(training_sampled_B1) - 10), floor_index)]
testing_part_floor_B1 <- training_sampled_B1[-inTrain_floor_B1, ][ , c(1:(ncol(training_sampled_B1) - 10), floor_index)]



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
training_knn_floor_B1 <- train(FLOOR ~ . ,
                            data = training_part_floor_B1,             # train data partition
                            method = "knn",                         # type of model
                            preProc = c("center", "scale"),         # normalization
                            tuneLength = 10,                        # how many Ks
                            trControl = ctrl,
                            metric = "Accuracy"

)

training_knn_floor_B1
# k   Accuracy   Kappa    
# 5  0.9597071  0.9453023


# Test dataset
knn_pred_floor_B1 <- predict(training_knn_floor_B1, testing_part_floor_B1)

#Results testset
postResample(knn_pred_floor_B1, testing_part_floor_B1$FLOOR)
# Accuracy     Kappa 
# 0.9589744 0.9442937









#### SVM ####
training_svm_floor_B1 <- train(FLOOR ~ . ,
                               data = training_part_floor_B1,          # train data partition
                               method = "svmLinear",                   # type of model
                               preProc = c("center", "scale"),         # normalization
                               tuneLength = 10,                        # how many Ks
                               trControl = ctrl,
                               metric = "Accuracy"
                               
)

training_svm_floor_B1
# Accuracy   Kappa    
# 0.9858059  0.9807469


# Test dataset 
svm_pred_floor_build_1 <- predict(training_svm_floor_B1, testing_part_floor_B1)

#Results testset 
postResample(svm_pred_floor_build_1, testing_part_floor_B1$FLOOR)
# Accuracy    Kappa 
# 1           1











#### SVM3 ####
training_svm3_floor_B1 <- train(FLOOR ~ . ,
                                data = training_part_floor_B1,          # train data partition
                                method = "svmLinear3",                  # type of model
                                preProc = c("center", "scale"),         # normalization
                                tuneLength = 10,                        # how many Ks
                                trControl = ctrl,
                                metric = "Accuracy"

)

training_svm3_floor_B1
# cost    Loss  Accuracy   Kappa    
# 0.25  L1    0.9745062  0.9654907


# Test dataset
svm3_pred_floor_B1 <- predict(training_svm3_floor_B1, testing_part_floor_B1)

#Results testset
postResample(svm3_pred_floor_B1, testing_part_floor_B1$FLOOR)
# Accuracy     Kappa 
# 0.9846154 0.9791503 










#### C5.0 ####
training_C5.0_floor_build_1 <- train(FLOOR ~ . ,
                                     data = training_part_floor_B1,     # train data partition
                                     method = "C5.0",                        # type of model
                                     preProc = c("center", "scale"),         # normalization
                                     tuneLength = 10,                        # how many Ks
                                     trControl = ctrl,
                                     metric = "Accuracy"

)

training_C5.0_floor_build_1



# Test dataset
C5.0_pred_floor_build_1 <- predict(training_C5.0_floor_build_1, testing_part_floor_B1)

#Results testset
postResample(C5.0_pred_floor_build_1, testing_part_floor_B1$FLOOR)
#model  winnow  trials  Accuracy   Kappa
#rules  FALSE   90      0.9707778  0.9608399







#### VALIDATION SET ####

floor_B1_validation <- validation

# Substitute BuildingID data by the predicted BuildingID
floor_B1_validation$BUILDINGID <- svm3_validation_building

# Test to check if it was substituted 
sum(validation$BUILDINGID != floor_B1_validation$BUILDINGID)
names(floor_B1_validation)

# Selects only building 1 from validation dataset
floor_B1_validation <- floor_B1_validation %>% 
  filter(BUILDINGID == 1)


# Removes columns in the validation set to match training set
floor_B1_validation <- floor_B1_validation[ , which(names(floor_B1_validation) %in% names(testing_part_floor_B1))]




#View(head(building_validation))

# Check number of columns
ncol(testing_part_floor_B1)
ncol(floor_B1_validation)
nrow(testing_part_floor_B1)
nrow(floor_B1_validation)
names(testing_part_floor_B1)
names(floor_B1_validation)
glimpse(floor_B1_validation)


# Predicts validation set using SVM
svm_validation_floor_B1 <- predict(training_svm_floor_B1, floor_B1_validation)

postResample(svm_validation_floor_B1, floor_B1_validation$FLOOR)
# Accuracy     Kappa 
# 0.8000000    0.7149969  

