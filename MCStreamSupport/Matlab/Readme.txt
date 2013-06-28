Short instruction for MATLAB MCRack Interface:

MATLAB MCRack Interface is a software for reading
MCRack data files of all MCRack versions with MATLAB. 
Data files of Version 1.1 and above are read using 
the OLE interface that ships with MCRack (mcstream.dll).
(Data files of Version 0.0.0.72 and below are read by a 
MATLAB programmed reader.)

After installation please type

help datastrm 
help nextdata

in Matlab window for further information on available
data file header information and on data retrieving options

This interface is also used by the
MEA-Tools written by Uli Egert, Freiburg.

For using this interface you need some experience with
MATLAB.


******************************
% Installation and first steps

% install MCRack (especially register mcstream.dll)
% install MATLAB 

% start MATLAB

% copy following instructions to MATLAB and press Enter (or use File/Set Path menue):
% the following command assumes matlab installation drive to be c:
cd c:\matlab\toolbox\meatools\mcintfac;
addpath 'c:\Program Files\Multi Channel Systems\MC_Rack\MCStreamSupport\Matlab\meatools\mcintfac'


% Using MATLAB MCRack Interface routines:
% -set parameters 
% -copy instructions to MATLAB and press Enter
% -use help m-Files (eg help nextdata) for more information


******************************
% opening a MCRack file

a=datastrm('open')

% or

a=datastrm('d:\directory1\directory2\filename')

% Please note: only one MCRack file can be opened at a time.
% If you open a second file and do not delete the first datastrm object,
% the first datastrm object will read on data of the second file.

% Known bugs
% If you enter 'clear functions' to MATLAB command lind, all functions
% and also the OLE handle of the datastrm object are cleared from
% memory. Due to a MATLAB inconsistency this can lead to 
% segmentation faults, when accessing a datastrm object after typing
% 'clear functions'. After 'clear functions' please reopen the file before using.

******************************
% reading data (time always in ms)

c=nextdata(a,'startend',[1000,1250],'streamname','Electrode Raw Data');
% data come in 64 rows, analog data

c=nextdata(a,'startend',[2000 4000],'streamname','Spikes 1','originorder','on')
% data come in recording order, spike data

c=nextdata(a,'startend',[1 5000],'streamname','Trigger 1')
% trigger data


******************************
% upward compatibility 

Through the use of MCStream.dll changes in data format of MCRack
are followed by mcintfac, so that with the newest
mcstream.dll and mcintfac you can read MCRack data files of
all MCRack versions.



Copyright 1998,1999,2000,2002
Dieter Patzwahl, Multi Channel Systems, (patzwahl@multichannelsystems.com)
