#+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=+
#### TRAINING MODEL - FLOOR - BUILDING 2 ####
#+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=+



# Group dataset by building
training_sampled_B2 <- training_sampled %>% 
  filter(BUILDINGID == 2)

# Refactor Floor because there are 5 levels(4 floors) but building 0 and 1 have only 4 floors 
training_sampled_B2$FLOOR <- factor(training_sampled_B2$FLOOR)


#### inTrain for Floor ####
inTrain_floor_B2 <- createDataPartition(
  y = training_sampled_B2$FLOOR,
  p = 0.75,
  list = FALSE
)

floor_index <- grep("FLOOR", colnames(training_sampled_B2))

#### Training and Testing partition for Floor 2 ####
training_part_floor_B2 <- training_sampled_B2[ inTrain_floor_B2, ][ , c(1:(ncol(training_sampled_B2) - 10), floor_index)]
testing_part_floor_B2 <- training_sampled_B2[-inTrain_floor_B2, ][ , c(1:(ncol(training_sampled_B2) - 10), floor_index)]



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
training_knn_floor_B2 <- train(FLOOR ~ . ,
                            data = training_part_floor_B2,             # train data partition
                            method = "knn",                         # type of model
                            preProc = c("center", "scale"),         # normalization
                            tuneLength = 10,                        # how many Ks
                            trControl = ctrl,
                            metric = "Accuracy"

)

training_knn_floor_B2
# k   Accuracy   Kappa    
# 5  0.9683099  0.9584129


# Test dataset
knn_pred_floor_B2 <- predict(training_knn_floor_B2, testing_part_floor_B2)

#Results testset
postResample(knn_pred_floor_B2, testing_part_floor_B2$FLOOR)
# Accuracy     Kappa 
# 0.9502924 0.9346448 







#### SVM ####
training_svm_floor_B2 <- train(FLOOR ~ . ,
                               data = training_part_floor_B2,          # train data partition
                               method = "svmLinear",                   # type of model
                               preProc = c("center", "scale"),         # normalization
                               tuneLength = 10,                        # how many Ks
                               trControl = ctrl,
                               metric = "Accuracy"
                               
)

training_svm_floor_B2
# Accuracy   Kappa    
# 0.9912836  0.9885722

# Test dataset 
svm_pred_floor_B2 <- predict(training_svm_floor_B2, testing_part_floor_B2)

#Results testset 
postResample(svm_pred_floor_B2, testing_part_floor_B2$FLOOR)
# Accuracy     Kappa 
# 0.9824561 0.9769733 









#### SVM3 ####
training_svm3_floor_B2 <- train(FLOOR ~ . ,
                                data = training_part_floor_B2,          # train data partition
                                method = "svmLinear3",                  # type of model
                                preProc = c("center", "scale"),         # normalization
                                tuneLength = 10,                        # how many Ks
                                trControl = ctrl,
                                metric = "Accuracy"

)

training_svm3_floor_B2
# cost    Loss  Accuracy   Kappa    
# 0.25  L1    0.9848205  0.9800954


# Test dataset
svm3_pred_floor_B2 <- predict(training_svm3_floor_B2, testing_part_floor_B2)

#Results testset
postResample(svm3_pred_floor_B2, testing_part_floor_B2$FLOOR)
# Accuracy     Kappa 
# 0.9795322 0.9731512 









#### C5.0 ####
training_C5.0_floor_build_2 <- train(FLOOR ~ . ,
                                     data = training_part_floor_B2,     # train data partition
                                     method = "C5.0",                        # type of model
                                     preProc = c("center", "scale"),         # normalization
                                     tuneLength = 10,                        # how many Ks
                                     trControl = ctrl,
                                     metric = "Accuracy"

)

training_C5.0_floor_build_2



# Test dataset
C5.0_pred_floor_build_2 <- predict(training_C5.0_floor_build_2, testing_part_floor_B2)

#Results testset
postResample(C5.0_pred_floor_build_2, testing_part_floor_B2$FLOOR)
#model  winnow  trials  Accuracy   Kappa
#rules  FALSE   90      0.9707778  0.9608399







#### VALIDATION SET ####

floor_B2_validation <- validation

# Substitute BuildingID data by the predicted BuildingID
floor_B2_validation$BUILDINGID <- svm3_validation_building

# Test to check if it was substituted 
sum(validation$BUILDINGID != floor_B2_validation$BUILDINGID)
names(floor_B2_validation)

# Selects only building 2 from validation dataset
floor_B2_validation <- floor_B2_validation %>% 
  filter(BUILDINGID == 2)


# Removes columns in the validation set to match training set
floor_B2_validation <- floor_B2_validation[ , which(names(floor_B2_validation) %in% names(testing_part_floor_B2))]




#View(head(building_validation))

# Check number of columns
ncol(testing_part_floor_B2)
ncol(floor_B2_validation)
nrow(testing_part_floor_B2)
nrow(floor_B2_validation)
names(testing_part_floor_B2)
names(floor_B2_validation)
glimpse(floor_B2_validation)



# Predicts validation set using SVM
svm_validation_floor_B2 <- predict(training_svm_floor_B2, floor_B2_validation)

postResample(svm_validation_floor_B2, floor_B2_validation$FLOOR)
# Accuracy     Kappa 
# 0.8619403    0.8110158 

