function cfg = get_class_config()

cfg = struct();
gp = gfx('elsevier','lassonde');

cfg(1).lbl = 'MMP (class 1 events)';
cfg(2).lbl = 'MMP (class 2 events)';
cfg(3).lbl = 'MMP (class 3 events)';
cfg(numel(cfg)+1).lbl = 'MMP (classes 1-3 events)';
cfg(numel(cfg)+2).lbl = 'SMP';

cfg(1).col = gp.c.green;
cfg(2).col = gp.c.purple;
cfg(3).col = gp.c.yellow;
cfg(4).col = gp.c.blue;
cfg(5).col = gp.c.red;

cfg(1).class = 1;
cfg(2).class = 2;
cfg(3).class = 12;

cfg(1).idx = [];
        
end