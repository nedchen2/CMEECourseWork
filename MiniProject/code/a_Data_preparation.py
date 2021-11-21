import matplotlib.pyplot as p
import pandas as pd
import seaborn as sns
import numpy as np

data = pd.read_csv("../data/LogisticGrowthData.csv")
print("Loaded {} columns.".format(len(data.columns.values)))

print(data.columns.values)

pd.read_csv("../data/LogisticGrowthMetaData.csv")

print(data.PopBio_units.unique()) #units of the response variable 

data.insert(0, "ID", data.Species + "_" + data.Temp.map(str) + "_" + data.Medium + "_" + data.Citation)#Species, Medium, Temp and Citation columns (each species-medium-citation combination is unique)

print (data.head())

data_subset = data[data['ID']=='Chryseobacterium.balustinum_5_TSB_Bae, Y.M., Zheng, L., Hyun, J.E., Jung, K.S., Heu, S. and Lee, S.Y., 2014. Growth characteristics and biofilm formation of various spoilage bacteria isolated from fresh produce. Journal of food science, 79(10), pp.M2072-M2080.']
data_subset.head()

sns.lmplot("Time", "PopBio", data = data_subset, fit_reg = False) # will give warning - you can ignore it
