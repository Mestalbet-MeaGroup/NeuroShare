function plotCenter(B)
%plotCenter plots scaling results together with all the points within one
%           cluster linked to the centroid of the cluster
%
%   Usage: plotCenter(B);
%
%   @param B - symmetric matrix containing pairwise inner products as 
%              similarity measure

%B=normB;
[O D]=eig(B);

% check for the maximum eigenvalue
myD=[(1:length(diag(D)))' diag(D)];
myD=sortrows(myD,2);

X = real(sqrtm(D))*O';

%----------- PARAMETERIZATION ----------------
%figure;
mySymbols=['+o*.xsd<>ph']; % cc/slope
cm=colormap(autumn); % Hz
myFrequency = [2:2:10 15 20:10:50];
myCC = 0:.1:1;
myOnset=0:200:800;
mySlope=[.5 1 2 5 10];
%sigma=1;

varColor=myOnset; varSymbol=mySlope; % parameterizable
myUnit = 'ms'; % ms or Hz

colorIndex=1; %symbolIndex=2;
colorInterval=15; % parameterizable
nTrials=size(B,2)/(length(varColor)*length(varSymbol)); 
myColors=colorIndex:colorInterval:64;
firstSymbol = 3; % parameterizable, starting from the 3rd slope value

%---------------------------------------------


for symbolIndex = firstSymbol:firstSymbol+1

% subset of points
index=symbolIndex:5:250;

% subplot with points belonging to a certain slope
subplot(2,2,2*(symbolIndex-2)-1);

colorIndex=1;
for i=1:length(index)
    plot(X(myD(end,1), index(i)), X(myD(end-1,1), index(i)), mySymbols(symbolIndex), ...
        'Color', cm(colorIndex,:));
    hold on;
    
    if mod(i,nTrials) == 0 
        colorIndex = colorIndex + colorInterval; 
    end
end

xlabel('1st coordinate','fontsize',16);
ylabel('2nd coordinate','fontsize',16);
xlim([0.5 1]);
set(gca,'fontsize',16);

text(0.9, 0.8, ['Exp.(\tau=100ms) slope = ' ...
    num2str(mySlope(symbolIndex))], 'fontsize', 18);

% subplot with centroids of clusters
subplot(2,2,2*(symbolIndex-2));
colorIndex=1;


for i=1:length(index)
    plot(X(myD(end,1), index(i)), X(myD(end-1,1), index(i)), mySymbols(symbolIndex), ...
        'Color', cm(colorIndex,:));
    hold on;
    
    if mod(i,nTrials) == 0 
        colorIndex = colorIndex + colorInterval; 
        centerMatrix(10, ceil(i/nTrials), 1)=X(myD(end,1), index(i));
        centerMatrix(10, ceil(i/nTrials), 2)=X(myD(end-1,1), index(i));
    else
        centerMatrix(mod(i,nTrials), ceil(i/nTrials), 1)=X(myD(end,1), index(i));
        centerMatrix(mod(i,nTrials), ceil(i/nTrials), 2)=X(myD(end-1,1), index(i));
    end
    
end

% calculate coordinates for the centroids
centerPoints=mean(centerMatrix, 1);

for i=1:size(centerMatrix, 2)
    % plot centroids
    plot(centerPoints(:,i,1), centerPoints(:,i,2),...
        'k+','markersize',12);
    % link points to the centroid
    for j=1:nTrials
        line([centerPoints(:,i,1) centerMatrix(j,i,1)], ...
             [centerPoints(:,i,2) centerMatrix(j,i,2)], ...
             'Color', cm(myColors(i),:));
        
    end
end

xlabel('1st coordinate','fontsize',16);
ylabel('2nd coordinate','fontsize',16);
xlim([0.5 1]);
set(gca,'fontsize',16);

end
