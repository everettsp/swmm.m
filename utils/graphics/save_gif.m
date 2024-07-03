function save_gif(ffile,compl)
    fh = gcf;
    frame = getframe(fh);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    % Write to the GIF File
    
    if compl == 0
        imwrite(imind,cm,[ffile '.gif'],'gif','WriteMode','overwrite','DelayTime',0.5,'Loopcount',inf);
    elseif compl == 1
        imwrite(imind,cm,[ffile '.gif'],'gif','WriteMode','append','DelayTime',5); 
    else
        imwrite(imind,cm,[ffile '.gif'],'gif','WriteMode','append','DelayTime',0.5);
    end
end