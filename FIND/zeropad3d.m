function [out1,out2]=zeropad3d(in1,in2)
%zero padding for 3d data (typically segment data)
%
% Markus Nenniger 2006
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

if size(in1,1) > size(in2,1)
    in2=cat(1,in2,zeros(size(in1,1)-size(in2,1),size(in2,2),size(in2,3)));
elseif size(in1,1) < size(in2,1)
    in1=cat(1,in1,zeros(size(in2,1)-size(in1,1),size(in1,2),size(in1,3)));
end

if size(in1,2) > size(in2,2)
    in2=cat(2,in2,zeros(size(in2,1),size(in1,2)-size(in2,2),size(in2,3)));
elseif size(in1,2) < size(in2,2)
    in1=cat(2,in1,zeros(size(in1,1),size(in2,2)-size(in1,2),size(in1,3)));
end

out1=in1;
out2=in2;
