function retval = subfigure(m,n,i)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Generates a vector for a rectangle,
%  which defines the new plot_region in normalized coordinates
%  input : m : number of rows
%	   n : number of columns
%	   i : number of section (count along rows from left to tright)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

y_dist	= 0.0;			% distance from upper and lower side
x_dist  = 0.0;			% distance from left and right side

y_delta = (1-(2*y_dist))/m;
x_delta = (1-(2*x_dist))/n;

if rem(i,n) == 0
 act_n = n;
else
 act_n   = rem(i,n);
end

act_m	= ceil(i/n);
retval  = [x_dist+(act_n-1)*x_delta, 1-y_dist-(act_m*y_delta),...
           x_delta, y_delta];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

