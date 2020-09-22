%====================================
%多分辨率参数图像配准 mutil level parameteric image registration
%====================================
%[yc,w] = MLPR(T,RC,omega,m,wo)
%====================================

function w = my_MLPR(ML,varargin)

if nargin == 0 && nargout == 0 %& isempty(OPTN),
  help(mfilename);
  runMinimalExample
  return;
end
tt = 2;
imgModel('reset','imgModel','linearInter');
distance('reset','distance','SSD');
trafo('reset','trafo','affine2D');
regularizer('reset','regularizer','mbCurvature','alpha',1e1);

PIRobj      = @PIRobjFctn;
PIRpara     = optPara('SD');

[ML,minLevel,maxLevel] = getMultilevel(ML);
minLevel = maxLevel -tt;
% pre-registration
% [w_pre,his] = affine(ML{maxLevel}.T,ML{maxLevel}.R,'omega',ML{maxLevel}.omega,'m',ML{maxLevel}.m,'flag',0,'LM',0,'messure','SSD');
% 
% 插值
% xc = getCellCenteredGrid(ML{maxLevel}.omega,ML{maxLevel}.m);
% yc = affine2D(w_pre,xc);
% dataT = reshape(imgModel(ML{maxLevel}.T,ML{maxLevel}.omega,yc),ML{maxLevel}.m);
% ML = getMultilevel({dataT,ML{maxLevel}.R},ML{maxLevel}.omega,ML{maxLevel}.m);


imgModel('reset','imgModel','splineInter','regularizer','moments','theta',1e-2);


plotIter    = 0;% flag for output of iteration history each level
plotMLiter  = 0;% flag for output of summarized iteration history

%生成网格
grid_size = 5; %init grid size for the coarse level
omega = ML{minLevel}.omega;
m = ML{minLevel}.m;
dim = size(omega,2)/2;
xc = getCellCenteredGrid(ML{minLevel}.omega,ML{minLevel}.m); %获取当前分辨率的坐标点 横坐标是m（1）纵坐标是m（2）
for i = 1:dim
    h(i) = (omega(2*i)-omega(2*i-1))./m(i);
end
gs = grid_size.*h; % the phy size of the grid
[x, y] = meshgrid((1-grid_size)*h(1)+h(1)/2:gs(1):(m(1)+2*grid_size)*h(1)+h(1)/2, ...
(1-grid_size)*h(2):gs(2):(m(2)+2*grid_size)*h(2)+h(2)/2);
p = size(x); p = [p(2),p(1)];
x = x';y = y';
wc = [x(:);y(:)]; 
% test = [1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20]
% [wOpt,] = subdivide(test,[5,2],1);
wc = reshape(wc,[p,2]);
wmin = [wc(1,1,1),wc(1,1,2)];
trafo('reset','trafo','my_spline2d','omega',ML{minLevel}.omega,'m',ML{minLevel}.m,'p',p,'wmin',wmin,'gs',gs);
w0          = trafo('w0');
[yc,dy] = my_spline2d(w0,xc);



%w0          = wOpt;
w0          = trafo('w0');
wStop       = w0;  
wRef        = w0;           % regularization: (w-wRef)'*M*(w-wRef)
M           = [];           %
beta        = 0.1;            % regularization: H -> H + beta*I

for k=1:2:length(varargin)   % overwrites default parameter
  eval([varargin{k},'=varargin{',int2str(k+1),'};']);
end

%omega = ML{end}.omega;
tic

