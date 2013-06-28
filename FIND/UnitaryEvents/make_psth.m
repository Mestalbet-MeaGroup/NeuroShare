function [pv,iv] = make_psth(data,l,time_units,bin_width,format)
%[pv,iv]=make_psth(data,l,time_units,bin_width,format): generate psth (in sp/sec)
% ***************************************************************
% *								*
% * Usage:							*
% * 								*
% *	data, 		data matrix, each column is a trial;	*
% *	      		full or sparse are allowed;		*
% *     l,  length of trial in bins                             * 
% *								*
% *	time_units,	time units of data (in ms)		*
% *								*
% *	bin_width, 	binsize of psth vector in units of time_units
% *	 	   	(default value is 1)			*
% *     format,    data format. supported formats are:          *
% *                  'workcell', 'gdfcell'                      *
% *								*
% * Output: (optional)						*
% *								*
% *	pv, 		row vector containing the psth data	*
% *	 	  	if bin_width is a divider of the	*
% *		   	 length of data: rows(data)/bin_width	*
% *		  	else the psth_vec is shortened to the	*
% *		   	 next possible divider; it contains	*
% *		   	 data from 1:rows(data)/bin_width)	*
% *								*
% *	iv, 		index vector, containing the mid points	*
% *		  	of the bins; same length as psth_vec	*
% *								*
% * USES  :							*
% *								*
% * See Also: spar2psth(), binclip()				*
% *								*
% *								*
% * NOTES : for plotting of the PSTH: bar(iv,pv)		*
% *								*
% *								*
% * History:							*
% *								*
% *     (2) support for GDFCell format added                    *
% *        MD, 11.5.1997, Freiburg                              *
% *	(1) cleaned and commented; output in sp/secs		*
% *	     SG, 24.3.97 Jerusalem				*
% *	(0) first version					*
% *	     SG, 24.10.96, Jerusalem				*
% *								*
% * 								*
% *					gruen@hbf.huji.ac.il	*
% *								*
% *								*
% ***************************************************************

disp('calculating PSTH ...');

% ***************************************
% % check input arguments	        *
% *                             	*
% *					*
% ***************************************


if nargin < 3
 time_units = 1;
end

if nargin < 4
 bin_width = 1;
end

if nargin < 5
 format = 'gdfcell';
end


switch format
 
 % ***************************************
 % * binning for workcell format:	 *
 % *                                     *
 % ***************************************
 case 'workcell'

  m = cols(data);
  n = rows(data);


  if m>1 & n>1					% matrix
   if issparse(data)				% check if it is sparse	
    psth_vec	= (rsum(full(data)));
   else
    psth_vec	= (rsum(data));
   end
  elseif m>1 & n==1				% column vector
   psth_vec 	= data';
  elseif m==1 & n>1				% row vector
   psth_vec 	= data;
  end
  clear data;

                                                % *  binning by reshape	
  if rem(size(psth_vec,1),bin_width) == 0
    nb	   	= rows(psth_vec)/bin_width;
    if bin_width ~= 1
     psth_vec = (sum(reshape(psth_vec,bin_width,nb)))';
    end 
   else
    nb = floor(rows(psth_vec)/bin_width);
    disp(['WARNING::make_psth::BinWidthNotDivider::PSTHvecShortend']);
    psth_vec = (sum(reshape(psth_vec(1:nb*bin_width),bin_width,nb)))';
   end

 % ***************************************
 % * binning for gdfcell format:	 *
 % *                                     *
 % ***************************************
 case 'gdfcell'

  nb = floor(l/bin_width);
  if rem(l,bin_width) ~= 0
    disp(['WARNING::make_psth::BinWidthNotDivider::PSTHvecShortend']);
  end

  m=max(data(:,1));       % number of trials
  w=zeros(m,l);           % allocate 1-0 matrix

  i=find(data(:,2)<=l);  
  w(sub2ind([m,l],data(i,1),data(i,2)))=1; 
  psth_vec=reshape(w,m*bin_width,nb);
  psth_vec=sum(psth_vec,1)';
  
 otherwise
   error('MakePSTH::UnknownInputFormat');
end


% ***************************************
% *					*
% *  generate index vector		*
% *					*
% ***************************************

 if bin_width == 1
  iv 	= 1:nb;
 else
  iv 	= (1:nb)*bin_width - bin_width/2;
 end
 iv = iv';

% ***************************************
% *					*
% *  put into spikes/sec:		*
% *					*
% ***************************************

PSTHBinsizeInSeconds = bin_width * (time_units/1000);

pv = (psth_vec./m) / PSTHBinsizeInSeconds ;

clear psth_vec bin_width time_units;






