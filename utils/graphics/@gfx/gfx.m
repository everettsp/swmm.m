classdef gfx
    % class containing graphical parameters and functions for plotting in
    % MATLAB
    %
    % properties cover linewidths, markers, colors, destination style and page size,
    % font
    
    properties
        fh
        ahs
        style {} = 'tex';
        theme {} = 'lassonde';
        pgw
        pgh
        pgw_hc
        pgw_dc
        pgw_sc
        
        width
        height
        
        posmat {mustBeNumeric};
        
        x2ax;
        y2ax;
        
        nahs {mustBeNumeric};
        ncols {mustBeNumeric};
        nrows {mustBeNumeric};
        
        font {} = 'SansSerif';
        fontsize = 11;
        alphbt = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        lw  {mustBeNumeric};      % linewidth
        lw0 {mustBeNumeric};     % "
        lw1 {mustBeNumeric};     % "
        lw2 {mustBeNumeric};     % "
        ms  {mustBeNumeric};      % marker size
        ms0 {mustBeNumeric};     % "
        ms1 {mustBeNumeric};     % "
        ms2 {mustBeNumeric};     % "
        c       % colours
        cs      % colours (cell)
        lns     % lines (cell)
        mks     % markers (cell)
    end
    
    methods
        function obj = gfx2(varargin)
            
            par = inputParser;
            addParameter(par,'fh',gcf);
            addParameter(par,'style',obj.style);
            addParameter(par,'theme',obj.theme);
            
            parse(par,varargin{:})

            obj.fh = par.Results.fh;
            set(0,'CurrentFigure', obj.fh); % if figure handle is input, set it as current figure
            obj.ahs = findall(obj.fh,'type','axes');
            obj.style = par.Results.style;
            obj.theme = par.Results.theme;
            
            switch lower(obj.style)
                case {'ppt','powerpoint'}
                    obj.lw0 = 1;
                    obj.lw1 = 2;
                    obj.lw2 = 4;
                    obj.lw = obj.lw1;
                    
                    obj.ms0 = 4;
                    obj.ms1 = 6;
                    obj.ms2 = 10;
                    obj.ms = obj.ms1;
                    
                    obj.pgw = 33.867; %21.91;%<-full screen%29.21; %figure width (16:9)
                    obj.pgh = 19.05; %12.09;%<-full sreen %12.09; %figure height (16:9)
                    obj.width = struct();
                    obj.width.page = 33.867;
                    
                    obj.height = struct();
                    obj.height.page = 19.05;
                    
%                     assert(any(ismember(lower(obj.orientation),{'default','wide'})),strcat("orientation kwd '",obj.orientation,"' not recognized for style '",obj.style,"'"));
%                     switch lower(obj.orienation)
%                         case 'wide'
%                             obj.pgw = 29.21; %figure width (16:9)
%                     end
                    
                    obj.fontsize = 14; %figure text size
                    obj.font = 'SansSerif'; %figure font
                    
                case {'publisher','poster','pub'}
                    obj.lw0 = 1;
                    obj.lw1 = 2;
                    obj.lw2 = 4;
                    obj.lw = obj.lw1;
                    
                    obj.ms0 = 4;
                    obj.ms1 = 6;
                    obj.ms2 = 10;
                    obj.ms = obj.ms1;
                    
                    obj.pgw = 47.64 - 0.64;
                    obj.pgh = 47.64 - 0.64;
%                     assert(any(ismember(lower(obj.orientation),{'default','landscape'})),strcat("orientation kwd '",obj.orientation,"' not recognized for style '",obj.style,"'"));
%                     switch lower(obj.orienation)
%                         case 'portrait'
%                             temp = obj.pgw;
%                             obj.pgw = obj.pgh;
%                             obj.pgh = temp;
%                             clear temp;
%                     end
                    
                    obj.fontsize = 18;
                    obj.font = 'Source Sans Pro';
                    
                case {'word','doc','docx'}
                    obj.lw0 = 0.5;
                    obj.lw1 = 1.5;
                    obj.lw2 = 3;
                    obj.lw = obj.lw1;
                    
                    obj.ms0 = 4;
                    obj.ms1 = 6;
                    obj.ms2 = 10;
                    obj.ms = obj.ms1;
                    
                    obj.pgw = 21.59 - 2*2.54;
                    obj.pgh = 27.94 - 2*2.54;
                    
