# =========================================================
# SECTION 1: SETUP, LIBRARIES & DATA LOADING
# =========================================================
library(tidyverse)
library(ISLR)
library(corrplot)
library(randomForest)
library(cluster)
library(viridis)
library(scales)

# Load Data
data(Wage)
df <- Wage
View(df)
# Check dimensions and structure
dim(df)
str(df)

head(df)
summary(df)

table(df$education)
table(df$maritl)
table(df$jobclass)

# Remove Logwage and Region Columns (Not needed for interpretation)
df <- df %>% select(-logwage)
df <- df %>% select(-region)
View(df)

# Calculate Mean Age
mean_age <- mean(df$age)
mean_age

# Calculate Mean and Median Wage
mean_wage <- mean(df$wage)
mean_wage

median_wage <- median(df$wage)
median_wage

# Count Empty Columns/NA values
sum(is.na(df))

# Check for Duplicated Rows
sum(duplicated(df))
df <- unique(df) 
dim(df)

# =========================================================
# SECTION 2: EXPLORATORY DATA ANALYSIS (EDA)
# =========================================================

# --- 2.1. Overall Wage Distribution ---

# Calculate Median 
median_val <- median(df$wage)

ggplot(df, aes(x = wage)) +
  # Histogram
  geom_histogram(fill = "#2c3e50", color = "white", bins = 30, alpha = 0.9) +
  
  # Median Line 
  geom_vline(aes(xintercept = median_val), color = "red", linetype = "dashed", size = 1) +
  
  # Annotation
  annotate("text", x = median_val + 10, y = 250, 
           label = paste("Median Wage:\n", round(median_val, 1), "k"), 
           color = "red", fontface = "bold", hjust = 0) +
  
  # Labels
  labs(title = "Overall Wage Distribution", 
       subtitle = "Right-skewed distribution: Majority clustered around 100k",
       x = "Wage ($1000)", y = "Frequency")

# --- 2.2. Age vs Wage (Career Arc) ---

ggplot(df, aes(x = age, y = wage)) +
  # 1. Points (Grey and faint to show trend)
  geom_point(alpha = 0.2, color = "gray60") +
  
  # 2. Trend Line (Loess with Confidence Interval)
  geom_smooth(method = "loess", color = "#d35400", size = 1.5, se = TRUE) + 
  
  # 3. Reference Line for Peak (Approx. 42-45 years old)
  geom_vline(xintercept = 42, linetype = "dashed", color = "black", alpha = 0.6) +
  
  # 4. Annotation
  annotate("text", x = 43, y = 250, 
           label = "Career Peak\n(~42-45 Years)", 
           hjust = 0, fontface = "bold", color = "#2c3e50") +
  
  # 5. Labels
  labs(title = "Relationship Between Age and Wage", 
       subtitle = "Non-linear: Wages rise fast between 20-40, then plateau.",
       x = "Age", y = "Wage ($1000)")

# --- 2.3. Education Premium (Boxplot) ---
df$education <- factor(df$education, levels = sort(unique(df$education)))

ggplot(df, aes(x = education, y = wage, fill = education)) +
  geom_boxplot(alpha = 0.7) +
  scale_fill_viridis_d() +
  labs(title = "Education Premium: Wage by Education Level",
       x = "Education Level", y = "Wage") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "none")


# --- 2.4. Wage Groups vs Health Insurance (Stacked Bar) ---

# Step 1: Discretize Wage into Categories (Binning)
# Dividing wages into logical economic brackets
df_stack <- df %>%
  mutate(wage_group = cut(wage, 
                          breaks = c(0, 70, 90, 110, 130, 160, 350),
                          labels = c("< 70k", "70k-90k", "90k-110k", "110k-130k", "130k-160k", "> 160k")))

# Step 2: Calculate Proportions (Required for Labels)
df_stack_prop <- df_stack %>%
  count(wage_group, health_ins) %>%
  group_by(wage_group) %>%
  mutate(prop = n / sum(n)) %>%
  ungroup()

