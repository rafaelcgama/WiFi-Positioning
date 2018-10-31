#+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=+
#### TRAINING MODEL - FLOOR - BUILDING 0 ####
#+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=+



# Group dataset by building
training_sampled_B0 <- training_sampled %>% 
  filter(BUILDINGID == 0)

nrow(training_sampled_B0)

# Refactor Floor because there are 5 levels(4 floors) but building 0 and 1 have only 4 floors 
training_sampled_B0$FLOOR <- factor(training_sampled_B0$FLOOR)


#### inTrain for Floor ####
inTrain_floor_B0 <- createDataPartition(
  y = training_sampled_B0$FLOOR,
  p = 0.75,
  list = FALSE
)

floor_index <- grep("FLOOR", colnames(training_sampled_B0))

#### Training and Testing partition for Floor 0 ####
training_part_floor_B0 <- training_sampled_B0[ inTrain_floor_B0, ][ , c(1:(ncol(training_sampled_B0) - 10), floor_index)]
testing_part_floor_B0 <- training_sampled_B0[-inTrain_floor_B0, ][ , c(1:(ncol(training_sampled_B0) - 10), floor_index)]

nrow(training_part_floor_B0)

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
training_knn_floor_B0 <- train(FLOOR ~ . ,
                            data = training_part_floor_B0,          # train data partition
                            method = "knn",                         # type of model
                            preProc = c("center", "scale"),         # normalization
                            tuneLength = 10,                        # how many Ks
                            trControl = ctrl,
                            metric = "Accuracy"

)

training_knn_floor_B0
#k   Accuracy   Kappa
#5  0.9278924  0.9033854


# Test dataset
knn_pred_floor_B0 <- predict(training_knn_floor_B0, testing_part_floor_B0)

#Results testset
postResample(knn_pred_floor_B0, testing_part_floor_B0$FLOOR)
# Accuracy    Kappa 
# 0.947619 0.929783 




#### SVM ####
training_svm_floor_B0 <- train(FLOOR ~ . ,
                                    data = training_part_floor_B0,          # train data partition
                                    method = "svmLinear",                   # type of model
                                    preProc = c("center", "scale"),         # normalization
                                    tuneLength = 10,                        # how many Ks
                                    trControl = ctrl,
                                    metric = "Accuracy"
                                    
)

training_svm_floor_B0
# Accuracy  Kappa   
# 0.98314   0.977425

# Test dataset 
svm_pred_floor_B0 <- predict(training_svm_floor_B0, testing_part_floor_B0)

#Results testset 
postResample(svm_pred_floor_B0, testing_part_floor_B0$FLOOR)
# Accuracy     Kappa 
# 0.9761905 0.9681122







# #### SVM3 ####
training_svm3_floor_B0 <- train(FLOOR ~ . ,
                                    data = training_part_floor_B0,          # train data partition
                                    method = "svmLinear3",                  # type of model
                                    preProc = c("center", "scale"),         # normalization
                                    tuneLength = 10,                        # how many Ks
                                    trControl = ctrl,
                                    metric = "Accuracy"

)

training_svm3_floor_B0
# cost    Loss  Accuracy   Kappa    
# 0.25  L1    0.9720788  0.9625571


# Test dataset
svm3_pred_floor_B0 <- predict(training_svm3_floor_B0, testing_part_floor_B0)

#Results testset
postResample(svm3_pred_floor_B0, testing_part_floor_B0$FLOOR)
#Accuracy     Kappa 
#0.9476190 0.9297595









#### C5.0 ####
training_C5.0_floor_build_0 <- train(FLOOR ~ . ,
                                     data = training_part_floor_B0,     # train data partition
                                     method = "C5.0",                        # type of model
                                     preProc = c("center", "scale"),         # normalization
                                     tuneLength = 10,                        # how many Ks
                                     trControl = ctrl,
                                     metric = "Accuracy"

)





# # Test dataset 
C5.0_pred_floor_build_0 <- predict(training_C5.0_floor_build_0, testing_part_floor_B0)

# #Results testset 
postResample(C5.0_pred_floor_build_0, testing_part_floor_B0$FLOOR)
# #model  winnow  trials  Accuracy   Kappa 
# #rules  FALSE   90      0.9707778  0.9608399







#### VALIDATION SET ####

floor_B0_validation <- validation

# Substitute BuildingID data by the predicted BuildingID
floor_B0_validation$BUILDINGID <- svm3_validation_building


# Test to check if it was substituted 
sum(validation$BUILDINGID != floor_B0_validation$BUILDINGID)
names(floor_B0_validation)

# Selects only building 0 from validation dataset
floor_B0_validation <- floor_B0_validation %>% 
  filter(BUILDINGID == 0)


# Removes columns in the validation set to match training set
floor_B0_validation <- floor_B0_validation[ , which(names(floor_B0_validation) %in% names(testing_part_floor_B0))]




#View(head(building_validation))

# Check number of columns
ncol(testing_part_floor_B0)
ncol(floor_B0_validation)
nrow(testing_part_floor_B0)
nrow(floor_B0_validation)
names(testing_part_floor_B0)
names(floor_B0_validation)
glimpse(floor_B0_validation)


# Predicts validation set using SVM
svm_validation_floor_B0 <- predict(training_svm_floor_B0, floor_B0_validation)

postResample(svm_validation_floor_B0, floor_B0_validation$FLOOR)
# Accuracy     Kappa 
# 0.9458955 0.9236782
