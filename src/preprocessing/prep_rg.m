function [tt_buff, mask] = prep_rg(tt,varargin)

par = inputParser;
addParameter(par,'antecedent_days',0,@isnumeric)
addParameter(par,'subsequent_days',0,@isnumeric)

parse(par,varargin{:})

antecedent_days = par.Results.antecedent_days;
subsequent_days = par.Results.subsequent_days;

timestep = tt.Properties.RowTimes(2) - tt.Properties.RowTimes(1);

buff = [antecedent_days subsequent_days];
tt_zeros = cell(2,1);

for i2 = 1:2
    if i2 == 1
    rt = (tt.Properties.RowTimes(1) - days(buff(i2))) : timestep : ...
        tt.Properties.RowTimes(1) - timestep;
    elseif i2 == 2
    rt = (tt.Properties.RowTimes(end) + timestep) : timestep : ...
        tt.Properties.RowTimes(end) + days(buff(i2));
    else
        error('code better')
    end
    data = zeros(numel(rt), 1);
    
    tt_zeros{i2} = timetable(rt');
    for i3 = 1:size(tt,2)
        tt_zeros{i2} = addvars(tt_zeros{i2},data,'NewVariableNames',tt.Properties.VariableNames{i3});
    end
end
% mask indicates which timesteps to crop - used if you want to run the
% simulation before or after the event but not include that in the analysis
mask = [true(height(tt_zeros{1}),1); false(height(tt),1); false(height(tt_zeros{2}),1)];

tt_buff = [tt_zeros{1}; tt; tt_zeros{2}];
tt_buff = retime(tt_buff,'regular','TimeStep',tt.Properties.TimeStep);
end