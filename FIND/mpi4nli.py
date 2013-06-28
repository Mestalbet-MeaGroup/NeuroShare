import numpy
import tables
import time
import os
import re
from mpi4py import MPI


def nli4python(x,y,m,tau,neighbours,thel):
    """
	nli4python
	This function implements the Nonlinear Interdependences as described 
	in [1,2]. It uses an approach implemented by Jon Farrimond[3] which can be 
	found in the FIND toolbox. This Function is very much the exact copy of
	his code translated into Python.
	
	x,y=			Two time Series for which NLIS are to be calculated
	tau = 			delay time 
	neighbours = 	number of neighbours to calculate
	thel = 			value for theiler correction
	
	It returns a list whichs first entry are the values for 
	sxy,syx,hxy,hyx,nxy,nyx and whichs second entry is the cross correlation
	of x and y.(not normalized)
	
	[1]Pereda, E., Quiroga, R.Q. & Bhattacharya, J. Nonlinear multivariate 
	analysis of neurophysiological signals. Prog Neurobiol 77, 137(2005).
	[2]Rosenblum, M. et al. Phase synchronization: from theory to data 
	analysis. (2001).at <http://citeseer.ist.psu.edu/rosenblum99phase.html>
	[3]Farrimond, J.A. Nonlinear Analysis toolkit,NLITV, 
	technical documentation. (2007).
	
	This function belongs to the FIND-Toolbox. For the license
	details see licence.txt or for further information & updates see
	http://find.bccn.uni-freiburg.de.
	Please cite:
	[Meier, R. et al. FIND-A unified framework for neural data analysis. Neural 
    Networks 2008 Special Issue doi:10.1016/j.neunet.2008.06.019]

	"""
    import numpy 
    import math
    import scipy
    import scipy.stats
    import scipy.signal

    dpx=x.size
    dpy=y.size
    tdp=dpx

    rn=scipy.stats.zs(x)
    sn=scipy.stats.zs(y)

    cross=scipy.signal.correlate(rn,sn)


    if tdp-(m-1)*tau-1>(2*thel+neighbours):
        bivar=numpy.array((x,y))
        sxy=0
        syx=0
        hxy=0
        hyx=0
        nxy=0
        nyx=0

        ax=numpy.zeros((neighbours+1),dtype=float)
        ix=numpy.zeros((neighbours+1),dtype=int)
        ay=numpy.zeros((neighbours+1),dtype=float)
        iy=numpy.zeros((neighbours+1),dtype=int)

        dx=numpy.zeros((tdp-(m-1)*tau-1),dtype=float)
        dy=numpy.zeros((tdp-(m-1)*tau-1),dtype=float)

        for i in range(0,tdp-(m-1)*tau-1): 
            for k in range(0,neighbours):
                ax[k]=100000000
                ix[k]=100000000
                ay[k]=100000000
                iy[k]=100000000

            ax[neighbours]=0
            ix[neighbours]=100000000
            ay[neighbours]=0
            iy[neighbours]=100000000

            rrx=0.0 
            rry=0.0

            for j in range(0,tdp-(m-1)*tau-1):
                dx[j]=0
                dy[j]=0
                for k in range(0,m):

                    dx[j]=dx[j]+(bivar[0,i+k*tau]-bivar[0,j+k*tau])**2
                    dy[j]=dy[j]+(bivar[1,i+k*tau]-bivar[1,j+k*tau])**2

                if abs(i-j)>thel:
                    if dx[j]<ax[0]:
                        dcontroll1=0
                        for k in range(0,neighbours+1):
                            if dx[j]<ax[k]:
                                ax[k]=ax[k+1]
                                ix[k]=ix[k+1]
                            else:
                                ax[k-1]=dx[j]
                                ix[k-1]=j
                                dcontroll1=1
                            if dcontroll1==1:
                                break 

                    if dy[j]<ay[0]:
                        dcontroll2=0
                        for k in range(0,neighbours+1):
                            if dy[j]<ay[k]:
                                ay[k]=ay[k+1]
                                iy[k]=iy[k+1]
                            else:
                                ay[k-1]=dy[j]
                                iy[k-1]=j
                                dcontroll2=1
                            if dcontroll2==1:
                                break 
                rrx=rrx+dx[j]
                rry=rry+dy[j]

            rxx=0
            ryy=0
            rxy=0
            ryx=0

            for k in range(0,neighbours):
                rxx=ax[k]+rxx
                ryy=ay[k]+ryy
                rxy=dx[iy[k]]+rxy
                ryx=dy[ix[k]]+ryx
            rxx=rxx/neighbours
            ryy=ryy/neighbours
            rxy=rxy/neighbours
            ryx=ryx/neighbours
            sxy=sxy+rxx/rxy
            syx=syx+ryy/ryx
            try:
                hxy=hxy+math.log(rrx/((tdp-(m-1)*tau-2))/rxy)
                hyx=hyx+math.log(rry/((tdp-(m-1)*tau-2))/ryx )
            except OverflowError:
                hxy=hxy
                hyx=hyx
            nxy=nxy+rxy/(rrx/((tdp-(m-1)*tau-2)))
            nyx=nyx+ryx/(rry/((tdp-(m-1)*tau-2)))

        sxy=sxy/(tdp-(m-1)*tau-1)
        syx=syx/(tdp-(m-1)*tau-1)
        hxy=hxy/(tdp-(m-1)*tau-1)
        hyx=hyx/(tdp-(m-1)*tau-1)
        nxy=1.0-nxy/(tdp-(m-1)*tau-1)
        nyx=1.0-nyx/(tdp-(m-1)*tau-1)

        return [[sxy,syx,hxy,hyx,nxy,nyx],cross]

    else:
        return [numpy.array\
	([numpy.nan,numpy.nan,numpy.nan,numpy.nan,numpy.nan,numpy.nan]),cross]


