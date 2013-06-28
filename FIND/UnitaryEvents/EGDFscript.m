% ***************************************************************
% *								*
% * GDFscript for generating GDF files from Alexa format	*
% *   for use of a single files interactively			*
% *								*
% * See:    help alexa2gdf  					*
% *	for specifications, code of output files etc		*
% *								*                                                          *
% * History:                                                    *
% *								*
% *         (0) first version                                   *
% *            Sonja Gruen, 26.3.1997 , Jerusalem               * 
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@hbf.huji.ac.il               *
% *                                                             *
% ***************************************************************

%****************************************************************
% ***************************************************************
% *								*
% * SPECIFY PARAMETERS						*	
% *								*
% ***************************************************************

% ***************************************
% *					*
% * Give name of output file		*	
% *  if not defined by empty brackets	*
% *, default filename is:		*
% *  behaviorfilename.gdf		*
% *					*
% ***************************************
%out_filename = 'winny131_235';
out_filename = [];


% ***************************************
% * type: adds according to	*
% * this error code different event codes
% * in the gdf-format			*
% *        type: 7=correct trial	*
% *		 5=no response		*
% *		[]=all trials		*
% *     others are not implemented yet	*
% ***************************************
type   	= 7;


% ***************************************
% *					*
% * Give name of input files to be	*	
% *  merged into one gdf-formatted file *
% *					*
% ***************************************

input_files  = ['winny1312';'winny1313'; 'winny1315'];





% **************************************************************	
%***************************************************************

% ***************************************
% *					*
% * function call			*
% *  !!!!! do not change !!!!!!		*
% *		 			*
% ***************************************
if isempty(out_filename)
 alexa2gdf(input_files, type );
else
 alexa2gdf(input_files, type, out_filename );
end;

clear input_files type out_filename; 
% ***************************************************************
% * end of GDFscript.m 						*                                                           *
% ***************************************************************










