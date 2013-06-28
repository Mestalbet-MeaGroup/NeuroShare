function rs = subrect(r,m,n,i,dx,dy)
% subrect, return rectangle for a sub-figure (normalized coordinates)
%          and may be used to specify the position of the axes
%          in the current figure
%  
%  Generates a vector for a rectangle,
%  which defines the new plot_region in normalized coordinates
%  input :
%          r : rectangle defining sub-figure ([x,y,w,h] in norm. coord.)
%          m : number of rows
%	   n : number of columns
%	   i : number of section (count along rows from left to tright)
%          dx : x-distance between plots (normalized coordinates)
%          dy : y-distance between plots (normalized coordinates)
%
%
%  example: f   = figure;
%	    pos = subrect(r,4,1,4,0,0.05);
%	    a   = axes;
%           set(gca, 'Position', pos);
%           ...
%
% See also: normxdist,  normydist
%       
% History:
%          (1) rectangle added: extended version of subfigure.m
%              3.11.1996 Markus Diesmann, Freiburg
%          (0) first version
%              July 1996, Markus Diesmann, Sonja Gruen, Jerusalem


x=r(1);
y=r(2);
w=r(3);
h=r(4);

ndx=n-1;
ndy=m-1;

rw=(w-ndx*dx)/n;
rh=(h-ndy*dy)/m;


in=rem(i,n);
if in==0
 in = n;
end
im = ceil(i/n);

rx=x+(in-1)*(rw+dx);
ry=y+(im-1)*(rh+dy);

rs=[rx,ry,rw,rh];
