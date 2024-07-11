
#Question: I have a data set. How should I analyse it?

# In general, these are the steps that we should follow:

# Step 1: Install (only once) and Upload the libraries

# Load libraries
#
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
#
#
#
# Step 2: Upload your data in R

rice <- read.csv('rice.csv', na.strings = "NA")
rice

# Check that your data have been read correctly
# For example, are the variables and factors correctly presented in R?
#
str(rice)
#
# Our variables are: SlNo, Variety, Treatment, Block, PlantNo, RootDryMass, and ShootDryMass
# Our factors are: Variety ('Two levels' means we have two varieties), and 
# Treatment ('three levels' means we have three treatments) 
#
#
# Step 3: Visualise your data
# Shoot Dry Mass

RiceShootBiomass<-ggplot(data=rice, aes(x=Treatment, y=ShootDryMass, fill=Variety)) +
  geom_boxplot()+
  ylab("Shoot Dry Mass (g)")+ 
  xlab("Treatments")+
  theme_classic()+ 
  theme(legend.position="top")+
  theme( axis.title.x = element_text(color="blue", size=12, face="bold"),
         axis.title.y = element_text(color="#993333", size=12, face="bold"))

RiceShootBiomass

# Step 4: Do the statistical analyses
# First of all, test the dataset for normal distribution and homogeneity of variance
# If passed, then 'parametric analysis' such as ANOVA can be used.
# Because, parametric analysis assumes that the data are normally distributed and 
# the variance in the population is equal.
# If not passed, the data may be log-transformed and 
# tested again for normal distribution and homogeneity of variance
# If still not passed, then 'non-parametric analysis' such as 'kruskal wallis' can be used. 
# Because,the non-parametric analysis does not assume that the data are normally distributed
# Therefore, the non-parametric analysis is also called 'distribution free analysis'

# Let's start:
# Let's test if the data for ShootDryMass trait are normally distributed
# Shapiro-Wilk test can be used to test normality
# P-value > 0.05 means normal distribution

ShootDryMass <- rice$ShootDryMass
shapiro.test(ShootDryMass)

# p-value = 0.05042, so the shoot dry mass data are normally distributed.

# Test for homogeneity of variances for the ShootDryMass data

leveneTest(ShootDryMass~Variety*Treatment, data = rice)

# The p-value is 0.1577. Greater than 0.05. Non-significant.
# Therefore, paramatric analysis such as ANOVA should be used 
# for analysing 'ShoootDryMass' data

shoot.aov <- aov(ShootDryMass~Variety*Treatment, data = rice)
summary(shoot.aov)

# There are significant differences in ShootDryMass
# between varieties and
# among treatments, 
# as well as in variety and treatment interaction

TukeyHSD(shoot.aov, "Treatment", ordered = TRUE)

# NH4NO3 Vs NH4Cl is significatly different
# NH4NO3 Vs F10 is significatly different

# Step 5: Annotate the graph 

labs = tibble(Variety = c("ANU843","ANU843","ANU843","wt","wt","wt"),
              Treatment = c("F10", "NH4Cl", "NH4NO3", "F10", "NH4Cl", "NH4NO3"),
              labels = c("a", "b", "c", "d", "e", "f") )

labs


labeldat = rice %>%
  group_by(Variety, Treatment) %>%
  summarize(ypos = median(ShootDryMass) + 38 ) %>%
  inner_join(., labs)

ShootBiomass_annot <- RiceShootBiomass +
  geom_text(data = labeldat, aes(label = labels, y = ypos), 
          position = position_dodge(width = .75), 
          show.legend = FALSE )

ShootBiomass_annot
  
# Step 6: Save the graph

ggsave("Figure 1_Rice Shoot Biomass.png", 
       device = "png", 
       ShootBiomass_annot, 
       height = 19, width = 18.5, units = 'cm', 
       dpi = 600)
###
