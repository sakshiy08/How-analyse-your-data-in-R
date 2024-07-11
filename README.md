# How-to-analyse-your-data-in-R

## Step 1: Install (only once) and Upload the libraries
```bash
# Libraries for data manipulation
library(plyr) # to split data apart, and puts back together
library(dplyr) # to manipulate data like select(), mutate()
library(reshape2) # to transform data between wide and long formats
#
# Libraries for making graphs
library (ggplot2) # to make graphs
library(gridExtra) # to combine graphs together
library(grid) # to add an nx by ny rectangular grid to an existing plot
library(cowplot) # to combine graphs together
library(scales) # to determine breaks and labels for axes and legends
#
# Libraries for statistical analysis
library(nlme) # to model data e.g generalized least square model
library(emmeans)  # to extract outputs of a model
library(multcompView) # to summarize multiple paired comparisons
library(multcomp) #  to do multiple comparisons of groups
library(car) # for leven test

```


## Step 2: Upload your data in R
```bash
rice <- read.csv('rice.csv', na.strings = "NA") 
# data reference : https://app.quadstat.net/dataset/r-dataset-package-daag-rice
rice
```

Check that your data have been read correctly <br>
For example, are the variables and factors correctly presented in R?
```bash
str(rice)
```

```bash
## 'data.frame':    72 obs. of  7 variables:
##  $ SlNo        : int  1 2 3 4 5 6 7 8 9 10 ...
##  $ Variety     : Factor w/ 2 levels "ANU843","wt": 2 2 2 2 2 2 2 2 2 2 ...
##  $ Treatment   : Factor w/ 3 levels "F10","NH4Cl",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ Block       : int  1 1 1 1 1 1 2 2 2 2 ...
##  $ PlantNo     : int  1 2 3 4 5 6 7 8 9 10 ...
##  $ RootDryMass : int  56 66 40 43 55 66 41 67 40 35 ...
##  $ ShootDryMass: int  132 120 108 134 119 125 98 122 114 82 ...
```

>In this example: <br>
>Variables are SlNo, Variety, Treatment, Block, PlantNo, RootDryMass, and ShootDryMass <br>
>Factors are Variety (‘Two levels’ means we have two varieties) and Treatment (‘three levels’ means we have three treatments) <br>

## Step 3: Visualise your data
Let’s start with the ‘Shoot Dry Mass’ variable
```bash
RiceShootBiomass<-ggplot(data=rice, aes(x=Treatment, y=ShootDryMass, fill=Variety)) +
  geom_boxplot()+
  ylab("Shoot Dry Mass (g)")+ 
  xlab("Treatments")+
  theme_classic()+ 
  theme(legend.position="top")+
  theme( axis.title.x = element_text(color="blue", size=12, face="bold"),
         axis.title.y = element_text(color="#993333", size=12, face="bold"))

RiceShootBiomass
```
./images/Figure 1A.png