# Step 3: Visualization
ggplot(df_stack_prop, aes(x = wage_group, y = prop, fill = health_ins)) +
  
  # Stacked Bar (Percentage)
  geom_col(position = "fill", width = 0.7) +
  
  # Add percentage labels inside the bars
  geom_text(aes(label = scales::percent(prop, accuracy = 1)), 
            position = position_fill(vjust = 0.5), 
            color = "white", fontface = "bold", size = 4) +
  
  # Colors: Security (Green) vs Risk (Red)
  scale_fill_manual(values = c("1. Yes" = "#27ae60", "2. No" = "#c0392b"),
                    labels = c("Insured", "Uninsured")) +
  
  # Axis Formatting
  scale_y_continuous(labels = scales::percent) +
  
  # Titles & Labels
  labs(title = "Income Security: Insurance Coverage by Wage Brackets",
       subtitle = "As wages rise, the risk of being uninsured disappears.",
       x = "Annual Wage Group ($1000)", y = "Percentage", fill = "Status") +
  
  # Theme Settings
  theme_minimal() +
  theme(legend.position = "top",
        axis.text.x = element_text(angle = 0, face = "bold"),
        panel.grid.major.x = element_blank())



# --- 2.5. Health Insurance by Education (Stacked Bar) ---
ggplot(df, aes(x = education, fill = health_ins)) +
  geom_bar(position = "fill") + 
  scale_y_continuous(labels = scales::percent) + 
  coord_flip() + 
  labs(title = "Health Insurance Coverage by Education",
       subtitle = "Does higher education lead to better insurance coverage?",
       x = "Education Level", y = "Percentage", fill = "Insurance Status") +
  scale_fill_brewer(palette = "Paired")

table(df$health_ins)

# =========================================================
# SECTION 3: DEEP DIVE & STATISTICAL INSIGHTS
# =========================================================

# --- 3.1. The Economics of Marital Status ---


df_marriage_summary <- df %>% 
  filter(maritl %in% c("1. Never Married", "2. Married", "4. Divorced")) %>%
  mutate(age_bin = cut(age, breaks = seq(18, 80, 10), include.lowest = TRUE)) %>%
  filter(!is.na(age_bin)) %>% 
  group_by(maritl, age_bin) %>%
  summarise(
    mean_wage = mean(wage),
    n = n(),                  
    .groups = 'drop'
  )


ggplot(df_marriage_summary, aes(x = age_bin, y = mean_wage, color = maritl, group = maritl)) +
  
  
  geom_line(size = 1.2, alpha = 0.6) +
  
 
  geom_point(aes(size = n), alpha = 0.8) +

  geom_text(aes(label = n), vjust = -1.2, size = 3, fontface = "bold", show.legend = FALSE) +
  

  labs(title = "The Economics of Marital Status (Weighted)",
       subtitle = "Bubble size represents the number of people (Sample Size)",
       x = "Age Group", y = "Average Wage ($1000)", 
       color = "Status", size = "Sample Size (n)") +
  

  scale_color_manual(values = c("1. Never Married" = "#95a5a6", 
                                "2. Married" = "#2c3e50", 
                                "4. Divorced" = "#e74c3c"),
                     labels = c("Never Married", "Married", "Divorced")) +
  
  
  scale_size_continuous(range = c(2, 10)) + 
  

  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "top")

# --- 3.2. Wage Comparison Boxplot (Race vs Education) ---
ggplot(df, aes(x = education, y = wage, fill = race)) +
  geom_boxplot(outlier.alpha = 0.4, outlier.size = 1.5) +
  scale_fill_brewer(palette = "Set2") +
  labs(title = "Distribution Analysis: Education & Race",
       subtitle = "Wage comparison across races with the same degree",
       x = "Education Level", y = "Wage ($1000)", fill = "Race") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, face = "bold"),
        legend.position = "top", panel.grid.minor = element_blank())

table(df$race)

# 3.3.--- Educational Breakdown by Race (100% Stacked Bar) ---

# Step 1: Calculate the proportion of education levels within each race
race_edu_data <- df %>%
  count(race, education) %>%
  group_by(race) %>%
  mutate(prop = n / sum(n)) %>%
  ungroup()

# Step 2: Create the Visualization
ggplot(race_edu_data, aes(x = race, y = prop, fill = education)) +
  
  # Percentage Stacked Bar
  geom_col(position = "fill", width = 0.6) +
  
  # Add percentage labels inside the bars (hiding values < 5% for clarity)
  geom_text(aes(label = ifelse(prop > 0.05, scales::percent(prop, accuracy = 1), "")), 
            position = position_fill(vjust = 0.5), 
            color = "white", size = 3.5, fontface = "bold") +
  
  # Axis Formatting
  scale_y_continuous(labels = scales::percent) +
  
  # Color Palette (Using Viridis for academic clarity)
  scale_fill_viridis_d(option = "D", direction = -1) + 
  
  # Titles & Labels
  labs(title = "Demographic Analysis: Education Levels by Race",
       subtitle = "Percentage distribution of education within each racial group",
       x = "Race", y = "Percentage", fill = "Education Level") +
  
  # Theme Settings
  theme_minimal() +
  theme(panel.grid.major.x = element_blank(),
        legend.position = "right")




