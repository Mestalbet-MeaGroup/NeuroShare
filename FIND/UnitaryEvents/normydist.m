function rd = normydist(f,d)
% normxdist, return normalized y distance for d in cm in figure f 

set(f,'Units','centimeters');
p=get(f,'Position');
set(f,'Units','pixels');

rd=d/p(4);
