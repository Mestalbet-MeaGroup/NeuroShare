function incr(x)

% yes, thats call by reference!
assignin('caller',inputname(1),x+1);
