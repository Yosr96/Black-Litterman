T = readtable('1120_ci_data_bl.xlsm');
assetNames = {"MLEXPTL", "MLHEUCL", "MLCORML", "MLHMACL", "JPMPTOT"};
%Dates=;
%head(T(:,[HeadNames]))

assetprice=T{:, 2:end};
retnsT = tick2ret(assetprice);
%assetRetns = retnsT{:,};
numAssets = size(assetRetns, 2);
v = 3;  % total 3 views
P = zeros(v, numAssets);
q = zeros(v, 1);
Omega = zeros(v);

% View 1
P(1, assetNames=='MLEXPTL') = 1; 
q(1) = 0.05;
Omega(1, 1) = 1e-3;

% View 2
P(2, assetNames=='MLCORML') = 1; 
q(2) = 0.03;
Omega(2, 2) = 1e-3;

% View 3
P(3, assetNames=='MLHMACL') = 1; 
P(3, assetNames=='JPMPTOT') = -1; 
q(3) = 0.05;
Omega(3, 3) = 1e-5;