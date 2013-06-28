function r = check(expr);

r= evalin('caller', expr);

if r==0
 r=['check ' expr ' failed.'];
else 
 r=''; 
end

