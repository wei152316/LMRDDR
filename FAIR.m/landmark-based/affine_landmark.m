clear, close all, help(mfilename)

%% setup data
setup2D_lungdata

omegaT = omega(1,:);
omegaR = omega(end,:);
xT = getCellCenteredGrid(omegaT,m);
xR = getCellCenteredGrid(omegaR,m);
imgModel('reset','imgModel','linearInter');
viewImage('reset','viewImage','viewImage2D');
Tc = imgModel(dataT,omegaT,xT);
Rc = imgModel(dataR,omegaR,xR);
dim = 2;
if exist('result.log','file'), delete('result.log'); end
fid = fopen('result.log','a+');
%% visualize data
FAIRfigure(1,'figname',mfilename); clf; 
subplot(1,3,1); viewImage(Tc,omegaT,m); hold on;
ph = plotLM(LM(:,1:2),'numbering','off','color','r');
set(ph,'linewidth',1,'markersize',5);
title(sprintf('%s','T&LM'),'fontsize',20);

subplot(1,3,2); viewImage(Rc,omegaR,m); hold on;
ph = plotLM(LM(:,3:4),'numbering','off','color','g','marker','+');
set(ph,'linewidth',1,'markersize',5);
title(sprintf('%s','R&LM'),'fontsize',20);


%% compute landmark based registration
fprintf(fid,'compute landmark based registration\n');
fprintf(fid,'------------------------------------\n');
tmp_diff = LM(:,1:2)-LM(:,3:4);
pre_error = sum(sqrt(sum(tmp_diff.^2,2)))/size(tmp_diff,1);
fprintf(fid,'landmark error before registration = ,%d\n',pre_error);

%%
for i = 1:size(LM,1)
    index = sort(randperm(size(LM,1),i)); %
    LM_selected = LM(index,1:4);
    [yc,LM_selected,w] = LMreg('linear',LM_selected(:,1:4),xR);
    r   = LM(:,dim+1:2*dim);
    Q  = [r,ones(size(LM,1),1)];
    for j = 1:dim
        LM(:,2*dim+j) = Q*w(:,j);
    end
    TLM = imgModel(dataT,omegaT,yc);
    fprintf(fid,'number of landmark = %d\n',i);
    fprintf(fid,'w = %d,%d,%d,%d,%d,%d\n',w(:,1),w(:,2));
    subplot(1,3,3); cla; viewImage(TLM,omegaR,m); hold on;
    ph = plotLM(LM(:,5:6),'numbering','off','color','g','marker','+');
%    qh = plotLM(LM(:,7:8),'numbering','off','color','m','marker','x');
%    rh = plot(LM(:,[3,7])',LM(:,[4,8])','m-','linewidth',3);
%    set([ph;qh;rh],'linewidth',1,'markersize',5);
    set(ph,'linewidth',1,'markersize',5);
    title(sprintf('%s','T(y^{affine})&LM'),'fontsize',20);
    %==============================================================================
    %% error analysis
    tmp_diff = LM(:,1:2)-LM(:,5:6);
    affine_error = sum(sqrt(sum(tmp_diff.^2,2)))/size(tmp_diff,1);
    fprintf(fid,'landmark error after landmark-based affine registration = %d\n',affine_error);
end
fclose(fid);