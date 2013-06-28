%--------- OBSOLETE ------------
% able to generate inner-product matrix for SIP simulations


%{
tic

figure;

i=2, k=1;
while i<300 
    disp(['$$$$$$$$$$ tau = ' num2str(i) ' $$$$$$$$$$$$']);
    subplot(2,4,k);
    runDifferentFrequency(i);
    i=i*2,k=k+1;
end

toc

disp(['Elapsed time = ' num2str(toc-tic) 's']);

exit;
%}

%myFrequency = [4 10 20 50];
%myCC = [0 .3 .7 1];
sigma=10; kernel='gauss';
myFrequency = [2:2:10 15 20:10:50];
myCC = 0:.1:1;
myOnset=0:200:800;

%load('tmp/Scaling/Poisson10Hz10S100Neuron1Trial.mat');

B = [], stdMatrix = [], myGdf={}, myLabel={};
for i = 1:length(myFrequency)
    disp(['************* ' num2str(myFrequency(i)) 'Hz ****************']);
    for j = 1:length(myCC)
        disp(['------- ' num2str(myCC(j)) 'CC ---------']);
        filename = ['/home/bao/PointProcess/ParPoPro-1.2.5/tmp/'...
            '/SIP' num2str(myFrequency(i)) 'Hz'...
            num2str(myCC(j)) 'CC.mat'];
        %disp([num2str(i) ',' num2str(j)]);
        load(filename);
        myGdf(end+1)=num2cell(Data.gdf(find(Data.gdf(:,1)==1),2),1);
        myGdf(end+1)=num2cell(Data.gdf(find(Data.gdf(:,1)==2),2),1);
        %mySimilarity = getDistanceWithGaussKernel(filename, sigma);
        %B(i, j) = mySimilarity.score; B(j,i) = mySimilarity.score; 
        %stdMatrix(i, j) = mySimilarity.stdScore;
        myLabel(end+1)=cellstr([num2str(myFrequency(i)) 'Hz,' ...
            num2str(myCC(j)) 'cc,1']);
        myLabel(end+1)=cellstr([num2str(myFrequency(i)) 'Hz,' ...
            num2str(myCC(j)) 'cc,2']);
    end
end

for i = 1:length(myGdf)
    for j = i:length(myGdf)
        disp([num2str(i) ',' num2str(j)]);
        mySimilarity = getSimilarityWithKernel(cell2mat(myGdf(i)),...
            cell2mat(myGdf(j)),kernel,sigma);
        B(i, j) = mySimilarity.normScore; B(j,i) = mySimilarity.normScore; 
    end
end

%mySymbols=['+o*.xsd<>p'];

scaling(B,2);
%gname(myLabel);
%myColorbar={};
%for i = 1:length(myFrequency)
%    myColorbar(end+1) = {[num2str(myFrequency(i)) 'Hz']};
%end
%colorbar('YTickLabel', myColorbar);

%scaling(B,3);
%gname(myLabel);
