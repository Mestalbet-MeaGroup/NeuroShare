
fname = '/home/gruen/matlab/Tilmann/JitterGDF/UEr3f201-trigger7'  %'UEr3f201-trigger1'
eval(['load ' fname])

fname

binsize = DataFile(1).Analysis.Binsize;
Tslid   = DataFile(1).Analysis.TSlid;
alpha   = DataFile(1).Analysis.Alpha;
jit     = 0;


shiftWin= 10;              		 % Tslid shifted in steps of shiftWin
shiftWin= floor(shiftWin/binsize);	 % in bins,if binsize would
                                         % not be 1 ms!
                        % if shiftWin = binsize: 'sliding window'
                        % if shiftWin > binsize: 'stepping window',

nbins   = Bin.Results.TrialLengthInBins;
nTrials = Cut.Results.NumberOfTrials;

nNeuron = Cut.Results.NumberOfNeurons;

% indicates bin of trigger event
trig    = abs(DataFile(1).TPre)/binsize;

% initialize cell-array for original neuron data
WorkCell    = cell(1,nNeuron);
WorkCell{1,1}        = zeros(nbins,nTrials);    
WorkCell{1,2}        = zeros(nbins,nTrials);

% put spikes into WorkCell
for i=1:nTrials
 tmpidx1 = find(Bin.Results.Data{1,1}(:,1) == i);
 WorkCell{1,1}(Bin.Results.Data{1,1}(tmpidx1,2),i) = 1;

 tmpidx2 = find(Bin.Results.Data{1,2}(:,1) == i);
 WorkCell{1,2}(Bin.Results.Data{1,2}(tmpidx2,2),i) = 1;
end

% **************************************
% * initialize
% **************************************

% calculate number of Tslids fitting in given number of bins (nbins)
nTslid = floor(1+ ((nbins-Tslid)/shiftWin));


% initialize window index matrix 
winLimMat = zeros(nTslid,2);

% initialize significant window index vector
sig_winLimMat=[];


% *************************************************
% * count coincidences in the whole trial length
% *************************************************


[cc,ns1,ns2,j1,j2]= countJBS(WorkCell{1,1},WorkCell{1,2},jit);



% factor for conversion to Rate in sliding window
toRateInTslid  = (1000/(Tslid*binsize*nTrials));

% array of indices of center bins
centerBinArr = [];

freq1 = zeros(nTslid,nTrials); 
freq2 = freq1;

psth1 = zeros(nTslid,1); 
psth2 = zeros(nTslid,1); 


sp1 = WorkCell{1,1};
sp2 = WorkCell{1,2};

% UE arrays
ue1 = zeros(0,2);
ue2 = zeros(0,2);

SignArr     = zeros(nTslid,1);
ExpCoincArr = zeros(nTslid,1);
JitCoincArr = zeros(nTslid,1);

num_trials_UE = zeros(nTslid,1);



for ii=0:nTslid-1                    % sliding window loop
%for ii=260-1:300-1	  
  % generate Tslid indices around each center bin
  winIdx = [ii*shiftWin+1:1:(ii*shiftWin)+Tslid];
	  
	 
  % put window index limits in matrix for plotting
  winLimMat(ii+1,:) = [ii*shiftWin+1,(ii*shiftWin)+Tslid];
	  

  % bin index of center bin
  centerBin    = winIdx(floor(Tslid/2));
  centerBinArr = [centerBinArr, centerBin];
 

  % spike counts per trial per neuron
  for jj=1:nTrials
  freq1PerTrial(ii+1,jj) = sum(sp1(winIdx,jj),1);
  freq2PerTrial(ii+1,jj) = sum(sp2(winIdx,jj),1);
  end

ctmp = corrcoef(freq1PerTrial(ii+1,:),freq2PerTrial(ii+1,:));
C(ii+1)=ctmp(2,1);

     m1(ii+1) = mean(freq1PerTrial(ii+1,:));
     s1(ii+1) = std(freq1PerTrial(ii+1,:));
     s1t(ii+1) = sqrt(m1(ii+1));
