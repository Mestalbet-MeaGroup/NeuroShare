[O D]=eig(normB);
X = real(sqrtm(D))*O';

tildeX = X(end-1:end, :);
[idx center] = kmeans(tildeX', 5);

subplot(121);
scaling(normB, 2);

subplot(122);
cm = colormap(autumn);
colorTick = 1:15:64;
for i = 1:size(tildeX, 2)
    myColor = idx(i);
    plot(tildeX(2, i), tildeX(1, i), '+', 'color', cm(colorTick(myColor), :));
    hold on;
end