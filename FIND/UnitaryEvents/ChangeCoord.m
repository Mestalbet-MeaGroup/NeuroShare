function [k,nx,ny]= ChangCoord(nx,ny,i,j)
% [k,nx,ny]= ChangCoord(nx,ny,i,j): Change Coordinates for subplot to address a specific x,y location
% 
% input: 
%        nx  : total number of plots in x-direction
%        ny  : total number of plots in y-direction
%        i,j : i<=nx: index in row, j,+ny: index in column
%
% output: 
%        nx  : total number of plots in x-direction
%        ny  : total number of plots in y-direction
%         k  : index as required by subplot (nx,ny,k)
%              (running continously along rows)
%
% Example: [1,1]  [1,2] [1,3] [1,4]
%          [2,1]  [2,2] [2,3] [2,4]
%
%
%   ==>     [1]    [2]   [3]   [4]
%           [5]    [6]   [7]   [8]
%
% History: SG, 27.2.02, FfM
%

k = j + (i-1)*nx;
