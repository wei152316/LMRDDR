%multi_scale local rigid
function [newLM,hiswc] = mslocal_rigid(im,refim,LM,Scale,coef,thrc,varargin)

addpath(genpath('D:\code\FAIR.m'));
[row,col] = size(im); omega = [0,row,0,col]; m = [row,col];
% initialize the interpolation scheme and coefficients
imgModel('reset','imgModel','linearInterMex');
[T,R] = imgModel('coefficients',im,refim,omega,'out',0);

p = [7,7];
num = size(LM,1);
newLM = zeros(num,4);
dispimage = 0;
edge = 0;
for k=1:2:length(varargin)               % overwrites default parameter
    eval([varargin{k},'=varargin{',int2str(k+1),'};']);
end;
msize = (p(1)-1)/2;
wcp = w0;

for j = 1:Scale
 if j>1
            gausFilter = fspecial('gaussian',[3 3],1.6);
            msr{j} = imfilter(msr{j-1},gausFilter,'replicate');
            mst{j} = imfilter(mst{j-1},gausFilter,'replicate');
        else
            msr{j} = R;
            mst{j} = T;
 end
end

for i = 1:num 
    for j = 1:Scale %multiscale registration
        xc = cell2mat(msxc(Scale-j+1));
        R = msr{Scale-j+1};
        T = mst{Scale-j+1};
        Rc_local    = imgModel(R,omega,xc);
        distance('reset','distance','NGF','edge',edge);
        trafo('reset','trafo','rigid2D');
        if ~exist('w0','var')
            w0 = wcp;
        end
        beta = 0; M = []; wRef = [];
        if j == 1,
            wold = w0;
        end

        [yc,~] = trafo(w0,xc,'doDerivative',0);
        [Tc,~] = imgModel(T,omega,yc,'doDerivative',0);
        f = calcrc(Tc,Rc_local);
        disp(f)
        if f >= thrc
            wc = [0;0;0];
            break;
        end 

        fctn = @(wc) lcPIRobjFctn(T,Rc_local,omega,m,beta,M,wRef,xc,wc,p); fctn([]); % report status
        [wc,His] = lcGaussNewton(fctn,wold,'maxIter',100,'solver','backslash','Plots',@FAIRplots,'p',p,'dispimage',dispimage);
        wold = wc;
        ngf_value = His.his(end,2);
        if ngf_value == 0
            ngf_value = His.his(end-1,2);
        end
        disp(ngf_value)
        
        [yc,~] = trafo(wc,xc,'doDerivative',0);
        [Tc,~] = imgModel(T,omega,yc,'doDerivative',0);
        wc_his{j} = wc;
        f = calcrc(Tc,Rc_local);
        disp(f)
        if f >= thrc
            break;
        end 
    end

    if abs(wc(1))<10 && f < thrc %removing outliers
        if exist('wc_his')
            wc = wc_his{end-1};
            w1 = [cos(wc(1)),-sin(wc(1)),wc(2),sin(wc(1)),cos(wc(1)),wc(3)];
            q1 = kron(eye(2),[LM(i,2),LM(i,1),1]);
            rxnew1 = q1*w1';
            
            wc = wc_his{end};
            w2 = [cos(wc(1)),-sin(wc(1)),wc(2),sin(wc(1)),cos(wc(1)),wc(3)];
            q2 = kron(eye(2),[LM(i,2),LM(i,1),1]);
            rxnew2 = q2*w2';
            
            vary = rxnew1-rxnew2;
            th1 = sqrt(vary'*vary);
            
            vary = wc_his{end}-wc_his{end-1};
            th2 = sqrt(vary'*vary);
        end
        if th1 < 20 && th2 <30
            rxnew = rxnew2;
            newLM(i,:) = [LM(i,:),rxnew(2),rxnew(1)];
            hiswc{i} = wc;
        end
    else
        hiswc{i} = [-1;-1;-1];
    end
    clear w0 wc;
end
end