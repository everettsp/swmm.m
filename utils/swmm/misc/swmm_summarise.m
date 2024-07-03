function t = swmm_summarise(mdl)

t = struct();
t.name = mdl.name;
t.outlet = mdl.p.outfalls.Name{1};
t.num_subcatchments = height(mdl.p.subcatchments);
t.total_area = sum(mdl.p.subcatchments.Area);
t.mean_area = mean(mdl.p.subcatchments.Area);
t.mean_imperv = sum((mdl.p.subcatchments.Area .* mdl.p.subcatchments.PercentImperv)) ./ sum(mdl.p.subcatchments.Area);
t.conduit_length = sum(mdl.p.conduits.Length);
end