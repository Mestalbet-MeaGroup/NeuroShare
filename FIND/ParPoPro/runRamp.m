%runRamp calculates the inner-product matrix

%----------- PARAMETERIZATION ----------------

myOnset=0:200:800;
sigma=50;
kernel = 'gauss';

%---------------------------------------------

mySpike={};
for nOnset=1:length(myOnset)
    % load the file containing spike times
    load(['tmp/ramp/ramp' num2str(myOnset(nOnset)) 'Trial10.mat']);
    markers = find(Data.gdf(:,1)==Data.TrialParameters.Marker);
    duration = Data.TrialParameters.TrialDurationMs;
    
    % store gdf data to mySpike
    for nTrial=1:Data.TrialParameters.NumberOfTrials
        if nTrial < length(markers)
            myGdf = Data.gdf(markers(nTrial):markers(nTrial+1), :);
        else
            myGdf = Data.gdf(markers(end):end, :);
        end
        for nProcess=1:Data.TrialParameters.NumberOfProcesses
            % duration MUST be subtracted from the subsequent trials
            mySpike(end+1)=num2cell(myGdf(...
                find(myGdf(:,1)==nProcess),2)-duration*(nTrial-1),1);
        end
    end
end

tic

% calculate the inner products
%{
for i=1:size(mySpike,2)
    for j=i:size(mySpike,2)
        disp([num2str(i) ',' num2str(j)]);
        mySimilarity = getSimilarityWithKernel(cell2mat(mySpike(i)),...
            cell2mat(mySpike(j)), kernel, sigma);
        normB(i, j) = mySimilarity.normScore; normB(j,i) = mySimilarity.normScore; 
        rawB(i, j) = mySimilarity.rawScore; rawB(j,i) = mySimilarity.rawScore; 
    end
end
%}

% store rate vectors in myProfile
myProfile={};
for nOnset=1:length(myOnset)
    rateProfile = load(['Data/RateNonStatRamp' ...
        num2str(myOnset(nOnset)) '.dat']);

    for iSlope=1:size(rateProfile, 2)
        myProfile(end+1) = num2cell(rateProfile(:, iSlope), 1);
    end
end


tau = 100; % parameterizable
samplingFactor = 100; % parameterizable

index = [1:5 51:55 101:105 151:155 201:205];
for i = 1:length(index)
    myMat = cell2mat(mySpike(i));
    
    % initializing a binary matrix for spike timing
    myMatrix = zeros(1, Data.TrialParameters.TrialDurationMs*100/samplingFactor);
    for i = 1:length(myMat)
        myMatrix(1, myMat(i)*100/samplingFactor) = 1;
    end
    
    % Gaussian
    trainFiltered=conv(myMatrix,normpdf(-5*tau:0.01*samplingFactor:5*tau,0,tau));
    trainFiltered=trainFiltered(500/samplingFactor*tau+1:end-500/samplingFactor*tau);
    
    myProfile(end+1) = num2cell(trainFiltered, 2);
end

% calculate the inner products of rate functions
for i = 1:size(myProfile, 2)
    for j = i:size(myProfile, 2)
        B(i, j) = dot(cell2mat(myProfile(i)), cell2mat(myProfile(j))); 
        B(j, i) = dot(cell2mat(myProfile(i)), cell2mat(myProfile(j)));
        normB(i, j) = dot(cell2mat(myProfile(i)), cell2mat(myProfile(j)))...
            / (norm(cell2mat(myProfile(i)))*norm(cell2mat(myProfile(j))));
        normB(j, i) = normB(i, j);
        rawB(i, j) = dot(cell2mat(myProfile(i)), cell2mat(myProfile(j)));
        rawB(j, i) = rawB(i, j);
    end
end
    

toc
%{
figure;
scaling(normB,2);
title(['Normalized ' kernel ' sigma=' num2str(sigma)]);

figure;
scaling(rawB,2);
title(['Unnormalized ' kernel ' sigma=' num2str(sigma)]);
%}

%t=toc


%------- plot rate profile together with simulated spike trains ---------

[O D]=eig(B);

% check for the maximum eigenvalue
myD=[(1:length(diag(D)))' diag(D)];
myD=sortrows(myD,2);

X = real(sqrtm(D))*O';

