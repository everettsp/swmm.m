function events2 = prerun(mdl,events, varargin)


par = inputParser;
addParameter(par,'overwrite',false)
parse(par,varargin{:})
overwrite = par.Results.overwrite;



num_events = numel(events);
events2 = events;
% mdl.p.storage.InitDepth(:) = 0;
files_original = mdl.p.files;
assert(~isempty(mdl.dir_data),'must specify data folder for model');

for i2 = 1:num_events
    
    % write the dates to SWMM .INP
    
    mdl.p.options.START_DATE = events2(i2).start_date;
    mdl.p.options.REPORT_START_DATE = events2(i2).start_date;
    mdl.p.options.END_DATE = events2(i2).end_date;
    
    prerun_duration = days(1);
    event_start = mdl.p.options.START_DATE;
    event_start.Format = 'uuuu-MM-dd-HHmm';
    
    event_end = mdl.p.options.END_DATE;
    event_end.Format = 'uuuu-MM-dd-HHmm';
    
    prerun_duration_str = replace(char(days(1)),' ','');
    ffile_hs = [mdl.dir_data,'hotstart_',char(event_start),'_',char(prerun_duration_str),'.hsf'];
    events2(i2).ffile_hs = ffile_hs;
    if ~isfile(ffile_hs) || overwrite
    mdl.save_hsf(ffile_hs,prerun_duration);
    
    else
        disp(['WARNING: hotstart file ',ffile_hs,' already exists, skipping...'])
    end
    
    mdl2 = mdl.use_hsf(ffile_hs);
    % create a copy of the model to fuck with the RFF settings
    % calc. HSF using the original model, which should have default
    % rainfall config.
    % alternative would be to store default RFF file location path, but
    % this is annoying to do
    
    
    ffile_rff = [mdl.dir_data,'rainfall_',char(event_start),'_',char(event_end),'.rff'];
    ffile_rfdat = [mdl2.dir_data,'rainfall_',char(event_start),'_',char(event_end),'.dat'];
    
    if ~isfile(ffile_rfdat) || overwrite
        swmm_tt2dat(events(i2).tt_rg,ffile_rfdat); % create dat file
    else
        disp(['WARNING: rainfall dat file ',ffile_rfdat,' already exists, skipping...'])
    end
    
    ffile_rfdat = strrep(ffile_rfdat,'\\','\'); % clean file path
    mdl2.p.raingages.SourceName = repmat({['"',ffile_rfdat,'"']},height(mdl.p.raingages),1); % change filepath to new dat file
    mdl2.p.files = mdl2.p.files(~strcmp(mdl2.p.files.Type,'RAINFALL'),:); % remove any existing rainfall files
    
    if ~isfile(ffile_rff) || overwrite
        mdl2 = mdl2.save_rff(ffile_rff); % create binary rainfall file
    else
        disp(['WARNING: rainfall dat file ',ffile_rff,' already exists, skipping...'])
    end
    
    events2(i2).ffile_rf = ffile_rff;

end

mdl.p.files = files_original;