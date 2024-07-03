function save(obj,savepath,varargin)
fh = obj.fh;
fh.Renderer = 'Painters'; % manually set renderer to ensure MATLAB does not default to bitmap

if ~isfolder([savepath,'/'])
    error('save location not found')
end

if strcmp(fh.Name,'')
    error('figure name empty, cannot save file')
end


par = inputParser;
addParameter(par,'formats',{'fig','svg','png','pdf'})
parse(par,varargin{:})
fileformats = par.Results.formats;

if ~iscell(fileformats)
    fileformats = {fileformats};
end



for ii = 1:numel(fileformats)
    
    fig_subfolder = fileformats{ii};
    if numel(fileformats) == 1
        fig_subfolder = '';
    end
    
    if ~isfolder([savepath,'/',fileformats{ii}])
        disp(['fig subfolder not found, creating subfolder for .' fileformats{ii}])
        mkdir([savepath '/' fig_subfolder])
    end
    switch fig_subfolder
        case {'tiff','png','pdf','svg'}
            print(fh,[savepath,'/',fig_subfolder,'/',fh.Name],['-d',fileformats{ii}])
        case {'fig'}
            savefig([savepath,'/',fig_subfolder,'/',fh.Name])
        otherwise
            error(strcat("file format '",fileformats{ii},"' not recognized, modify save_fig script"))
    end
end

disp('figures saved successfully')
%     export_fig([savepath '/figures/svg/' fh.Name],'-svg','-nocrop')
%     export_fig([savepath '/figures/tiff/' fh.Name],'-tiff','-nocrop')
%     savefig([savepath '/figures/fig/' fh.Name])