clear, close all
setup2D_lungdata
xc = getCellCenteredGrid(omega,m);
image = @(xc) imgModel(dataT,omega,xc);
cc = getTPScoefficients(LM(:,1:4),'theta',100);
[yc,yLM] = evalTPS(LM,cc,xc); 
LM(:,[5,6]) = reshape(yLM,[],2); 
P5_LM;
figure,viewImage2D(image(yc),omega,m,'colormap','bone(256)','title','result');

figure,viewImage2D(image(xc),omega,m,'colormap','bone(256)','title','moving');

figure,viewImage2D(dataR(:),omega,m,'colormap','bone(256)','title','fixed');