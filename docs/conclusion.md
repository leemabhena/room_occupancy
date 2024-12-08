---
title: "Conclusion"
---

## Summary of Findings

This project explored the use of multivariate statistical analysis to gain insights on room occupancy levels based on environmental sensor data. Two primary methodological approaches were employed:

1. **Principal Component Analysis (PCA) followed by Multivariate Analysis of Variance (MANOVA)**
2. **Aggregation of Sensor Data by Type followed by MANOVA**

### First Approach: PCA and MANOVA

- **Dimensionality Reduction:** PCA reduced the dataset's complexity by transforming 19 correlated sensor variables into five uncorrelated principal components (PCs).
- **Key Findings:**
  - **PC1 (Combined Environmental Activity):** Strongly associated with occupancy levels, effectively distinguishing between unoccupied and occupied rooms.
  - **Significant Differences:** MANOVA results indicated highly significant differences in the PCs across different occupancy levels (*p*-value < 0.001).
  - **Post-Hoc Analysis:** Pairwise comparisons showed significant differences mainly between unoccupied and occupied states, with less distinction between higher occupancy levels (e.g., 2 vs. 3 occupants).

### Second Approach: Aggregated Sensor Data and MANOVA

- **Data Simplification:** Sensors were averaged by type (Temperature, Light, Sound, CO₂) to maintain interpretability and direct relationships with occupancy levels.
- **Key Findings:**
  - **CO₂ and Light Sensors:** Demonstrated the most significant differences across all occupancy levels, serving as robust indicators of room occupancy.
  - **Significant Differences:** MANOVA confirmed statistically significant differences in the aggregated sensor readings across occupancy levels (*p*-value < 0.001).
  - **Post-Hoc Analysis:** Pairwise comparisons revealed that CO₂ concentration and light intensity could effectively distinguish between all occupancy levels, including higher ones.

## Insights from the Analysis

### Environmental Factors Influencing Occupancy:

- **CO₂ Concentration:** The most significant predictor of occupancy levels.
- **Light Intensity:** Strong indicator of occupancy, as rooms tend to be lit when occupied.
- **Temperature and Sound Levels:** Useful for detecting occupancy but less effective in distinguishing between higher numbers of occupants.

### Methodological Insights:

- **PCA Approach:** Useful for dimensionality reduction but resulted in abstract components that were less interpretable and less effective in differentiating between higher occupancy levels.
- **Aggregation Approach:** Provided clearer, more practical insights, maintaining the interpretability of sensor data.

## Limitations

### Difficulty in Quantifying Higher Occupancy Levels:

- Both approaches struggled to accurately differentiate between rooms with 2 and 3 occupants. Sensor readings did not show sufficiently distinct changes at higher occupancy levels.

### Controlled Environment Constraints:

- Data was collected in a single room under controlled conditions, which may limit the generalizability of the findings to other settings or larger spaces.

### Class Imbalance:

- The dataset was initially skewed towards zero occupancy, necessitating techniques like undersampling, which may result in the loss of valuable data.

## Future Directions

### Enhanced Data Collection:

- **Diverse Environments:** Collect data from multiple rooms with varying sizes, layouts, and usage patterns to improve the generalizability of the study. 
- **Extended Occupancy Levels:** Include scenarios with higher occupancy counts to explore the model's effectiveness in more crowded settings.

### Advanced Analytical Methods:

- **Machine Learning Models:** Implement algorithms like Random Forests, Support Vector Machines, or Neural Networks that can capture non-linear relationships and interactions between variables.
- **Time-Series Analysis:** Incorporate temporal dynamics to account for patterns over time, potentially improving occupancy estimation during transitional periods.

### Addressing Limitations:

- **Handling Class Imbalance:** Use techniques like Synthetic Minority Over-sampling Technique (SMOTE) to create a more balanced dataset without discarding data.
- **Improved Data Preprocessing:** Implement noise reduction and outlier detection methods to enhance data quality.

### Practical Implementation:

- **Real-Time Monitoring Systems:** Develop and test occupancy detection systems in live environments to assess performance and make iterative improvements.

## Conclusion

The analysis demonstrates that multivariate statistical methods can effectively utilize environmental sensor data to estimate study room occupancy levels. Key environmental factors—particularly CO₂ concentration and light intensity—were identified as significant predictors of occupancy. While both methodological approaches provided valuable insights, aggregating sensor data by type offered clearer interpretations and practical applicability.

Addressing the limitations through enhanced data collection and advanced analytical techniques can further improve occupancy estimation models. This project lays the groundwork for developing efficient occupancy detection systems, which can significantly enhance student life by streamlining the process of finding available study spaces with desired amenities.

## Final Thoughts

This project confirms the viability of using environmental sensor data and multivariate statistical analysis for occupancy estimation. By identifying the most significant environmental factors and employing appropriate analytical methods, we can develop effective systems to alleviate the challenges students face in finding available study rooms, thereby improving campus life and resource utilization.
