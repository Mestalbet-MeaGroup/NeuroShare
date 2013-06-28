function [mat,n_list,n_trial]= anna2gdf(file_arr,output_file)
% anna2gdf(file_arr,output_file) filter from Anna's format to gdf
% ***************************************************************
% *                                                             *
% * Usage:                                                      *
% *        file_arr:	array of strings of the spike filenames *
% *			to be put together into gdf format	*
% *                                                             *
% *	   output_file: optional; if not given, then the	*
% *			behaviorfilename is taken; both		*
% *			with extension .gdf			*
% *								*
% *        input data: the structure of the data in the 	*
% *			 spike files (to be read): 		*
% *			per row one trial, time (in 0.1ms)	*
% *			starts from 0 in each trial		*
% *                                                             *
% *        output data: > optional:				*
% *			 mat	:   first col  : event ids	*
% *				    second col : time (in ms)	*
% *			 n_list  : list of neuron id in mat	*
% *			 n_trial : number of trials included	* 
% *                                           			*
% *          		> file of name behaviorfilename.gdf	*
% *			  or of the given output_file.gdf	*
% *			  containing  the gdf-matrix		*
% *								*
% *		event codes: 					*
% *		0-6 : neuron id					*
% *                                                             *
% * See Also:                                                   *
% *       read_gdf.m, alexa2gdf.m				*
% *                                                             *
% * Uses:                                                       *
% *       copy()		                                *
% *                                                             *
% * History: 							*
% *	    (1) this is a modified version from alexa2gdf	*
% *		SG, 20.11.97, Jerusalem				*
% *								*
% *         (0) first version                                   *
% *            SG, 10.3.1997                                    * 
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@hbf.huji.ac.il               *
% *                                                             *
% ***************************************************************

% ***************************************************************
% * example:
% * filename        = 'BiOpp_2_12';
% * anna_file_arr   = ['BiOpp_2_1'; 'BiOpp_2_2'];
% * anna2gdf(anna_file_arr, filename);
% *
% *  OR:
% * anna2gdf(['BiOpp_2_1'; 'BiOpp_2_2'], 'BiOpp_2_12') ; 
% *
% ***************************************************************

disp('anna2gdf ...');

if nargin == 0
 disp('Give input parameters: '),
 disp(' array of filenames, output filename (optional)');
 return
end
         
num_str	= size(file_arr);
n_files	= num_str(1);
name_len= num_str(2);

N_NEURON	= n_files;
NEURON_LIST	= [];

START_ID	= 140;   % maybe Anna wants something else ...

strCat		= [''];


% ***************************************
% * initialize gdf_mat as row matrix	*
% * do avoid multiple transforms	*
% ***************************************			

gdf_mat = zeros(2,10);
last = 1;


% ************************************************
% ************************************************
% *						**
% * looping over files == neurons		** 
% *						**
% ************************************************
% ************************************************

for i=1:n_files
 filename = file_arr(i,:);
 load(filename); %eval(['load ' filename ]);
 [TRIAL_LENGTH, N_TRIAL] = size(data);


 % ***********************************************
 % *						*
 % * Calculate cumulative times of		* 
 % *  start of trial 				*
 % *						*
 % ***********************************************
 
 % assuming all files have same number of trials ...
 if n_files == 1

  CUM_T	= (0:N_TRIAL-1)*TRIAL_LENGTH;

 end


 NEURON_LIST(i) = eval(filename(name_len));
 strCat		= [strCat num2str(NEURON_LIST(i))]; 
 
 disp(['...putting data of ' filename ' into gdf_mat ']);

 % ***********************************************
 % *						*
 % * loop over trials				* 
 % *						*
 % ***********************************************

 for j=1:N_TRIAL

  % *********************************************
  % *						*
  % *  find index where spikes are		*
  % *   take index as spike time		*
  % *						*
  % *********************************************
      
   ii = find(data(j,:));


 if ~isempty(ii)

  % *********************************************
  % *						*
  % *  put spike times with trial offset	*
  % *						*
  % *********************************************


   % disp ('putting spikes in gdf_mat ...');

    gdf_mat(2,last:last+length(ii)-1) = ...
		 ii + CUM_T(j);

  % *********************************************
  % *						*
  % *  put neuron id, taken from last string	*
  % *	of filename				*
  % *						*
  % *********************************************

   % disp(' putting neuron id in gdf_mat ...');

    gdf_mat(1,last:last+length(ii)-1) = ...
     copy(eval(filename(name_len)),1,length(ii));

 end	% ~isempty(ii)

 % **********************************************
 % *						*
 % * update index of last event			*
 % *						*
 % **********************************************

 last = last+length(ii);




 % **********************************************
 % *						*
 % * putting behavioral events:			*
 % *  during the trials ONLY of the last file	* 
 % *  once is enough				*
 % *						*
 % **********************************************

 if i == n_files


  % *********************************************
  % *						*
  % *  put ST (start of trial)			*
  % *						*
  % *********************************************


   % disp (' putting trial start ids ...');
    
    gdf_mat(2,last) = CUM_T(j);
    gdf_mat(1,last) = Start_ID;

    last = last + 1;

 end		% if i == n_files 


 end		% of trial loop

end		% of file loop



% ***********************************************
% *						*
% * convert to 1 ms resolution:			*
% *  original data are in 0.1ms			*
% *						*
% ***********************************************
% WHAT is Anna's time resolution?

%   gdf_mat(2,:)= gdf_mat(2,:)*0.1;		


% ***********************************************
% *						*
% * sort according to the time			*
% *						*
% ***********************************************

 [time_sort, idx_sort] = sort(gdf_mat(2,:));
 gdf_mat  = floor(gdf_mat(:,idx_sort));



% ***********************************************
% *						*
% * write to file: behaviorfilename.gdf		*
% *	 					*
% ***********************************************

 if nargin == 3
  write_name = [output_file '.gdf'];
 else
  write_name = [file_arr(1,1:name_len-1) strCat '.gdf']; 
 end

 disp(['...writing gdf data to file ' write_name]); 
 fid=fopen(write_name, 'w');
 fprintf(fid, '%12d %12d\n', gdf_mat);
 fclose(fid);
 disp([' file closed ']);


% ***********************************************
% *						*
% * 	generate output matrix			*
% *	 					*
% ***********************************************


if nargout == 1
  mat = gdf_mat';
elseif nargout == 2
 mat 	= gdf_mat';
 n_list = NEURON_LIST;
elseif nargout == 3
 mat 	= gdf_mat';
 n_list = NEURON_LIST;
 n_trial= N_SEL_TRIAL;
end

clear;

%------------------------------------------------------------------
% end
%------------------------------------------------------------------
