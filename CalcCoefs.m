function [a,a22,Time_data, Time, Coefs, Coefs_data, txt_data, step]=CalcCoefs(a,a22,Coefs_data,Time_Data,txt_data,i,c,Params,step,frame,VoltageData,TimeData,a2)
% [a,a22,Time_data, Time, Coefs, Coefs_data, txt_data,step]=CalcCoefs(a,a22,[Coefs_data,Coefs'],[Time_data; Time],[txt_data; round(a(1:240))],i,c,Params,step,frame,VoltageData,TimeData,a2);
% j=j+1;
Coefs=WPextractMark(a,-1*min(abs(a(4:end))),Params); %The function recieves the threshold setting and spike detection parameters
% wp - 9 coeficients of decomposition.
% 'i' is the number of frame in data in which the spike show.
    if ~isempty(Coefs)
        Time=Coefs(:,12);
        Coefs=Coefs(:,[1:11,13:14]);
        Coefs(:,11)=Coefs(:,11)+step{c};
        Coefs_data=[Coefs_data,Coefs'];
        Time_data=[Time_data; Time];
        a(4:end)=a(4:end).*10^7; % For some reason, the scaling is off. I suspect missing ad2muvolt is the problem.
        txt_data=[txt_data; round(a(1:240))];
        step{c}=step{c}+1;
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
    
    