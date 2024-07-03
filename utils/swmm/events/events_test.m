function events_test(events)
% make sure event struct has all necessary fields
event_fields = fields(events);
check_fields = {'class','ffile_hs','ffile_rf'};
for i2 = 1:numel(check_fields)
    assert(any(contains(event_fields, check_fields{i2})),["event field '",check_fields{i2},"' not found in event data, cannot run swmm simulation..."])
end
end

