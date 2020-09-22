%输入：xc：图像中心点坐标，wc：网格点坐标 gs 网格点的实际宽度
%输出 yc：变换后图像中心点坐标，dy：对参数的导数 
function [y,dy] = my_spline2d(w,x,varargin)
persistent Q p m omega wmin gs
for k=1:2:length(varargin), % overwrite default parameter
  eval([varargin{k},'=varargin{',int2str(k+1),'};']);
end;
if nargin==0
    warning('none of input') 
    return;
else
  y = mfilename('fullfile'); 
  dy = zeros(2*prod(p),1);             % parameterization of identity
  if ischar(w),  Q  = []; w = []; end; % reset Q
  if isempty(w), return;          end; 
end;

if isempty(w) || (size(Q,1) ~= numel(x)) || (size(Q,2) ~= numel(w)),
  % it is assumed that x is a cell centered grid, extract xi1 and xi2
  dim = size(omega,2)/2;
  n   = numel(x)/dim
  if n == prod(m) %m 是当前网格的大小 判断当前是否是中心点 p是控制点的大小
    q = m;
  elseif n == prod(m+1)
    q = m+1
  else
    error('can not handle this grid')
  end;
  x  = reshape(x,[q,2]);

  Q1 = (1./6)*getQ1d(omega(1:2),q(1),p(1),x(:,1,1),wmin(1),gs(1));
  Q2 = (1./6)*getQ1d(omega(3:4),q(2),p(2),x(1,:,2),wmin(2),gs(2));
  Q  = kron(speye(2),kron(sparse(Q2),sparse(Q1)));
  if nargout == 0, return; end;
end;

y = x(:) + Q*w;
dy = Q;


function Q = getQ1d(omega,m,p,xi,wmin,gs)
Q  = zeros(m,p); xi = reshape(xi,[],1);
for j=1:p,
  cj=zeros(p,1); cj(j) = 1;
  Q(:,j) = my_splineInter(cj,omega,xi,wmin,gs);
end