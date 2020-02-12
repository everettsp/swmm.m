function gp = gfx_properties(gfx_style,gfx_theme)
% produce a struct 'gp' containing graphical properties, based on a
% destination style (i.e., ms-word) and a colour scheme
% 
%
% lw corresponds to LineWidth
% ms corresponds to MarkerSize
% suffix 0 and 2 indicate smaller and bigger sizes, respectively
% colours are RGB triplets and have a 3 letter ID
% duplicate colour IDs (i.e., two shades or red) are given a numeric suffix

gp = struct();
gp.style = gfx_style;
gp.theme = gfx_theme;

switch lower(gfx_style)
    case {'ppt','powerpoint','pptfull','fullslide','fullscreen','pptwide','ppt_wide','ppt16:9','ppt169','wide','pres_wide'}
        gp.lw = 2;
        gp.lw0 = 1;
        gp.lw2 = 4;
        gp.ms = 6;
        gp.ms0 = 4;
        gp.ms2 = 10;
        
    case {'publisher','poster','pub'}
        gp.lw = 2;
        gp.lw0 = 1;
        gp.lw2 = 4;
        gp.ms = 6;
        gp.ms0 = 4;
        gp.ms2 = 10;
        
    case {'word','doc','docx'}
        gp.lw = 2;
        gp.lw0 = 1;
        gp.lw2 = 4;
        gp.ms = 6;
        gp.ms0 = 4;
        gp.ms2 = 10;
end

gp.c = gfx_colors(gfx_theme);
        
end