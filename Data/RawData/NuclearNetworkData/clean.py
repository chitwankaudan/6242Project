import numpy as np

data_path = "//Users//austin//Documents//Berkeley//Spring 2017//NetworkGroup//python_scripts//RawDataCSVs//NewWeapons.csv"

data = np.genfromtxt(data_path, dtype=None, delimiter=',', skip_header=1)
#key = np.genfromtxt("//Users//austin//Documents//Berkeley//Spring 2017//NetworkGroup//python_scripts//RawDataCSVs//countrykey.csv", dtype=None, delimiter=',', skip_header=1)
# for i in range(len(data)):
#     cn = data[i][0]
#     for j in range(len(key)):
#         if key[j][1].replace(" ","") == cn:
#             data[i][0] = key[j][0]
for d in data.copy():
    if d[2] == -1: np.delete(data,d)
np.savetxt(data_path,data,delimiter=',',fmt="%s")

