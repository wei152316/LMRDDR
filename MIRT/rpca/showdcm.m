function showdcm(image,a,b,c)
figure;
while(1)
   for i = 1:c
       if strcmpi(get(gcf,'CurrentCharacter'),'e')
          close all
          return;
       end
       imshow(reshape(image(:,i),[a,b]),[]);
       pause(0.1);
   end
end
end