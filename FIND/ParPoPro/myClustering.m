data.X=x;
param.vis=1; param.val=3;

myDI=[];
for i=2:14
    param.c=i;
    result=Kmeans(data,param);
    result=validity(result,data,param);
    myDI(end+1)=result.validity.DI;
end

figure;
plot(myDI);