sk1(ii+1) = skewness(freq1PerTrial(ii+1,:));
kt1(ii+1) = kurtosis(freq1PerTrial(ii+1,:));

     
     s2(ii+1) = std(freq2PerTrial(ii+1,:));
     m2(ii+1) = mean(freq2PerTrial(ii+1,:));
     s2t(ii+1) = sqrt(m2(ii+1));
sk2(ii+1) = skewness(freq2PerTrial(ii+1,:));
kt2(ii+1) = kurtosis(freq2PerTrial(ii+1,:));


f1 = figure(1)
set(f1,'Units','centimeters');
set(f1,'PaperType','a4letter');
set(f1,'PaperUnits','centimeters');
pp(1)=1;		% in cm
pp(2)=15;		% in cm
pp(3)=10; 		% in cm
pp(4)=10; 		% in cm
set(f1,'Position',pp);
set(f1,'PaperPosition',pp);

 plot(freq1PerTrial(ii+1,:),freq2PerTrial(ii+1,:),'*')
 title([fname '; c1 vs. c2; Tslid: ' num2str(ii+1)])
     %set(gca, 'Xlim', [0 20])
     %set(gca, 'Ylim', [0 20])
 hold on
 b = C(ii+1)*s2(ii+1)/s1(ii+1);
 a = m2(ii+1) - b*m1(ii+1);
 xvec = 0:max(freq1PerTrial(ii+1,:));
 yvec = a+xvec*b;
 
 plot(xvec,yvec)
 hold off
 drawnow  




figure(2)
subplot(7,1,1)

     plot(0:ii,m1(1:ii+1),'b')
     hold on
     plot(0:ii,m2(1:ii+1),'g')
     title('mean of spike counts (blue: neuron1; green: neuron2)')
     hold off
     drawnow


subplot(7,1,2)

     plot(0:ii,s1(1:ii+1)./s1t(ii+1),'b')
     hold on
     plot(0:ii,s2(1:ii+1)./s2t(ii+1),'g')
     title('fraction std of spike counts/std if Poisson (blue: neuron1; green: neuron2)')
     hold off
     drawnow

subplot(7,1,3)

     plot(0:ii,sk1(1:ii+1),'b')
     hold on
     plot(0:ii,sk2(1:ii+1),'g')
     title('sknewness (blue: neuron1; green: neuron2)')
     hold off
   drawnow 

subplot(7,1,4)

     plot(0:ii,kt1(1:ii+1),'b')
     hold on
     plot(0:ii,kt2(1:ii+1),'g')
     title('kurtosis (blue: neuron1; green: neuron2)')
     hold off
   drawnow
 
subplot(7,1,5)
     plot(0:ii,C(1:ii+1))
     hold on
     title('correlation coefficient of spike counts')
     hold off
   drawnow

  
  % total number of spikes in current window in each trial 
  freq1(ii+1,:) =  sum(sp1(winIdx,:),1);
  freq2(ii+1,:) =  sum(sp2(winIdx,:),1);
  
  % total nu,ber of spikes in current window
  ns1 = sum(freq1(ii+1,:),2);
  ns2 = sum(freq2(ii+1,:),2);

  % rate estimated over window
  psth1(ii+1)=ns1*toRateInTslid;
  psth2(ii+1)=ns2*toRateInTslid;


  % put coincidence counts of window
  JitCoincArr(ii+1)= sum(cc(winIdx));


  % Equation 21 in JNM 1999
  %  expected coincidence counts of window
  % (ns1/(Tslid*nTrials)) : probability per bin
  ExpCoincArr(ii+1)= (ns1/(Tslid*nTrials))* ...
                          (ns2/(Tslid*nTrials))*Tslid*nTrials*(2*jit+1);	
 

 
  % put significance (put Surprise value from new function: jointSurprise.m)
  SignArr(ii+1) = jointSurprise(JitCoincArr(ii+1), ...
                                     ExpCoincArr(ii+1));
  % joint-p-value
  jpArr(ii+1)=gammainc(ExpCoincArr(ii+1),JitCoincArr(ii+1));

if 1
 % HERE: make distribution!
 [dhh,dXentry,jpd,jsd]=...
   SimulCovCounts2(freq1(ii+1,:),freq2(ii+1,:),JitCoincArr(ii+1),0,nTrials,Tslid,1000);

 % mean of distribution einbauen!!!!
 
