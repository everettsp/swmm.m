function [iTrain,iVal,iTest] = partition_kfcv1(data_fracs,x,t,i2)%,ynPlot)
%% this code isn't pretty, but it's good enough, max 2 timestep roundoff error

if nargin < 4; i2 = 1; end

%% get the number of t/v/t timesteps - dump roundoff to test split
idx = ~(any(isnan(x),2) | isnan(t));
n = sum(idx);

ind_data = 1:n;

n_train = ceil(n * data_fracs(1));
n_val = ceil(n * data_fracs(2));
n_test = n - n_train - n_val;

n_cal = n_train + n_val; % training and validation
%% construct indices
iTest = (ind_data(end) - n_test) : ind_data(end); %test split at the end

foldsDecimal = n_cal/n_val; %number of folds in calibration set (decimal)
foldsUpper = ceil(foldsDecimal); %round up
foldsLower = floor(foldsDecimal); %round down
foldsOverflow = mod(foldsUpper,foldsDecimal); %excess folds
foldsOverlap = foldsOverflow / foldsLower; %amount of overlap between folds

foldStart = mod(i2-1,foldsUpper); %starting point of validation fold based on iteration number
iVal = floor((foldStart * n_val) * (1 - foldsOverlap)) + (1:n_val); %validation split
iTrain = ind_data(~(ismember(ind_data,iVal) | ismember(ind_data,iTest))); %training split as remainder

while any(ismember(iVal,iTest)) %if overlap between validation and test split, shift validation left
    iVal = iVal-1;
    iTrain = iTrain(~ismember(iTrain,iVal)); %delete subsequent overlap of training split
end

%%
indexWnan = 1:length(t);
indexWOnan = nan(sum(idx),5);

indexWOnan(:,1) = 1:sum(idx);

indexWOnan(:,2) = indexWnan(idx);
indexWOnan(iTrain,3) = 1;
indexWOnan(iVal,4)= 1;
indexWOnan(iTest,5) = 1;

iTrain = indexWOnan(indexWOnan(:,3) == 1,2);
iVal = indexWOnan(indexWOnan(:,4) == 1,2);
iTest = indexWOnan(indexWOnan(:,5) == 1,2);

%
if (i <= foldsUpper) && ynplot
    figure(242)
    subplot(foldsUpper,1,i2)
        hold on
        plot(t,'LineWidth',2,'color','black','DisplayName','Target')
        
        yl = ylim;
        area([iTrain(1) iTrain(end)],[max(t) max(t)],'FaceColor',[1,0,0],'DisplayName','Training')
        area([iVal(1) iVal(end)],[max(t) max(t)],'FaceColor',[0,1,0],'DisplayName','Validation')
        area([iTest(1) iTest(end)],[max(t) max(t)],'FaceColor',[0,0,1],'DisplayName','Test')
        plot(t,'LineWidth',2,'color','black','HandleVisibility','Off')

        ylim(yl)
        xlim([0 length(t)])
    %     plot(y,'-.','LineWidth',2,'color','blue','DisplayName','Modelled')
    if i == foldsUpper
        title(['K-fold cross-validation (K=' num2str(foldsUpper) ')'])
        legend('Location','best')
    end
end


end