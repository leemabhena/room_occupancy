library(readr)
library(tidyverse)
library(lubridate)
library(ggplot2)
library(corrplot)
library(MANOVA.RM)
library(DescTools)

# Read in the data
occupancy <- read_csv("Occupancy_Estimation.csv")

# Get the data summary
summary(occupancy)

# View the first few rows
head(occupancy)

# Inspect the data
str(occupancy)
dim(occupancy)

# Combine Date and Time into a single datetime column
occupancy <- occupancy %>%
  mutate(DateTime = as.POSIXct(paste(Date, Time)))

# Remove the original Date and Time columns
occupancy <- occupancy %>%
  select(-Date, -Time)

# Check for missing values
colSums(is.na(occupancy))

##########################################################
# Exploratory Data Analysis
##########################################################

# Melt the temperature data for plotting
temp_data <- occupancy %>%
  select(DateTime, starts_with("S")) %>%
  select(DateTime, contains("Temp")) %>%
  filter(DateTime <= ymd_hms("2017-12-27 00:00:00")) %>%
  gather(key = "Sensor", value = "Temperature", -DateTime)

# Plot
ggplot(temp_data, aes(x = DateTime, y = Temperature, color = Sensor)) +
  geom_line() +
  theme_minimal() +
  labs(title = "Temperature Readings Over Time", x = "DateTime", y = "Temperature (°C)")


# Melt the light data for plotting
light_data <- occupancy %>%
  select(DateTime, starts_with("S")) %>%
  select(DateTime, contains("Light")) %>%
  filter(DateTime <= ymd_hms("2017-12-27 00:00:00")) %>%
  gather(key = "Sensor", value = "Light", -DateTime)

# Plot
ggplot(light_data, aes(x = DateTime, y = Light, color = Sensor)) +
  geom_line() +
  theme_minimal() +
  labs(title = "Light Sensor Readings Over Time", x = "DateTime", y = "Light Level")

# Melt the sound data for plotting
sound_data <- occupancy %>%
  select(DateTime, starts_with("S")) %>%
  select(DateTime, contains("Sound")) %>%
  filter(DateTime <= ymd_hms("2017-12-27 00:00:00")) %>%
  gather(key = "Sensor", value = "Sound", -DateTime)

# Plot
ggplot(sound_data, aes(x = DateTime, y = Sound, color = Sensor)) +
  geom_line() +
  theme_minimal() +
  labs(title = "Sound Sensor Readings Over Time", x = "DateTime", y = "Sound Level")


# Histogram of Room Occupancy Count
ggplot(occupancy, aes(x = Room_Occupancy_Count)) +
  geom_histogram(binwidth = 1, fill = "skyblue", color = "black") +
  theme_minimal() +
  labs(title = "Distribution of Room Occupancy Count", x = "Occupancy Count", y = "Frequency")

# Boxplots for all numeric columns
occupancy %>%
  select(where(is.numeric)) %>%
  pivot_longer(cols = everything()) %>%
  ggplot(aes(x = name, y = value)) +
  geom_boxplot(fill = "orange", alpha = 0.7) +
  coord_flip() +
  labs(title = "Univariate Analysis - Boxplots", x = "Variable", y = "Value")

# Boxplots of Room Occupancy Count vs Other Variables
occupancy %>% select(where(is.numeric))  %>%
  pivot_longer(cols = -Room_Occupancy_Count) %>%
  ggplot(aes(x = as.factor(Room_Occupancy_Count), y = value, fill = as.factor(Room_Occupancy_Count))) +
  geom_boxplot() +
  facet_wrap(~ name, scales = "free") +
  labs(
    title = "Bivariate Analysis - Room Occupancy Count vs Variables", 
    x = "Room Occupancy Count", y = "Value", fill = "R.O.C"
    )


##########################################################
# PCA Analysis
##########################################################

numeric_variables <- occupancy[, -c(1, 2, ncol(occupancy))]
pca_results <- prcomp(numeric_variables, scale. = TRUE)
summary(pca_results)

# Screeplot of the PCA
plot(pca_results, type = "l", main = "Scree Plot - Correlation PCA")

# Check the loadings
par(mfrow=c(1,2))
for (i in 1:5) {
  barplot(pca_results$rotation[, i], las = 2, main = paste("PC", i, sep = ""))
}


# Extract the first 5 principal components
pca_data <- as.data.frame(pca_results$x[, 1:5])

##############################################################
# MANOVA using the PCAs
##############################################################

pca_data$Room_Occupancy_Count <- occupancy$Room_Occupancy_Count

