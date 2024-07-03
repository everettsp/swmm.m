function pmifs =calc_pmi(X,namesX,y,sf)
%% algorithm description
% Based on (He et al. 2011) and (May et al. 2008)
% 
% specify scaling factor (sf)
% initialize candidate set C = X
% select first input based on maximum mutual information between input and output
% while candidate input set (C) remain or termination criteria is met
%     regress selected input/s (S) on output (Y)
%     calculate AIC to check termination criteria
%     regress selected input/s on each remaining candidate input (Cj)
%     calculate PMI for each Cj
%     select next input based on maximum PMI (remove Cj from candidate set, add to selected set)
% end

%%

warning('off','all')

pmifs = struct();

dispstat('','init'); %one time only init 
dispstat('Begining PMIFS algorithm...','timespamp','keepthis'); 
i = 1;
C = X;
S = [];
[n,D] = size(X);
Sidx = [];
pmi = zeros(D,1);
fu = []; fv = []; fuv = [];
if nargin < 2
    sf = 1; %scaling factor
end
%% calculate MI for first selection
MI = zeros(D,1);

Ky = get_kernel(y,sf); %estimate pdf
fy = (1/n) * sum(Ky,2);

for j = 1:D %find maximum MI(Cj,y)
    Cj = C(:,j);
    KCj = get_kernel(Cj,sf); %estimate pdf
    fCj = (1/n) * sum(KCj,2);
    
    KCjy = get_kernel([Cj y],sf); %estimate pdf
    fCjy = (1/n) * sum(KCjy,2);
    
    MI(j) = (1/n) * sum(log(fCjy ./ (fCj .* fy)));
end

selection = MI == max(MI);
Cs = C(:,selection); %selected candidate Cs (maximum MI)

figure(100+i)
scatterhist(y,Cs,'kernel','on');
xlabel('obs(y)'); ylabel('selected candidate (Cj)');

C(:,selection) = []; %remove selected candidate from candidate set
pmi(1) = max(MI); %save MI value
S = [S Cs]; %place selected candidate in selected input set S
pmid{1} = MI; %save partial mutual information distribution
Sidx(1) = find(all(Cs == X)); %index of selected input(s)
clear vars MI Cs fCj fCjy fy

%% Calculate PMI for subsequent inputs until AIC decreases
AIC = zeros(D,1);
ui = zeros(n,D);
mYSi = zeros(n,D);

% dispstat(sprintf('Processing %d%%',round(100*i/D)),'timestamp'); 
for i = 2:D %for second selection
    dispstat(sprintf('%s added to selection, %d%% of candidate set remaining',char(namesX(Sidx(length(Sidx)))),100-round(100*i/D)),'timestamp');
    ii = i-1; %store things like mYS with previous step (instead of having first iteration all = 0)
    kS = get_kernel(S,sf);%expected output based on selected input(s),E[y|X=x]
    mYS = sum((y' .* kS),2) ./ sum(kS,2);
    H{ii} = kS ./ sum(kS,2);
    u = y - mYS; %residual
    mYSi(:,ii) = mYS; %save expectation,E[y|X=x]
    
    figure(200+i)
    subplot(1,2,1)
    plot(y,'Displayname','obs (Y)'); hold on;
    plot(mYS,'Displayname','estimate (E[Y|S])')
    plot(u,'Displayname','residuals (u)'); legend();
    
    ui(:,ii) = u; %save residual for troubleshooting/analysis
    kH{ii} = kS;
%     p = size(S,2); %this is not technically correct but papers are bad
%     p = i;
    dof  = trace(H{ii});
    AIC(ii) = n * log((1/n) * sum(u.^2)) + 2 * dof;
    
    if i > 13 %3 %turn off stoping criteria && false %check once at least 2 inputs have been selected
        if AIC(ii) > AIC(ii-1) %termination crit
            nS = ii-1; % -2 because it calculates AIC from previous run at the start of the loop
            S = S(:,1:nS); %remove most recently added input
            Sidx = Sidx(1:nS); %remove most recently added input from index
            
            pmi = pmi(1:(nS+1)); %keep an extran input (the last one that didn't get selected) for these variables
            AIC = AIC(1:(nS+1));
            mYSi = mYSi(:,1:(nS+1));
            ui = ui(:,1:(nS+1));
            break
        end
    end
    

            
    %% if there are inputs remaining, initialize
    if size(C,2) ~= 0 %if there are candidate inputs remaining
        
        
        ku = get_kernel(u,sf); %estimate pdf
        fu = (1/n) * sum(ku,2);
        
        
        dC = size(C,2); %number of remaining candidates
        MI = zeros(dC,1);
        vj = zeros(n,dC);
        
        %% calculate PMI for remaining inputs Cj in candidate set C
%         Ks = get_kernel(S,sf);

        for j = 1:dC %for each remaning candidate input
            Cj = C(:,j);

            mCS = sum((Cj' .* kS),2) ./ sum(kS,2); %expection Cj based on selected input(s),E[Cj|X=x]
            v = Cj - mCS; %calculate residuals
            
            Kv = get_kernel(v,sf); %estimate pdf
            fv = (1/n) * sum(Kv,2);
            Kvu = get_kernel([v u],sf); %estimate joint pdf
            fvu = (1/n) * sum(Kvu,2);

            MI(j) = (1/n) * sum(log(fvu ./ (fv .* fu))); %estimate partial mutual information
            
            mCjS(:,j) = mCS; %store mCjS
            vj(:,j) = v; %store v
        end
        selection = MI == max(MI);
        
    figure(200+i)
    subplot(1,2,2)
    plot(C(:,selection),'Displayname','selected candidate (Cs)'); hold on;
    plot(mCjS(:,selection),'Displayname','estimate (E[Cj|S])')
    plot(vj(:,selection),'Displayname','residuals (vs)'); legend();
    text(min(xlim),max(ylim),'recall: bad fit here is better, since if S can explain Cj it is not a useful input')
    
    figure(300+i)
    subplot(1,3,3)
    scatterhist(u,vj(:,selection),'kernel','on');
    xlabel('u'); ylabel('vs');
    
    Cs = C(:,selection); %selected candidate (maximum PMI)
%     vs = v(MI == max(MI)); %residuals of selected candidate (maximum PMI)
    C(:,selection) = []; %remove selected candidate from candidate set
    pmi(i) = max(MI); %save maximum pmi
    pmid{i} = MI; %save partial mutual information distribution
    S = [S Cs]; %augment selection with Cs
    Sidx = [Sidx find(all(Cs == X))]; %find corresponding input idx in X
    clear vars MI
    end
    
end

%% store everything in a struct, since structs are the best

pmifs.pmi = pmi;
pmifs.aic = AIC;
pmifs.sortd = Sidx;
pmifs.names = namesX;
pmifs.numC = D;
pmifs.numS = length(Sidx);
pmifs.X = X;
pmifs.y = y;
pmifs.mY = mYSi;
pmifs.dof = dof;
pmifs.kH = kH;
pmifs.hat = H;
pmifs.pmid = pmid;
pmifs.residuals = ui;
mask = zeros(D,1); mask(Sidx) = 1; mask = logical(mask); %create logical mask from index
pmifs.mask = mask;

% clearvars -except pmifs a A pathRoot annData annConfig
dispstat(sprintf('Finished. %d inputs selected: %s',pmifs.numS,strjoin(pmifs.names(pmifs.sortd),', ')),'keepprev'); fprintf('\n')

%%


end
