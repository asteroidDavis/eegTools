% function cLDA = CanonicalLDA(Y,Groups,GroupLabels)
% canonical linear discrimination analysis
%
% Bruce J. Gluckman
% 3/09
%
% Modeled after Flurry, chapter 7
% some coding follows 
%       Schiff SJ, Sauer T, Kumar R, Weinstein SL. 
%       Neuronal spatiotemporal pattern discrimination: the dynamical evolution of seizures. 
%       Neuroimage. 2005 Dec;28(4):1043-55. PMID: 16198127
%
function classLDA = CanonicalLDAClassify(Y,cLDA)
%  input has the elements
%         cLDA.p        = dimensional size of a measured data value
%         cLDA.k    	= number of groups
%         cLDA.mu_j     = (estimated) group mean
%         cLDA.psi_j    = (estimated) group covariance
%         cLDA.psi_w    = within group covariance
%         cLDA.psi_bar  = total covariance
%         cLDA.psi_b    = between covariance
%         cLDA.m        = number of classifier vectors
%         cLDA.Gam1     = classifier rotation matrix
%         cLDA.Zmu_j    = centers of each group
%         cLDA.MissClassificationRate
% output has the elements
%         classLDA.Group= classified group
%         classLDA.Z    = data positions in transformed coordinates

Dists = zeros(cLDA.k,1);
classLDA.Z = Y*cLDA.Gam1;
NTot = size(Y,1);
classLDA.Group = zeros(NTot,1);
%
for j=1:classLDA.k
    r = bsxfun(@minus,classLDA.Z,classLDA.Zmu_j(j,:));
    Dists(:,j) = sum(r.*r,2);
end;
[minr,classLDA.Group] = min(Dists,[],2);
