function mgabor=constructGabor(varargin)
%   creates normalized gabor kernel
%   creates a gabor filter
%
%
% Parameters to be passed as parameter-value pairs:
%
% %%%%% Obligatory Parameters %%%%%
%
%   f= spatial frequency of cosine
%   theta=orientation of cos wave in rad
%   sdx= width of gauss along cosine
%   sdy= width of gauss orthogonal to wave    
%   pha= phase of cosine
%   gamma_x= value of ellipsicity
%
%
% Henriette Walz 03/08
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de
%



% obligatory argument names
obligatoryArgs={'f','theta','sdy','sdx','pha','gamma_x'};  

% optional arguments names with default values
optionalArgs={''};


% Valid var names provided? Otherwise, error is generated. You can also
% supply functions to test the validity of the values, see checkPVP for
% details.
errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
    error(errorMessage,''); %used this format so that the '\n' are converted
end


% loading parameter value pairs into workspace, overwriting defaul values
pvpmod(varargin);

lambda=1/f;

sz_x=fix(6*sdx);
if mod(sz_x,2)==0, sz_x=sz_x+1;end
 
 
sz_y=fix(6*sdy);
if mod(sz_y,2)==0, sz_y=sz_y+1;end
 
[x y]=meshgrid(-fix(sz_x/2):fix(sz_x/2),fix(-sz_y/2):fix(sz_y/2));
 
% Rotation 
x_theta=x*cos(theta)+y*sin(theta);
y_theta=-x*sin(theta)+y*cos(theta);
 
tmp_gabor=exp(-.5*(x_theta.^2/sdx^2+gamma_x^2*y_theta.^2/sdy^2)).*cos(2*pi/lambda*x_theta+pha);

%normalize
tmp_mgabor=tmp_gabor-mean(reshape(tmp_gabor,[1 prod(size(tmp_gabor))]));
figure;
set(gcf,'name','gabor patch');
cmap=[zeros(10,1) , [1:-0.1:0.1]' ,zeros(10,1);[0.1:0.1:1]', zeros(10,1),zeros(10,1)];
imagesc(tmp_mgabor);
colormap(cmap);
colorbar;
mgabor=tmp_mgabor;

