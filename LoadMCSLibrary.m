fileList = getAllFiles(uigetdir('C:\NeuroShare\MCStreamSupport\MC_StreamMEX\'));
counter=1;
for ii=1:length(fileList)
    a=fileList{ii};
    if (a(end-1:end)=='.h')
        HeaderFile{counter}=fileList{ii};
        counter=counter+1;
    end
end

loadlibrary('MCStreamMEX64.dll','mex.h','addheader','matrix.h','addheader','iostream.h',...
    'addheader',HeaderFile{1},...
    'addheader',HeaderFile{2},...
    'addheader',HeaderFile{3},...
    'addheader',HeaderFile{4},...
    'addheader',HeaderFile{5},...
    'addheader',HeaderFile{6},...
    'addheader',HeaderFile{7},...
    'addheader',HeaderFile{8},...
    'addheader',HeaderFile{9},...
    'addheader',HeaderFile{10},...
    'addheader',HeaderFile{11},...
    'addheader',HeaderFile{12},...
    'addheader',HeaderFile{13},...
    'addheader',HeaderFile{14},...
    'addheader',HeaderFile{15},...
    'addheader',HeaderFile{16},...
    'addheader',HeaderFile{17},...
    'addheader',HeaderFile{18},...
    'addheader',HeaderFile{19},...
    'addheader',HeaderFile{20},...
    'addheader',HeaderFile{21},...
    'addheader',HeaderFile{22},...
    'addheader',HeaderFile{23},...
    'addheader',HeaderFile{24},...
    'addheader',HeaderFile{25},'alias','mcs');