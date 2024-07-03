function save_fig(savepath,fileformats)
    fh = gcf;
    fh.Renderer = 'Painters'; % manually set renderer to ensure MATLAB does not default to bitmap

    if ~isfolder([savepath,'/'])
        error('save location not found')
    end
    
    if strcmp(fh.Name,'')
        error('figure name empty, cannot save file')
    end
    
    if nargin < 2
        fileformats = {'fig','svg','png','pdf'};
    end
    
    if ~iscell(fileformats)
        fileformats = {fileformats};
    end
    
    for ii = 1:numel(fileformats)
        if ~isfolder([savepath,'/',fileformats{ii}])
            disp(['fig subfolder not found, creating subfolder for .' fileformats{ii}])
            mkdir([savepath '/' fileformats{ii}])
        end
        switch fileformats{ii}
            case {'tiff','png','pdf','svg'}
                print(fh,[savepath,'/',fileformats{ii},'/',fh.Name],['-d',fileformats{ii}])
            case {'fig'}
                savefig([savepath,'/',fileformats{ii},'/',fh.Name])
            otherwise
                error(strcat("file format '",fileformats{ii},"' not recognized, modify save_fig script"))
        end 
    end

    disp('figures saved successfully')
%     export_fig([savepath '/figures/svg/' fh.Name],'-svg','-nocrop')
%     export_fig([savepath '/figures/tiff/' fh.Name],'-tiff','-nocrop')
%     savefig([savepath '/figures/fig/' fh.Name])