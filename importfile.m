function importfile(varargin)
% Imports Ca imaging tables from CSV into matlab (Matt data).
 if isempty(varargin)
    [fileToRead1,filepath] = uigetfile('*.csv');
    [data,ss,sss] = xlsread([filepath fileToRead1]);
    clear ss; clear sss;   
        if isempty(strfind(fileToRead1,'MATLAB'))
            time=data(:,2).*(8.6400e+004);
        else
            time=data(:,2);
        end
    data=data(:,3:3:end);
    save([filepath fileToRead1(1:end-4) '.mat'],'data','time');
 else
    [data,ss,sss] = xlsread(varargin{1,1}{1,1});
    clear ss; clear sss;   
        if isempty(strfind(varargin{1,1}{1,1},'MATLAB'))
            time=data(:,2).*(8.6400e+004);
        else
            time=data(:,2);
        end
    data=data(:,3:3:end);
    save([varargin{1,1}{1,1}(1:end-4) '.mat'],'data','time');

 end
end