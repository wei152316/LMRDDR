%==============================================================================
% This code is part of the Matlab-based toolbox
% FAIR - Flexible Algorithms for Image Registration. 
% For details see 
% - https://github.com/C4IR and
% - http://www.siam.org/books/fa06/
%==============================================================================
%
% Tutorial for FAIR: MLPIR, MultiLevel Parametric Image Registration
% 
%   - data                 HNSP, Omega=(0,2)x(0,1), level=3:7, m=[256,128]
%   - viewer               viewImage2D
%   - interpolation        splineInter
%   - distance             SSD
%   - pre-registration     affine2D
%   - optimization         Gauss-Newton
% ===============================================================================

clear, close all, help(mfilename);

setup2DHNSPData;                             % set up data
% distance('reset','distance','SSD');          % specify distance measure
% imgModel('reset','imgModel','splineInter','regularizer','moments','theta',1e-2);  % specify interpolator
% trafo('reset','trafo','affine2D');           % specify transformation
% regularizer('reset','regularizer','mbCurvature','alpha',1e1);

imgModel('reset','imgModel','splineInter','regularizer','moments','theta',1e-2);
distance('reset','distance','SSD');
trafo('reset','trafo','affine2D');
regularizer('reset','regularizer','mbCurvature','alpha',1e1);

[wc,his] = MLPIR(ML,'minLevel',3,'plotMLiter',1);
%==============================================================================