#--- 3.4. Corelation Matrix---
# 1. Prepare the Matrix (Re-run this part to ensure data is ready)
df_full_corr <- df %>%
  # Remove unnecessary, non-predictive, or redundant columns
  select(-any_of(c("logwage", "education_num", "region"))) %>% 
  
  # Critical Step: Convert all FACTOR (Categorical) columns to NUMERIC
  # R needs numbers to calculate correlation (e.g., Industrial -> 1, Information -> 2)
  mutate_if(is.factor, as.numeric) %>%
  mutate_if(is.character, as.numeric) 

# Calculate the correlation matrix
# 'use = "complete.obs"' handles missing values by ignoring rows with NAs
cor_matrix_full <- cor(df_full_corr, use = "complete.obs")

# 2. Define Color Palette (Professional tones)
# Red (Negative Correlation) -> White (Neutral) -> Blue (Positive Correlation)
col_palette <- colorRampPalette(c("#D73027", "#FC8D59", "#FFFFFF", "#91BFDB", "#4575B4"))(200)

# 3. Plot the Heatmap
corrplot(cor_matrix_full, 
         method = "color",        # Fill boxes with color
         col = col_palette,       # Apply our custom Red-White-Blue palette
         type = "upper",          # Show only the upper triangle (since it's symmetrical)
         
         addCoef.col = "black",   # Print correlation coefficients in BLACK
         tl.col = "black",        # Color of text labels (Variable names)
         tl.cex = 0.8,            # Size of text labels (Adjusted to fit)
         number.cex = 0.7,        # Size of the coefficients inside boxes
         
         title = "Correlation Heatmap: Intensity Analysis", 
         mar = c(0,0,2,0),        # Margins to make room for the title
         diag = FALSE,            # Hide the diagonal line (the 1s) to reduce clutter
         cl.pos = "r")            # Position the color legend on the right
View(df)
# --- 3.4. Intersectional Analysis: Race + Education on Insurance ---
df_cross <- df %>%
  count(race, education, health_ins) %>%
  group_by(race, education) %>%
  mutate(prop = n / sum(n)) %>%
  ungroup()

ggplot(df_cross, aes(x = education, y = prop, fill = health_ins)) +
  geom_col(position = "fill", width = 0.8) +
  facet_wrap(~race, ncol = 2) +
  geom_text(aes(label = ifelse(prop > 0.10, percent(prop, accuracy = 1), "")), 
            position = position_fill(vjust = 0.5), 
            color = "white", size = 3, fontface = "bold") +
  scale_fill_manual(values = c("1. Yes" = "#2ca02c", "2. No" = "#d62728"),
                    labels = c("Insured", "Uninsured")) +
  scale_y_continuous(labels = scales::percent) +
  labs(title = "Intersectional Analysis: Race and Education",
       subtitle = "Insurance coverage by education within each racial group",
       x = "Education Level", y = "Percentage", fill = "Insurance Status") +
  theme_bw(base_size = 12) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
        legend.position = "top")

# =========================================================
# SECTION 4: TIME SERIES TRENDS
# =========================================================

# --- 4.1. Wage Trends by Education (2003-2009) ---
trend_data <- df %>%
  group_by(year, education) %>%
  summarise(mean_wage = mean(wage), .groups = 'drop')

general_trend <- df %>%
  group_by(year) %>%
  summarise(mean_wage = mean(wage)) %>%
  mutate(education = "General Average")

ggplot() +
  geom_line(data = trend_data, aes(x = year, y = mean_wage, color = education), size = 1.2) +
  geom_point(data = trend_data, aes(x = year, y = mean_wage, color = education), size = 3) +
  geom_line(data = general_trend, aes(x = year, y = mean_wage), 
            color = "black", linetype = "dashed", size = 1.2, alpha = 0.7) +
  scale_x_continuous(breaks = unique(df$year)) +
  scale_color_viridis_d(option = "C", end = 0.9) +
  labs(title = "Wage Trends Over Years (2003-2009)",
       subtitle = "Dashed black line shows general average",
       x = "Year", y = "Average Wage ($1000)", color = "Education Level")

# --- 4.2. General Trend Line ---
yearly_trend <- df %>%
  group_by(year) %>%
  summarise(mean_wage = mean(wage))

