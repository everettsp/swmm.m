function sym_spec = swmm_dict_symbols(swmm_class)

gp = get_gp('word','lassonde');
gp.ms = 1;


switch lower(swmm_class)
    case 'subcatchments'
        sym_spec = makesymbolspec('Polygon',...
            {'Default','FaceColor',[0.9 0.9 0.9]});
        
    case 'junctions'
        sym_spec = makesymbolspec('Point',...
            {'Default','MarkerEdgeColor',gp.c.purple,'MarkerFaceColor',gp.c.purple,'Marker','o','MarkerSize',gp.ms});
        
    case 'outfalls'
        sym_spec = makesymbolspec('Point',...
            {'Default','MarkerEdgeColor',gp.c.blue,'MarkerFaceColor',gp.c.blue,'Marker','^','MarkerSize',gp.ms*4});
        
    case 'storage'
        sym_spec = makesymbolspec('Point',...
            {'Default','MarkerEdgeColor',gp.c.purple,'MarkerFaceColor',gp.c.purple,'Marker','sq','MarkerSize',gp.ms*4});
        
    case 'conduits'
        sym_spec = makesymbolspec('Line',...
            {'Default','Color',gp.c.blue,'LineWidth',gp.lw});
        
    case 'outlets'
        sym_spec = makesymbolspec('Line',...
            {'Default','Color',gp.c.blue,'LineWidth',gp.lw});
        
    otherwise
        error('SWMM class not recognized...')
end