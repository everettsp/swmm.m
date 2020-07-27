k=1; hid(k).code = 0; hid(k).descr = 'no event'; 
    hid(k).mark = '.'; hid(k).col = 'k'; hid(k).size = 2; hid(k).width = 1;
    
k=2; hid(k).code = 2; hid(k).descr = 'peak'; 
    hid(k).mark = '^'; hid(k).col = [1 0 1]; hid(k).size = 2; hid(k).width = 2;
    
k=3; hid(k).code = 1; hid(k).descr = 'rising'; 
    hid(k).mark = '<'; hid(k).col = [1 0 0]; hid(k).size = 2; hid(k).width = 2;
    
k=4; hid(k).code = -1; hid(k).descr = 'falling'; 
    hid(k).mark = '>'; hid(k).col = [0 0 1]; hid(k).size = 2; hid(k).width = 2;
    
k=5; hid(k).code = -2; hid(k).descr = 'valley'; 
    hid(k).mark = 'v'; hid(k).col = [0 1 0]; hid(k).size = 2; hid(k).width = 2;
    


plot(t,'k-','DisplayName','Flow')
hold on
for ii = 1:numel(hid)
    plot(find(tagEvent == hid(ii).code),t(tagEvent == hid(ii).code),hid(ii).mark,'DisplayName',hid(ii).descr,...
        'Color',hid(ii).col,'LineWidth',hid(ii).width)
end
legend('location','best')