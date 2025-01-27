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
function cLDA = CanonicalLDA(Y,Groups,GroupLabels)
%  Output has the elements
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

%
cLDA.p = size(Y,2);
cLDA.k = length(GroupLabels);
N_j = zeros(cLDA.k,1);
cLDA.mu_j = zeros(cLDA.k,cLDA.p);
cLDA.psi_j = zeros(cLDA.k,cLDA.p,cLDA.p);
cLDA.psi_w = zeros(cLDA.p,cLDA.p);
NTot = size(Y,1);
cLDA.psi_bar = cov(Y,1);
%
for j=1:cLDA.k
    GroupIndex = find(Groups==GroupLabels(j));
    N = length(GroupIndex);
    N_j(j) = N;
    cLDA.mu_j(j,:) = mean(Y(GroupIndex,:));
    cLDA.psi_j(j,:,:) = cov(Y(GroupIndex,:),1);  % normalizes by N not N-1
    cLDA.psi_w = cLDA.psi_w + (N/NTot)*squeeze(cLDA.psi_j(j,:,:));
end
cLDA.psi_b = cLDA.psi_bar - cLDA.psi_w;
%  now do the simultaneous diagonalization
[H, lambda] = simdiag2(cLDA.psi_w, cLDA.psi_b) ; %HERE IS WHERE SVD APPLIED IN SUBROUTINE
Gam = inv(H');
% now figure out how many useful dimensions
% recall m = min(k-1,p);
cLDA.m = min(cLDA.p,cLDA.k-1);
%
cLDA.Gam1 = Gam(:,1:cLDA.m);
%
cLDA.Zmu_j = cLDA.mu_j*cLDA.Gam1;
%
%% Now try classifying
% 
% Dists = zeros(NTot,cLDA.k);
% Z = Y*cLDA.Gam1;
% class = zeros(NTot,1);
% %
% for i=1:NTot
%     for j=1:cLDA.k
%         r = Z(i,:) - cLDA.Zmu_j(j,:);
%         Dists(i,j) = sum(r.*r);
%     end;
%     [minr,I] = min(Dists(i,:));
%     class(i) = I;
% end
classLDA = CanonicalLDAClassify(Y,cLDA)
%% now estimate how many correct
%
NWrong = 0;
for j=1:cLDA.k
    GroupIndex = find(Groups==GroupLabels(j));
    NWrong = NWrong + sum(classLDA.Group(GroupIndex)~=j);
end
cLDA.MissClassificationRate = NWrong/NTot;
% message = sprintf('Missclassification rate = %g', cLDA.MissClassificationRate);
% disp(message);