for level=maxLevel-tt:maxLevel
  m     = ML{level}.m;
  omega = ML{level}.omega;
  % p 为网格点个数 wmin 为网格点起始坐标 gs为网格点宽度
  trafo('reset','trafo','my_spline2d','omega',omega,'m',m,'p',p,'wmin',wmin,'gs',gs);
  
  % get data for current level, compute interpolation coefficients
  [T,R] = imgModel('coefficients',ML{level}.T,ML{level}.R,omega);
 
  % update transformation
  trafo('set','omega',omega,'m',m);
  
   % initialize plots
  PIRpara.Plots('reset','mode','PIR-multi level','fig',level);
  PIRpara.Plots('init',struct('Tc',T,'Rc',R,'omega',ML{level}.omega,'m',ML{level}.m));
  
   % ----- call PIR ------------------------------------
  xc   = getCellCenteredGrid(ML{level}.omega,ML{level}.m);
  Rc   = imgModel(R,ML{level}.omega,center(xc,ML{level}.m));
  fctn = @(wc) PIRobj(T,Rc,ML{level}.omega,ML{level}.m,beta,M,wRef,xc,wc);
  if level == maxLevel-tt
    fctn([]);   % report status
  else
    w0 = wOpt;  % update starting guess
  end
  PIRpara.yStop = wStop;
  f = fieldnames(PIRpara);
  v = struct2cell(PIRpara);
  temp = reshape({f{:};v{:}},1,[]);
  [wOpt,hisPIR] = PIRpara.scheme(fctn,w0,temp{:});
  if level<maxLevel
    [wOpt,] = subdivide(wOpt,p,1); % parameter update 
    [wStop,p] = subdivide(wStop,p,1);
    gs = gs/2;
  end
  % ----- end PIR --------------------------------------
  if plotIter                                             
    plotIterationHistory(hisPIR,'J',[1,2,5],'fig',20+level);  
  end
  if level == maxLevel-tt
    his.str = hisPIR.str;
    his.his = hisPIR.his;
  else
    his.his = [his.his;hisPIR.his];
  end
end
% -- for loop over all levels ---------------------------------------------
his.time = toc;
if plotMLiter
  plotMLIterationHistory(his,'fig',30);
end
if isempty(wStop), wStop = w0; end
his.reduction = hisPIR.his(end,2) / (hisPIR.his(1,2)+(hisPIR.his(1,2)==0));
J = find(his.his(:,1)==-1); 
his.iter(maxLevel-tt:maxLevel) = his.his([J(2:end)-1;size(his.his,1)],1)';
w = wOpt;
FAIRmessage([mfilename,' : done !']);


function [ML] = getML(dataT,dataR,omega,m)
imgModel('reset','imgModel','splineInter','regularizer','moments','theta',1e-2);
[coefT,coefR] = imgModel('coefficients',dataT,dataR,omega,'out',0);
for i = 0:3
    level = log2(m(1));
    xT = getCellCenteredGrid(omega,m);
    xR = getCellCenteredGrid(omega,m);
    Tc = imgModel(coefT,omega,xT);
    Rc = imgModel(coefR,omega,xR);
    ML{1,level}.m = m;
    ML{1,level}.omega = omega;
    ML{1,level}.T = reshape(Tc,m);
    ML{1,level}.R = reshape(Rc,m);
    m = m/2;
end

function doPause(p)
if strcmp(p,'on')
  pause; 
elseif p>0
  pause(p); 
end

function runMinimalExample
clear all; close all;
setup2DHNSPData;
load mirt2D_data1.mat;
m = size(im);
omega = [0,m(1),0,m(2)];
im = 256.*im;
refim = 256.*refim;
ML = getMultilevel({im,refim},omega,m);
wc = my_MLPR(ML);
xc   = getCellCenteredGrid(omega,m);
[T,R] = imgModel('coefficients',im,refim,omega);
yc = trafo(wc,center(xc,m));
Tc   = reshape(imgModel(T,omega,center(yc,m)),m);
Fixed = reshape(imgModel(T,omega,center(xc,m)),m);
Rc   = reshape(imgModel(R,omega,center(xc,m)),m);
figure,imshow(Tc,[]);
title('deformed image');
figure,imshow(Rc,[]);
title('reference image');
figure,imshow(Fixed,[]);
title('fixed image');
