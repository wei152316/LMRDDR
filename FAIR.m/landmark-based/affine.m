% 
function [wc,his] = affine(dataT,dataR,varargin)
    if nargin==0
    help(mfilename)
    runMinimalExample; 
    return;
    end

    %default parameter
    [row,col] = size(dataT);
    omega = [0,row,0,col];
    m = [row,col];
    flag = 0; % if flag = 1, run error analysis;
    messure = 'MI';
    % overwrites default parameter
    for k=1:2:length(varargin) 
        eval([varargin{k},'=varargin{',int2str(k+1),'};']);
    end
    
    omegaT = omega(1,:);
    omegaR = omega(end,:);
    imgModel('reset','imgModel','linearInter');
    [T,R] = imgModel('coefficients',dataT,dataR,omega,'out',0);
    viewImage('reset','viewImage','viewImage2D','colormap','bone(256)');
    xT = getCellCenteredGrid(omegaT,m);
    xR = getCellCenteredGrid(omegaR,m);

    % T = imgModel(dataT,omegaT,xT);
    Rc = imgModel(dataR,omegaR,xR);
    trafo('reset','trafo','affine2D');
    distance('reset','distance',messure);
    w0 = trafo('w0');
    % setup plots and initialize objective function for PIR
    FAIRplots('reset','mode','PIR-GN-rigid','omega',omega,'m',m,'fig',1,'plots',1);
    FAIRplots('init',struct('Tc',T,'Rc',R,'omega',omega,'m',m)); 

    xc = getCellCenteredGrid(omega,m);
    beta = 0; M = []; wRef = [];
    fctn = @(wc) PIRobjFctn(T,Rc,omega,m,beta,M,wRef,xc,wc); fctn([]); % report status
    % solve PIR
    [wc,his] = GaussNewton(fctn,w0,'maxIter',500,'solver','backslash','Plots',@FAIRplots);
    if flag == 1 && ~isempty(LM),
    error_analysis(LM,wc,messure);end

function error_analysis(LM,wc,messure)
%% landmark_based error analysis
    col = size(LM,1);
    [LM(:,5:6)] = reshape(affine2D(wc,[LM(:,3);LM(:,4)]),[col,2]);
    fid = fopen('result.log','a+');
    tmp_diff = LM(:,1:2)-LM(:,5:6);
    affine_error = sum(sqrt(sum(tmp_diff.^2,2)))/size(tmp_diff,1);
    fprintf(fid,'affine %s error = %d\n',messure,affine_error);
    a = sprintf('affine %s error = %d',messure,affine_error);
    disp(a);
    fclose(fid);

function runMinimalExample
    clear, close all,
    setup2D_lungdata
    affine(dataT,dataR,'omega',omega,'m',m,'flag',1,'LM',LM,'messure','MI');
    