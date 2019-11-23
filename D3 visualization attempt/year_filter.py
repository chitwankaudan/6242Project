# -*- coding: utf-8 -*-
"""
Created on Fri Nov 22 18:11:12 2019

@author: Frank
"""
import pandas as pd
import datetime as dt
all_data = pd.read_csv("migration_flows_all_years.csv")
all_data['year0'] = pd.to_datetime(all_data['year0'])
all_data['year0'] = all_data['year0'].dt.year
#print(all_data.dtypes)
#date = datetime.date(2010,1,1)
#print(date)
#print(type(date))
#data2015 = all_data[all_data["year0"]== date]


#all_data['year0'] = pd.to_datetime(all_data['year0'])
#data2010 = all_data[all_data['year0'].dt.year == 2010]

#data2010.to_csv("data2010.csv", index=False)

#data2010["Node1"] = data2010[["orig", "dest"]].min(axis=1)
#data2010["Node2"] = data2010[["orig","dest"]].max(axis=1)
#result = data2010.groupby(["Node1","Node2"], as_index=False)["flow"].sum()#.sort_values(by = ["flow"], ascending = False)
#result.rename(columns={'flow':'total_flow'}, inplace=True)

#data2010 = pd.merge(data2010, result, on = ["Node1", "Node2"], how = "left").sort_values(by = ["total_flow"], ascending = False)
#data2010 = data2010.drop(["Unnamed: 0","orig_code", "dest_code", "Node1", "Node2"], axis = 1)
#data2010.to_csv("data2010mod.csv",index = False)

#group_list = pd.unique(all_data[["orig","dest"]].values.ravel('K'))
#group_list = group_list.tolist()

#data2010 = data2010.head(100)
#data2010.to_csv("data2010.csv", index=False)

#data2010_USA = data2010[(data2010["orig"] == "USA") | (data2010["dest"] == "USA")]
#data2010_USA.to_csv("data2010_USA.csv", index=False)


####below lines to be used to create final ####
#all_data['year0'] = pd.to_datetime(all_data['year0'])
all_data["Node1"] = all_data[["orig", "dest"]].min(axis=1)
all_data["Node2"] = all_data[["orig","dest"]].max(axis=1)
result = all_data.groupby(["year0", "Node1","Node2"], as_index=False)["flow"].sum()#.sort_values(by = ["flow"], ascending = False)
result.rename(columns={'flow':'total_flow'}, inplace=True)

all_data = pd.merge(all_data, result, on = ["Node1", "Node2", "year0"], how = "left").sort_values(by = ["total_flow", "year0"], ascending = False)
all_data = all_data.drop(["Unnamed: 0","orig_code", "dest_code", "Node1", "Node2"], axis = 1)
all_data.to_csv("all_data_mod.csv",index = False)
####above lines to be used to create final ####

#group_list = pd.unique(all_data[["orig","dest"]].values.ravel('K'))
#group_list = group_list.tolist()
yearlist = []
for i in range(1960,2015,1):
    yearlist.append(i)
    