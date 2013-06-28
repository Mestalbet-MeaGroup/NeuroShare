function scaling(B,dimension)
%scaling generates the multidimensional scaling plot for the given 
%        inner product matrix
%
%   Usage: scaling(B, dimension)
%
%   @param B - symmetric matrix containing pairwise inner products as 
%              similarity measure
%   @param dimension - 2 or 3 to specify the dimension of plot

%A=rand(100);

% my symmetric distance matrix
%B=A+A';


[O D]=eig(B);

% check for the maximum eigenvalue
myD=[(1:length(diag(D)))' diag(D)];
myD=sortrows(myD,2);

O = real(sqrtm(D))*O';

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
colorInterval=15; % parameterizable
myFontSize = 14; % parameterizable
myMarkerSize = 10; % parameterizable

%---------------------------------------------

colorIndex=1; symbolIndex=1;
nTrials=size(B,2)/(length(varColor)*length(varSymbol)); 


for i=1:size(B,2)
    % if symbols are all used, reset to the first one
    if symbolIndex > length(varSymbol) symbolIndex = 1; end 

    if dimension == 2
        plot(O(myD(end,1), i), O(myD(end-1,1), i), mySymbols(symbolIndex), ...
            'Color', cm(colorIndex,:), 'MarkerSize', myMarkerSize);
    
    elseif dimension == 3
        plot3(O(myD(end,1), i), O(myD(end-1,1), i), O(myD(end-2, 1), i), ...
            mySymbols(symbolIndex), 'Color', cm(colorIndex,:));
        grid on;
        zlabel(['3rd coordinate eigenvalue=' num2str(myD(end-2,2))]);
    else

        error('Dimension must be either 2 or 3...');
    end
    
    hold on;
    symbolIndex = symbolIndex + 1;
    
    % if all trials are plotted, change the color
    if mod(i,length(varSymbol)*nTrials) == 0 
        colorIndex = colorIndex + colorInterval; 
    end
end
    
    
legend(num2str(varSymbol'),'Location','NorthWest'); 

% specify the labels of colorbar
myColorbar={};
for i = 1:length(varColor) 
    myColorbar(end+1) = {[num2str(varColor(i)) myUnit]}; 
end
c=colorbar(cm);
set(c, 'YTick', 1:colorInterval:64);
set(c, 'YTickLabel', myColorbar);


xlabel(['1st coordinate eigenvalue=' num2str(myD(end,2))],'fontsize',myFontSize);
ylabel(['2nd coordinate eigenvalue=' num2str(myD(end-1,2))],'fontsize',myFontSize);
%title(['\sigma = ' num2str(sigma)]);
set(gca,'fontsize',myFontSize);

%myD(end)/sum(myD)


