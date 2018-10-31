#+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=+
#### TRAINING MODEL - FLOOR ####
#+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=+

#### inTrain for Floor ####
inTrain_floor <- createDataPartition(
  y = training_sampled$FLOOR,
  p = 0.75,
  list = FALSE
)

floor_index <- grep("FLOOR", colnames(training_sampled))

#### Training and Testing partition for Floor ####
training_part_floor <- training_sampled[ inTrain_floor, ][ ,c(1:(ncol(training_sampled) - 10), floor_index)]
testing_part_floor <- training_sampled[-inTrain_floor, ][ ,c(1:(ncol(training_sampled) - 10), floor_index)]


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


# #### KNN ####
# training_knn_floor <- train(FLOOR ~ . ,
#                                data = training_part_floor,             # train data partition
#                                method = "knn",                         # type of model
#                                preProc = c("center", "scale"),         # normalization
#                                tuneLength = 10,                        # how many Ks
#                                trControl = ctrl,
#                                metric = "Accuracy"
#                                
# )
# 
# training_knn_floor
# #k   Accuracy   Kappa    
# #5  0.9357530  0.9150870
# 
# 
# # Test dataset 
# knn_pred_floor <- predict(training_knn_floor, testing_part_floor)
# 
# #Results testset 
# postResample(knn_pred_floor, testing_part_floor$FLOOR)
# #Accuracy     Kappa 
# #0.9358289    0.9151025




#### SVM ####
system.time(training_svm_floor <- train(FLOOR ~ . ,
                            data = training_part_floor,             # train data partition
                            method = "svmLinear",                   # type of model
                            preProc = c("center", "scale"),         # normalization
                            tuneLength = 10,                        # how many Ks
                            trControl = ctrl,
                            metric = "Accuracy"
                            
))

training_svm_floor
#user  system elapsed 
#34.46    3.15   38.00

# Accuracy   Kappa    
# 0.9845963  0.9796558

# Test dataset 
svm_pred_floor <- predict(training_svm_floor, testing_part_floor)

#Results testset 
postResample(svm_pred_floor, testing_part_floor$FLOOR)
# Accuracy     Kappa 
# 0.9866489    0.9823584 






# #### SVM3 ####
# system.time(training_svm3_floor <- train(FLOOR ~ . ,
#                             data = training_part_floor,             # train data partition
#                             method = "svmLinear3",                  # type of model
#                             preProc = c("center", "scale"),         # normalization
#                             tuneLength = 10,                        # how many Ks
#                             trControl = ctrl,
#                             metric = "Accuracy"
#                             
# ))
# #user  system elapsed 
# #1440.31   43.23 1494.08
# 
# 
# training_svm3_floor
# #cost    Loss  Accuracy   Kappa    
# #0.25    L1    0.9652201  0.9540260
# 
# # Test dataset 
# svm3_pred_floor <- predict(training_svm3_floor, testing_part_floor)
# 
# #Results testset 
# postResample(svm3_pred_floor, testing_part_floor$FLOOR)
# #Accuracy     Kappa 
# #0.9665775 0.9558102 
# 
# 
# 
# 
# 
# #### C.05 ####
# training_c5.0_floor <- train(FLOOR ~ . ,
#                              data = training_part_floor,             # train data partition
#                              method = "C5.0",                        # type of model
#                              preProc = c("center", "scale"),         # normalization
#                              tuneLength = 10,                        # how many Ks
#                              trControl = ctrl,
#                              metric = "Accuracy"
#                              
# )
# 
# training_c5.0_floor
# 
# 
# 
# 
# # Test dataset 
# c5.0_pred_floor <- predict(training_c5.0_floor, testing_part_floor)
# 
# 
# 
# #Results testset 
# postResample(c5.0_pred_floor, testing_part_floor$FLOOR)











#### VALIDATION SET ####


floor_validation <- validation

# Substitute BuildingID data by the predicted BuildingID
floor_validation$BUILDINGID <- svm3_validation_building


# Test to check if it was substituted 
sum(validation$BUILDINGID != floor_validation$BUILDINGID)
names(floor_validation)


# Removes columns in the validation set to match training set
floor_validation <- floor_validation[ , which(names(floor_validation) %in% names(testing_part_floor))]



#View(head(building_validation))

# Check number of columns
ncol(testing_part_floor)
ncol(floor_validation)
nrow(testing_part_floor)
nrow(floor_validation)
names(testing_part_floor)
names(floor_validation)
glimpse(floor_validation)



# Predicts validation set using SVM
svm_validation_floor <- predict(training_svm_floor, floor_validation)

postResample(svm_validation_floor, floor_validation$FLOOR)
# Accuracy     Kappa 
# 0.8818756    0.8355665 
