function w=orientv(v,o)

if ~strcmp(orientation(v),o)
 w=v';
else
 w=v;
end
