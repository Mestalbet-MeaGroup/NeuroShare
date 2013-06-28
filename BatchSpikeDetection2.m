function BatchSpikeDetection2()
% matlabpool open 2;
addpath('C:\NeuroShare\FIND');
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

% matlabpool close;
end