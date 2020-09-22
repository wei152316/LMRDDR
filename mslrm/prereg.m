%pre-registration (rigid) using FAIR tool
function [NewImg,wc] = prereg(refim,im)
    [wc,yc] = rigid(im,refim,'edge',0.1,'dispimage',0);
    [row,col] = size(im); omega = [0,row,0,col]; m = [row,col];
    [T,~] = imgModel('coefficients',im,refim,omega);
    NewImg = reshape(imgModel(T,omega,yc),[row,col]);
end