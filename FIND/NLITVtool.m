function NLITVtoolout = NLITVtool(xfull,yfull,m,tau,nneighbours,thel,shiftlength,samplefreq)
% Non linear time interdependency toolbox
% function NLITVtoolout = NLITVtool(xfull,yfull,m,tau,nneighbours,thel,shiftlength,samplefreq) 
%
% A Bivariate input is taken from the main experimental data set and
% converted into two datastreams which are iteratively evaluated for
% S(X|Y), S(Y|X), H(X|Y), H(Y|X), N(X|Y), N(Y|X) and cross
% correlation. See Pereda 2005 and Quiroga 2002 for full details.
%
% m             embedding dimension, it is the size of features the user wishs
%               to search the input signals for.
% tau           time constant.
% thel          Theiler correction constant. (see Theiler, Phys Rev A, 1986)
% nneighbours   number of nearest neighbours.
% shiftlength   the required shiftlength in samples (see technical
%               documentation).
% samplefreq    The frequency in Hz of your original sample.
%
% Outputs are produced as a matrix of the form S(X|Y), S(Y|X), H(X|Y), 
% H(Y|X), N(X|Y), N(Y|X) and cross correlation, these variables are 
% accessed via NLITVtoolout. Outputs are seen as figures for S, H and N
% measures.
%
% This software is adapted from Pereda 2005 (Nonlinear Multivariate 
% analysis of neurophysiological signals, E Pereda et al 2005), Quiroga 2002
% (Performace of different synchronisation measures in real data: A case
% study on electroencephalographic signals) and other attached documentaton
% and resources from Quiroga's website.
%
% Author : Jonathan Farrimond,
%          University of Reading,
%          Schools of Systems Engineering and Pharmacy.
% Supervisors : Dr. B. J. Whalley  (School of Pharmacy).
%               Dr. G. J. Stephens (School of Pharmacy).
%               Dr. S. J. Nasuto   (School of Systems Engineering).
%
% Please see http://www.pharmacy.rdg.ac.uk/research/electrophys.htm for 
% further details.
%%


lx = length(xfull);
ly = length(yfull);

sl = shiftlength / m; %finds datastore length
NLITVtool = zeros(sl+1,8); %creates a dataset for use at the end of the 
                           % m-file to store outputs
predata = zeros(sl+1,1); %creates a dataset for the time shift data

mbp = (sl/2);
midposn = mbp+1;
bounds = shiftlength/2;

flag1 = 1;
flag2 = 1;
flag3 = mbp+1;

    if ((flag1) < (flag3)) %loop to find timeshift periods and apply them 
                           % to a data structure
        for flag4 = flag1:(flag3-1) %sets the length of the loop runtime, 
                    % forcing the loop to repeat until the array is filled
            predata(midposn+flag1,1) = ((bounds/mbp)*flag2); % Pushes the data into 
                                % symmetric positions in the predata matrix
            predata(midposn-flag1,1) = (-(bounds/mbp)*flag2); % Second data push
            flag1=flag1+1; %Increments flag1
            flag2=flag2+1; %Increments flag2
        end
    else
    end

    NLITVtool( :,1) = predata; %Add shift data to NLITVtool

