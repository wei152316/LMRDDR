%==============================================================================
% This code is part of the Matlab-based toolbox
% FAIR - Flexible Algorithms for Image Registration. 
% For details see 
% - https://github.com/C4IR and
% - http://www.siam.org/books/fa06/
% ##2
%==============================================================================
% 
%   - data                 Hands, Omega=(0,20)x(0,25), level=5, m=[32,32]
%   - viewer               viewImage2D
%   - interpolation        splineInter
%   - distance             SSD
%   - pre-registration     affine2D
%   - regularizer          mbElastic
%   - optimization         Gauss-Newton
% ===============================================================================

% setup data and initialize image viewer
setup2DhandData; 
level = 5; omega = ML{level}.omega; m = ML{level}.m; 

% initialize the interpolation scheme and coefficients
imgModel('reset','imgModel','splineInter'); 
[T,R] = imgModel('coefficients',ML{level}.T,ML{level}.R,omega,'out',0);
xc    = getCellCenteredGrid(omega,m); 
Rc    = imgModel(R,omega,xc);

% initialize distance measure
distance('set','distance','SSD');       

% initialize regularization, note: yc-yRef is regularized, elastic is staggered 
regularizer('reset','regularizer','mbElastic','alpha',1e4,'mu',1,'lambda',0);
y0   = getStaggeredGrid(omega,m); yRef = y0; yStop = y0;

% -- the PIR pre-registration -------------------------
trafo('reset','trafo','affine2D'); w0 = trafo('w0')
% setup plots and initialize objective function for PIR
FAIRplots('set','mode','PIR-GN-rigid','omega',omega,'m',m,'fig',1,'plots',1);
FAIRplots('init',struct('Tc',T,'Rc',R,'omega',omega,'m',m)); 
beta = 0; M = []; wRef = []; xc = getCellCenteredGrid(omega,m);
fctn = @(wc) PIRobjFctn(T,Rc,omega,m,beta,M,wRef,xc,wc); fctn([]); % report status
% solve the PIR
PIRpara  = FAIRcell2struct(optPara('GN','maxIter',500,'Plots',@FAIRplots))
[wc,his] = GaussNewton(fctn,w0,PIRpara{:});

y0   = grid2grid(trafo(wc,getNodalGrid(omega,m)),m,'nodal','staggered');
yRef = y0;

%%
% setup and initialize plots 
FAIRplots('set','mode','NPIR-Gauss-Newton','omega',omega,'m',m,'fig',1,'plots',1);
FAIRplots('init',struct('Tc',T,'Rc',R,'omega',omega,'m',m)); 

% build objective function, note: T coefficients of template, Rc sampled reference
fctn = @(yc) NPIRobjFctn(T,Rc,omega,m,yRef,yc); fctn([]); % report status

% -- solve the optimization problem -------------------------------------------
NPIRpara  = FAIRcell2struct(optPara('NPIR-GN','maxIter',500,'Plots',@FAIRplots));
[yc,his] = GaussNewton(fctn,y0,NPIRpara{:},'yStop',yStop);
% report results
iter      = size(his.his,1)-2; 
reduction = 100*fctn(yc)/fctn(getStaggeredGrid(omega,m)); 
yOpt      = yc;
fprintf('reduction = %s%% after %d iterations\n',num2str(reduction),iter);
%==============================================================================
