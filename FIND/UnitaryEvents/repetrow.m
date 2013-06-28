function w=repetrow(v,n,l)
% w=repetrow(v,m,l), fast restricted version of repetition
% ***************************************************************
% *                                                             *
% * Usage:                                                      *
% *        see repetition                                       *
% *                                                             *
% * repmat, reshape                                             *
% * History:                                                    *
% *         (1) version 5 matrix operations                     *
% *            MD, 4.5.97, Freiburg                             * 
% *         (0) first version                                   *
% *            MD, 1.4.1997, Freiburg                           *
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@hbf.huji.ac.il               *
% *                                                             *
% ***************************************************************


if (n~=0) & (l~=0)
 lv=length(v);
 if l==lv
   w=repmat(v,1,n);
  else
   m=floor(lv/l);                       % number of segments
   w=reshape(repmat(reshape(v,l,m),n,1),1,l*n*m);   
  end
else
 w=[];
end

% ***************************************************************
% * Historical Section                                          *
% *                                                             *
% *                                                             *
% ***************************************************************


%
% last matlab 4 version
% 
%
%compiled=0;
%
%if ~compiled
%
% if (n~=0) & (l~=0)
%  lv=length(v);
%  if l==lv
%   i=(1:lv)';
%   w=part(v,i(:,ones(1,n)),'row');       % outer product
%  else
%   m=floor(lv/l);                       % number of segments
%   w=part(v,copy(reshape(1:m*l,l,m)',1,n)','row'); 
%  end
% else
%  w=[];
% end
%
%else
%
% lv=length(v);
% m=floor(lv/l);       % number of segments
% w=zeros(1,n*l*m);
% nl=n*l;
% for i=0:(m-1)        % segments
%  inl=i*nl;
%  il=i*l;
%  for k=1:l           % length of segments
%   e=v( il+k );
%   inlk=inl+k;
%   for j=0:l:(n-1)*l  % repetitions
%    w(inlk+j) = e;
%   end
%  end
% end
%
%end

