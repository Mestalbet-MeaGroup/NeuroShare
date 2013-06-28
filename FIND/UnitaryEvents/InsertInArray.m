function aa = InsertInArray(a,b,index,orient)
% aa = InsertInArray(a,b,index,orient): insert b in a at index
%                                       along dimension d
% ***************************************************************
% *                                                             *
% * Usage:                                                      *
% *       a    , array (matrix), in which b has to be inserted  *
% *       b    , array (matrix) to insert                       *
% *       index, index at which b should start
% *       orient, 1: insert along colum
% *               2: insert along row
% *                                                             *
% * output: 
% *       aa , output matrix
% *
% *                                                             * 
% * History:                                                    *
% *         (0) first version                                   *
% *            SG, 22.3.02, FFM
% *                                                             *
% *                                                             *
% *                          gruen@mpih-frankfurt.mpg.de        *
% *                                                             *
% ***************************************************************

sa = size(a);
sb = size(b);

if orient == 2 % insert along row
 if sa(1) ~= sb(1)
  error('InsertInArray::ColDimensionsDoNotAgree')
 end
 a1tmp = a(:,1:index-1);
 a2tmp = a(:,index:end);
 aa    = cat(2,a1tmp,b,a2tmp);
end

if orient == 1 % insert along colum
 if sa(2) ~= sb(2)
  error('InsertInArray::RowDimensionsDoNotAgree')
 end
 a1tmp = a(1:index-1,:);
 a2tmp = a(index:end,:);
 aa    = cat(1,a1tmp,b,a2tmp);
end 













