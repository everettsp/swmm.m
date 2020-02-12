% plot the runoff coefficient

path_gis = [path_model 'shapefiles\'];
swmm_names = {'subcatchments','junctions', 'outfalls', 'storage', 'conduits', 'outlets'};
path_save = [path_project 'doc\report\'];
param_attribute = 'Runoff_Coeff';


fh = figure;
fh.Name = [name_model '_' lower(param_attribute)];
axesm utm
utm_zone = 17;
gp = get_gp('word','lassonde');
% get swmm classes (before and after calibration)

%     sc = swmm_read_class(ffile_model, 'subcatchments');
%     sc_parent = swmm_read_class(ffile_parent, 'subcatchments');

ffile_pre = 'C:\Users\everett\Google Drive\02_phd\00_projects_major\02_swmm_calibration\results\cal_event3_good\pre_calibration';
ffile_post = 'C:\Users\everett\Google Drive\02_phd\00_projects_major\02_swmm_calibration\results\cal_event3_good\fourteenmile';

sc = swmm_summary(ffile_pre, 'subcatchment');
sc_parent = swmm_summary(ffile_post, 'subcatchment');
sc_parent = sc_parent(contains(sc_parent.Subcatchment,sc.Subcatchment),:);


symbology_names = sc.Subcatchment;




% sym fun converts data (parameter values) to an index within the range
% of the col_grad variable
%     sym_fun = @(symbology_data) round(1 + 999 * normalize(symbology_data,'range'));

sym_fun = @(symbology_data) round(1000*symbology_data);


data_change = - (sc_parent(:,param_attribute).Variables - sc(:,param_attribute).Variables) ./ sc_parent(:,param_attribute).Variables;


lower_val = -10;
upper_val = 10;

data_change(data_change > upper_val) = upper_val;
data_change(data_change < lower_val) = lower_val;

col_linspace = (lower_val:0.001:upper_val);
col_grad1 = get_colgrad(gp.c.green,gp.c.yellow,'grad_num',(numel(col_linspace)-1)/2);
col_grad2 = get_colgrad(gp.c.yellow,gp.c.red,'grad_num',(numel(col_linspace)-1)/2);
col_grad = [col_grad1; gp.c.yellow; col_grad2];

%     num_gens = numel(gbl_pop);
% data = NaN(num_gens,height(sc));
%     data = NaN(1,height(sc));

% for i2 = 1%:num_gens
%     for i3 = 1:height(sc)
%         ldx = strcmp({gbl_opt.type},'SUBCATCHMENTS') ...
%             & strcmp({gbl_opt.field},'PercentImperv') ...
%             & strcmp({gbl_opt.name}, sc.Name(i3));
%         data(i2,i3) = mean(gbl_pop{i2}(:,ldx));
%     end
% end

%     i2 = 1;
%
% get the index of the triplet in the global optimization swmm
% object (we want to use this instead of values directly from SWMM
% in case we want to get values across GA generations)
%     for i3 = 1:height(sc)
%         ldx = strcmp({gbl_opt.type},param_class) ...
%             & strcmp({gbl_opt.field},param_attribute) ...
%             & strcmp({gbl_opt.id}, symbology_names{i3});
%         % calculate the relative difference
%         data(i2,i3) = (mean(gbl_pop{1}(:,ldx)) - mean(gbl_pop{end}(:,ldx))) ./ mean(gbl_pop{1}(:,ldx));
%     end
%
sym_norm = sym_fun(data_change');

for i5 = 1%:num_gens
    for i6 = 1:numel(swmm_names)
        ffilename = [path_gis swmm_names{i6} '.shp'];
        if ~exist(ffilename)
            continue
        end
        s = shaperead(ffilename);
        sym_spec = swmm_dict_symbols(swmm_names{i6});
        
        if strcmpi(swmm_names{i6},'subcatchments')
            % if it's the important one, plot 1 by 1
            for i3 = 1:numel(s)
                idx = strcmp(symbology_names,s(i3).Name);
                col_idx = ((size(col_grad,1) - 1) / 2 + 1) + sym_norm(i5,idx);
                
                sym_fields = fields(sym_spec);
                sym_idx = contains(sym_fields,'Color');
                for i8 = find(sym_idx')
                    sym_spec.(sym_fields{i8}){3} = col_grad(col_idx, :);
                end
                mapshow(s(i3),'SymbolSpec',sym_spec);
                hold on
            end
        else
            mapshow(s,'SymbolSpec',sym_spec);
        end
    end
    
    
end

%         fh = figure('Name','dummy_legend');
hold on
xlim_temp = xlim;
ylim_temp = ylim;

%
%     leg_linspace = linspace(min(col_linspace),max(col_linspace),5);
%     leg_idx = ((size(col_grad,1) - 1) / 2 + 1) + leg_linspace;
leg_prctiles = [0 25 50 75 100];
leg_idx = round(prctile(find(col_linspace),leg_prctiles));
for i21 = flipud(1:numel(leg_idx))
    leg_col = col_grad(leg_idx(i21),:);
    leg_name = [num2str(round(col_linspace(leg_idx(i21)),1)     ) '%'];
    area([0],[0],'FaceColor',leg_col,'DisplayName',leg_name)
end

ylim(ylim_temp)
xlim(xlim_temp)
box on
autoformat([1 0.7],'compact','style','pptw_fs')
legend('location','southwest')
%         autoformat([1 0.3],'compact','style','word')
save_fig(path_save)
%     animate_forloop('temp',i5,num_gens)


% apply_style([1 0.3],'compact','style','word')

%%

