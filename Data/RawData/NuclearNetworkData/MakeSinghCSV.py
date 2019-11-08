# -*- coding: utf-8 -*-
"""
Created on Wed Feb 15 11:35:31 2017

@author: Yara
"""

import pandas as pan
import numpy as np 

path2 = 'C://Users//Yara//Documents//Research//python_scripts//RawDataCSVs//jcrdata.dta'
singh= pan.read_stata(path2)

singhmat= np.array([singh['cowcc'], singh['year'], singh['level']]).T

#remove nulls in level 
new= np.array(['country', 'year','level'])
for j in range(0,len(singhmat)):
    state= True 
    for i in range(0,3):
        entry= singhmat[j,i]
        if np.isnan(entry):
            state= False 
    if state is True : 
        new= np.vstack([new, singhmat[j,:]])
# %% 
dataframe= pan.DataFrame(new)
pathcsv = 'C://Users//Yara//Documents//Research//python_scripts//RawDataCSVs//SinghAndWay.csv'
dataframe.to_csv(pathcsv)