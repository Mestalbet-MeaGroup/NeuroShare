function n=ndigits(x,b)

if x==0
 n=1;
else
 n=fix(1+log(x)./log(b));
end