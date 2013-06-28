function y = gauss(x, sigma)

y = 1/(sigma*sqrt(2*pi)) * exp(-x.^2/(2*sigma^2));



%{
function y = triangle(x, k)

if x >= 0
    y = 1 - x/k;
else
    y = 1 + x/k;
end

end
%}

end