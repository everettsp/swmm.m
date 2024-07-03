function pcfs = ivs_pc(X,y,varargin)
%% Applies parcial correlation feature selection
%% algorithm description
% Based on (He et al. 2011) and (May et al. 2008)
%
% initialize candidate set C = X
% select first input based on maximum mutual information between input and output
% while candidate input set (C) remain or termination criteria is met
%     regress selected input/s (S) on output (Y)
%     calculate AIC to check termination criteria
%     regress selected input/s on each remaining candidate input (Cj)
%     calculate Pearson's Correlation for each Cj
%     select next input based on maximum R (remove Cj from candidate set, add to selected set)
% end

%%
% load([pathRoot '/results/' 'C60Base.mat']);
if nargin < 3

end
par = inputParser;
addParameter(par,'names_inp',[])
addParameter(par,'num_select',size(X,2))
parse(par,varargin{:})

names_inp = par.Results.names_inp;
num_select = par.Results.num_select;

num_inp = size(X,2);
if isempty(names_inp)
    names_inp = cell(num_inp,1);
    for i2 = 1:num_inp
        names_inp{i2} = ['x' num2str(i2)];
    end
end

pcfs = struct();

dispstat('','init'); %one time only init
dispstat('Begining PCFS algorithm...','timespamp','keepthis');


idx = ~(any(isnan(X),2) | isnan(y));
X = X(idx,:);
y = y(idx);

%%

C = X;
S = [];
Sidx = [];
[N,D] = size(X);

rp = zeros(D,1);
r = zeros(D,1);

%% calculate peason's corrcoef for first selection
PCC = zeros(D,1);

for j = 1:D %find maximum correlation (Cj,y)
    Cj = C(:,j);
    temp = cov(Cj,y)/(std(Cj)*std(y));
    PCC(j) = temp(1,2); clear temp
end

PCC = PCC.^2;
Cs = C(:,PCC == max(PCC)); %selected candidate Cs (maximum MI)
C(:,PCC == max(PCC)) = []; %remove selected candidate from candidate set
temp = corrcoef(Cs,y);
r(1) = temp(2,1); %save correlation between selected candidate and output
rp(1) = max(PCC); %save MI value
rpd{1} = PCC; %save partial correlation distribution
S = [S Cs]; %place selected candidate in selected input set S
Sidx(1) = find(all(Cs == X)); %find corresponding input idx in X
clear vars PCC Cs

%% Calculate PMI for subsequent inputs until AIC decreases
AIC = zeros(D,1);
ui = zeros(N,D);
mYSi = zeros(N,D);

for i2 = 2:num_select%D %for second selection

    B = [ones(size(S,1),1) S]\y; %linear regression model coefficients
    mYS = [ones(size(S,1),1) S]*B; %linear fit, E[y|X=x]
    u = y - mYS; %residual
    mYSi(:,i2-1) = mYS; %save expectation,E[y|X=x]
    ui(:,i2-1) = u; %save residual for troubleshooting/analysis
    %     p = size(S,2); %this is not technically correct but papers are bad
    AIC(i2-1) = N * log((1/N) * sum(u.^2)) + 2 * length(B);


    %     termination criteria
    if false && i2 > 2 %check once at least 2 inputs have been selected
        if AIC(i2-1) > AIC(i2-2) %termination crit
            nS = i2-2; % -2 because it calculates AIC from previous run at the start of the loop
            S = S(:,1:nS); %remove most recently added input
            Sidx = Sidx(1:nS); %remove most recently added input from index

            r = r(1:(nS+1)); %keep an extran input (the last one that didn't get selected) for these variables
            AIC = AIC(1:(nS+1));
            mYSi = mYSi(:,1:(nS+1));
            ui = ui(:,1:(nS+1));
            break
        end
    end

    %% if there are inputs remaining, initialize
    if size(C,2) ~= 0 %if there are candidate inputs remaining
        dispstat(sprintf('%s added to selection, %d%% of candidate set remaining',char(names_inp(Sidx(end))),100-round(100*i2/D)),'timestamp')

        dC = size(C,2); %number of remaining candidates
        PCC = zeros(dC,1);
        v = zeros(N,1);

        %% calculate PMI for remaining inputs Cj in candidate set C
        for j = 1:dC %for each remaning candidate input
            Cj = C(:,j);
            B = [ones(size(S,1),1) S]\Cj; %linear regression model coefficients
            mSCj = [ones(size(S,1),1) S]*B; %linear fit, E[y|X=x]
            v = Cj - mSCj; %residual
            temp = cov(u,v)/(std(u)*std(v));
            PCC(j) = temp(1,2); clear temp
        end
        PCC = PCC.^2; %NOT CLEAR IN PAPERS, COMBAT S SHAPE AIC!!!!!!!!!!!!
        Cs = C(:,PCC == max(PCC)); %selected candidate (maximum PMI)
        %     vs = v(MI == max(MI)); %residuals of selected candidate (maximum PMI)
        C(:,PCC == max(PCC)) = []; %remove selected candidate from candidate set

        temp = corrcoef(Cs,y);
        r(i2) = temp(2,1); %save correlation between selected candidate and output
        rp(i2) = max(PCC); %save maximum partial correlation
        rpd{i2} = PCC; %save partial correlation distribution
        S = [S Cs]; %place selected candidate in selected input set
        Sidx = [Sidx find(all(Cs == X))]; %find corresponding input idx in X
        clear vars MI
    end

end

%% store everything in a struct, since structs are the best

pcfs.pc = rp;
pcfs.aic = AIC;
pcfs.rank = Sidx;
pcfs.names = names_inp;
pcfs.num_candidates = D;
pcfs.num_selected = length(Sidx);
pcfs.inp = X;
pcfs.obs = y;
pcfs.mY = mYSi;
pcfs.residuals = ui;
pcfs.rp = rp;
pcfs.r = r;
pcfs.rpd = rpd;
mask = zeros(size(X,2),1); mask(Sidx) = 1; mask = logical(mask); %create logical mask from index
pcfs.mask = mask;
dispstat('Finished.','keepprev'); fprintf('\n')
end