nExpSurr(ii+1) = sum(dhh.*dXentry)/(sum(dhh));

 jsD(ii+1) = jsd;
 hpoiss = poisspdf(dXentry,ExpCoincArr(ii+1));
 
 if 1
  f5=figure(5)
  set(f5,'Units','centimeters');
  set(f5,'PaperType','a4letter');
  set(f5,'PaperUnits','centimeters');
  pp(1)=1;		% in cm
  pp(2)=1;		% in cm
  pp(3)=10; 		% in cm
  pp(4)=10; 		% in cm
  set(f5,'Position',pp);
  set(f5,'PaperPosition',pp);
  bar(dXentry,dhh/sum(dhh))
   hold on
  plot(dXentry,hpoiss,'-*m')
  plot(JitCoincArr(ii+1),0,'r*')
  plot(nExpSurr(ii+1),0,'b*')
  plot(ExpCoincArr(ii+1),0,'g*')
  hold off
  title(['Surrogate Distr (blue), Poission (red)' ]) 
  drawnow
 end

end
 figure(2)
 subplot(7,1,6)
     plot(0:ii,ExpCoincArr(1:ii+1),'g')
     hold on
  plot(0:ii, nExpSurr(1:ii+1),'b')
     plot(0:ii,JitCoincArr(1:ii+1),'r')
     %set(gca, 'Ylim', [-3 3])
     title(['Coincidence Counts']);
     hold off
     grid on
     drawnow

  
  subplot(7,1,7)
     plot(0:ii,SignArr(1:ii+1),'k','LineWidth',2)
     hold on
     plot(0:ii,jsD(1:ii+1),'r','LineWidth',2)
     set(gca, 'Ylim', [-10 10])
     grid on
     title(['Joint-Surprise (black: Poisson; red: Surrogates)']);
     grid on
     drawnow
  end



  if 0
  %keyboard
  subplot(4,1,4)
  plot(SignArr(1:ii+1),C(1:ii+1),'*')
   
  clear tmpIdx;
  tmpIdx = find(SignArr(:)~=-inf);
  if ~isempty(tmpIdx) 
     ctmp = cov(SignArr(tmpIdx),C(tmpIdx));
   CC=ctmp(2,1);
   title(['covariation of spike counts vs. joint-surprise; Covar= ' num2str(CC)])
     clear tmpIdx;
   end
   drawnow
  end

if 0
  % put UE jitter spikes into UECell - matrix
  if SignArr(ii+1)>= jointSurprise(alpha)
    
    % indicate significant area
    MoreSigIndicator(winIdx)=MoreSigIndicator(winIdx)+ ...
                             ones(size(MoreSigIndicator(winIdx)));
    % indicate signif. and (after) anti-synchronized area in the same vector
    more_lessIndicator(winIdx)=more_lessIndicator(winIdx)+ ...
                             ones(size(more_lessIndicator(winIdx)));

    % ei == coincidence in current window
    if ~isempty(j1)
     ei  = find(j1(:,2) >= winLimMat(ii+1,1) & j1(:,2) <= winLimMat(ii+1,2) );
     ue1 = cat(1,ue1, j1(ei,:)); 
    end
 
    if ~isempty(j2)
     ei  = find(j2(:,2) >= winLimMat(ii+1,1) & j2(:,2) <= winLimMat(ii+1,2) );
     ue2 = cat(1,ue2, j2(ei,:)); 
    end
  

     % Delimit the significant area to use for
     % computing the % of UE per trial inside each significant area
     sig_winLimMat(ii+1,:)=winLimMat(ii+1,:);


     % **********************************************
     % determine number of trials in which UEs occurr
     % **********************************************

     %num_trials_UE(ii+1) = length(unique(j1(ei,1))) ;
   
   end         % of UECell matrix  

  
end    % end of sliding window loop

  pname = [fname 'Moments.eps'];
eval(['print -depsc ' pname])

eval(['save ' fname 'Moments'])

figure
plot(sort(C))
title(['Corrcoefs ' fname ' (sorted)'])
xlabel('sorting index')
ylabel('R_{xy}')


pname = [fname 'CorrCoeff.eps'];
eval(['print -depsc ' pname])
keyboard
