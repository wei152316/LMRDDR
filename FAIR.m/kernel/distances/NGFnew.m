function [Dc,rho,dD,drho,d2psi] = NGFnew(Tc,Rc,omega,m,varargin)
% This is a wrapper to NGFdot, THE implementation of Normalized Gradient Fields

if nargin == 0,  
  help(mfilename);  
  NGFdot;  
  return;  
end;

[Dc,rho,dD,drho,d2psi] = NGFdotnew(Tc,Rc,omega,m,varargin{:});