grouped_means_pca <- pca_data %>%
  group_by(Room_Occupancy_Count) %>%
  summarise(
    Mean_PC1 = mean(PC1, na.rm = TRUE),
    Mean_PC2 = mean(PC2, na.rm = TRUE),
    Mean_PC3 = mean(PC3, na.rm = TRUE),
    Mean_PC4 = mean(PC4, na.rm = TRUE), 
    Mean_PC5 = mean(PC5, na.rm = TRUE)
  )
grouped_means_pca

grouped_means_long_pca <- grouped_means_pca %>%
  pivot_longer(
    cols = starts_with("Mean_"),
    names_to = "Sensor_Type",
    values_to = "Mean_Value"
  )

# Plot the data
ggplot(grouped_means_long_pca, aes(x = Room_Occupancy_Count, y = Mean_Value, color = Sensor_Type, group = Sensor_Type)) +
  geom_line() +
  geom_point(size = 3) +
  labs(
    x = "Room Occupancy Count",
    y = "Mean Value",
    title = "Grouped Means of Sensors by Room Occupancy Count",
    color = "Sensor Type"
  ) +
  theme_minimal()

# Reshape the dataset to long format for faceting
data_long_pca <- pca_data %>%
  pivot_longer(
    cols = c(PC1, PC2, PC3, PC4, PC5),
    names_to = "Sensor_Type",
    values_to = "Sensor_Value"
  )

ggplot(data_long_pca, aes(x = as.factor(Room_Occupancy_Count), y = Sensor_Value, fill = as.factor(Room_Occupancy_Count))) +
  geom_boxplot() +
  facet_wrap(~Sensor_Type, scales = "free_y") +
  labs(
    x = "Room Occupancy Count",
    y = "Sensor Values",
    title = "Sensor Value Distribution by Room Occupancy Count",
    fill = "Occupancy Count"
  ) +
  theme_minimal() +
  theme(
    strip.text = element_text(size = 12),
    axis.text = element_text(size = 10) 
  )

# Conduct MANOVA
manova_result_pca <- MANOVA.wide(
  formula = cbind(PC1, PC2, PC3, PC4, PC5) ~ Room_Occupancy_Count,
  data = pca_data,
  iter = 1000, # Number of resampling iterations
  resampling = "paramBS", # Resampling method (e.g., parametric bootstrap)
  alpha = 0.05
)

# View a summary of the results
summary(manova_result_pca)

# Perform pairwise comparisons using simCI()
pairwise_results <- simCI(
  object = manova_result_pca,  # Your MANOVA result object
  contrast = "pairwise",  # Specifies pairwise comparisons
  type = "Tukey"          # Tukey's method for pairwise comparisons
)

# View results
pairwise_results

# Example visualization of pairwise differences
pairwise_df <- as.data.frame(pairwise_results)
pairwise_df$Comparison <- rownames(pairwise_df)

# Create a plot for the confidence intervals
ggplot(pairwise_df, aes(x = Comparison, y = Estimate, ymin = Lower, ymax = Upper)) +
  geom_pointrange() +
  coord_flip() +
  labs(title = "Pairwise Comparisons with Confidence Intervals",
       x = "Comparison", y = "Difference in Means") +
  theme_minimal()

# Ensure Room_Occupancy_Count is a factor
pca_data$Room_Occupancy_Count <- as.factor(pca_data$Room_Occupancy_Count)

# Perform ANOVA for each numeric sensor column
aov.list <- lapply(pca_data[ , c("PC1", "PC2", "PC3", "PC4", "PC5")], 
                   function(x) aov(x ~ Room_Occupancy_Count, data = pca_data))

# Check if all ANOVA models are valid
print(aov.list)

# Perform Post-Hoc tests
multi.comp <- lapply(aov.list, PostHocTest, method = "bonferroni", conf.level = 0.99)

par(mfrow=c(2, 2))
lapply(multi.comp, plot, las=2)

##########################################################
# MANOVA by averaging the same types of sensors
##########################################################

# Downsampling the larger dataset
class0 <- occupancy[occupancy$Room_Occupancy_Count == 0, ]
class1 <- occupancy[occupancy$Room_Occupancy_Count == 1, ]
class2 <- occupancy[occupancy$Room_Occupancy_Count == 2, ]
class3 <- occupancy[occupancy$Room_Occupancy_Count == 3, ]

# Calculate the minimum class size
#min_size <- min(table(occupancy$Room_Occupancy_Count))
min_size = 700

# Undersample majority classes
set.seed(123)
class0_under <- class0[sample(1:nrow(class0), min_size), ]
class1_under <- class1
class2_under <- class2
class3_under <- class3

# Combine all classes
balanced_data <- rbind(class0_under, class1_under, class2_under, class3_under)

# Shuffle the data
balanced_data <- balanced_data[sample(1:nrow(balanced_data)), ]

# Check the new class distribution
prop.table(table(balanced_data$Room_Occupancy_Count))

