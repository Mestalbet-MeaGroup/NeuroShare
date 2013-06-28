function i=inlist(c,s)

i=0;
for j=1:length(c)
 if strcmp(c{j},s)
  i=j;
  break
 end
end
