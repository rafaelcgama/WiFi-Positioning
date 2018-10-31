#+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=+
#### TRAINING MODEL - BUILDING ####
#+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=+


#### InTrain for Building ####
inTrain_building <- createDataPartition(
  y = training_sampled$BUILDINGID,
  p = 0.75,
  list = FALSE
)


building_index <- grep("BUILDINGID", colnames(training_sampled))

#### Training and Testing partition for Building ####
training_part_building <- training_sampled[ inTrain_building, ][ ,c(1:(ncol(training_sampled) - 10), building_index)]
testing_part_building <- training_sampled[-inTrain_building, ][ ,c(1:(ncol(training_sampled) - 10), building_index)]

names(training_part_building)
nrow(training_part_building)
ncol(training_part_building)
3000*.75
#View(head(training_part_building))


#+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=+
#### TRAIN/TEST MODELS ####
#+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=+

set.seed(123)

#system.time() to check how long it takes to run 

##### Set the k-fold cross validation ####
ctrl <- trainControl(method = "repeatedcv",
                     number = 10,
                     repeats = 3,
                    )


#### MODELS FOR BUILDING ####


#### KNN ####
training_knn_building <- train(BUILDINGID ~ . ,
                            data = training_part_building,          # train data partition
                            method = "knn",                         # type of model
                            preProc = c("center", "scale"),         # normalization
                            tuneLength = 10,                        # how many Ks
                            trControl = ctrl,
                            metric = "Accuracy"

)

training_knn_building

# RESULTS:
# k   Accuracy   Kappa
# 5  0.9839978  0.9754418



# Test dataset
knn_pred_building <- predict(training_knn_building, testing_part_building)

#Results testset
postResample(knn_pred_building, testing_part_building$BUILDINGID)
# Accuracy     Kappa
# 0.9786667 0.9672629




#### SVM ####
training_svm_building <- train(BUILDINGID ~ . ,
                            data = training_part_building,                # train data partition
                            method = "svmLinear",                         # type of model
                            preProc = c("center", "scale"),               # normalization
                            tuneLength = 10,                              # how many Ks
                            trControl = ctrl,
                            metric = "Accuracy"

)

training_svm_building
# Train result
# Accuracy    Kappa
# 1           1



svm_pred_building <- predict(training_svm_building, testing_part_building)

postResample(svm_pred_building, testing_part_building$BUILDINGID)
# Normalized by Row
# Accuracy    Kappa
# 1           1


#### SVM3 ####
training_svm3_building <- train(BUILDINGID ~ . ,
                               data = training_part_building,           # train data partition
                               method = "svmLinear3",                   # type of model
                               preProc = c("center", "scale"),          # normalization
                               tuneLength = 10,                         # how many Ks
                               trControl = ctrl,
                               metric = "Accuracy"
                               
)
#Test Results:
# cost    Loss  Accuracy   Kappa    
# 0.25  L1    1.0000000  1.0000000



svm3_pred_building <- predict(training_svm3_building, testing_part_building)

postResample(svm3_pred_building, testing_part_building$BUILDINGID)
# Accuracy    Kappa 
# 1           1 
 
 
 
 
 
# #### C5.0 ####
system.time(training_c5.0_building <- train(BUILDINGID ~ . ,
                                data = training_part_building,           # train data partition
                                method = "C5.0",                        # type of model
                                preProc = c("center", "scale"),          # normalization
                                tuneLength = 10,                         # how many Ks
                                trControl = ctrl,
                                metric = "Kappa"

))
# Test result
# model   winnow trials  Accuracy   Kappa
# rules   TRUE   20      0.9995556  0.9993150



c5.0_pred_building <- predict(training_c5.0_building, testing_part_building)

postResample(c5.0_pred_building, testing_part_building$BUILDINGID)
#model  winnow  trials  Accuracy   Kappa
#rules  FALSE   80      0.9939298  0.9906624






#+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=+
#### VALIDATION SET ####
#+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=++=+=+=+=+=+=+=+=++=+

# Removes columns in the validation set to match training set
building_validation <- validation[ , which(names(validation) %in% names(testing_part_building))]


# Check number of columns
ncol(testing_part_building)
ncol(building_validation)
nrow(testing_part_building)
nrow(building_validation)
names(testing_part_building)
names(building_validation)
glimpse(building_validation)

sum(names(testing_part_building) != names(building_validation))


# # Predicts validation set using SVM
# svm_validation_building <- predict(training_svm_building, building_validation)
# 
# postResample(svm_validation_building, building_validation$BUILDINGID)
# # Accuracy     Kappa 
# # 0.9954914 0.9928696



# Predicts validation set using SVM3
svm3_validation_building <- predict(training_svm3_building, building_validation)

postResample(svm3_validation_building, building_validation$BUILDINGID)
# Accuracy    Kappa 
# 1           1





