function NLItoolout = NLItool(x,y,m,tau,nneighbours,thel) 
% Non linear time interdependency toolbox
% function NLItoolout = NLItool(x,y,m,tau,nneighbours,thel)
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
%
% Outputs are produced as a matrix of the form S(X|Y), S(Y|X), H(X|Y), 
% H(Y|X), N(X|Y), N(Y|X) and cross correlation, these variables are 
% accessed via NLItoolout.
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

dpx = length(x); %finds the number of data points in x
dpy = length(y); %finds the number of data points in y
tdp = dpx;
    
rn = zscore(x);   %time indices of the k nearest neighbours to x
sn = zscore(y);   %time indices of the k nearest neighbours to y
bivar  = [x,y];   % produces a bivariate dataset
zbivar = [rn,sn]; % produces a bivariate datset from the standardised z 
                  % score of x and y
cross = xcorr(zbivar(:,1),zbivar(:,2),0,'biased'); %Cross Correlation function 
                                    % between x and y datasets, with bias
nccout = zeros(7,1); %creates an empty vector for nccout(n) function

sxy = 0; 
syx = 0; 
hxy = 0; 
hyx = 0; 
nxy = 0; 
nyx = 0;  %initisation of S, H and N measures for both X|Y and Y|X configurations

for i = 1:tdp-(m-1)*tau-1; % (1) Applies the loop for all data points in the arrays x and y
    for k=1:nneighbours % (2) From paper, k is used to denote a particular nearest neighbour
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

% function outputs
nccout(1) = sxy;
nccout(2) = syx;
nccout(3) = hxy;
nccout(4) = hyx;
nccout(5) = nxy;
nccout(6) = nyx;
nccout(7) = cross;

sxystr=NUM2STR(sxy);
syxstr=NUM2STR(syx);
hxystr=NUM2STR(hxy);
hyxstr=NUM2STR(hyx);
nxystr=NUM2STR(nxy);
nyxstr=NUM2STR(nyx);
crossstr=NUM2STR(cross);

disp('sxy = '), disp(sxystr), disp(' ');
disp('syx = '), disp(syxstr), disp(' '), disp(' ');
disp('hxy = '), disp(hxystr), disp(' ');
disp('hyx = '), disp(hyxstr), disp(' '), disp(' ');
disp('nxy = '), disp(nxystr), disp(' ');
disp('nyx = '), disp(nyxstr), disp(' '), disp(' ');
disp('Cross correlation = '), disp(crossstr);
