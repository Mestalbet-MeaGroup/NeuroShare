%Batch converts all csv files in working directory 

files = dir ('*.csv');
filenames = {files.name};

matlabpool open 2
counter=1;
fileList = getAllFiles(uigetdir);
for i=1:length(fileList)
    a=fileList{i};
    if a(end-3:end)=='.csv'
        CsvFiles{counter}=a;
        counter=counter+1;
    end
end

parfor i=1:length(filenames)
    importfile(CsvFiles(i));
end

matlabpool close;