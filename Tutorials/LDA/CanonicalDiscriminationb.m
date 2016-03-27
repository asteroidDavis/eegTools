%% Cononical Linear Discrimination Analysis
%  Notes derived after Flury, Chapter 7
%
%  Code modified in places from 
%       Schiff SJ, Sauer T, Kumar R, Weinstein SL. 
%       Neuronal spatiotemporal pattern discrimination: the dynamical evolution of seizures. 
%       Neuroimage. 2005 Dec;28(4):1043-55. PMID: 16198127
%
%  Recall from Flurry that
%  we have k groups, X, and measurements Yi which each have p dimensions  
%  Then we can estimate that each group has 
%     mean            mu_j  = E[Y|X=j]
%     cov            psi_j = E[(Y-mu_j)(Y-mu_j)' | X=j]
%     prior prob      pi_j = E[X=j]
%
%  then mixture distribution will have 
%     mean            mu_bar = sum(pi_j*mu_j)
%     cov            psi_bar = sum(pi_j*psi_j) + ...
%                              sum(pi_j*(mu_j-mu_bar)(mu_j-mu_bar)')
%  But we can rewrite as
%                    psi_bar = psi_within + psi_between
%                            = psi_w + psi_b
%
%
%  we want to find a (or set of) linear combinations Z=a'Y that maximizes
%  the ratio of the full variance to the in-group variance:
%            Ratio(a) = Var[a'Y]/Var[a'Y|X=j]
%
%  if we make the assumption that psi_j=psi_w (all have about the same variance)
%  then
%            Ratio(a) = 1 + (a'*psi_b*a)/(a'*psi_w*a)
%                     = 1 + r(a)
%
%  We then use simultaneous decomposition for 2 positive-definite matrices
%           psi_w = H*H'
%           psi_b = H*Lam*H'
%
%           Lam is a (p x p) diagonal matrix with m non-zero 
%           entries lam_i.  m is the rank of psi_b
%
%  We arrange the columns of H so that lam_1>= lam_2...>=0
%
%  Now we see that 
%
%  r(a) = (a'*H*Lam*H'*a)/(a'*H*H*a)
%       = b'*Lam*b / b'b
%
%                        b = H'a
%  b is a vector, so 
%  we're free to choose a proportionality constant, so normalize
%                        b'b = 1
%  so
%      r(a) = b'*Lam*b
%
%  Now comes the tricky part.  We want to maximize 
%      r(a) = b'*Lam*b 
%           = sum(lam_i*b_i^2)
%  but we ordered lam_i, so lam_i<=lam_1
%      r(a)<=lam_1*sum(b_i^2)
%      r(a)<=lam_1
%
%  so r(a) is maximal for for b=(1,0...)'=e1
%  following backward
%  
%  H'a = b
%    a = b*(H')^-1
%  define
%            Gam = (H')^-1 = (gam_1,gam_2,...)
%  then for 
%            b=e1
%  a = gam_1
%
%  and our First Canonical Variate is
%  Z1 = gam_1'*Y
%
%  we can continue this process to find additional linear combination that
%  also maximize the difference subject to the constraint that they add
%  additional information, or are uncorrelated with the existing linear
%  combinations.
%  technically, we write that we want to find additional linear
%  combinations Z_n = a_n'Y
%  that maximize
%               r(a_n)=(a_n'*psi_b*a_n)/(a_n'*psi_w*a_n)
%  subject to the constraints that
%                 a_n'*psi_w*a_q = 0  for q<n
%  This constraint can be rewritten from psi_w=H*H'
%                 a_n'*H*H'*a_q = 0
%                      b'*H'*a_q = 0
%
%
%  if you follow the above steps to find a_2, and recognize that 
%   a_1 = gam_1
%   H'*a_1 = e1
%  then above, where we maximized r(a_n) = sum(lam_i*b_i^2)
%  the constraint says that 
%                           b'*e1 = 0, or b_1 = 0
%  then the inequality must translate to
%   r(a_n)<lam_2*sum(b_i^2)=lam_2
%  which is satified with 
%                        b_2 = e2 
%  and
%  Z2 = gam_2'*Y
%  and by extension
%  Zn = gam_n'*Y
%
%  We can find m canonical uncorrelated discriminant functions
%  and all differences in location among the k groups are contained in 
%  m<=p variables Z1..Zm
%  m<= min(p,k-1)
%  where k= number of groups and p is the number of dimensions measured
%
%  Algorithmically, to classify a point, you do the following steps
%  I) Extract the classifiers
%    1) find (estimate) the mean, covariance, prior probability of all groups
%    2) find the within and between variances
%    3) co-diagonalize the matrices to get H and Lam
%    4) invert Gam = inv(H'), extract the m<=min(p,k-1) nonzero vectors.   These are our a_n
%    5) create a linear transformation matrix A = [a_1; a_2; a_3]  
%      (p x m) with nth row filled with vector a_n'

