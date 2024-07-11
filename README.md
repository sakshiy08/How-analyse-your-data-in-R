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
![image 1](https://github.com/sakshiy08/How-to-analyse-your-data-in-R/blob/main/Figure%201A.png)

## Step 4: Do the statistical analyses
>First of all, test the dataset for normal distribution and homogeneity of variance <br>
>If passed, then ‘parametric analysis’ such as ANOVA can be used. Because, parametric analysis assumes that the data are normally distributed and the variance in the population is equal <br>
>If not passed, the data may be log-transformed and tested again for normal distribution and homogeneity of variance <br>
>If still not passed, then ‘non-parametric analysis’ such as ‘kruskal wallis’ can be used. Because,the non-parametric analysis does not assume that the data are normally distributed. Therefore, the non-parametric analysis is also called ‘distribution free analysis’ <br>

Let’s start. Let’s test if the data for ShootDryMass trait are normally distributed Shapiro-Wilk test can be used to test normality
```bash
ShootDryMass <- rice$ShootDryMass
shapiro.test(ShootDryMass)
```

```bash
## 
##  Shapiro-Wilk normality test
## 
## data:  ShootDryMass
## W = 0.96627, p-value = 0.05042
```

>p-value = 0.05042 <br>
>P-value > 0.05 means normal distribution so the shoot dry mass data are normally distributed <br>

Test for homogeneity of variances for the ShootDryMass data
```bash
leveneTest(ShootDryMass~Variety*Treatment, data = rice)
```

```bash
## Levene's Test for Homogeneity of Variance (center = median)
##       Df F value Pr(>F)
## group  5  1.6558 0.1577
##       66
```

>The p-value is 0.1577. Greater than 0.05. Non-significant.
>Therefore, paramatric analysis such as ANOVA should be used for analysing ‘ShoootDryMass’ data
```bash
shoot.aov <- aov(ShootDryMass~Variety*Treatment, data = rice)
summary(shoot.aov)
```
```bash
##                   Df Sum Sq Mean Sq F value   Pr(>F)    
## Variety            1  22685   22685   60.95 5.86e-11 ***
## Treatment          2   7019    3509    9.43  0.00025 ***
## Variety:Treatment  2  38622   19311   51.89 2.88e-14 ***
## Residuals         66  24562     372                     
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

>There are significant differences in ShootDryMass between varieties among treatments as well as in variety and treatment interaction
```bash
TukeyHSD(shoot.aov, "Treatment", ordered = TRUE)
```

```bash
##   Tukey multiple comparisons of means
##     95% family-wise confidence level
##     factor levels have been ordered
## 
## Fit: aov(formula = ShootDryMass ~ Variety * Treatment, data = rice)
## 
## $Treatment
##                   diff       lwr      upr     p adj
## F10-NH4Cl     9.416667 -3.935941 22.76927 0.2162588
## NH4NO3-NH4Cl 24.000000 10.647393 37.35261 0.0001630
## NH4NO3-F10   14.583333  1.230726 27.93594 0.0290795
```

>NH4NO3 Vs NH4Cl is significatly different <br>
>NH4NO3 Vs F10 is significatly different <br>

## Step 5: Annotate the graph

```bash
labs = tibble(Variety = c("ANU843","ANU843","ANU843","wt","wt","wt"),
              Treatment = c("F10", "NH4Cl", "NH4NO3", "F10", "NH4Cl", "NH4NO3"),
              labels = c("a", "b", "c", "d", "e", "f") )

labs
```

```bash
## # A tibble: 6 x 3
##   Variety Treatment labels
##   <chr>   <chr>     <chr> 
## 1 ANU843  F10       a     
## 2 ANU843  NH4Cl     b     
## 3 ANU843  NH4NO3    c     
## 4 wt      F10       d     
## 5 wt      NH4Cl     e     
## 6 wt      NH4NO3    f
```
```bash
labeldat = rice %>%
  group_by(Variety, Treatment) %>%
  summarize(ypos = median(ShootDryMass) + 38 ) %>%
  inner_join(., labs)

ShootBiomass_annot <- RiceShootBiomass +
  geom_text(data = labeldat, aes(label = labels, y = ypos), 
          position = position_dodge(width = .75), 
          show.legend = FALSE )

ShootBiomass_annot
```
![image 2]()
