function [Py,Pyf] = fftsimple(x,fs,an) 
% [Py,Pyf] = fftsimple(x,fs,an): power spectrum
% *
% *  input:  x : signal as row vector (!!!!!!!!)
% *          fs: sampling frequency in Hz
% *          an: flag for amplitude normalization:
% *              if an = 1: normalize to total area of spectrum
% *              if an = 0: not normalized to area
% * 
% *  output: 
% *          Py: array with spectrum, if an=0: non normalized
% *                                   if an=1: normalized
% *          Pyf: array of frequency values to which entries of Py
% *              belong to
% *
% *  Note: 
% *
% *
% *  History:
% *          (0) SG, Ffm, 27.7.98
% *              based on hints from Egbert Juergens
% *          (1) SG, FfM, 21.8.98
% *              bug in window function corrected
% *          (2) SG, FfM, 29.1.99
% *              simple version of fft
% *
% *
% *************************************************************************
     s    = size(x);
     k =0;
     nn=0;
     while nn<s(2)
       nn = 2^k;
       k = k+1;
     end
     dt = 1/fs;
     
     maxT = s(2)*dt;
     t    = dt:dt:maxT;
            
     tt = -1:2/(length(t)-1):1;
        
     % window function for getting rid of
     % window : cos^2 of lenght of signal
     
     %cc = (cos(tt*pi/2)).^2;
     %yy = x.*cc;
     
     yy = x;
     
     YY = fft(yy,nn);
     Pyy = YY.* conj(YY) / nn;
     
     %sqrtPyy = sqrt(Pyy(1:(nn/2)+1));
     %sqrtPyy_an = sqrtPyy/(sum(sqrtPyy));
     
     sqrtPyy = Pyy(1:(nn/2)+1);
     sqrtPyy_an = sqrtPyy/(sum(sqrtPyy));
     
     % frequency axis values
     f = fs*(0:nn/2)/nn;
 
     if an == 0
       Py = sqrtPyy;
     elseif an == 1
       Py = sqrtPyy_an;
     end
     Pyf = f;
     

 
  
