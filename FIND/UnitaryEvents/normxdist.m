function rd = normxdist(f,d)
% normxdist, return normalized x distance for d in cm in figure f 

set(f,'Units','centimeters');
p=get(f,'Position');
set(f,'Units','pixels');

rd=d/p(3);