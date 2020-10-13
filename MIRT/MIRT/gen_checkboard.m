checkboard = zeros(256,256);
% checkboard(44:84,44:84) = 1;
[row,col] = size(checkboard);
checkboard(row/2-70:row/2+70,col/2-70:col/2+70) = 0.8;
checkboard(row/2-54:row/2+54,col/2-54:col/2+54) = 0;
figure,imshow(checkboard);
save checkboard.mat checkboard
close all;