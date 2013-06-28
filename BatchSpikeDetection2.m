function BatchSpikeDetection2()
% matlabpool open 2;
hostname = char( getHostName( java.net.InetAddress.getLocalHost ) );
if hostname=='CZC2X'
    addpath('D:\Users\zeiss\Documents\GitHub\NeuroShare\FIND');
else
    if hostname=='NoahLaptop'
        addpath('D:\Users\zeiss\Documents\GitHub\NeuroShare\FIND');
    else
        error('You need the assert function from FIND toolbox. Change the path for this computer');
    end
end

fileList = getAllFiles(uigetdir);
counter=1;
for ii=1:length(fileList)
    a=fileList{ii};
    if (a(end-3:end)=='.mcd')
        McdFiles{counter}=fileList{ii};
        counter=counter+1;
    end
end
% spmd
for j=drange(1:length(McdFiles))
    SpikeDetection_mod4Batch(McdFiles{j});
end
% end
for i=length(fileList)
    [~,~,triggers]=GetTriggers(fileList{i});
    save([fileList{i}(1:end-4) '.mat'],'triggers','-append');
end

if hostname=='CZC2X'
    rmpath('D:\Users\zeiss\Documents\GitHub\NeuroShare\FIND');
end
if hostname=='NoahLaptop'
    rmpath('D:\Users\zeiss\Documents\GitHub\NeuroShare\FIND');
end
% matlabpool close;
end