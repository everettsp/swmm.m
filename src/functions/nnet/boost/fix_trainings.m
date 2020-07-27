function nnd = fix_trainings(nnd)

num_configs = numel(nnd);
for ii = 1:num_configs
    num_iterations = numel(nnd(ii).trainings);
    for iii = 1:num_iterations
        nnd(ii).trainings{iii} = nnd(ii).trainings{iii}{1};
    end
end
end