# Agregate the data, using averages of each of the sensors
new_dataset <- balanced_data %>%
  mutate(
    Temp_Sensor = rowMeans(select(., S1_Temp, S2_Temp, S3_Temp, S4_Temp), na.rm = TRUE),
    Light_Sensor = rowMeans(select(., S1_Light, S2_Light, S3_Light, S4_Light), na.rm = TRUE),
    Sound_Sensor = rowMeans(select(., S1_Sound, S2_Sound, S3_Sound, S4_Sound), na.rm = TRUE),
    CO2_Sensor = S5_CO2  # Use S5_CO2 directly as there is only one CO2 sensor
  ) %>%
  select(Date, Time, Temp_Sensor, Light_Sensor, Sound_Sensor, CO2_Sensor, Room_Occupancy_Count)

# View the new dataset
head(new_dataset)

grouped_means <- new_dataset %>%
  group_by(Room_Occupancy_Count) %>%
  summarise(
    Mean_Temp_Sensor = mean(Temp_Sensor, na.rm = TRUE),
    Mean_Light_Sensor = mean(Light_Sensor, na.rm = TRUE),
    Mean_Sound_Sensor = mean(Sound_Sensor, na.rm = TRUE),
    Mean_CO2_Sensor = mean(CO2_Sensor, na.rm = TRUE)
  )
grouped_means

# Plot the means to see the trend
grouped_means_long <- grouped_means %>%
  pivot_longer(
    cols = starts_with("Mean_"),
    names_to = "Sensor_Type",
    values_to = "Mean_Value"
  )

# Plot the data
ggplot(grouped_means_long, aes(x = Room_Occupancy_Count, y = Mean_Value, color = Sensor_Type, group = Sensor_Type)) +
  geom_line() +
  geom_point(size = 3) +
  labs(
    x = "Room Occupancy Count",
    y = "Mean Value",
    title = "Grouped Means of Sensors by Room Occupancy Count",
    color = "Sensor Type"
  ) +
  theme_minimal()

# Reshape the dataset to long format for faceting
data_long <- new_dataset %>%
  pivot_longer(
    cols = c(Temp_Sensor, Light_Sensor, Sound_Sensor, CO2_Sensor),
    names_to = "Sensor_Type",
    values_to = "Sensor_Value"
  )

ggplot(data_long, aes(x = as.factor(Room_Occupancy_Count), y = Sensor_Value, fill = as.factor(Room_Occupancy_Count))) +
  geom_boxplot() +
  facet_wrap(~Sensor_Type, scales = "free_y") +
  labs(
    x = "Room Occupancy Count",
    y = "Sensor Values",
    title = "Sensor Value Distribution by Room Occupancy Count",
    fill = "Occupancy Count"
  ) +
  theme_minimal() +
  theme(
    strip.text = element_text(size = 12),
    axis.text = element_text(size = 10) 
  )

# Carryout MANOVA
manova_result <- MANOVA.wide(
  formula = cbind(Temp_Sensor, Light_Sensor, Sound_Sensor, CO2_Sensor) ~ Room_Occupancy_Count,
  data = new_dataset,
  iter = 1000, # Number of resampling iterations
  resampling = "paramBS", # Resampling method (e.g., parametric bootstrap)
  alpha = 0.05
)

# View a summary of the results
summary(manova_result)

# Perform pairwise comparisons using simCI()
pairwise_results <- simCI(
  object = manova_result,  # Your MANOVA result object
  contrast = "pairwise",  # Specifies pairwise comparisons
  type = "Tukey"          # Tukey's method for pairwise comparisons
)

# View results
pairwise_results

# Convert pairwise_results to a data frame for plotting
pairwise_df <- as.data.frame(pairwise_results)
pairwise_df$Comparison <- rownames(pairwise_df)

# Create a plot for the confidence intervals
ggplot(pairwise_df, aes(x = Comparison, y = Estimate, ymin = Lower, ymax = Upper)) +
  geom_pointrange() +
  coord_flip() +
  labs(title = "Pairwise Comparisons with Confidence Intervals",
       x = "Comparison", y = "Difference in Means") +
  theme_minimal()

# Ensure Room_Occupancy_Count is a factor
new_dataset$Room_Occupancy_Count <- as.factor(new_dataset$Room_Occupancy_Count)

# Perform ANOVA for each numeric sensor column
aov.list <- lapply(new_dataset[ , c("Temp_Sensor", "Light_Sensor", "Sound_Sensor", "CO2_Sensor")], 
                   function(x) aov(x ~ Room_Occupancy_Count, data = new_dataset))

# Check if all ANOVA models are valid
print(aov.list)

# Perform Post-Hoc tests
multi.comp <- lapply(aov.list, PostHocTest, method = "bonferroni", conf.level = 0.99)

par(mfrow=c(2, 2))
lapply(multi.comp, plot, las=2)
