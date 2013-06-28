function Similarity = getSimilarityWithKernel(train1, train2, kernel, sigma)
%getSimilarityWithKernel calculates the similarity score between 2 given
%                        spike trains, the score is the inner product of
%                        the 2 spike trains convolved with a specified 
%                        kernel
%
%   Usage: Similarity = getSimilarityWithKernel(train1, train2, kernel, sigma)
%
%   @param train1 - a vector including all the spike times of spike train 1
%   @param train1 - a vector including all the spike times of spike train 2
%   @param kernel - type of kernel used to filter the original spike
%                   trains, choices are 'gauss' and 'exp'
%   @param sigma - kernel width in milliseconds, i.e. sigma in Gaussian
%                  kernel or tau in exponential kernel
%
%   @return Similarity - a struct containing the following fields:
%           
%           r1 - spike count of the 1st spike train
%           r2 - spike count of the 2nd spike train
%           normScore - similarity score normalized by the product of the
%                       2 vector norms
%           rawScore - original similarity score as the inner product


tic

rawScore = 0;
for i = 1:length(train1)
    for j = 1:length(train2)
        tau = train1(i) - train2(j);
        if strcmp(kernel, 'gauss')
            rawScore = rawScore + normpdf(tau, 0, sigma*sqrt(2));
        elseif strcmp(kernel, 'exp')
            rawScore = rawScore + 0.5*exppdf(tau, sigma);
        end
    end
end

xNorm=0;
for i = 1:length(train1)
    for j = 1:length(train1)
        tau = train1(i) - train1(j);
        if strcmp(kernel, 'gauss')
            xNorm = xNorm + normpdf(tau, 0, sigma*sqrt(2));
        elseif strcmp(kernel, 'exp')
            xNorm = xNorm + 0.5*exppdf(tau, sigma);
        end
    end
end

yNorm=0;
for i = 1:length(train2)
    for j = 1:length(train2)
        tau = train2(i) - train2(j);
        if strcmp(kernel, 'gauss')
            yNorm = yNorm + normpdf(tau, 0, sigma*sqrt(2));
        elseif strcmp(kernel, 'exp')
            yNorm = yNorm + 0.5*exppdf(tau, sigma);
        end
    end
end

toc

Similarity.r1 = length(train1);
Similarity.r2 = length(train2);
Similarity.normScore = rawScore/sqrt(xNorm*yNorm);
Similarity.rawScore = rawScore;

disp(['Normalized score = ' num2str(Similarity.normScore)]);