ggplot(yearly_trend, aes(x = year, y = mean_wage)) +
  geom_line(color = "#2c3e50", size = 1.5) +
  geom_point(color = "#e74c3c", size = 4) +
  geom_text(aes(label = round(mean_wage, 1)), vjust = -0.8, fontface = "bold", size = 5) +
  scale_x_continuous(breaks = unique(df$year)) +
  ylim(100, 120) +
  labs(title = "General Average Wage Trend",
       subtitle = "Overall wage change from 2003 to 2009",
       x = "Year", y = "Average Wage ($1000)") +
  theme(panel.grid.minor = element_blank())

# --- 4.3. Wage trend over the years according to sector ---

ggplot(df, aes(x = year, y = wage, color = jobclass)) + 
  # 1. Calculate mean and plot as LINE (to visualize trend)
  stat_summary(fun = mean, geom = "line", size = 1) +
  
  # 2. Add POINTS to annual means (to highlight years)
  stat_summary(fun = mean, geom = "point", size = 3) +
  
  # 3. Optional: Display values on top of points
  geom_text(stat = "summary", fun = mean, aes(label = round(..y.., 1)), 
            vjust = -1, show.legend = FALSE, size = 3) +
  
  # Labels
  labs(title = "Average Wage Change by Year and Sector", 
       subtitle = "Comparison of Job Classes over Time",
       x = "Year", 
       y = "Average Wage",
       color = "Job Class") +
  
  # Color Palette (Preferred pastel tones)
  scale_color_brewer(palette = "Set1") +
  
  # Theme settings
  theme_minimal() +
  theme(legend.position = "bottom") # Move legend to bottom to expand graph width

# =========================================================
# SECTION 5: MACHINE LEARNING & ADVANCED MODELING
# =========================================================

# --- 5.1. Feature Importance (Random Forest) ---

set.seed(42)
rf_test <- randomForest(wage ~ ., data = df_test, importance = TRUE, ntree = 100)

importance_new <- data.frame(Feature = rownames(importance(rf_test)), 
                             Importance = importance(rf_test)[, "%IncMSE"])

ggplot(importance_new, aes(x = reorder(Feature, Importance), y = Importance)) +
  geom_bar(stat = "identity", fill = "red", alpha = 0.8) + 
  coord_flip() +
  labs(title = "Feature Importance (Simplified)",
       subtitle = "Health Insurance & Duplicate Education Removed",
       x = "Feature", y = "Importance (% Increase in MSE)")

# --- 5.2. Clustering Analysis (K-Means) ---

# A. Elbow Method
cluster_data <- df %>% select(age, wage)
scaled_data <- scale(cluster_data)

wss <- numeric(10)
for (i in 1:10) { wss[i] <- kmeans(scaled_data, centers = i, nstart = 25)$tot.withinss }
elbow_df <- data.frame(k = 1:10, wss = wss)

ggplot(elbow_df, aes(x = k, y = wss)) +
  geom_line(color = "blue", size = 1) +
  geom_point(size = 3) +
  scale_x_continuous(breaks = 1:10) +
  labs(title = "Elbow Method for Optimal K", x = "Clusters (k)", y = "Total Within Sum of Squares")

# B. Running K-Means (k=3)
set.seed(123) 
km_result <- kmeans(scaled_data, centers = 3, nstart = 25)
df$cluster <- as.factor(km_result$cluster)

real_centroids <- df %>%
  group_by(cluster) %>%
  summarise(age = mean(age), wage = mean(wage))

ggplot(df, aes(x = age, y = wage, color = cluster)) +
  geom_point(alpha = 0.5) +
  geom_point(data = real_centroids, aes(x = age, y = wage), 
             color = "black", size = 5, shape = 18) +
  labs(title = "Worker Personas (Clustering)", 
       subtitle = "Segmentation based on Age and Wage",
       x = "Age", y = "Wage", color = "Cluster") +
  scale_color_brewer(palette = "Set1")

# Cluster Summary
cluster_summary <- df %>%
  group_by(cluster) %>%
  summarise(Count = n(), Avg_Age = round(mean(age), 1), Avg_Wage = round(mean(wage), 1))
print("--- Cluster Profiles ---")
print(cluster_summary)

# --- 5.3. The Catch-Up Curve (ROI Analysis) ---
target_edu <- c("2. HS Grad", "5. Advanced Degree")
df_catchup <- df %>% filter(education %in% target_edu)

ggplot(df_catchup, aes(x = age, y = wage, color = education)) +
  geom_smooth(method = "loess", size = 1.5, se = TRUE) +
  labs(title = "ROI Analysis: HS Grad vs Advanced Degree Trajectories",
       x = "Age", y = "Wage Trend", color = "Education") +
  scale_color_brewer(palette = "Set1")