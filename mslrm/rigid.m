%全局刚性配准
function [wc,yc] = rigid(im,refim,varargin)

imgModel('set','imgModel','splineInter');
addpath(genpath('D:\code\FAIR.m'));
[row,col] = size(im); omega = [0,row,0,col]; m = [row,col];
[T,R] = imgModel('coefficients',im,refim,omega);
xc = getCellCenteredGrid(omega,m);

Rc = imgModel(R,omega,xc);
edge = 0.2;
dispimage = 0;

for k=1:2:length(varargin)               % overwrites default parameter
    eval([varargin{k},'=varargin{',int2str(k+1),'};']);
end;
% distance('set','distance','SSD');       % initialize distance measure
distance('reset','distance','NGF','edge',edge);

trafo('reset','trafo','rigid2D'); w0 = trafo('w0');

% FAIRplots('reset','mode','PIR-rigid','omega',omega,'m',m,'fig',1,'plots',1);
% FAIRplots('init',struct('Tc',T,'Rc',R,'omega',omega,'m',m)); 

% ----- call Gaus-Newton ------------------------------------
GNoptn = {'maxIter',500,'Plots',@FAIRplots,'solver','backslash','dispimage',dispimage,'m',m};
fctn  = @(wc) PIRobjFctn(T,Rc,omega,m,0,[],[],xc,wc);
[wc,~] = GaussNewton(fctn,w0,GNoptn{:});
[yc,] = trafo(wc,xc,'doDerivative',0);


% plot iteration history
% his.str{1} = sprintf('iteration history PIR: distance=%s, y=%s',distance,trafo);
% [ph,th] = plotIterationHistory(his,'J',1:4,'fig',2);
%==============================================================================
end
