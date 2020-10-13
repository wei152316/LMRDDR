close all; clear all;
load data.mat
[a,b,c,d] = size(data);
A_data = zeros(a*b,c);
for i = 1:c
    A_data(:,i) = reshape(data(:,:,i,10),[a*b,1]);
end
maxd = max(max(A_data));
mind = min(min(A_data));
A_data = (A_data-mind)./maxd;
% showdcm(A_data,a,b,c);
[A,E] = exact_alm_rpca(A_data);
save rpca.mat A E A_data
showdcm(E,a,b,c);
function showdcm(image,a,b,c)
figure;
while(1)
   for i = 1:c
       if strcmpi(get(gcf,'CurrentCharacter'),'e')
          close all
          return;
       end
       imshow(reshape(image(:,i),[a,b]),[]);
       pause(1);
   end
end
end