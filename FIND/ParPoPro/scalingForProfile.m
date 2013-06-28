function scalingForProfile
%scalingForProfile plots the scaling result for the rate function

clear;

%----------- PARAMETERIZATION ----------------

myOnset=0:200:800; % parameterizable
%sigma=100; % in milliseconds
%kernel = 'gauss'; % 'gauss' or 'exp'

%---------------------------------------------

% store rate vectors in myProfile
myProfile={};
for nOnset=1:length(myOnset)
    rateProfile = load(['Data/RateNonStatRamp' ...
        num2str(myOnset(nOnset)) '.dat']);

    for iSlope=1:size(rateProfile, 2)
        myProfile(end+1) = num2cell(rateProfile(:, iSlope), 1);
    end
end

% calculate the inner products of rate functions
for i = 1:size(myProfile, 2)
    for j = i:size(myProfile, 2)
        B(i, j) = dot(cell2mat(myProfile(i)), cell2mat(myProfile(j))); 
        B(j, i) = dot(cell2mat(myProfile(i)), cell2mat(myProfile(j)));
        normB(i, j) = dot(cell2mat(myProfile(i)), cell2mat(myProfile(j)))...
            / (norm(cell2mat(myProfile(i)))*norm(cell2mat(myProfile(j))));
        normB(j, i) = normB(i, j);
    end
end

B = normB;
[O D]=eig(B);
X = real(sqrtm(D))*O';

% check for the maximum eigenvalue
myD=[(1:length(diag(D)))' diag(D)];
myD=sortrows(myD,2);

%----------- PARAMETERIZATION ----------------
%figure;
mySymbols=['+o*.xsd<>ph']; % cc/slope
cm=colormap(autumn); % Hz
myFrequency = [2:2:10 15 20:10:50];
myOnset=0:200:800;
mySlope=[.5 1 2 5 10];

colorIndex=1; symbolIndex=1;
colorInterval=15; % parameterizable
nTrials=1; % always 1

myFontSize = 14; % parameterizable

%---------------------------------------------


% color code for firing rate
for i=1:size(B,2)
    % if symbols are all used, reset to the first one
    if symbolIndex > length(mySlope) symbolIndex = 1; end
    
    plot(X(myD(end,1), i), X(myD(end-1,1), i),  ...
        mySymbols(symbolIndex), ...
        'Color', cm(colorIndex,:));%,'MarkerSize',12);
    %plot3(X(myD(end,1), i), X(myD(end-1,1), i), X(myD(end-2,1), i),...
    %    mySymbols(symbolIndex), 'color', cm(colorIndex,:));
    %grid on;
    
    hold on;
    symbolIndex = symbolIndex + 1;
    
    % if all trials are plotted, change the color
    if mod(i,length(mySlope)*nTrials) == 0 
        colorIndex = colorIndex + colorInterval; 
    end
end

legend(num2str(mySlope'),'Location','NorthWest');

% specify the labels of colorbar
myColorbar={};
for i = 1:length(myOnset)
    myColorbar(end+1) = {[num2str(myOnset(i)) 'ms']};
end
c=colorbar(cm);
set(c, 'YTick', 1:colorInterval:64);
set(c, 'YTickLabel', myColorbar);
set(gca,'fontsize',myFontSize);

xlabel(['1st coordinate eigenvalue=' num2str(myD(end,2))],'fontsize',myFontSize);
ylabel(['2nd coordinate eigenvalue=' num2str(myD(end-1,2))],'fontsize',myFontSize);
%title('Scaling of unnormalized rate profiles');

