function [shifts] = nShift(varargin);
% function [shifts] = nShift(varargin);
% Parameter List:
% data,samplingRate,maxlagms,normflag,parabolicflag,parabolicsigma
%
% Returns
% =======
% shifts [ms] - vector of shifts for each trial (version 2.0)
%               in former version: cell with vector of shifts
%               for each neuron seperately.
% lags [ms]
% Parameters
% ==========
% data         rate-estimated data (time series to align) in 2D or 3D ADF format:
%               
%                2D matrix [sampleNo x trial]                 
%                3D matrix [sampleNo x channelindex x trial]
%              where the time is represented in the
%              sampleNo index with time = sampleNo/samplingRate
%
% samplingRate [kHz]   internally, all calculations are performed
%                      on the binning of the data
% maxlagms             correlation width halfsided in ms
%
% normflag='none'      no normalization of raw correlogram
% normflag='coeff'     normalization : max=1.0;
%                      does the same as normalizing
%                      the vectors beforehand by their
% norm (compare Step1) help xcorr
% normflag='unbiased'  accounts for low cc ends
% parabolicflag ='lin' defines type of parabolic approximation
% parabolicflag ='log'
% parabolicsigma       [ms] half width of range around maximum of xcorr
%                      function to use for parabolic fit
%
%
% History
% =======
%
%
% (0) Feb 14, 2008 : Martin Nawrot (nawrot@neurobiologie.fu-berlin.de).
%           Former version 'Nshift' (2001) (with Eric Bury)
%           Adapted to FIND: Feb 2008: R. Meier.
%
% --------------------------------------------------
% Original References of this tool
%
%   [1] Nawrot MP, Aertsen A, Rotter S (2003) Elimination of response
%   latency variability in neuronal spike trains. Biol Cybern 88: 321-334 
%   -> detailed decription and calibration of the method
%
%   [2] Meier R, Egert U, Aertsen A, Nawrot M (2008)
%   FIND - a unified framework for neural data analysis
%   (submitted manuscript)
%   -> application: alignment of stimulus response onsets estimated from MUA
%   on different recoding channels
%



obligatoryArgs={'data','samplingRate','maxlagms',{'normflag', @(value) ismember(value,{'none','coeff','unbiased','biased'})},{'parabolicflag', @(value) ismember(value,{'lin','log'})},'parabolicsigma'};

% optional arguments names with default values
optionalArgs={};

errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
    error(errorMessage,''); %used this format so that the '\n' are converted
end

% loading parameter value pairs into workspace, overwriting defaul values
pvpmod(varargin);




%*********************************
% local VARs
%*********************************
if ndims(data)<3;
    data=reshape(data,size(data,1),1,size(data,2));
end

nTrial = size(data,3);
nUnits = size(data,2);
timeUnit = 1/samplingRate;    % [ms]
maxlag=ceil(maxlagms/timeUnit);
parabolicsigma = ceil(parabolicsigma/timeUnit); % to bins of ADF

% If maxima in correlation function is not unequivocal or it's
%  time value outside the max. range we set predefined coefficients 'pdefault'
%   instead of actually fitting a second order polynomial. (M.N.)
%    constant fcn instead of polynomial leads ot Inf numbers during
%    matrix devision
pdefault=[1e-9,0,0];
%
% Martin. Sep 8, 2001:
%
maxlagplus=maxlag+parabolicsigma;

% obsolete version 2: A=cell(nUnits,1); B=cell(nUnits,1);
% coefficient matrix A and vector B
A=zeros(nTrial,nTrial);
B=zeros(nTrial,1);