%                     assert(any(ismember(lower(obj.orientation),{'default','landscape'})),strcat("orientation kwd '",obj.orientation,"' not recognized for style '",obj.style,"'"));
%                     switch lower(obj.orientation)
%                         case 'landscape'
%                             temp = obj.pgw;
%                             obj.pgw = obj.pgh;
%                             obj.pgh = temp;
%                             clear temp;
%                     end
                    
                    obj.fontsize = 8; %text header
                    obj.font = 'Source Sans Pro';
                    
                    
                case {'tex','latex','mdpi','elsevier','hess'}
                    obj.lw0 = 0.5;
                    obj.lw1 = 1.5;
                    obj.lw2 = 3;
                    obj.lw = obj.lw1;
                    
                    obj.ms0 = 4;
                    obj.ms1 = 6;
                    obj.ms2 = 10;
                    obj.ms = obj.ms1;
                    
                    obj.pgw = 19;
                    obj.pgh = 22;
                    
                    obj.pgw_sc = 9;  % single col
                    obj.pgw_dc = 19; % double col
                    obj.pgw_hc = 14; % half col
                    obj.width.sc = 9;
                    obj.width.dc = 19;
                    obj.width.hc = 14;
                    obj.height.page = 22;
                    obj.width.page = 19;
                    
                    
                    
%                     assert(any(ismember(lower(obj.orientation),{'default','landscape'})),strcat("orientation kwd '",obj.orientation,"' not recognized for style '",obj.style,"'"));
%                     switch lower(obj.orientation)
%                         case 'landscape'
%                             temp = obj.pgw;
%                             obj.pgw = obj.pgh;
%                             obj.pgh = temp;
%                             clear temp;
%                     end
                    
                    obj.fontsize = 10; %text header
                    obj.font = 'Source Sans Pro'; % getting PDF error in OverLeaf...
                    obj.font = 'Arial';
            end
            
%             switch lower(obj.journal)
%                 case {'elsevier'}
%                     obj.pgw = 19;
%                     obj.pgh = 22;
%                     
%                     obj.pgw_sc = 9;  % single col
%                     obj.pgw_dc = 19; % double col
%                     obj.pgw_hc = 14; % half col
%                     
%                 case {'hess'}
%                     obj.pgw = 19;
%                     obj.pgh = 22;
%                     
%                     obj.pgw_sc = 8.3;  % single col
%                     obj.pgw_dc = 12; % double col
% %                     obj.pgw_hc = 14; % half col
%                     
%             end
            
            obj.c = colors(obj.theme);
            obj.cs = struct2cell(obj.c);
            obj.lns = repmat({'o-','x-','+-','sq-','d-'},[1,50]);
            obj.mks = repmat({'o','x','+','sq','d'},[1,50]);
            obj = obj.rearrange;
            obj = obj.check_second_axes;
        end
        
        
        obj = rearrange(obj);
        obj = check_second_axes(obj);
        obj = enumerate(obj,varargin);
        
        fh = apply(obj, frac, marg, varargin);
        fh = apply2(obj, frac, varargin);
        
        
        remove_inner(obj,elements);
        
        share_lims(obj,axis);
        squeeze_ticks(obj,axis,p);
        save(obj, savepath, varargin);
        
        
    end
    
    

    %
    % gp = struct();
    % gp.style = gfx_style;
    % gp.theme = gfx_theme;
    %
    % gp.apply = @gfx_apply;
    
    % gp.sqlims = @apply_sqlims;
    % gp.save = @save_fig;
    % gp.save_gif = @save_gif;
    %
    %
    
end


    



