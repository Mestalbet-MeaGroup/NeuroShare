function o=orientation(v)

r=rows(v); c=cols(v);

if r==1 & c==1
 o='none';
elseif r~=1 & c~=1
 o='matrix';
elseif r~=1 & c==1
 o='col';
elseif r==1 & c~=1
 o='row';
end;