%% DATA SHIFTING AND LOOP NCC
%% -ve Data shift and run ncc
fneg1 = 1;
fneg2 = mbp;

    if (fneg1 < fneg2)
        for fneg3 = fneg1:fneg2; %Sets runtime for loop
        shiftvalue = abs(predata(fneg1,1)); %takes the data from predata, since 
                        % the matrix is symmetric only one point is needed
        x = xfull(1:((lx)-((shiftvalue/1000)*samplefreq)+1),1); %Reduces the x 
                        % dataset to allow for comparrison at shifted time
        y = yfull((((shiftvalue/1000)*samplefreq):(ly)),1); %Reduces the y 
                                    % data for time shifted comparrison
    
        %Start of ncc
        dpx = length(x); %finds the number of data points in x
        dpy = length(y); %finds the number of data points in y
        tdp = dpx; %arbitary choice of dataset length, dpx and dpy are 
                % designed to allow for error checking in a later version
        
        rn = zscore(x);   %time indices of the k nearest neighbours to x
        sn = zscore(y);   %time indices of the k nearest neighbours to y
        bivar  = [x,y];   % produces a bivariate dataset
        zbivar = [rn,sn]; % produces a bivariate datset from the standardised 
                          % z score of x and y
        cross = xcorr(zbivar(:,1),zbivar(:,2),0,'biased'); %Cross Correlation 
                                % function between x and y datasets, with bias
        
        sxy = 0; 
        syx = 0; 
        hxy = 0; 
        hyx = 0; 
        nxy = 0; 
        nyx = 0;  %initisation of S, H and N measures for both X|Y and Y|X 
                  % configurations
        
        for i = 1:tdp-(m-1)*tau-1; % (1) Applies the loop for all data points 
                                   % in the arrays x and y
            for k=1:nneighbours % (2) From paper, k is used to denote a 
                                % particular nearest neighbour
                ax(k) = 100000000; % initial values set v.high
                ix(k) = 100000000;
                ay(k) = 100000000;
                iy(k) = 100000000;
            end %ends (2)
            
            ax(nneighbours+1) = 0;
            ay(nneighbours+1) = 0;
            ix(nneighbours+1) = 100000000;
            iy(nneighbours+1) = 100000000;
            rrx = 0; rry = 0;
            
            for j = 1:tdp-(m-1)*tau-1 % (3)                   
                dx(j) = 0;
                dy(j) = 0;
                
                for k=0:m-1 % (4)                        
                    dx(j) = dx(j)+(bivar(i+k*tau,1)-bivar(j+k*tau,1)).^2; % Euclidean distance x
                    dy(j) = dy(j)+(bivar(i+k*tau,2)-bivar(j+k*tau,2)).^2; % Euclidean distance y
                end % ends (4)
                
                if ((abs(i-j)) > thel)   
                    if (dx(j) < ax(1)) % (5)
                        dcontrol1=0;
                        for k=1:nneighbours+1 % (6)
                            if (dx(j) < ax(k))  % (7)
                                ax(k) = ax(k+1);
                                ix(k) = ix(k+1);
                            else
                                ax(k-1) = dx(j);
                                ix(k-1) = j;
                                dcontrol1=1;
                            end  % end (7)
                            if dcontrol1==1;break;end
                        end % end (6)
                    end % end (5)
                    
                    if (dy(j) < ay(1)) % (8)
                        dcontrol2=0;
                        for k=1:nneighbours+1 % (9)
                            if (dy(j) < ay(k)) % (10)
                                ay(k) = ay(k+1);
                                iy(k) = iy(k+1);
                            else
                                ay(k-1) = dy(j);
                                iy(k-1) = j;
                                dcontrol2=1;
                            end % end (10)
                            if dcontrol2==1,break,end
                        end  % end (9)
                    end
                end % end (8)
                
                rrx = rrx + dx(j);        
                rry = rry + dy(j);
                
            end % end (3)                                          
            rxx = 0; ryy = 0; rxy = 0; ryx = 0;
            
            for k=1:nneighbours
                rxx = ax(k) + rxx;
                ryy = ay(k) + ryy;
                rxy = dx(iy(k)) + rxy;
                ryx = dy(ix(k)) + ryx;
            end
            
            rxx = rxx/nneighbours;
            ryy = ryy/nneighbours;
            rxy = rxy/nneighbours;
            ryx = ryx/nneighbours;
            sxy = sxy + rxx/rxy;
            syx = syx + ryy/ryx;
            hxy =  hxy + log(rrx/((tdp-(m-1)*tau-2)) / rxy);
            hyx =  hyx + log(rry/((tdp-(m-1)*tau-2)) / ryx);
            nxy =  nxy + rxy / (rrx/((tdp-(m-1)*tau-2))); 
            nyx =  nyx + ryx / (rry/((tdp-(m-1)*tau-2)));  
            
        end %ends (1)
        
        %final outputs
        sxy = sxy/(tdp-(m-1)*tau-1);
        syx = syx/(tdp-(m-1)*tau-1);
        hxy = hxy/(tdp-(m-1)*tau-1);
        hyx = hyx/(tdp-(m-1)*tau-1);
        nxy = 1 - nxy/(tdp-(m-1)*tau-1);
        nyx = 1 - nyx/(tdp-(m-1)*tau-1);
        %end of ncc
        
        %INSERT DATA INTO NLITVtool
        NLITVtool(fneg1,2) = sxy;
        NLITVtool(fneg1,3) = syx;
        NLITVtool(fneg1,4) = hxy;
        NLITVtool(fneg1,5) = hyx;
        NLITVtool(fneg1,6) = nxy;
        NLITVtool(fneg1,7) = nyx;
        NLITVtool(fneg1,8) = cross;
        
        %Increment fneg1
        fneg1=fneg1+1;
    end
    else
    end    

    
