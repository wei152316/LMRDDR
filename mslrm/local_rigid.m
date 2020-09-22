function newLM = local_rigid(im,refim,LM,varargin)
if nargin == 0
    runminexample();
    return;
end
addpath(genpath('D:\code\FAIR.m'));
[row,col] = size(im); omega = [0,row,0,col]; m = [row,col];
% initialize the interpolation scheme and coefficients
imgModel('reset','imgModel','linearInter'); 
[T,R] = imgModel('coefficients',im,refim,omega,'out',0);
xc    = getCellCenteredGrid(omega,m); 
Rc    = imgModel(R,omega,xc);
p = [7,7];%宽5*高5 只能是基数
edge = 0.2;
%一次计算所有的LM点;
num = size(LM,1); %获取检测标记点对的个数
newLM = zeros(num,6);
dispimage = 0;
for k=1:2:length(varargin)               % overwrites default parameter
  eval([varargin{k},'=varargin{',int2str(k+1),'};']);
end;

msize = (p(1)-1)/2;
for i = 1:num
x = LM(i,3);y = LM(i,4);%获取参考位置的坐标点
[t1,t2] = meshgrid(x-msize:x+msize,y-msize:y+msize); %在标记点附近生成15*15的网格
x = [reshape(t1,[],1);reshape(t2,[],1)];
xc = pixeltocenter(x,omega,m,p); %将图像坐标点数据转换成中心点
Rc_local    = imgModel(R,omega,xc); %插值生成局部图像数据;

%配准参数设置
% initialize distance measure
% distance('set','distance','SSD');
distance('reset','distance','NGF','edge',edge);
% -- the PIR pre-registration -------------------------
trafo('reset','trafo','rigid2D'); w0 = trafo('w0');
beta = 0; M = []; wRef = [];
w0(2) = LM(i,2)-LM(i,4); w0(3) = LM(i,1) - LM(i,3);
fctn = @(wc) lcPIRobjFctn(T,Rc_local,omega,m,beta,M,wRef,xc,wc,p); fctn([]); % report status
% solve PIR
[wc,his] = lcGaussNewton(fctn,w0,'maxIter',500,'solver','backslash','Plots',@FAIRplots,'p',p,'dispimage',dispimage);

w = [cos(wc(1)),-sin(wc(1)),wc(2),sin(wc(1)),cos(wc(1)),wc(3)];
q = kron(eye(2),[LM(i,4),LM(i,3),1]);
rxnew = q*w';
newLM(i,:) = [LM(i,:),rxnew(2),rxnew(1)];
end

%显示坐标


end

function runminexample()
% setup data and initialize image viewer
clear all; close all;
setup2DhandData; 
level = 5; omega = ML{level}.omega; m = ML{level}.m;
im = ML{level}.T'; refim = ML{level}.R';

h  = (omega(2:2:end)-omega(1:2:end))./m;
LM(:,1:2:3) = (LM(:,1:2:3)-h(1)/2)./h(1);
LM(:,2:2:4) = (LM(:,2:2:4)-h(2)/2)./h(2);
figure,imshow(im,[]);hold on;
plot(LM(:,1),LM(:,2),'r*');
figure,imshow(refim,[]);hold on;
plot(LM(:,3),LM(:,4),'r*');

%局部刚性配准
newLM = local_rigid(im,refim,LM);

figure,imshow(im,[]);hold on;
plot(newLM(:,5),newLM(:,6),'r*');
figure,imshow(refim,[]);hold on;
plot(newLM(:,3),newLM(:,4),'r*');
end



%==============================================================================
