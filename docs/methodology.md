---
title: "Methodology"
---

## Introduction

The primary objective of this project is to analyze multivariate sensor data to estimate room occupancy counts. Given the high dimensionality of the dataset—with 19 sensor variables potentially correlated with each other—it is essential to employ statistical methods that can reduce dimensionality and address multicollinearity. Two main multivariate statistical approaches were used:

1. **Principal Component Analysis (PCA)** followed by **Multivariate Analysis of Variance (MANOVA)** using the selected principal components.
2. **Aggregation of Sensor Data by Type** (averaging sensors of the same type) followed by **MANOVA** on the aggregated variables.

These methods were chosen to simplify the dataset while preserving the underlying structure necessary for accurate occupancy estimation.


## Approach 1: Principal Component Analysis (PCA) and MANOVA

### Principal Component Analysis (PCA)
#### Rationale
- **Dimensionality Reduction**: PCA transforms a high-dimensional dataset into a lower-dimensional one by identifying the principal components (PCs) that explain the most variance. This simplifies the dataset without significant loss of information.
- **Multicollinearity Mitigation**: By transforming correlated variables into uncorrelated PCs, PCA eliminates issues arising from multicollinearity, which can adversely affect statistical analyses like MANOVA.

#### Application
1. **Data Preparation**: All numeric sensor variables were selected for PCA, excluding the target variable (`Room_Occupancy_Count`) and any non-sensor data.
2. **Performing PCA**: PCA was conducted on standardized sensor data to ensure equal contribution from each variable, regardless of scale.
3. **Selecting Principal Components**: The elbow method (scree plot) determined the appropriate number of PCs to retain, focusing on components explaining a substantial proportion of the variance.
4. **Interpreting Loadings**: The loadings of each PC were examined to understand the contribution of the original variables, aiding in the interpretation of the PCs.


### Multivariate Analysis of Variance (MANOVA)
#### Rationale
- **Testing for Group Differences**: MANOVA assesses statistical differences in the mean vectors of multiple dependent variables (PCs) across levels of an independent variable (`Room_Occupancy_Count`).
- **Handling Non-Normal Data**: The `MANOVA.RM` package was used as it relaxes the assumption of multivariate normality, making it suitable for real-world data.

#### Application
1. **Setting Up the MANOVA**: The selected PCs were used as dependent variables, with `Room_Occupancy_Count` as the independent variable.
2. **Executing MANOVA**: The null hypothesis tested whether there are no differences in the mean vectors of the PCs across occupancy levels.
3. **Post-Hoc Analysis**: Significant effects were followed by post-hoc pairwise comparisons to identify specific differences between occupancy levels.


## Approach 2: Aggregation of Sensor Data by Type and MANOVA

### Data Aggregation by Sensor Type
#### Rationale
- **Simplification**: Averaging sensor readings of the same type (e.g., all temperature sensors) reduces the number of variables while retaining essential information.
- **Focus on Sensor Categories**: This approach emphasizes the overall effect of each sensor type on occupancy estimation, improving interpretability.

#### Application
1. **Averaging Sensor Readings**: Sensor data were aggregated by calculating the mean for sensors within the same category (e.g., Temperature, Light, Sound). CO₂ sensor data were included directly, as there was only one CO₂ sensor.
2. **Addressing Class Imbalance**: Undersampling of the majority class (zero occupancy) ensured balanced representation across occupancy levels.


### Multivariate Analysis of Variance (MANOVA)
#### Rationale
- **Testing Aggregated Effects**: Using aggregated sensor variables as dependent variables in MANOVA assesses the collective impact of each sensor type on occupancy levels.
- **Enhanced Interpretability**: Aggregated data provide clearer insights into how environmental factors affect occupancy.

#### Application
1. **Setting Up the MANOVA**: The averaged sensor variables (Temperature, Light, Sound, CO₂) were used as dependent variables, with `Room_Occupancy_Count` as the independent variable.
2. **Executing MANOVA**: Similar to the first approach, differences in mean vectors across occupancy levels were tested.
3. **Post-Hoc Analysis**: Significant results were followed by post-hoc tests to explore specific differences between groups.
   

## Comparison and Justification of Methods

1. **Choice of PCA and MANOVA**:
   - PCA was chosen for its ability to reduce dimensionality and address multicollinearity, which is vital when handling numerous correlated variables.
   - MANOVA was selected because it can test for differences across multiple dependent variables simultaneously, providing a comprehensive understanding of how sensor data relates to occupancy levels.

2. **Aggregation Approach**:
   - The second approach simplifies the dataset further and focuses on broader categories of sensor data. This enhances interpretability and facilitates practical applications where understanding the impact of each sensor type is beneficial.

3. **Use of Non-Parametric MANOVA**:
   - The `MANOVA.RM` package was employed as it relaxes the assumption of multivariate normality, making it more robust for data that may not meet traditional MANOVA assumptions.