% __________________________________
% CORRELATE PAIRWISE (FILLED MATRIX)
% ----------------------------------
%
% LINEAR FIT
%
%
% former version: each neuron was treated seperately and thus the
% outest loop went over k. Now, in this new version multiple
% neurons are treated differently. For each trial the correlation
% functions of all neurons are added (=averaged) and we fit the
% parabola to the final mean correlation function!
for i=1:nTrial;
    for j=i:nTrial
        corr=0;
        for k=1:nUnits;
            [c,lags]=xcorr(data(:,k,i),data(:,k,j), ...
                maxlagplus,normflag);
            corr=corr+c;
        end;
        tmax=find(corr==max(corr));
        %
        % Check for special cases:
        %
        % 1) tmax not unique?
        % 2) tmax beyond maxlag?
        % 3) zeros entires in correlation function?
        % -> set coefficeints to default coeff.
        r1 = tmax-parabolicsigma;
        r2 = tmax+parabolicsigma;
        if length(tmax)>1
            %disp(['WARNING: ',num2str(length(tmax)),' maxima found in ...
            %	 xcorr(',num2str([i j]),') -> parabolic fit set to default']);
            p=pdefault;
            % alternatively we may choose one of the encountered maxima:
            % tmax = tmax(ceil(length(tmax)/2));
            %keyboard
        elseif (r1<1) | (r2>length(corr))
            %disp(['WARNING: tmax beyond maxlag for trials ' ...
            %    ,num2str([i j]),'-> parabolic fit set to default'])
            p=pdefault;
        elseif max(corr)<10e-15
            % happened once so far for bit-noise in xcorr
            % would lead to log(0) !
            %disp('maximum due to bit noise -> parabolic fit set to default')
            p=pdefault;

        elseif (find(corr(r1:r2)==0) & parabolicflag =='log')
            % correction : March 05, 2007: zero correlation only relevant if
            % parabolicflag == 'log'
            %if parabolicflag =='log'
            %disp('zero in corr for log fit -> parabolic fit set to default')
            p=pdefault;
            % alternative:
            % corr(find(corr<10e-15))=10e-15;
            %end;
        else
            if parabolicflag =='lin' % prefferred case
                correl = corr(r1:r2);
            else
                correl = log(corr(r1:r2));
            end;
            p=polyfit(lags(r1:r2),correl',2);
            if find(p==0)
                keyboard
                %  p(1)=-0.01;
                %  p(2)=0;
            end;

        end;
        % store the coefficients of quadratic fit
        % f(t) = a t^2 + b t + c
        % former version stored this seperately for each unit,
        % now we have only one resulting fit in nTrials dimensions
        a(i,j)=p(1);
        a(j,i)=p(1); % a{k}(i,j);
        b(i,j)=p(2);
        b(j,i)=p(2); %-b{k}(i,j);
        % c{k}(i,j)=p(3); % won't be needed
        % removed erikbury -
        % b{l}(k,k) is never used in this implementation
        % % NOTE: b{k}(i,i)= 0.0 in theory, but there is always
        % % a bit of noise. So redefine it at beein' zero
        % b{l}(k,k)=0;
    end;
end;

%end;

% ____________________________________________________
% COMPUTE SHIFTS BY SOLVING N-1 LINEAR EQUATIONS A.X=B
% ----------------------------------------------------
% oBdA: t1=0
% Matrix A is symmetric!
% B is nonhom. Solution
%
%disp(['solving A.x = B']);

% convert the parameters of the quadratic fit into
% coefficients of the equation
% compare protocol/documentation
% no more needed in version 2 : for l=1:nUnits
A = -a;
for k=1:nTrial
    A(k,k) = sum(a(k,:)) - a(k,k);
    B(k,1)= -0.5*(sum(b(k,1:k-1)) - sum(b(k,k+1:end)));
end;
%   disp(num2str(A{l}));
%   disp(num2str(B{l}));
% ***************************
% LINEAR EQUATION
% ***************************
% version 2: no more seperate calculation for seperate units:
% in version 2.0 we determine one set of shifts for the
% combined set of all neurons. Thus, we receive a vector
% of shifts rather than a cell of vectors, one for each
% neuron as in earlier versions.
% set reference tau_11=0
% remove first column of A and rows of A and B:
shifts=zeros(nTrial,1);
shifts(1,1) = 0;
shifts(2:end,1)=A(2:end,2:end)\B(2:end,1);
%disp(num2str(shifts{k}));
%  X{k}=A{k}\B{k};
% original formulation leads to singularity warning
% reason: rank(A) is (dim(A)-1) and the equation under-
% determined (e.g. there is no unique solution) because
% the reference t(1,1) is not yet defined as described
% in M.Nawrot's diploma thesis.
% This is done here implicitly by skipping delP/del\tau_11
% (first row of A and B) and eliminating the coefficients
% of tau_11 (first column of A).
% X{l} contains now the tau_11-referenced shifts
%disp('Oriented shifts.')

% ******************************************************
% check whether 'NaN' results and return zero shifts instead
wrong=[];
% ***************************
% tranform shifts in [ms]!
shifts=shifts*timeUnit;
% ***************************
if sum(isfinite(shifts))<length(shifts)
    wrong=[wrong k];
    disp(['ERROR: shifts in cell ',num2str(k), ' are non-numeric.'])
    disp(['setting it to zeros.']);
    keyboard
end;
if ~isempty(wrong)
    for k=wrong
        shifts=zeros(nTrial,1);
    end;
end;

return;