%% 0 Data shift and run ncc, no loop needed
    
        %Start of ncc
        dpx = length(xfull); %finds the number of data points in x
        dpy = length(yfull); %finds the number of data points in y
        tdp = dpx;
        
        rn = zscore(xfull);   %time indices of the k nearest neighbours to x
        sn = zscore(yfull);   %time indices of the k nearest neighbours to y
        bivar  = [xfull,yfull];   % produces a bivariate dataset
        zbivar = [rn,sn]; % produces a bivariate datset from the standardised 
                          % z score of x and y
        cross = xcorr(zbivar(:,1),zbivar(:,2),0,'biased'); %Cross Correlation 
                            % function between x and y datasets, without bias
        
        sxy = 0; 
        syx = 0; 
        hxy = 0; 
        hyx = 0; 
        nxy = 0; 
        nyx = 0;  %initisation of S, H and N measures for both X|Y and Y|X 
                  % configurations
        
        for i = 1:tdp-(m-1)*tau-1; % (1) Applies the loop for all data points 
                                   % in the arrays x and y
            for k=1:nneighbours % (2) From paper, k is used to denote a 
                                % particular nearest neighbour
                ax(k) = 100000000; % initial values set v.high
                ix(k) = 100000000;
                ay(k) = 100000000;
                iy(k) = 100000000;
            end %ends (2)
            
            ax(nneighbours+1) = 0;
            ay(nneighbours+1) = 0;
            ix(nneighbours+1) = 100000000;
            iy(nneighbours+1) = 100000000;
            rrx = 0; rry = 0;
            
            for j = 1:tdp-(m-1)*tau-1 % (3)                   
                dx(j) = 0;
                dy(j) = 0;
                
                for k=0:m-1 % (4)                        
                    dx(j) = dx(j)+(bivar(i+k*tau,1)-bivar(j+k*tau,1)).^2; % Euclidean distance x
                    dy(j) = dy(j)+(bivar(i+k*tau,2)-bivar(j+k*tau,2)).^2; % Euclidean distance y
                end % ends (4)
                
                if ((abs(i-j)) > thel)   
                    if (dx(j) < ax(1)) % (5)
                        dcontrol1=0;
                        for k=1:nneighbours+1 % (6)
                            if (dx(j) < ax(k))  % (7)
                                ax(k) = ax(k+1);
                                ix(k) = ix(k+1);
                            else
                                ax(k-1) = dx(j);
                                ix(k-1) = j;
                                dcontrol1=1;
                            end  % end (7)
                            if dcontrol1==1;break;end
                        end % end (6)
                    end % end (5)
                    
                    if (dy(j) < ay(1)) % (8)
                        dcontrol2=0;
                        for k=1:nneighbours+1 % (9)
                            if (dy(j) < ay(k)) % (10)
                                ay(k) = ay(k+1);
                                iy(k) = iy(k+1);
                            else
                                ay(k-1) = dy(j);
                                iy(k-1) = j;
                                dcontrol2=1;
                            end % end (10)
                            if dcontrol2==1,break,end
                        end  % end (9)
                    end
                end % end (8)
                
                rrx = rrx + dx(j);        
                rry = rry + dy(j);
                
            end % end (3)                                          
            rxx = 0; ryy = 0; rxy = 0; ryx = 0;
            
            for k=1:nneighbours
                rxx = ax(k) + rxx;
                ryy = ay(k) + ryy;
                rxy = dx(iy(k)) + rxy;
                ryx = dy(ix(k)) + ryx;
            end
            
            rxx = rxx/nneighbours;
            ryy = ryy/nneighbours;
            rxy = rxy/nneighbours;
            ryx = ryx/nneighbours;
            sxy = sxy + rxx/rxy;
            syx = syx + ryy/ryx;
            hxy =  hxy + log(rrx/((tdp-(m-1)*tau-2)) / rxy);
            hyx =  hyx + log(rry/((tdp-(m-1)*tau-2)) / ryx);
            nxy =  nxy + rxy / (rrx/((tdp-(m-1)*tau-2))); 
            nyx =  nyx + ryx / (rry/((tdp-(m-1)*tau-2)));  
            
        end %ends (1)
        
        %final outputs
        sxy = sxy/(tdp-(m-1)*tau-1);
        syx = syx/(tdp-(m-1)*tau-1);
        hxy = hxy/(tdp-(m-1)*tau-1);
        hyx = hyx/(tdp-(m-1)*tau-1);
        nxy = 1 - nxy/(tdp-(m-1)*tau-1);
        nyx = 1 - nyx/(tdp-(m-1)*tau-1);
        %end of ncc
        
        NLITVtool(mbp,2) = sxy;
        NLITVtool(mbp,3) = syx;
        NLITVtool(mbp,4) = hxy;
        NLITVtool(mbp,5) = hyx;
        NLITVtool(mbp,6) = nxy;
        NLITVtool(mbp,7) = nyx;
        NLITVtool(mbp,8) = cross;
        
