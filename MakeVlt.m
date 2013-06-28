function VoltageDataTmp = MakeVlt(NSubWindowSamples,VoltageData,PPW,j)

    for k=1:PPW %divides the every window to 20ms windows.
             VoltageDataTmp(:,(j-1)*PPW+k)=spline(1:NSubWindowSamples, VoltageData(((k-1)*NSubWindowSamples+1):k*NSubWindowSamples,j),linspace(1,NSubWindowSamples,237));      
    end
    
end