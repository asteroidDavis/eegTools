% procedure SIMDIAG2 - MODIFIED VERSION WITH SVD
%Tim Sauer and Steven Schiff 2003-2005
function [H, lambda] = simdiag2(W, A) ;
%%%%%%%%TIM'S VERSION %%%%%%%%%%%%%%%%%%%
[u1,s1,v1]=svd(W);
% then the sqrt of W is g
g=u1*sqrt(s1)*u1';
ginv=pinv(g); 
[u2,s2,v2]=svd(ginv*A*ginv); 
H=g*u2;  
gamma=ginv*u2;
lambda = diag(s2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
