dataT = 255.*mat2gray(dicomread('test1/IM_1027'))';
dataR = 255.*mat2gray(dicomread('test1/IM_1028'))';
load('test1/landmark1.mat')
dcminfo = dicominfo('test1/IM_1027');
h = dcminfo.PixelSpacing;
LM =  [h'.*movingPoints,h'.*fixedPoints]; %landmark positions
omega = [0,h(1)*size(dataT,1),0,h(2)*size(dataT,2)];
m     = size(dataR);

