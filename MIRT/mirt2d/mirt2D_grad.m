% MIRT2D_grad computes the value of the similarity measure and its gradient
function  [f, Gr, imsmall]=mirt2D_grad(X,  main)

% find the dense transformation for a given position of B-spline control
% points (X).
%给定网格的位置，求出图像对应坐标
[Xx,Xy]=mirt2D_nodes2grid(X, main.F, main.okno);

% Compute the similarity function value (f) and its gradient (dd) at Xx, Xy
%ddx,ddy是相似度函数的导数乘插值的导数
[f,ddx,ddy, imsmall]=mirt2D_similarity(main, Xx, Xy);

% Find the gradient at each B-spline control point
Gr=mirt2D_grid2nodes(ddx, ddy, main.F, main.okno, main.mg, main.ng);





                        