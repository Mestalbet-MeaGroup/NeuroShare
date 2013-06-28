function runDifferentFrequency(sigma)
%------------------ OBSOLETE -------------------
% written for SIP simulations

myFrequency = [2:2:10 15 20:10:50];
myCC = 0:.1:1;

meanMatrix = [], stdMatrix = [];
for i = 1:length(myFrequency)
    disp(['************* ' num2str(myFrequency(i)) 'Hz ****************']);
    for j = 1:length(myCC)
        disp(['------- ' num2str(myCC(j)) 'CC ---------']);
        filename = ['/home/bao/PointProcess/ParPoPro-1.2.5/tmp/'...
            '10Simulations/SIP' num2str(myFrequency(i)) 'Hz'...
            num2str(myCC(j)) 'CC.mat'];

        mySimilarity = getDistanceWithKernel(filename, 'gauss', sigma);
        meanMatrix(i, j) = mySimilarity.meanScore;
        stdMatrix(i, j) = mySimilarity.stdScore;
        
        % normalization
        %n = mean([mySimilarity.r1 mySimilarity.r2]) * ...
        %    normpdf(0, 0, sigma*sqrt(2));
        %myMatrix(i, j) = myMatrix()
        
    end
end

%figure;
%imagesc(myFrequency,myCC,myMatrix); colorbar;
%xlabel('Hz');
%ylabel('CC');

cm = gray(length(myFrequency) + 1);
for i = 1:length(myFrequency)
    %plot(myCC, myMatrix(i,:), 'Color', cm(i,:));
    errorbar(myCC, meanMatrix(i,:), stdMatrix(i,:), '-', 'Color', cm(i,:));
    hold on;
end

title(['(filtered with Gauss kernel \sigma = ' num2str(sigma) ')']);
xlabel('Correlation coefficient');
ylabel('Similarity');
xlim([0 inf]);
ylim([0 inf]);

myLegend = {};
for i = 1:length(myFrequency)
    myLegend(end+1) = {[num2str(myFrequency(i)) 'Hz']};
end
legend(myLegend, 'Location', 'NorthWest');
