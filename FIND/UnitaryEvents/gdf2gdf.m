function gdf2gdf(fn_in,tu_in,tu_out)
% gdf2gdf(fn_in,tu_in,tu_out)
% ***************************************************************
% *                                                             *
% * Convert input gdf data with time resolution tu_in to        *
% * gdf data with time resolution tu_out.                       *
% * It is assumed that the time unit of the input gdf file is   *
% * equal to the input time resolution.                         *
% * The time unit of the output file is equal to its time       *
% * resolution by definition.                                   *
% * The output file name is the input file name with a string   *
% * indicating the new resolution/unit inserted before the last *
% * dot '.' .                                                   *
% *                                                             *
% * Usage:                                                      *
% *        fn_in,  input file name including extension          *
% *        tu_in,  input time resolution in ms                  *
% *        tu_out, output time resolution in ms                 *
% *        fn_out, output file name including extension         *
% *                                                             *
% * History:							*
% *         (0) first version                                   *
% *            MD, 28.7.1997                                    * 
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@hbf.huji.ac.il               *
% *                                                             *
% ***************************************************************
BinMethod='IDLVersion';  %'leftclosed'



% **************************************************
% * check compatibility of time units              *
% *                                                *
% *                                                *
% **************************************************
b=tu_out/tu_in;
if b-fix(b)~=0
 error('GDF2GDF::BinsizeNotIntegerMultiple');
end


% **************************************************
% * generate output file name from input           *
% * name                                           *
% *                                                *
% **************************************************
i=findstr(fn_in,'.');
if isempty(i)
 error('GDF2GDF::CannotLocateDot');
end
i=i(length(i));
fn_out=cat(2,fn_in(1:i-1),'-',num2str(tu_out),'ms',fn_in(i:length(fn_in)));


% **************************************************
% * read input gdf file                            *
% *                                                *
% *                                                *
% **************************************************
[fid_in, msg]=fopen(fn_in, 'r');
if fid_in~=-1
  disp(cat(2,'reading',' ',fn_in,' ...'));
  gdf=fscanf (fid_in, '%f %f', [2 inf])';
  fclose(fid_in);
else
 error('GDF2GDF::CannotFOpenForReading');
end


% **************************************************
% * bin data with selected method                  *
% *                                                *
% *                                                *
% **************************************************
switch BinMethod

 case 'leftclosed'
  gdf(:,2)=floor(gdf(:,2)/b);

 case 'IDLVersion'
  gdf(:,2)=round(gdf(:,2)/b);

 otherwise
  error('GDF2GDF::UnknownBinMethod');
end


% **************************************************
% * write output gdf file                          *
% *                                                *
% *                                                *
% **************************************************
[fid_in, msg]=fopen(fn_out, 'w');
if fid_in~=-1
  disp(cat(2,'writing ',fn_out,' ...'));
  fprintf(fid_in, '%d\t%d\n', gdf');
  fclose(fid_in);
else
 error('GDF2GDF::CannotFOpenForWriting');
end

