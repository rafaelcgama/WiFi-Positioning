lat_long_name <- c("LAT", "LONG", "LAT_PRED", "LONG_PRED")

distance_pred_error <- function (data) {
  long <- (data["LONG"] - data["LONG_PRED"])
  lat <- (data["LAT"]- data["LAT_PRED"])
  d = sqrt((long^2) + (lat^2))
  return (d)
  }



#### LATITUDE/LONGITUDE ####
lat_long <- validation %>% 
  select(LATITUDE, LONGITUDE)

lat_long <- cbind(lat_long, knn_validation_latitude, knn_validation_longitude)
colnames(lat_long) <- lat_long_name
names(lat_long)

lat_long <- lat_long %>% 
  mutate(ERROR = apply(lat_long, 1, distance_pred_error))

summary(lat_long$ERROR)

lat_long$BUILDINGID <- validation$BUILDINGID

ggplot() + 
  geom_histogram(data=lat_long, aes(x=ERROR), bins = 50) +
  xlim(0,50)


# Actual Building coordenates
ggplot() + 
  geom_point(data=lat_long, aes(x=LONG, y=LAT, color=BUILDINGID)) +
  ggtitle('Actual Coordinates') + 
  xlab('LONGITUDE') +
  ylab('LATITUDE') + 
  theme(plot.title = element_text(hjust = 0.5))

#Predicted Building corrdenates
ggplot() + 
  geom_point(data=lat_long, aes(x=LONG_PRED, y=LAT_PRED, color=BUILDINGID)) +
  ggtitle('Predicted Coordinates') + 
  xlab('LONGITUDE') +
  ylab('LATITUDE') + 
  theme(plot.title = element_text(hjust = 0.5))

  







#### LATITUDE/LONGITUDE - BULDING 0 ####
lat_long_B0 <- validation %>% 
  filter(BUILDINGID == 0) %>% 
  select(LATITUDE, LONGITUDE) 

lat_long_B0 <- cbind(lat_long_B0, knn_validation_latitude_B0, knn_validation_longitude_B0)
colnames(lat_long_B0)<- lat_long_name

lat_long_B0 <- lat_long_B0 %>% 
  mutate(ERROR = apply(lat_long_B0, 1, distance_pred_error))

summary(lat_long_B0$ERROR)

ggplot() + 
  geom_histogram(data=lat_long_B0, aes(x=ERROR), bins = 50) +
  xlim(0,50)

ggplot() +
  geom_point(data = lat_long_B0, aes(x=LONG_PRED, y=LAT_PRED, color='Building 0'))








#### LATITUDE/LONGITUDE - BULDING 1 ####
lat_long_B1 <- validation %>% 
  filter(BUILDINGID == 1) %>% 
  select(LATITUDE, LONGITUDE)

lat_long_B1 <- cbind(lat_long_B1, knn_validation_latitude_B1, knn_validation_longitude_B1)
colnames(lat_long_B1)<- lat_long_name

lat_long_B1 <- lat_long_B1 %>% 
  mutate(ERROR = apply(lat_long_B1, 1, distance_pred_error))


#View(lat_long_B1)
summary(lat_long_B1$ERROR)

ggplot() + 
  geom_histogram(data=lat_long_B1, aes(x=ERROR), bins = 50) +
  xlim(0,50)

ggplot() +
  geom_point(data = lat_long_B1, aes(x=LONG_PRED, y=LAT_PRED, color='Building 1'))




#### LATITUDE/LONGITUDE - BULDING 2 ####
lat_long_B2 <- validation %>% 
  filter(BUILDINGID == 2) %>% 
  select(LATITUDE, LONGITUDE)

lat_long_B2 <- cbind(lat_long_B2, knn_validation_latitude_B2, knn_validation_longitude_B2)
colnames(lat_long_B2)<- lat_long_name

lat_long_B2 <- lat_long_B2 %>% 
  mutate(ERROR = apply(lat_long_B2, 1, distance_pred_error))

#View(lat_long_B1)
summary(lat_long_B2$ERROR)


ggplot() + 
  geom_histogram(data=lat_long_B2, aes(x=ERROR), bins = 50) +
  xlim(0,50)


ggplot() +
  geom_point(data = lat_long_B2, aes(x=LONG_PRED, y=LAT_PRED, color='Building 2'))




