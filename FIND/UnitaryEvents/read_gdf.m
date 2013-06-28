function gdf=read_gdf(f,m)
% gdf=read_gdf(f,m), read gdf from file
% ***************************************************************
% *                                                             *
% * Usage:                                                      *
% *         1.  (gdf=) read_gdf                                 *
% *      or 2.  (gdf=) read_gdf('myfile')                       *
% *      or 3.  (gdf=) read_gdf('myfile','gui')                 *
% *                                                             *
% * The reference for the return value is optional. If no       *
% * reference is provided (nargout==0), read_gdf calls the      *
% * globalGDF script to export gdf data to global workspace.    *
% *                                                             *
% * 1. If no input arguments are provided (nargin==0) read_gdf  *
% *    brings up a GUI for file name selection.                 *
% * 2. If one input argument is provided (nargin==1) it is      *
% *    assumed to be a file name.                               *
% * 3. If two input arguments are provided (nargin==2) and the  *
% *    second one (m)ode is 'gui', a GUI is brought up in case  *
% *    of an error.                                             *
% *                                                             *
% *        f,         string - relative or absolut path         *
% *        m,         string - mode (default 'nogui')           *
% *                                                             *
% *    gdf (GDF_MAT), result - n x 2 matrix                     *
% *                   gdf(i,1) id of ith event in file          *
% *                   gdf(i,1) time of ith event in file        *
% *                                                             *
% * The file itself does not carry information about the unit   *
% * of time. In Gersteins original format it was defined to be  *
% * 0.5ms . Here we have to define it externally and export to  *
% * global workspace with globalGDF (TIME_UNITS).               *
% *                                                             *
% * In case of an uncorrected ERROR gdf (GDF_MAT) ==-1          *
% *                                                             *
% * Bugs:                                                       *
% *       no syntax check of GDF                                *
% *                                                             *
% *                                                             *
% * Future:                                                     *
% *         - syntax check of GDF                               *
% *         - better dialog boxes                               *
% *         - 'nongui' error messages                           *
% *         - control flow by a DFA ?                           *
% *                                                             *
% *                                                             *
% *                                                             *
% * History:                                                    *
% *         (4) now using real GDF struct                       *
% *            MD, 8.8.97, Freiburg                             *
% *         (3) put filename into global variable GDF_FILENAME	*
% *            SG, 23.3.97                                      *
% *         (2) optional return value and experimental support  *
% *             of a GUI.                                       *
% *            MD, 25.1.97, Freiburg                            *
% *         (1) adapted to globalGDF and commented              *
% *            MD, 20.1.97, Freiburg                            *
% *         (0) first Version                                   *
% *            SG, 9.4.96                                       *
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@hbf.huji.ac.il               *
% *                                                             *
% ***************************************************************

% global GDF;



if nargin==0
 m='gui';
 in=0;
elseif nargin==1
 m='nogui';
 in=f;
elseif nargin==2
 in=f;
end

f=0;
s1='Select';
fid=-1;
s2='Select';
while fid==-1 & strcmp(s2,'Select') & f==0 & strcmp(s1,'Select')

if in==0
 f=0;
 s1='Select';
 while f==0 & strcmp(s1,'Select')
  if strcmp(m,'gui')
   f=uigetfile('*.gdf','read_gdf');
  else
   f=0;
  end
  if strcmp(f,'')
   f=0;
  end
  if f==0
   if strcmp(m,'gui')
    s1=questdlg('No file selected.','Select','Abort');
   else
    s1='Abort';
   end
  end
 end
else
 f=in;
 in=0;
end

disp(['reading ' f '...']);

if f~=0
 [fid, message]  	= fopen(f, 'r');
 if fid~=-1
  disp('reading...');
  gdf.Data=fscanf (fid, '%f %f', [2 inf])';
  s=fclose(fid);
  if s==-1
   if strcmp(m,'gui')
    errordlg('Cannot close file.','error');
   end
   gdf.Data=-1;
  end
 else
  gdf.Data=-1;
 end
else
 gdf.Data=-1;
end

 if fid==-1 & ~strcmp(s1,'Abort')
   f=0;
   if strcmp(m,'gui')
    s2=questdlg(message,'Select','Abort');
   else
    s2='Abort';
   end
 end
end


gdf.FileName  = f;
gdf.TimeUnits = [];
