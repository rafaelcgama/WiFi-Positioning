# **Wi-Fi Positioning**
![](/images/dom_jaime.png)

## _Objective_
The goal of this project is to explore the [UJIIndoorLoc](https://archive.ics.uci.edu/ml/datasets/ujiindoorloc) dataset provided by the **UC Irvine Machine Learning Repository** and apply machine learning techniques to predict the location of a user in a university campus based on the intensity of the signals received by different wireless access points across campus from the user's Wi-Fi device.

## _Background_

Many real world applications need to know the localization of a user in the world to provide their services. Therefore, automatic user localization has been a hot research topic in the last years. Automatic user localization consists of estimating the position of the user (latitude, longitude and altitude) by using an electronic device, usually a mobile phone. Outdoor localization problem can be solved very accurately thanks to the inclusion of GPS sensors into the mobile devices. However, indoor localization is still an open problem mainly due to the loss of GPS signal in indoor environments. Although, there are some indoor positioning technologies and methodologies, this database is focused on WLAN fingerprint-based ones (also know as Wi-Fi Fingerprinting). 

## _Dataset_

The UJIIndoorLoc database covers three buildings of Universitat Jaume I, in Spain, with 4 or 5 floors. It was created in 2013 by means of more than 20 different users and 25 Android devices. The database consists of 2 files, one containing 19937 training/reference records `trainingData.csv` and other containing 1111 validation/test records `validationData.csv`. Both sets are composed  of 529 attributes that are described below:


### Attribute Information:

* **Attribute 001 (WAP001) - 520 (WAP520)**: Negative integer values from -104 to 0 and +100. Positive value 100 used if signal was not detected. The closer to zero the better.
* **Attribute 521 (Longitude)**: Longitude. Negative real values from -7695.9387549299299000 to -7299.786516730871000 
* **Attribute 522 (Latitude)**: Latitude. Positive real values from 4864745.7450159714 to 4865017.3646842018. 
* **Attribute 523 (Floor)**: Altitude in floors inside the building. Integer values from 0 to 4. 
* **Attribute 524 (BuildingID)**: ID to identify the building. Measures were taken in three different buildings. Categorical integer values from 0 to 2. 
* **Attribute 525 (SpaceID)**: Internal ID number to identify the Space (office, corridor, classroom) where the capture was taken. Categorical integer values. 
* **Attribute 526 (RelativePosition)**: Relative position with respect to the Space (1 - Inside, 2 - Outside in Front of the door). Categorical integer values. 
* **Attribute 527 (UserID)**: User identifier (see below). Categorical integer values. 
* **Attribute 528 (PhoneID)**: Android device identifier (see below). Categorical integer values. 
* **Attribute 529 (Timestamp)**: UNIX Time when the capture was taken. Integer value. 


## _**Data Preparation**_

Before the machine learning models were applied to the dataset, a few modifications were made to the dataset in order to make it more concise and remove noise. The main ones are described below:

* **Converted low and undetected signals to -100**: all undetected signals (value 100) and signal below -90 were converted to -100 to bring consistency  to very bad signals.
* **Removed all WAPs (column) and records (row) with zero variance values**: If a WAP does not detect signal strengths  variations is not useful to make predictions. Same rationale  applies to instances that always provide the same signal to all WAPs.
* **Removed all Users with duplicate signal footprint**: It is needless to have more than one observations stating the same thing.
* **Converted signals higher than -30 to -100**: Signals higher than -30 are considered prefect but they are not typical or desirable in the real world so they were considered errors and modified to -100(very bad signal)
* **Removed User 6**: User 6 appears in 976 records of which 430 are between -30 and 0, which means that his device was probably buggy or had some sort of compatibility issue.
* **Normalized by row**: Dataset was normalized by row, columns and by overall values but the normalization by row was used for the modeling as it generated better results.
* **3000 records were sampled to apply the models**: Out of the 19937 records, 3000 were sampled and then partitioned into training/testing sets on a 75/25 ratio.


## _**Results**_

### _**Building and Floor**_

The first step was to train models to predict the just the building based on the WAPs signal strength. Once the building was predicted, those results were added to the dataset and then the data was filtered by building in order to predict the floor in that particular building. The results for the training and validation sets were as follow:


|                    | KNN   | SVM   | SVM3  | C.50  |
|--------------------|-------|-------|-------|-------|
| Building           | 0.984 | 1.000 | 1.000 | 0.999 |
| Floor - Building 0 | 0.948 | 0.976 | 0.948 | 0.970 |
| Floor - Building 1 | 0.959 | 1.000 | 0.984 | 0.970 |
| Floor - Building 2 | 0.950 | 0.982 | 0.979 | 0.970 |



As we can see, we achieved a 100% prediction for the building and SVM yielded the best floor results in the training/validation phase. Therefore, it was the model selected to move to the test phase and it achieved the following success  rates:

![](/images/floor_results2.PNG)


### _**Latitude and Longitude**_

To predict Latitude and Longitude, the same steps used to build the models for the Building and Floor were applied. The only difference was that some parameters were modified in order to reflect the regression nature of this prediction. First we predicted the Lat & Long for the whole campus based on the WAP signal strength and then we reapplied the models filtering the data by building as we did previously. The follow results were achieved:


| RSME                   | KNN   | SVM    | SVM3      |
|------------------------|-------|--------|-----------|
| LATITUDE               | 7.068 | 18.867 | 4.861E+06 |
| LONGITUDE              | 6.646 | 32.197 | 7.470E+03 |
|                        |       |        |           |
| LATITUDE - BUILDING 0  | 6.101 | 10.180 | 4.867E+06 |
| LONGITUDE - BUILDING 0 | 5.490 | 12.042 | 7.653E+03 |
|                        |       |        |           |
| LATITUDE - BUILDING 1  | 7.068 | 12.608 | 4.861E+06 |
| LONGITUDE - BUILDING 1 | 7.769 | 14.149 | 7.485E+03 |
|                        |       |        |           |
| LATITUDE - BUILDING 2  | 7.484 | 14.175 | 4.862E+06 |
| LONGITUDE - BUILDING 2 | 7.235 | 14.671 | 7.36E+03  |


This time the KNN performed significantly better than the other models, hence it was the one chosen to be applied to the test set. After we collected the results of the Lat & Long predictions, the Euclidian distance between the actual and predicted geographic coordinates was calculated in order to get the amount of error in each prediction, as well as the mean and the median of all points. Now let's plot the actual and the predicted coordinates and compare them:

![](/images/actual.jpg)


![](/images/predicted.jpg)

As we can see, the shape of the 2 plots are fairly similar which means that we achieved a decent degree of accuracy in our model.  
