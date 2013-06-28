function w=wraparound(x,N)
% w=wraparound(x,N)

w=rem(x,N);
i=find(w<=0);
w(i)=N+w(i);