%% +ve Data shift and run ncc
fpos1 = mbp+1;
fpos2 = sl+1;

    if (fpos1 < fpos2)
        for fpos3 = fpos1:fpos2; %defines loop runtime
        shiftvalue1 = abs(predata(fpos1,1)); %finds shift value, again 
                        % predata is symmetric so only one value is needed
        x1 = xfull(((shiftvalue/1000)*samplefreq):(length(xfull)),1);
        y1 = yfull(1:((length(yfull))-((shiftvalue/1000)*samplefreq)+1),1);
    
        %Start of ncc
        dpx = length(x1); %finds the number of data points in x
        dpy = length(y1); %finds the number of data points in y
        tdp = dpx;
        
        rn = zscore(x1);   %time indices of the k nearest neighbours to x
        sn = zscore(y1);   %time indices of the k nearest neighbours to y
        bivar  = [x1,y1];   % produces a bivariate dataset
        zbivar = [rn,sn]; % produces a bivariate datset from the standardised 
                          % z score of x and y
        cross = xcorr(zbivar(:,1),zbivar(:,2),0,'biased'); %Cross Correlation 
                            % function between x and y datasets, without bias
        
        sxy = 0; 
        syx = 0; 
        hxy = 0; 
        hyx = 0; 
        nxy = 0; 
        nyx = 0;  %initialisation of S, H and N measures for both X|Y and Y|X 
                  % configurations
        
        for i = 1:tdp-(m-1)*tau-1; % (1) Applies the loop for all data points 
                                   % in the arrays x and y
            for k=1:nneighbours % (2) From paper, k is used to denote a 
                                % particular nearest neighbour
                ax(k) = 100000000; % initial values set v.high
                ix(k) = 100000000;
                ay(k) = 100000000;
                iy(k) = 100000000;
            end %ends (2)
            
            ax(nneighbours+1) = 0;
            ay(nneighbours+1) = 0;
            ix(nneighbours+1) = 100000000;
            iy(nneighbours+1) = 100000000;
            rrx = 0; rry = 0;
            
            for j = 1:tdp-(m-1)*tau-1 % (3)                   
                dx(j) = 0;
                dy(j) = 0;
                
                for k=0:m-1 % (4)                        
                    dx(j) = dx(j)+(bivar(i+k*tau,1)-bivar(j+k*tau,1)).^2; % Euclidean distance x
                    dy(j) = dy(j)+(bivar(i+k*tau,2)-bivar(j+k*tau,2)).^2; % Euclidean distance y
                end % ends (4)
                
                if ((abs(i-j)) > thel)   
                    if (dx(j) < ax(1)) % (5)
                        dcontrol1=0;
                        for k=1:nneighbours+1 % (6)
                            if (dx(j) < ax(k))  % (7)
                                ax(k) = ax(k+1);
                                ix(k) = ix(k+1);
                            else
                                ax(k-1) = dx(j);
                                ix(k-1) = j;
                                dcontrol1=1;
                            end  % end (7)
                            if dcontrol1==1;break;end
                        end % end (6)
                    end % end (5)
                    
                    if (dy(j) < ay(1)) % (8)
                        dcontrol2=0;
                        for k=1:nneighbours+1 % (9)
                            if (dy(j) < ay(k)) % (10)
                                ay(k) = ay(k+1);
                                iy(k) = iy(k+1);
                            else
                                ay(k-1) = dy(j);
                                iy(k-1) = j;
                                dcontrol2=1;
                            end % end (10)
                            if dcontrol2==1,break,end
                        end  % end (9)
                    end
                end % end (8)
                
                rrx = rrx + dx(j);        
                rry = rry + dy(j);
                
            end % end (3)                                          
            rxx = 0; ryy = 0; rxy = 0; ryx = 0;
            
            for k=1:nneighbours
                rxx = ax(k) + rxx;
                ryy = ay(k) + ryy;
                rxy = dx(iy(k)) + rxy;
                ryx = dy(ix(k)) + ryx;
            end
            
            rxx = rxx/nneighbours;
            ryy = ryy/nneighbours;
            rxy = rxy/nneighbours;
            ryx = ryx/nneighbours;
            sxy = sxy + rxx/rxy;
            syx = syx + ryy/ryx;
            hxy =  hxy + log(rrx/((tdp-(m-1)*tau-2)) / rxy);
            hyx =  hyx + log(rry/((tdp-(m-1)*tau-2)) / ryx);
            nxy =  nxy + rxy / (rrx/((tdp-(m-1)*tau-2))); 
            nyx =  nyx + ryx / (rry/((tdp-(m-1)*tau-2)));  
            
        end %ends (1)
        
        %final outputs
        sxy = sxy/(tdp-(m-1)*tau-1);
        syx = syx/(tdp-(m-1)*tau-1);
        hxy = hxy/(tdp-(m-1)*tau-1);
        hyx = hyx/(tdp-(m-1)*tau-1);
        nxy = 1 - nxy/(tdp-(m-1)*tau-1);
        nyx = 1 - nyx/(tdp-(m-1)*tau-1);
        %end of ncc
        
        %INSERT DATA INTO NLITVtool
        NLITVtool(fpos1,2) = sxy;
        NLITVtool(fpos1,3) = syx;
        NLITVtool(fpos1,4) = hxy;
        NLITVtool(fpos1,5) = hyx;
        NLITVtool(fpos1,6) = nxy;
        NLITVtool(fpos1,7) = nyx;
        NLITVtool(fpos1,8) = cross;
        
        %Increment fneg1
        fpos1=fpos1+1;
    end
    else
    end    
    
