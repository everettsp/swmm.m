function archive_directory(savepath)
if strcmp(savepath(end),'\'); savepath = savepath(1:(end-1)); end
if 7 == exist(savepath,'dir')
        archiveNum = 1;
        while 7 == exist([savepath '_archive' num2str(archiveNum)],'dir') %find archive number that does not already exist
            archiveNum = archiveNum + 1;
        end
        sprintf('WARNING: %d existing directories found with same path, archiving...',archiveNum)
        movefile(savepath,[savepath '_archive' num2str(archiveNum)]) %move to archive
end
mkdir(savepath)
mkdir([savepath '\figures'])
end