%  II) To classify a point y
%    1) compute the k mutual vector distances of the point from the group means:
%        d_j = y-mu_j
%    2) transform these vectors into a space spanned by a_n
%    3) compute the length of these new vector
%    4) classify with the smallest of these
%
%% first make a dummy function
% this allows us to include the standard functions at the end here
% function cow = cows()
% cow = 0;
%%  Create some data
%   here we use multivariate normal distributed data, 3 groups, in 2
%   dimensions each generated with the same covariance
mu = [2 1; 5 1; 2 -2];
sig = [2 1; 1 1];
Nper = 300;
y1 = mvnrnd(mu(1,:),sig,Nper);
y2 = mvnrnd(mu(2,:),sig,Nper);
y3 = mvnrnd(mu(3,:),sig,Nper);
figure; 
plot(y1(:,1),y1(:,2),'ro',...
     y2(:,1),y2(:,2),'go',...
     y3(:,1),y3(:,2),'bo');
title('example 2d multivariate data');
%% Group all data together in a common array
%
Y = [y1; y2; y3];
Groups = squeeze([ones(size(y1,1),1)' 2*ones(size(y2,1),1)' 3*ones(size(y3,1),1)']);
GroupLabels = [1 2 3];
%
%%  Compute the means and covariances
%
% make space
p = size(Y,2);
k = length(GroupLabels);
N_j = zeros(k,1);
mu_j = zeros(k,p);
psi_j = zeros(k,p,p);
psi_w = zeros(p,p);
NTot = size(Y,1);
psi_bar = cov(Y,1);
%
for j=1:k
    GroupIndex = find(Groups==GroupLabels(j));
    N = length(GroupIndex);
    N_j(j) = N;
    mu_j(j,:) = mean(Y(GroupIndex,:));
    psi_j(j,:,:) = cov(Y(GroupIndex,:),1);  % normalizes by N not N-1
    psi_w = psi_w + (N/NTot)*squeeze(psi_j(j,:,:));
end
psi_b = psi_bar - psi_w;
%  now do the simultaneous diagonalization
[H, lambda] = simdiag2(psi_w, psi_b) ; %HERE IS WHERE SVD APPLIED IN SUBROUTINE
Gam = inv(H');
% now figure out how many useful dimensions
% recall m = min(k-1,p);
m = min(p,k-1);
%
Gam1 = Gam(:,1:m);
%
%% Now try classifying
% 
Dists = zeros(NTot,k);
Z = Y*Gam1;
Zmu_j = mu_j*Gam1;
classifiedGroup = zeros(NTot,1);
%
for j=1:k
    r = bsxfun(@minus,Z,Zmu_j(j,:));
    Dists(:,j) = sum(r.*r,2);
end;
[minr,classifiedGroup] = min(Dists,[],2);
%%
figure;

plot(Z(:,1),Z(:,2),'.','MarkerSize',1); hold;
Symb = {'ro' ; 'go' ; 'bo'};
for j=1:k
    GroupIndex = find(Groups==GroupLabels(j));
    WrongIndex = find(classifiedGroup(GroupIndex)~=j);
    plot(Z(GroupIndex,1),Z(GroupIndex,2),Symb{j});
    plot(Zmu_j(j,1),Zmu_j(j,2),'m.','MarkerSize',10);
    plot(Z(WrongIndex,1),Z(WrongIndex,2),'X','MarkerSize',8);
end
%
%% now estimate how many correct
%
NWrong = 0;
for j=1:k
    GroupIndex = find(Groups==GroupLabels(j));
    NWrong = NWrong + sum(class(GroupIndex)~=j);
end
MissClassificationRate = NWrong/NTot;
message = sprintf('Missclassification rate = %g', MissClassificationRate);
disp(message);
%% now test the function versions
%
cLDA =  CanonicalLDA(Y,Groups,GroupLabels);
classLDA = CanonicalLDAClassify(Y,cLDA);
%
plot(classLDA.Z(:,1),classLDA.Z(:,2),'.','MarkerSize',1); hold;
Symb = {'ro' ; 'go' ; 'bo'};
for j=1:cLDA.k
    GroupIndex = find(Groups==GroupLabels(j));
    WrongIndex = find(classLDA.Group(GroupIndex)~=j);
    plot(classLDA.Z(GroupIndex,1),classLDA.Z(GroupIndex,2),Symb{j});
    plot(cLDA.Zmu_j(j,1),cLDA.Zmu_j(j,2),'m.','MarkerSize',10);
    plot(classLDA.Z(WrongIndex,1),classLDA.Z(WrongIndex,2),'X','MarkerSize',8);
end
%    

