function [Time,Coefs,a]=ForPar(stp,a,Params)
    Coefs=WPextractMark(a,-1*min(abs(a(4:end))),Params); 
   if ~isempty(Coefs)
    Time=Coefs(:,12);
    Coefs=Coefs(:,[1:11,13:14]);
    Coefs(:,11)=Coefs(:,11) + stp;
    a(4:end)=a(4:end).*10^7;
    tempstp=tempstp+1;
   end
end