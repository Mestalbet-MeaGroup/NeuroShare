######
mpi4nli
######
author: 		Christian Garbers
organisation:	BCCN Freiburg
contact: 		garbers@bccn.uni-freiburg.de

This Folder conatains Python scripts to calculate Nonlinear Interdependencies 
optionally in a paralel fashion.

You can import them in Python using

import mpi4nli

We have prepared two functions 
nli4python and mpi4nli 

nli4python simple calculates NLI for two time series and returns them.
mpi4nli uses MPI to calculate NLIs for many time Series
detailed usage information can be found using 
help(mpi4nli) in the python interpreter afer you imported mpi4nli 

nli4python depend on Python>2.5 numpy and scipy
mpi4nli depend on Python>2.5 numpy,scipy,pytables and mpi4py 

all of the needes packages can be obtained free of charge from the www

Plaese cite:
[Meier, R. et al. FIND-A unified framework for neural data analysis. Neural 
Networks 2008 Special Issue doi:10.1016/j.neunet.2008.06.019]
