function dist=k_DistMatrix(Data,Centroids)
% calculates the euclidean distance between the data points and the
% centroids. For the kmeans clustering.
%
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

[m,n]=size(Data);
[p,q]=size(Centroids);
if n ~= q,  error(' second dimension of Data and Centroids must be the same'); end
C=cell(n,1);
D=cell(n,1);
for k=1:n
    C{k}= repmat(Data(:,k),1,p);
    D{k}= repmat(Centroids(:,k),1,m);
end
d=zeros(m,p);
for kk=1:n
    d=d+(C{kk}-D{kk}').^2;
end
dist=sqrt(d);

