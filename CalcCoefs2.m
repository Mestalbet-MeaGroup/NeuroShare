function [Time_data, Coefs_data, txt_data]=CalcCoefs2(a,stp,Params)


%The function recieves the threshold setting and spike detection parameters
Coefs=WPextractMark(a,-1*min(abs(a(4:end))),Params); 
% wp - 9 coeficients of decomposition.

if ~isempty(Coefs)
        Time=Coefs(:,12);
        Coefs=Coefs(:,[1:11,13:14]);
        Coefs(:,11)=Coefs(:,11)+stp;
        Coefs_data=[Coefs_data,Coefs'];
        Time_data=[Time_data; Time];
        a(4:end)=a(4:end).*10^7; % For some reason, the scaling is off. I suspect missing ad2muvolt is the problem.
        txt_data=[txt_data; round(a(1:240))];
end

a22=VoltageData(:,frame)';
b=TimeData(frame);
% Sometimes reading of file never stops for some reason. this terminates if data read is same.

    if isequal(a22(1:4),a2(1:4)),
        if RepeatedData==0, % First time: write an error message.
            fprintf('\nDamaged file: Found repeated data! Might be a damaged file!\nContinues in opening file...');
        end
     RepeatedData=1;
    end
    
 a2=a22;
 a=a22;
 a=[i 327 b a];
end
    
    