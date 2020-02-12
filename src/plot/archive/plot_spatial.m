
path_gis = [path_model 'shapefiles\'];
swmm_names = {'subcatchments','junctions', 'outfalls', 'storage', 'conduits', 'outlets'};
path_save = [path_project 'doc\presentation\'];

for i7 = 9%1%:numel(cp)
    
    
    fh = figure;
    fh.Name = [name_model '_' lower(param_attribute)];
    axesm utm
    utm_zone = 17;
    
    
    
    param_class = cp(i7).class;
    param_attribute = cp(i7).attribute;
    param_uncertainty = cp(i7).uncertainty;
    
    
    
    % get swmm classes (before and after calibration)
    sc = swmm_class(ffile_model, param_class);
    sc_parent = swmm_class([ffile_parent], param_class);
    
    symbology_names = sc.Properties.RowNames;
    
    % sym fun converts data (parameter values) to an index within the range
    % of the col_grad variable
    
    
    %         sym_fun = @(symbology_data) round(1 + 999 * normalize(symbology_data,'range'));
    sym_fun = @(symbology_data) round(1000 * symbology_data);
    
    col_linspace = (-param_uncertainty:0.001:param_uncertainty);
    col_grad1 = get_colgrad(gp.c.red,gp.c.yellow,'grad_num',(numel(col_linspace)-1)/2);
    col_grad2 = get_colgrad(gp.c.yellow,gp.c.green,'grad_num',(numel(col_linspace)-1)/2);
    col_grad = [col_grad1; gp.c.yellow; col_grad2];
    
    num_gens = numel(gbl_pop);
    % data = NaN(num_gens,height(sc));
    data_change = NaN(height(sc),num_gens);
%     
%     for i2 = 1:num_gens
%         for i3 = 1:height(sc)
%             ldx = strcmp({gbl_opt.class},'SUBCATCHMENTS') ...
%                 & strcmp({gbl_opt.attribute},'PercentImperv') ...
%                 & strcmp({gbl_opt.id}, sc.Properties.RowNames(i3));
%             data_change(i3,i2) = mean(gbl_pop{i2}(:,ldx));
%         end
%     end
%     
%     for i2 = 2:num_gens
%         data_change(:,i2) = (data_change(:,1) - data_change(:,i2)) ./ data_change(:,1);
%     end
%     data_change(:,1) = zeros(size(data_change,1),1);
%     
    %     for i2 = 1:num_gens
    %         data_change(:,i2) = - (sc_parent(:,param_attribute).Variables - sc(:,param_attribute).Variables) ./ sc_parent(:,param_attribute).Variables;
    %     end
    
%     get the index of the triplet in the global optimization swmm
%     object (we want to use this instead of values directly from SWMM
%     in case we want to get values across GA generations)
for i2 = 1:num_gens
        for i3 = 1:height(sc)
            ldx = strcmp({gbl_opt.class},param_class) ...
                & strcmp({gbl_opt.attribute},param_attribute) ...
                & strcmp({gbl_opt.id}, symbology_names{i3});
            % calculate the relative difference
            data_change(i3,i2) = (gbl_opt(ldx).init_val - mean(gbl_pop{i2}(:,ldx))) ./ gbl_opt(ldx).init_val;
        end
end
    sym_norm = sym_fun(data_change);
    sym_norm = sym_norm + ((size(col_grad,1) - 1) / 2 + 1);
    %     for i2 = 1:num_gens
    
    for i2 = 1:num_gens
        
        
        
        for i6 = 1:numel(swmm_names)
            s = shaperead([path_gis,swmm_names{i6},'.shp']);
            sym_spec = swmm_dict_symbols(swmm_names{i6});
            
            if strcmpi(swmm_names{i6},swmm_mainclass(param_class))
                for i3 = 1:numel(s)
                    idx = strcmp(symbology_names,s(i3).id);
                    col_idx = sym_norm(idx,i2);
                    
                    sym_fields = fields(sym_spec);
                    sym_idx = contains(sym_fields,'Color');
                    for i8 = find(sym_idx')
                        sym_spec.(sym_fields{i8}){3} = col_grad(col_idx, :);
                    end
                    
                    if strcmp(param_attribute,'CONDUITS') || i6 == 5
                        sym_spec.LineWidth{3} = 6;
                    end
                    mapshow(s(i3),'SymbolSpec',sym_spec);
                    hold on
                end
            else
                mapshow(s,'SymbolSpec',sym_spec);
            end
        end
        
        
        
        
        %         fh = figure('Name','dummy_legend');
        hold on
        xlim_temp = xlim;
        ylim_temp = ylim;
        leg_linspace = linspace(-1000*param_uncertainty,1000*param_uncertainty,5);
        leg_idx = ((size(col_grad,1) - 1) / 2 + 1) + leg_linspace;
        for i21 = flipud(1:numel(leg_idx))
            leg_col = col_grad(leg_idx(i21),:);
            leg_name = [num2str(leg_linspace(i21)/10) '%'];
            area([0],[0],'FaceColor',leg_col,'DisplayName',leg_name)
        end
        ylim(ylim_temp)
        xlim(xlim_temp)
        box on
        text(xlim_temp(1) + 0.8 * (xlim_temp(2) - xlim_temp(1)), ylim_temp(1) + 0.9 * (ylim_temp(2) - ylim_temp(1)),['generation ' num2str(i2)])

        autoformat([1 1],'compact','style','pptw_body')
        legend('location','southwest')
        %         autoformat([1 0.3],'compact','style','word')
        %     save_fig(path_save)
        save_gif('temp2',(i2-1)/(num_gens-1))
%             kill
        clf
    end
end

% apply_style([1 0.3],'compact','style','word')

%%

