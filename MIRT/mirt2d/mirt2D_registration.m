% MIRT2D_REGISTERATION  non-rigid registration 
% of a single pair of 2D images at a given hierarchical level

% Copyright (C) 2007-2010 Andriy Myronenko (myron@csee.ogi.edu)
% also see http://www.bme.ogi.edu/~myron/matlab/MIRT/
%
% This file is part of the Medical Image Registration Toolbox (MIRT).

function [X, im]=mirt2D_registration(X, main, optim)

%% normalize the initial optimization step size
% compute the gradient of the similarity measure
[Xx,Xy]=mirt2D_nodes2grid(X, main.F, main.okno);
[f, ddx, ddy]=mirt2D_similarity(main, Xx, Xy);
% divide the initial optimization step size by the std of the gradient
% this somewhat normalizes the initial step size for different possible
% similarity measures used
optim.gamma=optim.gamma/std([ddx(:); ddy(:)],0);
clear ddx ddy Xx Xy

%% Start the main registration
% compute the objective function and its gradient
%fe：目标函数值，T函数值的导数，im：插值后的图像
[fe, T, im]=mirt2D_grad(X,  main);              % compute the similarity measure and its gradient
try
    lamda = optim.lmlamda;
catch
    y = 0;dy = 0;
    warning('no landmark parameters');
end
if exist('lamda','var')
    if main.level <= 1
        [y,~] = landmark(main.LM,X,main.okno,lamda,main); %标记点约束项
        lamda = main.lm_cof*abs(fe)./(y);
        [y,dy] = landmark(main.LM,X,main.okno,lamda,main); %标记点约束项
    else
%         [y,~] = landmark(main.LM,X,main.okno,lamda,main); %标记点约束项
%         lamda = num./100*main.lm_cof*abs(fe)./(y*cc1*cc2);
        [y,dy] = landmark(main.LM,X,main.okno,lamda,main); %标记点约束项
    end
end
T = T+dy;

[Xp, fr]=mirt2D_regsolve(X,T,main, optim, 1);   % compute the regularization term and update the transformation
% edited by cnx 18/5/29

f=fe+fr+y;                                        % compute the value of the total objective function (similarity + regularization)

fchange=optim.fundif+1; % some big number
iter=0;

% do while the relative function difference is below the threshold and
% the meximum number of iterations has not been reached
while (abs(fchange)>optim.fundif) && (iter<optim.maxsteps)
                
        % find the new positions of B-spline control points,
        % given their currect positions (X) and gradient in (T)
        [Xp, fr]=mirt2D_regsolve(X,T,main, optim);    % compute the regularization term and update the transformation
        
        % compute new function value and new gradient
        [fe, Tp, imb]=mirt2D_grad(Xp,  main);        % compute the similarity measure and its gradient
        if exist('lamda','var')
            [y,dy] = landmark(main.LM,Xp,main.okno,lamda,main); %标记点约束项
        end
        Tp = Tp+dy;
        fp=fe+fr +y;
%         Tp = dy;
%         fp=fe+y;
        % compute the relative objective function change
        fchange=(fp-f)/f;
        % check if the step size is appropriate
        if ((fp-f)>0),
            % if the new objective function value does not decrease,
            % then reduce the optimization step size and
            % slightly increase the value of the objective function 
            % (this is an optimization heuristic to avoid some local minima)
            optim.gamma=optim.gamma*optim.anneal;
            f=f+0.001*abs(f);
        else
            % if the new objective function value decreased
            % then accept all the variable as true and show the progress
            X=Xp; f=fp; T=Tp; im=imb;
            
            if main.single
                subplot(1,3,1,'align'), imshow(main.refimsmall); title('Reference image'); drawnow;
                subplot(1,3,2,'align'), imshow(im); title('Registration progress'); drawnow;
                subplot(1,3,3,'align'), mirt2D_meshplot(X(:,:,1),X(:,:,2));  drawnow;
            end
             
            % show progress
           disp([upper(main.similarity) ' ' num2str(f-y) ' dif ' num2str(fchange) ' sub ' num2str(main.level) ' cyc ' num2str(main.cycle) ' vol ' num2str(main.volume) ' iter ' num2str(iter) ' gamma = ' num2str(optim.gamma)]);
        end;
      iter=iter+1;
end
