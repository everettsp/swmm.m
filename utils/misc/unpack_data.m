function [X,T,R,Ys,nets,trs] = unpack_data(nnd,varargin)
%retrieve timetable or array for a given model configuration z
p = inputParser;
default_type = 'timetable';
addParameter(p,'type',default_type)
addParameter(p,'summarize','false')
parse(p,varargin{:})
type = p.Results.type;
summarize = p.Results.summarize;

% global rootDir
% load([rootDir '/results/' filename]);
nets = nnd.nets;
trs = nnd.trainings;
ttT = nnd.targets;
ttX = nnd.inputs;
ttR = nnd.stations;
%ttY = annData.modelled;
num_iterations = numel(nets);
num_samples = length(table2array(ttT));


%Ys = zeros(N,I);
ttY = timetable(ttT.Time);

for ii = 1:num_iterations
    net = nets{ii};
    tr = trs{ii};
    %% START BOOST UNPACKING
    if iscell(net)
        
        boost_num = numel(net);
        net0 = net{1};
        Yb(:,1) = net0(table2array(ttX)');
        rho = 1;
        learning_rate = 1;
        
        for iii = 2:boost_num
            net0 = net{iii};
            tr0 = tr{iii};
            
            rho(iii) = tr0.lsb_rho;
            learning_rate(iii) = tr0.lsb_learn_rate;
            Yb(:,iii) = net0(table2array(ttX)');
        end
        Y = Yb * (learning_rate .* rho)';
        
    else
        %% END BOOST UNPACKING
        
        Y = net(table2array(ttX)')';
    end
    
    ttY = addvars(ttY,Y,'newVariableNames',{['i' num2str(ii)]});
    
    
    %Ys(:,i) = Y';
end

switch lower(summarize)
    case {'median','med'}
        ttY_summary = timetable(ttY.Time);
        ttY_summary = addvars(ttY_summary,median(ttY.Variables,2),'newVariableNames',{'median'});
        clear ttY
        ttY = ttY_summary;
        disp('calculating median prediction...')
    case {'mean','average'}
        ttY_summary = timetable(ttY.Time);
        ttY_summary = addvars(ttY_summary,mean(ttY.Variables,2),'newVariableNames',{'mean'});
        clear ttY
        ttY = ttY_summary;
        disp('calculating mean prediction...')
    otherwise
        
end

clear vars net Y i

switch lower(type)
    case {'array','mat','num','double'}
        Ys = table2array(ttY);
        R  = table2array(ttR);
        T  = table2array(ttT);
        X  = table2array(ttX);
    case {'timetable','tt'}
        Ys = ttY;
        R = ttR;
        T = ttT;
        X = ttX;
end

end