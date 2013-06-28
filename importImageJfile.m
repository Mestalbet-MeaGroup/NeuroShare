function data = importImageJfile()
% Reads csv tables produced from ImageJ into matlab.

[fileToRead1,filepath] = uigetfile('*.csv');
% Import the file
% filepath='C:\CalciumImagingMEArecordings\10Jun2010\';
% fileToRead1='RatioTable_4. CH22_centered_baseline-2.csv';

[data,ss,sss] = xlsread([filepath fileToRead1]);
    
%     if isempty(strfind(fileToRead1,'MATLAB'))
%       time=data(:,2).*(8.6400e+004);
%     else
%       time=data(:,2);
%     end

data=data(:,3:4:end);
% save([filepath fileToRead1(1:end-4) '.mat'],'data','time');
end