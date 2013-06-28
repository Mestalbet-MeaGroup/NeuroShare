function d = getEuclideanDistance(filename, binSize)
%getEuclideanDistance Calculate the Euclidean distance between 2 vectors
%                      built from the spike times
%
%   Usage: d = getEuclideanDistance(filename, binSize)
%
%   @param filename - data saved from the simulation (ideally a .mat file
%                     including a Data struct)
%   @param binSize - bin width specified in ms
%
%   @return d - the Euclidean distance


load(filename);

% initializing a binary matrix
myMatrix = zeros(Data.TrialParameters.NumberOfProcesses, ...
    Data.TrialParameters.TrialDurationMs);
for i = 1:size(Data.gdf, 1)
    if Data.gdf(i,1) ~= Data.TrialParameters.Marker
        myMatrix(Data.gdf(i,1), Data.gdf(i,2)) = 1;
    end
end

% binning
edges = 1:binSize:Data.TrialParameters.TrialDurationMs;
myBinnedMatrix = [];
for i = 1:size(edges, 2) - 1
    myBinnedMatrix(:, i) = sum(myMatrix(:,edges(i):edges(i+1)-1), 2);
end
myBinnedMatrix(:, size(edges, 2)) = sum(myMatrix(:, ...
    edges(end):Data.TrialParameters.TrialDurationMs), 2);

% plotting
figure;
for i = 1:size(myBinnedMatrix,1)
    plot(myBinnedMatrix(i,:).*i, '.');
    hold on;
end
%plot(myMatrix(2,:).*2, '.');
%ylim([.8 2.2]);

d = sum((myBinnedMatrix(1,:) - myBinnedMatrix(2,:)).^2).^0.5
