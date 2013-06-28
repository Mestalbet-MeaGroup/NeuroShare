function coh=calculateCoherence(varargin)
% calculates coherence between two signals, either averaged over trials or over sliding windows of size windowSize and shifted by windowShift 
%
%%%% Obligatory Parameters %%%%%
%
% signal1: a time series of the signal in ms-resolution
%
% signal2: same as signal1 in ms-resolution
%
% 
%%%%% Optional Parameters %%%%%%
%
% method:
%       trials:averaged over trials
%       window:averaged over windows of size windowSize and shifted by
%           windowShift
% windowSize: size of window in ms (default 3000)
% windowShift: number of bins to shift the window in ms (default 13)
    % windowKernel: what kind of window (default @Hann);
%
%
% %%%% H. Walz
% FIND-project: http://find.bccn-freiburg.de

% obligatory argument names
obligatoryArgs={'signal1', 'signal2'};           

% optional arguments names with default values
optionalArgs={'method','windowSize','windowShift', 'windowKernel'};
method='window';
windowSize=3000;
windowShift=13;
windowKernel=@Hamm;

% Valid var names provided? Otherwise, error is generated. You can also
% supply functions to test the validity of the values, see checkPVP for
% details.
errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
    error(errorMessage,''); %used this format so that the '\n' are converted
end


% loading parameter value pairs into workspace, overwriting defaul values
pvpmod(varargin);

%%% transform signals




%%% if trials calculate over trials
switch method
    case 'trials'
    nTrials=size(signal1,1);
    m=size(s1,2);
    CXX=zeros(nTrials,m);
    CYY=zeros(nTrials,m);
    CXY=zeros(nTrials,m);
    for ii=1:nTrials
        X=fft(signal1(ii,:));
        Y=fft(signal2(ii,:));
        CXX(ii,:)=X.*conj(X);
        CYY(ii,:)=Y.*conj(Y);
        CXY(ii,:)=X.*conj(Y);
    end;
    coh=abs(mean(CXY,1))./sqrt(mean(CXX,1).*mean(CYY,1));
    
    case 'window'
        nWindows1=floor((length(signal1)-windowSize)/windowShift+1);
        nWindows2=floor((length(signal1)-windowSize)/windowShift+1);
        nWin=min(nWindows2,nWindows1);

        CXX=zeros(nWin,windowSize);
        CYY=zeros(nWin,windowSize);
        CXY=zeros(nWin,windowSize);
        for ii=1:nWin
            X=fft(window(windowKernel,windowSize).*signal1((ii-1)*windowShift+1:(ii-1)*windowShift+windowSize));
            Y=fft(window(windowKernel,windowSize).*signal2((ii-1)*windowShift+1:(ii-1)*windowShift+windowSize));
            CXX(ii,:)=X.*conj(X);
            CYY(ii,:)=Y.*conj(Y);
            CXY(ii,:)=X.*conj(Y);
        end;
        coh=abs(mean(CXY,1))./sqrt((mean(CXX,1)).*mean(CYY,1));

    
end











