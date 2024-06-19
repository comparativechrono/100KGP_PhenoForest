# 100KGP_PhenoForest
This repository contains tools to analyse phenotype associations in the 100,000 genomes project using Random Forests. Currently it contains an R script and a Jupyter notebook. Although the examples provided focus on Brugada syndrome, the tools and methodologies are designed to be applicable to any phenotypic data that follows the required data structure.

<img src="images/phenotree.png" alt="Random Forest Data Forest Visualization" width="500">

## Overview

This toolkit employs a variety of data analysis techniques to explore and understand the relationships between different phenotypes and their impact on specific conditions. Key components include data preprocessing, model training with Random Forest, and association rule mining to uncover meaningful patterns within the data.

## Data Structure

The input dataset should be in a CSV format with specific columns structured as follows:

| Column Name      | Description                               | Data Type       |
|------------------|-------------------------------------------|-----------------|
| patient_id       | Unique identifier for each patient        | Integer/String  |
| condition        | Medical condition of the patient          | String (Factor) |
| phenotype1       | First phenotypic attribute (example)      | String (Factor) |
| phenotype2       | Second phenotypic attribute (example)     | String (Factor) |
| ...              | ...                                       | ...             |
| phenotypeN       | N-th phenotypic attribute (example)       | String (Factor) |

- **patient_id**: This is a unique identifier assigned to each patient and is used to track results and analysis without revealing patient identity.
- **condition**: This column contains the categorical outcomes or diagnoses related to each patient. This field is critical as it is used as the dependent variable in predictive modeling.
- **phenotypes (phenotype1, phenotype2, ..., phenotypeN)**: These columns contain various attributes or characteristics of the patients, which are treated as independent variables in the analysis.

Please ensure that your CSV file follows this structure, otherwise the analysis will not work. You can include as many phenotype columns as you like, and there is no naming convention required for these columns.

Please see the brugada_phenotype_data.csv example data in the examples directory.

## Features

### Random Forest Analysis

- **Model Training:** Trains a Random Forest model to predict conditions based on phenotypes.
- **Feature Importance:** Identifies and ranks phenotypes based on their importance in predicting the condition using the Mean Decrease Gini index.
- **Visualization:** Provides a bar chart visualization of the phenotypes ranked by their importance, helping to visually assess which features are most influential.

### Association Rule Mining

- **Rule Generation:** Applies the Apriori algorithm to generate association rules that link combinations of phenotypic traits with specific conditions.
- **Rule Filtering:** Filters rules to focus on those that are most relevant to the conditions of interest.
- **Interpretation of Rules:** Extracts and formats the top rules for clarity, displaying support, confidence, and lift metrics to evaluate the strength and relevance of each rule.
- **Phi Coefficient Analysis:** Explores the phi coefficient as a measure of association between the items in the rules, providing deeper insights into the interactions within the data.

## Usage

1. **Data Preparation:** Load your CSV data file. Adjust the column indices in the script if your data structure differs.
2. **Run the Analysis:** Execute the script or notebook cells sequentially to perform the analysis.
3. **Interpret Results:** Review the outputs, including plots and CSV files of feature importance and association rules, to gain insights into the data.


## Plots

### Phenotype Importance Plot
This plot is generated using `ggplot2` and visually represents the importance of various phenotypes in predicting the condition as determined by the Random Forest model. Each phenotype is ranked by the Mean Decrease Gini index, which measures how each feature contributes to the homogeneity of the nodes and leaves in the constructed random forest:

- **X-axis:** Lists the phenotypes, reordered based on their importance.
- **Y-axis:** Shows the importance score for each phenotype.
- **Bar Chart:** Each bar represents a phenotype; the length of the bar indicates its relative importance.

### Rule Visualization
The visualization of association rules provides a graphical representation of the relationships between different phenotypes and the specified conditions. These plots are made using the `arulesViz` package:

- **Graph Plot:** Displays rules as nodes linked by edges. The nodes represent items (phenotypes or conditions), and edges signify the rules connecting these items. The thickness or color of the edges can vary to represent the rule's support, confidence, or lift. There are two graph plots produced currently. The second graph plot shows the top 100 rules ranked by phi, allowing for an in-depth look at the strongest and most relevant associations within the dataset.  The strength of their association (as measured by phi) dictates the layout and linkages
- **Grouped Matrix Plot:** This plot groups similar rules together and provides a matrix-like visualization where the presence of a rule is indicated by colored cells. This format can be particularly useful for spotting frequent patterns across multiple rules.

These plots help demystify complex rule sets by illustrating how various phenotypic characteristics co-occur with conditions, offering insights into the data's underlying structure and the strength of these associations.

## Output Files

### Phenotype Importance
- **File:** `phenotype_importance.csv`
- **Contents:** This CSV file contains a list of phenotypes along with their importance scores derived from the Random Forest analysis. Each row corresponds to a phenotype, and the columns include the phenotype name and its Mean Decrease Gini importance score.

### Top Association Rules
- **File:** `top_rules.csv`
- **Contents:** This CSV file records the top association rules based on the 'lift' metric, which indicates the strength of an association relative to its expected frequency under independence. The file includes columns for the rule description (in a human-readable format), support, confidence, and lift values.

### Patient IDs for Each Rule
- **File:** `rule_matches.csv`
- **Contents:** Contains the matching patient IDs for each of the top rules identified. It provides a way to trace back the specific data points that conform to high-confidence rules. The file includes columns for the rule number, the rule text, and the patient IDs.


## Requirements

This script requires the following R packages:
- `tidyverse`
- `randomForest`
- `caret`
- `arules`
- `arulesViz`

Ensure these packages are installed and loaded as shown at the beginning of the script or notebook.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Issues

If you encounter any problems or have any queries about using the software, please file an issue in the repository's issue tracker. We aim to resolve issues promptly and rely on feedback to improve the project.
