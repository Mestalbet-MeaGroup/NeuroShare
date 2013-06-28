function pbm = k_pbm(K, Dist, IDX, E1, C)
% calculates the pbm index for validation of clustering for the k_means
% function. 
%
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

%calculate biggest distance between two centroids
[m,n]=size(C);
for i=1:K
    for j=1:K
        temp=0;
        for k=1:n
            temp=temp+(C(i,n)-C(j,n)).^2;
        end
        cd(i,j)=sqrt(temp);
    end
end
CD=max(max(cd));

%calculate the sum of distances
Dist_sum=sum(Dist);

pbm=(1/K*E1/Dist_sum*CD)^2;

