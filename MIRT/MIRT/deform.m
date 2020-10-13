clear;
close all;
clc;
load example_landmark_data
img=im;
img=img(:,:,1);

[m n]=size(img);

% img(1:3,:)=0;
% img(m-2:m,:)=0;
% img(:,1:3)=0;
% img(:,n-2:n)=0;
% img(415:m,1:18)=0;

% imwrite(img,'t2_90_fixed.tif');
% imwrite(img,'t2_90_fixed.PNG');
figure,imshow(img,[]);

x=1:n;
y=1:m;
[X, Y]=meshgrid(x,y);

X=sin(10*X*pi/m);
Y=cos(10*Y*pi/m);
field(:,:,2)=X;
field(:,:,1)=Y;
field=field*5;
deform_img=imwarp(img,field);
figure,imshow(deform_img,[]);
% deform_img=imresize(deform_img,[round(m/2) round(n/2)]);
% imgedge=double(edge(deform_img,'canny'));
% deform_img=deform_img+uint8(imgedge)*5;
% imwrite(deform_img,'deform_90.tif');
% imwrite(deform_img,'deform_90.PNG');

figure,imshow(deform_img,[]);
imwrite(deform_img,'deform_t1_model.tif');


clear;
close all;
clc;

img=imread('dwi_model.tif');
img=img(:,:,1);

[m n]=size(img);

% img(1:3,:)=0;
% img(m-2:m,:)=0;
% img(:,1:3)=0;
% img(:,n-2:n)=0;
% img(415:m,1:18)=0;

% imwrite(img,'pd_90_fixed.tif');
% imwrite(img,'pd_90_fixed.PNG');
figure,imshow(img);

x=1:n;
y=1:m;
[X, Y]=meshgrid(x,y);

X=sin(5*X*pi/m);
Y=cos(5*Y*pi/m);
field(:,:,2)=X;
field(:,:,1)=Y;
field=field*5;
deform_img=imwarp(img,field);
figure,imshow(deform_img);
% deform_img=imresize(deform_img,[round(m/2) round(n/2)]);
% imgedge=double(edge(deform_img,'canny'));
% deform_img=deform_img+uint8(imgedge)*5;
imwrite(deform_img,'deform_dwi_model.tif');
% imwrite(deform_img,'pd_deform_90.PNG');

figure,imshow(deform_img);


