# Quantifying the Causes of Human Migration

# Description
In recent years, it has been speculated that climate change is beginning to have an impact of human migration. To study the effect of climate change on migration, we use a General Additive Model (GAM) to model the human migration using traditional variables such as trade and climate variables such as average temperatures. This package includes our results in the final report and poster in the DOC folder. 

This package also includes our complete analysis and visualization tool under the CODE folder. If you would like a quick demo of our visualization tool without running any code, navigate to the quick demo section. If you would like to train the model and build the visualization tool from scratch, navigate to the full installation seciton.

# Demo Execution
For your convenience, we have published a subset of our results from 2005-2014 (inclusive) [here.](https://migration-flow-visualization.shinyapps.io/6242_visualization/)

# Full Installation
### Requirements
- Anaconda or miniconda

### Train the model
*Note: Depending on your machine, training the model may require you to purchase additional memory resources. We have provided a sample trained master_table.csv in case you are unable to train the GAM or would like to jump straight to visualization.*

1. Download all datasets from this [folder](https://github.com/APWright/6242Project/tree/master/Data/CleanData) into your Data/ directory

2. Navigate to the CODE/ directory and run the following command in your terminal to create the climate environment
```
conda env create -f environment.yml
```
3. Activate climate environment
```
conda activate climate
```
4. Navigate to the Analysis/ directory. Launch jupyter notebook using the following command.
```
jupyter notebook
```
5. Open and run Estimating Migration.ipynb. This notebook will save your trained model in Model/ and the final output estimates as master_table.csv in InteractiveViz/


### Build the visualization
6. Make sure there is an unzipped master_table.csv file in your InteractiveViz/ directory and that you have created the climate environment from steps 2-3 above. From the terminal where you have climate activated, launch rstudio.
```
rstudio
```
7. Navigate to File>Open Project and open InteractiveViz.Rproj project. Then open the app.R file.
8. Click on the RunApp button to launch the visualization

*Note: It may take a few minutes to load the dataset when you first launch the app.*
