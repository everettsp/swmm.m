function XmovPc = prctile_moving(x,pc,window)

windowLeft = window(1);
windowRight = window(2);
XmovPc = nan(length(x),1);

for i = 1 : length(x)
    window = (i-windowLeft):(windowRight+i);
    if window(1) < 1
        window = window(find(1 == window):end);
    end
    if window(end) > length(x)
        window = window(1:find(length(x) == window));
    end
    Xselection = x(window);
    XmovPc(i) = prctile(Xselection,pc);
end