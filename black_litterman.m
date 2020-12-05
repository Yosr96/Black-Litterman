clear all;
clc;
filename = '1120_ci_data_bl.xlsm';
%T = xlsread(filename)
%filename = 'myExample.xlsx';
sheet2 = 2;
sheet3= 3;
xlRange = 'B1:B5710';
Govies=xlsread(filename,sheet3,xlRange);
Equity = xlsread(filename,sheet2);

assetNames = char('MLEXPTL', 'MLHEUCL', 'MLCORML', 'MLHMACL', 'JPMPTOT');

retnsT = tick2ret(Equity);
retnsG=tick2ret(Govies);
benchmarkRetns=array2table(retnsG,'VariableNames',{'BMBD02Y'});
assetRetns = array2table(retnsT,'VariableNames',{'MLEXPTL','MLHEUCL','MLCORML','MLHMACL','JPMPTOT'});
numAssets = size(retnsT, 2);
v = 3;  % total 3 views
P = zeros(v, numAssets);
q = zeros(v, 1);
Omega = zeros(v);

% View 1
P(1,1 ) = 1; 
q(1) = 0.05;
Omega(1, 1) = 1e-3;

% View 2
P(2,2 ) = 1; 
q(2) = 0.03;
Omega(2, 2) = 1e-3;


% View 3
P(3,3 ) = 1; 
P(3,4 ) = -1; 
q(3) = 0.05;
Omega(3, 3) = 1e-5;
viewTable = array2table([P q diag(Omega)],'VariableNames',{'MLEXPTL','MLHEUCL','MLCORML','MLHMACL','JPMPTOT','View_Return','View_Uncertainty'})

Sigma = cov(assetRetns.Variables);
tau = 1/size(assetRetns.Variables, 1);
C = tau*Sigma;

%
[wtsMarket, PI] = findMarketPortfolioAndImpliedReturn(assetRetns.Variables,benchmarkRetns.Variables);
mu_bl = (P'*(Omega\P) + inv(C)) \ ( C\PI + P'*(Omega\q));
cov_mu = inv(P'*(Omega\P) + inv(C));

%table(assetNames, PI*252, mu_bl*252, 'VariableNames', ["Asset_Name", ...
    %"Prior_Belief_of_Expected_Return", "Black_Litterman_Blended_Expected_Return"])


port = Portfolio('NumAssets', numAssets, 'lb', 0, 'budget', 1, 'Name', 'Mean Variance');
port = setAssetMoments(port, mean(assetRetns.Variables), Sigma);
wts = estimateMaxSharpeRatio(port);

portBL = Portfolio('NumAssets', numAssets, 'lb', 0, 'budget', 1, 'Name', 'Mean Variance with Black-Litterman');
portBL = setAssetMoments(portBL, mu_bl, Sigma + cov_mu);  
wtsBL = estimateMaxSharpeRatio(portBL);

ax1 = subplot(1,2,1);
idx = wts>0.001;
pie(ax1, wts(idx), assetNames(idx));
title(ax1, port.Name ,'Position', [-0.05, 1.6, 0]);

ax2 = subplot(1,2,2);
idx_BL = wtsBL>0.001;
pie(ax2, wtsBL(idx_BL), assetNames(idx_BL));
title(ax2, portBL.Name ,'Position', [-0.05, 1.6, 0]);
table(assetNames', wts, wtsBL, 'VariableNames', ["AssetName", "Mean_Variance", ...
     "Mean_Variance_with_Black_Litterman"])



