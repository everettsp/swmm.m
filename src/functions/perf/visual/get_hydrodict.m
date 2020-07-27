function hid = get_hydrodict()

cols = get_colmat('lassonde');
lw = 2;
ms = 2;

%Two incides for all hydro classes, representing obs and modelled respectivelly
for k = 1:2
j=1; hid(j,k).code = 0; hid(j,k).descr = 'no event'; 
    hid(j,k).mark = '.'; hid(j,k).col = 'k'; hid(j,k).size = ms; hid(j,k).lw = lw;
    
j=2; hid(j,k).code = 2; hid(j,k).descr = 'Peak'; 
    hid(j,k).mark = '^'; hid(j,k).col = cols(5,:); hid(j,k).size = ms*2; hid(j,k).lw = lw;

j=3; hid(j,k).code = 1; hid(j,k).descr = 'Rising (Obs.)'; 
    hid(j,k).mark = 'o-'; hid(j,k).col = cols(4,:); hid(j,k).size = ms; hid(j,k).lw = lw;
    
    if k == 2 % if it's the modelled k, change the colour
        hid(j,k).col = cols(3,:);
        hid(j,k).descr = 'Rising (Pred.)';
    end

%make the falling limb a brigher shade of the rising limb...
colFall = hid(3,k).col * 2;
colFall(colFall > 1) = 1;

j=4; hid(j,k).code = -1; hid(j,k).descr = 'Falling (Obs.)'; 
    hid(j,k).mark = 'o-'; hid(j,k).col = colFall; hid(j,k).size = ms; hid(j,k).lw = lw;
    
    if k == 2 % if it's the modelled k, change the colour
        hid(j,k).descr = 'Falling (Pred.)';
    end

j=5; hid(j,k).code = -2; hid(j,k).descr = 'Valley'; 
    hid(j,k).mark = 'v'; hid(j,k).col = cols(5,:); hid(j,k).size = ms*2; hid(j,k).lw = lw;
    
j=6; hid(j,k).code = 4; hid(j,k).descr = 'Start'; 
    hid(j,k).mark = '<'; hid(j,k).col = cols(2,:); hid(j,k).size = ms*2; hid(j,k).lw = lw;
    
j=7; hid(j,k).code = -4; hid(j,k).descr = 'End'; 
    hid(j,k).mark = '>'; hid(j,k).col = cols(2,:); hid(j,k).size = ms*2; hid(j,k).lw = lw;
end