%% Plotting

%S(X|Y), H(X|Y), N(X|Y)
figure;
subplot(1,3,1); plot((NLITVtool( :,1)),(NLITVtool( :,2)),'-r'),title('S(X|Y)',... 
  'FontWeight','bold'),xlabel('Timeshift',... 
  'FontWeight','bold'); %Red plot 

hold
plot((NLITVtool( :,1)),(NLITVtool( :,3)),'*g'); %S(Y|X)

subplot(1,3,2); plot((NLITVtool( :,1)),(NLITVtool( :,4)),'-r'),title('H(X|Y)',... 
  'FontWeight','bold'),xlabel('Timeshift',... 
  'FontWeight','bold'); %Green plot
hold
plot((NLITVtool( :,1)),(NLITVtool( :,5)),'*g'); %H(Y|X)

subplot(1,3,3); plot((NLITVtool( :,1)),(NLITVtool( :,6)),'-r'),title('N(X|Y)',... 
  'FontWeight','bold'),xlabel('Timeshift',... 
  'FontWeight','bold'); %Blue plot
hold
plot((NLITVtool( :,1)),(NLITVtool( :,7)),'*g'); %N(Y|X)


%Cross Correlation plot
figure;
plot((NLITVtool( :,1)),(NLITVtool( :,8)),'Color',[0 0 1]),title('Cross Correlation',... 
  'FontWeight','bold'),xlabel('Timeshift',... 
  'FontWeight','bold');
  