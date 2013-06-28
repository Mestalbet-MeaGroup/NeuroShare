function checkstruct(strct,expected);
% CheckStruct, check struct members

if ~isstruct(strct)
 error('CheckStruct::NotAStruct');
end

contained = fieldnames(strct);

for i=1:size(expected,1)
 if ~inlist(contained,expected{i})
   error('CheckStruct::UnknownField');
 end
end