def mpi4nli(m=10,tau=2,neighbours=10,thel=5,file_directory='./',\
	node_pattern='(.+?)\.h5'):
	"""
	This function reads in Data from HDF5 Files calculates every possible 
	combination off data according to equality in unitID and calculates 
	NLIs for them. Results are stored in the very same HDF5 Files from where 
	data was loaded.
	
	HDF Files should have the fellowing structure:
	/dataId/Segment/Dataset1/Data
							/UnitID
	
	where dataId is a qualifier for the dataset (could for eg be the filename)
	which can be determined from the filename using the node_pattern 
	(see below). Data is an array where every row is a data series. UnitID has 
	same dimension as data and conatain an integer where every row in UnitID 
	qualifies the same row in data. NLIs will be calculated for every possible 
	time series combination in Data which is qualified with the same integer
	(0 and 9999 will be ignored).(eg. if row 10, 45 and 60 in Data have the 
	same number in UnitID, meaning that row 10,45 and 60 in UnitID have the 
	same integer, NLIs will be calculated for 10 vs. 45 for 10 vs. 60 and for 
	45 vs. 60). 
	
	Results will be stored in 
	/dataId/Segment/Dataset1/NLIResults_tau?_m?_neigh?_thel?
							/ResultsID_tau?_m?_neigh?_thel?
	
	where ? will be replaced with the correct values.
	
	This approach is heavily optimised for MEA Data exported via the find HDF5
	exporter and we are fully aware that it is less easy to use with other 
	types of data storage. The "use case" is: Export Data from Find using the 
	HDF5 Exporter to an arbitrary Directory. Then Run the script giving the 
	same directory as an argument and, if neccesary, redefine node_pattern to 
	fit to your naming scheme.	
	
	m = 			number of embedding Dimensions
	tau = 			delay time 
	neighbours = 	number of neighbours to calculate
	thel = 			value for theiler correction
	file_directory = directory containing the hdf5 files from which the NLIs 
					should be calculated
	node_pattern=	Pattern which tells us how to translate file names to 
					dataIds eg. (.+?)\.h5 tells us that everything in front off
					.h5	will be the respective root node name. node Pattern 
					should be in correct re syntax.
					
	This function belongs to the FIND-Toolbox. For the license
	details see licence.txt or for further information & updates see
	http://find.bccn.uni-freiburg.de.
	Please cite:
	[Meier, R. et al. FIND-A unified framework for neural data analysis. Neural 
    Networks 2008 Special Issue doi:10.1016/j.neunet.2008.06.019]
	"""	
	
	## Initilaize the MPI Stuff
	comm=MPI.COMM_WORLD
	myRank=comm.rank
	mySize=comm.size
	myName=MPI.Get_processor_name()	
	
	os.chdir(file_directory) 
	
	## Here we decide whether we are the root process and if we are we start 
	## calculating and distributing problems and data
	if myRank==0: 
		filesToCalculate=os.listdir(file_directory) 
		calculatedFiles=0
		for files in filesToCalculate:
			## load data drom files
			workingFile=tables.openFile(files,'a')
			searchString='/%s/Segment/Dataset1'\
			%(re.findall(node_pattern,files)[0])
			dataSetNode=workingFile.getNode(searchString)
			unitID=dataSetNode.UnitID[:]
			data=dataSetNode.Data[:]
			
			## determine the Problems to solve
			setOfUnitID=set(unitID)
			setOfUnitID.add(9999)
			setOfUnitID.add(0)
			setOfUnitID.remove(9999)
			setOfUnitID.remove(0)
			listOfProblems=[]
			for e in setOfUnitID:
				counter=0
				layerChannels=[]
				for i in unitID:
					if e==i:
						layerChannels.append(counter)
					counter=counter+1  
				for i in range(0,len(layerChannels)):
					for j in range(i+1,len(layerChannels)):
						listOfProblems.append\
						([layerChannels[i],layerChannels[j],e])
						
			## MPI Communication routines
			NLIresults=[]
			crossResults=[]
			phaseCohResults=[]
			resultsID=[]
			sendProblems=0
			recProblems=0
			status=MPI.Status() 
			for process in range(1,min(mySize,len(listOfProblems))): 
				comm.Send(True,process,3)
				comm.Send(data,process,1)
				comm.Send(listOfProblems[sendProblems],process,2)
				sendProblems=sendProblems+1
			while recProblems<len(listOfProblems):
				status=MPI.Status()
				comm.Probe(-1,3,status)
				result=comm.Recv(0,status.Get_source(),3)
				NLIresults.append(result[0])
				comm.Probe(status.Get_source(),2,status)
				resultsID.append(comm.Recv(0,status.Get_source(),2))				
				recProblems=recProblems+1
				if sendProblems<len(listOfProblems):
					comm.Send(True,status.Get_source(),3)
					comm.Send(data,status.Get_source(),1)
					comm.Send(listOfProblems[sendProblems],\
					status.Get_source(),2)
					sendProblems=sendProblems+1
			NLIresultMatrix=numpy.array(NLIresults)
			resultIDMatrix=numpy.array(resultsID)
			counter=0
	
			## save results etc. in the hdf5 File (including meta information)
			result_node=workingFile.createArray(dataSetNode,\
			'NLIResults_tau%s_m%s_neigh%s_thel%s'\
			%(tau,m,neighbours,thel),NLIresultMatrix)
			
			result_id_node=workingFile.createArray(dataSetNode,\
			'ResultsID_tau%s_m%s_neigh%s_thel%s'\
			%(tau,m,neighbours,thel),resultIDMatrix)
			
			result_node.attrs.id=\
			"[id,data,(S(xy),S(yx),H(xy),H(yx),N(xy),N(yx))]"
			
			result_id_node.attrs.parameter=\
			"tau=%s,m=%s,neighbour=%s,theiler=%s"%(tau,m,neighbours,thel)
			
			result_id_node.attrs.id="[(IDChannel1,IDChannel2,LayerID)]"
			
			print "[Node=%s|Process=%i||Saving results]"%(myName,myRank)
			calculatedFiles=calculatedFiles+1
			print "[Node=%s|Process=%i||Calculated %s of %s files]"\
			%(myName,myRank,calculatedFiles,len(filesToCalculate))
			workingFile.flush()
			workingFile.close()
		
		for process in range(1,mySize):
			comm.Send(False,process,3)
		
		print "[Node=%s|Process=%i||!stopped working at %s]"\
				%(myName,myRank,time.localtime())
			
	## If we are not Process 0 then we receive problems and data and calculate 
	## NLIs
	else: 
		goOn=True
		while goOn:
			goOn=comm.Recv(0,0,3)
			if goOn:
				data=comm.Recv(0,0,1)
				problem=comm.Recv(0,0,2)
				print "[Node=%s|Process=%i||!start calculation at %s]"\
				%(myName,myRank,time.localtime())
				result=nli4python\
				(data[problem[0]],data[problem[1]],m,tau,neighbours,thel)
				comm.Send(result,0,3)
				comm.Send(problem,0,2)
		print "[Node=%s|Process=%i||!stopped working at %s]"\
				%(myName,myRank,time.localtime())
